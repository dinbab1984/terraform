//Get Workspace Id
data "azurerm_databricks_workspace" "this" {
  name                = var.databricks_workspace
  resource_group_name = var.databricks_workspace_rg
}

//transit vnet frontend private link subnet
resource "azurerm_subnet" "transit_fe_pl_subnet" {
  name                                      = "${var.name_prefix}-fe-privatelink_subnet"
  resource_group_name                       = azurerm_resource_group.transit_vnet_rg.name
  virtual_network_name                      = azurerm_virtual_network.transit_vnet.name
  address_prefixes                          = [var.transit_pl_subnets_cidr]
  depends_on = [azurerm_virtual_network.transit_vnet]
}

//private dsn zone
resource "azurerm_private_dns_zone" "dns_zone_fe" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = azurerm_resource_group.transit_vnet_rg.name
  tags                = var.tags
  depends_on = [ azurerm_resource_group.transit_vnet_rg ]
}

//private dsn zone and vnet link
resource "azurerm_private_dns_zone_virtual_network_link" "fe_uiapi_dns_zone_vnet_link" {
  name                  = "dnszonefevnetconnection"
  resource_group_name   = azurerm_resource_group.transit_vnet_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_fe.name
  virtual_network_id    = azurerm_virtual_network.transit_vnet.id
  tags                  = var.tags
  depends_on = [azurerm_private_dns_zone.dns_zone_fe, azurerm_virtual_network.transit_vnet]
}

//private end point (frontend) - workspace to db web ui and db rest api
resource "azurerm_private_endpoint" "uiapi" {
  name                = "feuiapipvtendpoint"
  location            = azurerm_resource_group.transit_vnet_rg.location
  resource_group_name = azurerm_resource_group.transit_vnet_rg.name
  subnet_id           = azurerm_subnet.transit_fe_pl_subnet.id
  tags                = var.tags
  private_service_connection {
    name                           = "ple-fe-${var.name_prefix}-uiapi"
    private_connection_resource_id = data.azurerm_databricks_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["databricks_ui_api"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-fe-uiapi"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_zone_fe.id]
  }
  depends_on = [azurerm_subnet.transit_fe_pl_subnet, data.azurerm_databricks_workspace.this, azurerm_private_dns_zone.dns_zone_fe]
}
