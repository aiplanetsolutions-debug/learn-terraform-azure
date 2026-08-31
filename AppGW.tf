# ==============================================================================
# LAB RESOURCE GROUP & NEW VNET CORE ARCHITECTURE
# ==============================================================================

resource "azurerm_resource_group" "contoso_rg" {
  name     = "Contoso2ResourceGroup"
  location = "East US"
}

resource "azurerm_virtual_network" "contoso_vnet" {
  name                = "ContosoVNet"
  location            = azurerm_resource_group.contoso_rg.location
  resource_group_name = azurerm_resource_group.contoso_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "ag_subnet" {
  name                 = "AGSubnet"
  resource_group_name  = azurerm_resource_group.contoso_rg.name
  virtual_network_name = azurerm_virtual_network.contoso_vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "backend_server_subnet" {
  name                 = "BackendSubnet"
  resource_group_name  = azurerm_resource_group.contoso_rg.name
  virtual_network_name = azurerm_virtual_network.contoso_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ==============================================================================
# FRONTEND PUBLIC IP MAPPING
# ==============================================================================

resource "azurerm_public_ip" "ag_pip" {
  name                = "AGPublicIPAddress"
  location            = azurerm_resource_group.contoso_rg.location
  resource_group_name = azurerm_resource_group.contoso_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# ==============================================================================
# APPLICATION GATEWAY CONFIGURATION (STANDARD V2 TIER)
# ==============================================================================

resource "azurerm_application_gateway" "contoso_app_gateway" {
  name                = "ContosoAppGateway"
  location            = azurerm_resource_group.contoso_rg.location
  resource_group_name = azurerm_resource_group.contoso_rg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }
  
  # 👇 ADD THIS BLOCK TO SATISFY AZURE'S RETIRED TLS VALIDATION MANDATE
  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101" # Strictly enforces TLS 1.2 & 1.3 compliance
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.ag_subnet.id
  }

  frontend_port {
    name = "frontendPort80"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.ag_pip.id
  }

  backend_address_pool {
    name = "BackendPool"
  }

  backend_http_settings {
    name                  = "HTTPSetting"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "Listener"
    frontend_ip_configuration_name = "LoadBalancerFrontEnd"
    frontend_port_name             = "frontendPort80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                        = "RoutingRule"
    rule_type                   = "Basic"
    priority                    = 100
    http_listener_name          = "Listener"
    backend_address_pool_name   = "BackendPool"
    backend_http_settings_name  = "HTTPSetting"
  }
}

# Step 2 of a two step process
# ==============================================================================
# TASK 3: ASSOCIATE BACKEND VM NICS TO APPLICATION GATEWAY BACKEND POOL
# ==============================================================================

# 1. Associate BackendVM1-nic to the BackendPool
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "vm1_ag_assoc" {
  network_interface_id    = azurerm_network_interface.backend_vm1_nic.id # References your BackendVM1-nic resource
  ip_configuration_name   = "ipconfig1"                                  # Matches the internal IP config name of your NIC
  backend_address_pool_id = tolist(azurerm_application_gateway.contoso_app_gateway.backend_address_pool)[0].id
}

# 2. Associate BackendVM2-nic to the BackendPool
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "vm2_ag_assoc" {
  network_interface_id    = azurerm_network_interface.backend_vm2_nic.id # References your BackendVM2-nic resource
  ip_configuration_name   = "ipconfig1"                                  # Matches the internal IP config name of your NIC
  backend_address_pool_id = tolist(azurerm_application_gateway.contoso_app_gateway.backend_address_pool)[0].id
}

# ==============================================================================
# MISSING DEPENDENCY: NETWORK INTERFACES FOR BACKEND SERVERS
# ==============================================================================

resource "azurerm_network_interface" "backend_vm1_nic" {
  name                = "BackendVM1-nic" # Matches your task target string name
  location            = azurerm_resource_group.contoso_rg.location
  resource_group_name = azurerm_resource_group.contoso_rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.backend_server_subnet.id # Binds to BackendSubnet
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "backend_vm2_nic" {
  name                = "BackendVM2-nic" # Matches your task target string name
  location            = azurerm_resource_group.contoso_rg.location
  resource_group_name = azurerm_resource_group.contoso_rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.backend_server_subnet.id # Binds to BackendSubnet
    private_ip_address_allocation = "Dynamic"
  }
}