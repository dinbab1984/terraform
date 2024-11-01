# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    databricks = {
      source = "databricks/databricks"
    }
    restapi = {
      source = "pruiz/restapi"
      version = "1.16.2-p2"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
}

provider "databricks" {
  alias         = "accounts"
  host          = var.databricks_host
  account_id    = var.databricks_account_id
  client_id     = var.databricks_client_id
  client_secret = var.databricks_client_secret
}

provider "restapi" {
  # Configuration options
  uri = var.databricks_host
  oauth_client_credentials{
    oauth_client_id      = var.databricks_client_id
    oauth_client_secret  = var.databricks_client_secret
    oauth_token_endpoint = "${var.databricks_host}/oidc/accounts/${var.databricks_account_id}/v1/token"
    oauth_scopes = ["all-apis"]

  }
}
