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
  
  # CREATE ROLE
  db_roles = [
    { id = "admin", role = "app_admin_role", inherit = true, login = false, validity = "infinity", privileges = ["USAGE", "CREATE"], createrole = true },
  ],

  #  GRANT PERMISSIONS ON ROLES
  db_grants = [
    # define grants for app_admin_role : 
    # - access to all objects on database
    { object_type = "database", privileges = ["CREATE", "CONNECT", "TEMPORARY"], objects = [], role = "app_admin_role", owner_role = "root", grant_option = true },
    { object_type = "type", privileges = ["USAGE"], objects = [], role = "app_admin_role", owner_role = "root", grant_option = true },

  ],

  # CREATE USER
  db_users = [
    { name = "admin", inherit = true, login = true, membership = ["app_admin_role"], validity = "infinity", connection_limit = -1, createrole = true },
  ]

}

# Refresh or not refresh passwords
refresh_passwords = ["all"]

# set tags & environment
environment = "test"
tags = {
  createdBy     = "terraform"
  "ippon:owner" = "jparnaudeau"
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
allowed_ip_addresses      = ["88.164.184.133/32"] # your personal Outbound IP Address
rds_superuser_name        = "root"

# define parameter groups for our RDS, apply_method = "immediate"
# for setting pg_extension parameters, the apply_method need to be "pending-reboot"
# reboot required if the database already exsits : aws rds reboot-db-instance --db-instance-identifier xxx
# extension pg_stat_statements : https://pganalyze.com/docs/install/amazon_rds/01_configure_rds_instance
# extension pg_audit           : https://aws.amazon.com/premiumsupport/knowledge-center/rds-postgresql-pgaudit/?nc1=h_ls
parameter_group_params = {
  immediate = {
    autovacuum         = 1
    client_encoding    = "utf8"
    log_connections    = "1"
    log_disconnections = "1"
    log_statement      = "all"
  }
  pending-reboot = {
    shared_preload_libraries     = "pgaudit",
    track_activity_query_size    = "2048",
    "pgaudit.log"                = "ALL",
    "pgaudit.log_level"          = "info",
    "pgaudit.log_statement_once" = "1"
  }
}

################################################
# ElasticSearch
################################################
create_elasticsearch = false
es_instance_type     = "t3.small.elasticsearch"
es_instance_count    = 1
es_ebs_volume_size   = 10
 