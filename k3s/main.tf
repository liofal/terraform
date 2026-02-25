terraform {
  # backend "s3" {
  #   bucket         = "lfa-speos-test"
  #   key            = "terraform/state"
  #   encrypt        = true
  # }
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

provider "proxmox" {
  pm_tls_insecure = true
  pm_api_url      = var.pm_api_url
  pm_parallel     = 1
}

resource "proxmox_lxc" "k3s-controller1" {
  hostname    = "k3sc1"
  cores       = 4
  memory      = "4096"
  swap        = "512"
  password    = "123456"
  target_node = "proxmox"

  unprivileged = false
  onboot       = true
  pool         = "k3s"
  clone        = "101"

  searchdomain = var.searchdomain
  nameserver   = var.nameserver
  network {
    name     = "eth0"
    bridge   = "vmbr0"
    type     = "veth"
    firewall = true
    ip       = "192.168.1.201/24"
    hwaddr   = "7A:00:00:00:04:01"
    gw       = var.gw
    ip6      = "auto"
    # tag    =1
  }
  rootfs {
    storage = "local-lvm"
    size    = "20G"
  }
}


resource "proxmox_lxc" "k3s-controller2" {
  count       = var.k3s_ha_enabled ? 1 : 0
  hostname    = "k3sc2"
  cores       = 4
  memory      = "4096"
  swap        = "512"
  password    = "123456"
  target_node = "proxmox"

  unprivileged = false
  onboot       = true
  pool         = "k3s"
  clone        = "template3"

  searchdomain = var.searchdomain
  nameserver   = var.nameserver
  network {
    name     = "eth0"
    bridge   = "vmbr0"
    type     = "veth"
    firewall = true
    ip       = "192.168.1.207/24"
    hwaddr   = "7A:00:00:00:04:07"
    gw       = var.gw
    ip6      = "auto"
    # tag    =1
  }
  rootfs {
    storage = "local-lvm"
    size    = "20G"
  }
}

resource "proxmox_lxc" "k3s-controller3" {
  count       = var.k3s_ha_enabled ? 1 : 0
  hostname    = "k3sc3"
  cores       = 4
  memory      = "4096"
  swap        = "512"
  password    = "123456"
  target_node = "proxmox"

  unprivileged = false
  onboot       = true
  pool         = "k3s"
  clone        = "template3"

  searchdomain = var.searchdomain
  nameserver   = var.nameserver
  network {
    name     = "eth0"
    bridge   = "vmbr0"
    type     = "veth"
    firewall = true
    ip       = "192.168.1.208/24"
    hwaddr   = "7A:00:00:00:04:08"
    gw       = var.gw
    ip6      = "auto"
    # tag    =1
  }
  rootfs {
    storage = "local-lvm"
    size    = "20G"
  }
}
resource "proxmox_lxc" "k3s-worker5" {
  hostname    = "k3sw5"
  cores       = 4
  memory      = "8192"
  swap        = "512"
  password    = "123456" # Note: Consider managing secrets more securely
  target_node = "proxmox"

  unprivileged = false
  onboot       = true
  pool         = "k3s"
  clone        = "101" # Assuming template ID 101 is correct

  searchdomain = var.searchdomain
  nameserver   = var.nameserver
  network {
    name     = "eth0"
    bridge   = "vmbr0"
    type     = "veth"
    firewall = true
    ip       = "192.168.1.206/24"
    hwaddr   = "7A:00:00:00:04:06"
    gw       = var.gw
    ip6      = "auto"
    # tag    =1
  }
  rootfs {
    storage = "local-lvm"
    size    = "20G"
  }
}

resource "proxmox_lxc" "k3s-worker1" {
  hostname    = "k3sw1"
  cores       = 4
  memory      = "8192"
  swap        = "512"
  password    = "123456"
  target_node = "proxmox"

  unprivileged = false
  onboot       = true
  pool         = "k3s"
  clone        = "101"

  searchdomain = var.searchdomain
  nameserver   = var.nameserver
  network {
    name     = "eth0"
    bridge   = "vmbr0"
    type     = "veth"
    firewall = true
    ip       = "192.168.1.202/24"
    hwaddr   = "7A:00:00:00:04:02"
    gw       = var.gw
    ip6      = "auto"
    # tag    =1
  }
  rootfs {
    storage = "local-lvm"
    size    = "20G"
  }
}

resource "proxmox_lxc" "k3s-worker2" {
  hostname    = "k3sw2"
  cores       = 4
  memory      = "8192"
  swap        = "512"
  password    = "123456"
  target_node = "proxmox"

  unprivileged = false
  onboot       = true
  pool         = "k3s"
  clone        = "101"

  searchdomain = var.searchdomain
  nameserver   = var.nameserver
  network {
    name     = "eth0"
    bridge   = "vmbr0"
    type     = "veth"
    firewall = true
    ip       = "192.168.1.203/24"
    hwaddr   = "7A:00:00:00:04:03"
    gw       = var.gw
    ip6      = "auto"
    # tag    =1
  }
  rootfs {
    storage = "local-lvm"
    size    = "20G"
  }
}

resource "proxmox_lxc" "k3s-worker3" {
  hostname    = "k3sw3"
  cores       = 4
  memory      = "8192"
  swap        = "512"
  password    = "123456"
  target_node = "proxmox"

  unprivileged = false
  onboot       = true
  pool         = "k3s"
  clone        = "101"

  searchdomain = var.searchdomain
  nameserver   = var.nameserver
  network {
    name     = "eth0"
    bridge   = "vmbr0"
    type     = "veth"
    firewall = true
    ip       = "192.168.1.204/24"
    hwaddr   = "7A:00:00:00:04:04"
    gw       = var.gw
    ip6      = "auto"
    # tag    =1
  }
  rootfs {
    storage = "local-lvm"
    size    = "20G"
  }
}

resource "proxmox_lxc" "k3s-worker4" {
  hostname    = "k3sw4"
  cores       = 4
  memory      = "8192"
  swap        = "512"
  password    = "123456"
  target_node = "proxmox"

  unprivileged = false
  onboot       = true
  pool         = "k3s"
  clone        = "101"

  searchdomain = var.searchdomain
  nameserver   = var.nameserver
  network {
    name     = "eth0"
    bridge   = "vmbr0"
    type     = "veth"
    firewall = true
    ip       = "192.168.1.205/24"
    hwaddr   = "7A:00:00:00:04:05"
    gw       = var.gw
    ip6      = "auto"
    # tag    =1
  }
  rootfs {
    storage = "local-lvm"
    size    = "20G"
  }
}
