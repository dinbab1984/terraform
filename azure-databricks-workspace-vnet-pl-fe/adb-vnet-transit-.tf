//resource group for hub/transit vnet
resource "azurerm_resource_group" "transit_vnet_rg" {
  name     = var.transit_vnet_rg
  location = var.azure_region
  tags     = var.tags
}

//create hub/transit vnet for firewall
resource "azurerm_virtual_network" "transit_vnet" {
  name                = "${var.name_prefix}-vnet-transit"
  location            = azurerm_resource_group.transit_vnet_rg.location
  resource_group_name = azurerm_resource_group.transit_vnet_rg.name
  address_space       = [var.transit_cidr_block]
  tags                = var.tags
  depends_on = [azurerm_resource_group.transit_vnet_rg]
}

