# Remote state in Azure Storage with native blob locking.
#
# Authentication uses GitHub OIDC (use_azuread_auth + use_oidc); no access keys or
# connection strings are stored. The storage account is bootstrapped once via
# ../../bootstrap (see bootstrap/README.md).
#
# `use_azuread_auth = true` makes the backend talk to the blob using Entra ID, so the
# CI identity needs "Storage Blob Data Contributor" on the state container.
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-aircloud-tfstate"
    storage_account_name = "staircloudtfstate"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
    use_azuread_auth     = true
    use_oidc             = true
  }
}
