# Policy as Code

Static and policy-based guardrails for the Terraform in this repo.

| Tool | Config | Scope |
| --- | --- | --- |
| **tflint** | `.tflint.hcl` | HCL lint, provider-aware rules, naming, module structure |
| **tfsec** (via Trivy) | `tfsec.yaml` | Built-in Azure misconfiguration rules |
| **checkov** | `.checkov.yaml` | Cloud security graph checks, SARIF for code scanning |
| **conftest / OPA** | `rego/*.rego` | Org-specific guardrails on the plan JSON |

## Running locally

```bash
task security           # runs the whole suite (see Taskfile.yml)

# or individually:
tflint --recursive --config "$PWD/policy/.tflint.hcl"
trivy config --config policy/tfsec.yaml .
checkov --config-file policy/.checkov.yaml -d .

terraform -chdir=environments/dev plan -out=plan.tfplan
terraform -chdir=environments/dev show -json plan.tfplan > plan.json
conftest test --policy policy/rego plan.json
conftest verify --policy policy/rego   # run the rego unit tests
```

All four tools also run in `terraform-plan.yml` on every pull request. Suppressions
must be documented inline with the rule ID and justification.
