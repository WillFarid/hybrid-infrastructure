# -----------------------------------------------------------------------------
# variables.tf (vpn module)
# -----------------------------------------------------------------------------
variable "name" {
  description = "Name prefix for all resources, e.g. hybrid-lab."
  type        = string
}

variable "vpc_id" {
  description = "VPC the virtual private gateway is attached to."
  type        = string
}

variable "vpc_cidr" {
  description = "Address range of the AWS side. Used as the VPN's remote traffic selector."
  type        = string
}

variable "onprem_cidr" {
  description = "Address range of the on-premises network. Routed through the tunnels."
  type        = string

  validation {
    condition     = can(cidrhost(var.onprem_cidr, 0))
    error_message = "onprem_cidr must be a valid CIDR block, e.g. 192.168.0.0/16."
  }
}

variable "route_table_id" {
  description = "Route table that learns the on-premises route through the VPN (route propagation)."
  type        = string
}

variable "customer_gateway_ip" {
  description = "PUBLIC IP address of the on-premises VPN device. The default is a documentation address (RFC 5737), not a real device."
  type        = string
  default     = "203.0.113.10"

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.customer_gateway_ip))
    error_message = "customer_gateway_ip must be an IPv4 address, e.g. 203.0.113.10."
  }

  # The tunnel is built over the internet, so the device must have a public
  # address. Private ranges (RFC 1918) can never be reached from AWS.
  validation {
    condition     = !can(regex("^(10\\.|192\\.168\\.|172\\.(1[6-9]|2[0-9]|3[01])\\.)", var.customer_gateway_ip))
    error_message = "customer_gateway_ip must be a PUBLIC address. Private ranges cannot terminate an internet VPN."
  }
}

variable "customer_gateway_bgp_asn" {
  description = "BGP ASN of the on-premises device. Required by AWS even when static routing is used."
  type        = number
  default     = 65000

  validation {
    condition     = var.customer_gateway_bgp_asn >= 1 && var.customer_gateway_bgp_asn <= 2147483647
    error_message = "customer_gateway_bgp_asn must be between 1 and 2147483647."
  }
}

variable "amazon_side_asn" {
  description = "BGP ASN of the AWS side (virtual private gateway)."
  type        = number
  default     = 64512
}

variable "log_retention_days" {
  description = "How long to keep VPN tunnel logs in CloudWatch."
  type        = number
  default     = 365
}

variable "tags" {
  description = "Extra tags merged onto resources."
  type        = map(string)
  default     = {}
}
