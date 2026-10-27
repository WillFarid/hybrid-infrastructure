# -----------------------------------------------------------------------------
# main.tf (lab root module)
# Calls the child modules. Built step by step: network first.
# -----------------------------------------------------------------------------
locals {
  name = "${var.project}-${var.environment}" # e.g. hybrid-lab

  # Carve /24 subnets out of the /16 with cidrsubnet(range, 8, N).
  # For 10.2.0.0/16 the numbers below give 10.2.10.0/24, 10.2.11.0/24, and so on.
  # Gaps between 10, 20 and 30 leave room to add subnets later.
  directory_subnet_cidrs = [for n in [10, 11] : cidrsubnet(var.vpc_cidr, 8, n)]
  server_subnet_cidrs    = [for n in [20, 21] : cidrsubnet(var.vpc_cidr, 8, n)]
  endpoint_subnet_cidrs  = [for n in [30, 31] : cidrsubnet(var.vpc_cidr, 8, n)]
}

module "network" {
  source = "../../modules/network" # up two folders (lab -> environments -> repo), then modules/network

  name     = local.name
  region   = var.region
  vpc_cidr = var.vpc_cidr
  azs      = var.azs

  directory_subnet_cidrs = local.directory_subnet_cidrs
  server_subnet_cidrs    = local.server_subnet_cidrs
  endpoint_subnet_cidrs  = local.endpoint_subnet_cidrs
}

# --- Identity: AWS Managed Microsoft AD ----------------------------------------------
module "directory" {
  source = "../../modules/directory"

  name       = local.name
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.directory_subnet_ids # chained from the network module

  domain_name    = var.directory_domain_name
  netbios_name   = var.directory_netbios_name
  admin_password = var.directory_admin_password
  edition        = "Standard"
}
