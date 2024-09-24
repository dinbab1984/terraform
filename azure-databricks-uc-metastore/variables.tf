variable "tags" {
  default = {}
}

variable "azure_uc_metastore" {
  description = "Azure UC Metastore"
  type        = string
  default     = "dinbab-tf-uc-metastore"
}

variable "azure_region" {
  type    = string
  default = "germanywestcentral"
}

variable "databricks_account_id" {
  description = "Your Databricks Account ID"
  type        = string
  default = ""
}

variable "databricks_host" {
  description = "Databricks Account console URL"
  type        = string
  default = ""
}

variable "client_id" {
  description = "Databricks Account Client Id"
  type        = string
  default = ""
}

variable "client_secret" {
  description = "Databricks Account Client Secret"
  type        = string
  default = ""
}
