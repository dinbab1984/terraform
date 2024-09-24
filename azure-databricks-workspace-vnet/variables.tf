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
  default = "dinbab-tf-vnet"
}

variable "dbfs_storage_account" {
  type    = string
  default = "dbfs4dinbabtfvnet"
}

variable "rg_name" {
  type    = string
  default = "dinbab-tf-vnet-rg"
}

variable "cidr_block" {
  description = "VPC CIDR block range"
  type        = string
  default = "10.20.0.0/23"
}

//variable "whitelisted_urls" {
//  default = [".pypi.org", ".pythonhosted.org", ".cran.r-project.org"]
//}

// for cluster container
variable "private_subnets_cidr" {
  type = string
  default = "10.20.0.0/25"
}

// for cluster host
variable "public_subnets_cidr" {
  type = string
  default = "10.20.0.128/25"
}

// for private link (backend and other azure services )
variable "pl_subnets_cidr" {
  type = string
  default = "10.20.1.0/27"
}

locals {
  tags = {
    Owner = "dinesh.kamalakkannan@databricks.com"
  }
}