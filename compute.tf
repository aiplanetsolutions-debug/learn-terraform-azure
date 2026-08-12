# ==============================================================================
# PUBLIC IP ADDRESSES (Page 7)
# ==============================================================================

resource "azurerm_public_ip" "pip1" {
  name                = "testvm1-pip"
  location            = var.eastus_location
  resource_group_name = azurerm_resource_group.rg.name # References your rg.tf
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "pip2" {
  name                = "testvm2-pip"
  location            = var.eastus_location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "pip3" {
  name                = "ManufacturingVM-pip"
  location            = var.eastus2_location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# ==============================================================================
# NETWORK SECURITY GROUPS (Page 4 & Page 6)
# ==============================================================================

resource "azurerm_network_security_group" "nsg1" {
  name                = "testvm1-nsg"
  location            = var.eastus_location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "default-allow-rdp"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    # Combined home IP and Azure regional Service Tags
    source_address_prefixes    = [
      var.home_ip,
      "AzureCloud.eastus",
      "AzureCloud.eastus2",
      "AzureCloud.southeastasia"
    ]
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg2" {
  name                = "testvm2-nsg"
  location            = var.eastus_location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "default-allow-rdp"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    # Combined home IP and Azure regional Service Tags
    source_address_prefixes    = [
      var.home_ip,
      "AzureCloud.eastus",
      "AzureCloud.eastus2",
      "AzureCloud.southeastasia"
    ]
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg3" {
  name                = "ManufacturingVM-nsg"
  location            = var.eastus2_location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "default-allow-rdp"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    # Combined home IP and Azure regional Service Tags
    source_address_prefixes    = [
      var.home_ip,
      "AzureCloud.eastus",
      "AzureCloud.eastus2",
      "AzureCloud.southeastasia"
    ]
    destination_address_prefix = "*"
  }
}

# ==============================================================================
# NETWORK INTERFACES (Page 3 & Page 5)
# ==============================================================================

resource "azurerm_network_interface" "nic1" {
  name                = var.nic_name_1
  location            = var.eastus_location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.DatabaseSubnet.id # 👈 References your existing subnet
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip1.id
  }
}

resource "azurerm_network_interface" "nic2" {
  name                = var.nic_name_2
  location            = var.eastus_location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.DatabaseSubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip2.id
  }
}

resource "azurerm_network_interface" "nic3" {
  name                = var.nic_name_3
  location            = var.eastus2_location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.ManufacturingSystemSubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip3.id
  }
}

# Bind NSGs to their respective Network Interfaces
resource "azurerm_network_interface_security_group_association" "nsg_assoc1" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc2" {
  network_interface_id      = azurerm_network_interface.nic2.id
  network_security_group_id = azurerm_network_security_group.nsg2.id
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc3" {
  network_interface_id      = azurerm_network_interface.nic3.id
  network_security_group_id = azurerm_network_security_group.nsg3.id
}

# ==============================================================================
# VIRTUAL MACHINES (Page 2 & Page 4)
# ==============================================================================

resource "azurerm_windows_virtual_machine" "vm1" {
  name                = var.vm_name_1
  computer_name       = var.vm_name_1
  location            = var.eastus_location
  resource_group_name = azurerm_resource_group.rg.name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [azurerm_network_interface.nic1.id]

  # Clean, regular Windows parameters (No Spot properties)
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-gensecond"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
   # 👇 TRACKS INITIAL SETUP ONLY; MANUALLY CHANGED CREDENTIALS ARE PROTECTED
  lifecycle {
    ignore_changes = [
      admin_password,
    ]
  }
}

resource "azurerm_windows_virtual_machine" "vm2" {
  name                = var.vm_name_2
  computer_name       = var.vm_name_2
  location            = var.eastus_location
  resource_group_name = azurerm_resource_group.rg.name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [azurerm_network_interface.nic2.id]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-gensecond"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
   # 👇 TRACKS INITIAL SETUP ONLY; MANUALLY CHANGED CREDENTIALS ARE PROTECTED
  lifecycle {
    ignore_changes = [
      admin_password,
    ]
  }
}

resource "azurerm_windows_virtual_machine" "vm3" {
  name                = var.vm_name_3
  computer_name       = var.vm_name_3
  location            = var.eastus2_location
  resource_group_name = azurerm_resource_group.rg.name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [azurerm_network_interface.nic3.id]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-gensecond"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
   # 👇 TRACKS INITIAL SETUP ONLY; MANUALLY CHANGED CREDENTIALS ARE PROTECTED
  lifecycle {
    ignore_changes = [
      admin_password,
    ]
  }
}

