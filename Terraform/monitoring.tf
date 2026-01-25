resource "azurerm_log_analytics_workspace" "aks_logs" {
  name                = "aks-logs"
  location            = azurerm_resource_group.monitoring_rg.location
  resource_group_name = azurerm_resource_group.monitoring_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_data_collection_rule" "aks_logs" {
  depends_on          = [azurerm_kubernetes_cluster.aks]
  kind                = "Linux"
  location            = azurerm_resource_group.monitoring_rg.location
  name                = "aks-logs-collection-rule"
  resource_group_name = azurerm_resource_group.monitoring_rg.name

  data_flow {
    destinations = ["ciworkspace"]
    streams      = ["Microsoft-ContainerLogV2", "Microsoft-KubeEvents", "Microsoft-KubePodInventory"]
  }
  data_sources {
    extension {
      extension_json = jsonencode({
        dataCollectionSettings = {
          enableContainerLogV2   = true
          interval               = "1m"
          namespaceFilteringMode = "Off"
        }
      })
      extension_name = "ContainerInsights"
      name           = "ContainerInsightsExtension"
      streams        = ["Microsoft-ContainerLogV2", "Microsoft-KubeEvents", "Microsoft-KubePodInventory"]
    }
  }
  destinations {
    log_analytics {
      name                  = "ciworkspace"
      workspace_resource_id = azurerm_log_analytics_workspace.aks_logs.id
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "aks_logs" {
  name                    = "collect-kubernetes-logs"
  target_resource_id      = azurerm_kubernetes_cluster.aks.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.aks_logs.id
}


# ############################
# resource "azurerm_monitor_workspace" "aks_metrics" {
#   name                = "aks-metrics"
#   resource_group_name = azurerm_resource_group.monitoring_rg.name
#   location            = azurerm_resource_group.monitoring_rg.location
#   tags = {
#     key = "value"
#   }
# }
