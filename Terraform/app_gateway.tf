# locals {
#   backend_address_pool_name      = "${azurerm_virtual_network.k8s_vnet.name}-beap"
#   frontend_port_name             = "${azurerm_virtual_network.k8s_vnet.name}-feport"
#   frontend_ip_configuration_name = "${azurerm_virtual_network.k8s_vnet.name}-feip"
#   http_setting_name              = "${azurerm_virtual_network.k8s_vnet.name}-be-htst"
#   listener_name                  = "${azurerm_virtual_network.k8s_vnet.name}-httplstn"
#   request_routing_rule_name      = "${azurerm_virtual_network.k8s_vnet.name}-rqrt"
#   redirect_configuration_name    = "${azurerm_virtual_network.k8s_vnet.name}-rdrcfg"
# }

# resource "azurerm_application_gateway" "app_gtw" {
#   name                = "k8s_vnet-appgateway"
#   resource_group_name = azurerm_resource_group.k8s_rg.name
#   location            = azurerm_resource_group.k8s_rg.location

#   sku {
#     name     = "WAF_v2"
#     tier     = "WAF_v2"
#     capacity = 1
#   }

#   waf_configuration {
#     enabled = false   # <-- disables WAF, still uses WAF_v2 SKU
#     firewall_mode = "Detection"
#     rule_set_type    = "OWASP"
#     rule_set_version = "3.2"
#   }

#   gateway_ip_configuration {
#     name      = "my-gateway-ip-configuration"
#     subnet_id = azurerm_subnet.appgw.id
#   }

#   frontend_port {
#     name = local.frontend_port_name
#     port = 80
#   }

#   frontend_ip_configuration {
#     name                 = local.frontend_ip_configuration_name
#     public_ip_address_id = azurerm_public_ip.ip_v6.id
#   }

#   backend_address_pool {
#     name = local.backend_address_pool_name
#   }

#   backend_http_settings {
#     name                  = local.http_setting_name
#     cookie_based_affinity = "Disabled"
#     port                  = 80
#     protocol              = "Http"
#     request_timeout       = 60
#   }

#   http_listener {
#     name                           = local.listener_name
#     frontend_ip_configuration_name = local.frontend_ip_configuration_name
#     frontend_port_name             = local.frontend_port_name
#     protocol                       = "Http"
#   }

#   request_routing_rule {
#     name                       = local.request_routing_rule_name
#     priority                   = 9
#     rule_type                  = "Basic"
#     http_listener_name         = local.listener_name
#     backend_address_pool_name  = local.backend_address_pool_name
#     backend_http_settings_name = local.http_setting_name
#   }
# }