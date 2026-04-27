org_prefix = "internal"
region_sh  = "we"
location   = "westeurope"

tags = {
  Owner       = "Przemek Gorzynski"
  environment = "dev"
  purpose     = "landing_zone"
  createdBy   = "terraform"
}

# ── Subscriptions ──────────────────────────────────────────
mgmt_subscription_id   = "498ff788-a1a1-4860-a97f-3ee90d4fab61"
spoke1_subscription_id = "4d0f2de4-fd44-4c94-ab45-5d8f2d2b3720"
spoke2_subscription_id = "fa2293f5-402a-453a-a8da-0870c83a6122"

# ── Hub ────────────────────────────────────────────────────
hub_vnet_address_prefix = "10.0.0.0/16"

hub_subnets = [
  {
    name                              = "Hub-mgmnt-subnet"
    prefix                            = "10.0.1.0/24"
    private_endpoint_network_policies = "Disabled"
  },
  {
    name                              = "Hub-pe-subnet"
    prefix                            = "10.0.2.0/24"
    private_endpoint_network_policies = "Disabled"
  },
  {
    name                              = "Hub-nva-subnet"
    prefix                            = "10.0.3.0/28"
    private_endpoint_network_policies = "Disabled"
  }
]

hub_nsg_rules = [
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

private_dns_zones = [
  {
    name              = "privatelink.blob.core.windows.net"
    auto_registration = false
  }
]

# VM machine acting like proxy between spokes
deploy_nva             = false
nva_private_ip         = "10.0.3.4"
nva_public_ip          = true
nva_vm_size            = "Standard_B2ats_v2"
nva_admin_username     = "azureadmin"
nva_admin_ssh_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILZBY8AiU6cRPY+HCUQ2jr5Sti7Xs5UpS5Ke00yYTkia Przemyslaw Gorzynski"
nva_vm_image_publisher = "Canonical"
nva_vm_image_offer     = "0001-com-ubuntu-server-jammy"
nva_vm_image_sku       = "22_04-lts"
nva_vm_image_version   = "latest"

# ── Spoke 1 ────────────────────────────────────────────────
spoke1_vnet_address_prefix = "10.1.0.0/16"

spoke1_subnets = [
  {
    name                              = "subnet-pe"
    prefix                            = "10.1.1.0/24"
    private_endpoint_network_policies = "Disabled"
  },
  {
    name                              = "subnet-02"
    prefix                            = "10.1.2.0/24"
    private_endpoint_network_policies = "Disabled"
  }
]

spoke1_nsg_rules = [
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