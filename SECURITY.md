# Security Policy

## Reporting a vulnerability

**Do not open a public issue, pull request, or discussion for security problems.**

Report privately via GitHub Security Advisories:
<https://github.com/aircloud/template-terraform-azure/security/advisories/new>

If you cannot use GitHub Advisories, email **security@aircloud.com.pl** with a description,
affected paths/modules, and reproduction steps. Please **do not** include any secrets,
subscription IDs, tenant IDs, or live `terraform plan`/state output in your report.

### What to expect

| Stage | Target |
| --- | --- |
| Acknowledgement | within **2 business days** |
| Triage & severity assessment | within **5 business days** |
| Fix or mitigation plan | depends on severity; Critical/High are prioritized |
| Coordinated disclosure | after a fix ships or by mutual agreement |

We follow coordinated disclosure and will credit reporters who wish to be acknowledged.

## Supported versions

This is a template repository released with SemVer tags via release-please. Security fixes
target the **latest released tag** and `main`. Pin to a released tag and track Dependabot/
Renovate updates.

## Security model of this template

- **Keyless cloud auth.** Every Azure operation (plan, apply, drift) authenticates through
  **GitHub OIDC** federated to a user-assigned managed identity (`azure/login`,
  `ARM_USE_OIDC=true`, `ARM_USE_AZUREAD=true`). There are **no client secrets, SP passwords,
  storage access keys, or connection strings** anywhere in the repo or CI.
  `AZURE_CLIENT_ID` / `AZURE_TENANT_ID` / `AZURE_SUBSCRIPTION_ID` are non-sensitive GitHub
  **variables**, not secrets.
- **Remote state hardening.** State lives in an Azure Storage account with Entra-ID-only
  auth (`use_azuread_auth = true`), shared-key access disabled, TLS 1.2+, public blob
  access off, blob versioning + soft-delete. `*.tfstate*` and real `*.tfvars` are gitignored
  and must never be committed.
- **Private-by-default infrastructure.** Private AKS API server, RBAC-only Key Vault with
  purge protection, private ACR with `admin_user` disabled, deny-by-default NSGs.
- **Plan on PR / apply on merge.** Applies run only on merge to `main` and are gated by
  **GitHub Environments** with required reviewers on staging and prod.
- **Supply-chain controls.** All GitHub Actions are pinned to full commit SHAs,
  `step-security/harden-runner` enforces egress policy, and CI runs gitleaks, CodeQL,
  Semgrep, Trivy/tfsec, checkov, conftest, OpenSSF Scorecard, dependency review, SBOM
  (CycloneDX) generation, keyless cosign signing and build-provenance attestation.

## Handling a leaked secret

If a credential is ever committed: rotate/revoke it immediately at the source (Entra ID,
Azure, GitHub), then remove it from history. Because auth is keyless by design, the most
likely "secrets" are accidental tfvars or state — purge them and rotate any identifiers
they exposed. gitleaks runs on every push, PR, and nightly to catch regressions.
