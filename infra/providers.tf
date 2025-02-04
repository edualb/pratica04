terraform {
  required_version = ">= 0.12"

  backend "local" {}

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~>2.5"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}