# -----------------------------------------------------------------------------
# variables.tf (hybrid-dns module)
# -----------------------------------------------------------------------------
variable "name" {
  description = "Name prefix for all resources, e.g. hybrid-lab."
  type        = string
}

variable "vpc_id" {
  description = "VPC the resolver endpoints and rule belong to."
  type        = string
}

variable "endpoint_subnet_ids" {
  description = "Subnets for the resolver endpoints (one per AZ). The first two are used."
  type        = list(string)

  validation {
    condition     = length(var.endpoint_subnet_ids) >= 2
    error_message = "Resolver endpoints need subnets in at least 2 availability zones."
  }
}

variable "onprem_cidr" {
  description = "Address range of the on-premises network. It may query the inbound endpoint."
  type        = string

  validation {
    condition     = can(cidrhost(var.onprem_cidr, 0))
    error_message = "onprem_cidr must be a valid CIDR block, e.g. 192.168.0.0/16."
  }
}

variable "onprem_domain_name" {
  description = "DNS name of the on-premises Active Directory domain, e.g. corp.example.com."
  type        = string

  validation {
    condition     = can(regex("^([a-z0-9]([a-z0-9-]*[a-z0-9])?\\.)+[a-z]{2,}$", var.onprem_domain_name))
    error_message = "onprem_domain_name must be a lowercase fully qualified domain name, e.g. corp.example.com."
  }
}

variable "onprem_dns_ip" {
  description = "IP address of the on-premises DNS server (a domain controller), reached over the VPN."
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.onprem_dns_ip))
    error_message = "onprem_dns_ip must be an IPv4 address, e.g. 192.168.1.10."
  }
}

variable "directory_id" {
  description = "ID of the AWS Managed AD directory that gets a conditional forwarder for the on-premises domain."
  type        = string
}

variable "tags" {
  description = "Extra tags merged onto resources."
  type        = map(string)
  default     = {}
}
