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

resource "azurerm_managed_disk" "blog_ghost_data_disk" {
  name = "blog-ghost-data-disk"
  location = data.azurerm_resource_group.cscms_rg.location
  resource_group_name = data.azurerm_resource_group.cscms_rg.name
  storage_account_type = "Standard_LRS"
  create_option = "Empty"
  disk_size_gb = "2"
}

output "blog_ghost_data_disk_uri" {
  value = azurerm_managed_disk.blog_ghost_data_disk.source_uri
}