variable "vsphere_server" {
  type = string
}

variable "vsphere_user" {
  type = string
}

variable "vsphere_password" {
  type      = string
  sensitive = true
}

variable "allow_unverified_ssl" {
  type    = bool
  default = true
}

variable "default_user" {
  type    = string
  default = "hedcadm"
}

variable "ssh_authorized_keys" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vm_type_profiles" {
  type = map(object({
    num_cpus      = number
    memory_gb     = number
    firmware      = string
    disk0_size_gb = number
    additional_disks = list(object({
      label            = string
      size_gb          = number
      unit_number      = number
      thin_provisioned = optional(bool, true)
      eagerly_scrub    = optional(bool, false)
    }))
  }))
}

variable "vms" {
  type = map(object({
    vm_name    = string
    vm_type    = string
    annotation = optional(string, "")

    # Per‑VM vSphere placement
    vsphere_datacenter    = string
    vsphere_cluster       = string
    vsphere_datastore     = string
    vsphere_folder        = optional(string, "")
    vsphere_resource_pool = optional(string, "")
    template_name         = string

    vm_domain = optional(string, "idm.hedc.mil")

    # Optional per‑VM DNS server list (you can also load from CSV in Ansible)
    dns_servers = optional(list(string), [])

    networks = optional(list(object({
      name               = string
      portgroup          = string
      adapter_type       = optional(string, "vmxnet3")
      ipv4_address       = optional(string)
      ipv4_prefix_length = optional(number)
      ipv4_gateway       = optional(string)
      dns_servers        = optional(list(string), [])
      dns_search         = optional(list(string), [])
      dhcp4              = optional(bool, false)
      default_gateway    = optional(bool, false)
      routes = optional(list(object({
        to  = string
        via = string
      })), [])
    })), [])

    additional_disks = optional(list(object({
      label            = string
      size_gb          = number
      unit_number      = number
      thin_provisioned = optional(bool, false)
      eagerly_scrub    = optional(bool, false)
    })), [])

    cpu_override       = optional(number, 0)
    memory_gb_override = optional(number, 0)
    disk0_gb_override  = optional(number, 0) ### NEW DATA ###
  }))
}

