terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group
  address_space       = [var.address_prefix]
  tags                = var.tags
}