resource "azurerm_resource_group" "this" {
  name     =  var.rg_name
  location = var.azure_region
  tags     = local.tags
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
  tags                        = local.tags
  depends_on = [azurerm_resource_group.this]
}

output "databricks_host" {
  value = "https://${azurerm_databricks_workspace.this.workspace_url}/"
}