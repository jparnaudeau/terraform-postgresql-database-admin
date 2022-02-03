#######################################
# Define Providers pgadm & pgmgm for postgresql
#######################################
provider "postgresql" {
  alias            = "pgadm"
  host             = module.rds.db_instance_address
  port             = var.dbport
  username         = var.rds_superuser_name
  sslmode          = var.sslmode
  connect_timeout  = var.connect_timeout
  superuser        = var.superuser
  expected_version = var.expected_version
}

provider "postgresql" {
  alias            = "pgmgm"
  host             = module.rds.db_instance_address
  port             = var.dbport
  database         = var.inputs["db_name"]
  username         = var.rds_superuser_name
  sslmode          = var.sslmode
  connect_timeout  = var.connect_timeout
  superuser        = var.superuser
  expected_version = var.expected_version
}

#######################################
# Define Provider for aws
#######################################
provider "aws" {
  region = var.region
}

#######################################
# Manage version of providers
#######################################
terraform {
  required_version = ">= 1.0.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.15"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.11.0"
    }
    random = {
      source = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
}
