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
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
}
