

resource "aws_ssm_parameter" "config" {
  for_each    = var.parameters
  name        = format("%s/%s/%s", var.namespace, var.service, each.key)
  type        = lookup(each.value, "type", "String")
  value       = lookup(each.value, "value", "*** NO VALUE SET ***")
  description = lookup(each.value, "description", "*** NO DESCRIPTION SET ***")
  overwrite   = lookup(each.value, "overwrite", false)
  tags        = var.tags
  lifecycle {
    # Never update the value of an existing SSM parameter.
    ignore_changes = [value]
  }
}
