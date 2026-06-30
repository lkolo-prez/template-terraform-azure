# Contributing

Thanks for contributing to `template-terraform-azure`. This repo follows trunk-based
development with short-lived branches and automated quality gates.

## Ground rules

- Be respectful — see [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
- Never commit secrets, subscription IDs, tenant IDs or real `terraform.tfvars`.
- All commits must be **signed (verified)** and follow **Conventional Commits**.

## Development setup

```bash
task setup          # installs pre-commit hooks and verifies tool versions
pre-commit run -a   # run all hooks against the whole tree
```

Required tools: Terraform >= 1.9, Azure CLI, tflint, tfsec/Trivy, checkov,
terraform-docs, conftest, gitleaks, pre-commit, Task. The `.devcontainer`
provides all of them.

## Branch & commit conventions

- Branch from `main`: `feat/<area>-<slug>`, `fix/<area>-<slug>`, `docs/<slug>`.
- **Conventional Commits** drive release-please and the changelog:

  ```
  feat(aks): enable cilium dataplane network policy
  fix(keyvault): default purge protection to enabled
  docs(architecture): add OIDC trust diagram
  ci(actions): pin scorecard action to v2.4.0
  ```

- A breaking change uses `!` and a footer:

  ```
  feat(network)!: rename `subnets` map key schema

  BREAKING CHANGE: callers must move `cidr` to `address_prefixes`.
  ```

## Signed commits

Verified commits are **required** by the ruleset. Configure once:

```bash
# SSH signing (simplest)
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
# then add the key under GitHub → Settings → SSH and GPG keys → "Signing Key"
```

## Pull request checklist

1. `task lint && task format && task test` pass locally (or rely on pre-commit + CI).
2. `terraform validate` passes for each touched environment.
3. tflint, tfsec/Trivy, checkov and conftest are green; any suppression is documented inline.
4. `terraform-docs` is regenerated for changed modules (CI fails on drift).
5. The PR description includes the (redacted) plan summary; CI also posts a sticky plan comment.
6. At least **2 approvals** including the relevant CODEOWNERS.

## How a change ships

```
PR ──► terraform-plan (fmt/validate/lint/scan/plan + sticky comment)
   ──► review (2 approvals, CODEOWNERS, signed, linear history)
   ──► merge to main
        ├─► terraform-apply (OIDC, env gates on staging/prod)
        └─► release-please opens/updates the release PR; merging it tags a SemVer release,
            builds the SBOM, signs + attests the bundle.
```

## Reporting bugs / requesting features

Use the issue templates. For **security issues**, follow [SECURITY.md](SECURITY.md) —
do not open a public issue.
