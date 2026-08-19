# ==============================================================================
# VNET & SUBNET
# ==============================================================================
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
  #Configures zones required by VpnGw1AZ
  zones               = ["1", "2", "3"] 
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
  location            = var.eastus2_location # 
  allocation_method   = "Static"
  sku                 = "Standard"
  #Configures zones required by VpnGw1AZ
  zones               = ["1", "2", "3"] 
}

# Deploy the Manufacturing Virtual Network Gateway
resource "azurerm_virtual_network_gateway" "manufacturing_gw" {
  name                = "ManufacturingVnetGateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.eastus2_location # 

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
/*  
# Note: Keep this as is to BLOCK the section & # to UNBLOCK

# =========================================================================
# Site-to-Site Gateway: Local Network Target (On-Prem Office)
# =========================================================================
resource "azurerm_local_network_gateway" "on_prem_office_manual" {
  name                = "OnPremOffice-LocalGateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.eastus_location

  gateway_address     = "71.17.169.75"
  address_space       = ["172.16.0.0/16"]
}

# =========================================================================
# Site-to-Site Connection: CoreServices Gateway to On-Prem Office
# =========================================================================
resource "azurerm_virtual_network_gateway_connection" "on_prem_office_manual" {
  name                = "CoreServices-to-OnPremOffice"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.eastus_location

  type                               = "IPsec"
  connection_protocol                = "IKEv1"
  connection_mode                    = "Default"
  dpd_timeout_seconds                = 45
  enable_bgp                         = false
  use_policy_based_traffic_selectors = false

  # DYNAMIC REFERENCES: No more hardcoded resource IDs
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.coreservices_gw.id
  local_network_gateway_id        = azurerm_local_network_gateway.on_prem_office_manual.id

  # MANDATORY SECURITY TUNNEL KEY (Replace with your actual pre-shared key)
  shared_key = "Agbalagba@20080228" 

  ipsec_policy {
    dh_group         = "DHGroup14"
    ike_encryption   = "AES256"
    ike_integrity    = "SHA384"
    ipsec_encryption = "AES256"
    ipsec_integrity  = "SHA256"
    pfs_group        = "None"
    sa_lifetime      = 27000
    # FIX: sa_datasize = 0 removed to pass schema validation
  }
}

*/  # Closing tag

/*  
# =========================================================================
# TASK 1: Create a Virtual WAN (Global Blueprint Layer)
# =========================================================================
resource "azurerm_virtual_wan" "vwan" {
  name                = "ContosoVirtualWAN"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.eastus_location # Metadata control plane anchor region
  type                = "Standard"          # Matches "Standard" portal selection
}

# =========================================================================
# TASK 2: Create a Virtual Hub (Basics Tab Configuration)
# =========================================================================
resource "azurerm_virtual_hub" "eastus2_hub" {
  name                = "ContosoVirtualWANHub-EastUS2" 
  resource_group_name = azurerm_resource_group.rg.name
  location            = "eastus2"                     
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_prefix      = "10.60.0.0/24"               

  # PORTAL MATCH: "Virtual hub capacity: 2 Routing infrastructure units"
  # In Azure, 2 Routing Units is the exact definition of a "Standard" hub SKU.
  sku = "Standard"

  # PORTAL MATCH: "Hub routing preference: leave the default"
  # By omitting the 'hub_routing_preference' parameter, Terraform allows Azure 
  # to apply its default platform routing preference ("ExpressRoute" or "ASPath").
}

# =========================================================================
# TASK 2 (Continued): Site-to-Site Tab Configuration (VPN Gateway: Yes)
# =========================================================================
resource "azurerm_vpn_gateway" "hub_s2s_gateway" {
  name                = "ContosoVirtualWANHub-EastUS2-VPNGateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "eastus2"
  virtual_hub_id      = azurerm_virtual_hub.eastus2_hub.id # Links it to the Hub above

  # PORTAL MATCH: "Gateway scale units: 1 scale unit = 500 Mbps x 2"
  scale_unit = 1

  # PORTAL MATCH: "Routing preference: leave the default"
  # Omitted internet routing overrides to let the system default to Microsoft's premium backbone.
}


# =========================================================================
# TASK 3: Connect the Southeast Asia Research VNet to the East US2 Hub
# =========================================================================
resource "azurerm_virtual_hub_connection" "research_vnet_connection" {
  name                      = "ContosoVirtualWAN-to-ResearchVNet"
  virtual_hub_id            = azurerm_virtual_hub.eastus2_hub.id
  remote_virtual_network_id = azurerm_virtual_network.vnetResearch.id # Dynamic resource reference

  # Enforces explicit route table mappings specified in the exercise
  routing {
    associated_route_table_id = "${azurerm_virtual_hub.eastus2_hub.id}/hubRouteTables/defaultRouteTable"
    
    # Portal equivalent: "Propagate to none: Yes"
    propagated_route_table {
      labels          = ["default"]
      route_table_ids = ["${azurerm_virtual_hub.eastus2_hub.id}/hubRouteTables/defaultRouteTable"]
    }
  }

  # Crucial: Forces connection to wait until the underlying hub VPN gateway is online
  depends_on = [azurerm_vpn_gateway.hub_s2s_gateway]
}
*/ 

# =========================================================================
# TASK 1: ExpressRoute Virtual Network Gateway
# =========================================================================
resource "azurerm_virtual_network_gateway" "coreservices_er_gw" {
  name                = "CoreServicesVnetGateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.eastus_location # Matches East US region selection

  type     = "ExpressRoute" # PORTAL MATCH: Gateway type
  sku      = "Standard"     # PORTAL MATCH: SKU
  vpn_type = "RouteBased"   # Default provider requirement

  # ExpressRoute deployment scales do not utilize the "generation" attribute
  
  ip_configuration {
    name                          = "vnetGatewayConfig"
    private_ip_address_allocation = "Dynamic"
    
    # DYNAMIC REFERENCE: Attaches straight to your existing CoreServices GatewaySubnet
    subnet_id                     = azurerm_subnet.GatewaySubnet.id
	
	# ADD THIS LINE: Satisfies the Terraform v4 schema required validation rule
    public_ip_address_id          = azurerm_public_ip.er_gw_pip.id
  }
}

# =========================================================================
# REQUIRED FIX: Standard Public IP for ExpressRoute Gateway Validation
# =========================================================================
resource "azurerm_public_ip" "er_gw_pip" {
  name                = "CoreServicesVnetGateway-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.eastus_location
  allocation_method   = "Static"
  sku                 = "Standard"  # Azure requires Standard SKU for gateways
}

# =========================================================================
# TASK 2 : Create and Provision ExpressRoute Circuit
# =========================================================================
resource "azurerm_express_route_circuit" "test_er_circuit" {
  name                = "TestERCircuit" # Portal: Circuit Name
  resource_group_name = azurerm_resource_group.rg.name
  location            = "eastus2"       # The peering location and MS entrance point oe edge facility

  # Portal: Provider, Peering Location, & Bandwidth Configuration
  service_provider_name = "Equinix"
  peering_location      = "Seattle"
  bandwidth_in_mbps     = 50

  sku {
    tier = "Standard" # Portal: SKU tier
    family = "MeteredData"  # Portal: Data metering billing model
  }

  tags = {}
}

# =========================================================================
# TASK 3: ExpressRoute Virtual Network Gateway Connection (The Bridge)
# =========================================================================
resource "azurerm_virtual_network_gateway_connection" "er_vnet_connection" {
  name                = "CoreServicesToTestERCircuit"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.eastus_location

  type                       = "ExpressRoute"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.coreservices_er_gw.id
  express_route_circuit_id   = azurerm_express_route_circuit.test_er_circuit.id
}

# =========================================================================
# TASK 3: ExpressRoute BGP Private Peering Configuration
# =========================================================================
resource "azurerm_express_route_circuit_peering" "private_peering" {
  peering_type                  = "AzurePrivatePeering"
  express_route_circuit_name    = azurerm_express_route_circuit.test_er_circuit.name
  resource_group_name           = azurerm_resource_group.rg.name
  
  peer_asn                      = 65001          # Your On-Premises BGP Autonomous System Number
  primary_peer_address_prefix   = "192.168.11.0/30"  # Subnet allocation for primary physical link point-to-point
  secondary_peer_address_prefix = "192.168.11.4/30"  # Subnet allocation for secondary physical link point-to-point
  vlan_id                       = 11             # The Dot1Q Client Tag you are using for data isolation

  # Option for MD5 Security Encryption
  # shared_key                  = "YourSecretMESSKey" 
}