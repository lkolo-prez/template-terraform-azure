variable "name" {
  description = "Base name used to derive resource names (e.g. \"aircloud-dev\")."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,40}$", var.name))
    error_message = "name must be 2-40 chars of lowercase letters, digits and hyphens."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group to create the network resources in."
  type        = string
}

variable "location" {
  description = "Azure region (e.g. \"westeurope\")."
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "subnets" {
  description = <<-EOT
    Map of subnets to create. Key is the subnet logical name.
    `service_endpoints` and `delegation` are optional.
  EOT
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
    delegation = optional(object({
      name         = string
      service_name = string
      actions      = list(string)
    }))
    private_endpoint_network_policies = optional(string, "Enabled")
  }))
}

variable "enable_private_dns" {
  description = "Create a private DNS zone for private endpoints and link it to the VNet."
  type        = bool
  default     = true
}

variable "private_dns_zone_names" {
  description = "Private DNS zones to create and link (e.g. for Key Vault, ACR, AKS API)."
  type        = list(string)
  default = [
    "privatelink.vaultcore.azure.net",
    "privatelink.azurecr.io",
  ]
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID for NSG diagnostic settings. If null, diagnostics are not created."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
