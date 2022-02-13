terraform {
  required_version = ">= 1.0.4"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
      #source  = "terraform-providers/postgresql"
      version = ">= 1.15.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
}
