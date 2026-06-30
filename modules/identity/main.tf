resource "azurerm_user_assigned_identity" "this" {
  name                = "id-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Federated credentials for GitHub Actions OIDC. No client secret is ever issued:
# GitHub mints a short-lived token, Entra ID validates issuer + subject + audience.
resource "azurerm_federated_identity_credential" "github" {
  for_each = var.github_oidc_credentials

  name                = "fic-gh-${each.key}"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.this.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.github_oidc_issuer
  subject             = each.value.subject
}

# Federated credentials for AKS Workload Identity (Kubernetes service accounts).
resource "azurerm_federated_identity_credential" "workload" {
  for_each = var.workload_identity_credentials

  name                = "fic-wi-${each.key}"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.this.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = each.value.issuer
  subject             = each.value.subject
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}
