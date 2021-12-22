variable "dbhost" {
  type        = string
  default     = "localhost"
  description = "The database host"
}

variable "dbport" {
  type        = number
  default     = 5432
  description = "The database port"
}

variable "pgadmin_user" {
  type        = string
  description = "The RDS user to used for creating/managing other user in the database."
}

variable "sslmode" {
  type        = string
  description = "Set the priority for an SSL connection to the server. Valid values are [disable,require,verify-ca,verify-full]"
  default     = "require"
}

variable "connect_timeout" {
  type        = number
  description = "Maximum wait for connection, in seconds. The default is 180s. Zero or not specified means wait indefinitely."
  default     = 180
}

variable "superuser" {
  type        = bool
  description = "Should be set to false if the user to connect is not a PostgreSQL superuser"
  default     = false
}

variable "expected_version" {
  type        = string
  description = "Specify a hint to Terraform regarding the expected version that the provider will be talking with. This is a required hint in order for Terraform to talk with an ancient version of PostgreSQL. This parameter is expected to be a PostgreSQL Version or current. Once a connection has been established, Terraform will fingerprint the actual version. Default: 9.0.0"
  default     = "12.0.0"
}

variable "inputs" {
  type = any
  description = "The map containing all elements for creating objects inside database"
  default     = null
}

variable "postprocessing_playbook_params" {
  description = "params for postprocessing playbook"
  type = any
  default = null
}