output "db_users" {
   description = "The list of users created by the module"
   value       = { for tuple in var.db_users : tuple.name => merge(tuple, { "password" = var.passwords[tuple.name]})  }
   sensitive   = true
}
