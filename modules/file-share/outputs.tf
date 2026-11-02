# -----------------------------------------------------------------------------
# outputs.tf (file-share module)
# -----------------------------------------------------------------------------
output "file_system_id" {
  description = "ID of the FSx file system."
  value       = aws_fsx_windows_file_system.this.id
}

output "dns_name" {
  description = "DNS name of the file system. Map the share as \\\\<dns_name>\\share."
  value       = aws_fsx_windows_file_system.this.dns_name
}

output "security_group_id" {
  description = "Security group of the file system."
  value       = aws_security_group.file_share.id
}
