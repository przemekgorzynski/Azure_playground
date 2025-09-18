terraform {
  backend "azurerm" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.44.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "5.10.1"
    }
  }
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

provider "cloudflare" {
  api_token = var.cf_api_token
}

#######################################################
resource "azurerm_resource_group" "k8s_rg" {
  name     = "k8s"
  location = "polandcentral"
}