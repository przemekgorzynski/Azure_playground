variable "org_prefix" { type = string }
variable "region_sh" { type = string }
variable "location" { type = string }

variable "tags" { type = map(string) }

##########################################################
#── Subscriptions ──────────────────────────────────────────
variable "mgmt_subscription_id" { type = string }
variable "spoke1_subscription_id" { type = string }
variable "spoke2_subscription_id" { type = string }

##########################################################
# ── Hub ────────────────────────────────────────────────────
variable "hub_vnet_address_prefix" { type = string }

variable "hub_subnets" {
  type = list(object({
    name                              = string
    prefix                            = string
    private_endpoint_network_policies = string
  }))
}

variable "private_dns_zones" {
  type = list(object({
    name              = string
    auto_registration = bool
  }))
}

# ── VM image ───────────────────────────────────────────────
variable "deploy_nva" {
  type    = bool
  default = false
}

variable "nva_vm_size" {
  type    = string
  default = "Standard_B2ats_v2"
}

variable "nva_admin_username" {
  type    = string
  default = "azureadmin"
}

variable "nva_admin_ssh_key" {
  type      = string
  sensitive = true
}

variable "nva_private_ip" { type = string }
variable "nva_public_ip" { type = bool }
variable "nva_vm_image_publisher" { type = string }
variable "nva_vm_image_offer" { type = string }
variable "nva_vm_image_sku" { type = string }
variable "nva_vm_image_version" { type = string }

##########################################################
# ── Spoke 1 ────────────────────────────────────────────────
variable "spoke1_vnet_address_prefix" { type = string }

variable "spoke1_subnets" {
  type = list(object({
    name                              = string
    prefix                            = string
    private_endpoint_network_policies = string
  }))
}

##########################################################
# ── Spoke 2 ────────────────────────────────────────────────
variable "spoke2_vnet_address_prefix" { type = string }

variable "spoke2_subnets" {
  type = list(object({
    name                              = string
    prefix                            = string
    private_endpoint_network_policies = string
  }))
}
