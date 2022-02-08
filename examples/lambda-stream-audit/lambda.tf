#####################################
# deploy our lambda function
#####################################
locals {
    function_name = "rds-audit-steam"
}

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "2.34.0"

  # set global attributs
  function_name = format("lbd-%s-%s", var.environment,local.function_name)
  publish       = true
  handler       = "index.handler"
  runtime       = "python3.9"
  source_path = [
    "${path.module}/src/index.py",
  ]

  # attach a cloudWatch log group
  attach_cloudwatch_logs_policy = true

  # add environment variables
  environment_variables = {
    RDS_INSTANCES = module.networkdata.database_identifier
    FORMAT = "JSON"
  }

  # add additional permissions to stream log from rds
  attach_policy_statements = true
  policy_statements = {
    rds_dblogfiles = {
      effect = "Allow",
      actions = [
        "rds:DownloadDBLogFilePortion",
        "rds:DescribeDBLogFiles",
        "rds:DownloadCompleteDBLogFile"
      ],
      resources = [module.networkdata.database_arn]
    },
  }

  # put tags on lambda function
  tags = local.tags
}

##############################
# Trigger every 15 min our lambda function
##############################
resource "aws_cloudwatch_event_rule" "trigger_lambda" {
  name                = "cer-${var.environment}-${local.function_name}-trigger"
  description         = "Event rule to trigger ${local.function_name} Lambda function."
  is_enabled          = true
  schedule_expression = "cron(0/15 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule      = aws_cloudwatch_event_rule.trigger_lambda.name
  target_id = "TriggerRdsAudit"
  arn       =  module.lambda.lambda_function_arn
}

resource "aws_lambda_permission" "trigger_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_function_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger_lambda.arn
}
