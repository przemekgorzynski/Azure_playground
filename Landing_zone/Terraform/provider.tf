terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.44.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }

  cloud {
    organization = "pszemazzz"
    workspaces {
      name = "Landing_Zone"
    }
  }
}

provider "azurerm" {
  alias           = "mgmt"
  subscription_id = var.mgmt_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "spoke1"
  subscription_id = var.spoke1_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "spoke2"
  subscription_id = var.spoke2_subscription_id
  features {}
}