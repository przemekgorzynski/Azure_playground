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
    address_prefixes = ["10.0.2.0/24"]
  }
}

# Public IP for App Gateway
resource "azurerm_public_ip" "ip_v6" {
  name                = "appgw-pip"
  resource_group_name = azurerm_resource_group.k8s_rg.name
  location            = azurerm_resource_group.k8s_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv6"
}

output "ipv6" {
  value = azurerm_public_ip.ip_v6.ip_address
}

# Cloudflare DNS AAAA record
resource "cloudflare_dns_record" "cloudflare_ipv6_dns_record" {
  zone_id = "${var.cf_zone_id}"
  name    = "@"
  content = azurerm_public_ip.ip_v6.ip_address
  proxied = true
  type    = "AAAA"
  ttl     = 1
}