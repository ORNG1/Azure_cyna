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

# Sous-réseau Application Gateway (public)
resource "azurerm_subnet" "appgw_subnet" {
  name                 = "appgw-subnet"
  resource_group_name  = azurerm_resource_group.cyna_rg.name
  virtual_network_name = azurerm_virtual_network.cyna_vnet.name
  address_prefixes     = ["172.16.5.128/25"]
}

# Sous-réseau Admin (privé)
resource "azurerm_subnet" "admin_subnet" {
  name                 = "appgw-subnet"
  resource_group_name  = azurerm_resource_group.cyna_rg.name
  virtual_network_name = azurerm_virtual_network.cyna_vnet.name
  address_prefixes     = ["172.16.20.0/24"]
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
    source_address_prefix      = azurerm_subnet.appgw_subnet.address_prefixes[0]
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
    source_address_prefix      = azurerm_subnet.appgw_subnet.address_prefixes[0]
    destination_address_prefix = "*"
  }
}

# Association NSG au subnet AKS
resource "azurerm_subnet_network_security_group_association" "aks_nsg_assoc" {
  subnet_id                 = azurerm_subnet.saas-aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

# Public IP pour Application Gateway
resource "azurerm_public_ip" "appgw_ip" {
  name                = "appgw-public-ip"
  resource_group_name = azurerm_resource_group.cyna_rg.name
  location            = azurerm_resource_group.cyna_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Azure Application Gateway
resource "azurerm_application_gateway" "cyna_appgw" {
  name                = "cynaAppGateway"
  resource_group_name = azurerm_resource_group.cyna_rg.name
  location            = azurerm_resource_group.cyna_rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ipconfig"
    subnet_id = azurerm_subnet.appgw_subnet.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontendIpConfig"
    public_ip_address_id = azurerm_public_ip.appgw_ip.id
  }

  backend_address_pool {
    name = "aks-backend-pool"
  }

  backend_http_settings {
    name                  = "http-setting"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
  }

  http_listener {
    name                           = "listener-http"
    frontend_ip_configuration_name = "frontendIpConfig"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "listener-http"
    backend_address_pool_name  = "aks-backend-pool"
    backend_http_settings_name = "http-setting"
  }
}
