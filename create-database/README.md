## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.70, < 4 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0.0 |
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | ~> 1.11.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.0.0 |
| <a name="provider_postgresql"></a> [postgresql](#provider\_postgresql) | ~> 1.11.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_fake_user_password"></a> [fake\_user\_password](#module\_fake\_user\_password) | ../ssm-parameter |  |
| <a name="module_naming"></a> [naming](#module\_naming) | git@gitlab.eulerhermes.io:cloud-devops/terraform-modules/naming.git?ref=v1.1.0 |  |
| <a name="module_security"></a> [security](#module\_security) | git@gitlab.eulerhermes.io:cloud-devops/terraform-modules/securitydata.git?ref=v2.2.0 |  |
| <a name="module_ssm_db_users"></a> [ssm\_db\_users](#module\_ssm\_db\_users) | ../ssm-parameter |  |

## Resources

| Name | Type |
|------|------|
| [null_resource.pgusers_postprocessing_playbook](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [postgresql_database.db](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/database) | resource |
| [postgresql_default_privileges.alter_defaults_privs](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/default_privileges) | resource |
| [postgresql_extension.psql_extension](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/extension) | resource |
| [postgresql_grant.grant_roles_schema](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_grant.privileges](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_grant.revoke_create_public](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_role.app_roles](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/role) | resource |
| [postgresql_role.app_users](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/role) | resource |
| [postgresql_schema.schema](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/schema) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_costcenter"></a> [costcenter](#input\_costcenter) | CostCenter | `string` | n/a | yes |
| <a name="input_data_service"></a> [data\_service](#input\_data\_service) | a constant used inside parameterstore path. Default : rds | `string` | `"rds"` | no |
| <a name="input_db_numerical_version"></a> [db\_numerical\_version](#input\_db\_numerical\_version) | Use this variable to be a workaround between the naming of the rds instance and its path in parameterstore | `string` | `"-00"` | no |
| <a name="input_dbhost"></a> [dbhost](#input\_dbhost) | The RDS DB Hostname | `string` | n/a | yes |
| <a name="input_dbport"></a> [dbport](#input\_dbport) | The RDS DB Port | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Envrionment name. Ie: dev, sandbox, ... | `string` | n/a | yes |
| <a name="input_inputs"></a> [inputs](#input\_inputs) | The Inputs parameters for objects to create inside the database | <pre>object({<br>    db_schema_name = string<br>    db_name        = string<br>    db_admin       = string<br>    sslmode        = string<br>    extensions     = list(string)<br>    db_roles = list(object({<br>      id         = string<br>      role       = string<br>      inherit    = bool<br>      login      = bool<br>      validity   = string<br>      db         = string<br>      privileges = list(string)<br>      createrole = bool<br>    }))<br>    db_grants = list(object({<br>      object_type  = string<br>      privileges   = list(string)<br>      schema       = string<br>      db           = string<br>      role         = string<br>      owner_role   = string<br>      grant_option = bool<br>    }))<br>    db_users = list(object({<br>      name             = string<br>      inherit          = bool<br>      login            = bool<br>      membership       = list(string)<br>      validity         = string<br>      connection_limit = number<br>      createrole       = bool<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Email of the team owning application | `string` | n/a | yes |
| <a name="input_pgadmin_user"></a> [pgadmin\_user](#input\_pgadmin\_user) | The RDS Master username | `string` | n/a | yes |
| <a name="input_product_name"></a> [product\_name](#input\_product\_name) | Application Short Name | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | region | `string` | `"eu-central-1"` | no |
| <a name="input_revoke_create_public"></a> [revoke\_create\_public](#input\_revoke\_create\_public) | Enable/Disable the revoke command for create table in schema public | `bool` | `true` | no |
| <a name="input_short_description"></a> [short\_description](#input\_short\_description) | The short description | `string` | `"main"` | no |

## Outputs

No outputs.
