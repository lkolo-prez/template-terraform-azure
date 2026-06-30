# AGENTS.md

Instructions for AI coding agents (Codex, and any tool that reads the
[agents.md](https://agents.md) open standard) working in **template-terraform-azure**.
This file mirrors `CLAUDE.md`, `.github/copilot-instructions.md` and
`.cursor/rules/00-project.mdc` — keep them consistent.

## Project

Security-first **Azure Infrastructure-as-Code** template: private AKS (Workload Identity,
Azure RBAC), RBAC Key Vault, private ACR, identity/OIDC plumbing, centralized
observability. All Azure access is via **GitHub Actions OIDC** — **no long-lived cloud
secrets**.

- Terraform **>= 1.9** (CI pins **1.9.8**); `hashicorp/azurerm` **~> 4.21**,
  `hashicorp/azuread` **~> 3.1**.
- Placeholders: org/prefix `aircloud`, region `westeurope`.

## Project structure

- `modules/{network,aks,identity,keyvault,acr,observability}` — reusable, documented modules.
- `environments/{dev,staging,prod}` — compositions; each has its own remote-state key.
- `policy/` — `tflint` (`.tflint.hcl`), `tfsec` (`tfsec.yaml`), `checkov` (`.checkov.yaml`),
  OPA/`conftest` (`rego/`).
- `bootstrap/` — one-time `az` scripts: remote state storage + GitHub OIDC identity.
- `.github/workflows/` — `terraform-plan`, `terraform-apply`, `drift-detection`, plus
  supply-chain/quality gates (codeql, semgrep, gitleaks, scorecard, sbom, dependency-review,
  release-please, ci).

## Setup & commands

This repo uses **Task** (go-task). Commands below match what CI runs.

```bash
task setup                 # install pre-commit hooks + verify tool versions
task format                # terraform fmt -recursive
task fmt-check             # terraform fmt -check -recursive
task validate ENV=dev      # terraform init -backend=false && terraform validate
task lint                  # tflint --recursive --config policy/.tflint.hcl
task security              # tflint + trivy(tfsec) + checkov + conftest
task docs                  # terraform-docs for all modules
task plan ENV=dev          # init + plan + conftest test (uses local az login)
pre-commit run -a          # all pre-commit hooks
```

Raw tools: `terraform fmt|validate|plan|apply`, `tflint --config policy/.tflint.hcl`,
`trivy config --config policy/tfsec.yaml .`, `checkov --config-file policy/.checkov.yaml -d .`,
`conftest test|verify --policy policy/rego`,
`terraform-docs --config .terraform-docs.yml ./modules/<name>`.

## Hard constraints

- **Keyless auth only.** GitHub OIDC → user-assigned managed identity. Never introduce a
  client secret, SP password, storage key, or connection string. `AZURE_CLIENT_ID`,
  `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` are GitHub **variables** (`vars.*`), not secrets.
- **Never commit** `*.tfstate*` or real `*.tfvars` (only `*.tfvars.example`). State is
  remote in Azure Storage with AAD + OIDC (`use_azuread_auth = true`, `use_oidc = true`).
- **Plan on PR, apply on merge** with GitHub Environment approvals on staging/prod. Do not
  add a way to apply from a PR or to skip the environment gate.
- **All GitHub Actions pinned to a 40-hex SHA** with a `# vX.Y.Z` comment; harden-runner is
  the first step; permissions are least-privilege; `concurrency` is set.
- Document every tfsec/checkov/conftest suppression inline with its rule ID and reason.
- Never weaken the security posture: private AKS API, RBAC-only Key Vault + purge
  protection, ACR `admin_user = false`, deny-by-default NSGs, content trust/retention.

## Conventions

- **Conventional Commits** (`feat`, `fix`, `docs`, `ci`, `build`, `refactor`, `chore`;
  `!` + `BREAKING CHANGE:` for breaks) — they drive release-please.
- Branch from `main`: `feat/<area>-<slug>`, `fix/<area>-<slug>`, `docs/<slug>`.
- Commits are **signed/verified** (ruleset-enforced; see `docs/BRANCH-PROTECTION.md`).
- snake_case identifiers; document every variable/output; run `task docs` after module
  variable/output changes (CI fails on a docs diff).

## Validation before you finish

1. `task fmt-check` and `task validate ENV=<each touched env>` pass.
2. `task lint` and `task security` are green (or any new suppression is documented inline).
3. `task docs` produced no diff for changed modules.
4. No secrets, subscription/tenant IDs, state or real tfvars are added.
5. Workflow edits keep SHA pins, harden-runner, least-privilege perms and concurrency.
