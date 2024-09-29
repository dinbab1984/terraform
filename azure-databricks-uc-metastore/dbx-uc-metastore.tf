resource "databricks_metastore" "this" {
  provider      = databricks.accounts
  name          = var.databricks_metastore
  force_destroy = true
  region        = var.azure_region
}

