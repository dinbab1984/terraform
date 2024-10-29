variable "azure_tenant_id" {
  type  = string
  default = ""
}

variable "azure_subscription_id" {
  type  = string
  default = ""
}

variable "azure_client_id" {
  type  = string
  default = ""
}

variable "azure_client_secret" {
  type  = string
  default = ""
}

variable "data_storage_account_rg" {
  description = "Data Storage Account resource group (here, storage for catalog - external location)"
  type        = string
  default     = ""
}

variable "data_storage_account" {
  description = "Data Storage Account name (here, storage for catalog - external location)"
  type        = string
  default     = ""
}

variable "databricks_workspace_vnet" {
  description = "Name of databricks workspace VNET"
  type = string
  default = ""
}

variable "databricks_workspace_vnet_rg" {
  description = "Name of databricks workspace VNET resource group"
  type = string
  default = ""
}