//storage account secure connection 
data azurerm_storage_account "data_storage_account" {
  name = var.data_storage_account
  resource_group_name = var.data_storage_account_rg
}