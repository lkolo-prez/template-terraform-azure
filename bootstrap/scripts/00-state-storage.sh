#!/usr/bin/env bash
# Bootstrap the Terraform remote-state backend: a hardened Storage Account with a
# blob container, Entra-ID-only auth and versioning. Run ONCE per organization.
#
# Idempotent: re-running converges to the desired state. Requires `az` >= 2.60 and
# an interactive login (`az login`) with Owner/Contributor + User Access Admin on
# the target subscription.
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration (override via environment variables)
# ---------------------------------------------------------------------------
LOCATION="${LOCATION:-westeurope}"
STATE_RG="${STATE_RG:-rg-aircloud-tfstate}"
STATE_SA="${STATE_SA:-staircloudtfstate}"   # 3-24 lowercase alphanumerics, globally unique
STATE_CONTAINER="${STATE_CONTAINER:-tfstate}"
SUBSCRIPTION_ID="${SUBSCRIPTION_ID:?Set SUBSCRIPTION_ID to the target subscription}"

echo ">> Using subscription ${SUBSCRIPTION_ID}"
az account set --subscription "${SUBSCRIPTION_ID}"

echo ">> Resource group ${STATE_RG}"
az group create \
  --name "${STATE_RG}" \
  --location "${LOCATION}" \
  --tags managed-by=bootstrap purpose=terraform-state \
  --output none

echo ">> Storage account ${STATE_SA}"
az storage account create \
  --name "${STATE_SA}" \
  --resource-group "${STATE_RG}" \
  --location "${LOCATION}" \
  --sku Standard_ZRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --allow-shared-key-access false \
  --https-only true \
  --public-network-access Enabled \
  --default-action Allow \
  --tags managed-by=bootstrap purpose=terraform-state \
  --output none

echo ">> Enable blob versioning + soft delete (state safety net)"
az storage account blob-service-properties update \
  --account-name "${STATE_SA}" \
  --resource-group "${STATE_RG}" \
  --enable-versioning true \
  --enable-delete-retention true \
  --delete-retention-days 30 \
  --enable-container-delete-retention true \
  --container-delete-retention-days 30 \
  --output none

echo ">> Grant the current user Storage Blob Data Owner so we can create the container via AAD"
CURRENT_USER_OID="$(az ad signed-in-user show --query id -o tsv)"
SA_ID="$(az storage account show --name "${STATE_SA}" --resource-group "${STATE_RG}" --query id -o tsv)"
az role assignment create \
  --assignee-object-id "${CURRENT_USER_OID}" \
  --assignee-principal-type User \
  --role "Storage Blob Data Owner" \
  --scope "${SA_ID}" \
  --output none || true

echo ">> Waiting for role propagation"
sleep 30

echo ">> Container ${STATE_CONTAINER}"
az storage container create \
  --name "${STATE_CONTAINER}" \
  --account-name "${STATE_SA}" \
  --auth-mode login \
  --output none

cat <<EOF

State backend ready. Reference it in environments/*/backend.tf:

  resource_group_name  = "${STATE_RG}"
  storage_account_name = "${STATE_SA}"
  container_name       = "${STATE_CONTAINER}"
  use_azuread_auth     = true
  use_oidc             = true

Remember to grant each environment's CI identity "Storage Blob Data Contributor"
on the state container (the identity module does this at the RG scope by default;
narrow it to the state container scope for tighter least-privilege).
EOF
