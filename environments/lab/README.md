# lab

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.70 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_directory"></a> [directory](#module\_directory) | ../../modules/directory | n/a |
| <a name="module_network"></a> [network](#module\_network) | ../../modules/network | n/a |
| <a name="module_windows_servers"></a> [windows\_servers](#module\_windows\_servers) | ../../modules/windows-servers | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_azs"></a> [azs](#input\_azs) | Availability zones. Passed in (not looked up) so plan works without AWS credentials. | `list(string)` | <pre>[<br/>  "us-east-1a",<br/>  "us-east-1b"<br/>]</pre> | no |
| <a name="input_directory_admin_password"></a> [directory\_admin\_password](#input\_directory\_admin\_password) | Initial password of the directory's Admin account. Supply it through the TF\_VAR\_directory\_admin\_password environment variable, never in a committed file. | `string` | n/a | yes |
| <a name="input_directory_domain_name"></a> [directory\_domain\_name](#input\_directory\_domain\_name) | Domain name of the AWS Managed AD. Must differ from the on-premises domain (corp.example.com). | `string` | `"cloud.example.com"` | no |
| <a name="input_directory_netbios_name"></a> [directory\_netbios\_name](#input\_directory\_netbios\_name) | NetBIOS (short) name of the AWS domain. | `string` | `"CLOUD"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment. | `string` | `"lab"` | no |
| <a name="input_mock_mode"></a> [mock\_mode](#input\_mock\_mode) | true = fake credentials and no calls to AWS (offline plan). false for a real deployment. | `bool` | `true` | no |
| <a name="input_onprem_cidr"></a> [onprem\_cidr](#input\_onprem\_cidr) | Address range of the simulated on-premises network. The VPC must never overlap it. | `string` | `"192.168.0.0/16"` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name, used in resource names and tags. | `string` | `"hybrid"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy into. | `string` | `"us-east-1"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | Address range of the AWS VPC. Must be a /16 and must not overlap onprem\_cidr. | `string` | `"10.2.0.0/16"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_directory_dns_ips"></a> [directory\_dns\_ips](#output\_directory\_dns\_ips) | IP addresses of the domain controllers (also the VPC's DNS servers). |
| <a name="output_directory_id"></a> [directory\_id](#output\_directory\_id) | ID of the AWS Managed AD directory. |
| <a name="output_onprem_cidr"></a> [onprem\_cidr](#output\_onprem\_cidr) | Address range of the simulated on-premises side (the VPN and DNS steps route to it). |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | Address range of the AWS side. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC. |
| <a name="output_windows_server_private_ips"></a> [windows\_server\_private\_ips](#output\_windows\_server\_private\_ips) | Private IP addresses of the domain-joined Windows servers. |
<!-- END_TF_DOCS -->
