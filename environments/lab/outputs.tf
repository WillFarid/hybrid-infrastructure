# -----------------------------------------------------------------------------
# outputs.tf (lab root module)
# Nothing here is secret.
# -----------------------------------------------------------------------------
output "vpc_id" {
  description = "ID of the VPC."
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "Address range of the AWS side."
  value       = module.network.vpc_cidr
}

output "onprem_cidr" {
  description = "Address range of the simulated on-premises side (the VPN and DNS steps route to it)."
  value       = var.onprem_cidr
}

output "directory_id" {
  description = "ID of the AWS Managed AD directory."
  value       = module.directory.directory_id
}

output "directory_dns_ips" {
  description = "IP addresses of the domain controllers (also the VPC's DNS servers)."
  value       = module.directory.dns_ip_addresses
}

output "windows_server_private_ips" {
  description = "Private IP addresses of the domain-joined Windows servers."
  value       = module.windows_servers.private_ips
}
