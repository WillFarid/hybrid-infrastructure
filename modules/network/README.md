# network

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
| [aws_cloudwatch_log_group.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_default_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_flow_log.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_role.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.directory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.servers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.directory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.servers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_security_group_ingress_rule.endpoints_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_iam_policy_document.flow_logs_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.flow_logs_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_azs"></a> [azs](#input\_azs) | Availability zones to use. Managed AD needs at least two. | `list(string)` | n/a | yes |
| <a name="input_directory_subnet_cidrs"></a> [directory\_subnet\_cidrs](#input\_directory\_subnet\_cidrs) | CIDRs for the subnets that hold the Managed AD domain controllers, one per AZ. | `list(string)` | n/a | yes |
| <a name="input_endpoint_subnet_cidrs"></a> [endpoint\_subnet\_cidrs](#input\_endpoint\_subnet\_cidrs) | CIDRs for the subnets that hold VPC endpoints and (later) the DNS resolver endpoints, one per AZ. | `list(string)` | n/a | yes |
| <a name="input_flow_log_retention_days"></a> [flow\_log\_retention\_days](#input\_flow\_log\_retention\_days) | How long to keep VPC flow logs in CloudWatch. | `number` | `365` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for all resources, e.g. hybrid-lab. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region. Used to build VPC endpoint service names (passed in, so plan works offline). | `string` | n/a | yes |
| <a name="input_server_subnet_cidrs"></a> [server\_subnet\_cidrs](#input\_server\_subnet\_cidrs) | CIDRs for the subnets that hold the Windows servers and the file share, one per AZ. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Extra tags merged onto resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block of the VPC. Must not overlap with the on-premises network. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_directory_subnet_ids"></a> [directory\_subnet\_ids](#output\_directory\_subnet\_ids) | Subnets for the Managed AD domain controllers (one per AZ). |
| <a name="output_endpoint_subnet_ids"></a> [endpoint\_subnet\_ids](#output\_endpoint\_subnet\_ids) | Subnets for VPC endpoints and the DNS resolver endpoints (one per AZ). |
| <a name="output_private_route_table_id"></a> [private\_route\_table\_id](#output\_private\_route\_table\_id) | The shared route table. The VPN module enables route propagation on it. |
| <a name="output_server_subnet_ids"></a> [server\_subnet\_ids](#output\_server\_subnet\_ids) | Subnets for the Windows servers and the file share (one per AZ). |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | CIDR block of the VPC. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC. |
<!-- END_TF_DOCS -->
