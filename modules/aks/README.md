# Module: `aks`

Private, hardened Azure Kubernetes Service cluster:

- **Private cluster** (no public API endpoint), `local_account_disabled = true`.
- **Azure CNI overlay** with Cilium network policy (data plane), Azure RBAC for Kubernetes authorization, Entra ID integration.
- **Workload Identity** + OIDC issuer enabled (federate workloads via the `identity` module, never store secrets in pods).
- **Microsoft Defender for Containers**, Azure Policy add-on, image cleaner.
- Autoscaling system node pool across 3 availability zones, ephemeral OS disks.
- Diagnostic settings (api-server, audit-admin, guard, metrics) shipped to Log Analytics.

> The cluster uses a **user-assigned** control-plane identity so callers can pre-create
> least-privilege role assignments (e.g. `Network Contributor` on the VNet) via the `identity` module.

## Usage

```hcl
module "aks" {
  source = "../../modules/aks"

  name                       = "aircloud-dev"
  resource_group_name        = azurerm_resource_group.this.name
  location                   = "westeurope"
  subnet_id                  = module.network.subnet_ids["aks"]
  log_analytics_workspace_id = module.observability.workspace_id
  admin_group_object_ids     = [var.platform_admins_group_id]
  tags                       = local.tags
}
```

After apply, grant the kubelet identity `AcrPull` on the registry (done in the env composition):

```hcl
resource "azurerm_role_assignment" "acr_pull" {
  scope                = module.acr.registry_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_identity_object_id
}
```

<!-- BEGIN_TF_DOCS -->
<!-- terraform-docs injects the inputs/outputs table here on pre-commit / CI. -->
<!-- END_TF_DOCS -->
