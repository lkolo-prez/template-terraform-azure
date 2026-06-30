# Remote state in Azure Storage with native blob locking.
# Authentication uses GitHub OIDC (use_azuread_auth + use_oidc); no access keys.
# The storage account is bootstrapped once via ../../bootstrap.
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-aircloud-tfstate"
    storage_account_name = "staircloudtfstate"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    use_azuread_auth     = true
    use_oidc             = true
  }
}
