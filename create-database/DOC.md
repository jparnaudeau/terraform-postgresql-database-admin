## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.4 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0.0 |
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | ~> 1.11.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_postgresql"></a> [postgresql](#provider\_postgresql) | ~> 1.11.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [postgresql_database.db](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/database) | resource |
| [postgresql_default_privileges.alter_defaults_privs](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/default_privileges) | resource |
| [postgresql_extension.psql_extension](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/extension) | resource |
| [postgresql_grant.grant_roles_schema](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_grant.privileges](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_grant.revoke_create_public](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_role.app_roles](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/role) | resource |
| [postgresql_schema.schema](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/schema) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_database"></a> [create\_database](#input\_create\_database) | Enable/Disable the creation of the database. Except for local tests or Cloud environment, the database creation is not possible. Disabled by default | `bool` | `false` | no |
| <a name="input_dbhost"></a> [dbhost](#input\_dbhost) | The Postgresql Database Hostname | `string` | n/a | yes |
| <a name="input_dbport"></a> [dbport](#input\_dbport) | The Postgresql Database Port | `string` | n/a | yes |
| <a name="input_inputs"></a> [inputs](#input\_inputs) | The Inputs parameters for objects to create inside the database | <pre>object({<br>    db_schema_name = string<br>    db_name        = string<br>    db_admin       = string<br>    #sslmode        = string<br>    extensions     = list(string)<br>    db_roles = list(object({<br>      id         = string<br>      role       = string<br>      inherit    = bool<br>      login      = bool<br>      validity   = string<br>      privileges = list(string)<br>      createrole = bool<br>    }))<br>    db_grants = list(object({<br>      object_type  = string<br>      privileges   = list(string)<br>      #schema       = string<br>      role         = string<br>      owner_role   = string<br>      grant_option = bool<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_pgadmin_user"></a> [pgadmin\_user](#input\_pgadmin\_user) | The Postgresql username | `string` | n/a | yes |
| <a name="input_revoke_create_public"></a> [revoke\_create\_public](#input\_revoke\_create\_public) | Enable/Disable the revoke command for create table in schema public | `bool` | `true` | no |

## Outputs

No outputs.
