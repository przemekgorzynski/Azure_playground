# ── Spoke 1 Peerings ───────────────────────────────────────
module "peering_hub_to_spoke1" {
  source     = "../../modules/terraform/vnet_peering"
  providers  = { azurerm = azurerm.mgmt }
  depends_on = [module.hub_subnets, module.spoke1_subnets]

  peering_name    = "peering-hub-to-spoke1"
  local_vnet_name = module.vnet_hub.name
  local_vnet_rg   = module.rg_hub_vnet.name
  remote_vnet_id  = module.vnet_spoke1.id
}

module "peering_spoke1_to_hub" {
  source     = "../../modules/terraform/vnet_peering"
  providers  = { azurerm = azurerm.spoke1 }
  depends_on = [module.hub_subnets, module.spoke1_subnets]

  peering_name    = "peering-spoke1-to-hub"
  local_vnet_name = module.vnet_spoke1.name
  local_vnet_rg   = module.rg_spoke1_vnet.name
  remote_vnet_id  = module.vnet_hub.id
}

# ── Spoke 2 Peerings ───────────────────────────────────────
module "peering_hub_to_spoke2" {
  source     = "../../modules/terraform/vnet_peering"
  providers  = { azurerm = azurerm.mgmt }
  depends_on = [module.hub_subnets, module.spoke2_subnets]

  peering_name    = "peering-hub-to-spoke2"
  local_vnet_name = module.vnet_hub.name
  local_vnet_rg   = module.rg_hub_vnet.name
  remote_vnet_id  = module.vnet_spoke2.id
}

module "peering_spoke2_to_hub" {
  source     = "../../modules/terraform/vnet_peering"
  providers  = { azurerm = azurerm.spoke2 }
  depends_on = [module.hub_subnets, module.spoke2_subnets]

  peering_name    = "peering-spoke2-to-hub"
  local_vnet_name = module.vnet_spoke2.name
  local_vnet_rg   = module.rg_spoke2_vnet.name
  remote_vnet_id  = module.vnet_hub.id
}