/* 

--------------------------------------------------------------
RDS Audit Module 
--------------------------------------------------------------
This module allow you to get audit logs from your RDS Postgres 
database with PgAudit Activated

Author : Badr Bennasri 

*/


# AWS Region
data "aws_region" "current" {}

# AWS Account ID
data "aws_caller_identity" "current" {}

# Lambda file
data "archive_file" "lambda_src" {
  type        = "zip"
  source_file = "${path.module}/src/handler.py"
  output_path = "${path.module}/src/handler.zip"
}

# Module lambda usage  
module "lambda" {
  source = "git@gitlab.eulerhermes.io:cloud-devops/terraform-modules/lambda.git?ref=v3.6.2"

  filename          = data.archive_file.lambda_src.output_path
  handler           = "handler.handler"
  runtime           = "python3.8"
  description       = "Lambda RDS Stream audit logs for ${var.product_name}"
  product_name      = var.product_name
  environment       = var.environment
  short_description = var.short_description

  env = {
    RDS_INSTANCE_NAMES = join(",", var.rds_instances_list)
  }

  cloudwatch_retention_days = var.cloudwatch_retention_days

  lambda_alias = "STAGING"

  role_policy_count = 1

  role_policy_arns = [
    aws_iam_policy.lambda_rds_logging_policy.arn,
  ]

  attach_managed_sg = false

  tags = local.common_tags

  # Cloudwatch event rule
  source_services = ["events"]
  source_arns     = [aws_cloudwatch_event_rule.schedule_rule.arn]


}

# Cloudwatch event rule
resource "aws_cloudwatch_event_rule" "schedule_rule" {
  name                = "lambda_schedule_rule"
  description         = "Schedule rule for  ${var.product_name}"
  schedule_expression = var.cloudwatch_event_rule_schedule_expression
}

resource "aws_cloudwatch_event_target" "schedule_rule_target" {
  target_id = "cw-to-lambda"
  rule      = aws_cloudwatch_event_rule.schedule_rule.name
  arn       = module.lambda.arn
}

