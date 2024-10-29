data "azurerm_virtual_network" "ws_vnet" {
  name                = var.databricks_workspace_vnet
  resource_group_name = var.databricks_workspace_vnet_rg
}

//vnet private link subnet
resource "azurerm_subnet" "plsubnet" {
  name                                      = "${var.name_prefix}-privatelink"
  resource_group_name                       = var.databricks_workspace_vnet_rg
  virtual_network_name                      = data.azurerm_virtual_network.ws_vnet.name
  address_prefixes                          = [var.pl_subnets_cidr]
  depends_on = [data.azurerm_virtual_network.ws_vnet]
}