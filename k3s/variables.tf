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

variable "worker_cores" {
  description = "CPU cores for K3s worker LXCs."
  type        = number
  default     = 4
}

variable "worker_memory_mb" {
  description = "Memory (MiB) for K3s worker LXCs."
  type        = number
  default     = 8192
}

variable "k3s_ha_enabled" {
  description = "Provision additional controller nodes (k3sc2, k3sc3) for HA-ready topology."
  type        = bool
  default     = false
}

variable "controller1_clone_template" {
  description = "Template/VMID used when cloning k3sc1."
  type        = string
  default     = "101"
}

variable "controller_ha_clone_template" {
  description = "Template/VMID used when cloning k3sc2 and k3sc3."
  type        = string
  default     = "template3"
}

variable "controller1_vmid" {
  description = "Explicit VMID for k3sc1."
  type        = number
  default     = 103
}

variable "controller2_vmid" {
  description = "Explicit VMID for k3sc2 (used when k3s_ha_enabled=true)."
  type        = number
  default     = 108
}

variable "controller3_vmid" {
  description = "Explicit VMID for k3sc3 (used when k3s_ha_enabled=true)."
  type        = number
  default     = 107
}

variable "worker_clone_template" {
  description = "Template/VMID used when cloning k3s worker nodes."
  type        = string
  default     = "101"
}

variable "k3s_canary_worker_enabled" {
  description = "Create an extra canary worker LXC for major template/OS upgrades."
  type        = bool
  default     = false
}

variable "canary_worker_hostname" {
  description = "Hostname for the optional canary worker."
  type        = string
  default     = "k3sw6"
}

variable "canary_worker_ip_cidr" {
  description = "IPv4 CIDR address for the optional canary worker."
  type        = string
  default     = "192.168.1.210/24"
}

variable "canary_worker_hwaddr" {
  description = "MAC address for the optional canary worker."
  type        = string
  default     = "7A:00:00:00:04:10"
}

variable "canary_worker_vmid" {
  description = "Explicit VMID for the optional canary worker."
  type        = number
  default     = 111
}
