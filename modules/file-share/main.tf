# -----------------------------------------------------------------------------
# main.tf (file-share module)
# Amazon FSx for Windows File Server: a managed SMB file share, the cloud
# replacement for a Windows file server. It uses the AWS Managed AD directory,
# so permissions are NTFS ACLs and Kerberos, exactly like on premises.
#
# Builds: encryption key, audit log group, security group chain, the file system.
# -----------------------------------------------------------------------------

locals {
  multi_az = var.deployment_type == "MULTI_AZ_1"
}

# =============================================================================
# Encryption key (customer-managed)
# =============================================================================
resource "aws_kms_key" "fsx" {
  # checkov:skip=CKV2_AWS_64: The AWS default key policy is used. An explicit policy needs the account ID, which cannot be looked up offline.
  description             = "${var.name} FSx encryption key"
  enable_key_rotation     = true # AWS rotates the key material yearly
  deletion_window_in_days = 30   # safety net: a deleted key can be recovered for 30 days

  tags = merge(var.tags, { Name = "${var.name}-fsx-key" })
}

resource "aws_kms_alias" "fsx" {
  name          = "alias/${var.name}-fsx"
  target_key_id = aws_kms_key.fsx.key_id
}

# =============================================================================
# Audit log: who opened, changed or was denied access to which file
# =============================================================================
# FSx requires the log group name to start with /aws/fsx.
resource "aws_cloudwatch_log_group" "fsx_audit" {
  # checkov:skip=CKV_AWS_158: A KMS key policy needs the account ID, which cannot be looked up offline. Add a customer-managed key for a real deployment.
  name              = "/aws/fsx/${var.name}-file-share"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, { Name = "${var.name}-fsx-audit-logs" })
}

# =============================================================================
# Security group: only the servers may reach the share
# =============================================================================
resource "aws_security_group" "file_share" {
  name        = "${var.name}-fsx-sg"
  description = "FSx for Windows: SMB only from the Windows servers"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name}-fsx-sg" })
}

# SMB, the file-sharing protocol. The source is the servers' SECURITY GROUP, not an
# IP range: any machine wearing that group can connect, and nothing else can.
resource "aws_vpc_security_group_ingress_rule" "smb_from_servers" {
  security_group_id            = aws_security_group.file_share.id
  description                  = "SMB from the Windows servers"
  ip_protocol                  = "tcp"
  from_port                    = 445
  to_port                      = 445
  referenced_security_group_id = var.client_security_group_id
}

# Remote PowerShell, used by administrators to manage shares and quotas.
resource "aws_vpc_security_group_ingress_rule" "powershell_from_servers" {
  security_group_id            = aws_security_group.file_share.id
  description                  = "Remote PowerShell administration from the Windows servers"
  ip_protocol                  = "tcp"
  from_port                    = 5985
  to_port                      = 5985
  referenced_security_group_id = var.client_security_group_id
}

# Outbound: the VPC only. The file system must reach the domain controllers
# (DNS, Kerberos, LDAP, RPC), so all protocols are allowed, but only inside the VPC.
resource "aws_vpc_security_group_egress_rule" "to_vpc" {
  security_group_id = aws_security_group.file_share.id
  description       = "All traffic to the VPC (domain controllers)"
  ip_protocol       = "-1"
  cidr_ipv4         = var.vpc_cidr
}

# =============================================================================
# The file system
# =============================================================================
resource "aws_fsx_windows_file_system" "this" {
  active_directory_id = var.directory_id

  deployment_type = var.deployment_type
  storage_type    = "SSD"

  storage_capacity    = var.storage_capacity
  throughput_capacity = var.throughput_capacity

  # Multi-AZ: a primary in the first subnet and a standby in the second.
  # Single-AZ: only one subnet is allowed.
  subnet_ids          = local.multi_az ? var.subnet_ids : [var.subnet_ids[0]]
  preferred_subnet_id = local.multi_az ? var.subnet_ids[0] : null
  security_group_ids  = [aws_security_group.file_share.id]

  # Encrypted at rest with our own key.
  kms_key_id = aws_kms_key.fsx.arn

  # Backups
  automatic_backup_retention_days   = var.backup_retention_days
  daily_automatic_backup_start_time = "03:00" # UTC
  copy_tags_to_backups              = true
  skip_final_backup                 = var.skip_final_backup

  weekly_maintenance_start_time = "7:05:00" # day:HH:MM, 7 = Sunday, UTC

  # Log every successful and failed file access and share access.
  audit_log_configuration {
    audit_log_destination             = aws_cloudwatch_log_group.fsx_audit.arn
    file_access_audit_log_level       = "SUCCESS_AND_FAILURE"
    file_share_access_audit_log_level = "SUCCESS_AND_FAILURE"
  }

  tags = merge(var.tags, { Name = "${var.name}-file-share" })
}
