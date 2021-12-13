##############################################################
#
# Lambda Outputs
#
##############################################################

output "lambda_arn" {
  value       = module.lambda.arn
  description = "The ARN identifying created lambda function."
}

output "lambda_name" {
  value       = module.lambda.lambda_name
  description = "The name of created lambda function."
}


##############################################################
#
# Lambda CW Log Group Outputs
#
##############################################################

output "log_group_name" {
  value       = module.lambda.log_group_name
  description = "Log Group Name."
}

output "log_group_arn" {
  value       = module.lambda.log_group_arn
  description = "Log Group ARN."
}

