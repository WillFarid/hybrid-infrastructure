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
