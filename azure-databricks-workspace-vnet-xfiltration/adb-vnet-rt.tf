//get ip adddresses
locals {
  artefactstoreips = toset(flatten([for k, v in data.dns_a_record_set.artefact_store : v.addrs]))
  metastoreips = toset(flatten([for k, v in data.dns_a_record_set.metastore : v.addrs]))
}

//get ip adddresses of artefactstorefqdns
data "dns_a_record_set" "artefact_store" {
  for_each = toset(var.artefactstorefqdns)
  host     = each.value
}

//get ip adddresses of legacy metatorefqdns
data "dns_a_record_set" "metastore" {
  for_each = toset(var.metastorefqdns)
  host     = each.value
}

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
  
  /*route {
    name                   = "to-artefact"
    address_prefix         = var.storage_servicetag
    next_hop_type          = "Internet"
  }
  */
  dynamic "route" {
    for_each = local.artefactstoreips
    content {
      name           = "to-artefact-${route.value}"
      address_prefix = "${route.value}/32"
      next_hop_type  = "Internet" // since Artefact Store is azure service IP, traffic will remain in azure backbone, not Internet
    }
  }
  dynamic "route" {
    for_each = local.metastoreips
    content {
      name           = "to-metastore-${route.value}"
      address_prefix = "${route.value}/32"
      next_hop_type  = "Internet" // since Metastore Store is azure service IP, traffic will remain in azure backbone, not Internet
    }
  }

  depends_on = [ azurerm_resource_group.hubrg, azurerm_firewall.hubfw, data.dns_a_record_set.artefact_store , data.dns_a_record_set.metastore]
}

resource "azurerm_subnet_route_table_association" "vnetsubnetudr" {
  for_each       = toset(data.azurerm_virtual_network.ws_vnet.subnets)
  subnet_id      = data.azurerm_subnet.ws_subnets[each.value].id
  route_table_id = azurerm_route_table.adbroute.id
  depends_on     = [ azurerm_route_table.adbroute, data.azurerm_subnet.ws_subnets]
}

