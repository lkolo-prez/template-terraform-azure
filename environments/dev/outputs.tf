output "resource_group_name" {
  description = "Resource group name for this environment."
  value       = azurerm_resource_group.this.name
}

output "aks_cluster_name" {
  description = "AKS cluster name."
  value       = module.aks.cluster_name
}

output "aks_oidc_issuer_url" {
  description = "AKS OIDC issuer URL for Workload Identity federation."
  value       = module.aks.oidc_issuer_url
}

output "acr_login_server" {
  description = "ACR login server FQDN."
  value       = module.acr.login_server
}

output "key_vault_uri" {
  description = "Key Vault URI."
  value       = module.keyvault.key_vault_uri
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID."
  value       = module.observability.workspace_id
}
