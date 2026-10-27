# -----------------------------------------------------------------------------
# outputs.tf (network module)
# What the directory, servers, file share, VPN and DNS modules need.
# -----------------------------------------------------------------------------
output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "directory_subnet_ids" {
  description = "Subnets for the Managed AD domain controllers (one per AZ)."
  value       = aws_subnet.directory[*].id
}

output "server_subnet_ids" {
  description = "Subnets for the Windows servers and the file share (one per AZ)."
  value       = aws_subnet.servers[*].id
}

output "endpoint_subnet_ids" {
  description = "Subnets for VPC endpoints and the DNS resolver endpoints (one per AZ)."
  value       = aws_subnet.endpoints[*].id
}

output "private_route_table_id" {
  description = "The shared route table. The VPN module enables route propagation on it."
  value       = aws_route_table.private.id
}
