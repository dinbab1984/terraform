terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}


provider "databricks" {
  alias         = "accounts-data-provider"
  host          = var.provider_databricks_host
  account_id    = var.provider_databricks_account_id
  client_id     = var.provider_databricks_client_id
  client_secret = var.provider_databricks_client_secret
}

provider "databricks" {
  alias         = "accounts-data-recipient"
  host          = var.recipient_databricks_host
  account_id    = var.recipient_databricks_account_id
  client_id     = var.recipient_databricks_client_id
  client_secret = var.recipient_databricks_client_secret
}

provider "databricks" {
  alias         = "workspace-data-provider"
  host          = var.provider_databricks_workspace_host
  client_id     = var.provider_databricks_client_id
  client_secret = var.provider_databricks_client_secret
}

provider "databricks" {
  alias         = "workspace-data-recipient"
  host          = var.recipient_databricks_workspace_host
  client_id     = var.recipient_databricks_client_id
  client_secret = var.recipient_databricks_client_secret
}