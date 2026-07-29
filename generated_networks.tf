# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform
resource "azurerm_virtual_network" "vnet" {
  address_space           = ["10.20.0.0/16"]
  location                = azurerm_resource_group.rg.location
  name                    = "CoreServicesVnet"
  resource_group_name     = azurerm_resource_group.rg.name
  }
# 2. Standalone Subnet blocks (The recommended production networking standard)
resource "azurerm_subnet" "database" {
  name                 = "DatabaseSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.20.20.0/24"] 
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.20.0.0/27"] 
}

resource "azurerm_subnet" "public_web" {
  name                 = "PublicWebServiceSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.20.30.0/24"] 
}

resource "azurerm_subnet" "shared_services" {
  name                 = "SharedServicesSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.20.10.0/24"] 
}
resource "azurerm_subnet" "sim_subnet" {
  name                 = "SimulationSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.20.50.0/24"] # A completely fresh range
}

