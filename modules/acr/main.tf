locals {
  # ACR names are globally unique, 5-50 alphanumerics, no hyphens.
  acr_name = substr("acr${replace(var.name, "/[^a-zA-Z0-9]/", "")}", 0, 50)
}

resource "azurerm_container_registry" "this" {
  name                = local.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  # Never enable the admin user; auth is via Entra ID / managed identity (AcrPull).
  admin_enabled = false

  # Disable public access when fronted by a private endpoint.
  public_network_access_enabled = var.private_endpoint == null
  network_rule_bypass_option    = "AzureServices"

  # Premium-only hardening.
  zone_redundancy_enabled       = var.sku == "Premium"
  export_policy_enabled         = var.sku == "Premium" ? false : true
  data_endpoint_enabled         = var.sku == "Premium"
  trust_policy_enabled          = var.sku == "Premium"

  dynamic "retention_policy_in_days" {
    for_each = var.sku == "Premium" ? [var.retention_days] : []
    content {
      enabled = true
      days    = retention_policy_in_days.value
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "this" {
  count = var.private_endpoint == null ? 0 : 1

  name                = "pe-${local.acr_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-${local.acr_name}"
    private_connection_resource_id = azurerm_container_registry.this.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_endpoint.private_dns_zone_id]
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "diag-${local.acr_name}"
  target_resource_id         = azurerm_container_registry.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ContainerRegistryRepositoryEvents"
  }

  enabled_log {
    category = "ContainerRegistryLoginEvents"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
