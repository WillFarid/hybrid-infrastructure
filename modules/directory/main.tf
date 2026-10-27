# -----------------------------------------------------------------------------
# main.tf (directory module)
# AWS Managed Microsoft AD: a real Windows Server Active Directory, run by AWS.
# AWS patches, backs up and replaces the domain controllers; we manage the
# users, groups and Group Policy, exactly as on premises.
#
# Builds: the directory (2 domain controllers), DHCP options so the VPC uses the
# directory for DNS, and security event logs in CloudWatch.
# -----------------------------------------------------------------------------

resource "aws_directory_service_directory" "this" {
  name       = var.domain_name
  short_name = var.netbios_name
  password   = var.admin_password
  edition    = var.edition
  type       = "MicrosoftAD"

  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = var.subnet_ids # one domain controller per subnet, so one per AZ
  }

  tags = merge(var.tags, { Name = "${var.name}-directory" })

  # The password is only the INITIAL value. After creation, reset it out of band
  # (the AWS console or the "ds reset-user-password" CLI command) and let
  # Terraform ignore it, so the password in state is not the live one.
  lifecycle {
    ignore_changes = [password]
  }
}

# --- DNS for the whole VPC ---------------------------------------------------------
# Domain-joined servers find the domain controllers through DNS. A DHCP options
# set hands the directory's DNS servers to every instance in the VPC, and sets
# the default DNS suffix to our domain.
#
# To VERIFY in a real account: the directory's DNS forwards names it does not
# own (such as AWS service names) to the Amazon-provided resolver. The hybrid
# DNS step builds on that behavior.
resource "aws_vpc_dhcp_options" "this" {
  domain_name         = var.domain_name
  domain_name_servers = tolist(aws_directory_service_directory.this.dns_ip_addresses)

  tags = merge(var.tags, { Name = "${var.name}-dhcp-options" })
}

resource "aws_vpc_dhcp_options_association" "this" {
  vpc_id          = var.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.this.id
}

# --- Security event logs -------------------------------------------------------------
# Domain controller security events (logons, account changes) go to CloudWatch.
# Directory Service requires the log group to be named after the directory ID.
resource "aws_cloudwatch_log_group" "directory" {
  # checkov:skip=CKV_AWS_158: A KMS key policy needs the account ID, which cannot be looked up offline. Add a customer-managed key for a real deployment.
  name              = "/aws/directoryservice/${aws_directory_service_directory.this.id}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, { Name = "${var.name}-directory-logs" })
}

# Allow ONLY the Directory Service to write to this one log group.
data "aws_iam_policy_document" "directory_logs" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.directory.arn}:*"]

    principals {
      type        = "Service"
      identifiers = ["ds.amazonaws.com"]
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "directory" {
  policy_name     = "${var.name}-directory-logs"
  policy_document = data.aws_iam_policy_document.directory_logs.json
}

resource "aws_directory_service_log_subscription" "this" {
  directory_id   = aws_directory_service_directory.this.id
  log_group_name = aws_cloudwatch_log_group.directory.name

  depends_on = [aws_cloudwatch_log_resource_policy.directory]
}
