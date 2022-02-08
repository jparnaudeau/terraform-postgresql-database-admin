########################################
# define global variables tags, env, ...
########################################
variable "tags" {
  type        = map(string)
  description = "a map of string used to tag entries in AWS Secrets Manager"
  default     = {}
}

variable "environment" {
  type        = string
  description = "environment name"
  default     = "sta"
}

variable "region" {
  type        = string
  description = "AWS Region name"
  default     = "eu-west-3"
}

variable "vpc_label" {
  type        = string
  description = "A label to use for vpc_name"
  default     = "main"
}
