terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "databricks" {
  alias         = "accounts"
  host          = var.databricks_host
  account_id    = var.databricks_account_id
  client_id     = var.client_id
  client_secret = var.client_secret
}