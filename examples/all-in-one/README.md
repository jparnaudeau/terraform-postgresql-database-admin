# all-in-one

This example shows a complete real case. In this example, we will : 

* create the database, create the admin, write and readOnly roles.

* create 3 users

* generate passwords, update the password for each user, and store it into AWS ParameterStore.


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

## Prepare fake passwords in ParameterStore

```hcl

####################################################################
# for each users defined in var.inputs, create 
# - a parameter in parameterStore for storing the user (path : <namespace>/<username>_user)
# - create a fake password for this user and 
# - save it into parameterStore at <namespace>/<username>_password
# 
# we do this for having only one case to manage in the postprocessing shell : 
# we update systematically the value of the parameter
####################################################################
locals {
  namespace = format("/%s/%s",var.environment,var.inputs["db_name"])
  tags      = merge(var.tags,{"environment" = var.environment})
}

# the ssm parameters for storing username
module "ssm_db_users" {
  source = "git::https://github.com/jparnaudeau/terraform-postgresql-database-admin.git//ssm-parameter?ref=master"
  for_each = { for user in var.inputs["db_users"] : user.name => user }

  namespace = local.namespace
  tags      = local.tags

  parameters = {
    format("%s_user", each.key) = {
      description = "db user param value rds database"
      value       = each.key
      overwrite   = false
    },
  }
}

# the random passwords for each user
resource "random_password" "passwords" {
  for_each = { for user in var.inputs["db_users"] : user.name => user }

  length           = 16
  special          = true
  upper            = true
  lower            = true
  min_upper        = 1
  number           = true
  min_numeric      = 1
  min_special      = 3
  override_special = "@#%&?"
}

# the ssm parameters for storing password of each user
module "fake_user_password" {
  source = "git::https://github.com/jparnaudeau/terraform-postgresql-database-admin.git//ssm-parameter?ref=master"
  for_each = { for user in var.inputs["db_users"] : user.name => user }

  namespace = local.namespace
  tags      = local.tags

  parameters = {
    format("%s_password", each.key) = {
      description = "db user param value rds database"
      value       = random_password.passwords[each.key].result
      type        = "SecureString"
      overwrite   = false
    },
  }
}

```

Notes : 

* here, we use an another submodule `ssm-parameter` that creates parameter in the parameterStore. Don't forget to set yours AWS Credentials by setting the variable **AWS_PROFILE**.
* for each user, we create 2 parameters in the parameterStore : `<namespace>/<username>_user` and `<namespace>/<username>_password`
* by creating the parameters before the postprocessing playbook, it simplifies the shell executed by the playbook.


## call the module to initialize the database and all objects (roles,grants)

```hcl

########################################
# Initialize the database and the objects 
# (roles & grants), the default privileges
########################################
module "initdb" {

  source = "../../create-database"

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


## call the module to create the users and use the postprocessing playbook to store passwords in parameterStore.

```hcl

#########################################
# Create the users inside the database
#########################################
# AWS Region
data "aws_region" "current" {}

module "create_users" {
  source = "git::https://github.com/jparnaudeau/terraform-postgresql-database-admin.git//create-users?ref=master"

  # need that all objects, managed inside the module "initdb", are created
  depends_on = [module.initdb]

  # set the provider
  providers = {
    postgresql = postgresql.pgadm
  }

  # targetted rds
  pgadmin_user = var.pgadmin_user
  dbhost       = var.dbhost
  dbport       = var.dbport

  # input parameters for creating users inside database
  db_users = var.inputs["db_users"]

  # set passwords
  passwords = { for user in var.inputs["db_users"] : user.name => random_password.passwords[user.name].result }

  # set postprocessing playbook
  postprocessing_playbook_params = {
    enable = true
    db_name = var.inputs["db_name"]
    extra_envs = {
      REGION = data.aws_region.current.name
      ENVIRONMENT = var.environment
    }
    refresh_passwords = ["all"]
    shell_name = "./gen-password-in-ps.sh"
  }

}

```

Note : note the "depends_on" on this module : the initialization of the database need to be done before creating users.


## Define the inputs

in the `terraform.tfvars`, you could find : 

```hcl

# database and objects creation
inputs = {

  # parameters used for creating database
  db_schema_name = "public"
  db_name        = "mydatabase"
  db_admin       = "app_admin_role"   #owner of the database

  # install extensions if needed
  extensions     = []
 
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

  db_users = [
    { name = "readonly", inherit = true, login = true, membership = ["app_readonly_role"], validity = "infinity", connection_limit = -1, createrole = false },
    { name = "backend", inherit = true, login = true, membership = ["app_write_role"], validity = "infinity", connection_limit = -1, createrole = false },
    { name = "admin", inherit = true, login = true, membership = ["app_admin_role"], validity = "infinity", connection_limit = -1, createrole = false },
  ]

}

# set tags & environment
environment = "test"
tags = {
  createdBy   = "terraform"
}

