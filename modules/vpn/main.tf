# -----------------------------------------------------------------------------
# main.tf (vpn module)
# AWS Site-to-Site VPN: an encrypted IPsec link between the VPC and the
# (simulated) on-premises network.
#
#   on-premises device  <==== 2 IPsec tunnels ====>  virtual private gateway
#   (customer gateway)        over the internet       (attached to the VPC)
#
# AWS always provisions TWO tunnels, ending in different AZs, so one endpoint
# can be down for maintenance without breaking the connection.
# -----------------------------------------------------------------------------

locals {
  # Modern crypto only: IKEv2, AES-256, SHA-2 and strong Diffie-Hellman groups.
  # Excluded on purpose: IKEv1, SHA-1 and the weak DH group 2.
  ike_versions       = ["ikev2"]
  phase1_encryption  = ["AES256-GCM-16", "AES256"]
  phase1_integrity   = ["SHA2-384", "SHA2-256"]
  phase1_dh_groups   = [20, 14]
  phase2_encryption  = ["AES256-GCM-16", "AES256"]
  phase2_integrity   = ["SHA2-384", "SHA2-256"]
  phase2_dh_groups   = [20, 14]
  dpd_timeout_action = "restart" # if the other side stops answering, rebuild the tunnel
}

# --- AWS side of the link ------------------------------------------------------------
# The virtual private gateway (VGW) is the VPN endpoint on the VPC. Fine for one
# VPC. With several VPCs or accounts you would use a Transit Gateway instead.
resource "aws_vpn_gateway" "this" {
  vpc_id          = var.vpc_id
  amazon_side_asn = var.amazon_side_asn

  tags = merge(var.tags, { Name = "${var.name}-vgw" })
}

# --- On-premises side of the link ------------------------------------------------------
# The customer gateway is AWS's record of YOUR device: its public IP and ASN.
# In this lab the address is a documentation placeholder, so the tunnels would
# stay down until a real device is configured with it.
resource "aws_customer_gateway" "this" {
  type       = "ipsec.1"
  ip_address = var.customer_gateway_ip
  bgp_asn    = var.customer_gateway_bgp_asn

  tags = merge(var.tags, { Name = "${var.name}-cgw" })
}

# --- Encrypted logs of tunnel activity ---------------------------------------------------
resource "aws_cloudwatch_log_group" "vpn" {
  # checkov:skip=CKV_AWS_158: A KMS key policy needs the account ID, which cannot be looked up offline. Add a customer-managed key for a real deployment.
  name              = "/aws/vpn/${var.name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, { Name = "${var.name}-vpn-logs" })
}

# --- The VPN connection -------------------------------------------------------------------
resource "aws_vpn_connection" "this" {
  vpn_gateway_id      = aws_vpn_gateway.this.id
  customer_gateway_id = aws_customer_gateway.this.id
  type                = "ipsec.1"

  # Static routing: we tell AWS which prefix lives on the other side (below).
  # It works with any device. Production setups usually prefer BGP, which
  # learns routes automatically and fails over faster.
  static_routes_only = true

  # Traffic selectors: only traffic between the two networks enters the tunnel,
  # not 0.0.0.0/0, which is the default.
  local_ipv4_network_cidr  = var.onprem_cidr
  remote_ipv4_network_cidr = var.vpc_cidr

  # No pre-shared keys are set here on purpose. AWS generates a strong random key
  # for each tunnel, so no key is ever written in code. (They do end up in state,
  # marked sensitive. Download the device configuration from the console.)

  # --- Tunnel 1 -------------------------------------------------------------------------
  tunnel1_ike_versions                 = local.ike_versions
  tunnel1_phase1_encryption_algorithms = local.phase1_encryption
  tunnel1_phase1_integrity_algorithms  = local.phase1_integrity
  tunnel1_phase1_dh_group_numbers      = local.phase1_dh_groups
  tunnel1_phase2_encryption_algorithms = local.phase2_encryption
  tunnel1_phase2_integrity_algorithms  = local.phase2_integrity
  tunnel1_phase2_dh_group_numbers      = local.phase2_dh_groups
  tunnel1_dpd_timeout_action           = local.dpd_timeout_action

  tunnel1_log_options {
    cloudwatch_log_options {
      log_enabled       = true
      log_group_arn     = aws_cloudwatch_log_group.vpn.arn
      log_output_format = "json"
    }
  }

  # --- Tunnel 2 (identical settings) -----------------------------------------------------
  tunnel2_ike_versions                 = local.ike_versions
  tunnel2_phase1_encryption_algorithms = local.phase1_encryption
  tunnel2_phase1_integrity_algorithms  = local.phase1_integrity
  tunnel2_phase1_dh_group_numbers      = local.phase1_dh_groups
  tunnel2_phase2_encryption_algorithms = local.phase2_encryption
  tunnel2_phase2_integrity_algorithms  = local.phase2_integrity
  tunnel2_phase2_dh_group_numbers      = local.phase2_dh_groups
  tunnel2_dpd_timeout_action           = local.dpd_timeout_action

  tunnel2_log_options {
    cloudwatch_log_options {
      log_enabled       = true
      log_group_arn     = aws_cloudwatch_log_group.vpn.arn
      log_output_format = "json"
    }
  }

  tags = merge(var.tags, { Name = "${var.name}-vpn" })
}

# With static routing, AWS must be told what lives on the other side.
resource "aws_vpn_connection_route" "onprem" {
  vpn_connection_id      = aws_vpn_connection.this.id
  destination_cidr_block = var.onprem_cidr
}

# Route propagation: the gateway writes the on-premises route into our route
# table automatically. This is what lets the Windows servers and the directory
# answer machines on the other side of the VPN. No hand-written route is needed.
resource "aws_vpn_gateway_route_propagation" "this" {
  vpn_gateway_id = aws_vpn_gateway.this.id
  route_table_id = var.route_table_id
}
