variable "azure_region" {
  type    = string
  default = ""
}

variable "rg_name" {
  type    = string
  default = ""
}

variable "name_prefix" {
  type    = string
  default = ""
}

variable "dbfs_storage_account" {
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

// for private link (backend and other azure services )
variable "pl_subnets_cidr" {
  type = string
  default = "10.20.1.0/27"
}

variable "databricks_workspace" {
  description = "Databricks Workspace name"
  type        = string
  default     = ""
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