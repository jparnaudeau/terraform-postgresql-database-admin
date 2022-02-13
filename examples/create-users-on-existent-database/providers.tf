#######################################
# Define Providers pgadm & pgmgm for postgresql
#######################################
provider "postgresql" {
  alias            = "pgadm"
  host             = var.dbhost
  port             = var.dbport
  username         = var.pgadmin_user
  sslmode          = var.sslmode
  connect_timeout  = var.connect_timeout
  superuser        = var.superuser
  expected_version = var.expected_version
}

provider "postgresql" {
  alias            = "pgmgm"
  host             = var.dbhost
  port             = var.dbport
  database         = var.inputs["db_name"]
  username         = var.pgadmin_user
  sslmode          = var.sslmode
  connect_timeout  = var.connect_timeout
  superuser        = var.superuser
  expected_version = var.expected_version
}


#######################################
# Manage version of providers
#######################################
terraform {
  required_version = ">= 1.0.4"
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.15.0"
    }
  }
}
