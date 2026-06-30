output "registry_id" {
  description = "Resource ID of the container registry."
  value       = azurerm_container_registry.this.id
}

output "registry_name" {
  description = "Name of the container registry."
  value       = azurerm_container_registry.this.name
}

output "login_server" {
  description = "Login server FQDN of the registry."
  value       = azurerm_container_registry.this.login_server
}

output "identity_principal_id" {
  description = "Principal ID of the registry's system-assigned identity."
  value       = azurerm_container_registry.this.identity[0].principal_id
}
