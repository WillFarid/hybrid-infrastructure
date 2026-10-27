# -----------------------------------------------------------------------------
# outputs.tf (directory module)
# Nothing here is secret. The admin password is never output.
# -----------------------------------------------------------------------------
output "directory_id" {
  description = "ID of the directory. The Windows servers use it to join the domain."
  value       = aws_directory_service_directory.this.id
}

output "domain_name" {
  description = "Fully qualified domain name."
  value       = aws_directory_service_directory.this.name
}

output "dns_ip_addresses" {
  description = "IP addresses of the domain controllers (they are also the DNS servers)."
  value       = aws_directory_service_directory.this.dns_ip_addresses
}

output "security_group_id" {
  description = "Security group AWS created for the domain controllers. The VPN step opens it to the on-premises range."
  value       = aws_directory_service_directory.this.security_group_id
}
