terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm]
    }
  }
}

resource "azurerm_subnet" "this" {
  name                              = var.subnet_name
  resource_group_name               = var.resource_group
  virtual_network_name              = var.vnet_name
  address_prefixes                  = [var.subnet_prefix]
  private_endpoint_network_policies = var.private_endpoint_network_policies
}