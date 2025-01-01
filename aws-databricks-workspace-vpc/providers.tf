terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.46.0"
    }
    databricks = {
      source = "databricks/databricks"
      version = "1.51.0"
    }
  }
}

// aws provider configurations
provider "aws" {
  shared_credentials_files = var.aws_credentials_file
  profile = var.aws_profile
  region = var.aws_region
}

//databricks provider - mutliple workspace provisioning config
provider "databricks" {
  alias         = "mws"
  host          = var.databricks_host
  account_id    = var.databricks_account_id
  client_id     = var.databricks_client_id
  client_secret = var.databricks_client_secret
}