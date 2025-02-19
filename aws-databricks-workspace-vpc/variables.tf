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

variable "databricks_metastore" {
  description = "Databricks UC Metastore"
  type        = string
  default     = ""
}

//for vpc
variable "cidr_block" {
  description = "VPC CIDR block range"
  type        = string
  default = ""
}

// for cluster
variable "nat_subnets_cidr" {
  type = map(any)
  default = {}
}

variable "private_subnets_cidr" {
  type = map(any)
  default = {}
}

variable "workspace_admin" {
  description = "Email id of workspace admin"
  type        = string
  default     = ""
}

variable "tags" {
  default = {}
}

//network ACLs for the vpc subnets
variable "vpc_network_acl_ports" {
  type = list(number)
  default = [443, 3306, 6666, 2443, 8443, 8444, 8445]
  //443 for Databricks infrastructure, cloud data sources, and library repositories
  //3306: for the metastore
  //6666: for PrivateLink
  //2443: only for use with compliance security profile
  //8443: for internal calls from the Databricks compute plane to the Databricks control plane API
  //8444: for Unity Catalog logging and lineage data streaming into Databricks.
  //8445 through 8451: Future extendability.
}
