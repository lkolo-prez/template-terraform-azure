output "workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.id
}

output "workspace_name" {
  description = "Name of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.name
}

output "workspace_customer_id" {
  description = "Workspace (customer) GUID used by agents."
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "action_group_id" {
  description = "Resource ID of the monitor action group."
  value       = azurerm_monitor_action_group.this.id
}
