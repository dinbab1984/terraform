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

//for cluster
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

//backend-pl-specific
variable "backend_pl_subnets_cidr" {
  type = map(any)
  default = {}
}
//backend-pl-specific-rest
variable "db_rest_service" {
  default = ""
}
//backend-pl-specific-scc-relay
variable "db_scc_relay_service" {
  default = ""
}

//Legacy Metastore fqdn of region
variable "metastorefqdn" { 
  description = "Metastore  Store FQDN in the region"
  type = string
  default = "md15cf9e1wmjgny.cxg30ia2wqgj.eu-west-1.rds.amazonaws.com"
}

//hub cidr
variable "cidr_block_hub" {
  description = "Hub VPC CIDR block range"
  type        = string
  default = "10.30.0.0/16"
}

// for nat
variable "nat_subnets_cidr_hub" {
  type = map(any)
  default = {"eu-west-1a" : "10.30.1.0/24", "eu-west-1b" : "10.30.2.0/24"}
}

// for hub transit gateway
variable "backend_pl_subnets_cidr_hub" {
  type = map(any)
  default = {"eu-west-1a" : "10.30.3.0/24", "eu-west-1b" : "10.30.4.0/24"}
}

