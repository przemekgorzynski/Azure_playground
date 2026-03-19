variable "vm_name"          { type = string }
variable "location"         { type = string }
variable "resource_group"   { type = string }
variable "subnet_id"        { type = string }
variable "private_ip"       { type = string }
variable "vm_size"          { type = string }
variable "admin_username"   { type = string }
variable "admin_ssh_key"    { type = string }
variable "tags"             { type = map(string) }

variable "image_publisher" {
  type    = string
  default = "Canonical"
}

variable "image_offer" {
  type    = string
  default = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  type    = string
  default = "22_04-lts"
}

variable "image_version" {
  type    = string
  default = "latest"
}

variable "public_ip" {
  type    = bool
  default = false
}

variable "forward_traffic" {
  type        = bool
  default     = false
  description = "Set to true to configure VM as NVA — enables IP forwarding on NIC and configures iptables on first boot"
}