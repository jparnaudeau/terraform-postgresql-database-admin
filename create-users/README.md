## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.4 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0.0 |
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | >= 1.15.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.0.0 |
| <a name="provider_postgresql"></a> [postgresql](#provider\_postgresql) | >= 1.15.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.pgusers_postprocessing_playbook](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [postgresql_role.app_users](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/role) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_db_users"></a> [db\_users](#input\_db\_users) | The Inputs parameters for objects to create inside the database | <pre>list(object({<br>    name             = string<br>    inherit          = bool<br>    login            = bool<br>    membership       = list(string)<br>    validity         = string<br>    connection_limit = number<br>    createrole       = bool<br>    })<br>  )</pre> | `null` | no |
| <a name="input_dbhost"></a> [dbhost](#input\_dbhost) | The RDS DB Hostname | `string` | n/a | yes |
| <a name="input_dbport"></a> [dbport](#input\_dbport) | The RDS DB Port | `string` | n/a | yes |
| <a name="input_passwords"></a> [passwords](#input\_passwords) | Map of credentials, <username> = <password> | `map(string)` | `{}` | no |
| <a name="input_pgadmin_user"></a> [pgadmin\_user](#input\_pgadmin\_user) | The RDS Master username | `string` | n/a | yes |
| <a name="input_postprocessing_playbook_params"></a> [postprocessing\_playbook\_params](#input\_postprocessing\_playbook\_params) | params for postprocessing playbook | <pre>object({<br>    enable            = bool<br>    db_name           = string<br>    extra_envs        = map(string)<br>    shell_name        = string<br>    refresh_passwords = list(string)<br>  })</pre> | <pre>{<br>  "db_name": "",<br>  "enable": false,<br>  "extra_envs": {},<br>  "refresh_passwords": [],<br>  "shell_name": ""<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_users"></a> [db\_users](#output\_db\_users) | The list of users created by the module |
