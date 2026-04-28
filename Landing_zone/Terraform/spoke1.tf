# ── Spoke 1 RG ─────────────────────────────────────────────
module "rg_spoke1_vnet" {
  source    = "../../modules/terraform/resource_group"
  providers = { azurerm = azurerm.spoke1 }

  name     = "rg-VnetSpoke1-${var.org_prefix}-${var.region_sh}"
  location = var.location
  tags     = merge(var.tags, { Resource = "Resource Group" })
}

# ── Spoke 1 VNet ───────────────────────────────────────────
module "vnet_spoke1" {
  source     = "../../modules/terraform/vnet"
  providers  = { azurerm = azurerm.spoke1 }
  depends_on = [module.rg_spoke1_vnet]

  vnet_name      = "vnet-spoke1-${var.org_prefix}-${var.region_sh}"
  address_prefix = var.spoke1_vnet_address_prefix
  location       = module.rg_spoke1_vnet.location
  resource_group = module.rg_spoke1_vnet.name
  tags           = merge(var.tags, { Resource = "Virtual Network" })
}

# ── Spoke 1 Subnets ────────────────────────────────────────
module "spoke1_subnets" {
  source     = "../../modules/terraform/subnet"
  providers  = { azurerm = azurerm.spoke1 }
  for_each   = { for s in var.spoke1_subnets : s.name => s }
  depends_on = [module.vnet_spoke1]

  vnet_name                         = module.vnet_spoke1.name
  resource_group                    = module.rg_spoke1_vnet.name
  subnet_name                       = each.value.name
  subnet_prefix                     = each.value.prefix
  private_endpoint_network_policies = each.value.private_endpoint_network_policies
}

# ── Spoke 1 Route Table ────────────────────────────────────
module "rt_spoke1" {
  source     = "../../modules/terraform/route_table"
  providers  = { azurerm = azurerm.spoke1 }
  depends_on = [module.spoke1_subnets]

  name           = "rt-spoke1-${var.org_prefix}-${var.region_sh}"
  location       = module.rg_spoke1_vnet.location
  resource_group = module.rg_spoke1_vnet.name
  tags           = var.tags
  subnet_ids     = { for k, v in module.spoke1_subnets : k => v.id }
  routes = var.deploy_nva ? [
    {
      name                   = "default"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.nva_private_ip
    },
    {
      name                   = "to-spoke2"
      address_prefix         = var.spoke2_vnet_address_prefix
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.nva_private_ip
    }
  ] : [
    {
      name                   = "default"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "Internet"
      next_hop_in_ip_address = null
    }
  ]
}

module "spoke1_nsg" {
  source     = "../../modules/terraform/nsg"
  providers  = { azurerm = azurerm.spoke1 }
  depends_on = [module.spoke1_subnets]

  name           = "nsg-spoke1-${var.org_prefix}-${var.region_sh}"
  location       = module.rg_spoke1_vnet.location
  resource_group = module.rg_spoke1_vnet.name
  security_rules = var.spoke1_nsg_rules
  tags           = merge(var.tags, { Resource = "Network Security Group" })
}

resource "azurerm_subnet_network_security_group_association" "spoke1" {
  provider = azurerm.spoke1
  for_each = { for s in var.spoke1_subnets : s.name => module.spoke1_subnets[s.name].id }

  subnet_id                 = each.value
  network_security_group_id = module.spoke1_nsg.id
}

# ── Spoke 1 VM ─────────────────────────────────────────────
module "rg_spoke1_vm" {
  count     = var.deploy_spoke1_vm ? 1 : 0
  source    = "../../modules/terraform/resource_group"
  providers = { azurerm = azurerm.spoke1 }

  name     = "rg-Vm-Spoke1-${var.org_prefix}-${var.region_sh}"
  location = var.location
  tags     = merge(var.tags, { Resource = "Resource Group" })
}

module "spoke1_vm" {
  count      = var.deploy_spoke1_vm ? 1 : 0
  source     = "../../modules/terraform/linux_vm"
  providers  = { azurerm = azurerm.spoke1 }
  depends_on = [module.spoke1_subnets]

  vm_name               = "vm-spoke1-${var.org_prefix}-${var.region_sh}"
  location              = module.rg_spoke1_vm[0].location
  resource_group        = module.rg_spoke1_vm[0].name
  subnet_id             = module.spoke1_subnets["subnet-02"].id
  private_ip            = var.spoke1_vm_private_ip
  vm_size               = var.spoke1_vm_size
  admin_username        = var.spoke1_vm_admin_username
  admin_ssh_key         = var.spoke1_vm_admin_ssh_key
  additional_ssh_keys   = tls_private_key.ssh_key.public_key_openssh
  public_ip             = var.spoke1_vm_public_ip
  image_publisher       = var.spoke1_vm_image_publisher
  image_offer           = var.spoke1_vm_image_offer
  image_sku             = var.spoke1_vm_image_sku
  image_version         = var.spoke1_vm_image_version
  tags                  = merge(var.tags, { Resource = "Virtual Machine" })
}

resource "null_resource" "spoke1_vm_setup" {
  count = var.deploy_spoke1_vm ? 1 : 0
  depends_on = [
    module.spoke1_vm,
    null_resource.nva_setup,
  ]

  triggers = {
    script_hash = filemd5(local.standard_vm_script)
  }

  connection {
    type        = "ssh"
    # When NVA is deployed, the default route on spoke1 subnets forces all
    # return traffic through the NVA, breaking direct public-IP SSH. Jump
    # through the NVA instead and target the private IP.
    host        = var.deploy_nva ? module.spoke1_vm[0].private_ip : module.spoke1_vm[0].public_ip
    user        = var.spoke1_vm_admin_username
    private_key = tls_private_key.ssh_key.private_key_openssh
    timeout     = "5m"

    bastion_host        = var.deploy_nva ? module.nva[0].public_ip : null
    bastion_user        = var.deploy_nva ? var.nva_admin_username : null
    bastion_private_key = var.deploy_nva ? tls_private_key.ssh_key.private_key_openssh : null
  }

  provisioner "file" {
    source      = local.standard_vm_script
    destination = "/tmp/setup_standard.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup_standard.sh",
      "sudo /tmp/setup_standard.sh"
    ]
  }
}