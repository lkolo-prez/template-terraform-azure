# GitHub Copilot instructions — template-terraform-azure

Repository-wide guidance for GitHub Copilot (chat & code completions). This mirrors
`CLAUDE.md`, `AGENTS.md` and `.cursor/rules/00-project.mdc`.

## Context

Security-first **Azure Infrastructure-as-Code** template. Terraform **>= 1.9** (CI pins
**1.9.8**), provider `hashicorp/azurerm` **~> 4.21** and `hashicorp/azuread` **~> 3.1**.
It provisions private AKS (Workload Identity, Azure RBAC), RBAC Key Vault, private ACR,
identity/OIDC plumbing, and observability. All Azure access is via **GitHub Actions OIDC**;
there are **no long-lived cloud secrets**. Org/prefix `aircloud`, region `westeurope` are
placeholders.

Layout: `modules/{network,aks,identity,keyvault,acr,observability}`,
`environments/{dev,staging,prod}`, `policy/` (tflint/tfsec/checkov/OPA), `bootstrap/`,
`.github/workflows/`.

## Always

- Authenticate to Azure with **OIDC only** (`azure/login`, `ARM_USE_OIDC=true`,
  `ARM_USE_AZUREAD=true`). Treat `AZURE_CLIENT_ID` / `AZURE_TENANT_ID` /
  `AZURE_SUBSCRIPTION_ID` as GitHub **variables** (`vars.*`).
- Keep remote state in Azure Storage with AAD auth (`use_azuread_auth = true`,
  `use_oidc = true`); never reference access keys or connection strings.
- Pin every GitHub Action to a full **40-hex commit SHA** with a `# vX.Y.Z` comment
  (never `@v4` or `@main`); make `step-security/harden-runner` the first step; declare
  least-privilege `permissions`; set `concurrency`.
- Write snake_case Terraform identifiers and document every `variable` and `output`.
- Use **Conventional Commits** for suggested commit/PR titles
  (`feat(aks): ...`, `fix(keyvault): ...`).
- Document any tfsec/checkov/conftest suppression inline with its rule ID and reason.

## Never

- Never generate a `client_secret`, service-principal password, storage access key, or
  connection string.
- Never suggest committing `*.tfstate*` or real `*.tfvars` (only `*.tfvars.example`).
- Never propose applying Terraform from a pull request or bypassing the GitHub Environment
  approval gate (apply happens on merge to `main`).
- Never weaken the posture: private AKS API, RBAC-only Key Vault + purge protection, ACR
  `admin_user = false`, deny-by-default NSGs.

## Commands to suggest (match CI)

```bash
task setup            # pre-commit hooks + tool versions
task format           # terraform fmt -recursive
task validate ENV=dev # init -backend=false + validate
task lint             # tflint --config policy/.tflint.hcl
task security         # tflint + trivy/tfsec + checkov + conftest
task docs             # terraform-docs for all modules
task plan ENV=dev     # init + plan + conftest test (local az login)
```
