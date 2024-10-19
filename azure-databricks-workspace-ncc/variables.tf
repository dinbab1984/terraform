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

variable "databricks_workspace" {
  description = "Databricks Workspace name"
  type        = string
  default     = ""
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

variable "adls_sa_name" {
  description = "ALDS Storage account Name"
  type        = string
  default     = ""
}

variable "adls_sa_rg" {
  description = "ALDS Storage account resource group"
  type        = string
  default     = ""
}

variable "tags" {
  default = ""
}

