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


## Requirements

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.21 |

## Providers

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.81.0 |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure region. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace resource ID for diagnostic settings. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Base name used to derive the registry name. Sanitized to 5-50 alphanumerics. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group for the registry. | `string` | n/a | yes |
| <a name="input_private_endpoint"></a> [private\_endpoint](#input\_private\_endpoint) | Optional private endpoint. When set, public network access is disabled. | <pre>object({<br/>    subnet_id           = string<br/>    private_dns_zone_id = string<br/>  })</pre> | `null` | no |
| <a name="input_retention_days"></a> [retention\_days](#input\_retention\_days) | Untagged manifest retention in days (Premium only). | `number` | `30` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | ACR SKU. Premium is required for private endpoints, retention and geo-replication. | `string` | `"Premium"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id) | Principal ID of the registry's system-assigned identity. |
| <a name="output_login_server"></a> [login\_server](#output\_login\_server) | Login server FQDN of the registry. |
| <a name="output_registry_id"></a> [registry\_id](#output\_registry\_id) | Resource ID of the container registry. |
| <a name="output_registry_name"></a> [registry\_name](#output\_registry\_name) | Name of the container registry. |

## Resources

## Resources

| Name | Type |
|------|------|
| [azurerm_container_registry.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
<!-- END_TF_DOCS -->
