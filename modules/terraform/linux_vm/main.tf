terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm]
    }
  }
}

locals {
  cloud_init_nva = <<-EOF
    #!/bin/bash
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p
    apt-get update -y
    apt-get install -y iptables-persistent
    iptables -A FORWARD -i eth0 -o eth0 -j ACCEPT
    iptables -t nat -A POSTROUTING -j MASQUERADE
    netfilter-persistent save
  EOF

  cloud_init_normal = <<-EOF
    #!/bin/bash
    apt-get update -y
  EOF
}

resource "azurerm_public_ip" "this" {
  count               = var.public_ip ? 1 : 0
  name                = "${var.vm_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "this" {
  name                  = "${var.vm_name}-nic"
  location              = var.location
  resource_group_name   = var.resource_group
  ip_forwarding_enabled = var.forward_traffic

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip
    public_ip_address_id          = var.public_ip ? azurerm_public_ip.this[0].id : null
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "this" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resource_group
  size                  = var.vm_size
  admin_username        = var.admin_username
  
  network_interface_ids = [
    azurerm_network_interface.this.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  custom_data = base64encode(
    var.forward_traffic ? local.cloud_init_nva : local.cloud_init_normal
  )

  tags                  = var.tags
}