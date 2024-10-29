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

variable "private_subnet_endpoints" {
    type = list(string)
    default = []
}


//does the data plane (clusters) to control plane communication happen over private link endpoint only or publicly?
variable "network_security_group_rules_required" {
  type = string
  default = "AllRules"
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

variable "databricks_metastore" {
  description = "Databricks UC Metastore"
  type        = string
  default     = ""
}

variable "tags" {
  default = ""
}