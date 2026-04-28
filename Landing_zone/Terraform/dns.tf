# ── Private DNS Zones + VNet Links ────────────────────────
module "private_dns" {
  source    = "../../modules/terraform/private_dns_zone"
  providers = { azurerm = azurerm.mgmt }
  for_each  = { for z in var.private_dns_zones : z.name => z }
  depends_on = [
    module.peering_hub_to_spoke1,
    module.peering_spoke1_to_hub,
    module.peering_hub_to_spoke2,
    module.peering_spoke2_to_hub
  ]

  zone_name      = each.value.name
  resource_group = module.rg_hub_dns.name
  tags = merge(var.tags, {
    Resource    = "Private DNS Zone"
    PrivateZone = each.value.name
  })
  vnet_links = {
    hub    = { vnet_id = module.vnet_hub.id, auto_registration = each.value.auto_registration }
    spoke1 = { vnet_id = module.vnet_spoke1.id, auto_registration = false }
    spoke2 = { vnet_id = module.vnet_spoke2.id, auto_registration = false }
  }
}