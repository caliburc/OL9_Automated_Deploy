locals {
  profile         = var.vm_type_profiles[var.vm_type]
  resolved_cpus   = var.cpu_override > 0 ? var.cpu_override : local.profile.num_cpus
  resolved_memory = var.memory_gb_override > 0 ? var.memory_gb_override * 1024 : local.profile.memory_gb * 1024
  resolved_disk0_size = var.disk0_gb_override > 0 ? var.disk0_gb_override : local.profile.disk0_size_gb

  # Build a map from unitnumber to disk from the profile
  profile_disks_by_unit = {
    for d in local.profile.additional_disks :
    d.unit_number => d
  }

  # Convert per-VM additionaldisks list into a map keyed by unitnumber
  pervm_disks_by_unit = {
    for d in var.additional_disks :
    d.unit_number => d
  }

  # Merge, giving precedence to per-VM definitions
  merged_disks_by_unit = merge(
    local.profile_disks_by_unit, 
    local.pervm_disks_by_unit,
  )

  # Back to list for dynamic "disk" block
  resolved_disks = [
    for k in sort(keys(local.merged_disks_by_unit)) :
    local.merged_disks_by_unit[k]
  ]

  metadata = templatefile("${path.module}/../../templates/metadata.yaml.tftpl", {
    instance_id = var.vm_name
    hostname    = split(".", var.vm_name)[0]
    domain      = var.domain
    networks    = var.networks
  })

  userdata = templatefile("${path.module}/../../templates/userdata.yaml.tftpl", {
    hostname            = split(".", var.vm_name)[0]
    fqdn                = "${split(".", var.vm_name)[0]}.${var.domain}"
    default_user        = var.default_user
    ssh_authorized_keys = var.ssh_authorized_keys
    networks            = var.networks
  })
}

data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  count         = var.resource_pool != "" ? 1 : 0
  name          = var.resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  for_each      = { for n in var.networks : n.name => n }
  name          = each.value.portgroup
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_storage_policy" "vm_policy" {
    count = var.storage_policy_name != "" ? 1 : 0
    name = var.storage_policy_name
}

resource "vsphere_virtual_machine" "this" {
  name             = var.vm_name
  folder           = var.folder != "" ? var.folder : null
  resource_pool_id = var.resource_pool != "" ? data.vsphere_resource_pool.pool[0].id : data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = local.resolved_cpus
  memory           = local.resolved_memory
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  firmware         = local.profile.firmware
  annotation       = var.annotation

  lifecycle {
    prevent_destroy = true
  }

  storage_policy_id = var.storage_policy_name != "" ? data.vsphere_storage_policy.vm_policy[0].id : null

  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0

  dynamic "network_interface" {
    for_each = var.networks
    content {
      network_id   = data.vsphere_network.network[network_interface.value.name].id
      adapter_type = try(network_interface.value.adapter_type, "vmxnet3")
    }
  }

  disk {
    label            = "disk0"
    size             = local.resolved_disk0_size
    unit_number      = 0
    thin_provisioned = false
  }

  dynamic "disk" {
    for_each = local.resolved_disks
    content {
      label            = disk.value.label
      size             = disk.value.size_gb
      unit_number      = disk.value.unit_number
      thin_provisioned = try(disk.value.thin_provisioned, true)
      eagerly_scrub    = try(disk.value.eagerly_scrub, false)
      storage_policy_id = var.storage_policy_name != "" ? data.vsphere_storage_policy.vm_policy[0].id : null
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  extra_config = {
    "guestinfo.metadata"          = base64gzip(local.metadata)
    "guestinfo.metadata.encoding" = "gzip+base64"
    "guestinfo.userdata"          = base64gzip(local.userdata)
    "guestinfo.userdata.encoding" = "gzip+base64"
  }
}

