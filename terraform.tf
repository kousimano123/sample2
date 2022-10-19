terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
}
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false

    }
  }
  subscription_id = "438e0da6-95dd-4dae-b961-fa073a5095e4"
  tenant_id = "a4f73c75-f427-47f3-a349-8c00b8f5c292"
  client_id = "3dcf360f-e4ab-4913-91bf-9d2dc2a0a5e4"
  client_secret = "9b3e0d2f-09e7-43a7-869b-94a340fd389b"
}
resource "azurerm_resource_group" "rg" {
  name     = "test"
  location = "East US"
}
resource "azurerm_virtual_network" "main"{
  name = "aks-vnet-27032150"
  address_space = [ "10.224.0.0/12" ]
  location = azurerm_resource_group.rgmain.location
  resource_group_name = azurerm_resource_group.rgmain.name
}

resource "azurerm_subnet" "internal"{
  name = "aks-subnet"
  resource_group_name = azurerm_resource_group.rgmain.name
  virtual_network_name = azurerm_resource_group.main.name
  address_prefixes = [ "10.224.0.0/12"]
}
resource "azurerm_container_registry" "container19" {
  name                = "container19"
  resource_group_name = "test"
  location            = "East US"
  sku                 = "Premium"
  admin_enabled       = false
  georeplications {
    location                = "East US"
    zone_redundancy_enabled = true
    tags                    = {}
  }
}
resource "azurerm_kubernetes_cluster" "example" {
  name                = "firstcluster"
  location            = "East US"
  resource_group_name = "test"
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.example.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw
  sensitive = true
}