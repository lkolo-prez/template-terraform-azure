data "azurerm_client_config" "current" {}

locals {
  name = "${var.name_prefix}-${var.environment}"

  tags = merge({
    environment = var.environment
    managed-by  = "terraform"
    repository  = var.github_repository
    owner       = "platform-team"
    criticality = "high"
  }, var.tags)
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name}"
  location = var.location
  tags     = local.tags
}

module "observability" {
  source = "../../modules/observability"

  name                = local.name
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  retention_in_days   = 365

  action_group_email_receivers = {
    platform_oncall = var.alert_email
  }

  tags = local.tags
}

module "network" {
  source = "../../modules/network"

  name                = local.name
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  vnet_address_space  = ["10.40.0.0/16"]

  subnets = {
    aks = {
      address_prefixes = ["10.40.1.0/22"]
    }
    endpoints = {
      address_prefixes                  = ["10.40.8.0/24"]
      private_endpoint_network_policies = "Disabled"
    }
  }

  log_analytics_workspace_id = module.observability.workspace_id
  tags                       = local.tags
}

module "keyvault" {
  source = "../../modules/keyvault"

  name                       = local.name
  resource_group_name        = azurerm_resource_group.this.name
  location                   = var.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  log_analytics_workspace_id = module.observability.workspace_id

  private_endpoint = {
    subnet_id           = module.network.subnet_ids["endpoints"]
    private_dns_zone_id = module.network.private_dns_zone_ids["privatelink.vaultcore.azure.net"]
  }

  rbac_admins = {
    platform = var.platform_admins_group_id
  }

  tags = local.tags
}

module "acr" {
  source = "../../modules/acr"

  name                       = local.name
  resource_group_name        = azurerm_resource_group.this.name
  location                   = var.location
  retention_days             = 90
  log_analytics_workspace_id = module.observability.workspace_id

  private_endpoint = {
    subnet_id           = module.network.subnet_ids["endpoints"]
    private_dns_zone_id = module.network.private_dns_zone_ids["privatelink.azurecr.io"]
  }

  tags = local.tags
}

module "aks" {
  source = "../../modules/aks"

  name                       = local.name
  resource_group_name        = azurerm_resource_group.this.name
  location                   = var.location
  subnet_id                  = module.network.subnet_ids["aks"]
  log_analytics_workspace_id = module.observability.workspace_id
  admin_group_object_ids     = [var.platform_admins_group_id]

  system_node_pool = {
    vm_size   = "Standard_D8ds_v5"
    min_count = 3
    max_count = 9
  }

  tags = local.tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.registry_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_identity_object_id
}

module "ci_identity" {
  source = "../../modules/identity"

  name                = "${local.name}-ci"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location

  github_oidc_credentials = {
    # prod plans and applies both run against the protected "prod" environment,
    # which requires manual approval from required reviewers (see GitHub Environments).
    apply = {
      subject = "repo:${var.github_repository}:environment:${var.environment}"
    }
  }

  role_assignments = {
    rg_contributor = {
      role_definition_name = "Contributor"
      scope                = azurerm_resource_group.this.id
    }
    state_blob = {
      role_definition_name = "Storage Blob Data Contributor"
      scope                = azurerm_resource_group.this.id
    }
  }

  tags = local.tags
}
