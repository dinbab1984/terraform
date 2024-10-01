variable "databricks_workspace_host" {
  description = "Databricks Workspace URL"
  type        = string
  default     = ""
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

variable "allowed_ip_list" {
  description = "Allowed List of IPs"
  type        = list(string)
  default     = []
}