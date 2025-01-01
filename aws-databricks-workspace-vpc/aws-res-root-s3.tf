// root storage S3 bucket
resource "aws_s3_bucket" "root_storage_bucket" {
  bucket        = "${var.name_prefix}-root-bucket"
  force_destroy = true
  tags          = var.tags
}

// root storage S3 bucket server side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "root_storage_bucket" {
  bucket = aws_s3_bucket.root_storage_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
  depends_on = [aws_s3_bucket.root_storage_bucket]
}

// root storage S3 bucket block public access
resource "aws_s3_bucket_public_access_block" "root_storage_bucket" {
  bucket                  = aws_s3_bucket.root_storage_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.root_storage_bucket]
}

//databricks bucket policy generate
data "databricks_aws_bucket_policy" "this" {
  bucket = aws_s3_bucket.root_storage_bucket.bucket
  depends_on = [aws_s3_bucket.root_storage_bucket]
}

//add bucket policy to root storage bucket
resource "aws_s3_bucket_policy" "root_bucket_policy" {
  bucket     = aws_s3_bucket.root_storage_bucket.id
  policy     = data.databricks_aws_bucket_policy.this.json
  depends_on = [aws_s3_bucket.root_storage_bucket, data.databricks_aws_bucket_policy.this]
}

//disable verisioning on root storage bucket
resource "aws_s3_bucket_versioning" "root_bucket_versioning" {
  bucket = aws_s3_bucket.root_storage_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
  depends_on = [aws_s3_bucket.root_storage_bucket]
}
