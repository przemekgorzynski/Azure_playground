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
  source    = "../../modules/terraform/vnet"
  providers = { azurerm = azurerm.mgmt }

  vnet_name      = "vnet-hub-${var.org_prefix}-${var.region_sh}"
  address_prefix = var.hub_vnet_address_prefix
  location       = module.rg_hub_vnet.location
  resource_group = module.rg_hub_vnet.name
  tags           = merge(var.tags, { Resource = "Virtual Network" })
}

# ── Hub Subnets ────────────────────────────────────────────
module "hub_subnets" {
  source    = "../../modules/terraform/subnet"
  providers = { azurerm = azurerm.mgmt }
  for_each  = { for s in var.hub_subnets : s.name => s }

  vnet_name                         = module.vnet_hub.name
  resource_group                    = module.rg_hub_vnet.name
  subnet_name                       = each.value.name
  subnet_prefix                     = each.value.prefix
  private_endpoint_network_policies = each.value.private_endpoint_network_policies
}
