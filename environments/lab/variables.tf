# -----------------------------------------------------------------------------
# variables.tf
# We add more variables (CIDRs, domain names, passwords) as each step needs them.
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
