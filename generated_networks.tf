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

