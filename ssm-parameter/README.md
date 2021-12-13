## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Prefix prepended to parameter name if not using default | `any` | n/a | yes |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | Parameters expressed as a map of maps. Each map's key is its intended SSM parameter name, and the value stored under that key is another map that may contain the following keys: description, type, and value. | `map(map(string))` | n/a | yes |
| <a name="input_service"></a> [service](#input\_service) | The name of the service to which this parameter list belongs, e.g. `rds`, `api`, `lambda-auth` | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | common tags | `any` | n/a | yes |

## Outputs

No outputs.
