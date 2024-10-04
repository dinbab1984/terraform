variable "aws_credentials_file" {
  description = "list of aws credentials file locations"
  type        = list(string)
  default     = ["./.aws/credentials"]
}

variable "aws_profile" {
  description = "Value of AWS profile"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = ""
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

variable "databricks_workspace_host" {
  description = "Databricks Workspace URL"
  type        = string
  default     = ""
}

variable "databricks_client_id" {
  description = "Databricks Account Client Id"
  type        = string
  default = ""
}

variable "databricks_client_secret" {
  description = "Databricks Account Client Secret"
  type        = string
  default = ""
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

variable "tags" {
  default = {}
}





