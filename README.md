<p align="center">
  <a href="https://aircloud.com.pl"><img src=".github/assets/banner.png" alt="AIRCLOUD: DevOps, cloud and AI engineering" width="100%"></a>
</p>

# template-terraform-azure

**Security-first Azure IaC template: private AKS, Key Vault and ACR, deployed from GitHub Actions with OIDC and no long-lived cloud secrets.**

[![CI](https://github.com/lkolo-prez/template-terraform-azure/actions/workflows/ci.yml/badge.svg)](https://github.com/lkolo-prez/template-terraform-azure/actions/workflows/ci.yml)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](./LICENSE)

Opinionated, security-first **Azure Infrastructure-as-Code** template. It provisions a
private AKS platform (private cluster, Workload Identity, Azure RBAC), a private Key Vault
and Container Registry, identity/OIDC plumbing, and centralized observability — all wired
to **GitHub Actions with OIDC** so there are **no long-lived cloud secrets**.

> This is a **template repository**. The org `aircloud`, registry `ghcr.io/aircloud`,
> Azure prefix `aircloud`, region `westeurope` and the storage account
> `staircloudtfstate` are **examples** — search-and-replace them for your org. Target
> toolchain year: **2026**.

## Why this exists

- **Keyless by design**: every Azure call (plan, apply, drift) authenticates via GitHub
  OIDC federated to a user-assigned managed identity. No client secrets, anywhere.
- **Private by default**: private AKS API, private endpoints for Key Vault and ACR,
  deny-by-default NSGs, RBAC-only Key Vault with purge protection.
- **Supply-chain hardened**: pinned action SHAs, harden-runner egress control, SBOM
  (CycloneDX via Syft), keyless cosign signing, build-provenance attestation, OpenSSF
  Scorecard, Trivy/tfsec/checkov/conftest, gitleaks, CodeQL + Semgrep, dependency review.

## What's inside

```
modules/            Reusable, documented Terraform modules
  network/          VNet, subnets, deny-by-default NSGs, private DNS
  aks/              Private AKS, Azure CNI overlay, Workload Identity, Defender
  identity/         User-assigned identities + GitHub/AKS federated credentials
  keyvault/         RBAC Key Vault, purge protection, private endpoint
  acr/              Private ACR, no admin user, content trust, retention
  observability/    Log Analytics, Azure Monitor action group + alerts
environments/       Per-environment compositions with separate state keys
  dev/ staging/ prod/
policy/             tflint, tfsec, checkov, OPA/conftest guardrails
bootstrap/          One-time az CLI setup: state storage + GitHub OIDC
docs/               Architecture (Mermaid), branch protection, runbooks
.github/workflows/  plan, apply, drift, supply-chain & quality gates
```

## Prerequisites

| Tool | Version |
| --- | --- |
| Terraform | >= 1.9 (CI pins 1.9.8) |
| azurerm provider | ~> 4.21 |
| Azure CLI | >= 2.60 |
| Task (go-task) | >= 3.38 |
| pre-commit | >= 3.7 |

## Usage

Create a new repository from this template (or use **Use this template** on GitHub):

```bash
gh repo create <your-org>/<name> --template lkolo-prez/template-terraform-azure --private --clone
```

```bash
# 0. One-time per org: create remote state + GitHub OIDC (see bootstrap/README.md)
cd bootstrap && SUBSCRIPTION_ID=<sub> ./scripts/00-state-storage.sh
SUBSCRIPTION_ID=<sub> ./scripts/01-github-oidc.sh

# 1. Install tooling + hooks
task setup

# 2. Configure an environment
cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars
$EDITOR environments/dev/terraform.tfvars

# 3. Plan locally (uses your `az login`) or open a PR to let CI plan
task plan ENV=dev

# 4. Apply via CI: merge to main runs terraform-apply with GitHub Environment gates
```

## CI/CD flow

| Trigger | Workflow | What runs |
| --- | --- | --- |
| Pull request | `terraform-plan.yml` | fmt, validate, tflint, tfsec/Trivy, checkov, conftest, infracost, `plan` (OIDC) + sticky PR comment |
| Merge to `main` | `terraform-apply.yml` | `apply` (OIDC) gated by GitHub Environments (required reviewers on staging/prod) |
| Schedule (weekdays) | `drift-detection.yml` | `plan -detailed-exitcode`; opens a drift issue on exit code 2 |
| Push / schedule | `scorecard`, `codeql`, `semgrep`, `gitleaks`, `sbom`, `release-please` | supply-chain & release automation |

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the topology + OIDC trust diagram and
[docs/BRANCH-PROTECTION.md](docs/BRANCH-PROTECTION.md) for the required GitHub Ruleset.

## Security & governance

- Report vulnerabilities privately: see [SECURITY.md](SECURITY.md).
- Contribution workflow + Conventional Commits: see [CONTRIBUTING.md](CONTRIBUTING.md).
- Releases are automated with **release-please** (SemVer); commits are **signed/verified**.

## License

[Apache-2.0](./LICENSE) — Copyright 2026 AirCloud.

---

## Part of the AIRCLOUD golden path

| Repository | What it is |
| --- | --- |
| [00-engineering-standards](https://github.com/lkolo-prez/00-engineering-standards) | Golden paths, security baseline, AI-assistant policy (handbook) |
| **template-terraform-azure** (this repo) | Terraform on Azure: private AKS, Key Vault, ACR, OIDC, policy-as-code |
| [template-gitops-argocd](https://github.com/lkolo-prez/template-gitops-argocd) | Argo CD, Kustomize, Argo Rollouts, Kyverno, External Secrets |
| [template-backend-python](https://github.com/lkolo-prez/template-backend-python) | FastAPI, Python 3.12, uv, ruff, pytest |
| [template-backend-go](https://github.com/lkolo-prez/template-backend-go) | Go 1.23, chi, slog, OpenTelemetry, golangci-lint |
| [template-backend-typescript](https://github.com/lkolo-prez/template-backend-typescript) | Node 22, TypeScript, Fastify 5, Zod, Vitest, pnpm |
| [template-frontend-nextjs](https://github.com/lkolo-prez/template-frontend-nextjs) | Next.js 15, React 19, Tailwind v4, Playwright, Lighthouse CI |
| [.github](https://github.com/lkolo-prez/.github) | Reusable CI/CD workflows and community-health defaults |

Terraform modules for Azure: [AIRCLOUD-PL](https://github.com/AIRCLOUD-PL).

Built and maintained by [AIRCLOUD](https://aircloud.com.pl): DevOps, cloud and AI engineering. Need help adopting the golden path? See [aircloud.com.pl/consulting](https://aircloud.com.pl/consulting).
