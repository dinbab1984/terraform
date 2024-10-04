//credentials configurations
resource "databricks_mws_credentials" "this" {
  provider         = databricks.mws
  role_arn         = aws_iam_role.cross_account_role.arn
  credentials_name = "${var.name_prefix}-credentials"
  external_id      =  var.databricks_account_id
  depends_on       = [aws_iam_role.cross_account_role]
}

//storage configurations
resource "databricks_mws_storage_configurations" "this" {
  provider                   = databricks.mws
  account_id                 = var.databricks_account_id
  bucket_name                = aws_s3_bucket.root_storage_bucket.bucket
  storage_configuration_name = "${var.name_prefix}-storage-configuration"
  depends_on                 = [aws_s3_bucket.root_storage_bucket]
}

//network configuration
resource "databricks_mws_networks" "this" {
  provider           = databricks.mws
  account_id         = var.databricks_account_id
  network_name       = "${var.name_prefix}-network-configuration"
  security_group_ids = [module.vpc.default_security_group_id]
  subnet_ids         = module.vpc.private_subnets
  vpc_id             = module.vpc.vpc_id
}