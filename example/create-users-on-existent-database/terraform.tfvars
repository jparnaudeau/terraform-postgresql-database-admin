# provider connection infos
pgadmin_user     = "postgres"
dbhost           = "winhost"
sslmode          = "disable"

# set tags
tags={
  environment = "test"
  createdBy   = "terraform"
}

# for post processing
postprocessing_playbook_params = {
  enable = true
  db_name = "jerome"
  extra_envs = {
    REGION="myfuckingregion"
  }
  refresh_passwords = []
  shell_name = "./gen-password.sh"
}

inputs = {

  # ---------------------------------- USER  ------------------------------------------------------------------------------------
  # finally, we create : 
  # - a db_user 'sa_admin'     : service account (sa) - used to init database when boostraping application
  # - a db_user 'sa_myapp'     : service account (sa) - need write permissions
  # - a 'human' db_user 'pa009093' for debugging and explore data : based on a privileged Account (pa) - need only readonly permissions
  # you could find the generated password for these users in parameterStore in : 
  #  /{env}/{product_name}/{short_description}/rds/db_{username}_password
  db_users = [
    { name = "readonly", inherit = true, login = true, membership = ["app_readonly_role"], validity = "2022-11-25 00:00:00+00", connection_limit = -1, createrole = false },
    { name = "audejavel2", inherit = true, login = true, membership = ["app_readonly_role"], validity = "2022-11-25 00:00:00+00", connection_limit = -1, createrole = false },
    { name = "admin", inherit = true, login = true, membership = ["app_releng_role"], validity = "2022-11-25 00:00:00+00", connection_limit = -1, createrole = false },
  ]

}


