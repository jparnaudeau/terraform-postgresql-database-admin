########################################
# Retrieve infos on Network
########################################
locals {
  vpc_name = format("vpc-%s-%s", var.environment, var.vpc_label)
  tags     = merge(var.tags, { "environment" = var.environment })
}

module "networkdata" {
  source      = "./networkdata"
  environment = var.environment
  region      = var.region
  # set infos to retrieve resources
  vpc_name = local.vpc_name
  public_subnet_names = [
    format("%s-%s-%sa", local.vpc_name, "public", var.region),
    format("%s-%s-%sb", local.vpc_name, "public", var.region),
    format("%s-%s-%sc", local.vpc_name, "public", var.region)
  ]
  private_subnet_names = [
    format("%s-%s-%sa", local.vpc_name, "private", var.region),
    format("%s-%s-%sb", local.vpc_name, "private", var.region),
    format("%s-%s-%sc", local.vpc_name, "private", var.region)
  ]
  database_subnet_names = [
    format("%s-%s-%sa", local.vpc_name, "db", var.region),
    format("%s-%s-%sb", local.vpc_name, "db", var.region),
    format("%s-%s-%sc", local.vpc_name, "db", var.region)
  ]
  resources = {
    "database" = var.vpc_label
  }
}

