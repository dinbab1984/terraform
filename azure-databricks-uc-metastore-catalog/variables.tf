variable "tags" {
  default = {
    Owner = ""
  }
}

variable "azure_region" {
  type    = string
  default = ""
}

variable "azure_tenant_id" {
  type    = string
  default = ""
}

variable "azure_subscription_id" {
  type    = string
  default = ""
}

variable "azure_client_id" {
  description = "Azure service principal with needed permissions"
  type    = string
  default = ""
}

variable "azure_client_secret" {
  type    = string
  default = ""
}

variable "databricks_host" {
  description = "Databricks Account URL"
  type        = string
  default     = ""
}

variable "databricks_workspace_host" {
  description = "Databricks Workspace URL"
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

variable "rg_name" {
  description = "ALDS Storage account resource group"
  type        = string
  default     = ""
}

variable "adls_sa_name" {
  description = "ALDS Storage account Name"
  type        = string
  default     = ""
}

//nane_prefix for databricks resources
variable "name_prefix" {
  type    = string
  default = ""
}

variable "databricks_metastore" {
  description = "Name of the UC metastore"
  type    = string
  default = ""
}

variable "databricks_calalog" {
  description = "Name of catalog in metastore"
  type        = string
  default     = ""
}

variable "principal_name" {
  description = "Name of principal to grant access to catalog"
  type        = string
  default     = ""
}

variable "catalog_privileges" {
  description = "List of Privileges to catalog (grant to principal_name)"
  type        = list(string)
  default     = ["BROWSE"]
}
