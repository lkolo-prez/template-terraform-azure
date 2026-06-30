# CLAUDE.md

Guidance for Claude Code (and other AI agents) working in **template-terraform-azure** —
a security-first Azure Infrastructure-as-Code template. Read this before proposing or
making any change. The same rules live in `AGENTS.md`, `.github/copilot-instructions.md`
and `.cursor/rules/00-project.mdc`; keep all four in sync if you change one.

## What this repo is

Opinionated Terraform for a private AKS platform on Azure: private cluster + Workload
Identity, RBAC Key Vault, private ACR, identity/OIDC plumbing, and centralized
observability. Everything is wired to **GitHub Actions with OIDC** so there are **no
long-lived cloud secrets**.

- Terraform **>= 1.9** (CI pins **1.9.8**); provider `hashicorp/azurerm` **~> 4.21**,
  `hashicorp/azuread` **~> 3.1**.
- Example org `aircloud`, Azure prefix `aircloud`, region `westeurope`. These are
  search-and-replace placeholders.

## Layout

```
modules/{network,aks,identity,keyvault,acr,observability}   reusable modules
environments/{dev,staging,prod}                              per-env compositions, separate state keys
policy/                                                      tflint, tfsec, checkov, OPA/conftest (rego)
bootstrap/                                                   one-time az CLI: state storage + GitHub OIDC
docs/                                                        architecture, branch protection
.github/workflows/                                           plan, apply, drift, supply-chain gates
```

## Golden rules (do not violate)

1. **No secrets, ever.** Azure auth is GitHub OIDC federated to a user-assigned managed
   identity (`azure/login` + `ARM_USE_OIDC=true`, `ARM_USE_AZUREAD=true`). Never add a
   `client_secret`, service-principal password, storage access key, or connection string.
   `AZURE_CLIENT_ID` / `AZURE_TENANT_ID` / `AZURE_SUBSCRIPTION_ID` are **GitHub variables**
   (`vars.*`), not secrets — they are non-sensitive identifiers.
2. **Never commit state or real tfvars.** `*.tfstate*` and `*.tfvars` (except `*.tfvars.example`)
   are gitignored. Remote state lives in Azure Storage (`rg-aircloud-tfstate` /
   `staircloudtfstate` / container `tfstate`) with AAD auth + OIDC, no access keys. Do not
   add backend keys or print state.
3. **Plan on PR, apply on merge.** `terraform-plan.yml` runs on PRs; `terraform-apply.yml`
   applies on merge to `main`, gated by **GitHub Environments** (required reviewers on
   staging/prod). Do not add a path that applies from a PR or bypasses the env gate.
4. **Pin every GitHub Action to a full 40-hex commit SHA** with a `# vX.Y.Z` comment.
   Never use `@v4` / `@main`. Dependabot/Renovate rewrite the SHA + comment together.
5. **Keep workflows hardened.** `step-security/harden-runner` is the first step,
   top-level `permissions` are least-privilege (`contents: read`), jobs elevate only what
   they need (`id-token: write` for OIDC), and `concurrency` is set.
6. **Document every policy suppression inline** with its rule ID and justification
   (see `policy/.checkov.yaml`, `policy/tfsec.yaml`).

## Commands (run these — they match CI)

```bash
task setup                 # install pre-commit hooks + verify tool versions
task format                # terraform fmt -recursive
task fmt-check             # terraform fmt -check -recursive  (CI gate)
task validate ENV=dev      # terraform init -backend=false && validate
task lint                  # tflint --recursive --config policy/.tflint.hcl
task security              # tflint + trivy/tfsec + checkov + conftest verify
task docs                  # regenerate terraform-docs for every module
task plan ENV=dev          # init + plan + conftest test on plan.json (uses az login)
pre-commit run -a          # run all hooks across the tree
```

Underlying tools if you need them directly: `terraform fmt/validate/plan/apply`,
`tflint --config policy/.tflint.hcl`, `trivy config --config policy/tfsec.yaml .`,
`checkov --config-file policy/.checkov.yaml -d .`, `conftest test/verify --policy policy/rego`,
`terraform-docs --config .terraform-docs.yml ./modules/<name>`.

## Conventions

- **Conventional Commits** drive release-please: `feat(aks): ...`, `fix(keyvault): ...`,
  `docs(...)`, `ci(...)`, `feat(network)!: ...` + `BREAKING CHANGE:` footer.
- Branches: `feat/<area>-<slug>`, `fix/<area>-<slug>`, `docs/<slug>` from `main`.
- Commits must be **signed/verified** (enforced by the ruleset; see
  `docs/BRANCH-PROTECTION.md`).
- snake_case Terraform identifiers; each variable/output documented (tflint enforces it);
  run `task docs` after changing a module's variables/outputs or CI fails on the diff.
- Module versions are pinned in each `versions.tf`; do not loosen constraints without a
  documented reason.

## When you edit

- Touching `modules/*` → update that module's `README.md` via `task docs`, and consider
  all three environments that consume it.
- Touching `policy/*` → add/adjust a `rego` test in `policy/rego/terraform_test.rego`.
- Touching `.github/workflows/*` → keep SHA pins, harden-runner, least-privilege perms and
  concurrency; `actionlint` runs in CI.
- Never weaken: private AKS API, RBAC-only Key Vault, purge protection, ACR `admin_user`
  disabled, deny-by-default NSGs.
