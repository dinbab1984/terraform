/*
//storage account secure connection 
data "azurerm_storage_account" "data_storage_account" {
  name                = azurerm_storage_account.this.name
  resource_group_name = azurerm_storage_account.this.resource_group_name
}
*/
//Classsic Compute - VNET
data "azurerm_virtual_network" "ws_vnet" {
  name                = var.databricks_workspace_vnet
  resource_group_name = var.databricks_workspace_vnet_rg
}


data "azurerm_subnet" "ws_subnets" {
  for_each             = toset(data.azurerm_virtual_network.ws_vnet.subnets)
  name                 = each.value
  virtual_network_name = var.databricks_workspace_vnet
  resource_group_name  = var.databricks_workspace_vnet_rg
}

data "restapi_object" "subnets" {
  path = "/api/2.0/accounts/${var.databricks_account_id}/network-connectivity-configs"
  search_key = "name"
  search_value = var.workspace_ncc_name
  id_attribute ="network_connectivity_config_id"
  results_key = "items"
}

//output "subnets" {
//  value = toset(jsondecode(data.restapi_object.subnets.api_response).egress_config.default_rules.azure_service_endpoint_rule.subnets)
//}
//update data storage account netowrk rules
/*
resource "azurerm_storage_account_network_rules" "allow_vent_ncc_subnet" {
  storage_account_id         = data.azurerm_storage_account.data_storage_account.id
  default_action             = "Deny"
  virtual_network_subnet_ids = concat([for k,v in data.azurerm_subnet.ws_subnets : data.azurerm_subnet.ws_subnets[k].id] , (jsondecode(data.restapi_object.subnets.api_response).egress_config.default_rules.azure_service_endpoint_rule.subnets))
  depends_on = [ data.azurerm_storage_account.data_storage_account, data.azurerm_subnet.ws_subnets, data.restapi_object.subnets ]
}
*/
/*
resource "databricks_mws_ncc_private_endpoint_rule" "storage" {
  provider                       = databricks.accounts
  network_connectivity_config_id = databricks_mws_network_connectivity_config.ncc.network_connectivity_config_id
  resource_id                    = data.azurerm_storage_account.catalog_sa.id
  group_id                       = "dfs"
  depends_on = [databricks_mws_network_connectivity_config.ncc]
}
*/
