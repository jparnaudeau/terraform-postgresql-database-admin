########################################
# Initialize the database and the objects 
# (roles & grants), the default privileges
########################################
module "initdb" {

  source  = "jparnaudeau/database-admin/postgresql//create-database"
  version = "1.0.6"

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
  namespace = format("/%s/%s", var.environment, var.inputs["db_name"])
  tags      = merge(var.tags, { "environment" = var.environment })
}

# the ssm parameters for storing username
module "ssm_db_users" {
  source  = "jparnaudeau/database-admin/postgresql//ssm-parameter"
  version = "1.0.6"

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
  source  = "jparnaudeau/database-admin/postgresql//ssm-parameter"
  version = "1.0.6"

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

#########################################
# Create the users inside the database
#########################################
# AWS Region
data "aws_region" "current" {}

module "create_users" {
  source  = "jparnaudeau/database-admin/postgresql//create-users"
  version = "1.0.6"

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
    enable  = true
    db_name = var.inputs["db_name"]
    extra_envs = {
      REGION      = data.aws_region.current.name
      ENVIRONMENT = var.environment
    }
    refresh_passwords = ["all"]
    shell_name        = "./gen-password-in-ps.sh"
  }

}
