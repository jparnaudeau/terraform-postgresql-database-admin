########################################
# Initialize the database and the objects 
# (roles & grants), the default privileges
########################################
module "initdb" {

  source = "../../create-database"

  depends_on = [module.rds]

  # set the provider
  providers = {
    postgresql = postgresql.pgadm
  }

  # targetted rds
  pgadmin_user = var.rds_superuser_name
  dbhost       = module.rds.db_instance_address
  dbport       = var.dbport

  # input parameters for creating database & objects inside database
  create_database = false
  inputs          = var.inputs

  # because the superuser is not "postgres", need to set it in the module
  default_superusers_list = ["postgres", var.rds_superuser_name]
}

####################################################################
# for each users defined in var.inputs, create 
# - create a fake password for this user
# - save it into secretsManager with key = "secret-kv-${rds_name}-${username}"
# 
# we do this for having only one case to manage in the postprocessing shell : 
# we update systematically the value of the secret.
####################################################################

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

#########################################
# Store key/value username/password in AWS SecretsManager
#########################################
module "secrets-manager" {
  for_each = { for user in var.inputs["db_users"] : user.name => user }
  source   = "lgallard/secrets-manager/aws"
  version  = "0.5.1"

  secrets = {
    "secret-kv-${local.name}-${each.key}" = {
      description = format("Password for username %s for database %s", each.key, local.name)
      secret_key_value = {
        username = each.key
        password = random_password.passwords[each.key].result
      }
      recovery_window_in_days = var.recovery_window_in_days
    },
  }

  tags = local.tags
}

#########################################
# Create the users inside the database
#########################################
# AWS Region
data "aws_region" "current" {}

module "create_users" {
  source = "../../create-users"

  # need that all objects, managed inside the module "initdb", are created
  depends_on = [module.initdb]

  # set the provider
  providers = {
    postgresql = postgresql.pgadm
  }

  # targetted rds
  pgadmin_user = var.rds_superuser_name
  dbhost       = module.rds.db_instance_address
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
      REGION   = data.aws_region.current.name
      RDS_NAME = var.rds_name
    }
    refresh_passwords = ["all"]
    shell_name        = "./gen-password-in-secretsmanager.py"
  }

}
