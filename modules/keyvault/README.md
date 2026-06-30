# Module: `keyvault`

Hardened Azure Key Vault:

- **RBAC authorization mode** (`rbac_authorization_enabled = true`) — no legacy access policies.
- **Purge protection** + **soft delete** (90-day retention) enforced.
- `network_acls` default-deny; **public network access disabled** when a private endpoint is configured.
- Optional **private endpoint** with private DNS zone group (`privatelink.vaultcore.azure.net`).
- Diagnostic settings (`AuditEvent`, policy evaluation, metrics) to Log Analytics.

## Usage

```hcl
module "keyvault" {
  source = "../../modules/keyvault"

  name                       = "aircloud-dev"
  resource_group_name        = azurerm_resource_group.this.name
  location                   = "westeurope"
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  log_analytics_workspace_id = module.observability.workspace_id

  private_endpoint = {
    subnet_id           = module.network.subnet_ids["endpoints"]
    private_dns_zone_id = module.network.private_dns_zone_ids["privatelink.vaultcore.azure.net"]
  }

  rbac_admins = {
    platform = var.platform_admins_group_id
  }

  tags = local.tags
}
```

<!-- BEGIN_TF_DOCS -->
<!-- terraform-docs injects the inputs/outputs table here on pre-commit / CI. -->
<!-- END_TF_DOCS -->
