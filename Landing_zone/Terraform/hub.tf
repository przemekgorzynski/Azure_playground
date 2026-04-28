# ── Hub RGs ────────────────────────────────────────────────
module "rg_hub_vnet" {
  source    = "../../modules/terraform/resource_group"
  providers = { azurerm = azurerm.mgmt }

  name     = "rg-VnetHub-${var.org_prefix}-${var.region_sh}"
  location = var.location
  tags     = merge(var.tags, { Resource = "Resource Group" })
}

module "rg_hub_dns" {
  source    = "../../modules/terraform/resource_group"
  providers = { azurerm = azurerm.mgmt }

  name     = "rg-DnsHub-${var.org_prefix}-${var.region_sh}"
  location = var.location
  tags     = merge(var.tags, { Resource = "Resource Group" })
}

# ── Hub VNet ───────────────────────────────────────────────
module "vnet_hub" {
  source     = "../../modules/terraform/vnet"
  providers  = { azurerm = azurerm.mgmt }
  depends_on = [module.rg_hub_vnet]

  vnet_name      = "vnet-hub-${var.org_prefix}-${var.region_sh}"
  address_prefix = var.hub_vnet_address_prefix
  location       = module.rg_hub_vnet.location
  resource_group = module.rg_hub_vnet.name
  tags           = merge(var.tags, { Resource = "Virtual Network" })
}

# ── Hub Subnets ────────────────────────────────────────────
module "hub_subnets" {
  source     = "../../modules/terraform/subnet"
  providers  = { azurerm = azurerm.mgmt }
  for_each   = { for s in var.hub_subnets : s.name => s }
  depends_on = [module.vnet_hub]

  vnet_name                         = module.vnet_hub.name
  resource_group                    = module.rg_hub_vnet.name
  subnet_name                       = each.value.name
  subnet_prefix                     = each.value.prefix
  private_endpoint_network_policies = each.value.private_endpoint_network_policies
}

# ── Hub NSG ────────────────────────────────────────────────
module "hub_nsg" {
  source     = "../../modules/terraform/nsg"
  providers  = { azurerm = azurerm.mgmt }
  depends_on = [module.hub_subnets]

  name           = "nsg-hub-${var.org_prefix}-${var.region_sh}"
  location       = module.rg_hub_vnet.location
  resource_group = module.rg_hub_vnet.name
  security_rules = var.hub_nsg_rules
  tags           = merge(var.tags, { Resource = "Network Security Group" })
}

resource "azurerm_subnet_network_security_group_association" "hub" {
  provider = azurerm.mgmt
  for_each = { for s in var.hub_subnets : s.name => module.hub_subnets[s.name].id }

  subnet_id                 = each.value
  network_security_group_id = module.hub_nsg.id
}

# ── NVA ────────────────────────────────────────────────────
module "rg_nva" {
  count     = var.deploy_nva ? 1 : 0
  source    = "../../modules/terraform/resource_group"
  providers = { azurerm = azurerm.mgmt }

  name     = "rg-Nva-${var.org_prefix}-${var.region_sh}"
  location = var.location
  tags     = merge(var.tags, { Resource = "Resource Group" })
}

module "nva" {
  count      = var.deploy_nva ? 1 : 0
  source     = "../../modules/terraform/linux_vm"
  providers  = { azurerm = azurerm.mgmt }
  depends_on = [module.hub_subnets]

  vm_name               = "vm-nva-${var.org_prefix}-${var.region_sh}"
  location              = module.rg_nva[0].location
  resource_group        = module.rg_nva[0].name
  subnet_id             = module.hub_subnets["Hub-nva-subnet"].id
  private_ip            = var.nva_private_ip
  vm_size               = var.nva_vm_size
  admin_username        = var.nva_admin_username
  additional_ssh_keys   = tls_private_key.ssh_key.public_key_openssh
  admin_ssh_key         = var.nva_admin_ssh_key
  forward_traffic       = true
  public_ip             = var.nva_public_ip
  image_publisher       = var.nva_vm_image_publisher
  image_offer           = var.nva_vm_image_offer
  image_sku             = var.nva_vm_image_sku
  image_version         = var.nva_vm_image_version
  tags                  = merge(var.tags, { Resource = "Virtual Machine" })
}

resource "null_resource" "nva_setup" {
  count      = var.deploy_nva ? 1 : 0
  depends_on = [module.nva]

  triggers = {
    script_hash = filemd5(local.nva_script)
  }

  connection {
    type        = "ssh"
    host        = module.nva[0].public_ip
    user        = var.nva_admin_username
    private_key = tls_private_key.ssh_key.private_key_openssh
    timeout     = "3m"
  }

  provisioner "file" {
    source      = local.nva_script
    destination = "/tmp/setup_nva.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup_nva.sh",
      "sudo /tmp/setup_nva.sh"
    ]
  }
}

