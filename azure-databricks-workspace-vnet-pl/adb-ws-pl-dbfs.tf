//private dsn zone for dbfs
resource "azurerm_private_dns_zone" "dnsdbfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = var.rg_name
  depends_on          = [azurerm_resource_group.this]
  tags                = var.tags
}

//private dsn zone and vnet net link
resource "azurerm_private_dns_zone_virtual_network_link" "dbfsdnszonevnetlink" {
  name                  = "dbfsvnetconnection"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.dnsdbfs.name
  virtual_network_id    = azurerm_virtual_network.this.id // connect to spoke vnet
  tags                  = var.tags
  depends_on = [azurerm_private_dns_zone.dnsdbfs, azurerm_virtual_network.this]
}

data azurerm_storage_account "dbfs_storage_account" {
  name = var.dbfs_storage_account
  resource_group_name = "${var.name_prefix}-mrg"
  depends_on = [azurerm_databricks_workspace.this]
}

//private end point - workspace to storage account(dbfs)
resource "azurerm_private_endpoint" "dbfs" {
  name                = "dbfspvtendpoint"
  location            = var.azure_region
  resource_group_name = var.rg_name
  subnet_id           = azurerm_subnet.plsubnet.id
  tags                = var.tags
  private_service_connection {
    name                           = "ple-${var.name_prefix}-dbfs"
    private_connection_resource_id = data.azurerm_storage_account.dbfs_storage_account.id
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-dbfs"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdbfs.id]
  }
  depends_on = [azurerm_subnet.plsubnet, azurerm_private_dns_zone.dnsdbfs]
}
