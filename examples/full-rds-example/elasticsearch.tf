########################################
# Retrieve infos on AWS STS Caller 
########################################
data "aws_caller_identity" "current" {}

###########################################
# Deploy an ElasticSearch Cluster
###########################################
module "elasticsearch" {
  source  = "cloudposse/elasticsearch/aws"
  version = "0.35.0"

  # create or not all related resources inside the module
  enabled = var.create_elasticsearch

  #naming
  namespace               = "soc"
  stage                   = var.environment
  name                    = "es"
  
  # config
  vpc_enabled                    = false
  zone_awareness_enabled         = false
  elasticsearch_version          = "7.4"
  instance_type                  = var.es_instance_type
  instance_count                 = var.es_instance_count
  ebs_volume_size                = var.es_ebs_volume_size
  iam_role_arns                  = [""]   # Allow anonymous access
  iam_actions                    = ["es:ESHttpGet", "es:ESHttpPut", "es:ESHttpPost"]
  encrypt_at_rest_enabled        = "true"
  kibana_subdomain_name          = "kibana-soc"
  create_iam_service_linked_role = false
  allowed_cidr_blocks            = var.allowed_ip_addresses

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }
}

###########################################
# Deploy a Role with appropriate permissions
# to allow the underlying lambda used by subscription
###########################################
## Role
data "aws_iam_policy_document" "lambda-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "subscriptionfilter-role" {
  count       = var.create_elasticsearch ? 1 : 0
  name        = format("role-%s-subscriptionfilter-rds-audit",var.environment)
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role-policy.json
}


## Policy
data "aws_iam_policy_document" "lambda-policy" {
  statement {
    sid = "AWSLambdaVPCAccessExecutionRole"
    effect = "Allow"
    actions = [
        "logs:Create*",
        "logs:Describe*",
        "es:ESHttpPost"
    ]
    resources = ["*"]
  }
  statement {
    sid = "AWSLambdaBasicExecutionRole"
    effect = "Allow"
    actions = [
        "logs:CreateLogStream",
        "logs:Put*",
        "logs:FilterLogEvents"
    ]
    resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:*"]
  }
}

resource "aws_iam_role_policy" "lambda-policy" {
  count  = var.create_elasticsearch ? 1 : 0
  name   = format("policy-%s-subscription-lambda-policy",var.environment)
  role   = aws_iam_role.subscriptionfilter-role[0].id
  policy = data.aws_iam_policy_document.lambda-policy.json
}
