//private dsn zone
resource "azurerm_private_dns_zone" "dnsuiapi" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = var.rg_name
}

//private dsn zone and vnet net link
resource "azurerm_private_dns_zone_virtual_network_link" "uiapidnszonevnetlink" {
  name                  = "uiapivnetconnection"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.dnsuiapi.name
  virtual_network_id    = azurerm_virtual_network.this.id // connect to spoke vnet
}

//private end point - workspace to db web ui and db rest api
resource "azurerm_private_endpoint" "uiapi" {
  name                = "uiapipvtendpoint"
  location            = var.azure_region
  resource_group_name = var.rg_name
  subnet_id           = azurerm_subnet.plsubnet.id

  private_service_connection {
    name                           = "ple-${var.name_prefix}-uiapi"
    private_connection_resource_id = azurerm_databricks_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["databricks_ui_api"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-uiapi"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsuiapi.id]
  }
}
