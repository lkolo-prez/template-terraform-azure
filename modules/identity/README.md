# Module: `identity`

Creates a user-assigned managed identity (UAMI) and wires up **federated credentials**
so neither GitHub Actions nor in-cluster workloads ever hold a long-lived secret.

- **GitHub Actions OIDC**: `azurerm_federated_identity_credential` whose subject matches the
  workflow context (e.g. `repo:aircloud/template-terraform-azure:environment:prod`). The
  workflow uses `azure/login` with `client-id`/`tenant-id`/`subscription-id` and `id-token: write`.
- **AKS Workload Identity**: federated credential whose issuer is the cluster OIDC issuer and
  whose subject is `system:serviceaccount:<ns>:<sa>`.
- **Least-privilege role assignments**: an explicit, named map of `(role, scope)` pairs.

## Usage

```hcl
module "ci_identity" {
  source = "../../modules/identity"

  name                = "aircloud-dev-ci"
  resource_group_name = azurerm_resource_group.this.name
  location            = "westeurope"

  github_oidc_credentials = {
    plan = {
      subject = "repo:aircloud/template-terraform-azure:pull_request"
    }
    apply = {
      subject = "repo:aircloud/template-terraform-azure:environment:dev"
    }
  }

  role_assignments = {
    rg_contributor = {
      role_definition_name = "Contributor"
      scope                = azurerm_resource_group.this.id
    }
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
| <a name="input_name"></a> [name](#input\_name) | Base name used to derive identity names (e.g. "aircloud-dev"). | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group for the managed identities. | `string` | n/a | yes |
| <a name="input_github_oidc_credentials"></a> [github\_oidc\_credentials](#input\_github\_oidc\_credentials) | Federated credentials for GitHub Actions OIDC. Key is a logical name.<br/>`subject` is the full OIDC subject, e.g.<br/>"repo:aircloud/template-terraform-azure:environment:prod" or<br/>"repo:aircloud/template-terraform-azure:ref:refs/heads/main". | <pre>map(object({<br/>    subject = string<br/>  }))</pre> | `{}` | no |
| <a name="input_github_oidc_issuer"></a> [github\_oidc\_issuer](#input\_github\_oidc\_issuer) | OIDC issuer for GitHub Actions tokens. | `string` | `"https://token.actions.githubusercontent.com"` | no |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | Least-privilege role assignments granted to the created identity.<br/>Key is a logical name; `scope` is the target resource ID. | <pre>map(object({<br/>    role_definition_name = string<br/>    scope                = string<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources. | `map(string)` | `{}` | no |
| <a name="input_workload_identity_credentials"></a> [workload\_identity\_credentials](#input\_workload\_identity\_credentials) | Federated credentials for AKS Workload Identity. Key is a logical name.<br/>`issuer` is the AKS OIDC issuer URL, `subject` is<br/>"system:serviceaccount:<namespace>:<serviceaccount>". | <pre>map(object({<br/>    issuer  = string<br/>    subject = string<br/>  }))</pre> | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | Client ID of the managed identity (used in azure/login and AZURE\_CLIENT\_ID). |
| <a name="output_identity_id"></a> [identity\_id](#output\_identity\_id) | Resource ID of the user-assigned managed identity. |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | Principal (object) ID of the managed identity, for role assignments. |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | Tenant ID associated with the identity. |

## Resources

## Resources

| Name | Type |
|------|------|
| [azurerm_federated_identity_credential.github](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_federated_identity_credential.workload](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
<!-- END_TF_DOCS -->
