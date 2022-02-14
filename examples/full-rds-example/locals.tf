##################################################################
# Define locals
##################################################################
locals {
  name                 = var.rds_name
  subnet_grp_name      = format("subnetsgrp-%s", local.name)
  tags                 = merge(var.tags, { "environment" = var.environment })
  namespace            = format("/%s/%s", var.environment, var.inputs["db_name"])
  lambda_function_name = format("streamLogsToEsFor-%s", var.rds_name)
}
