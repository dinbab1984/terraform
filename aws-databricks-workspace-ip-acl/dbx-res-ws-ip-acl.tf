resource "databricks_workspace_conf" "this" {
  provider = databricks.workspace
  custom_config = {
    "enableIpAccessLists" = true
  }
}

resource "databricks_ip_access_list" "allowed-list" {
  provider = databricks.workspace
  label     = "allow_in"
  list_type = "ALLOW"
  ip_addresses = var.allowed_ip_list
  depends_on = [databricks_workspace_conf.this]
}

