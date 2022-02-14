##########################################
# Outputs for VPC
##########################################
output "vpc_infos" {
  description = "map of vpc informations"
  value = {
    vpc_id           = module.vpc.vpc_id,
    vpc_name         = module.vpc.name,
    public_subnets   = module.vpc.public_subnets,
    private_subnets  = module.vpc.private_subnets,
    database_subnets = module.vpc.database_subnets
  }
}

################################################
#  Outputs for RDS
################################################
output "rds_infos" {
  description = "map of rds informations"
  value = {
    db_instance_address  = module.rds.db_instance_address,
    db_instance_arn      = module.rds.db_instance_arn,
    db_instance_endpoint = module.rds.db_instance_endpoint,
    db_instance_id       = module.rds.db_instance_id,
    db_instance_name     = module.rds.db_instance_name,
    "connect_command"    = format("psql -h %s -p %s -U %s -d %s -W", module.rds.db_instance_address, var.dbport, var.rds_superuser_name, var.inputs["db_name"])
  }
}

output "affected_schema" {
  description = "the name of the schema in which the db objects have been created by the module"
  value       = var.inputs["db_schema_name"]
}

output "created_roles" {
  description = "The list of roles created by the module"
  value       = [for obj_role in var.inputs["db_roles"] : obj_role["role"]]
}

output "db_users" {
  description = "The list of users created by the module"
  value = { for user in var.inputs["db_users"] :
    user.name => {
      "secret_name"     = join(",", keys(module.secrets-manager[user.name].secret_arns)),
      "secret_arn"      = join(",", values(module.secrets-manager[user.name].secret_arns)),
      "connect_command" = format("psql -h %s -p %s -U %s -d %s -W", module.rds.db_instance_address, var.dbport, user.name, var.inputs["db_name"])
    }
  }
}

################################################
#  Outputs for elasticSearch
################################################
output "domain_arn" {
  description = "The ElasticSearch Domain ARN"
  value       = try(module.elasticsearch.domain_arn, "")
}

output "domain_endpoint" {
  description = "The ElasticSearch Domain Endpoint"
  value       = try(module.elasticsearch.domain_endpoint, "")
}
output "domain_hostname" {
  description = "The ElasticSearch Domain Hostname"
  value       = try(module.elasticsearch.domain_hostname, "")
}
output "domain_id" {
  description = "The ElasticSearch Domain Id"
  value       = try(module.elasticsearch.domain_id, "")
}
output "domain_name" {
  description = "The ElasticSearch Domain Name"
  value       = try(module.elasticsearch.domain_name, "")
}
output "elasticsearch_user_iam_role_arn" {
  description = "The ElasticSearch User IAM Role ARN"
  value       = try(module.elasticsearch.elasticsearch_user_iam_role_arn, "")
}
output "elasticsearch_user_iam_role_name" {
  description = "The ElasticSearch User IAM Role Name"
  value       = try(module.elasticsearch.elasticsearch_user_iam_role_name, "")
}
output "kibana_endpoint" {
  description = "The ElasticSearch Kibana Endpoint"
  value       = try(module.elasticsearch.kibana_endpoint, "")
}

################################################
#  Outputs for streaming lambda
################################################
output "streaming_lambda_arn" {
  description = "The Lambda ARN responsible of streaming RDS Logs to ElasticSearch"
  value       = try(module.stream2es["1"].lambda_function_arn, "Not Deploy")
}

output "streamed_cloudwatch_log_arn" {
  description = "The CloudWatch Log ARN being streamed by the lambda"
  value       = try(module.stream2es["1"].streamed_cloudwatch_log_arn, "Not Deploy")
}

output "streaming_lambda_role_arn" {
  description = "The Role ARN of the streaming lambda"
  value       = aws_iam_role.lambda-role.arn
}
