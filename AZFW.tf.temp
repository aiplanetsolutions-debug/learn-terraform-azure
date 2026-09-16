# ==========================================
# VARIABLES & PROVIDER CONFIGURATION
# ==========================================
variable "admin_password" {
  type        = string
  default     = "Agbaya@20080228" # Replace with your secure lab password
  sensitive   = true
}

# ==========================================
# TASK 1: CREATE A RESOURCE GROUP
# ==========================================
resource "azurerm_resource_group" "rg" {
  name     = "Test-FW-RG"
  location = "eastus" # Replace with your preferred target Azure region
}

# ==========================================
# TASK 2: CREATE A VIRTUAL NETWORK & SUBNETS
# ==========================================
resource "azurerm_virtual_network" "vnet" {
  name                = "Test-FW-VN"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "fw_subnet" {
  name                 = "AzureFirewallSubnet" # Mandatory naming convention
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/26"]
}

resource "azurerm_subnet" "workload_subnet" {
  name                 = "Workload-SN"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# ==========================================
# TASK 3: CREATE WORKLOAD VM & NIC 
# ==========================================
resource "azurerm_network_interface" "vm_nic" {
  name                = "Srv-Work-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.workload_subnet.id
    private_ip_address_allocation = "Dynamic" # Corrected parameter name
  }

  # TASK 9 INTEGRATION: Consolidated custom DNS configuration
  dns_servers = ["209.244.0.3", "209.244.0.4"]
}

resource "azurerm_windows_virtual_machine" "workload_vm" {
  name                = "Srv-Work"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2s_v7"
  admin_username      = "TestUser"
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.vm_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }
}

# ==========================================
# TASK 4: DEPLOY FIREWALL AND FIREWALL POLICY
# ==========================================
resource "azurerm_public_ip" "fw_pip" {
  name                = "fw-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard" # Standard SKU Firewall requires Standard Public IP
}

resource "azurerm_firewall_policy" "fw_policy" {
  name                = "fw-test-pol"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
}

resource "azurerm_firewall" "firewall" {
  name                = "Test-FW01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.fw_policy.id

  ip_configuration {
    name                 = "fw-pip-config"
    subnet_id            = azurerm_subnet.fw_subnet.id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }
}

# ==========================================
# TASK 5: CREATE A DEFAULT ROUTE & UDR
# ==========================================
resource "azurerm_route_table" "fw_route_table" {
  name                          = "Firewall-route"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  disable_bgp_route_propagation = false # Setting true corresponds to "Propagate gateway routes: Yes"
}

resource "azurerm_route" "default_route" {
  name                   = "fw-dg"
  resource_group_name    = azurerm_resource_group.rg.name
  route_table_name       = azurerm_route_table.fw_route_table.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
}

resource "azurerm_subnet_route_table_association" "workload_udr_assoc" {
  subnet_id      = azurerm_subnet.workload_subnet.id
  route_table_id = azurerm_route_table.fw_route_table.id
}

# ==========================================
# TASK 6: CONFIGURE AN APPLICATION RULE
# ==========================================
resource "azurerm_firewall_policy_rule_collection_group" "app_rules" {
  name               = "DefaultApplicationRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id
  priority           = 200

  application_rule_collection {
    name     = "App-Coll01"
    priority = 200
    action   = "Allow"

    rule {
      name             = "Allow-Google"
      source_addresses = ["10.0.2.0/24"]
      destination_fqdns = [
         "*google.com"
      ] # Replaced placeholder with matching explicit endpoints based on rule naming context

      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
    }
  }
}

# ==========================================
# TASK 7: CONFIGURE A NETWORK RULE
# ==========================================
resource "azurerm_firewall_policy_rule_collection_group" "net_rules" {
  name               = "DefaultNetworkRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id
  priority           = 300 # Collection groups must have unique evaluation orders

  network_rule_collection {
    name     = "Net-Coll01"
    priority = 200
    action   = "Allow"

    rule {
      name                  = "Allow-DNS"
      protocols             = ["UDP"]
      source_addresses      = ["10.0.2.0/24"]
      destination_ports     = ["53"]
      destination_addresses = ["209.244.0.3", "209.244.0.4"]
    }
  }
}

# ==========================================
# TASK 8: CONFIGURE A DESTINATION NAT RULE
# ==========================================
resource "azurerm_firewall_policy_rule_collection_group" "nat_rules" {
  name               = "DefaultDnatRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id
  priority           = 100 # DNAT executes before Network/Application checks

  nat_rule_collection {
    name     = "rdp"
    priority = 200
    action   = "Dnat"

    rule {
      name                = "rdp-nat"
      protocols           = ["TCP"]
      source_addresses    = ["*"]
      destination_ports   = ["3389"]
      destination_address = azurerm_public_ip.fw_pip.ip_address
      translated_address  = azurerm_network_interface.vm_nic.private_ip_address
      translated_port     = "3389"
    }
  }
}


