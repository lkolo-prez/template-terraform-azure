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
| <a name="input_name"></a> [name](#input\_name) | Base name used to derive workspace and alert resource names. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group for observability resources. | `string` | n/a | yes |
| <a name="input_action_group_email_receivers"></a> [action\_group\_email\_receivers](#input\_action\_group\_email\_receivers) | Map of logical name to email address for the alert action group. | `map(string)` | `{}` | no |
| <a name="input_daily_quota_gb"></a> [daily\_quota\_gb](#input\_daily\_quota\_gb) | Daily ingestion cap in GB. -1 means unlimited. | `number` | `-1` | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Log Analytics data retention in days (30-730). | `number` | `90` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_action_group_id"></a> [action\_group\_id](#output\_action\_group\_id) | Resource ID of the monitor action group. |
| <a name="output_workspace_customer_id"></a> [workspace\_customer\_id](#output\_workspace\_customer\_id) | Workspace (customer) GUID used by agents. |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | Resource ID of the Log Analytics workspace. |
| <a name="output_workspace_name"></a> [workspace\_name](#output\_workspace\_name) | Name of the Log Analytics workspace. |

## Resources

## Resources

| Name | Type |
|------|------|
| [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_action_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) | resource |
| [azurerm_monitor_scheduled_query_rules_alert_v2.activity_errors](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2) | resource |
<!-- END_TF_DOCS -->
