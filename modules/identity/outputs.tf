output "identity_id" {
  description = "Resource ID of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.this.id
}

output "client_id" {
  description = "Client ID of the managed identity (used in azure/login and AZURE_CLIENT_ID)."
  value       = azurerm_user_assigned_identity.this.client_id
}

output "principal_id" {
  description = "Principal (object) ID of the managed identity, for role assignments."
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "tenant_id" {
  description = "Tenant ID associated with the identity."
  value       = azurerm_user_assigned_identity.this.tenant_id
}
