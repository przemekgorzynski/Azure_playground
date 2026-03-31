variable "name" { type = string }
variable "location" { type = string }
variable "resource_group" { type = string }
variable "tags" { type = map(string) }

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to associate this NSG with"
}

variable "security_rules" {
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