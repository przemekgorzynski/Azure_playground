variable "name"             { type = string }
variable "resource_group"   { type = string }
variable "location"         { type = string }
variable "container_name"   { type = string }
variable "tags"             { type = map(string) }

variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "replication_type" {
  type    = string
  default = "LRS"
}