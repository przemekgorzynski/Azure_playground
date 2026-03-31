terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm]
    }
  }
}

resource "azurerm_virtual_network_peering" "this" {
  name                      = var.peering_name
  resource_group_name       = var.local_vnet_rg
  virtual_network_name      = var.local_vnet_name
  remote_virtual_network_id = var.remote_vnet_id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}