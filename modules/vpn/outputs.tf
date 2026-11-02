# -----------------------------------------------------------------------------
# outputs.tf (vpn module)
# Nothing here is secret. The tunnel pre-shared keys are deliberately NOT output.
# -----------------------------------------------------------------------------
output "vpn_connection_id" {
  description = "ID of the VPN connection."
  value       = aws_vpn_connection.this.id
}

output "tunnel1_address" {
  description = "Public IP of AWS tunnel endpoint 1. Configure this as a peer on the on-premises device."
  value       = aws_vpn_connection.this.tunnel1_address
}

output "tunnel2_address" {
  description = "Public IP of AWS tunnel endpoint 2. Configure this as a peer on the on-premises device."
  value       = aws_vpn_connection.this.tunnel2_address
}

output "vpn_gateway_id" {
  description = "ID of the virtual private gateway."
  value       = aws_vpn_gateway.this.id
}
