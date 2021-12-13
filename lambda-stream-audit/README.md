## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda"></a> [lambda](#module\_lambda) | git@gitlab.eulerhermes.io:cloud-devops/terraform-modules/lambda.git?ref=v3.6.2 |  |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.schedule_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.schedule_rule_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_policy.lambda_rds_logging_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [archive_file.lambda_src](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.rds_audit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_event_rule_schedule_expression"></a> [cloudwatch\_event\_rule\_schedule\_expression](#input\_cloudwatch\_event\_rule\_schedule\_expression) | Number of days for which to retain log events in the specified log group | `string` | `"rate(15 minutes)"` | no |
| <a name="input_cloudwatch_retention_days"></a> [cloudwatch\_retention\_days](#input\_cloudwatch\_retention\_days) | Number of days for which to retain log events in the specified log group | `number` | `14` | no |
| <a name="input_costcenter"></a> [costcenter](#input\_costcenter) | CostCenter | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Envrionment name. Ie: dev, sandbox, ... | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | Email of the team owning application | `string` | n/a | yes |
| <a name="input_product_name"></a> [product\_name](#input\_product\_name) | Product Name | `string` | n/a | yes |
| <a name="input_rds_instances_list"></a> [rds\_instances\_list](#input\_rds\_instances\_list) | List of RDS instances you want to audit | `list(string)` | n/a | yes |
| <a name="input_short_description"></a> [short\_description](#input\_short\_description) | Short description of the lambda | `string` | `"rds-stream-auditlogs"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | The ARN identifying created lambda function. |
| <a name="output_lambda_name"></a> [lambda\_name](#output\_lambda\_name) | The name of created lambda function. |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | Log Group ARN. |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | Log Group Name. |
