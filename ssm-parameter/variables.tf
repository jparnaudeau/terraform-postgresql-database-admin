
variable "parameters" {
  description = "Parameters expressed as a map of maps. Each map's key is its intended SSM parameter name, and the value stored under that key is another map that may contain the following keys: description, type, and value."
  type        = map(map(string))
}

variable "namespace" {
  description = "Prefix prepended to parameter name if not using default"
  #default     = "/service"
}

variable "service" {
  description = "The name of the service to which this parameter list belongs, e.g. `rds`, `api`, `lambda-auth`"
  type        = string
}

variable "tags" {
  description = "common tags"
}
