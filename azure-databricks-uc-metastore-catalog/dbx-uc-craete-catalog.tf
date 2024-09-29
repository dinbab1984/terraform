//Create catalog in the metastore using the external location created
resource "databricks_catalog" "this" {
  name = var.databricks_calalog
  provider = databricks.workspace
  metastore_id = data.databricks_metastore.this.id
  storage_root = databricks_external_location.this.url
  isolation_mode = "ISOLATED"
  depends_on = [data.databricks_metastore.this]
}

