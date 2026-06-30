variable "name" {
  description = "Base name used to derive the cluster name (e.g. \"aircloud-dev\")."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the AKS cluster."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes minor version (e.g. \"1.30\"). Leave null to use the AKS default."
  type        = string
  default     = null
}

variable "dns_prefix" {
  description = "DNS prefix for the cluster. Defaults to the cluster name."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Resource ID of the subnet that hosts the system node pool."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID for Container Insights and diagnostics."
  type        = string
}

variable "admin_group_object_ids" {
  description = "Entra ID group object IDs granted cluster-admin via Azure RBAC."
  type        = list(string)
  default     = []
}

variable "system_node_pool" {
  description = "System node pool configuration."
  type = object({
    vm_size              = optional(string, "Standard_D4ds_v5")
    min_count            = optional(number, 2)
    max_count            = optional(number, 5)
    os_disk_size_gb      = optional(number, 64)
    only_critical_addons = optional(bool, true)
    zones                = optional(list(string), ["1", "2", "3"])
  })
  default = {}
}

variable "network_policy" {
  description = "Network policy engine: \"cilium\", \"azure\" or \"calico\"."
  type        = string
  default     = "cilium"

  validation {
    condition     = contains(["cilium", "azure", "calico"], var.network_policy)
    error_message = "network_policy must be one of: cilium, azure, calico."
  }
}

variable "service_cidr" {
  description = "CIDR for Kubernetes services (must not overlap the VNet)."
  type        = string
  default     = "172.16.0.0/16"
}

variable "dns_service_ip" {
  description = "IP for kube-dns within service_cidr."
  type        = string
  default     = "172.16.0.10"
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
