//create workspace
resource "databricks_mws_workspaces" "this" {
  provider       = databricks.mws
  account_id     = var.databricks_account_id
  aws_region     = var.aws_region
  workspace_name = "${var.name_prefix}-workspace"

  credentials_id           = databricks_mws_credentials.this.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.this.storage_configuration_id
  network_id               = databricks_mws_networks.this.network_id

  token {
    comment = "Terraform"
  }
  depends_on = [databricks_mws_credentials.this, databricks_mws_storage_configurations.this, databricks_mws_networks.this]
}

//Get metastore IDs
data "databricks_metastore" "this" {
  provider = databricks.mws
  name     = var.databricks_metastore
}

resource "databricks_metastore_assignment" "this" {
  provider     = databricks.mws
  metastore_id = data.databricks_metastore.this.id
  workspace_id = databricks_mws_workspaces.this.workspace_id
  depends_on   = [databricks_mws_workspaces.this, data.databricks_metastore.this]
}

data "databricks_user" "workspace_admin" {
  provider  = databricks.mws
  user_name = var.workspace_admin
}

resource "databricks_mws_permission_assignment" "workspace_admin" {
  provider     = databricks.mws
  permissions  = ["ADMIN"]
  principal_id = data.databricks_user.workspace_admin.id
  workspace_id = databricks_mws_workspaces.this.workspace_id
  depends_on   = [databricks_mws_workspaces.this, databricks_metastore_assignment.this]
}


output "databricks_ws_id" {
  value = databricks_mws_workspaces.this.id
}

output "databricks_host" {
  value = databricks_mws_workspaces.this.workspace_url
}

output "databricks_token" {
  value     = databricks_mws_workspaces.this.token[0].token_value
  sensitive = true
}
