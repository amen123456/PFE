terraform {
  required_version = ">= 1.7.0" 
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "= 1.15.0"
    }
  }
}
provider "vsphere" {
  user                 = var.vsphere_login
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}
//----data sources---//
///getting the datacenter
data "vsphere_datacenter" "datacenter" {
  name = var.datacenter_name
}
///getting the cluster
data "vsphere_compute_cluster" "cluster" {
  name = var.cluster_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
data "vsphere_datastore" "datastore" {
  name = var.datastore_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
///getting the network
data "vsphere_network" "network" {
  name = var.network_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
//getting the vm template
data "vsphere_virtual_machine" "template" {
  name = var.template_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
//----end data sources---//
//--ressources--//
resource "vsphere_virtual_machine" "vm_machine" {
  count = 3
  name = format("VM-%s", ["Master", "Worker1", "Worker2"][count.index])
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  folder = "Amen allah Ben Khalifa"
  datastore_id = data.vsphere_datastore.datastore.id
  guest_id = "ubuntu64Guest"
  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }
  disk {
    label = "disk0"
    size  = 120
    thin_provisioned = false
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    timeout       = 60
  }
}

output "vm_ip_addresses" {
  value = {for vm in vsphere_virtual_machine.vm_machine : vm.name => vm.default_ip_address}
}