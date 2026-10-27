# -----------------------------------------------------------------------------
# variables.tf
# Inputs for the lab environment. Validation fails early and clearly.
# -----------------------------------------------------------------------------
variable "project" {
  description = "Project name, used in resource names and tags."
  type        = string
  default     = "hybrid"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.project))
    error_message = "Project must be 3-20 characters: lowercase letters, numbers, hyphens."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "lab"
}

variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "mock_mode" {
  description = "true = fake credentials and no calls to AWS (offline plan). false for a real deployment."
  type        = bool
  default     = true
}

variable "azs" {
  description = "Availability zones. Passed in (not looked up) so plan works without AWS credentials."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "onprem_cidr" {
  description = "Address range of the simulated on-premises network. The VPC must never overlap it."
  type        = string
  default     = "192.168.0.0/16"

  validation {
    condition     = can(cidrhost(var.onprem_cidr, 0))
    error_message = "onprem_cidr must be a valid CIDR block, e.g. 192.168.0.0/16."
  }
}

variable "vpc_cidr" {
  description = "Address range of the AWS VPC. Must be a /16 and must not overlap onprem_cidr."
  type        = string
  default     = "10.2.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0)) && endswith(var.vpc_cidr, "/16")
    error_message = "vpc_cidr must be a valid /16 CIDR block, e.g. 10.2.0.0/16."
  }

  # Overlapping ranges make routing over the VPN impossible: a packet for an
  # address that exists on both sides has no way to know where to go.
  #
  # Terraform has no built-in "do these ranges overlap" function, so we compare
  # the leading bits. The VPC is a /16, so only its first two octets matter.
  # Take the shorter of the two prefix lengths (at most 16), keep only that many
  # leading bits of each address, and check whether they are equal.
  # Example: 10.2.0.0/16 vs 10.0.0.0/8 -> compare the first 8 bits -> both 10 -> overlap.
  validation {
    condition = (
      floor(
        (tonumber(split(".", var.vpc_cidr)[0]) * 256 + tonumber(split(".", var.vpc_cidr)[1]))
        / pow(2, 16 - min(16, tonumber(split("/", var.onprem_cidr)[1])))
        ) != floor(
        (tonumber(split(".", var.onprem_cidr)[0]) * 256 + tonumber(split(".", var.onprem_cidr)[1]))
        / pow(2, 16 - min(16, tonumber(split("/", var.onprem_cidr)[1])))
      )
    )
    error_message = "vpc_cidr overlaps onprem_cidr. Pick a range that does not overlap the on-premises network."
  }
}
