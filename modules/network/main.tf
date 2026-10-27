# -----------------------------------------------------------------------------
# main.tf (network module)
# A fully PRIVATE network: no internet gateway, no NAT gateway.
#
# Why? This models a company extending its internal network into AWS. Servers
# and directory controllers are reachable only over the VPN (added later) and
# reach AWS services through VPC endpoints. Nothing here has a public IP.
#
# Three subnet tiers, two AZs each:
#   directory  AWS Managed Microsoft AD domain controllers
#   servers    Windows servers and the FSx file share
#   endpoints  VPC endpoints (SSM) and, later, Route 53 Resolver endpoints
# -----------------------------------------------------------------------------

locals {
  # SSM needs these three endpoints to manage instances with no internet access.
  ssm_endpoint_services = toset(["ssm", "ssmmessages", "ec2messages"])
}

# --- The VPC -----------------------------------------------------------------
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  # Both are required: the directory and the DNS resolver rely on DNS in the VPC.
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.name}-vpc" })
}

# Lock down the default security group (no rules at all). We create our own.
resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.name}-default-sg-locked" })
}

# --- Subnets -------------------------------------------------------------------
# count loops once per AZ. Index 0 pairs with azs[0], index 1 with azs[1].
resource "aws_subnet" "directory" {
  count = length(var.azs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.directory_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, {
    Name = "${var.name}-directory-${var.azs[count.index]}"
    Tier = "directory"
  })
}

resource "aws_subnet" "servers" {
  count = length(var.azs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.server_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, {
    Name = "${var.name}-servers-${var.azs[count.index]}"
    Tier = "servers"
  })
}

resource "aws_subnet" "endpoints" {
  count = length(var.azs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.endpoint_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, {
    Name = "${var.name}-endpoints-${var.azs[count.index]}"
    Tier = "endpoints"
  })
}

# --- Route table ---------------------------------------------------------------
# ONE table for every subnet, with NO routes of its own: only the implicit
# "local" route (traffic inside the VPC) exists. Later steps add routes learned
# from the VPN (route propagation) and the S3 gateway endpoint below.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.name}-private-rt" })
}

resource "aws_route_table_association" "directory" {
  count = length(var.azs)

  subnet_id      = aws_subnet.directory[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "servers" {
  count = length(var.azs)

  subnet_id      = aws_subnet.servers[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "endpoints" {
  count = length(var.azs)

  subnet_id      = aws_subnet.endpoints[count.index].id
  route_table_id = aws_route_table.private.id
}

# --- VPC endpoints: how private servers reach AWS services ------------------------

# S3 gateway endpoint: free, adds a route to the table above. Used for agent
# and patch downloads without any internet path.
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = merge(var.tags, { Name = "${var.name}-s3-endpoint" })
}

# Security group for the interface endpoints: HTTPS from inside the VPC only.
resource "aws_security_group" "endpoints" {
  name        = "${var.name}-endpoints-sg"
  description = "VPC interface endpoints: HTTPS from inside the VPC only"
  vpc_id      = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.name}-endpoints-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "endpoints_https" {
  security_group_id = aws_security_group.endpoints.id
  description       = "HTTPS from the VPC"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = var.vpc_cidr
}

# Interface endpoints for Systems Manager. With these, Session Manager and the
# domain-join automation work with no internet access and no RDP port open.
# Each one costs roughly $7 per month per AZ, which is the price of staying private.
resource "aws_vpc_endpoint" "ssm" {
  for_each = local.ssm_endpoint_services

  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.endpoints[*].id
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = merge(var.tags, { Name = "${var.name}-${each.key}-endpoint" })
}

# --- VPC Flow Logs -------------------------------------------------------------------
# Records every accepted/rejected connection: essential for security and debugging.
resource "aws_cloudwatch_log_group" "flow_logs" {
  # checkov:skip=CKV_AWS_158: A KMS key policy needs the account ID, which cannot be looked up offline. Add a customer-managed key for a real deployment.
  name              = "/aws/vpc/${var.name}/flow-logs"
  retention_in_days = var.flow_log_retention_days

  tags = merge(var.tags, { Name = "${var.name}-flow-logs" })
}

# Trust policy: only the VPC Flow Logs service may assume this role.
data "aws_iam_policy_document" "flow_logs_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

# Permission policy: least privilege. It may write ONLY to this one log group.
data "aws_iam_policy_document" "flow_logs_write" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = ["${aws_cloudwatch_log_group.flow_logs.arn}:*"]
  }
}

resource "aws_iam_role" "flow_logs" {
  name               = "${var.name}-vpc-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.flow_logs_assume.json

  tags = merge(var.tags, { Name = "${var.name}-vpc-flow-logs-role" })
}

resource "aws_iam_role_policy" "flow_logs" {
  name   = "write-flow-logs"
  role   = aws_iam_role.flow_logs.id
  policy = data.aws_iam_policy_document.flow_logs_write.json
}

resource "aws_flow_log" "this" {
  vpc_id          = aws_vpc.this.id
  traffic_type    = "ALL" # accepted AND rejected traffic
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
  iam_role_arn    = aws_iam_role.flow_logs.arn

  tags = merge(var.tags, { Name = "${var.name}-flow-log" })
}
