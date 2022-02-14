########################################
# Retrieve infos on AWS STS Caller 
########################################
data "aws_caller_identity" "current" {}

#########################################
# Because of a cyclic dependency, we need to 
# create the role of the lambda.
#########################################
resource "aws_iam_role" "lambda-role" {
  name               = format("role-%s-%s", var.environment, local.lambda_function_name)
  assume_role_policy = file("${path.module}/policies/lambda_role.json")
}

resource "aws_iam_role_policy" "lambda-policy" {
  name = format("policy-%s-%s", var.environment, local.lambda_function_name)
  role = aws_iam_role.lambda-role.id
  policy = templatefile("${path.module}/policies/lambda_policy.tpl", {
    account_id = data.aws_caller_identity.current.account_id,
    region     = var.region
  })
}


###########################################
# Deploy an ElasticSearch Cluster
###########################################
module "elasticsearch" {
  source  = "cloudposse/elasticsearch/aws"
  version = "0.35.0"

  # create or not all related resources inside the module
  enabled = var.create_elasticsearch

  #naming
  namespace = "soc"
  stage     = var.environment
  name      = "es"

  # config
  vpc_enabled            = false
  zone_awareness_enabled = false
  elasticsearch_version  = "7.4"
  instance_type          = var.es_instance_type
  instance_count         = var.es_instance_count
  ebs_volume_size        = var.es_ebs_volume_size
  # because of a cyclic dependencies, create in a first step the elasticsearch without allowing the role of the lambda streaming 
  iam_role_arns                  = [aws_iam_role.lambda-role.arn]
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
# Deploy a subscription filter on RDS CloudWatch Logs
# to stream logs on an ElasticSearch domain endpoint
###########################################
module "stream2es" {
  source  = "jparnaudeau/cloudwatch-subscription-elasticsearch/aws"
  version = "1.0.0"

  for_each = var.create_elasticsearch ? toset(["1"]) : []

  # gloval variables
  region      = var.region
  environment = var.environment
  tags        = local.tags

  # other variables
  function_name           = local.lambda_function_name
  rds_name                = var.rds_name
  rds_cloudwatch_log_name = format("/aws/rds/instance/%s/postgresql", var.rds_name)
  es_domain_endpoint      = try(module.elasticsearch.domain_endpoint, "")
  source_account_id       = data.aws_caller_identity.current.account_id
  lambda_role_arn         = aws_iam_role.lambda-role.arn
}