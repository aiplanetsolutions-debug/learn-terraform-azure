# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"

  # 👇 ADD THIS BLOCK TO SHIFT FROM LOCAL TO CLOUD STORAGE
  backend "azurerm" {
    resource_group_name  = "rg-devops-mgmt-prod"
    storage_account_name = "tfstatestorageaiplanet" # Use your unique storage account name here
    container_name       = "tfstate"
    key                  = "network.tfstate" # The name of the file inside the blob
  }
} 
  provider "azurerm" {
  features {}
}

