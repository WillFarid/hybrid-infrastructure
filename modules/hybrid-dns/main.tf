# -----------------------------------------------------------------------------
# main.tf (hybrid-dns module)
# Names must resolve in BOTH directions across the VPN, or nothing works:
# Kerberos, domain join and file shares all depend on DNS.
#
#   AWS -> on premises   a conditional forwarder on the Managed AD, plus a
#                        Route 53 Resolver outbound endpoint and forwarding rule
#   on premises -> AWS   a Route 53 Resolver inbound endpoint
#
# Two layers, because two things ask the questions:
#   * Domain members use the directory's DNS (set by the DHCP options in the
#     directory module). The conditional forwarder answers for the on-premises domain.
#   * Anything else in the VPC that uses the Route 53 Resolver directly follows
#     the forwarding rule. Both point at the same on-premises DNS server.
# -----------------------------------------------------------------------------

# =============================================================================
# Security group for the resolver endpoints
# =============================================================================
resource "aws_security_group" "resolver" {
  name        = "${var.name}-resolver-sg"
  description = "Route 53 Resolver endpoints: DNS to and from the on-premises network only"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name}-resolver-sg" })
}

# Inbound endpoint: on-premises DNS servers send queries for AWS names here.
resource "aws_vpc_security_group_ingress_rule" "dns_udp_from_onprem" {
  security_group_id = aws_security_group.resolver.id
  description       = "DNS (UDP) from the on-premises network"
  ip_protocol       = "udp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = var.onprem_cidr
}

resource "aws_vpc_security_group_ingress_rule" "dns_tcp_from_onprem" {
  security_group_id = aws_security_group.resolver.id
  description       = "DNS (TCP) from the on-premises network"
  ip_protocol       = "tcp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = var.onprem_cidr
}

# Outbound endpoint: queries leave toward ONE address, the on-premises DNS server.
resource "aws_vpc_security_group_egress_rule" "dns_udp_to_onprem_dns" {
  security_group_id = aws_security_group.resolver.id
  description       = "DNS (UDP) to the on-premises DNS server"
  ip_protocol       = "udp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = "${var.onprem_dns_ip}/32"
}

resource "aws_vpc_security_group_egress_rule" "dns_tcp_to_onprem_dns" {
  security_group_id = aws_security_group.resolver.id
  description       = "DNS (TCP) to the on-premises DNS server"
  ip_protocol       = "tcp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = "${var.onprem_dns_ip}/32"
}

# =============================================================================
# Route 53 Resolver endpoints (one network interface per AZ)
# =============================================================================
resource "aws_route53_resolver_endpoint" "inbound" {
  name               = "${var.name}-resolver-inbound"
  direction          = "INBOUND"
  security_group_ids = [aws_security_group.resolver.id]

  ip_address {
    subnet_id = var.endpoint_subnet_ids[0]
  }

  ip_address {
    subnet_id = var.endpoint_subnet_ids[1]
  }

  tags = merge(var.tags, { Name = "${var.name}-resolver-inbound" })
}

resource "aws_route53_resolver_endpoint" "outbound" {
  name               = "${var.name}-resolver-outbound"
  direction          = "OUTBOUND"
  security_group_ids = [aws_security_group.resolver.id]

  ip_address {
    subnet_id = var.endpoint_subnet_ids[0]
  }

  ip_address {
    subnet_id = var.endpoint_subnet_ids[1]
  }

  tags = merge(var.tags, { Name = "${var.name}-resolver-outbound" })
}

# =============================================================================
# Forwarding rule: "for names under the on-premises domain, ask the on-premises DNS"
# =============================================================================
resource "aws_route53_resolver_rule" "onprem" {
  name                 = "${var.name}-forward-onprem"
  domain_name          = var.onprem_domain_name
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id

  target_ip {
    ip   = var.onprem_dns_ip
    port = 53
  }

  tags = merge(var.tags, { Name = "${var.name}-forward-onprem" })
}

# A rule does nothing until it is associated with a VPC.
resource "aws_route53_resolver_rule_association" "onprem" {
  name             = "${var.name}-forward-onprem"
  resolver_rule_id = aws_route53_resolver_rule.onprem.id
  vpc_id           = var.vpc_id
}

# =============================================================================
# Conditional forwarder on the Managed AD (the Active Directory way)
# =============================================================================
# The same thing you would do on an on-premises domain controller with
# Add-DnsServerConditionalForwarderZone: "for the on-premises domain, ask this server".
resource "aws_directory_service_conditional_forwarder" "onprem" {
  directory_id       = var.directory_id
  remote_domain_name = var.onprem_domain_name
  dns_ips            = [var.onprem_dns_ip]
}
