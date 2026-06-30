variable "name" {
  description = "Base name used to derive workspace and alert resource names."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for observability resources."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "retention_in_days" {
  description = "Log Analytics data retention in days (30-730)."
  type        = number
  default     = 90
}

variable "daily_quota_gb" {
  description = "Daily ingestion cap in GB. -1 means unlimited."
  type        = number
  default     = -1
}

variable "action_group_email_receivers" {
  description = "Map of logical name to email address for the alert action group."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
