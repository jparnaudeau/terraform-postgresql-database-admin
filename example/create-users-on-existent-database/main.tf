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
# Store key/value username/password in AWS SecretManagers
#########################################
module "secrets-manager" {
  for_each = { for user in var.inputs["db_users"] : user.name => user }
  source  = "lgallard/secrets-manager/aws"
  version = "0.5.1"

  secrets = {
    "secret-kv-${each.key}" = {
      description = format("Secret access from username %s",each.key)
      secret_key_value = {
        username = each.key
        password = random_password.passwords[each.key].result
      }
      recovery_window_in_days = var.recovery_window_in_days
    },
  }

  tags = var.tags
}



#########################################
# Create the users inside the database
#########################################
module "create_users" {
  source = "../../create-users"

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
