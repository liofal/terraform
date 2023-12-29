terraform {
  backend "s3" {
    bucket         = "lfa-speos-test"
    key            = "terraform/state"
    encrypt        = true
  }
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
  pm_parallel     = 1
}

resource "proxmox_lxc" "k3s-controller1" {
  hostname     = "k3sc1"
  cores        = 4
  memory       = "2048"
  swap         = "512"
  password     = "123456"
  target_node  = "proxmox"
  
  unprivileged = false
  onboot        = true
  pool         = "k3s"
  clone        = "100"
  
  searchdomain = var.searchdomain
  nameserver   = var.nameserver
  network {
    name   = "eth0"
    bridge = "vmbr0"
    type   = "veth"
    firewall = true
    ip     = "192.168.1.201/24"
    gw     = var.gw
    ip6    = "auto"
    # tag    =1
  }
  rootfs {
    storage = "local-lvm"
    size = "8G"
  }
}

resource "proxmox_lxc" "k3s-worker1" {
  hostname     = "k3sw1"
  cores        = 4
  memory       = "8192"
  swap         = "512"
  password     = "123456"
  target_node  = "proxmox"

  unprivileged = false
  onboot        = true
  pool         = "k3s"
  clone        = "100"

  searchdomain = var.searchdomain
  nameserver   = var.nameserver
  network {
    name   = "eth0"
    bridge = "vmbr0"
    type   = "veth"
    firewall = true
    ip     = "192.168.1.202/24"
    gw     = var.gw
    ip6    = "auto"
    # tag    =1
  }
  rootfs {
    storage = "local-lvm"
    size = "8G"
  }
}

resource "proxmox_lxc" "k3s-worker2" {
  hostname     = "k3sw2"
  cores        = 4
  memory       = "8192"
  swap         = "512"
  password     = "123456"
  target_node  = "proxmox"

  unprivileged = false
  onboot        = true
  pool         = "k3s"
  clone        = "100"

  searchdomain = var.searchdomain
  nameserver   = var.nameserver
  network {
    name   = "eth0"
    bridge = "vmbr0"
    type   = "veth"
    firewall = true
    ip     = "192.168.1.203/24"
    gw     = var.gw
    ip6    = "auto"
    # tag    =1
  }
  rootfs {
    storage = "local-lvm"
    size = "8G"
  }
}

resource "proxmox_lxc" "k3s-worker3" {
  hostname     = "k3sw3"
  cores        = 4
  memory       = "8192"
  swap         = "512"
  password     = "123456"
  target_node  = "proxmox"

  unprivileged = false
  onboot        = true
  pool         = "k3s"
  clone        = "100"

  searchdomain = var.searchdomain
  nameserver   = var.nameserver
  network {
    name   = "eth0"
    bridge = "vmbr0"
    type   = "veth"
    firewall = true
    ip     = "192.168.1.204/24"
    gw     = var.gw
    ip6    = "auto"
    # tag    =1
  }
  rootfs {
    storage = "local-lvm"
    size = "8G"
  }
}
