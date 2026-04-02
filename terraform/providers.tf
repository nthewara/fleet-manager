terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }

  # Configure your own backend
  # backend "azurerm" {
  #   resource_group_name  = "<your-rg>"
  #   storage_account_name = "<your-storage>"
  #   container_name       = "tfstate"
  #   key                  = "fleet-manager-demo.tfstate"
  #   use_azuread_auth     = true
  # }
}

provider "azurerm" {
  features {}
  subscription_id     = var.subscription_id
  storage_use_azuread = true
}
