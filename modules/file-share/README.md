# file-share

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
| [aws_cloudwatch_log_group.fsx_audit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_fsx_windows_file_system.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fsx_windows_file_system) | resource |
| [aws_kms_alias.fsx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.fsx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_security_group.file_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.to_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.powershell_from_servers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.smb_from_servers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days) | Days to keep automatic daily backups (0 to 90). | `number` | `7` | no |
| <a name="input_client_security_group_id"></a> [client\_security\_group\_id](#input\_client\_security\_group\_id) | Security group of the machines allowed to reach the share (the Windows servers). | `string` | n/a | yes |
| <a name="input_deployment_type"></a> [deployment\_type](#input\_deployment\_type) | MULTI\_AZ\_1 (standby in a second AZ with automatic failover), SINGLE\_AZ\_1 or SINGLE\_AZ\_2. | `string` | `"MULTI_AZ_1"` | no |
| <a name="input_directory_id"></a> [directory\_id](#input\_directory\_id) | ID of the AWS Managed AD directory. It controls who can open the share. | `string` | n/a | yes |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | How long to keep file access audit logs in CloudWatch. | `number` | `365` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for all resources, e.g. hybrid-lab. | `string` | n/a | yes |
| <a name="input_skip_final_backup"></a> [skip\_final\_backup](#input\_skip\_final\_backup) | Skip the backup taken when the file system is deleted. true only for disposable labs. | `bool` | `true` | no |
| <a name="input_storage_capacity"></a> [storage\_capacity](#input\_storage\_capacity) | Storage in GiB. SSD file systems start at 32. | `number` | `32` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnets for the file system (one per AZ). Multi-AZ uses two, single-AZ uses the first. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Extra tags merged onto resources. | `map(string)` | `{}` | no |
| <a name="input_throughput_capacity"></a> [throughput\_capacity](#input\_throughput\_capacity) | Throughput in MB/s. Check the minimum for your deployment type before a real deployment. | `number` | `32` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR of the VPC. The file system may send traffic only inside it. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC the file system belongs to. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | DNS name of the file system. Map the share as \\<dns\_name>\share. |
| <a name="output_file_system_id"></a> [file\_system\_id](#output\_file\_system\_id) | ID of the FSx file system. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group of the file system. |
<!-- END_TF_DOCS -->
