data "restapi_object" "ncc" {
  path = "/api/2.0/accounts/${var.databricks_account_id}/network-connectivity-configs"
  search_key = "name"
  search_value = "ncc-dbk-vnet-demo-workspace" //var.workspace_ncc_name
  id_attribute ="network_connectivity_config_id"
  results_key = "items"
}

output "ncc_config_id" {
  value = jsondecode(data.restapi_object.ncc.api_response).network_connectivity_config_id
}

//add ncc private endpoint rule
resource "databricks_mws_ncc_private_endpoint_rule" "storage" {
  provider                       = databricks.accounts
  network_connectivity_config_id = jsondecode(data.restapi_object.ncc.api_response).network_connectivity_config_id
  resource_id                    = data.azurerm_storage_account.data_storage_account.id
  group_id                       = "dfs"
  depends_on = [data.restapi_object.ncc]
}

