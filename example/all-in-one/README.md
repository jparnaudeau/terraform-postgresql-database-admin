## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.70, < 4 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0.0 |
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | ~> 1.11.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.70, < 4 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_initdb"></a> [initdb](#module\_initdb) | ../create-users |  |

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.postgres](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/db_instance) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_costcenter"></a> [costcenter](#input\_costcenter) | CostCenter | `string` | n/a | yes |
| <a name="input_data_service"></a> [data\_service](#input\_data\_service) | a constant string used in building parameterStore path | `string` | `"rds"` | no |
| <a name="input_dbhost"></a> [dbhost](#input\_dbhost) | The Host of the RDS Instance. If empty, retrieve the amazon endpoint of the RDS Instance. | `string` | `""` | no |
| <a name="input_dbid"></a> [dbid](#input\_dbid) | The Id of the RDS Instance | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Envrionment name. Ie: dev, sandbox, ... | `string` | n/a | yes |
| <a name="input_inputs"></a> [inputs](#input\_inputs) | The map containing all elements for creating objects inside database | <pre>object({<br>    db_schema_name = string<br>    db_name        = string<br>    db_admin       = string<br>    db_roles = list(object({<br>      id         = string<br>      role       = string<br>      inherit    = bool<br>      login      = bool<br>      validity   = string<br>      db         = string<br>      privileges = list(string)<br>      createrole = bool<br>    }))<br>    db_grants = list(object({<br>      object_type  = string<br>      privileges   = list(string)<br>      schema       = string<br>      db           = string<br>      role         = string<br>      owner_role   = string<br>      grant_option = bool<br>    }))<br>    db_users = list(object({<br>      name             = string<br>      inherit          = bool<br>      login            = bool<br>      membership       = list(string)<br>      validity         = string<br>      connection_limit = number<br>      createrole       = bool<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Email of the team owning application | `string` | n/a | yes |
| <a name="input_pgadmin_user"></a> [pgadmin\_user](#input\_pgadmin\_user) | The RDS user to used for creating/managing other user in the database. If empty, retrieve the master user of the RDS Instance | `string` | `""` | no |
| <a name="input_product_name"></a> [product\_name](#input\_product\_name) | Application Short Name | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | region | `string` | `"eu-central-1"` | no |
| <a name="input_short_description"></a> [short\_description](#input\_short\_description) | The short description | `string` | `"main"` | no |
| <a name="input_sslmode"></a> [sslmode](#input\_sslmode) | Establish the communication to the database on ssl | `string` | `"require"` | no |

## Outputs

No outputs.
