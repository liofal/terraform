terraform {
  required_version = ">= 0.14"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">= 0.14"
    }
  }
}

provider "proxmox" {
  pm_tls_insecure = true
  pm_api_url      = var.pm_api_url
}

resource "proxmox_lxc" "lxc-test" {
  hostname     = "lxc-test-host"
  cores        = 1
  memory       = "1024"
  swap         = "2048"
  password     = "123456"
  target_node  = "proxmox"
  unprivileged = true
  pool         = "terraform"
  # network {
  #   name   = "eth0"
  #   bridge = "vmbr0"
  #   ip     = "dhcp"
  #   ip6    = "dhcp"
  # }
  rootfs {
    storage = "local-lvm"
    size = "10G"
  }
  ostemplate = "local:vztmpl/rockylinux-9-default_20221109_amd64.tar.xz"
}
