########################################
# Creation of users. a user is a role with
# a permission to log in.
########################################
resource "postgresql_role" "app_users" {
  for_each = { for tuple in var.db_users : tuple.name => tuple }

  name                = each.value.name
  login               = each.value.login
  roles               = each.value.membership
  inherit             = each.value.inherit
  valid_until         = each.value.validity
  encrypted_password  = true
  password            = var.passwords[each.key]
  skip_drop_role      = false
  skip_reassign_owned = false
  create_role         = lookup(each.value, "createrole", false)
  connection_limit    = each.value.connection_limit
  search_path         = lookup(each.value, "search_path", null)
}

#######################################
# modify postgres app_users (previously created) password 
# and update the corresponding parameter store value
########################################
locals {
  postprocessing_users = var.postprocessing_playbook_params["enable"] ? var.db_users : []
}

resource "null_resource" "pgusers_postprocessing_playbook" {
  depends_on = [postgresql_role.app_users]

  for_each = { for tuple in local.postprocessing_users : tuple.name => tuple }

  triggers = {
    appuser_to_update = postgresql_role.app_users[each.key].name
    refresh_password  = timestamp()
  }

  provisioner "local-exec" {
    when = create
    environment = merge({
      DBUSER           = self.triggers.appuser_to_update
      PGHOST           = var.dbhost
      PGPORT           = var.dbport
      PGUSER           = var.pgadmin_user
      PGDATABASE       = var.postprocessing_playbook_params["db_name"]
      SHELL_TO_EXECUTE = var.postprocessing_playbook_params["shell_name"]
      REFRESH_PASSWORD = contains(var.postprocessing_playbook_params["refresh_passwords"], each.key) || try(var.postprocessing_playbook_params["refresh_passwords"][0], "") == "all"
      },
      var.postprocessing_playbook_params["extra_envs"]
    )

    command = <<EOT
      sh -c $SHELL_TO_EXECUTE
    EOT
  }
}
