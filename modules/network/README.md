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
<!-- terraform-docs injects the inputs/outputs table here on pre-commit / CI. -->
<!-- END_TF_DOCS -->
