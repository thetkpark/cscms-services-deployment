terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.68.0"
    }
  }
}

provider "azurerm" {
  features {}
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
    vm_size    = "Standard_B2s"
    enable_auto_scaling = false
  }

  identity {
    type = "SystemAssigned"
  }
}


output "kube_config" {
  value = azurerm_kubernetes_cluster.cscms-services.kube_config_raw
  sensitive = true
}