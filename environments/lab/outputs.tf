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

output "file_share_dns_name" {
  description = "DNS name of the file share. Map it as \\\\<dns_name>\\share from a domain-joined server."
  value       = module.file_share.dns_name
}

output "vpn_connection_id" {
  description = "ID of the Site-to-Site VPN connection."
  value       = module.vpn.vpn_connection_id
}

output "vpn_tunnel_addresses" {
  description = "Public IPs of the two AWS tunnel endpoints (peers for the on-premises device)."
  value       = [module.vpn.tunnel1_address, module.vpn.tunnel2_address]
}

output "dns_inbound_endpoint_ips" {
  description = "Resolver inbound endpoint IPs. The on-premises DNS server forwards AWS names to these."
  value       = module.hybrid_dns.inbound_endpoint_ips
}
