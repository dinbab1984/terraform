//resource group for storage account and associated resources
resource "azurerm_resource_group" "this" {
  name     = var.data_storage_account_rg
  location = var.azure_region
  tags     = var.tags
}
//storage account for adls with hierarchical namespace enabled
resource "azurerm_storage_account" "this" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = var.azure_region
  name                     = var.data_storage_account
  resource_group_name      = var.data_storage_account_rg
  is_hns_enabled           = true
  network_rules {
    default_action = "Deny"
    ip_rules = var.storage_account_allowed_ips
  }
  tags                     = var.tags
  depends_on               = [azurerm_resource_group.this]
}
//containers with the storage account
resource "azurerm_storage_container" "this" {
  name                  = "container"
  storage_account_id = azurerm_storage_account.this.id
  container_access_type = "container"
  depends_on            = [azurerm_storage_account.this]
}

//user assigned identity for access to storage account
resource "azurerm_user_assigned_identity" "this" {
  location            = var.azure_region
  name                = "${var.data_storage_account}-user-identity"
  resource_group_name = var.data_storage_account_rg
  tags                = var.tags
  depends_on          = [azurerm_resource_group.this]

}
//Assign blob contributor role for storage account to user managed identity
resource "azurerm_role_assignment" "this" {
  scope                =  azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  depends_on           = [azurerm_storage_account.this, azurerm_user_assigned_identity.this]
}

//Attach User assigned identity to databricks access connector
resource "azurerm_databricks_access_connector" "this" {
  location            = var.azure_region
  name                = "${var.data_storage_account}-access-connector"
  resource_group_name = var.data_storage_account_rg
  tags                = var.tags
  depends_on          = [azurerm_user_assigned_identity.this]
  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }
}
