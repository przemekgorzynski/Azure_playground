terraform {
  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "k8s_rg" {
  name     = "k8s"
  location = "polandcentral"
}