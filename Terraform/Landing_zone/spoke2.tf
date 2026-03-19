# ── Spoke 2 RG + VNet ──────────────────────────────────────
module "rg_spoke2_vnet" {
  source    = "../../modules/terraform/resource_group"
  providers = { azurerm = azurerm.spoke2 }

  name     = "rg-VnetSpoke2-${var.org_prefix}-${var.region_sh}"
  location = var.location
  tags     = merge(var.tags, { Resource = "Resource Group" })
}

module "vnet_spoke2" {
  source    = "../../modules/terraform/vnet"
  providers = { azurerm = azurerm.spoke2 }

  vnet_name      = "vnet-spoke2-${var.org_prefix}-${var.region_sh}"
  address_prefix = var.spoke2_vnet_address_prefix
  location       = module.rg_spoke2_vnet.location
  resource_group = module.rg_spoke2_vnet.name
  tags           = merge(var.tags, { Resource = "Virtual Network" })
}

# ── Spoke 2 Subnets ────────────────────────────────────────
module "spoke2_subnets" {
  source    = "../../modules/terraform/subnet"
  providers = { azurerm = azurerm.spoke2 }
  for_each  = { for s in var.spoke2_subnets : s.name => s }

  vnet_name                         = module.vnet_spoke2.name
  resource_group                    = module.rg_spoke2_vnet.name
  subnet_name                       = each.value.name
  subnet_prefix                     = each.value.prefix
  private_endpoint_network_policies = each.value.private_endpoint_network_policies
}

# ── Spoke 2 Route Table ────────────────────────────────────
module "rt_spoke2" {
  source    = "../../modules/terraform/route_table"
  providers = { azurerm = azurerm.spoke2 }

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

# ── Spoke 2 Peerings ───────────────────────────────────────
module "peering_hub_to_spoke2" {
  source    = "../../modules/terraform/vnet_peering"
  providers = { azurerm = azurerm.mgmt }

  peering_name    = "peering-hub-to-spoke2"
  local_vnet_name = module.vnet_hub.name
  local_vnet_rg   = module.rg_hub_vnet.name
  remote_vnet_id  = module.vnet_spoke2.id
}

module "peering_spoke2_to_hub" {
  source    = "../../modules/terraform/vnet_peering"
  providers = { azurerm = azurerm.spoke2 }

  peering_name    = "peering-spoke2-to-hub"
  local_vnet_name = module.vnet_spoke2.name
  local_vnet_rg   = module.rg_spoke2_vnet.name
  remote_vnet_id  = module.vnet_hub.id
}