include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "azurerm" {
      subscription_id = "${get_env("ARM_SPOKE2_SUBSCRIPTION_ID")}"
      features {}
    }
  EOF
}

generate "main" {
  path      = "main.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF

    module "rg_vnet" {
      source    = "${get_repo_root()}/modules/terraform/resource_group"
      providers = { azurerm = azurerm }
      name      = var.rg_vnet_name
      location  = var.location
      tags      = merge(var.tags, { Resource = "Resource Group" })
    }

    module "vnet" {
      source          = "${get_repo_root()}/modules/terraform/vnet"
      providers       = { azurerm = azurerm }
      vnet_name       = var.vnet_name
      location        = var.location
      resource_group  = module.rg_vnet.name
      address_prefix  = var.address_prefix
      tags            = merge(var.tags, { Resource = "Vnet" })
    }
  EOF
}

inputs = {
  rg_vnet_name    = "rg-VnetSpoke2-${include.root.locals.org_prefix}-${include.root.locals.region_sh}"
  vnet_name       = "vnet-Hub-${include.root.locals.org_prefix}-${include.root.locals.region_sh}"
  address_prefix  = "10.2.0.0/16"
  location        = include.root.locals.location
  tags            = include.root.locals.tags
}
