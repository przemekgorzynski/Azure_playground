# Read existing DNS Zone from management/hub sub
data "azurerm_private_dns_zone" "blob" {
  provider            = azurerm.mgmt
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = "rg-DnsHub-internal-we"
}

data "azurerm_virtual_network" "vnet-hub" {
  provider              = azurerm.mgmt
  name                  = "vnet-hub-internal-we"
  resource_group_name   = "rg-VnetHub-internal-we"
}

# Read existing PE subnet in mgmt/hub VNet
data "azurerm_subnet" "mgmt_pe_subnet" {
  provider             = azurerm.mgmt
  name                 = "Hub-pe-subnet"
  virtual_network_name = data.azurerm_virtual_network.vnet-hub.name
  resource_group_name  = "rg-VnetHub-internal-we"
}