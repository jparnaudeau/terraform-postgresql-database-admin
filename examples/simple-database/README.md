# simple-database

This example shows you how to use the module to create a database and all roles and permissions. It is usefull for : 

* create a database locally. It's the case with the use of the docker-compose
* in a cloud environment : After you have created an postgresql instance, you have a super-user and you want to create the database and prepare the database with roles and permissions.

## Prepare you postgresql provider

```hcl

#######################################
# Define Providers pgadm & pgmgm for postgresql
#######################################
provider "postgresql" {
  alias            = "pgadm"
  host             = var.dbhost
  port             = var.dbport
  username         = var.pgadmin_user
  sslmode          = var.sslmode
  connect_timeout  = var.connect_timeout
  superuser        = var.superuser
  expected_version = var.expected_version
}

provider "postgresql" {
  alias            = "pgmgm"
  host             = var.dbhost
  port             = var.dbport
  database         = var.inputs["db_name"]
  username         = var.pgadmin_user
  sslmode          = var.sslmode
  connect_timeout  = var.connect_timeout
  superuser        = var.superuser
  expected_version = var.expected_version
}

```

Note : the password of the `var.pgadmin_user` are stored in the environment variable **PGPASSWORD** that you must setted before the terraform plan or apply. 

## Call the module

```hcl

module "initdb" {

  source  = "jparnaudeau/database-admin/postgresql//create-database"
  version = "2.0.0"

  # set the provider
  providers = {
    postgresql = postgresql.pgadm
  }

  # targetted rds
  pgadmin_user = var.pgadmin_user
  dbhost       = var.dbhost
  dbport       = var.dbport

  # input parameters for creating database & objects inside database
  create_database = true
  inputs          = var.inputs
}


```


## Define the inputs

in the `terraform.tfvars`, you could find : 

```hcl

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
    { object_type = "database", privileges = ["CREATE", "CONNECT", "TEMPORARY"], objects = [],  role = "app_admin_role", owner_role = "postgres", grant_option = true },
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

}

```
