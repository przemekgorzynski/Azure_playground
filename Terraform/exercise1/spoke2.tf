# Read existing VNet
data "azurerm_virtual_network" "vnet-spoke2" {
  provider              = azurerm.spoke2
  name                  = "vnet-spoke2-internal-we"
  resource_group_name   = "rg-VnetSpoke2-internal-we"
}

# Read existing Subnet
data "azurerm_subnet" "subnet-01-spoke2" {
  provider              = azurerm.spoke2
  name                  = "subnet-01"
  virtual_network_name  = data.azurerm_virtual_network.vnet-spoke2.name
  resource_group_name   = "rg-VnetSpoke2-internal-we"
}

data "azurerm_subnet" "subnet-02-spoke2" {
  provider              = azurerm.spoke2
  name                  = "subnet-02"
  virtual_network_name  = data.azurerm_virtual_network.vnet-spoke2.name
  resource_group_name   = "rg-VnetSpoke2-internal-we"
}


resource "azurerm_resource_group" "rg_spoke2" {
  provider  = azurerm.spoke2
  name      = "rg-storage-account-spoke2"
  location  = "westeurope"
}

resource "random_string" "suffix-spoke2" {
  length    = 12
  upper     = false
  special   = false
}

resource "azurerm_storage_account" "sa-spoke2" {
  provider                         = azurerm.spoke2
  name                             = "st${random_string.suffix-spoke2.result}"
  resource_group_name              = azurerm_resource_group.rg_spoke2.name
  location                         = azurerm_resource_group.rg_spoke2.location
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

resource "azurerm_private_endpoint" "pe-sa-spoke2" {
  provider            = azurerm.spoke2
  name                = "pe-sa-spoke2"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.rg_spoke2.name
  subnet_id           = data.azurerm_subnet.subnet-01-spoke2.id

  private_service_connection {
    name                           = "psc-sa-spoke2"
    private_connection_resource_id = azurerm_storage_account.sa-spoke2.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "dns-group-sa-spoke2"
    private_dns_zone_ids = [
      data.azurerm_private_dns_zone.blob.id
    ]
  }
}
