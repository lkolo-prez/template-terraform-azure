#!/usr/bin/env bash
# Devcontainer post-create: install the remaining toolchain that has no devcontainer
# feature, then wire up pre-commit hooks. Terraform, tflint, Azure CLI, GitHub CLI,
# Python and Go are provided by devcontainer features (see devcontainer.json).
set -euo pipefail

echo ">> Installing Task (go-task)"
sh -c "$(curl -fsSL https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

echo ">> Installing terraform-docs"
TFDOCS_VERSION="0.19.0"
curl -fsSL "https://terraform-docs.io/dl/v${TFDOCS_VERSION}/terraform-docs-v${TFDOCS_VERSION}-linux-amd64.tar.gz" \
  | tar -xz terraform-docs
sudo install -m 0755 terraform-docs /usr/local/bin/terraform-docs && rm -f terraform-docs

echo ">> Installing conftest"
CONFTEST_VERSION="0.56.0"
curl -fsSL "https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz" \
  | tar -xz conftest
sudo install -m 0755 conftest /usr/local/bin/conftest && rm -f conftest

echo ">> Installing gitleaks"
GITLEAKS_VERSION="8.21.2"
curl -fsSL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" \
  | tar -xz gitleaks
sudo install -m 0755 gitleaks /usr/local/bin/gitleaks && rm -f gitleaks

echo ">> Installing Python tooling (pre-commit, checkov)"
pipx install pre-commit || pip install --user pre-commit
pipx install checkov || pip install --user checkov

echo ">> Installing Trivy (tfsec engine)"
curl -fsSL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
  | sudo sh -s -- -b /usr/local/bin

echo ">> Installing pre-commit hooks"
pre-commit install --install-hooks || true

echo ">> Done. Authenticate with 'az login' (OIDC is used in CI; no secrets needed)."
