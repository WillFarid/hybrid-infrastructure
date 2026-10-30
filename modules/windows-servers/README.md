# windows-servers

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
| [aws_iam_instance_profile.servers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.servers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.directory_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.windows](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.servers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ssm_association.domain_join](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_association) | resource |
| [aws_ssm_document.domain_join](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_document) | resource |
| [aws_vpc_security_group_egress_rule.servers_to_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_iam_policy_document.ec2_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI to launch. The default is an SSM parameter alias that AWS resolves at<br/>launch time to the latest Windows Server 2022 image, so no lookup (and no<br/>AWS call) is needed to plan. To pin an exact image, pass an AMI ID instead. | `string` | `"resolve:ssm:/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base"` | no |
| <a name="input_directory_id"></a> [directory\_id](#input\_directory\_id) | ID of the AWS Managed AD directory the servers join. | `string` | n/a | yes |
| <a name="input_directory_name"></a> [directory\_name](#input\_directory\_name) | Fully qualified domain name of the directory, e.g. cloud.example.com. | `string` | n/a | yes |
| <a name="input_dns_ip_addresses"></a> [dns\_ip\_addresses](#input\_dns\_ip\_addresses) | IP addresses of the domain controllers (they are the DNS servers). | `list(string)` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type. Windows needs at least 2 GiB of memory. | `string` | `"t3.medium"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for all resources, e.g. hybrid-lab. | `string` | n/a | yes |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | Root EBS volume size in GiB (Windows needs at least 30). | `number` | `50` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Server subnets. One Windows server is created per subnet, so one per AZ. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Extra tags merged onto resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR of the VPC. The servers may send traffic only inside it. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC the servers run in. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | IDs of the Windows servers. |
| <a name="output_private_ips"></a> [private\_ips](#output\_private\_ips) | Private IP addresses of the Windows servers. |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the servers' IAM role. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group of the servers. The file share allows SMB from this group. |
<!-- END_TF_DOCS -->
