# -----------------------------------------------------------------------------
# outputs.tf (windows-servers module)
# -----------------------------------------------------------------------------
output "instance_ids" {
  description = "IDs of the Windows servers."
  value       = aws_instance.windows[*].id
}

output "private_ips" {
  description = "Private IP addresses of the Windows servers."
  value       = aws_instance.windows[*].private_ip
}

output "security_group_id" {
  description = "Security group of the servers. The file share allows SMB from this group."
  value       = aws_security_group.servers.id
}

output "role_name" {
  description = "Name of the servers' IAM role."
  value       = aws_iam_role.servers.name
}
