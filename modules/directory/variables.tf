# -----------------------------------------------------------------------------
# variables.tf (directory module)
# -----------------------------------------------------------------------------
variable "name" {
  description = "Name prefix for all resources, e.g. hybrid-lab."
  type        = string
}

variable "vpc_id" {
  description = "VPC the directory is created in."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the domain controllers. Exactly two, in different availability zones."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) == 2
    error_message = "AWS Managed Microsoft AD needs exactly two subnets, in different availability zones."
  }
}

variable "domain_name" {
  description = "Fully qualified domain name of the directory, e.g. cloud.example.com. Must differ from the on-premises domain."
  type        = string

  validation {
    condition     = can(regex("^([a-z0-9]([a-z0-9-]*[a-z0-9])?\\.)+[a-z]{2,}$", var.domain_name))
    error_message = "domain_name must be a lowercase fully qualified domain name, e.g. cloud.example.com."
  }
}

variable "netbios_name" {
  description = "NetBIOS (short) name of the domain, e.g. CLOUD. Up to 15 characters."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{1,15}$", var.netbios_name))
    error_message = "netbios_name must be 1-15 characters: letters, numbers and hyphens."
  }
}

variable "admin_password" {
  description = <<-EOT
    Initial password of the directory's built-in "Admin" account.
    AWS Managed AD cannot generate this for us, so it is the one secret that
    passes through Terraform. It is marked sensitive and ignored after creation.
  EOT
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition     = length(var.admin_password) >= 8 && length(var.admin_password) <= 64
    error_message = "The directory admin password must be 8-64 characters long."
  }

  # AWS requires characters from at least 3 of these 4 groups.
  validation {
    condition = (
      (can(regex("[a-z]", var.admin_password)) ? 1 : 0) +
      (can(regex("[A-Z]", var.admin_password)) ? 1 : 0) +
      (can(regex("[0-9]", var.admin_password)) ? 1 : 0) +
      (can(regex("[^a-zA-Z0-9]", var.admin_password)) ? 1 : 0)
    ) >= 3
    error_message = "The directory admin password needs characters from at least 3 of: lowercase, uppercase, digits, symbols."
  }

  # AWS rejects any password containing the word "admin".
  validation {
    condition     = !can(regex("(?i)admin", var.admin_password))
    error_message = "The directory admin password must not contain the word \"admin\"."
  }
}

variable "edition" {
  description = "Standard (up to about 30,000 objects) or Enterprise (up to about 500,000)."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Enterprise"], var.edition)
    error_message = "edition must be Standard or Enterprise."
  }
}

variable "log_retention_days" {
  description = "How long to keep directory security logs in CloudWatch."
  type        = number
  default     = 365
}

variable "tags" {
  description = "Extra tags merged onto resources."
  type        = map(string)
  default     = {}
}
