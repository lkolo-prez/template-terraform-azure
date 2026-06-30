variable "subscription_id" {
  description = "Target Azure subscription ID."
  type        = string
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "westeurope"
}

variable "environment" {
  description = "Environment name. Used in tags and naming."
  type        = string
  default     = "dev"
}

variable "name_prefix" {
  description = "Naming prefix for all resources."
  type        = string
  default     = "aircloud"
}

variable "platform_admins_group_id" {
  description = "Entra ID group object ID granted cluster-admin and Key Vault admin."
  type        = string
}

variable "github_repository" {
  description = "owner/repo used to scope GitHub Actions OIDC federated credentials."
  type        = string
  default     = "aircloud/template-terraform-azure"
}

variable "alert_email" {
  description = "Email address for the platform on-call alert action group."
  type        = string
}

variable "tags" {
  description = "Extra tags merged onto the standard tag set."
  type        = map(string)
  default     = {}
}
