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
    name                       = "allow-rdp-from-home"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = var.home_ip
    destination_address_prefix = "*"
  }

 # Rules B: Dynamic loop that auto-generates the separate Service Tag blocks
  dynamic "security_rule" {
    for_each = var.azure_regions_map
    content {
      name                       = "allow-rdp-from-azure-${security_rule.key}"
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = security_rule.value.tag # Singular property used here
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_network_security_group" "nsg2" {
  name                = "testvm2-nsg"
  location            = var.eastus_location
  resource_group_name = azurerm_resource_group.rg.name

    security_rule {
    name                       = "allow-rdp-from-home"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = var.home_ip
    destination_address_prefix = "*"
  }

 # Rules B: Dynamic loop that auto-generates the separate Service Tag blocks
  dynamic "security_rule" {
    for_each = var.azure_regions_map
    content {
      name                       = "allow-rdp-from-azure-${security_rule.key}"
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = security_rule.value.tag # Singular property used here
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_network_security_group" "nsg3" {
  name                = "ManufacturingVM-nsg"
  location            = var.eastus2_location
  resource_group_name = azurerm_resource_group.rg.name

    security_rule {
    name                       = "allow-rdp-from-home"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = var.home_ip
    destination_address_prefix = "*"
  }

  # Rules B: Dynamic loop that auto-generates the separate Service Tag blocks
  dynamic "security_rule" {
    for_each = var.azure_regions_map
    content {
      name                       = "allow-rdp-from-azure-${security_rule.key}"
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = security_rule.value.tag # Singular property used here
      destination_address_prefix = "*"
    }
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

# ==============================================================================
# VMs for LB
# ==============================================================================

resource "azurerm_windows_virtual_machine" "template_vms" {
  count               = 3
  name                = "myVM${count.index + 1}"
  computer_name       = "myVM${count.index + 1}"
  location            = azurerm_resource_group.intlb_rg.location
  resource_group_name = azurerm_resource_group.intlb_rg.name
  size                = "Standard_D2s_v7"
  admin_username      = "TestUser"
  admin_password      = var.admin_password

  network_interface_ids = [azurerm_network_interface.template_nics[count.index].id]

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

  provision_vm_agent = true

  lifecycle {
    ignore_changes = [
      admin_password,
    ]
  }
}

# ==============================================================================
# INLINE EXECUTION VERSION (REPLACES EXISTING EXTENSION IN VIRTUAL_MACHINES.TF)
# ==============================================================================
resource "azurerm_virtual_machine_extension" "iis_extension" {
  count                = 3
  name                 = "VMConfig"
  virtual_machine_id   = azurerm_windows_virtual_machine.template_vms[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10" # Upgraded to stable handler version

  # REMOVED fileUris entirely. The command now installs IIS directly using local modules.
  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -Command \"Install-WindowsFeature -Name Web-Server -IncludeManagementTools\""
    }
SETTINGS
}

# ==============================================================================
# STANDALONE TEST COMPUTATIONAL WORKLOAD (NO EXTENSIONS ATTACHED)
# ==============================================================================
resource "azurerm_windows_virtual_machine" "test_vm" {
  name                = "myTestVM"
  computer_name       = "myTestVM"
  location            = azurerm_resource_group.intlb_rg.location
  resource_group_name = azurerm_resource_group.intlb_rg.name
  size                = Standard_D2s_v3          # Portal Core Profile Choice
  admin_username      = "TestUser"                 # Portal Core Profile Choice
  admin_password      = var.admin_password         # Safe infrastructure global variable check

  network_interface_ids = [azurerm_network_interface.test_vm_nic.id]

  # Maps natively to removing availability set rules
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-gensecond"               
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"          # Match structural production baseline
  }

  provision_vm_agent = true

  lifecycle {
    ignore_changes = [
      admin_password,
    ]
  }
}
