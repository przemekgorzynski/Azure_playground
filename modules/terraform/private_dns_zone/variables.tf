variable "zone_name" { type = string }
variable "resource_group" { type = string }
variable "tags" { type = map(string) }

variable "vnet_links" {
  type = map(object({
    vnet_id           = string
    auto_registration = bool
  }))
}