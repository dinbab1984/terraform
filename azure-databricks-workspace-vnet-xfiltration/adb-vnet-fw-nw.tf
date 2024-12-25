//resource group for hub/transit vnet for firewall
resource "azurerm_resource_group" "hubrg" {
  name     = var.hub_rg_name
  location = var.azure_region
  tags     = var.tags
}

//create hub/transit vnet for firewall
resource "azurerm_virtual_network" "hubvnet" {
  name                = "${var.name_prefix}-vnet-fw"
  location            = azurerm_resource_group.hubrg.location
  resource_group_name = azurerm_resource_group.hubrg.name
  address_space       = [var.hub_cidr_block]
  tags                = var.tags
  depends_on = [azurerm_resource_group.hubrg]
}

//create hub/transit subnet for firewall
resource "azurerm_subnet" "hubfw" {
  //name must be fixed as AzureFirewallSubnet
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hubrg.name
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  address_prefixes     = [var.fw_subnets_cidr]
  //service_endpoints    = ["Microsoft.Storage"]
  depends_on = [ azurerm_virtual_network_peering.hubvnet ]
}

//Get workspace vnet aka spoke vnet
data "azurerm_virtual_network" "ws_vnet" {
  name                = var.databricks_workspace_vnet
  resource_group_name = var.databricks_workspace_vnet_rg
}

//Get Subnets of spoke vnet
data "azurerm_subnet" "ws_subnets" {
  for_each             = toset(data.azurerm_virtual_network.ws_vnet.subnets)
  name                 = each.value
  virtual_network_name = var.databricks_workspace_vnet
  resource_group_name  = var.databricks_workspace_vnet_rg
}

output "name" {
  value = [for k,v in data.azurerm_subnet.ws_subnets : data.azurerm_subnet.ws_subnets[k].address_prefixes[0] ]
}

//vnet peering (hub to spoke)
resource "azurerm_virtual_network_peering" "hubvnet" {
  name                      = "peerhubtospoke"
  resource_group_name       = azurerm_resource_group.hubrg.name
  virtual_network_name      = azurerm_virtual_network.hubvnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.ws_vnet.id
  depends_on = [ azurerm_virtual_network.hubvnet, data.azurerm_virtual_network.ws_vnet ]
}

//vnet peering (spoke to hub)
resource "azurerm_virtual_network_peering" "spokevnet" {
  name                      = "peerspoketohub"
  resource_group_name       = var.databricks_workspace_vnet_rg
  virtual_network_name      = data.azurerm_virtual_network.ws_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hubvnet.id
  depends_on = [ azurerm_virtual_network.hubvnet, data.azurerm_virtual_network.ws_vnet ]
}

