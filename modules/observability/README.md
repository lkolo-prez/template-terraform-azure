# Module: `observability`

Central logging + alerting foundation consumed by the other modules' diagnostic settings.

- **Log Analytics workspace** (`PerGB2018`), Entra-only auth (`local_authentication_disabled = true`), configurable retention + daily ingestion cap.
- **Action group** with email receivers (common alert schema).
- Example **scheduled query alert** on Azure Activity failures (extend with your KQL).

This module is created **first** in each environment so its `workspace_id` can be passed to
`network`, `aks`, `keyvault` and `acr` for diagnostics.

## Usage

```hcl
module "observability" {
  source = "../../modules/observability"

  name                = "aircloud-dev"
  resource_group_name = azurerm_resource_group.this.name
  location            = "westeurope"
  retention_in_days   = 90

  action_group_email_receivers = {
    platform_oncall = "platform-oncall@aircloud.com.pl"
  }

  tags = local.tags
}
```

<!-- BEGIN_TF_DOCS -->
<!-- terraform-docs injects the inputs/outputs table here on pre-commit / CI. -->
<!-- END_TF_DOCS -->
