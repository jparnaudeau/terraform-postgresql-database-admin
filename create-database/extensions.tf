########################################
# Extras Schemas Creation 
# + creation of grants for the role "app_releng_role" inside schema
# here, we assume that the role "app_releng_role" is defined
########################################
resource "postgresql_extension" "psql_extension" {

  for_each = toset(var.inputs["extensions"])
  name     = each.key

  depends_on = [
    postgresql_role.app_roles,
    postgresql_database.db,
  ]
}
