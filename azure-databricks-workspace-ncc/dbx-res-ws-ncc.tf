//Get Workspace Id
data "azurerm_databricks_workspace" "this" {
  name                = var.databricks_workspace
  resource_group_name = var.databricks_workspace_rg
}

resource "databricks_mws_network_connectivity_config" "ncc" {
  provider = databricks.accounts
  name     = "ncc-${var.databricks_workspace}"
  region   = var.azure_region
}

resource "databricks_mws_ncc_binding" "ncc_binding" {
  provider                       = databricks.accounts
  network_connectivity_config_id = databricks_mws_network_connectivity_config.ncc.network_connectivity_config_id
  workspace_id                   = data.azurerm_databricks_workspace.this.workspace_id
  depends_on = [databricks_mws_network_connectivity_config.ncc]
  
}

data "azurerm_storage_account" "catalog_sa" {
  name                = var.data_storage_account
  resource_group_name = var.data_storage_account_rg
}

output "subnets" {
  value = databricks_mws_network_connectivity_config.ncc.egress_config[0].default_rules[0].azure_service_endpoint_rule[0].subnets
}

//update data storage account netowrk rules
resource "azurerm_storage_account_network_rules" "allow_ws_subnet" {
  storage_account_id         = data.azurerm_storage_account.catalog_sa.id
  default_action             = "Deny"
  virtual_network_subnet_ids = databricks_mws_network_connectivity_config.ncc.egress_config[0].default_rules[0].azure_service_endpoint_rule[0].subnets
}

/*
resource "databricks_mws_ncc_private_endpoint_rule" "storage" {
  provider                       = databricks.accounts
  network_connectivity_config_id = databricks_mws_network_connectivity_config.ncc.network_connectivity_config_id
  resource_id                    = data.azurerm_storage_account.catalog_sa.id
  group_id                       = "dfs"
  depends_on = [databricks_mws_network_connectivity_config.ncc]
}
*/