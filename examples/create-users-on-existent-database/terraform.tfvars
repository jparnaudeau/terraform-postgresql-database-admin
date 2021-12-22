# provider connection infos
pgadmin_user = "postgres"
dbhost       = "localhost"
sslmode      = "disable"

# for post processing
postprocessing_playbook_params = {
  enable  = true
  db_name = "mydatabase"
  extra_envs = {
    REGION = "paris"
  }
  refresh_passwords = ["all"]
  shell_name        = "./gen-password.sh"
}

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


