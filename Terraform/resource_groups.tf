resource "azurerm_resource_group" "vnet_rg" {
  name     = "vnet"
  location = "polandcentral"
}

resource "azurerm_resource_group" "aks_rg" {
  name     = "aks"
  location = "polandcentral"
}

resource "azurerm_resource_group" "monitoring_rg" {
  name     = "monitoring"
  location = "polandcentral"
}