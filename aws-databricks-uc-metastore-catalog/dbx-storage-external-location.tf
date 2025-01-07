
data "aws_caller_identity" "current" {}

locals {
  uc_iam_role = "${var.name_prefix}-uc-access"
}

//Get metastore IDs
data "databricks_metastore" "this" {
  provider = databricks.accounts
  name = var.databricks_metastore
}


resource "databricks_storage_credential" "catalog_storage_credential" {
  provider        = databricks.workspace
  name            = "${var.name_prefix}-storage-credential"
  metastore_id    = data.databricks_metastore.this.metastore_id
  isolation_mode  = "ISOLATION_MODE_ISOLATED"
  force_destroy   = true
  //cannot reference aws_iam_role directly, as it will create circular dependency
  aws_iam_role {
    role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.uc_iam_role}"
  }
  comment   = "Managed by TF"
}

// UC catalog storage bucket
resource "aws_s3_bucket" "catalog_storage_bucket" {
  bucket        = "${var.name_prefix}-catalog-bucket"
  force_destroy = true
}

// catalog storage S3 bucket server side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "catalog_storage_bucket" {
  bucket = aws_s3_bucket.catalog_storage_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
  depends_on = [aws_s3_bucket.catalog_storage_bucket]
}

//disable verisioning on metastore storage bucket
resource "aws_s3_bucket_versioning" "catalog_bucket_versioning" {
  bucket = aws_s3_bucket.catalog_storage_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
  depends_on = [aws_s3_bucket.catalog_storage_bucket]
}

//role policy
data "databricks_aws_unity_catalog_assume_role_policy" "this" {
  aws_account_id = data.aws_caller_identity.current.account_id
  role_name      = local.uc_iam_role
  external_id    = var.databricks_account_id
  depends_on     = [data.aws_caller_identity.current]
}

data "databricks_aws_unity_catalog_policy" "this" {
  aws_account_id = data.aws_caller_identity.current.account_id
  bucket_name    = aws_s3_bucket.catalog_storage_bucket.id
  role_name      = local.uc_iam_role
  depends_on     = [aws_s3_bucket.catalog_storage_bucket]
}

resource "aws_iam_policy" "catalog_iam_policy" {
  name   = "${var.name_prefix}-catalog-iam-policy"
  policy = data.databricks_aws_unity_catalog_policy.this.json
  tags   = var.tags
}

resource "aws_iam_role" "catalog_iam_role" {
  name                = local.uc_iam_role
  assume_role_policy  = data.databricks_aws_unity_catalog_assume_role_policy.this.json
  managed_policy_arns = [aws_iam_policy.catalog_iam_policy.arn]
  tags                = var.tags
  depends_on          = [data.databricks_aws_unity_catalog_assume_role_policy.this, aws_iam_policy.catalog_iam_policy]
}


//credentials configurations
resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"
  depends_on = [aws_iam_role.catalog_iam_role, aws_iam_policy.catalog_iam_policy]
}

//Add External location
resource "databricks_external_location" "catalog_external_location" {
  provider        = databricks.workspace
  metastore_id    = data.databricks_metastore.this.metastore_id
  isolation_mode  = "ISOLATION_MODE_ISOLATED"
  name            = "${var.name_prefix}-external-location"
  url             = "s3://${aws_s3_bucket.catalog_storage_bucket.id}/"
  credential_name = databricks_storage_credential.catalog_storage_credential.name
  force_destroy   = true
  comment         = "Managed by TF"
  depends_on      = [time_sleep.wait_30_seconds, aws_s3_bucket.catalog_storage_bucket,databricks_storage_credential.catalog_storage_credential,aws_iam_role.catalog_iam_role, aws_iam_policy.catalog_iam_policy]
}

//provide access to external location to workspace admins
resource "databricks_grants" "principal_browse_access" {
  provider          = databricks.workspace
  external_location = databricks_external_location.catalog_external_location.id
  grant {
    principal  = var.principal_name
    privileges = ["BROWSE"]
  }
  depends_on = [databricks_external_location.catalog_external_location]
}





