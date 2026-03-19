variable "org_prefix" { type = string }
variable "region_sh"  { type = string }
variable "location"   { type = string }

variable "tags" { type = map(string) }

# ── Service Principal ──────────────────────────────────────
variable "service_principal_object_id" { type = string }
variable "role_definition_id"          { type = string }
variable "principal_type"              { type = string }

# ── Subscriptions ──────────────────────────────────────────
variable "mgmt_subscription_id"  { type = string }
variable "spoke1_subscription_id" { type = string }
variable "spoke2_subscription_id" { type = string }

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

# ── Spoke 1 ────────────────────────────────────────────────
variable "spoke1_vnet_address_prefix" { type = string }

variable "spoke1_subnets" {
  type = list(object({
    name                              = string
    prefix                            = string
    private_endpoint_network_policies = string
  }))
}

# ── Spoke 2 ────────────────────────────────────────────────
variable "spoke2_vnet_address_prefix" { type = string }

variable "spoke2_subnets" {
  type = list(object({
    name                              = string
    prefix                            = string
    private_endpoint_network_policies = string
  }))
}