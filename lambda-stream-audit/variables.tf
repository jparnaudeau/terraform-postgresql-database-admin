
variable "environment" {
  description = "Envrionment name. Ie: dev, sandbox, ..."
  type        = string
}

variable "costcenter" {
  description = "CostCenter"
  type        = string
}

variable "owner" {
  description = "Email of the team owning application"
  type        = string
}

variable "product_name" {
  description = "Product Name"
  type        = string
}

variable "short_description" {
  description = "Short description of the lambda"
  type        = string
  default     = "rds-stream-auditlogs"
}

variable "rds_instances_list" {
  description = "List of RDS instances you want to audit"
  type        = list(string)
}


variable "cloudwatch_retention_days" {
  description = "Number of days for which to retain log events in the specified log group"
  type        = number
  default     = 14
}

variable "cloudwatch_event_rule_schedule_expression" {
  description = "Number of days for which to retain log events in the specified log group"
  type        = string
  default     = "rate(15 minutes)"
}






