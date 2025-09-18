terraform {
  backend "azurerm" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.44.0"
    }
  }
  required_version = ">= 1.0"
}

#######################################################
provider "azurerm" {
  features {}
}

# Kubernetes provider for namespace
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

#######################################################
resource "azurerm_resource_group" "k8s_rg" {
  name     = "k8s"
  location = "polandcentral"
}

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
    address_prefixes = ["10.0.2.0/28"]
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks"
  location            = azurerm_resource_group.k8s_rg.location
  resource_group_name = azurerm_resource_group.k8s_rg.name
  dns_prefix          = "aks"
  kubernetes_version  = "1.32.6"

  # Enable auto-upgrade via upgrade_channel
  automatic_upgrade_channel  = "patch"  # Options: patch, rapid, node-image, stable

  maintenance_window_auto_upgrade {
    frequency   = "RelativeMonthly"
    interval    = "3"
    duration    = "4"
    week_index   = "First"
    day_of_week = "Sunday"
    start_time  = "23:00"
    utc_offset  = "+02:00"
  }

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
    max_pods   = 50
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

}
