# providers.tf
terraform {
  cloud { 
    organization = "pszemazzz" 
    workspaces { 
      name = "exercise1" 
    } 
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.44.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.0"
    }
  }
}

# Subscription mgmnt
provider "azurerm" {
  alias           = "mgmt"
  subscription_id = "498ff788-a1a1-4860-a97f-3ee90d4fab61"
  features {}
}

# Subscription  spoke1
provider "azurerm" {
  alias           = "spoke1"
  subscription_id = "4d0f2de4-fd44-4c94-ab45-5d8f2d2b3720"
  features {}
}

# Subscription spoke2 
provider "azurerm" {
  alias           = "spoke2"
  subscription_id = "fa2293f5-402a-453a-a8da-0870c83a6122"
  features {}
}