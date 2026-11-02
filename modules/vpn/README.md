# vpn

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.70 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.70 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_group.vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_customer_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/customer_gateway) | resource |
| [aws_vpn_connection.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_connection) | resource |
| [aws_vpn_connection_route.onprem](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_connection_route) | resource |
| [aws_vpn_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway) | resource |
| [aws_vpn_gateway_route_propagation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_route_propagation) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_amazon_side_asn"></a> [amazon\_side\_asn](#input\_amazon\_side\_asn) | BGP ASN of the AWS side (virtual private gateway). | `number` | `64512` | no |
| <a name="input_customer_gateway_bgp_asn"></a> [customer\_gateway\_bgp\_asn](#input\_customer\_gateway\_bgp\_asn) | BGP ASN of the on-premises device. Required by AWS even when static routing is used. | `number` | `65000` | no |
| <a name="input_customer_gateway_ip"></a> [customer\_gateway\_ip](#input\_customer\_gateway\_ip) | PUBLIC IP address of the on-premises VPN device. The default is a documentation address (RFC 5737), not a real device. | `string` | `"203.0.113.10"` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | How long to keep VPN tunnel logs in CloudWatch. | `number` | `365` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for all resources, e.g. hybrid-lab. | `string` | n/a | yes |
| <a name="input_onprem_cidr"></a> [onprem\_cidr](#input\_onprem\_cidr) | Address range of the on-premises network. Routed through the tunnels. | `string` | n/a | yes |
| <a name="input_route_table_id"></a> [route\_table\_id](#input\_route\_table\_id) | Route table that learns the on-premises route through the VPN (route propagation). | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Extra tags merged onto resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | Address range of the AWS side. Used as the VPN's remote traffic selector. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC the virtual private gateway is attached to. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_tunnel1_address"></a> [tunnel1\_address](#output\_tunnel1\_address) | Public IP of AWS tunnel endpoint 1. Configure this as a peer on the on-premises device. |
| <a name="output_tunnel2_address"></a> [tunnel2\_address](#output\_tunnel2\_address) | Public IP of AWS tunnel endpoint 2. Configure this as a peer on the on-premises device. |
| <a name="output_vpn_connection_id"></a> [vpn\_connection\_id](#output\_vpn\_connection\_id) | ID of the VPN connection. |
| <a name="output_vpn_gateway_id"></a> [vpn\_gateway\_id](#output\_vpn\_gateway\_id) | ID of the virtual private gateway. |
<!-- END_TF_DOCS -->
