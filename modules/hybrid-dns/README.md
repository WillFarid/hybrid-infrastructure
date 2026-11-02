# hybrid-dns

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
| [aws_directory_service_conditional_forwarder.onprem](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/directory_service_conditional_forwarder) | resource |
| [aws_route53_resolver_endpoint.inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_endpoint) | resource |
| [aws_route53_resolver_endpoint.outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_endpoint) | resource |
| [aws_route53_resolver_rule.onprem](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_rule) | resource |
| [aws_route53_resolver_rule_association.onprem](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_rule_association) | resource |
| [aws_security_group.resolver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.dns_tcp_to_onprem_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.dns_udp_to_onprem_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.dns_tcp_from_onprem](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.dns_udp_from_onprem](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_directory_id"></a> [directory\_id](#input\_directory\_id) | ID of the AWS Managed AD directory that gets a conditional forwarder for the on-premises domain. | `string` | n/a | yes |
| <a name="input_endpoint_subnet_ids"></a> [endpoint\_subnet\_ids](#input\_endpoint\_subnet\_ids) | Subnets for the resolver endpoints (one per AZ). The first two are used. | `list(string)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for all resources, e.g. hybrid-lab. | `string` | n/a | yes |
| <a name="input_onprem_cidr"></a> [onprem\_cidr](#input\_onprem\_cidr) | Address range of the on-premises network. It may query the inbound endpoint. | `string` | n/a | yes |
| <a name="input_onprem_dns_ip"></a> [onprem\_dns\_ip](#input\_onprem\_dns\_ip) | IP address of the on-premises DNS server (a domain controller), reached over the VPN. | `string` | n/a | yes |
| <a name="input_onprem_domain_name"></a> [onprem\_domain\_name](#input\_onprem\_domain\_name) | DNS name of the on-premises Active Directory domain, e.g. corp.example.com. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Extra tags merged onto resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC the resolver endpoints and rule belong to. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_inbound_endpoint_ips"></a> [inbound\_endpoint\_ips](#output\_inbound\_endpoint\_ips) | IP addresses of the inbound resolver endpoint. Point an on-premises conditional forwarder for AWS names here. |
| <a name="output_resolver_rule_id"></a> [resolver\_rule\_id](#output\_resolver\_rule\_id) | ID of the rule that forwards the on-premises domain to the on-premises DNS server. |
| <a name="output_resolver_security_group_id"></a> [resolver\_security\_group\_id](#output\_resolver\_security\_group\_id) | Security group of the resolver endpoints. |
<!-- END_TF_DOCS -->
