terraform {
  required_version = ">= 0.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.70, < 4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0.0"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
      #source  = "terraform-providers/postgresql"
      version = "~> 1.11.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0.0"
    }
  }
}
