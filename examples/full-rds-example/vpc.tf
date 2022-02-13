######################################
# Create our playground - VPC
######################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2"

  name = format("vpc-%s-%s", var.environment, local.name)
  cidr = var.vpc_cidr

  azs              = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets   = var.vpc_public_subnets
  private_subnets  = var.vpc_private_subnets
  database_subnets = var.vpc_database_subnets

  create_database_subnet_group = false
  
  enable_dns_hostnames         = true
  enable_dns_support           = true

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
