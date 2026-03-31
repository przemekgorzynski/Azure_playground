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

module "spoke1_nsg" {
  source     = "../../modules/terraform/nsg"
  providers  = { azurerm = azurerm.spoke1 }
  depends_on = [module.spoke1_subnets]

  name           = "nsg-spoke1-${var.org_prefix}-${var.region_sh}"
  location       = module.rg_spoke1_vnet.location
  resource_group = module.rg_spoke1_vnet.name
  security_rules = var.spoke1_nsg_rules
  tags           = merge(var.tags, { Resource = "Network Security Group" })
  subnet_ids     = [for s in module.spoke1_subnets : s.id]
}