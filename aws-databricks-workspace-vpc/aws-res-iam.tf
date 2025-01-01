//databricks config for assume role with customer databricks account
data "databricks_aws_assume_role_policy" "this" {
  provider    = databricks.mws
  external_id = var.databricks_account_id
}

//create cross account role with databricks aws account
resource "aws_iam_role" "cross_account_role" {
  name               = "${var.name_prefix}-cross-account-role" //
  assume_role_policy = data.databricks_aws_assume_role_policy.this.json
  depends_on = [data.databricks_aws_assume_role_policy.this]
  tags = var.tags
}

data "databricks_aws_crossaccount_policy" "this" {
  provider = databricks.mws
  policy_type = "customer"
}

// policy to allows cluster creation
resource "aws_iam_role_policy" "this" {
  name   = "${var.name_prefix}-cross-account-policy" //var.name_prefix
  role   = aws_iam_role.cross_account_role.id
  policy = data.databricks_aws_crossaccount_policy.this.json
  depends_on = [aws_iam_role.cross_account_role, data.databricks_aws_crossaccount_policy.this]
}


