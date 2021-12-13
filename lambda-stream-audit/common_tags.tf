locals {
  common_tags = {
    Environment = var.environment
    Owner       = var.owner
    Application = var.product_name
    CostCenter  = var.costcenter
  }
}
