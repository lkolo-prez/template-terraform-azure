locals {
  # Key Vault names are globally unique, 3-24 chars, alphanumerics and hyphens.
  kv_name = substr("kv${replace(var.name, "/[^a-zA-Z0-9]/", "")}", 0, 24)
}

resource "azurerm_key_vault" "this" {
  name                = local.kv_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = var.tenant_id
  sku_name            = var.sku_name

  # Authorization via Azure RBAC only (no legacy access policies).
  rbac_authorization_enabled = true

  # Data protection: soft delete + purge protection are mandatory and irreversible.
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = true

  public_network_access_enabled = var.private_endpoint == null

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "admins" {
  for_each = var.rbac_admins

  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.value
}

resource "azurerm_private_endpoint" "this" {
  count = var.private_endpoint == null ? 0 : 1

  name                = "pe-${local.kv_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-${local.kv_name}"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_endpoint.private_dns_zone_id]
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "diag-${local.kv_name}"
  target_resource_id         = azurerm_key_vault.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
