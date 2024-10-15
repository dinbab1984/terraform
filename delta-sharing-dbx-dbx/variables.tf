variable "provider_databricks_host" {
  description = "Databricks Account URL"
  type        = string
  default     = ""
}

variable "provider_databricks_workspace_host" {
  description = "Databricks Workspace URL"
  type        = string
  default     = ""
}

variable "provider_databricks_account_id" {
  description = "Your Databricks Account ID"
  type        = string
  default = ""
}

variable "provider_databricks_client_id" {
  description = "Databricks Account Client Id (databricks service principal - account admin)"
  type        = string
  default     = ""
}

variable "provider_databricks_client_secret" {
  description = "Databricks Account Client Secret"
  type        = string
  default     = ""
}

variable "provider_metastore" {
  description = "Name of the UC metastore"
  type    = string
  default = ""
}


variable "recipient_databricks_host" {
  description = "Databricks Account URL"
  type        = string
  default     = ""
}

variable "recipient_databricks_workspace_host" {
  description = "Databricks Workspace URL"
  type        = string
  default     = ""
}

variable "recipient_databricks_account_id" {
  description = "Your Databricks Account ID"
  type        = string
  default = ""
}

variable "recipient_databricks_client_id" {
  description = "Databricks Account Client Id (databricks service principal - account admin)"
  type        = string
  default     = ""
}

variable "recipient_databricks_client_secret" {
  description = "Databricks Account Client Secret"
  type        = string
  default     = ""
}

variable "recipient_metastore" {
  description = "Name of the UC metastore"
  type    = string
  default = ""
}

variable "share_tables_name" {
  description = "Names of the tables to share (following namespace = catalog_name.schema_name.table_name)"
  type    = list(string)
  default = []
}


variable "name_prefix" {
  type    = string
  default = ""
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

