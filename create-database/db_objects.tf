
########################################
# Database Creation
########################################
resource "postgresql_database" "db" {
  name              = var.inputs["db_name"]
  owner             = var.inputs["db_admin"]
  template          = "template0"
  encoding          = "UTF8"
  lc_collate        = "en_US.UTF-8"
  lc_ctype          = "en_US.UTF-8"
  connection_limit  = -1
  allow_connections = true
}

########################################
# Roles Creation
########################################
resource "postgresql_role" "app_roles" {
  for_each = { for tuple in var.inputs["db_roles"] : tuple.role => tuple }

  name        = each.value.role
  login       = each.value.login
  inherit     = each.value.inherit
  valid_until = each.value.validity
  create_role = lookup(each.value, "createrole", false)
  roles       = lookup(each.value, "membership", null)
  search_path = lookup(each.value, "search_path", null)

  depends_on = [
    postgresql_database.db,
  ]

  provisioner "local-exec" {
    when = create
    environment = {
      PGHOST     = var.dbhost
      PGPORT     = var.dbport
      PGUSER     = var.pgadmin_user
      PGAPPNAME  = "terraform-psql"
      PGDATABASE = var.inputs["db_name"]
    }
    command = <<EOT
      psql -c "GRANT ${each.value.role} TO ${var.inputs["db_admin"]};"
    EOT
  }
}

########################################
# Schemas Creation & grant creation inside schema
########################################
resource "postgresql_schema" "schema" {
  database      = var.inputs["db_name"]
  name          = var.inputs["db_schema_name"]
  owner         = var.inputs["db_admin"]
  if_not_exists = true
  drop_cascade  = true

  depends_on = [
    postgresql_role.app_roles,
    postgresql_database.db,
  ]

}

resource "postgresql_grant" "grant_roles_schema" {

  for_each = { for tuple in var.inputs["db_roles"] : tuple.role => tuple.privileges }

  database    = var.inputs["db_name"]
  schema      = var.inputs["db_schema_name"]
  role        = each.key
  object_type = "schema"
  privileges  = try(each.value, null)

  depends_on = [
    postgresql_role.app_roles,
    postgresql_database.db,
    postgresql_schema.schema,
  ]
}




########################################
# Creation of grants for each role
########################################
resource "postgresql_grant" "privileges" {

  for_each = { for tuple in var.inputs["db_grants"] :
  join("_", [tuple.role, tuple.object_type, "privs"]) => tuple if tuple.object_type != "type" }

  database          = var.inputs["db_name"]
  schema            = var.inputs["db_schema_name"]
  role              = each.value.role
  object_type       = each.value.object_type
  privileges        = each.value.privileges
  with_grant_option = each.value.grant_option

  depends_on = [
    postgresql_role.app_roles,
    postgresql_database.db,
    postgresql_schema.schema,
  ]
}


########################################
# Update default privileges according to parameters setted in var.inputs
########################################
resource "postgresql_default_privileges" "alter_defaults_privs" {

  for_each = { for tuple in var.inputs["db_grants"] :
    join("_", [tuple.role, tuple.object_type, "defaults", "privs"]) => tuple if tuple.object_type != "database"
  }

  database    = var.inputs["db_name"]
  schema      = var.inputs["db_schema_name"]
  owner       = each.value.owner_role
  role        = each.value.role
  object_type = each.value.object_type
  privileges  = each.value.privileges

  depends_on = [
    #postgresql_role.app_users,
    postgresql_grant.privileges,
    postgresql_role.app_roles,
    postgresql_schema.schema,
    postgresql_database.db,
    postgresql_grant.revoke_create_public
  ]
}

########################################
# REVOKE CREATE ON SCHEMA public FROM PUBLIC;
# Because by default, the default privileges allow any user ("public")
# to create table inside "public" schema
########################################
resource "postgresql_grant" "revoke_create_public" {

  count       = var.revoke_create_public ? 1 : 0
  database    = var.inputs["db_name"]
  schema      = "public"
  role        = "public"
  object_type = "schema"
  privileges  = []

  depends_on = [
    postgresql_schema.schema,
    postgresql_database.db
  ]
}