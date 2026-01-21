resource "azurerm_virtual_network" "k8s_vnet" {
  name                = "k8s-vnet"
  location            = azurerm_resource_group.k8s_rg.location
  resource_group_name = azurerm_resource_group.k8s_rg.name
  address_space       = ["10.0.0.0/16"]
}

# AKS Subnet
resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.k8s_rg.name
  virtual_network_name = azurerm_virtual_network.k8s_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# App Gateway Subnet
resource "azurerm_subnet" "appgw" {
  name                 = "appgw-subnet"
  resource_group_name  = azurerm_resource_group.k8s_rg.name
  virtual_network_name = azurerm_virtual_network.k8s_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Public IP for App Gateway
resource "azurerm_public_ip" "ip_v4" {
  name                = "appgw-public_ip"
  resource_group_name = azurerm_resource_group.k8s_rg.name
  location            = azurerm_resource_group.k8s_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}

output "ipv4" {
  value = azurerm_public_ip.ip_v4.ip_address
}

# Cloudflare DNS AAAA record
resource "cloudflare_dns_record" "cloudflare_ipv4_dns_record" {
  zone_id = "${var.cf_zone_id}"
  name    = "@"
  content = azurerm_public_ip.ip_v4.ip_address
  proxied = false
  type    = "A"
  ttl     = 3600
}