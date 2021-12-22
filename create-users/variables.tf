########################################
# Provider vars
########################################
variable "pgadmin_user" {
  type        = string
  description = "The RDS Master username"
}

variable "dbhost" {
  type        = string
  description = "The RDS DB Hostname"
}

variable "dbport" {
  type        = string
  description = "The RDS DB Port"
}

########################################
# passwords vars
########################################
variable "passwords" {
  type        = map(string)
  description = "Map of credentials, <username> = <password>"
  default     = {}
}

########################################
# Input vars for creating users inside database
########################################
variable "db_users" {
  type = list(object({
    name             = string
    inherit          = bool
    login            = bool
    membership       = list(string)
    validity         = string
    connection_limit = number
    createrole       = bool
    })
  )
  description = "The Inputs parameters for objects to create inside the database"
  default     = null
}


########################################
# params used inside postprocessing playbook.
# this playbook allows you to update in-fly the password and store it inside the secrets vault of your choice
# for doing this, you need to : 
# enable  : enable the postprocessing playbook. disable (false) by default.
# db_name : the database name on which the user is created
# shell_name : provide a shell that will be executed by the playbook. The playbook set environment variables : 
#  - postgresql native environment variables : DBUSER, PGHOST, PGPORT, PGUSER, PGDATABASE
#  - any extra environment variables setted in extra_envs 
# extra_envs : a map containing extra environments variables that you want manipulate inside your shell.
########################################
variable "postprocessing_playbook_params" {
  description = "params for postprocessing playbook"
  type = object({
    enable            = bool
    db_name           = string
    extra_envs        = map(string)
    shell_name        = string
    refresh_passwords = list(string)
  })
  default = {
    enable            = false
    db_name           = ""
    extra_envs        = {}
    shell_name        = ""
    refresh_passwords = []
  }
}