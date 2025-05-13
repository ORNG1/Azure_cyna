# Resource Group
resource "azurerm_resource_group" "cyna_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "cyna_vnet" {
  name                = "cynaVnet"
  address_space       = ["172.16.0.0/16"]
  location            = azurerm_resource_group.cyna_rg.location
  resource_group_name = azurerm_resource_group.cyna_rg.name
}

# Sous-réseau AKS (privé)
resource "azurerm_subnet" "saas-aks_subnet" {
  name                 = "saas-aks-subnet"
  resource_group_name  = azurerm_resource_group.cyna_rg.name
  virtual_network_name = azurerm_virtual_network.cyna_vnet.name
  address_prefixes     = ["172.16.5.0/25"]
}

# Sous-réseau Admin (privé)
resource "azurerm_subnet" "admin_subnet" {
  name                 = "admin-subnet"
  resource_group_name  = azurerm_resource_group.cyna_rg.name
  virtual_network_name = azurerm_virtual_network.cyna_vnet.name
  address_prefixes     = ["172.16.5.128/25"]
}

# NSG pour subnet AKS
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "aks-nsg"
  location            = azurerm_resource_group.cyna_rg.location
  resource_group_name = azurerm_resource_group.cyna_rg.name

  security_rule {
    name                       = "AllowHTTP-from-AppGW"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS-from-AppGW"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Association NSG au subnet AKS
resource "azurerm_subnet_network_security_group_association" "aks_nsg_assoc" {
  subnet_id                 = azurerm_subnet.saas-aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}
