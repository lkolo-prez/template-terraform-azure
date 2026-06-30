<!--
Title MUST follow Conventional Commits, e.g.:
  feat(aks): add cilium network policy support
  fix(keyvault): enable purge protection by default
-->

## Summary

<!-- What does this change and why? Link the issue: Closes #NNN -->

## Type of change

- [ ] feat — new capability
- [ ] fix — bug fix
- [ ] refactor — no behavior change
- [ ] docs
- [ ] ci / build
- [ ] chore

## Affected areas

- [ ] modules/network
- [ ] modules/aks
- [ ] modules/identity
- [ ] modules/keyvault
- [ ] modules/acr
- [ ] modules/observability
- [ ] environments/{dev,staging,prod}
- [ ] policy
- [ ] CI/CD

## Plan / blast radius

<!-- Paste the relevant, REDACTED portion of `terraform plan`. The CI bot also
     posts a sticky plan comment. Call out any destroy/replace operations. -->

## Checklist

- [ ] `task lint` and `task format` pass locally (or pre-commit ran).
- [ ] `terraform validate` passes for every touched environment.
- [ ] tflint, tfsec/Trivy, checkov and conftest pass (no new suppressions, or suppressions are documented inline).
- [ ] terraform-docs is regenerated for any changed module.
- [ ] No secrets, subscription IDs or tenant IDs are committed.
- [ ] Commits are signed (verified) and follow Conventional Commits.
- [ ] Docs / runbooks updated where behavior changed.
