resource "azurerm_route_table" "adbroute" {
  //route all traffic from spoke vnet to hub vnet
  name                = "spoke-routetable"
  location            = azurerm_resource_group.hubrg.location
  resource_group_name = azurerm_resource_group.hubrg.name

  route {
    name                   = "to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.hubfw.ip_configuration.0.private_ip_address // extract single item
  }
  route {
    name                   = "to-artefact"
    address_prefix         = var.storage_servicetag
    next_hop_type          = "Internet"
  }
  depends_on = [ azurerm_resource_group.hubrg, azurerm_firewall.hubfw ]
}

resource "azurerm_subnet_route_table_association" "vnetsubnetudr" {
  for_each       = toset(data.azurerm_virtual_network.ws_vnet.subnets)
  subnet_id      = data.azurerm_subnet.ws_subnets[each.value].id
  route_table_id = azurerm_route_table.adbroute.id
  depends_on     = [ azurerm_route_table.adbroute, data.azurerm_subnet.ws_subnets]
}

