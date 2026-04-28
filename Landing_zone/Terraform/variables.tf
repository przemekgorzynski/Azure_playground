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
variable "hub_nsg_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
}

variable "private_dns_zones" {
  type = list(object({
    name              = string
    auto_registration = bool
  }))
}

# NVA - network virtual appliance
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

variable "spoke1_nsg_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
}

# ── Spoke 1 VM ─────────────────────────────────────────────
variable "deploy_spoke1_vm" {
  type    = bool
  default = false
}

variable "spoke1_vm_size" {
  type    = string
  default = "Standard_B2ats_v2"
}

variable "spoke1_vm_admin_username" {
  type    = string
  default = "azureadmin"
}

variable "spoke1_vm_admin_ssh_key" {
  type      = string
  sensitive = true
}

variable "spoke1_vm_private_ip" {
  type    = string
  default = null
}
variable "spoke1_vm_public_ip"       { type = bool }
variable "spoke1_vm_image_publisher" { type = string }
variable "spoke1_vm_image_offer"     { type = string }
variable "spoke1_vm_image_sku"       { type = string }
variable "spoke1_vm_image_version"   { type = string }

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

variable "spoke2_nsg_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
}
