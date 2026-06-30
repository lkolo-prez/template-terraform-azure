variable "name" {
  description = "Base name used to derive identity names (e.g. \"aircloud-dev\")."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the managed identities."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "github_oidc_credentials" {
  description = <<-EOT
    Federated credentials for GitHub Actions OIDC. Key is a logical name.
    `subject` is the full OIDC subject, e.g.
    "repo:aircloud/template-terraform-azure:environment:prod" or
    "repo:aircloud/template-terraform-azure:ref:refs/heads/main".
  EOT
  type = map(object({
    subject = string
  }))
  default = {}
}

variable "github_oidc_issuer" {
  description = "OIDC issuer for GitHub Actions tokens."
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "workload_identity_credentials" {
  description = <<-EOT
    Federated credentials for AKS Workload Identity. Key is a logical name.
    `issuer` is the AKS OIDC issuer URL, `subject` is
    "system:serviceaccount:<namespace>:<serviceaccount>".
  EOT
  type = map(object({
    issuer  = string
    subject = string
  }))
  default = {}
}

variable "role_assignments" {
  description = <<-EOT
    Least-privilege role assignments granted to the created identity.
    Key is a logical name; `scope` is the target resource ID.
  EOT
  type = map(object({
    role_definition_name = string
    scope                = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
