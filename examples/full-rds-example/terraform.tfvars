# provider connection infos
expected_version = "12.0.0"
sslmode          = "disable"

# database and objects creation
inputs = {

  # parameters used for creating database
  db_schema_name = "public"
  db_name        = "mydatabase"     # should be the same as var.rds_name. if not, a new database will be created
  db_admin       = "app_admin_role" #owner of the database

  # install extensions if needed
  extensions = ["pgaudit"]

  # ---------------------------------- ROLES ------------------------------------------------------------------------------------
  # In this example, we want illustrate the "least privilege pattern". We have a schema in which 3 tables have been created : Customer, Product, Basket
  # We will create 4 roles :
  # - "app_admin_role" will be the role used for creation, deletion, grant operations on objects etc .. It's the "admin" role used for managed objects inside db 'mydatabase' (var.inputs['db_name']), schema 'public'
  # - "app_readonly_role" for readonly operations.
  # - "app_writeweb_role" for operations allowed from "web" application.
  # - "app_writebo_role" for operations allowed from "backoffice" application.
  db_roles = [
    { id = "admin", role = "app_admin_role", inherit = true, login = false, validity = "infinity", privileges = ["USAGE", "CREATE"], createrole = true },
    { id = "readonly", role = "app_readonly_role", inherit = true, login = false, validity = "infinity", privileges = ["USAGE"], createrole = false },
    { id = "writeweb", role = "app_writeweb_role", inherit = true, login = false, validity = "infinity", privileges = ["USAGE"], createrole = false },
    { id = "writebackoffice", role = "app_writebo_role", inherit = true, login = false, validity = "infinity", privileges = ["USAGE"], createrole = false },
  ],

  # ---------------------------------- GRANT PERMISSIONS ON ROLES ------------------------------------------------------------------------------------
  # you could find the available privileges on official postgresql doc : https://www.postgresql.org/docs/13/ddl-priv.html
  # Notes : 
  #   - "role" corresponds to the role on which the grants will be applied.
  #   - "owner_role" is the role used to create grants on "role".
  #   - object_type = "type" is used only for default privileges
  #   - objects = [] means "all"
  # all these grants are related to db 'mydatabase' (var.inputs['db_name']), schema 'public' (var.inputs['db_schema_name'])
  db_grants = [
    # define grants for app_admin_role : 
    # - access to all objects on database
    { object_type = "database", privileges = ["CREATE", "CONNECT", "TEMPORARY"], objects = [], role = "app_admin_role", owner_role = "root", grant_option = true },
    { object_type = "type", privileges = ["USAGE"], objects = [], role = "app_admin_role", owner_role = "root", grant_option = true },

    # define grants for app_readonly_role
    # - access to 'SELECT' on all tables 
    # - access to 'SELECT' on all sequences   
    { object_type = "database", privileges = ["CONNECT"], objects = [], role = "app_readonly_role", owner_role = "app_admin_role", grant_option = false },
    { object_type = "type", privileges = ["USAGE"], objects = [], role = "app_readonly_role", owner_role = "app_admin_role", grant_option = true },
    { object_type = "table", privileges = ["SELECT", "REFERENCES", "TRIGGER"], objects = [], role = "app_readonly_role", owner_role = "app_admin_role", grant_option = false },
    { object_type = "sequence", privileges = ["SELECT", "USAGE"], objects = [], role = "app_readonly_role", owner_role = "app_admin_role", grant_option = false },

    # define grants for app_writeweb_role
    # - access in Read/Write on tables "customer" & "Basket"
    # - access in Read on table "Product"
    { object_type = "database", privileges = ["CONNECT"], objects = [], role = "app_writeweb_role", owner_role = "app_admin_role", grant_option = false },
    { object_type = "type", privileges = ["USAGE"], objects = [], role = "app_writeweb_role", owner_role = "app_admin_role", grant_option = true },
    { object_type = "table", privileges = ["SELECT", "REFERENCES", "TRIGGER", "INSERT", "UPDATE", "DELETE"], objects = ["customer","basket"], role = "app_writeweb_role", owner_role = "app_admin_role", grant_option = false },
    { object_type = "table", privileges = ["SELECT", "REFERENCES", "TRIGGER"], objects = ["product"], role = "app_writeweb_role", owner_role = "app_admin_role", grant_option = false },
    { object_type = "sequence", privileges = ["SELECT", "USAGE"], objects = [], role = "app_writeweb_role", owner_role = "app_admin_role", grant_option = false },
    { object_type = "function", privileges = ["EXECUTE"], objects = [], role = "app_writeweb_role", owner_role = "app_admin_role", grant_option = false },

     # define grants for app_writebo_role
     # - access in Read/Write on table "Product"
     # - access in Read on table "Customer" & "Basket"
    { object_type = "database", privileges = ["CONNECT"], objects = [], role = "app_writebo_role", owner_role = "app_admin_role", grant_option = false },
    { object_type = "type", privileges = ["USAGE"], objects = [], role = "app_writebo_role", owner_role = "app_admin_role", grant_option = true },
    { object_type = "table", privileges = ["SELECT", "REFERENCES", "TRIGGER", "INSERT", "UPDATE", "DELETE"], objects = ["product"], role = "app_writebo_role", owner_role = "app_admin_role", grant_option = false },
    { object_type = "table", privileges = ["SELECT", "REFERENCES", "TRIGGER"], objects = ["customer","basket"], role = "app_writebo_role", owner_role = "app_admin_role", grant_option = false },
    { object_type = "sequence", privileges = ["SELECT", "USAGE"], objects = [], role = "app_writebo_role", owner_role = "app_admin_role", grant_option = false },
    { object_type = "function", privileges = ["EXECUTE"], objects = [], role = "app_writebo_role", owner_role = "app_admin_role", grant_option = false },
  ],

  db_users = [
    { name = "admin", inherit = true, login = true, membership = ["app_admin_role"], validity = "infinity", connection_limit = -1, createrole = true },
    { name = "reporting", inherit = true, login = true, membership = ["app_readonly_role"], validity = "infinity", connection_limit = -1, createrole = false },
    { name = "web", inherit = true, login = true, membership = ["app_writeweb_role"], validity = "infinity", connection_limit = -1, createrole = false },
    { name = "backoffice", inherit = true, login = true, membership = ["app_writebo_role"], validity = "infinity", connection_limit = -1, createrole = false },
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
vpc_database_subnets = ["10.66.6.0/24", "10.66.7.0/24", "10.66.8.0/24"]

# rds settings
rds_name                  = "myfullrdsexample"
rds_engine_version        = "13.5"
rds_major_engine_version  = "13"
rds_family                = "postgres13"
rds_instance_class        = "db.t3.micro"
rds_allocated_storage     = 10
rds_max_allocated_storage = 20
allowed_ip_addresses      = ["88.164.184.133/32","62.129.12.90/32"]


# define parameter groups for our RDS, apply_method = "immediate"
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
