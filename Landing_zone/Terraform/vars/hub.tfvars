mgmt_subscription_id = "498ff788-a1a1-4860-a97f-3ee90d4fab61"

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
  },
  {
    name              = "privatelink.azurecr.io"
    auto_registration = false
  },
  {
    name              = "privatelink.vaultcore.azure.net"
    auto_registration = false
  }
]

# ── NVA ────────────────────────────────────────────────────
deploy_nva             = true
nva_private_ip         = "10.0.3.4"
nva_public_ip          = true
nva_vm_size            = "Standard_B2ats_v2"
nva_admin_username     = "azureadmin"
nva_admin_ssh_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILZBY8AiU6cRPY+HCUQ2jr5Sti7Xs5UpS5Ke00yYTkia Przemyslaw Gorzynski"
nva_vm_image_publisher = "Canonical"
nva_vm_image_offer     = "0001-com-ubuntu-server-jammy"
nva_vm_image_sku       = "22_04-lts"
nva_vm_image_version   = "latest"
