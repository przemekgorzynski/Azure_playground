include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "azurerm" {
      subscription_id = "${get_env("ARM_MGMT_SUBSCRIPTION_ID")}"
      features {}
    }
  EOF
}

generate "main" {
  path      = "main.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    variable "rg_dns_name"      { type = string }

    module "rg_vnet" {
      source    = "${get_repo_root()}/modules/terraform/resource_group"
      providers = { azurerm = azurerm }
      name      = var.rg_vnet_name
      location  = var.location
      tags      = merge(var.tags, { Resource = "Resource Group" })
    }

    module "rg_dns" {
      source    = "${get_repo_root()}/modules/terraform/resource_group"
      providers = { azurerm = azurerm }
      name      = var.rg_dns_name
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
  rg_vnet_name    = "rg-VnetHub-${include.root.locals.org_prefix}-${include.root.locals.region_sh}"
  rg_dns_name     = "rg-DnsHub-${include.root.locals.org_prefix}-${include.root.locals.region_sh}"
  vnet_name       = "vnet-Hub-${include.root.locals.org_prefix}-${include.root.locals.region_sh}"
  address_prefix  = "10.0.0.0/16"
  location        = include.root.locals.location
  tags            = include.root.locals.tags
}
