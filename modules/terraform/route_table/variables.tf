variable "name"           { type = string }
variable "location"       { type = string }
variable "resource_group" { type = string }
variable "tags"           { type = map(string) }

variable "routes" {
  type = list(object({
    name           = string
    address_prefix = string
    next_hop_type  = string
  }))
}

variable "subnet_ids" {
  type        = map(string)
  description = "Map of subnet name => subnet id to associate with this route table"
}