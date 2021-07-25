terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.68.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "helm" {
  kubernetes {
    host = azurerm_kubernetes_cluster.cscms-services.kube_config.0.host
    client_key = base64decode(azurerm_kubernetes_cluster.cscms-services.kube_config.0.client_certificate) 
    client_certificate  =  base64decode(azurerm_kubernetes_cluster.cscms-services.kube_config.0.client_key)
    cluster_ca_certificate  =  base64decode(azurerm_kubernetes_cluster.cscms-services.kube_config.0.client_key)
  }
}

data "azurerm_resource_group" "cscms_rg" {
  name = "cscms.me"
}

resource "azurerm_kubernetes_cluster" "cscms-services" {
  name                = "cscms-services"
  location            = data.azurerm_resource_group.cscms_rg.location
  resource_group_name = data.azurerm_resource_group.cscms_rg.name
  dns_prefix = "cscms"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2a_v4"
    enable_auto_scaling = false
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "helm_release" "ingress_nginx" {
  name = "ingress-nginx"
  namespace = "ingress-nginx"
  create_namespace = true
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
}