```

## Allowed UseCase Matrix 

Based on those inputs, this is the matrix providing permissions for the different users defined in this example : 

|DDB User|Login on database|Create/Drop Database|Create/Drop Schema|Create/Drop Role|Create/Drop Table|Insert/Delete items in Table|Select on table|
|--------|-----------------|--------------------|------------------|----------------|-----------------|----------------------------|---------------|
|postgres|OK               |                  OK|                OK|              OK|               OK|                          OK|             OK|
|admin   |               OK|                  OK|                OK|OK (By default can't create role)|OK|OK|OK|
|backend |OK               |OK (Permission denied)|OK (Permission denied)|OK (Permission denied)|OK (Permission denied)|OK|OK|
|readonly|OK               |OK (Permission denied)|OK (Permission denied)|OK (Permission denied)|OK (Permission denied)|OK (Permission denied)|OK|

Note : you can allow the user `admin` to create role, by using the field **createrole** in the **db_users** declaration.



## script used by the postprocessing playbook

The postprocessing playbook put the native postgresql environment variables : DBUSER, PGHOST, PGPORT, PGUSER, PGDATABASE. So you can use it inside your shell.

```

#!/bin/bash

# generate a random password
USERPWD=$(openssl rand -base64 16 |tr -d '[;+%$!/]');

# generate the parameterStore path
USER_PWD_PATH="/${ENVIRONMENT}/${PGDATABASE}/${DBUSER}_password"

# Alter user inside postgresql database
psql -c "ALTER USER $DBUSER WITH PASSWORD '$USERPWD'";

# Alter Secret Storage
aws ssm put-parameter --name $USER_PWD_PATH --type SecureString --overwrite --value $USERPWD --region $REGION;

exit 0

```

Notes : 

* By using a direct call on the api aws ssm put-parameter (and not using the terraform resource), we assure that the password is not stored into clear text in the tfstate.
* note the use of the variable `REGION`, setted in the map extra_envs in the main.tf.

## To summarize

launch `terraform apply --auto-approve`

```

Outputs:

affected_schema = "public"
connect_string = "psql -h localhost -p 5432 -U app_admin_role -d mydatabase"
created_database = "mydatabase"
created_roles = [
  "app_admin_role",
  "app_readonly_role",
  "app_write_role",
]
db_users = {
  "admin" = {
    "connect_command" = "psql -h localhost -p 5432 -U admin -d mydatabase -W"
    "parameter_store_user" = "test/mydatabase/rds/admin_user"
    "parameter_store_user_password" = "test/mydatabase/rds/admin_password"
  }
  "backend" = {
    "connect_command" = "psql -h localhost -p 5432 -U backend -d mydatabase -W"
    "parameter_store_user" = "test/mydatabase/rds/backend_user"
    "parameter_store_user_password" = "test/mydatabase/rds/backend_password"
  }
  "readonly" = {
    "connect_command" = "psql -h localhost -p 5432 -U readonly -d mydatabase -W"
    "parameter_store_user" = "test/mydatabase/rds/readonly_user"
    "parameter_store_user_password" = "test/mydatabase/rds/readonly_password"
  }
}

```


Connect with the admin user to create table

```

psql -h localhost -p 5432 -U admin -d mydatabase -W
Password: <find password in parameterStore at test/mydatabase/rds/admin_password>

psql (12.8 (Ubuntu 12.8-0ubuntu0.20.04.1), server 13.4 (Debian 13.4-4.pgdg110+1))
WARNING: psql major version 12, server major version 13.
         Some psql features might not work.
Type "help" for help.

mydatabase=> create table table1(col1 TEXT);
CREATE TABLE
mydatabase=> \q

```

Connect with the backend user to insert line into this table

```

psql -h localhost -p 5432 -U backend -d mydatabase -W
Password: <find password in parameterStore at test/mydatabase/rds/backend_password>

psql (12.8 (Ubuntu 12.8-0ubuntu0.20.04.1), server 13.4 (Debian 13.4-4.pgdg110+1))
WARNING: psql major version 12, server major version 13.
         Some psql features might not work.
Type "help" for help.

psql (12.8 (Ubuntu 12.8-0ubuntu0.20.04.1), server 13.4 (Debian 13.4-4.pgdg110+1))
WARNING: psql major version 12, server major version 13.
         Some psql features might not work.
Type "help" for help.

mydatabase=> insert into table1 values ('first line');
ERROR:  permission denied for table table1

```

* It's normal, we need to re-execute the terraform apply to propage permissions on this new table
* be carefull to pass the refresh_passwords to [""] if you don't want regenerate new password.


```

terraform apply --auto-approve

...

# Test with backend user
psql -h localhost -p 5432 -U backend -d mydatabase -W

Password:
psql (12.8 (Ubuntu 12.8-0ubuntu0.20.04.1), server 13.4 (Debian 13.4-4.pgdg110+1))
WARNING: psql major version 12, server major version 13.
         Some psql features might not work.
Type "help" for help.

mydatabase=> insert into table1 values ('first line');
INSERT 0 1

```

Test the permissions for readonly user : 

```

psql -h localhost -p 5432 -U readonly -d mydatabase -W
Password: <find password in parameterStore at test/mydatabase/rds/readonly_password>
psql (12.8 (Ubuntu 12.8-0ubuntu0.20.04.1), server 13.4 (Debian 13.4-4.pgdg110+1))
WARNING: psql major version 12, server major version 13.
         Some psql features might not work.
Type "help" for help.

mydatabase=> select * from table1;
    col1
------------
 first line
(1 row)

mydatabase=> create table table2(col1 TEXT);
ERROR:  permission denied for schema public
LINE 1: create table table2(col1 TEXT);

```
