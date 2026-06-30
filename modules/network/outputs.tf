output "vnet_id" {
  description = "Resource ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Map of subnet logical name to subnet resource ID."
  value       = { for k, s in azurerm_subnet.this : k => s.id }
}

output "nsg_ids" {
  description = "Map of subnet logical name to NSG resource ID."
  value       = { for k, n in azurerm_network_security_group.this : k => n.id }
}

output "private_dns_zone_ids" {
  description = "Map of private DNS zone name to resource ID."
  value       = { for k, z in azurerm_private_dns_zone.this : k => z.id }
}
