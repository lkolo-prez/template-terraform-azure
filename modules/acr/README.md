# Module: `acr`

Private Azure Container Registry:

- **Admin user disabled** — authentication via Entra ID / managed identity (`AcrPull`).
- **Public network access disabled** when a private endpoint is configured (`privatelink.azurecr.io`).
- Premium hardening: zone redundancy, **content trust** (`trust_policy_enabled`), export policy off, untagged-manifest **retention**.
- Diagnostic settings (repository + login events, metrics) to Log Analytics.
- Microsoft Defender for container registries is enabled at the subscription level (see `observability` / Defender plan docs).

## Usage

```hcl
module "acr" {
  source = "../../modules/acr"

  name                       = "aircloud-dev"
  resource_group_name        = azurerm_resource_group.this.name
  location                   = "westeurope"
  log_analytics_workspace_id = module.observability.workspace_id

  private_endpoint = {
    subnet_id           = module.network.subnet_ids["endpoints"]
    private_dns_zone_id = module.network.private_dns_zone_ids["privatelink.azurecr.io"]
  }

  tags = local.tags
}
```

<!-- BEGIN_TF_DOCS -->
<!-- terraform-docs injects the inputs/outputs table here on pre-commit / CI. -->
<!-- END_TF_DOCS -->
