spoke2_subscription_id = "fa2293f5-402a-453a-a8da-0870c83a6122"

# ── Spoke 2 ────────────────────────────────────────────────
spoke2_vnet_address_prefix = "10.2.0.0/16"

spoke2_subnets = [
  {
    name                              = "subnet-pe"
    prefix                            = "10.2.1.0/24"
    private_endpoint_network_policies = "Disabled"
  },
  {
    name                              = "subnet-02"
    prefix                            = "10.2.2.0/24"
    private_endpoint_network_policies = "Disabled"
  }
]

spoke2_nsg_rules = [
  {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "allow-forward"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "10.0.0.0/8"
  },
  {
    name                       = "allow-icmp"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "10.0.0.0/8"
  }
]
