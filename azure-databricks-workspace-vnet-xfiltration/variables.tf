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

//Artefact store fqdns of region
variable "artefactstorefqdns" { 
  description = "List of Artefact  Store FQDNs in the region"
  type = list(string)
  default = [ //databricks artifacts
    "dbartifactsprodwesteu.blob.core.windows.net", 
    "arprodwesteua1.blob.core.windows.net",
    "arprodwesteua2.blob.core.windows.net",
    "arprodwesteua3.blob.core.windows.net",
    "arprodwesteua4.blob.core.windows.net",
    "arprodwesteua5.blob.core.windows.net",
    "arprodwesteua6.blob.core.windows.net",
    "arprodwesteua7.blob.core.windows.net",
    "arprodwesteua8.blob.core.windows.net",
    "arprodwesteua9.blob.core.windows.net",
    "arprodwesteua10.blob.core.windows.net",
    "arprodwesteua11.blob.core.windows.net",
    "arprodwesteua12.blob.core.windows.net",
    "arprodwesteua13.blob.core.windows.net",
    "arprodwesteua14.blob.core.windows.net",
    "arprodwesteua15.blob.core.windows.net",
    "arprodwesteua16.blob.core.windows.net",
    "arprodwesteua17.blob.core.windows.net",
    "arprodwesteua18.blob.core.windows.net",
    "arprodwesteua19.blob.core.windows.net",
    "arprodwesteua20.blob.core.windows.net",
    "arprodwesteua21.blob.core.windows.net",
    "arprodwesteua22.blob.core.windows.net",
    "arprodwesteua23.blob.core.windows.net",
    "arprodwesteua24.blob.core.windows.net",
    "dbartifactsprodnortheu.blob.core.windows.net" //databricks artifacts secondary
  ]
}

//Legacy Metastore fqdns of region
variable "metastorefqdns" { 
  description = "List of Metastore  Store FQDNs in the region"
  type = list(string)
  default = [
    "consolidated-westeurope-prod-metastore.mysql.database.azure.com",
    "consolidated-westeurope-prod-metastore-addl-1.mysql.database.azure.com",
    "consolidated-westeurope-prod-metastore-addl-2.mysql.database.azure.com",
    "consolidated-westeurope-prod-metastore-addl-3.mysql.database.azure.com",
    "consolidated-westeuropec2-prod-metastore-0.mysql.database.azure.com",
    "consolidated-westeuropec2-prod-metastore-1.mysql.database.azure.com",
    "consolidated-westeuropec2-prod-metastore-2.mysql.database.azure.com",
    "consolidated-westeuropec2-prod-metastore-3.mysql.database.azure.com",
  ]
}

variable "tags" { 
  default = ""
}