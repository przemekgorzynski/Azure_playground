terraform {
  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.44.0"
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

resource "azurerm_virtual_network" "k8s_vnet" {
  name                = "k8s-vnet"
  location            = azurerm_resource_group.k8s_rg.location
  resource_group_name = azurerm_resource_group.k8s_rg.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name             = "aks-subnet"
    address_prefixes = ["10.0.1.0/24"]
  }

  subnet {
    name             = "appgw-subnet"
    address_prefixes = ["10.0.2.0/28"]
  }
}