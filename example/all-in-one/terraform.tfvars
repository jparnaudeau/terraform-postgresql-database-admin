# provider connection infos
pgadmin_user     = "postgres"
dbhost           = "winhost"
expected_version = "12.0.0"
sslmode          = "disable"

inputs = {

  # parameters used for creating database
  db_schema_name = "public"
  db_name        = "david"
  db_admin       = "postgres"   #owner of the database
  extensions     = []
 
  # https://aws.amazon.com/blogs/database/managing-postgresql-users-and-roles/
  # The user 'db_admin', created by terraform during deployment, is the "super-administrator", equivalent to "root" user on linux machine.
  # Security Best Practices recommends to NOT USE this user in your daily maintenance task or in your application. Instead, the good approach is : 
  # 1) create Roles that are a set of permissions (= grant)
  # 2) set grants on role 
  # 3) create User (these users have username/password) that inherits their permissions to the role. You can retrieve the password from the parameterStore,

  # ---------------------------------- ROLES ------------------------------------------------------------------------------------
  # In this example, we create 3 roles
  # - one "releng" (for reengineering) will be the role that you used for creation, deletion, grant operations on objects.
  # - one "readonly" for readonly operations.
  # - one "write" for write operations. If you have an application that insert lines into tables or objects, use this role. 
  # Note : "write" role does not have the permissions to create table.
  # Note : the role app_releng_role is a best practice and is mandatory : KEEP IT !!   db = "jerome"
  # Note : the privileges is applied on object_type = schema.
  #         USAGE = GRANT USAGE ON SCHEMA public TO readonly;
  db_roles = [
    { id = "releng", role = "app_releng_role", inherit = true, login = false, validity = "infinity", privileges = ["USAGE", "CREATE"], createrole = true },
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
    # role app_releng_role : define grants to apply on db 'jerome', schema 'public'
    { object_type = "database", privileges = ["CREATE", "CONNECT", "TEMPORARY"], role = "app_releng_role", owner_role = "postgres", grant_option = true },
    { object_type = "type", privileges = ["USAGE"], role = "app_releng_role", owner_role = "postgres", grant_option = true },

    # role app_readonly_role : define grant to apply on db 'jerome', schema 'public'  
    { object_type = "database", privileges = ["CONNECT"], role = "app_readonly_role", owner_role = "app_releng_role", grant_option = false },
    { object_type = "type", privileges = ["USAGE"], role = "app_readonly_role", owner_role = "app_releng_role", grant_option = true },
    { object_type = "table", privileges = ["SELECT", "REFERENCES", "TRIGGER"], role = "app_readonly_role", owner_role = "app_releng_role", grant_option = false },
    { object_type = "sequence", privileges = ["SELECT", "USAGE"], role = "app_readonly_role", owner_role = "app_releng_role", grant_option = false },

    # role app_write_role : define grant to apply on db 'jerome', schema 'public'
    { object_type = "database", privileges = ["CONNECT"], role = "app_write_role", owner_role = "app_releng_role", grant_option = false },
    { object_type = "type", privileges = ["USAGE"], role = "app_write_role", owner_role = "app_releng_role", grant_option = true },
    { object_type = "table", privileges = ["SELECT", "REFERENCES", "TRIGGER", "INSERT", "UPDATE", "DELETE"], role = "app_write_role", owner_role = "app_releng_role", grant_option = false },
    { object_type = "sequence", privileges = ["SELECT", "USAGE"], role = "app_write_role", owner_role = "app_releng_role", grant_option = false },
    { object_type = "function", privileges = ["EXECUTE"], role = "app_write_role", owner_role = "app_releng_role", grant_option = false },

  ],

  db_users = [
    { name = "aa_readonly", inherit = true, login = true, membership = ["app_readonly_role"], validity = "2022-11-25 00:00:00+00", connection_limit = -1, createrole = false },
    { name = "aa_audejavel2", inherit = true, login = true, membership = ["app_readonly_role"], validity = "2022-11-25 00:00:00+00", connection_limit = -1, createrole = false },
    { name = "aa_admin", inherit = true, login = true, membership = ["app_releng_role"], validity = "2022-11-25 00:00:00+00", connection_limit = -1, createrole = false },
  ]

}

# set tags & environment
environment = "test"
tags = {
  createdBy   = "terraform"
}

