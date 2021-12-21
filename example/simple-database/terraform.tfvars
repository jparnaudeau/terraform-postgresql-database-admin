# provider connection infos
pgadmin_user     = "postgres"
dbhost           = "localhost"
expected_version = "12.0.0"
sslmode          = "disable"

inputs = {

  # parameters used for creating a database named 'mydatabase' and for creating objects in the public schema
  db_schema_name = "public"
  db_name        = "mydatabase"
  db_admin       = "app_admin_role"   # owner of the database
  extensions     = []
 
  # ---------------------------------- ROLES ------------------------------------------------------------------------------------
  # In this example, we create 3 roles
  # - "app_admin_role" will be the role used for creation, deletion, grant operations on objects, especially for tables.
  # - "app_write_role" for write operations. If you have a backend that insert lines into tables, it will used a user that inherits permissions from it.
  # - "app_readonly_role" for readonly operations.
  # Note : "write" role does not have the permissions to create table.
  # Note : the 'createrole' field is a boolean that provides a way to create other roles and put grants on it. Be carefull when you give this permission (privilege escalation).
  db_roles = [
    { id = "admin", role = "app_admin_role", inherit = true, login = false, validity = "infinity", privileges = ["USAGE", "CREATE"], createrole = true },
    { id = "readonly", role = "app_readonly_role", inherit = true, login = false, validity = "infinity", privileges = ["USAGE"], createrole = false },
    { id = "write", role = "app_write_role", inherit = true, login = false, validity = "infinity", privileges = ["USAGE"], createrole = false },

  ],

  # ---------------------------------- GRANT PERMISSIONS ON ROLES ------------------------------------------------------------------------------------
  # Notes : 
  # the concept of "Least privilege" need to be applied here.
  # in the structure of a grant, there is the "role" and "owner_role"
  # "role" corresponds to the role on which the grants will be applied
  # "owner_role" is the role used to create grants on "role".
  # you could find the available privileges on official postgresql doc : https://www.postgresql.org/docs/13/ddl-priv.html
  # Note object_type = "type" is used only for default privileges
  db_grants = [
    # role app_admin_role : define grants to apply on db 'mydatabase', schema 'public'
    { object_type = "database", privileges = ["CREATE", "CONNECT", "TEMPORARY"], role = "app_admin_role", owner_role = "postgres", grant_option = true },
    { object_type = "type", privileges = ["USAGE"], role = "app_admin_role", owner_role = "postgres", grant_option = true },

    # role app_readonly_role : define grant to apply on db 'mydatabase', schema 'public'  
    { object_type = "database", privileges = ["CONNECT"], role = "app_readonly_role", owner_role = "app_admin_role", grant_option = false },
    { object_type = "type", privileges = ["USAGE"], role = "app_readonly_role", owner_role = "app_admin_role", grant_option = true },
    { object_type = "table", privileges = ["SELECT", "REFERENCES", "TRIGGER"], role = "app_readonly_role", owner_role = "app_admin_role", grant_option = false },
    { object_type = "sequence", privileges = ["SELECT", "USAGE"], role = "app_readonly_role", owner_role = "app_admin_role", grant_option = false },

    # role app_write_role : define grant to apply on db 'mydatabase', schema 'public'
    { object_type = "database", privileges = ["CONNECT"], role = "app_write_role", owner_role = "app_admin_role", grant_option = false },
    { object_type = "type", privileges = ["USAGE"], role = "app_write_role", owner_role = "app_admin_role", grant_option = true },
    { object_type = "table", privileges = ["SELECT", "REFERENCES", "TRIGGER", "INSERT", "UPDATE", "DELETE"], role = "app_write_role", owner_role = "app_admin_role", grant_option = false },
    { object_type = "sequence", privileges = ["SELECT", "USAGE"], role = "app_write_role", owner_role = "app_admin_role", grant_option = false },
    { object_type = "function", privileges = ["EXECUTE"], role = "app_write_role", owner_role = "app_admin_role", grant_option = false },

  ],

}

