# -----------------------------------------------------------------------------
# variables.tf (windows-servers module)
# -----------------------------------------------------------------------------
variable "name" {
  description = "Name prefix for all resources, e.g. hybrid-lab."
  type        = string
}

variable "vpc_id" {
  description = "VPC the servers run in."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR of the VPC. The servers may send traffic only inside it."
  type        = string
}

variable "subnet_ids" {
  description = "Server subnets. One Windows server is created per subnet, so one per AZ."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 1
    error_message = "Provide at least one subnet."
  }
}

variable "directory_id" {
  description = "ID of the AWS Managed AD directory the servers join."
  type        = string
}

variable "directory_name" {
  description = "Fully qualified domain name of the directory, e.g. cloud.example.com."
  type        = string
}

variable "dns_ip_addresses" {
  description = "IP addresses of the domain controllers (they are the DNS servers)."
  type        = list(string)
}

variable "ami_id" {
  description = <<-EOT
    AMI to launch. The default is an SSM parameter alias that AWS resolves at
    launch time to the latest Windows Server 2022 image, so no lookup (and no
    AWS call) is needed to plan. To pin an exact image, pass an AMI ID instead.
  EOT
  type        = string
  default     = "resolve:ssm:/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base"
}

variable "instance_type" {
  description = "EC2 instance type. Windows needs at least 2 GiB of memory."
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB (Windows needs at least 30)."
  type        = number
  default     = 50

  validation {
    condition     = var.root_volume_size >= 30
    error_message = "Windows Server needs a root volume of at least 30 GiB."
  }
}

variable "tags" {
  description = "Extra tags merged onto resources."
  type        = map(string)
  default     = {}
}
