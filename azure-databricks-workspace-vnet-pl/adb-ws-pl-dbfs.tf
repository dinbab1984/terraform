//private dsn zone for dbfs
resource "azurerm_private_dns_zone" "dnsdbfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = var.databricks_workspace_vnet_rg
  tags                = var.tags
}

//private dsn zone for dbfs-blob
resource "azurerm_private_dns_zone" "dnsdbfsblob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.databricks_workspace_vnet_rg
  tags                = var.tags
}

//private dsn zone and vnet net link
resource "azurerm_private_dns_zone_virtual_network_link" "dbfsdnszonevnetlink" {
  name                  = "dbfsvnetconnection"
  resource_group_name   = var.databricks_workspace_vnet_rg
  private_dns_zone_name = azurerm_private_dns_zone.dnsdbfs.name
  virtual_network_id    = data.azurerm_virtual_network.ws_vnet.id // connect to spoke vnet
  tags                  = var.tags
  depends_on = [azurerm_private_dns_zone.dnsdbfs, data.azurerm_virtual_network.ws_vnet]
}

//private dsn zone (blob) and vnet net link
resource "azurerm_private_dns_zone_virtual_network_link" "dbfsblobdnszonevnetlink" {
  name                  = "dbfsblobvnetconnection"
  resource_group_name   = var.databricks_workspace_vnet_rg
  private_dns_zone_name = azurerm_private_dns_zone.dnsdbfsblob.name
  virtual_network_id    = data.azurerm_virtual_network.ws_vnet.id // connect to spoke vnet
  tags                  = var.tags
  depends_on = [azurerm_private_dns_zone.dnsdbfsblob, data.azurerm_virtual_network.ws_vnet]
}

//private link for root storage
data azurerm_storage_account "dbfs_storage_account" {
  name = var.dbfs_storage_account
  resource_group_name = var.dbfs_storage_account_rg
  depends_on = [data.azurerm_databricks_workspace.this]
}

//private end point - workspace to storage account(dbfs)
resource "azurerm_private_endpoint" "dbfs" {
  name                = "dbfspvtendpoint"
  location            = var.azure_region
  resource_group_name = var.databricks_workspace_vnet_rg
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

//private end point - workspace to storage account(dbfs-blob)
resource "azurerm_private_endpoint" "dbfsblob" {
  name                = "dbfspvtendpointblob"
  location            = var.azure_region
  resource_group_name = var.databricks_workspace_vnet_rg
  subnet_id           = azurerm_subnet.plsubnet.id
  tags                = var.tags
  private_service_connection {
    name                           = "ple-${var.name_prefix}-dbfs-blob"
    private_connection_resource_id = data.azurerm_storage_account.dbfs_storage_account.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-dbfs-blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdbfsblob.id]
  }
  depends_on = [azurerm_subnet.plsubnet, azurerm_private_dns_zone.dnsdbfsblob]
}

//private link for data storage (here, catalog external location)
data azurerm_storage_account "data_storage_account" {
  name = var.data_storage_account
  resource_group_name = var.data_storage_account_rg
}

//private end point - workspace to data storage (here, catalog external location)
resource "azurerm_private_endpoint" "data" {
  name                = "datapvtendpoint"
  location            = var.azure_region
  resource_group_name = var.databricks_workspace_vnet_rg
  subnet_id           = azurerm_subnet.plsubnet.id
  tags                = var.tags
  private_service_connection {
    name                           = "ple-${var.name_prefix}-data"
    private_connection_resource_id = data.azurerm_storage_account.data_storage_account.id
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-dbfs"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdbfs.id]
  }
  depends_on = [azurerm_subnet.plsubnet, azurerm_private_dns_zone.dnsdbfs]
}

//update data storage account netowrk rules
/*resource "azurerm_storage_account_network_rules" "allow_ws_subnet" {
  storage_account_id         = data.azurerm_storage_account.data_storage_account.id
  default_action             = "Deny"
}
*/

