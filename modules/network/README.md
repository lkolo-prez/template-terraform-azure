# Module: `network`

Creates a hub/spoke-friendly virtual network with:

- A VNet with one or more subnets.
- One **deny-by-default** NSG per subnet (explicit `DenyAllInbound` rule at priority 4096) associated to its subnet.
- Optional NSG diagnostic settings to a Log Analytics workspace.
- Optional private DNS zones (Key Vault, ACR by default) linked to the VNet for private endpoints.

## Usage

```hcl
module "network" {
  source = "../../modules/network"

  name                = "aircloud-dev"
  resource_group_name = azurerm_resource_group.this.name
  location            = "westeurope"
  vnet_address_space  = ["10.20.0.0/16"]

  subnets = {
    aks = {
      address_prefixes = ["10.20.1.0/22"]
    }
    endpoints = {
      address_prefixes                  = ["10.20.8.0/24"]
      private_endpoint_network_policies = "Disabled"
    }
  }

  log_analytics_workspace_id = module.observability.workspace_id
  tags                       = local.tags
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
| <a name="input_location"></a> [location](#input\_location) | Azure region (e.g. "westeurope"). | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Base name used to derive resource names (e.g. "aircloud-dev"). | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group to create the network resources in. | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Map of subnets to create. Key is the subnet logical name.<br/>`service_endpoints` and `delegation` are optional. | <pre>map(object({<br/>    address_prefixes  = list(string)<br/>    service_endpoints = optional(list(string), [])<br/>    delegation = optional(object({<br/>      name         = string<br/>      service_name = string<br/>      actions      = list(string)<br/>    }))<br/>    private_endpoint_network_policies = optional(string, "Enabled")<br/>  }))</pre> | n/a | yes |
| <a name="input_enable_private_dns"></a> [enable\_private\_dns](#input\_enable\_private\_dns) | Create a private DNS zone for private endpoints and link it to the VNet. | `bool` | `true` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace resource ID for NSG diagnostic settings. If null, diagnostics are not created. | `string` | `null` | no |
| <a name="input_private_dns_zone_names"></a> [private\_dns\_zone\_names](#input\_private\_dns\_zone\_names) | Private DNS zones to create and link (e.g. for Key Vault, ACR, AKS API). | `list(string)` | <pre>[<br/>  "privatelink.vaultcore.azure.net",<br/>  "privatelink.azurecr.io"<br/>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources. | `map(string)` | `{}` | no |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | Address space for the virtual network. | `list(string)` | <pre>[<br/>  "10.20.0.0/16"<br/>]</pre> | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nsg_ids"></a> [nsg\_ids](#output\_nsg\_ids) | Map of subnet logical name to NSG resource ID. |
| <a name="output_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#output\_private\_dns\_zone\_ids) | Map of private DNS zone name to resource ID. |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Map of subnet logical name to subnet resource ID. |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | Resource ID of the virtual network. |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | Name of the virtual network. |

## Resources

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.deny_all_inbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_private_dns_zone.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
<!-- END_TF_DOCS -->
