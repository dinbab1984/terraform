variable "azure_region" {
  type    = string
  default = ""
}

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

variable "databricks_host" {
  description = "Databricks Account URL"
  type        = string
  default     = ""
}

variable "databricks_account_id" {
  description = "Your Databricks Account ID"
  type        = string
  default = ""
}

variable "databricks_client_id" {
  description = "Databricks Account Client Id (databricks service principal - account admin)"
  type        = string
  default     = ""
}

variable "databricks_client_secret" {
  description = "Databricks Account Client Secret"
  type        = string
  default     = ""
}

variable "databricks_workspace" {
  description = "Name of databricks workspace"
  type = string
  default = ""
}

variable "databricks_workspace_rg" {
  description = "Name of databricks workspace resource group"
  type = string
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

variable "tags" {
  default = ""
}

