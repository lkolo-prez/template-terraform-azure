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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.21 |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure region. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace resource ID for diagnostic settings. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Base name used to derive the Key Vault name. Will be sanitized to 3-24 alphanumerics. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group for the Key Vault. | `string` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Entra ID tenant ID. | `string` | n/a | yes |
| <a name="input_private_endpoint"></a> [private\_endpoint](#input\_private\_endpoint) | Optional private endpoint. When set, the vault disables public network access<br/>and is reachable only through the endpoint in the given subnet. | <pre>object({<br/>    subnet_id           = string<br/>    private_dns_zone_id = string<br/>  })</pre> | `null` | no |
| <a name="input_rbac_admins"></a> [rbac\_admins](#input\_rbac\_admins) | Map of logical name to principal object ID granted "Key Vault Administrator". | `map(string)` | `{}` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | Key Vault SKU. | `string` | `"standard"` | no |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | Soft-delete retention in days (7-90). | `number` | `90` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | Resource ID of the Key Vault. |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | Name of the Key Vault. |
| <a name="output_key_vault_uri"></a> [key\_vault\_uri](#output\_key\_vault\_uri) | URI of the Key Vault. |

## Resources

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.admins](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
<!-- END_TF_DOCS -->
