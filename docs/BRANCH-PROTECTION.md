# Branch protection (GitHub Rulesets)

This repo relies on a GitHub **Ruleset** (the modern replacement for classic branch
protection) on `main`. CODEOWNERS, signed commits, linear history and the required status
checks referenced elsewhere in this repo are all enforced here. Configure it once per repo.

> Rulesets live under **Settings → Rules → Rulesets → New branch ruleset**. They can also
> be managed as code via the GitHub API / Terraform `github_repository_ruleset`.

## Recommended ruleset for `main`

**Target:** Branch — default branch (`main`).
**Enforcement:** Active.
**Bypass list:** none (or a tightly scoped break-glass team only).

Enable these rules:

| Rule | Setting |
| --- | --- |
| Restrict deletions | on |
| Restrict force pushes (block non-fast-forward) | on |
| Require linear history | on |
| Require signed commits | on |
| Require a pull request before merging | on |
| → Required approvals | **2** |
| → Dismiss stale approvals on new commits | on |
| → Require review from Code Owners | on (see [.github/CODEOWNERS](../.github/CODEOWNERS)) |
| → Require approval of the most recent push | on |
| Require status checks to pass | on |
| → Require branches to be up to date before merging | on |
| Require conversation resolution before merging | on |

### Required status checks

Add the checks that gate a merge. These names come from the workflow job names in
`.github/workflows/`:

- `pre-commit (reusable)` and `actionlint` and `terraform-docs up to date` — from `ci.yml`
- `validate (dev)`, `validate (staging)`, `validate (prod)` — from `terraform-plan.yml`
  (these run fmt/validate/tflint/tfsec/checkov/conftest and the OIDC `terraform plan`)
- `Secret scan` — from `gitleaks.yml`
- `Dependency review` — from `dependency-review.yml`
- `Semgrep` — from `semgrep.yml`
- `CodeQL (actions)`, `CodeQL (javascript-typescript)` — from `codeql.yml`

> Only checks that actually run on pull requests can be marked required. `terraform-apply`,
> `scorecard`, `sbom` and `release-please` run on push/schedule, not on PRs, so they are
> **not** required checks.

## Environment protection (apply gating)

Applies are gated by **GitHub Environments**, not by the branch ruleset. Under
**Settings → Environments**, create `dev`, `staging`, `prod` and configure:

| Environment | Protection |
| --- | --- |
| `dev` | (optional) no required reviewers |
| `staging` | **Required reviewers**: `@aircloud/platform-engineering`; optional wait timer |
| `prod` | **Required reviewers**: `@aircloud/platform-engineering` + `@aircloud/platform-leads`; wait timer recommended |

`terraform-apply.yml` declares `environment: ${{ matrix.environment }}`, so the apply job
pauses for approval before touching staging/prod. Store `AZURE_CLIENT_ID`,
`AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `PLATFORM_ADMINS_GROUP_ID` and `ALERT_EMAIL`
as **environment variables** (not secrets) — they are non-sensitive identifiers used by
OIDC login.

## Other repo settings

- **Actions → General**: allow only actions pinned by SHA; enable "Require approval for all
  outside collaborators". The `permissions` default for the `GITHUB_TOKEN` is read-only
  (every workflow declares its own least-privilege `permissions`).
- **Code security**: enable Dependabot alerts/updates (see `.github/dependabot.yml`),
  secret scanning + push protection, and CodeQL (default setup is replaced by `codeql.yml`).
- **General → Pull Requests**: allow squash merge only; "Always suggest updating PR
  branches"; auto-delete head branches.
