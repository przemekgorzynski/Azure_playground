resource "azurerm_log_analytics_workspace" "this" {
  name                = "aks-law"
  location            = azurerm_resource_group.monitoring_rg.location
  resource_group_name = azurerm_resource_group.monitoring_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_workspace" "this" {
  name                = "aks-monitor"
  resource_group_name = azurerm_resource_group.monitoring_rg.name
  location            = azurerm_resource_group.monitoring_rg.location
  tags = {
    key = "value"
  }
}

# Custom Data Collection Endpoint
resource "azurerm_monitor_data_collection_endpoint" "dce" {
  name                = "aks-monitor"
  resource_group_name = azurerm_resource_group.monitoring_rg.name
  location            = azurerm_resource_group.monitoring_rg.location
}

resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                        = "aks-monitor"
  resource_group_name         = azurerm_resource_group.monitoring_rg.name
  location                    = azurerm_resource_group.monitoring_rg.location
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce.id

  # Define the destinations
  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.this.id
      name                  = "logAnalyticsWorkspace"
    }
    monitor_account {
      monitor_account_id = azurerm_monitor_workspace.this.id
      name               = "MonitorWorkspace"
    }
  }

  # What streams to collect and where to send them
  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["MonitorWorkspace"]
  }

  description = "DCR for Azure Monitor Metrics Profile (Managed Prometheus)"

  depends_on = [
    azurerm_monitor_data_collection_endpoint.dce
  ]
}

