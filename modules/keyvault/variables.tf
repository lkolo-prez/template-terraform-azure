variable "name" {
  description = "Base name used to derive the Key Vault name. Will be sanitized to 3-24 alphanumerics."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the Key Vault."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tenant_id" {
  description = "Entra ID tenant ID."
  type        = string
}

variable "sku_name" {
  description = "Key Vault SKU."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be \"standard\" or \"premium\"."
  }
}

variable "soft_delete_retention_days" {
  description = "Soft-delete retention in days (7-90)."
  type        = number
  default     = 90
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID for diagnostic settings."
  type        = string
}

variable "private_endpoint" {
  description = <<-EOT
    Optional private endpoint. When set, the vault disables public network access
    and is reachable only through the endpoint in the given subnet.
  EOT
  type = object({
    subnet_id           = string
    private_dns_zone_id = string
  })
  default = null
}

variable "rbac_admins" {
  description = "Map of logical name to principal object ID granted \"Key Vault Administrator\"."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
