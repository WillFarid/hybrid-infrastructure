# -----------------------------------------------------------------------------
# variables.tf (network module)
# -----------------------------------------------------------------------------
variable "name" {
  description = "Name prefix for all resources, e.g. hybrid-lab."
  type        = string
}

variable "region" {
  description = "AWS region. Used to build VPC endpoint service names (passed in, so plan works offline)."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC. Must not overlap with the on-premises network."
  type        = string
}

variable "azs" {
  description = "Availability zones to use. Managed AD needs at least two."
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 2
    error_message = "Use at least 2 availability zones (AWS Managed AD requires two)."
  }
}

variable "directory_subnet_cidrs" {
  description = "CIDRs for the subnets that hold the Managed AD domain controllers, one per AZ."
  type        = list(string)
}

variable "server_subnet_cidrs" {
  description = "CIDRs for the subnets that hold the Windows servers and the file share, one per AZ."
  type        = list(string)
}

variable "endpoint_subnet_cidrs" {
  description = "CIDRs for the subnets that hold VPC endpoints and (later) the DNS resolver endpoints, one per AZ."
  type        = list(string)
}

variable "flow_log_retention_days" {
  description = "How long to keep VPC flow logs in CloudWatch."
  type        = number
  default     = 365
}

variable "tags" {
  description = "Extra tags merged onto resources."
  type        = map(string)
  default     = {}
}
