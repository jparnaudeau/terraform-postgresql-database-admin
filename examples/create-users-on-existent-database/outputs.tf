output "db_users" {
   description = "The list of users created by the module"
   value       =  { for user in var.inputs["db_users"] : 
                    user.name => {
                      "secret_id"  = lookup(module.secrets-manager[user.name].secret_ids,format("secret-kv-%s",user.name)),
                      "secret_arn" = lookup(module.secrets-manager[user.name].secret_arns,format("secret-kv-%s",user.name))
                    } 
                  }
}
