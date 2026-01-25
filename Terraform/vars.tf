
variable "aks_auto_scaling_enabled" {
  type    = bool
  default = false
}

variable "aks_min_node_count" {
  type    = number
  default = 1
}

variable "aks_max_node_count" {
  type    = number
  default = 3
}
