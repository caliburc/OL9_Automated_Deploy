terraform {
  required_version = ">= 1.5.0"

  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 2.5.0"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = var.allow_unverified_ssl
}

module "vm" {
  source   = "./modules/vm"
  for_each = var.vms

  vsphere_server   = var.vsphere_server
  vsphere_user     = var.vsphere_user
  vsphere_password = var.vsphere_password

  vm_name       = each.value.vm_name
  vm_type       = each.value.vm_type
  template_name = each.value.template_name

  datacenter    = each.value.vsphere_datacenter
  cluster       = each.value.vsphere_cluster
  datastore     = each.value.vsphere_datastore
  folder        = try(each.value.vsphere_folder, "")
  resource_pool = try(each.value.vsphere_resource_pool, "")

  annotation       = try(each.value.annotation, "")
  networks         = try(each.value.networks, [])
  additional_disks = try(each.value.additional_disks, [])

  ssh_authorized_keys = var.ssh_authorized_keys
  default_user        = var.default_user

  # Per‑VM domain/DNS; fall back to global defaults if you add them later
  domain      = try(each.value.vm_domain, "idm.hedc.mil")
  dns_servers = try(each.value.dns_servers, [])

  tags = var.tags

  cpu_override       = try(each.value.cpu_override, 0)
  memory_gb_override = try(each.value.memory_gb_override, 0)
  disk0_gb_override  = try(each.value.disk0_gb_override, 0)

  vm_type_profiles = var.vm_type_profiles
  storage_policy_name = "VM Encryption Policy"
}

