variable "region" {
  description = "The AWS Region"
  type        = string
  default     = "eu-west-3"
}

variable "environment" {
  description = "The environment for which we want retrieve infos on network"
  type        = string
  // validation {
  //   condition     = contains(["dev", "sta", "prod"], var.environment)
  //   error_message = "Valid values for var: environment are (dev, sta, prod)."
  // } 
}

variable "resources" {
  type        = map(string)
  description = "A list of resources value. possible resources value supported are : `database`"
  default     = {}
}

variable "vpc_name" {
  type        = string
  description = "The vpc label to find vpc resource"
}

variable "public_subnet_names" {
  type        = list(string)
  description = "The list of subnet names to use to retrieve subnets"
}

variable "private_subnet_names" {
  type        = list(string)
  description = "The list of subnet names to use to retrieve subnets"
}

variable "database_subnet_names" {
  type        = list(string)
  description = "The list of subnet names to use to retrieve subnets"
}
