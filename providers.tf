terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70"
    }
  }

  # Configuración del Backend Remoto Seguro
  backend "azurerm" {
    resource_group_name  = "rg-tf-state"
    storage_account_name = "satf1122"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}