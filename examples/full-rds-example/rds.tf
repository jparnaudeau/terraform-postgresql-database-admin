##################################################################
# Define locals
##################################################################
locals {
  name            = var.rds_name
  subnet_grp_name = format("subnetsgrp-%s", local.name)
  tags            = merge(var.tags, { "environment" = var.environment })
}

######################################
# Create our playground - VPC
######################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2"

  name = format("vpc-%s-%s", var.environment, local.name)
  cidr = "10.99.0.0/18"

  azs              = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets   = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  private_subnets  = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
  database_subnets = ["10.99.7.0/24", "10.99.8.0/24", "10.99.9.0/24"]

  create_database_subnet_group = false
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}


######################################
# Deploy Security Group for our RDS Instance
# allow access from personal IP Address
######################################
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = "${local.name}-postgresql"
  description = "PostgreSQL RDS security group"
  vpc_id      = module.vpc.vpc_id

  tags = local.tags
}

resource "aws_security_group_rule" "allowed_ip_on_rds" {
  description       = "Expose Postgresql Listener to Allowed IP Addresses"
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "TCP"
  cidr_blocks       = var.allowed_ip_addresses
  security_group_id = module.security_group.security_group_id
}

resource "aws_security_group_rule" "rds_outbound" {
  description       = "Outbound access for ${local.name}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.security_group.security_group_id
}

######################################
# Deploy RDS Instance
######################################
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "3.5.0"

  identifier = local.name

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = var.rds_engine_version
  family               = var.rds_family
  major_engine_version = var.rds_major_engine_version
  instance_class       = var.rds_instance_class

  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage
  storage_encrypted     = var.rds_storage_encrypted

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  name     = var.inputs["db_name"]
  username = var.rds_superuser_name
  password = var.rds_root_password # password is setted inside environment variable TF_VAR_rds_root_password
  port     = 5432

  multi_az               = true

  # because we want reach the database from our local workstation, we need to deploy our RDS in the public subnets
  # DO NOT DO THAT IN PRODUCTION
  # to reduce the attack surface, limit the access of the RDS Instance to our personal IP addresses
  publicly_accessible    = true
  subnet_ids             = module.vpc.public_subnets
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false # for test purpose !!

  create_db_parameter_group = false
  parameter_group_name      = aws_db_parameter_group.postgres.id

  create_db_option_group = false

  create_db_subnet_group = false
  db_subnet_group_name   = aws_db_subnet_group.main_db_subnet_group.id

  tags = local.tags
}

resource "random_id" "val" {
  byte_length = 4
}

resource "aws_db_parameter_group" "postgres" {
  name        = format("param-%s-%s", local.name, random_id.val.hex)
  description = "Parameter group for our postgresql rds instance"
  family      = var.rds_family

  dynamic "parameter" {
    for_each = var.parameter_group_params
    content {
      name  = parameter.key
      value = parameter.value
    }
  }
  dynamic "parameter" {
    for_each = var.extensions_parameter_group_params
    content {
      name         = parameter.key
      value        = parameter.value
      apply_method = "pending-reboot"
    }
  }

  tags = local.tags
}


resource "aws_db_subnet_group" "main_db_subnet_group" {
  name        = local.subnet_grp_name
  description = format("%s db subnet group", local.name)
  subnet_ids  = module.vpc.public_subnets

  tags = local.tags
}
