data "restapi_object" "ncc" {
  path = "/api/2.0/accounts/${var.databricks_account_id}/network-connectivity-configs"
  search_key = "name"
  search_value = "ncc-dbk-vnet-demo-workspace" //var.workspace_ncc_name
  id_attribute ="network_connectivity_config_id"
  results_key = "items"
}

/*output "ncc_config_id" {
  value = jsondecode(data.restapi_object.ncc.api_response).network_connectivity_config_id
}
*/

//add ncc private endpoint rule
resource "databricks_mws_ncc_private_endpoint_rule" "storage" {
  provider                       = databricks.accounts
  network_connectivity_config_id = jsondecode(data.restapi_object.ncc.api_response).network_connectivity_config_id
  resource_id                    = data.azurerm_storage_account.data_storage_account.id
  group_id                       = "dfs"
  depends_on = [data.restapi_object.ncc]
}

/*
output "name" {
  value = databricks_mws_ncc_private_endpoint_rule.storage.endpoint_name
}
*/

data "azapi_resource_list" "list_storage_private_endpoint_connection" {
  type                   = "Microsoft.Storage/storageAccounts/privateEndpointConnections@2022-09-01"
  parent_id              = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${var.data_storage_account_rg}/providers/Microsoft.Storage/storageAccounts/${var.data_storage_account}"
  response_export_values = ["*"]
  depends_on = [ databricks_mws_ncc_private_endpoint_rule.storage ]
}

/*output "name_pepc" {
  value = data.azapi_resource_list.list_storage_private_endpoint_connection.output.value
}

output "list_storage_private_endpoint_connection" {
  value = [ for i in data.azapi_resource_list.list_storage_private_endpoint_connection.output.value :  i.name if endswith(i.properties.privateEndpoint.id , databricks_mws_ncc_private_endpoint_rule.storage.endpoint_name)][0]
}
*/

resource "azapi_update_resource" "approve_storage_private_endpoint_connection" {
  type      = "Microsoft.Storage/storageAccounts/privateEndpointConnections@2022-09-01"
  name      = [ for i in data.azapi_resource_list.list_storage_private_endpoint_connection.output.value :  i.name if endswith(i.properties.privateEndpoint.id , databricks_mws_ncc_private_endpoint_rule.storage.endpoint_name)][0]
  parent_id = data.azurerm_storage_account.data_storage_account.id

  body = {
    properties = {
      privateLinkServiceConnectionState = {
        description = "Auto Approved via Terraform"
        status      = "Approved"
      }
    }
  }

  depends_on = [data.azapi_resource_list.list_storage_private_endpoint_connection]
}
