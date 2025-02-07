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
  force_destroy = true
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

