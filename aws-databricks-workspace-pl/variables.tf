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

variable "name_prefix" {
  description = "Name prefix for all resources"
  type        = string
  default     = "dinbab-tf"
}

variable "tags" {
  default = {}
}





