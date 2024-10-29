//private link for data storage (here, catalog external location)
data azurerm_storage_account "data_storage_account" {
  name                = var.data_storage_account
  resource_group_name = var.data_storage_account_rg
}

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

//update data storage account netowrk rules
resource "azurerm_storage_account_network_rules" "allow_ws_subnet" {
  storage_account_id         = data.azurerm_storage_account.data_storage_account.id
  default_action             = "Deny"
  virtual_network_subnet_ids = [for k,v in data.azurerm_subnet.ws_subnets : data.azurerm_subnet.ws_subnets[k].id]
}
