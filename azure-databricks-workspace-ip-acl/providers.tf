# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "databricks" {
  alias         = "workspace"
  host          = var.databricks_workspace_host
  client_id     = var.databricks_client_id
  client_secret = var.databricks_client_secret
}