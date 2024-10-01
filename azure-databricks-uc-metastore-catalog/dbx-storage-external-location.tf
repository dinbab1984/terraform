//resource group for storage account and associated resources
resource "azurerm_resource_group" "this" {
  name     =  var.rg_name
  location = var.azure_region
  tags     = var.tags
}
//storage account for adls with hierarchical namespace enabled
resource "azurerm_storage_account" "this" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = var.azure_region
  name                     = var.adls_sa_name
  resource_group_name      = var.rg_name
  is_hns_enabled           = true
  tags                     = var.tags
  depends_on               = [azurerm_resource_group.this]
}
//containers with the storage account
resource "azurerm_storage_container" "this" {
  name                  = "container"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "container"
  depends_on            = [azurerm_storage_account.this]
}
//user assigned identity for access to storage account
resource "azurerm_user_assigned_identity" "this" {
  location            = var.azure_region
  name                = "${var.adls_sa_name}-user-identity"
  resource_group_name = var.rg_name
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
  name                = "${var.adls_sa_name}-access-connector"
  resource_group_name = var.rg_name
  tags                = var.tags
  depends_on          = [azurerm_user_assigned_identity.this]
  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }
}

//Get metastore IDs
data "databricks_metastore" "this" {
  provider = databricks.accounts
  name = var.databricks_metastore
}

//Add storage Credentials to databricks account
resource "databricks_storage_credential" "this" {
  provider = databricks.workspace
  name = "${var.name_prefix}-storage-credential"
  metastore_id = data.databricks_metastore.this.id
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.this.id
    managed_identity_id = azurerm_user_assigned_identity.this.id
  }
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  comment = "Managed identity credential managed by TF"
  depends_on = [azurerm_databricks_access_connector.this, azurerm_storage_account.this]
}
//Add External location to databricks account
resource "databricks_external_location" "this" {
  provider = databricks.workspace
  name = "${var.name_prefix}-external-location"
  metastore_id = data.databricks_metastore.this.id
  url = format("abfss://%s@%s.dfs.core.windows.net/", azurerm_storage_container.this.name, azurerm_storage_account.this.name)
  credential_name = databricks_storage_credential.this.name
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  comment         = "Managed by TF"
  depends_on = [databricks_storage_credential.this]
}
//provide access to external location to workspace admins
resource "databricks_grants" "admins_browse_access" {
  provider = databricks.workspace
  external_location = databricks_external_location.this.id
  grant {
    principal  = var.principal_name
    privileges = ["BROWSE"]
  }
  depends_on = [databricks_external_location.this]
}

