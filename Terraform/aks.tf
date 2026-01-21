# Generate an SSH key stored in terraform state file
resource "tls_private_key" "aks" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  node_resource_group = "aks_nodes"
  dns_prefix          = "aks"
  kubernetes_version  = "1.32.6"

  automatic_upgrade_channel = "patch" # Options: patch, rapid, node-image, stable

  private_cluster_enabled = false
  azure_policy_enabled    = false
  local_account_disabled  = false

  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    interval    = 1
    duration    = 8
    day_of_week = "Sunday"
    start_time  = "23:00"
    utc_offset  = "+02:00"
  }

  maintenance_window_node_os {
    frequency   = "Weekly"
    interval    = 1
    duration    = 8
    day_of_week = "Sunday"
    start_time  = "23:00"
    utc_offset  = "+02:00"
  }

  default_node_pool {
    name                 = "default"
    auto_scaling_enabled = var.aks_auto_scaling_enabled
    node_count           = var.aks_min_node_count
    min_count            = var.aks_auto_scaling_enabled == false ? null : var.aks_min_node_count
    max_count            = var.aks_auto_scaling_enabled == false ? null : var.aks_max_node_count
    vm_size              = "Standard_B2s_v2"
    max_pods             = 50
    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    pod_cidr            = "10.244.0.0/16"
    service_cidr        = "10.96.0.0/12"
    dns_service_ip      = "10.96.0.10"
  }

  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.this.id
    msi_auth_for_monitoring_enabled = true
  }

  linux_profile {
    admin_username = "adminaccount"
    ssh_key {
      key_data = tls_private_key.aks.public_key_openssh
    }
  }

  tags = {
    Environment = "Playground"
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      default_node_pool[0].tags,
      maintenance_window_node_os,
      tags
    ]
  }
}
