# Bootstrap

One-time, manual setup that creates the resources Terraform itself depends on:
the **remote state backend** and the **GitHub OIDC trust**. Run these as a human
with elevated rights *before* the first `terraform apply`; afterwards Terraform
(via the `identity` module) manages per-environment CI identities.

> These scripts are **not** part of any environment's state. Treat them as
> documented runbooks.

## Prerequisites

- `az` CLI >= 2.60, logged in (`az login`) to the right tenant.
- Rights on the target subscription: **Owner** (or Contributor + User Access
  Administrator) and **Application Administrator** in Entra ID.
- `gh` CLI for setting the resulting repository variables.

## Steps

### 1. Create the state Storage Account

```bash
export SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
./scripts/00-state-storage.sh
```

Creates `rg-aircloud-tfstate` / `staircloudtfstate` / container `tfstate` with:

- TLS 1.2 minimum, HTTPS only, **shared-key access disabled** (Entra-ID-only).
- Blob **versioning** + 30-day soft delete (a safety net for state corruption).
- ZRS redundancy.

State locking is handled natively by the azurerm backend using blob leases, so no
separate DynamoDB-style lock table is required.

### 2. Create the GitHub OIDC federated identity

```bash
export SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export GITHUB_ORG="aircloud"
export GITHUB_REPO="template-terraform-azure"
./scripts/01-github-oidc.sh
```

Creates a user-assigned managed identity with federated credentials for
`pull_request` and each environment, then prints the `gh variable set` commands for
`AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`.

### 3. First apply

```bash
gh variable set AZURE_CLIENT_ID       --body "<printed-client-id>"
gh variable set AZURE_TENANT_ID       --body "<printed-tenant-id>"
gh variable set AZURE_SUBSCRIPTION_ID --body "<your-subscription-id>"

# locally, using your own az login, or let CI run terraform-apply.yml
terraform -chdir=environments/dev init
terraform -chdir=environments/dev apply
```

## Replaceable example values

`aircloud`, `staircloudtfstate`, `westeurope` and `rg-aircloud-tfstate` are
**examples**. Override every `*_RG`, `*_SA`, `LOCATION`, `GITHUB_ORG`/`GITHUB_REPO`
via environment variables, and update `environments/*/backend.tf` to match.
