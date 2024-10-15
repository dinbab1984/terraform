//Get metastore ID (provider)
data "databricks_metastore" "provider_metastore" {
  provider = databricks.accounts-data-provider
  name = var.provider_metastore
}

//Get metastore ID (recipient)
data "databricks_metastore" "recipient_metastore" {
  provider = databricks.accounts-data-recipient
  name = var.recipient_metastore
}

//Create Recipient
resource "databricks_recipient" "recipient" {
  provider            = databricks.workspace-data-provider
  name                = "${var.name_prefix}-recipient"
  authentication_type = "DATABRICKS"
  data_recipient_global_metastore_id =  data.databricks_metastore.recipient_metastore.metastore_info[0].global_metastore_id
  depends_on = [data.databricks_metastore.recipient_metastore]
}

//Create Share
resource "databricks_share" "share" {
  provider            = databricks.workspace-data-provider
  name                = "${var.name_prefix}-share"
  dynamic "object" {
    for_each = var.share_tables_name
    content {
      name             = object.value
      data_object_type = "TABLE"
      history_data_sharing_status = "ENABLED"
    }
  }
}

//Share Grants to recipient
resource "databricks_grant" "grant_share" {
  provider   = databricks.workspace-data-provider
  share      = databricks_share.share.name
  principal  = databricks_recipient.recipient.name
  privileges = ["SELECT"]
  depends_on = [databricks_share.share, databricks_recipient.recipient]
}

//Create catalog in the metastore using the share
resource "databricks_catalog" "foreign_catalog" {
  name           = "${var.name_prefix}-catalog"
  provider       = databricks.workspace-data-recipient
  metastore_id   = data.databricks_metastore.recipient_metastore.id
  provider_name  = data.databricks_metastore.provider_metastore.metastore_info[0].global_metastore_id
  share_name     = databricks_share.share.name
  isolation_mode = "ISOLATED"
  depends_on     = [databricks_share.share, databricks_recipient.recipient]
}

//provide access to external location to workspace admins
resource "databricks_grants" "grant_catalog_access" {
  provider = databricks.workspace-data-recipient
  catalog  = databricks_catalog.foreign_catalog.name
  grant {
    principal  = var.principal_name
    privileges = var.catalog_privileges
  }
  depends_on = [databricks_catalog.foreign_catalog]
}



