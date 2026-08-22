resource "azurerm_resource_group" "rg" {
  name     = "ContosoResourceGroup"
  location = var.eastus_location
  }

resource "azurerm_resource_group" "intlb_rg" {
  name     = "IntLB-RG"
  location = "East US"
}