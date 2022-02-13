# provider connection infos
pgadmin_user     = "postgres"
dbhost           = "localhost"
expected_version = "12.0.0"
sslmode          = "disable"

# database and objects creation
inputs = {

  # parameters used for creating database
  db_schema_name = "public"
  db_name        = "mydatabase"
  db_admin       = "app_admin_role" #owner of the database

  # install extensions if needed
  extensions = []

  # https://aws.amazon.com/blogs/database/managing-postgresql-users-and-roles/
  # 1) create Roles that are a set of permissions (named grant inside postgresql)
  # 2) set grants on role 
  # 3) create User (these users have username/password) that inherits their permissions from the role.
  #    You can retrieve the password from the parameterStore. cf shell gen-password-in-ps.sh

  # ---------------------------------- ROLES ------------------------------------------------------------------------------------
  # In this example, we create 3 roles
  # - "app_admin_role" will be the role used for creation, deletion, grant operations on objects, especially for tables.
  # - "app_write_role" for write operations. If you have a backend that insert lines into tables, it will used a user that inherits permissions from it.
  # - "app_readonly_role" for readonly operations.
  # Notes : 
  #   - "write" role does not have the permissions to create table.
  #   - the 'createrole' field is a boolean that provides a way to create other roles and put grants on it. Be carefull when you give this permission.
  db_roles = [
    { id = "admin", role = "app_admin_role", inherit = true, login = false, validity = "infinity", privileges = ["USAGE", "CREATE"], createrole = true },
    { id = "readonly", role = "app_readonly_role", inherit = true, login = false, validity = "infinity", privileges = ["USAGE"], createrole = false },
    { id = "write", role = "app_write_role", inherit = true, login = false, validity = "infinity", privileges = ["USAGE"], createrole = false },
  ],

  # ---------------------------------- GRANT PERMISSIONS ON ROLES ------------------------------------------------------------------------------------
  # you could find the available privileges on official postgresql doc : https://www.postgresql.org/docs/13/ddl-priv.html
  # Notes : 
  #   - "role" corresponds to the role on which the grants will be applied.
  #   - "owner_role" is the role used to create grants on "role".
  #   - object_type = "type" is used only for default privileges
  #   - objects = [] means "all". Use this attribut if you want to allow permissions on specific tables, functions, procedures, sequences. Concept of Least privileges
  #   - object_type = "type" is used only for default privileges

  db_grants = [
    # role app_admin_role : define grants to apply on db 'mydatabase', schema 'public'
    { object_type = "database", privileges = ["CREATE", "CONNECT", "TEMPORARY"], objects = [], role = "app_admin_role", owner_role = "postgres", grant_option = true },
    { object_type = "type", privileges = ["USAGE"], objects = [], role = "app_admin_role", owner_role = "postgres", grant_option = true },

    # role app_readonly_role : define grant to apply on db 'mydatabase', schema 'public'  
    { object_type = "database", privileges = ["CONNECT"], objects = [], role = "app_readonly_role", owner_role = "app_admin_role", grant_option = false },
    { object_type = "type", privileges = ["USAGE"], objects = [], role = "app_readonly_role", owner_role = "app_admin_role", grant_option = true },
    { object_type = "table", privileges = ["SELECT", "REFERENCES", "TRIGGER"], objects = [], role = "app_readonly_role", owner_role = "app_admin_role", grant_option = false },
    { object_type = "sequence", privileges = ["SELECT", "USAGE"], objects = [], role = "app_readonly_role", owner_role = "app_admin_role", grant_option = false },

    # role app_write_role : define grant to apply on db 'mydatabase', schema 'public'
    { object_type = "database", privileges = ["CONNECT"], objects = [], role = "app_write_role", owner_role = "app_admin_role", grant_option = false },
    { object_type = "type", privileges = ["USAGE"], objects = [], role = "app_write_role", owner_role = "app_admin_role", grant_option = true },
    { object_type = "table", privileges = ["SELECT", "REFERENCES", "TRIGGER", "INSERT", "UPDATE", "DELETE"], objects = [], role = "app_write_role", owner_role = "app_admin_role", grant_option = false },
    { object_type = "sequence", privileges = ["SELECT", "USAGE"], objects = [], role = "app_write_role", owner_role = "app_admin_role", grant_option = false },
    { object_type = "function", privileges = ["EXECUTE"], objects = [], role = "app_write_role", owner_role = "app_admin_role", grant_option = false },

  ],

  db_users = [
    { name = "readonly", inherit = true, login = true, membership = ["app_readonly_role"], validity = "infinity", connection_limit = -1, createrole = false },
    { name = "backend", inherit = true, login = true, membership = ["app_write_role"], validity = "infinity", connection_limit = -1, createrole = false },
    { name = "admin", inherit = true, login = true, membership = ["app_admin_role"], validity = "infinity", connection_limit = -1, createrole = false },
  ]

}

# set tags & environment
environment = "test"
tags = {
  createdBy = "terraform"
}

