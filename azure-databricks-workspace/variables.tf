variable "azure_region" {
  type    = string
  default = "Germany West Central"
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

variable "name_prefix" {
  type    = string
  default = "dinbab-tf"
}

variable "dbfs_storage_account" {
  type    = string
  default = "dbfs4dinbabtf"
}

variable "rg_name" {
  type    = string
  default = "dinbab-tf-rg"
}

locals {
  tags = {
    Owner = "dinesh.kamalakkannan@databricks.com"
  }
}