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
<!-- terraform-docs injects the inputs/outputs table here on pre-commit / CI. -->
<!-- END_TF_DOCS -->
