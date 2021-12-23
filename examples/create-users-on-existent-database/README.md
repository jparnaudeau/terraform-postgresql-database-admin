# create-users-on-existent-database

This example shows you how to create users after a clean initialisation of a database i.e, with roles created in the example [simple-database](https://github.com/jparnaudeau/terraform-postgresql-database-admin/tree/master/examples/simple-database).

You can find a complete example for creating database, roles and users in the example [all-in-one](https://github.com/jparnaudeau/terraform-postgresql-database-admin/tree/master/examples/all-in-one).

This example provide a first illustration to "How to set password" with the postprocessing playbook.

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

#######################################
# Create Random Passwords for each user
#######################################
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


#########################################
# Create the users inside the database
#########################################
module "create_users" {

  source = "git::https://github.com/jparnaudeau/terraform-postgresql-database-admin.git//create-users?ref=master"

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
  postprocessing_playbook_params = var.postprocessing_playbook_params

}


```

Note : we use terraform resource `random_password` to initialize passwords, but the real passwords are setted by the postprocessing playbook. So even if the value of random_password are in clear text in the tfstate, the real passwords are not stored in the tfstate. 

### :warning: Important note:

We highly recommand you using **explicitly a version tag of this module** instead of branch reference since the latter is changing frequently. (use **ref=v1.0.0**,  don't use **ref=master**) 


## Define the inputs

in the `terraform.tfvars`, you could find : 

```hcl

inputs = {

  # ---------------------------------- USER  ------------------------------------------------------------------------------------
  # finally, we create : 
  # - a human user with the readonly permission and an expiration date (for troubelshooting by example)
  # - a user for a reporting application that requires only readonly permissions
  # - a user for a backend application that requires write permissions
  # 
  # Regarding passwords, it's the shell "gen-password.sh" executed in the postprocessing playbook that in charge to set password for each user.
  db_users = [
    { name = "audejavel", inherit = true, login = true, membership = ["app_readonly_role"], validity = "2021-12-31 00:00:00+00", connection_limit = -1, createrole = false },
    { name = "reporting", inherit = true, login = true, membership = ["app_readonly_role"], validity = "infinity", connection_limit = -1, createrole = false },
    { name = "backend", inherit = true, login = true, membership = ["app_write_role"], validity = "infinity", connection_limit = -1, createrole = false },
  ]

}

```

# Define the passwords with the postprocessing playbook

in the `terraform.tfvars`, you could find : 

```hcl

# for post processing
postprocessing_playbook_params = {
  enable = true
  db_name = "mydatabase"
  extra_envs = {
    REGION="paris"
  }
  refresh_passwords = ["all"]
  shell_name = "./gen-password.sh"
}

```

The different parameters available in the object `postprocessing_playbook_params` are : 

* **enable** : you need to enable the postprocessing playbook execution. If by example, you prepare passwords in a secure way, by example in an encrypted file, you can use a terraform datasource to read this file (see this [post](https://blog.gruntwork.io/a-comprehensive-guide-to-managing-secrets-in-your-terraform-code-1d586955ace1) ), you can pass directly the passwords into the module without the need to execute the postprocessing playbook. Otherwise, enable it.
* **db_name** : set the name of the database in which the users are related.
* **extra_envs** : you can pass extra environment variables that are available inside your script.
* **refresh_passwords** : you can force the execution of the postprocessing playbook for particular passwords. Just set in this field, the list of users for which you want a new password. In this case, a variable **REFRESH_PASSWORD** will be setted to `true`. Keep `all` if you want systematically regenerate new password for each user.
* **shell_name** : it's your responsability to write a shell that generate passwords, update the user in the postgresql database, and store it in a safe place.


# a dummy script used by the postprocessing playbook

The postprocessing playbook put the native postgresql environment variables : DBUSER, PGHOST, PGPORT, PGUSER, PGDATABASE. So you can use it inside your shell.

```

#!/bin/bash


if [ "${REFRESH_PASSWORD}" == "true" ]
then

    # generate a random password
    USERPWD=$(openssl rand -base64 16 |tr -d '[;+%$!/]');

    # Alter user inside postgresql database
    psql -c "ALTER USER $DBUSER WITH PASSWORD '$USERPWD'";

    # Alter Secret Storage
    echo "{password: $USERPWD}" > ./$DBUSER.json 

fi

exit 0

```

As you can see, we generate a random password and store the password in a file !! DO NOT DO THIS IN PRODUCTION !!. You can find a real secure script in the [all-in-one](https://github.com/jparnaudeau/terraform-postgresql-database-admin/tree/master/examples/all-in-one) example.