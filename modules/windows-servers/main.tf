# -----------------------------------------------------------------------------
# main.tf (windows-servers module)
# Two Windows Server member servers (one per AZ) that join the AWS Managed AD
# domain AUTOMATICALLY through Systems Manager.
#
# There is no RDP port, no key pair and no public IP. Administrators connect
# through Session Manager / Fleet Manager over the VPC endpoints from step 2.
# -----------------------------------------------------------------------------

# =============================================================================
# IAM: the servers' identity
# =============================================================================
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "servers" {
  name               = "${var.name}-windows-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json

  tags = merge(var.tags, { Name = "${var.name}-windows-role" })
}

# Lets the SSM agent register, so we can open sessions with no RDP.
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.servers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Lets the SSM domain-join document add the instance to the directory.
resource "aws_iam_role_policy_attachment" "directory_access" {
  role       = aws_iam_role.servers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
}

resource "aws_iam_instance_profile" "servers" {
  name = "${var.name}-windows-profile"
  role = aws_iam_role.servers.name

  tags = merge(var.tags, { Name = "${var.name}-windows-profile" })
}

# =============================================================================
# Security group: no inbound rules at all
# =============================================================================
resource "aws_security_group" "servers" {
  name        = "${var.name}-windows-sg"
  description = "Windows member servers: no inbound access, outbound to the VPC only"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name}-windows-sg" })
}

# Outbound: the VPC only. Joining a domain and using the file share need many
# ports (DNS, Kerberos, LDAP, SMB, RPC), so we allow all protocols, but ONLY
# toward the VPC. The VPC has no route to the internet, and later the VPN adds
# the on-premises range. Nothing here can talk to the internet.
resource "aws_vpc_security_group_egress_rule" "servers_to_vpc" {
  security_group_id = aws_security_group.servers.id
  description       = "All traffic to the VPC (domain controllers, endpoints, file share)"
  ip_protocol       = "-1"
  cidr_ipv4         = var.vpc_cidr
}

# =============================================================================
# The servers
# =============================================================================
resource "aws_instance" "windows" {
  count = length(var.subnet_ids)

  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id                   = var.subnet_ids[count.index] # one per AZ
  vpc_security_group_ids      = [aws_security_group.servers.id]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.servers.name

  # No key_name on purpose: nobody logs in with a key pair or a retrieved
  # Administrator password. Access is through SSM, and domain accounts after the join.

  ebs_optimized = true
  monitoring    = true # detailed (1-minute) CloudWatch metrics

  # IMDSv2 only: requests need a session token, which blocks SSRF attacks
  # from stealing the instance's credentials.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # Encrypted gp3 root volume.
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(var.tags, {
    Name = "${var.name}-win-${count.index + 1}"
    Role = "member-server"
  })

  volume_tags = merge(var.tags, { Name = "${var.name}-win-${count.index + 1}-root" })

  # The default AMI is an SSM alias that AWS resolves at launch to a concrete
  # AMI ID. Without this, every plan would see the real ID differ from the alias
  # and wrongly propose replacing the servers.
  lifecycle {
    ignore_changes = [ami]
  }

  # The role needs its permissions before the SSM agent starts.
  depends_on = [
    aws_iam_role_policy_attachment.ssm_core,
    aws_iam_role_policy_attachment.directory_access,
  ]
}

# =============================================================================
# Automatic domain join
# =============================================================================
# An SSM command document that runs the built-in "aws:domainJoin" plugin on the
# instance. It needs the directory ID, the domain name and the DNS server IPs.
resource "aws_ssm_document" "domain_join" {
  name            = "${var.name}-join-domain"
  document_type   = "Command"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Join instances to the ${var.directory_name} domain"
    runtimeConfig = {
      "aws:domainJoin" = {
        properties = {
          directoryId    = var.directory_id
          directoryName  = var.directory_name
          dnsIpAddresses = var.dns_ip_addresses
        }
      }
    }
  })

  tags = merge(var.tags, { Name = "${var.name}-join-domain" })
}

# An association = "run this document on these instances". It applies as soon as
# each instance's SSM agent comes online, so the servers join with no manual step.
resource "aws_ssm_association" "domain_join" {
  name             = aws_ssm_document.domain_join.name
  association_name = "${var.name}-join-domain"

  targets {
    key    = "InstanceIds"
    values = aws_instance.windows[*].id
  }
}
