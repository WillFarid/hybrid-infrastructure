# -----------------------------------------------------------------------------
# outputs.tf (hybrid-dns module)
# -----------------------------------------------------------------------------
output "inbound_endpoint_ips" {
  description = "IP addresses of the inbound resolver endpoint. Point an on-premises conditional forwarder for AWS names here."
  value       = [for a in aws_route53_resolver_endpoint.inbound.ip_address : a.ip]
}

output "resolver_rule_id" {
  description = "ID of the rule that forwards the on-premises domain to the on-premises DNS server."
  value       = aws_route53_resolver_rule.onprem.id
}

output "resolver_security_group_id" {
  description = "Security group of the resolver endpoints."
  value       = aws_security_group.resolver.id
}
