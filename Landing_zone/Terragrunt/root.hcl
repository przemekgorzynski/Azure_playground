locals {
  org_prefix = "internal"
  region_sh  = "we"
  location   = "westeurope"
  tags = {
    Owner       = "Przemek Gorzynski"
    environment = "dev"
    purpose     = "landing_zone"
    createdBy   = "terraform"
  }
}

generate "variables" {
  path      = "variables.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    variable "location"         { type = string }
    variable "tags"             { type = map(string) }
    variable "rg_vnet_name"     { type = string }
    variable "vnet_name"        { type = string }
    variable "address_prefix"   { type = string }
  EOF
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      cloud {
        organization = "pszemazzz"
        workspaces {
          name = "Landing-Zone-${path_relative_to_include()}"
        }
      }
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "4.44.0"
        }
      }
    }
  EOF
}
