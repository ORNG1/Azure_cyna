resource "azurerm_kubernetes_cluster" "cyna_aks" {
  name                = "cyna-aks-cluster"
  location            = azurerm_resource_group.cyna_rg.location
  resource_group_name = azurerm_resource_group.cyna_rg.name
  dns_prefix          = "cynadevops"

  default_node_pool {
  name           = "default"
  node_count     = 2
  vm_size        = "Standard_A2_v2"  # → 2 vCPU, 4 Go RAM (compatible Free Tier)
  vnet_subnet_id = azurerm_subnet.saas-aks_subnet.id
}

  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = "cynaadmin"

    ssh_key {
      key_data = tls_private_key.cyna_ssh_key.public_key_openssh
    }
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    environment = "dev"
  }
}
