# Read existing VNet
data "azurerm_virtual_network" "vnet-spoke1" {
  provider              = azurerm.spoke1
  name                  = "vnet-spoke1-internal-we"
  resource_group_name   = "rg-VnetSpoke1-internal-we"
}

# Read existing Subnet
data "azurerm_subnet" "subnet-01-spoke1" {
  provider              = azurerm.spoke1
  name                  = "subnet-01"
  virtual_network_name  = data.azurerm_virtual_network.vnet-spoke1.name
  resource_group_name   = "rg-VnetSpoke1-internal-we"
}

data "azurerm_subnet" "subnet-02-spoke1" {
  provider              = azurerm.spoke1
  name                  = "subnet-02"
  virtual_network_name  = data.azurerm_virtual_network.vnet-spoke1.name
  resource_group_name   = "rg-VnetSpoke1-internal-we"
}

# RG
resource "azurerm_resource_group" "rg_spoke1" {
  provider  = azurerm.spoke1
  name      = "rg-storage-account-spoke1"
  location  = "westeurope"
}

resource "random_string" "suffix-spoke1" {
  length    = 12
  upper     = false
  special   = false
}

resource "azurerm_storage_account" "sa-spoke1" {
  provider                         = azurerm.spoke1
  name                             = "st${random_string.suffix-spoke1.result}"
  resource_group_name              = azurerm_resource_group.rg_spoke1.name
  location                         = azurerm_resource_group.rg_spoke1.location
  account_tier                     = "Standard"
  account_replication_type         = "LRS"
  account_kind                     = "StorageV2"
  access_tier                      = "Cool"
  public_network_access_enabled    = false
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  shared_access_key_enabled        = true
  https_traffic_only_enabled       = true
  min_tls_version                  = "TLS1_2"
  sftp_enabled                     = false
  nfsv3_enabled                    = false
  is_hns_enabled                   = false
  infrastructure_encryption_enabled = false
  local_user_enabled               = false

  blob_properties {
    versioning_enabled       = false
    change_feed_enabled      = false
    last_access_time_enabled = false

    delete_retention_policy {
      days = 1
    }

    container_delete_retention_policy {
      days = 1
    }
  }
}

resource "azurerm_private_endpoint" "pe-sa-spoke1" {
  provider            = azurerm.spoke1
  name                = "pe-sa-spoke1"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.rg_spoke1.name
  subnet_id           = data.azurerm_subnet.subnet-01-spoke1.id

  private_service_connection {
    name                           = "psc-sa-spoke1"
    private_connection_resource_id = azurerm_storage_account.sa-spoke1.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "dns-group-sa-spoke1"
    private_dns_zone_ids = [
      data.azurerm_private_dns_zone.blob.id
    ]
  }
}

####### test vm

resource "azurerm_public_ip" "pip-test-vm-spoke1" {
  provider            = azurerm.spoke1
  name                = "pip-test-vm-spoke1"
  resource_group_name = azurerm_resource_group.rg_spoke1.name
  location            = "westeurope"
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic-test-vm-spoke1" {
  provider            = azurerm.spoke1
  name                = "nic-test-vm-spoke1"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.rg_spoke1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet-01-spoke1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-test-vm-spoke1.id
  }
}

resource "azurerm_linux_virtual_machine" "test-vm-spoke1" {
  provider            = azurerm.spoke1
  name                = "vm-test-spoke1"
  resource_group_name = azurerm_resource_group.rg_spoke1.name
  location            = "westeurope"
  size                = "Standard_B2ats_v2"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.nic-test-vm-spoke1.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_ed25519.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

output "test_vm_spoke1_public_ip" {
  value = azurerm_public_ip.pip-test-vm-spoke1.ip_address
}