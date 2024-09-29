resource "azurerm_resource_group" "this" {
  name     = var.rg_name
  location = var.azure_region
  tags     = var.tags
}

resource "azurerm_databricks_workspace" "this" {
  name                        = "${var.name_prefix}-workspace"
  resource_group_name         = var.rg_name
  location                    = var.azure_region
  sku                         = "premium"
  managed_resource_group_name = "${var.name_prefix}-mrg"
  custom_parameters {
    storage_account_name = var.dbfs_storage_account
  }
  tags                        = var.tags
  depends_on = [azurerm_resource_group.this]
}

//Get metastore IDs
data "databricks_metastore" "this" {
  provider = databricks.accounts
  name = var.databricks_metastore
}

resource "databricks_metastore_assignment" "this" {
  provider    = databricks.accounts
  metastore_id = data.databricks_metastore.this.id
  workspace_id = azurerm_databricks_workspace.this.workspace_id
  depends_on   = [azurerm_databricks_workspace.this, data.databricks_metastore.this]
}

output "databricks_host" {
  value = "https://${azurerm_databricks_workspace.this.workspace_url}/"
}

