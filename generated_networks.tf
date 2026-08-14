# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform
resource "azurerm_virtual_network" "vnetCoreServices" {
  address_space           = ["10.20.0.0/16"]
  location                = var.eastus_location
  name                    = "CoreServicesVnet"
  resource_group_name     = azurerm_resource_group.rg.name
  }
# 2. Standalone Subnet blocks (The recommended production networking standard)
resource "azurerm_subnet" "DatabaseSubnet" {
  name                 = "DatabaseSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnetCoreServices.name
  address_prefixes     = ["10.20.20.0/24"] 
}

resource "azurerm_subnet" "GatewaySubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnetCoreServices.name
  address_prefixes     = ["10.20.0.0/27"] 
}

resource "azurerm_subnet" "PublicWebServiceSubnet" {
  name                 = "PublicWebServiceSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnetCoreServices.name
  address_prefixes     = ["10.20.30.0/24"] 
}

resource "azurerm_subnet" "SharedServicesSubnet" {
  name                 = "SharedServicesSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnetCoreServices.name
  address_prefixes     = ["10.20.10.0/24"] 
}

resource "azurerm_virtual_network" "vnetResearch" {
  name                    = "ResearchVnet"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = var.seasia_location
  address_space           = ["10.40.0.0/16"]
}

resource "azurerm_subnet" "ResearchSystemSubnet" {
  name                 = "ResearchSystemSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnetResearch.name
  address_prefixes     = ["10.40.0.0/24"] 
}

resource "azurerm_virtual_network" "vnetManufacturing" {
  name                    = "ManufacturingVnet"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = var.eastus2_location
  address_space           = ["10.30.0.0/16"]
}

resource "azurerm_subnet" "ManufacturingSystemSubnet" {
  name                 = "ManufacturingSystemSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnetManufacturing.name
  address_prefixes     = ["10.30.10.0/24"] 
}
resource "azurerm_subnet" "GatewaySubnetManufacturing" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnetManufacturing.name
  address_prefixes     = ["10.30.0.0/27"] 
}
resource "azurerm_subnet" "SensorSubnet1" {
  name                 = "SensorSubnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnetManufacturing.name
  address_prefixes     = ["10.30.20.0/24"] 
}
resource "azurerm_subnet" "SensorSubnet2" {
  name                 = "SensorSubnet2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnetManufacturing.name
  address_prefixes     = ["10.30.21.0/24"] 
}
resource "azurerm_subnet" "SensorSubnet3" {
  name                 = "SensorSubnet3"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnetManufacturing.name
  address_prefixes     = ["10.30.22.0/24"] 
}

# ==============================================================================
# 1. PEERING DIRECTION: CoreServicesVnet -> ManufacturingVnet
# ==============================================================================
##resource "azurerm_virtual_network_peering" "core_to_manufacturing" {
  ##name                         = "CoreServicesVnet-to-ManufacturingVnet"
  ##resource_group_name          = azurerm_resource_group.rg.name
  
  # The source VNet initiating the peering link
  ##virtual_network_name         = azurerm_virtual_network.vnetCoreServices.name 
  
  # The target remote VNet destination ID
  ##remote_virtual_network_id    = azurerm_virtual_network.vnetManufacturing.id

  # Remote virtual network peering settings (Enabled)
  ##allow_virtual_network_access = true
  ##allow_forwarded_traffic      = true

  # Gateway transit settings (Leave false/disabled unless configuring a Hub-Spoke VPN)
  ##allow_gateway_transit        = false
  ##use_remote_gateways          = false
##}

# ==============================================================================
# 2. PEERING DIRECTION: ManufacturingVnet -> CoreServicesVnet
# ==============================================================================
##resource "azurerm_virtual_network_peering" "manufacturing_to_core" {
  ##name                         = "ManufacturingVnet-to-CoreServicesVnet"
  ##resource_group_name          = azurerm_resource_group.rg.name
  
  # The source VNet initiating the return link
  ##virtual_network_name         = azurerm_virtual_network.vnetManufacturing.name 
  
  # The target remote VNet destination ID
  ##remote_virtual_network_id    = azurerm_virtual_network.vnetCoreServices.id

  # Local virtual network peering settings (Enabled)
  ##allow_virtual_network_access = true
  ##allow_forwarded_traffic      = true

  ##allow_gateway_transit        = false
  ##use_remote_gateways          = false
##}

# =========================================================================
# TASK 6: CoreServicesVnet Gateway Infrastructure
# =========================================================================

# Create the standard Public IP required by the CoreServices gateway
resource "azurerm_public_ip" "pip_coreservices_gw" {
  name                = "CoreServicesVnetGateway-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.eastus_location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Deploy the CoreServices Virtual Network Gateway
resource "azurerm_virtual_network_gateway" "coreservices_gw" {
  name                = "CoreServicesVnetGateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.eastus_location

  type     = "Vpn"
  vpn_type = "RouteBased" # Required for VpnGw1AZ SKU

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1AZ"
  generation    = "Generation1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.pip_coreservices_gw.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.GatewaySubnet.id # Reference from your previous code
  }
}


# =========================================================================
# TASK 7: ManufacturingVnet Gateway Infrastructure
# =========================================================================

# Create the standard Public IP required by the Manufacturing gateway
resource "azurerm_public_ip" "pip_manufacturing_gw" {
  name                = "ManufacturingVnetGateway-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "var.eastus2_location" # 
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Deploy the Manufacturing Virtual Network Gateway
resource "azurerm_virtual_network_gateway" "manufacturing_gw" {
  name                = "ManufacturingVnetGateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "var.eastus2_location" # 

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1AZ"
  generation    = "Generation1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.pip_manufacturing_gw.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.GatewaySubnetManufacturing.id # 
}
}

# =========================================================================
# TASK 8: Connection - CoreServicesVnet to ManufacturingVnet
# =========================================================================

resource "azurerm_virtual_network_gateway_connection" "coreservices_to_manufacturing" {
  name                = "CoreServicesGW-to-ManufacturingGW"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.eastus_location

  type                               = "Vnet2Vnet"
  virtual_network_gateway_id         = azurerm_virtual_network_gateway.coreservices_gw.id
  peer_virtual_network_gateway_id    = azurerm_virtual_network_gateway.manufacturing_gw.id

  shared_key = "abc123"
}


# =========================================================================
# TASK 9: Connection - ManufacturingVnet to CoreServicesVnet
# =========================================================================

resource "azurerm_virtual_network_gateway_connection" "manufacturing_to_coreservices" {
  name                = "ManufacturingGW-to-CoreServicesGW"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.eastus2_location

  type                               = "Vnet2Vnet"
  virtual_network_gateway_id         = azurerm_virtual_network_gateway.manufacturing_gw.id
  peer_virtual_network_gateway_id    = azurerm_virtual_network_gateway.coreservices_gw.id

  shared_key = "abc123"
}