resource "azurerm_private_dns_zone" "contoso_dns" {
  name                = "contoso.com"
  resource_group_name = azurerm_resource_group.rg.name
}

# 2. Link the VNet and Enable Auto-Registration 
resource "azurerm_private_dns_zone_virtual_network_link" "coreservices_link" {
  name                  = "CoreServicesVnetLink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.contoso_dns.name
  
  # Fetches your existing central VNet ID 
  # Note: Ensure "azurerm_virtual_network.core_vnet" matches your actual local VNet resource block name
  virtual_network_id    = azurerm_virtual_network.vnetCoreServices.id 
 
  # This checkbox maps directly to the "Enable auto registration" setting
  registration_enabled  = true 
}

# 3. Link the VNet and Enable Auto-Registration 
resource "azurerm_private_dns_zone_virtual_network_link" "Manufacturing_link" {
  name                  = "ManufacturingVnetLink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.contoso_dns.name
  
  # Fetches your existing central VNet ID 
  # Note: Ensure "azurerm_virtual_network.core_vnet" matches your actual local VNet resource block name
  virtual_network_id    = azurerm_virtual_network.vnetManufacturing.id 
 
  # This checkbox maps directly to the "Enable auto registration" setting
  registration_enabled  = true 
}
