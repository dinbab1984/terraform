//Get Workspace Id
data "azurerm_databricks_workspace" "this" {
  name                = var.databricks_workspace
  resource_group_name = var.rg_name
}

resource "databricks_mws_network_connectivity_config" "ncc" {
  provider = databricks.accounts
  name     = "ncc-for-${var.databricks_workspace}"
  region   = var.azure_region
}

resource "databricks_mws_ncc_binding" "ncc_binding" {
  provider                       = databricks.accounts
  network_connectivity_config_id = databricks_mws_network_connectivity_config.ncc.network_connectivity_config_id
  workspace_id                   = data.azurerm_databricks_workspace.this.workspace_id
}

data "azurerm_storage_account" "catalog_sa" {
  name                = var.adls_sa_name
  resource_group_name = var.adls_sa_rg
}

resource "databricks_mws_ncc_private_endpoint_rule" "storage" {
  provider                       = databricks.accounts
  network_connectivity_config_id = databricks_mws_network_connectivity_config.ncc.network_connectivity_config_id
  resource_id                    = data.azurerm_storage_account.catalog_sa.id
  group_id                       = "dfs"
}