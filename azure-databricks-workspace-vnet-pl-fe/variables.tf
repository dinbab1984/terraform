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

variable "transit_vnet_rg" {
  type    = string
  default = ""
}

variable "transit_cidr_block" {
  description = "Transit VNET CIDR block range"
  type        = string
  default = "10.30.0.0/24"
}

// for pl subnet
variable "transit_pl_subnets_cidr" { #
  type = string
  default = "10.30.0.0/26"
}

variable "databricks_workspace_rg" { #
  description = "Databricks Workspace resource group"
  type        = string
  default     = ""
}

variable "databricks_workspace" { #
  description = "Databricks Workspace name"
  type        = string
  default     = ""
}

variable "tags" { 
  default = ""
}