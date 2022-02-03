# provider connection infos
#pgadmin_user     = "postgres"
#dbhost           = "localhost"
expected_version = "12.0.0"
sslmode          = "disable"

# database and objects creation
inputs = {

  # parameters used for creating database
  db_schema_name = "public"
  db_name        = "mydatabase"  # should be the same as var.rds_name. if not, a new database will be created
  db_admin       = "app_admin_role" #owner of the database

  # install extensions if needed
  extensions = ["pgaudit"]

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
  # Note : "write" role does not have the permissions to create table.
  # Note : the 'createrole' field is a boolean that provides a way to create other roles and put grants on it. Be carefull when you give this permission.
  db_roles = [
    { id = "admin", role = "app_admin_role", inherit = true, login = false, validity = "infinity", privileges = ["USAGE", "CREATE"], createrole = true },
    { id = "readonly", role = "app_readonly_role", inherit = true, login = false, validity = "infinity", privileges = ["USAGE"], createrole = false },
    { id = "write", role = "app_write_role", inherit = true, login = false, validity = "infinity", privileges = ["USAGE"], createrole = false },
  ],

  # ---------------------------------- GRANT PERMISSIONS ON ROLES ------------------------------------------------------------------------------------
  # Notes : 
  # the concept of "Least privilege" need to be applied here.
  # in the structure of a grant, there is the "role" and the "owner_role"
  # "role" corresponds to the role on which the grants will be applied.
  # "owner_role" is the role used to create grants on "role".
  # you could find the available privileges on official postgresql doc : https://www.postgresql.org/docs/13/ddl-priv.html
  # Note object_type = "type" is used only for default privileges
  db_grants = [
    # role app_admin_role : define grants to apply on db 'mydatabase', schema 'public'
    { object_type = "database", privileges = ["CREATE", "CONNECT", "TEMPORARY"], role = "app_admin_role", owner_role = "root", grant_option = true },
    { object_type = "type", privileges = ["USAGE"], role = "app_admin_role", owner_role = "root", grant_option = true },

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

################################################
# VPC & RDS Customization
################################################

# a standard vpc
vpc_cidr = "10.66.0.0/18"

vpc_public_subnets   = ["10.66.0.0/24", "10.66.1.0/24", "10.66.2.0/24"]
vpc_private_subnets  = ["10.66.3.0/24", "10.66.4.0/24", "10.66.5.0/24"]
vpc_database_subnets = ["10.66.7.0/24", "10.66.8.0/24", "10.66.9.0/24"]

# rds settings
rds_name                  = "myfullrdsexample"
rds_engine_version        = "13.5"
rds_major_engine_version  = "13"
rds_family                = "postgres13"
rds_instance_class        = "db.t3.micro"
rds_allocated_storage     = 10
rds_max_allocated_storage = 20
allowed_ip_addresses      = ["88.164.184.133/32"]


# define parameter groups for our RDS
parameter_group_params = {
  autovacuum         = 1
  client_encoding    = "utf8"
  log_connections    = "1",
  log_disconnections = "1",
  log_statement      = "all",
}

# for setting extension parameter, the apply_method need to be "pending-reboot"
# aws rds reboot-db-instance --db-instance-identifier xxx
# extension pg_stat_statements : https://pganalyze.com/docs/install/amazon_rds/01_configure_rds_instance
# extension pg_audit           : https://aws.amazon.com/premiumsupport/knowledge-center/rds-postgresql-pgaudit/?nc1=h_ls
extensions_parameter_group_params = {
  "shared_preload_libraries"   = "pgaudit",
  "track_activity_query_size"  = "2048",
  "pgaudit.log"                = "ALL",
  "pgaudit.log_level"          = "info",
  "pgaudit.log_statement_once" = "1"
}
