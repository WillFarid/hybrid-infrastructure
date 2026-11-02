# -----------------------------------------------------------------------------
# variables.tf (file-share module)
# -----------------------------------------------------------------------------
variable "name" {
  description = "Name prefix for all resources, e.g. hybrid-lab."
  type        = string
}

variable "vpc_id" {
  description = "VPC the file system belongs to."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR of the VPC. The file system may send traffic only inside it."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the file system (one per AZ). Multi-AZ uses two, single-AZ uses the first."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Provide two subnets in different availability zones."
  }
}

variable "directory_id" {
  description = "ID of the AWS Managed AD directory. It controls who can open the share."
  type        = string
}

variable "client_security_group_id" {
  description = "Security group of the machines allowed to reach the share (the Windows servers)."
  type        = string
}

variable "deployment_type" {
  description = "MULTI_AZ_1 (standby in a second AZ with automatic failover), SINGLE_AZ_1 or SINGLE_AZ_2."
  type        = string
  default     = "MULTI_AZ_1"

  validation {
    condition     = contains(["MULTI_AZ_1", "SINGLE_AZ_1", "SINGLE_AZ_2"], var.deployment_type)
    error_message = "deployment_type must be MULTI_AZ_1, SINGLE_AZ_1 or SINGLE_AZ_2."
  }
}

variable "storage_capacity" {
  description = "Storage in GiB. SSD file systems start at 32."
  type        = number
  default     = 32

  validation {
    condition     = var.storage_capacity >= 32
    error_message = "SSD file systems need at least 32 GiB."
  }
}

variable "throughput_capacity" {
  description = "Throughput in MB/s. Check the minimum for your deployment type before a real deployment."
  type        = number
  default     = 32

  validation {
    condition     = contains([8, 16, 32, 64, 128, 256, 512, 1024, 2048], var.throughput_capacity)
    error_message = "throughput_capacity must be one of 8, 16, 32, 64, 128, 256, 512, 1024, 2048."
  }
}

variable "backup_retention_days" {
  description = "Days to keep automatic daily backups (0 to 90)."
  type        = number
  default     = 7
}

variable "skip_final_backup" {
  description = "Skip the backup taken when the file system is deleted. true only for disposable labs."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "How long to keep file access audit logs in CloudWatch."
  type        = number
  default     = 365
}

variable "tags" {
  description = "Extra tags merged onto resources."
  type        = map(string)
  default     = {}
}
