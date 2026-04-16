# ── Spoke 2 RG ─────────────────────────────────────────────
module "rg_spoke2_vnet" {
  source    = "../../modules/terraform/resource_group"
  providers = { azurerm = azurerm.spoke2 }

  name     = "rg-VnetSpoke2-${var.org_prefix}-${var.region_sh}"
  location = var.location
  tags     = merge(var.tags, { Resource = "Resource Group" })
}

# ── Spoke 2 VNet ───────────────────────────────────────────
module "vnet_spoke2" {
  source     = "../../modules/terraform/vnet"
  providers  = { azurerm = azurerm.spoke2 }
  depends_on = [module.rg_spoke2_vnet]

  vnet_name      = "vnet-spoke2-${var.org_prefix}-${var.region_sh}"
  address_prefix = var.spoke2_vnet_address_prefix
  location       = module.rg_spoke2_vnet.location
  resource_group = module.rg_spoke2_vnet.name
  tags           = merge(var.tags, { Resource = "Virtual Network" })
}

# ── Spoke 2 Subnets ────────────────────────────────────────
module "spoke2_subnets" {
  source     = "../../modules/terraform/subnet"
  providers  = { azurerm = azurerm.spoke2 }
  for_each   = { for s in var.spoke2_subnets : s.name => s }
  depends_on = [module.vnet_spoke2]

  vnet_name                         = module.vnet_spoke2.name
  resource_group                    = module.rg_spoke2_vnet.name
  subnet_name                       = each.value.name
  subnet_prefix                     = each.value.prefix
  private_endpoint_network_policies = each.value.private_endpoint_network_policies
}

# ── Spoke 2 Route Table ────────────────────────────────────
module "rt_spoke2" {
  source     = "../../modules/terraform/route_table"
  providers  = { azurerm = azurerm.spoke2 }
  depends_on = [module.spoke2_subnets]

  name           = "rt-spoke2-${var.org_prefix}-${var.region_sh}"
  location       = module.rg_spoke2_vnet.location
  resource_group = module.rg_spoke2_vnet.name
  tags           = var.tags
  subnet_ids     = { for k, v in module.spoke2_subnets : k => v.id }
  routes = [
    {
      name           = "default"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    },
    {
      name           = "to-hub"
      address_prefix = var.hub_vnet_address_prefix
      next_hop_type  = "VnetLocal"
    }
  ]
}

module "spoke2_nsg" {
  source     = "../../modules/terraform/nsg"
  providers  = { azurerm = azurerm.spoke2 }
  depends_on = [module.spoke2_subnets]

  name           = "nsg-spoke2-${var.org_prefix}-${var.region_sh}"
  location       = module.rg_spoke2_vnet.location
  resource_group = module.rg_spoke2_vnet.name
  security_rules = var.spoke2_nsg_rules
  tags           = merge(var.tags, { Resource = "Network Security Group" })
}

resource "azurerm_subnet_network_security_group_association" "spoke2" {
  provider = azurerm.spoke2
  for_each = { for s in var.spoke2_subnets : s.name => module.spoke2_subnets[s.name].id }

  subnet_id                 = each.value
  network_security_group_id = module.spoke2_nsg.id
}