variable "pm_api_url" {
  type = string
}

variable "searchdomain" {
  type = string
}

variable "nameserver" {
  type = string
}

variable "gw" {
  type = string
}

variable "k3s_ha_enabled" {
  description = "Provision additional controller nodes (k3sc2, k3sc3) for HA-ready topology."
  type        = bool
  default     = false
}
