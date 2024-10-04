//Create catalog in the metastore using the external location created
resource "databricks_catalog" "this" {
  name           = var.databricks_calalog
  provider       = databricks.workspace
  metastore_id   = data.databricks_metastore.this.id
  storage_root   = databricks_external_location.catalog_external_location.url
  isolation_mode = "ISOLATED"
  depends_on     = [data.databricks_metastore.this, databricks_external_location.catalog_external_location]
}

//provide access to external location to workspace admins
resource "databricks_grants" "grant_catalog_access" {
  provider = databricks.workspace
  catalog  = var.databricks_calalog
  grant {
    principal  = var.principal_name
    privileges = var.catalog_privileges
  }
  depends_on = [databricks_catalog.this]
}