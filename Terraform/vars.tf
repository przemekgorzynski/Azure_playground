
variable "cf_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
  default     = ""   # optional, can be empty if always reading from env
}

variable "cf_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
  default     = ""
}