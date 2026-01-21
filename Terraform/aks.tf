# resource "azurerm_kubernetes_cluster" "aks" {
#   name                = "aks"
#   location            = azurerm_resource_group.k8s_rg.location
#   resource_group_name = azurerm_resource_group.k8s_rg.name
#   dns_prefix          = "aks"
#   kubernetes_version  = "1.32.6"

#   automatic_upgrade_channel  = "patch"  # Options: patch, rapid, node-image, stable

#   maintenance_window_auto_upgrade {
#     frequency   = "RelativeMonthly"
#     interval    = "3"
#     duration    = "4"
#     week_index   = "First"
#     day_of_week = "Sunday"
#     start_time  = "23:00"
#     utc_offset  = "+02:00"
#   }

#   default_node_pool {
#     name       = "default"
#     node_count = 1
#     vm_size    = "Standard_B2s"
#     max_pods   = 50
#     upgrade_settings {
#       drain_timeout_in_minutes      = 0
#       max_surge                     = "10%"
#       node_soak_duration_in_minutes = 0
#     }
#   }

#   identity {
#     type = "SystemAssigned"
#   }

#   network_profile {
#     network_plugin      = "azure"
#     network_plugin_mode = "overlay"
#     pod_cidr            = "10.244.0.0/16"
#     service_cidr        = "10.96.0.0/12"
#     dns_service_ip      = "10.96.0.10"
#   }

# }


# resource "kubernetes_namespace" "argocd" {
#   metadata {
#     name = "argocd"
#   }
# }