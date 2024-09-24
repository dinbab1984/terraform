resource "databricks_metastore" "this" {
  provider      = databricks.accounts
  name          = var.azure_uc_metastore
  force_destroy = true
  region       = var.azure_region
}