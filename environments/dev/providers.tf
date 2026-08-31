terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.3"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.1"
    }
  }
}

# OIDC: in CI, ARM_USE_OIDC=true plus ARM_CLIENT_ID/ARM_TENANT_ID/ARM_SUBSCRIPTION_ID
# (set by azure/login) authenticate the provider without any client secret.
provider "azurerm" {
  use_oidc        = true
  subscription_id = var.subscription_id

  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

provider "azuread" {
  use_oidc = true
}
