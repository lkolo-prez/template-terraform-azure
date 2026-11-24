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
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace resource ID for Container Insights and diagnostics. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Base name used to derive the cluster name (e.g. "aircloud-dev"). | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group for the AKS cluster. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Resource ID of the subnet that hosts the system node pool. | `string` | n/a | yes |
| <a name="input_admin_group_object_ids"></a> [admin\_group\_object\_ids](#input\_admin\_group\_object\_ids) | Entra ID group object IDs granted cluster-admin via Azure RBAC. | `list(string)` | `[]` | no |
| <a name="input_dns_prefix"></a> [dns\_prefix](#input\_dns\_prefix) | DNS prefix for the cluster. Defaults to the cluster name. | `string` | `null` | no |
| <a name="input_dns_service_ip"></a> [dns\_service\_ip](#input\_dns\_service\_ip) | IP for kube-dns within service\_cidr. | `string` | `"172.16.0.10"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes minor version (e.g. "1.30"). Leave null to use the AKS default. | `string` | `null` | no |
| <a name="input_network_policy"></a> [network\_policy](#input\_network\_policy) | Network policy engine: "cilium", "azure" or "calico". | `string` | `"cilium"` | no |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | CIDR for Kubernetes services (must not overlap the VNet). | `string` | `"172.16.0.0/16"` | no |
| <a name="input_system_node_pool"></a> [system\_node\_pool](#input\_system\_node\_pool) | System node pool configuration. | <pre>object({<br/>    vm_size              = optional(string, "Standard_D4ds_v5")<br/>    min_count            = optional(number, 2)<br/>    max_count            = optional(number, 5)<br/>    os_disk_size_gb      = optional(number, 64)<br/>    only_critical_addons = optional(bool, true)<br/>    zones                = optional(list(string), ["1", "2", "3"])<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | Resource ID of the AKS cluster. |
| <a name="output_cluster_identity_principal_id"></a> [cluster\_identity\_principal\_id](#output\_cluster\_identity\_principal\_id) | Principal ID of the cluster control-plane user-assigned identity. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the AKS cluster. |
| <a name="output_kubelet_identity_object_id"></a> [kubelet\_identity\_object\_id](#output\_kubelet\_identity\_object\_id) | Object ID of the kubelet (node) managed identity - grant AcrPull on the registry. |
| <a name="output_node_resource_group"></a> [node\_resource\_group](#output\_node\_resource\_group) | Auto-managed node resource group name. |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | OIDC issuer URL used to configure Workload Identity federated credentials. |

## Resources

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_monitor_diagnostic_setting.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_user_assigned_identity.cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
<!-- END_TF_DOCS -->
