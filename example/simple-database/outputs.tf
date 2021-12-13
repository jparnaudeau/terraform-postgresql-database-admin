output "created_database" {
  description = "the name of the database created by the module"
  value       = var.inputs["db_name"]
}

output "affected_schema" {
  description = "the name of the schema in which the db objects have been created by the module"
  value       = var.inputs["db_schema_name"]
}

output "created_roles" {
  description = "The list of roles created by the module"
  value       = [for obj_role in var.inputs["db_roles"] : obj_role["role"]]
}

output "connect_string" {
  description = "The connect string to use to connect on the database"
  value       = format("psql -h %s -p %s -U %s -d %s", var.dbhost, var.dbport, var.inputs["db_admin"], var.inputs["db_name"])
}
