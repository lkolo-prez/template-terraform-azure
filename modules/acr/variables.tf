variable "name" {
  description = "Base name used to derive the registry name. Sanitized to 5-50 alphanumerics."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the registry."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "sku" {
  description = "ACR SKU. Premium is required for private endpoints, retention and geo-replication."
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be Basic, Standard or Premium."
  }
}

variable "retention_days" {
  description = "Untagged manifest retention in days (Premium only)."
  type        = number
  default     = 30
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID for diagnostic settings."
  type        = string
}

variable "private_endpoint" {
  description = "Optional private endpoint. When set, public network access is disabled."
  type = object({
    subnet_id           = string
    private_dns_zone_id = string
  })
  default = null
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
