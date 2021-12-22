########################################
# Provider vars
########################################
variable "pgadmin_user" {
  type        = string
  description = "The Postgresql username"
}

variable "dbhost" {
  type        = string
  description = "The Postgresql Database Hostname"
}

variable "dbport" {
  type        = string
  description = "The Postgresql Database Port"
}

########################################
# Input vars for Creating Objects inside Database
########################################
variable "revoke_create_public" {
  type        = bool
  description = "Enable/Disable the revoke command for create table in schema public"
  default     = true
}

variable "create_database" {
  type        = bool
  description = "Enable/Disable the creation of the database. Except for local tests or Cloud environment, the database creation is not possible. Disabled by default"
  default     = false
}

variable "inputs" {
  type = object({
    db_schema_name = string
    db_name        = string
    db_admin       = string
    #sslmode        = string
    extensions = list(string)
    db_roles = list(object({
      id         = string
      role       = string
      inherit    = bool
      login      = bool
      validity   = string
      privileges = list(string)
      createrole = bool
    }))
    db_grants = list(object({
      object_type = string
      privileges  = list(string)
      #schema       = string
      role         = string
      owner_role   = string
      grant_option = bool
    }))
  })
  description = "The Inputs parameters for objects to create inside the database"
  default     = null
}

variable "default_superusers_list" {
  type        = list(string)
  description = "List the super-users. By default, it's the postgres user."
  default     = ["postgres"]
}
