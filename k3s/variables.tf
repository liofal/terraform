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

variable "controller_cores" {
  description = "CPU cores for K3s controller LXCs."
  type        = number
  default     = 2
}

variable "controller_memory_mb" {
  description = "Memory (MiB) for K3s controller LXCs."
  type        = number
  default     = 4096
}

variable "k3s_ha_enabled" {
  description = "Provision additional controller nodes (k3sc2, k3sc3) for HA-ready topology."
  type        = bool
  default     = false
}
