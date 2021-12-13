
# AWS Iam Policy 
resource "aws_iam_policy" "lambda_rds_logging_policy" {
  name        = format("policy-%s-%s-%s", var.environment, var.product_name, var.short_description)
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.rds_audit.json
}


# IAM Policy Document
data "aws_iam_policy_document" "rds_audit" {


  statement {
    actions = [
      "rds:DownloadDBLogFilePortion",
      "rds:DescribeDBLogFiles",
      "rds:DownloadCompleteDBLogFile"
    ]
    resources = [
      for instance in var.rds_instances_list :
      "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:db:${instance}"

    ]
  }

  statement {
    actions = [
      "lambda:GetFunction",
      "lambda:InvokeFunction"
    ]

    resources = [
      "*",
    ]
  }
}
