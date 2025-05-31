provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  allow_unverified_ssl = true
}

# Récupération du datacenter
data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

# Récupération du datastore partagé
data "vsphere_datastore" "datastore" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Récupération du cluster ESXi
data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Récupération du réseau "VLAN-SERVER"
data "vsphere_network" "vlan_server" {
  name          = "VLAN-SERVER"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Récupération du template Windows Server avec VMware Tools installé
data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Création des 2 VM
resource "vsphere_virtual_machine" "win2025_vm" {
  count            = 2
  name             = "win2025-vm-${count.index + 1}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = 16384
  guest_id = "windows9Server64Guest" # Adapté pour Windows Server 2022+, compatible 2025

  scsi_type = "lsilogic"

  network_interface {
    network_id   = data.vsphere_network.vlan_server.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = 60
    thin_provisioned = true
  }

  cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path         = "iso/Windows_Server_2025.iso" # ISO présente sur le datastore
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      windows_options {
        computer_name  = "win2025-${count.index + 1}"
        admin_password = var.admin_password
      }

      network_interface {
        ipv4_address = "192.168.10.${10 + count.index}" # IPs statiques : .10 et .11
        subnet_mask  = 24
      }

      ipv4_gateway = var.gateway
    }
  }

  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
}
