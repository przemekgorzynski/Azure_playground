spoke1_subscription_id = "4d0f2de4-fd44-4c94-ab45-5d8f2d2b3720"

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

# VM
deploy_spoke1_vm              = false
spoke1_vm_private_ip          = "10.1.2.4"
spoke1_vm_public_ip           = false
spoke1_vm_size                = "Standard_B2ats_v2"
spoke1_vm_admin_username      = "azureadmin"
spoke1_vm_admin_ssh_key       = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILZBY8AiU6cRPY+HCUQ2jr5Sti7Xs5UpS5Ke00yYTkia Przemyslaw Gorzynski"
spoke1_vm_image_publisher     = "Canonical"
spoke1_vm_image_offer         = "0001-com-ubuntu-server-jammy"
spoke1_vm_image_sku           = "22_04-lts"
spoke1_vm_image_version       = "latest"
