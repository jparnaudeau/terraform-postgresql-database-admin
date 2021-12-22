
variable "parameters" {
  description = "Parameters expressed as a map of maps. Each map's key is its intended SSM parameter name, and the value stored under that key is another map that may contain the following keys: description, type, and value."
  type        = map(map(string))
}

variable "namespace" {
  type        = string
  description = "Prefix prepended to parameter name if not using default"
}

variable "tags" {
  type        = map(string)
  description = "common tags"
  default     = {}
}
