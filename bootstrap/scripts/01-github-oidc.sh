#!/usr/bin/env bash
# Create the Entra ID app registration / managed identity and the GitHub Actions
# federated credentials used to BOOTSTRAP the first apply. After the first apply,
# the `identity` module manages per-environment CI identities in Terraform.
#
# This script uses a user-assigned managed identity (recommended) rather than an
# app registration, because UAMIs support federated credentials directly and need
# no client secret. Run ONCE per organization. Requires `az` with
# "Application Administrator" + "User Access Administrator".
set -euo pipefail

LOCATION="${LOCATION:-westeurope}"
BOOTSTRAP_RG="${BOOTSTRAP_RG:-rg-aircloud-tfstate}"
IDENTITY_NAME="${IDENTITY_NAME:-id-aircloud-tf-bootstrap}"
GITHUB_ORG="${GITHUB_ORG:-aircloud}"
GITHUB_REPO="${GITHUB_REPO:-template-terraform-azure}"
SUBSCRIPTION_ID="${SUBSCRIPTION_ID:?Set SUBSCRIPTION_ID}"
ISSUER="https://token.actions.githubusercontent.com"
AUDIENCE="api://AzureADTokenExchange"

az account set --subscription "${SUBSCRIPTION_ID}"

echo ">> Create user-assigned managed identity ${IDENTITY_NAME}"
az identity create \
  --name "${IDENTITY_NAME}" \
  --resource-group "${BOOTSTRAP_RG}" \
  --location "${LOCATION}" \
  --output none

CLIENT_ID="$(az identity show -n "${IDENTITY_NAME}" -g "${BOOTSTRAP_RG}" --query clientId -o tsv)"
PRINCIPAL_ID="$(az identity show -n "${IDENTITY_NAME}" -g "${BOOTSTRAP_RG}" --query principalId -o tsv)"
TENANT_ID="$(az account show --query tenantId -o tsv)"

# Federated credentials: one per trust context. Add more as needed.
declare -A SUBJECTS=(
  ["pull-request"]="repo:${GITHUB_ORG}/${GITHUB_REPO}:pull_request"
  ["env-dev"]="repo:${GITHUB_ORG}/${GITHUB_REPO}:environment:dev"
  ["env-staging"]="repo:${GITHUB_ORG}/${GITHUB_REPO}:environment:staging"
  ["env-prod"]="repo:${GITHUB_ORG}/${GITHUB_REPO}:environment:prod"
)

for name in "${!SUBJECTS[@]}"; do
  echo ">> Federated credential fic-${name} -> ${SUBJECTS[$name]}"
  az identity federated-credential create \
    --name "fic-${name}" \
    --identity-name "${IDENTITY_NAME}" \
    --resource-group "${BOOTSTRAP_RG}" \
    --issuer "${ISSUER}" \
    --subject "${SUBJECTS[$name]}" \
    --audiences "${AUDIENCE}" \
    --output none
done

echo ">> Grant Contributor + RBAC Administrator on the subscription for the bootstrap apply"
az role assignment create \
  --assignee-object-id "${PRINCIPAL_ID}" \
  --assignee-principal-type ServicePrincipal \
  --role "Contributor" \
  --scope "/subscriptions/${SUBSCRIPTION_ID}" \
  --output none
az role assignment create \
  --assignee-object-id "${PRINCIPAL_ID}" \
  --assignee-principal-type ServicePrincipal \
  --role "Role Based Access Control Administrator" \
  --scope "/subscriptions/${SUBSCRIPTION_ID}" \
  --output none

cat <<EOF

GitHub OIDC bootstrap identity created. Set these as repository / environment
variables (NOT secrets - they are non-sensitive identifiers):

  gh variable set AZURE_CLIENT_ID       --body "${CLIENT_ID}"
  gh variable set AZURE_TENANT_ID       --body "${TENANT_ID}"
  gh variable set AZURE_SUBSCRIPTION_ID --body "${SUBSCRIPTION_ID}"

The workflows use azure/login with these values and 'permissions: id-token: write'.
No client secret is ever created or stored.
EOF
