variable "azure_region" { #
  type    = string
  default = ""
}

variable "name_prefix" { #
  type    = string
  default = ""
}

variable "azure_tenant_id" { #
  type  = string
  default = ""
}

variable "azure_subscription_id" { #
  type  = string
  default = ""
}

variable "azure_client_id" { #
  type  = string
  default = ""
}

variable "azure_client_secret" { #
  type  = string
  default = ""
}

variable "hub_rg_name" {
  type    = string
  default = ""
}

variable "hub_cidr_block" {
  description = "Hub VNET CIDR block range"
  type        = string
  default = "10.30.0.0/24"
}

// for firewall subnet
variable "fw_subnets_cidr" { #
  type = string
  default = "10.30.0.0/26"
}

//workspace vnet or spoke vnet
variable "databricks_workspace_vnet_rg" { #
  description = "Name of databricks workspace VNET resource group"
  type = string
  default = ""
}

//workspace vnet or spoke vnet
variable "databricks_workspace_vnet" { #
  description = "Name of databricks workspace VNET"
  type = string
  default = ""
}

//mysql metastore addresses of region
variable "metastoreips" { 
  description = "List of Mysql Metastoe addresses in the region"
  type = list(string)
  #default = ["consolidated-westeurope-prod-metastore.mysql.database.azure.com","consolidated-westeurope-prod-metastore-addl-1.mysql.database.azure.com","consolidated-westeurope-prod-metastore-addl-2.mysql.database.azure.com","consolidated-westeurope-prod-metastore-addl-3.mysql.database.azure.com","consolidated-westeuropec2-prod-metastore-0.mysql.database.azure.com","consolidated-westeuropec2-prod-metastore-1.mysql.database.azure.com" ,"consolidated-westeuropec2-prod-metastore-2.mysql.database.azure.com","consolidated-westeuropec2-prod-metastore-3.mysql.database.azure.com"]
}

//Log store fdqns of region
variable "logstorefqdns" { 
  description = "List of Log Store FQDNs in the region"
  type = list(string)
  default = ["dblogprodwesteurope.blob.core.windows.net"]
}

//Telemetry fqdns of region
variable "telemetryfqdns" { 
  description = "List of Telemetry FQDNs in the region"
  type = list(string)
  default = ["prod-westeurope-observabilityeventhubs.servicebus.windows.net","prod-westeuc2-observabilityeventhubs.servicebus.windows.net"]
}

//System table store fqdns of region
variable "systemtablestorefqdns" { 
  description = "List of System Table Store FQDNs in the region"
  type = list(string)
  default = ["ucstprdwesteu.dfs.core.windows.net"]
}

variable "storage_servicetag" {
  description = "Azure Storage Service Tag"
  type        = string
  default = "Storage.WestEurope"
}

variable "tags" { 
  default = ""
}