resource "azurerm_databricks_workspace" "this" {
  name                                  = "${var.name_prefix}-workspace"
  resource_group_name                   = var.rg_name
  managed_resource_group_name           = "${var.name_prefix}-mrg"
  location                              = var.azure_region
  sku                                   = "premium"
  tags                                  = local.tags
  public_network_access_enabled         = true
  network_security_group_rules_required = "NoAzureDatabricksRules"
  customer_managed_key_enabled          = true
  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = azurerm_virtual_network.this.id
    private_subnet_name                                  = azurerm_subnet.private.name
    public_subnet_name                                   = azurerm_subnet.public.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private.id
    storage_account_name                                 = var.dbfs_storage_account
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.public,
    azurerm_subnet_network_security_group_association.private
  ]
}

output "databricks_host" {
  value = "https://${azurerm_databricks_workspace.this.workspace_url}/"
}