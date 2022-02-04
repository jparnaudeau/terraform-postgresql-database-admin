output "vpc_infos" {
  description = "map of vpc informations"
  value = {
    vpc_id           = module.vpc.vpc_id,
    vpc_name         = module.vpc.name,
    public_subnets   = module.vpc.public_subnets,
    private_subnets  = module.vpc.private_subnets,
    database_subnets = module.vpc.database_subnets
  }
}

output "rds_infos" {
  description = "map of rds informations"
  value = {
    db_instance_address  = module.rds.db_instance_address,
    db_instance_arn      = module.rds.db_instance_arn,
    db_instance_endpoint = module.rds.db_instance_endpoint,
    db_instance_id       = module.rds.db_instance_id,
    db_instance_name     = module.rds.db_instance_name,
    "connect_command"    = format("psql -h %s -p %s -U %s -d %s -W", module.rds.db_instance_address, var.dbport, var.rds_superuser_name, var.inputs["db_name"])
  }
}


output "affected_schema" {
  description = "the name of the schema in which the db objects have been created by the module"
  value       = var.inputs["db_schema_name"]
}

output "created_roles" {
  description = "The list of roles created by the module"
  value       = [for obj_role in var.inputs["db_roles"] : obj_role["role"]]
}

output "db_users" {
  description = "The list of users created by the module"
  value = { for user in var.inputs["db_users"] :
    user.name => {
      "parameter_store_user"          = format("%s/%s_user", local.namespace, user.name),
      "parameter_store_user_password" = format("%s/%s_password", local.namespace, user.name),
      "connect_command"               = format("psql -h %s -p %s -U %s -d %s -W", module.rds.db_instance_address, var.dbport, user.name, var.inputs["db_name"])
    }
  }
}