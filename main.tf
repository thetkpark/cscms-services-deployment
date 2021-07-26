terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.68.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.3.2"
    }
  }
}

provider "azurerm" {
  features {}
}
provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.cscms-services.kube_config.0.host
    client_key             = base64decode(azurerm_kubernetes_cluster.cscms-services.kube_config.0.client_key)
    client_certificate     = base64decode(azurerm_kubernetes_cluster.cscms-services.kube_config.0.client_certificate)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.cscms-services.kube_config.0.cluster_ca_certificate)
  }
}
provider "kubernetes" {
  host = azurerm_kubernetes_cluster.cscms-services.kube_config.0.host
  client_key             = base64decode(azurerm_kubernetes_cluster.cscms-services.kube_config.0.client_key)
  client_certificate     = base64decode(azurerm_kubernetes_cluster.cscms-services.kube_config.0.client_certificate)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.cscms-services.kube_config.0.cluster_ca_certificate)
}

data "azurerm_resource_group" "cscms_rg" {
  name = "cscms.me"
}

resource "azurerm_kubernetes_cluster" "cscms-services" {
  name                = "cscms-services"
  location            = data.azurerm_resource_group.cscms_rg.location
  resource_group_name = data.azurerm_resource_group.cscms_rg.name
  dns_prefix          = "cscms"

  default_node_pool {
    name                = "default"
    node_count          = 1
    vm_size             = "Standard_D2a_v4"
    enable_auto_scaling = false
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  depends_on = [
    azurerm_kubernetes_cluster.cscms-services
  ]

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }
  set {
    name = "controller.metrics.serviceMonitor.enabled"
    value = "true"
  }
  set {
    name  = "controller.podAnnotations.prometheus\\.io/scrape"
    value = "true"
  }
  set {
    name  = "controller.podAnnotations.prometheus\\.io/port"
    value = "10254"
  }
}

resource "helm_release" "prometheus_stack" {
  name = "prometheus"
  namespace = "monitoring"
  create_namespace = true
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "kube-prometheus-stack"

  set {
    name = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
    value = "false"
  }
  depends_on = [
    azurerm_kubernetes_cluster.cscms-services
  ]
}

resource "kubernetes_service" "grafana_service" {
  metadata {
    name = "grafana-srv"
  }
  spec {
    type = "ExternalName"
    external_name = "prometheus-grafana.monitoring.svc.cluster.local"
    port {
      port = 80
    }
  }
  depends_on = [
    azurerm_kubernetes_cluster.cscms-services,
    helm_release.prometheus_stack
  ]
}