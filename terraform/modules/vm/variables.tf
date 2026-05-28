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

variable "vm_name" {
  type = string
}

variable "vm_type" {
  type = string
}

variable "template_name" {
  type = string
}

variable "datacenter" {
  type = string
}

variable "cluster" {
  type = string
}

variable "datastore" {
  type = string
}

variable "folder" {
  type = string
}

variable "resource_pool" {
  type = string
}

variable "annotation" {
  type = string
}

variable "networks" {
  type = list(object({
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
  }))
  default = []
}

variable "additional_disks" {
  type = list(object({
    label            = string
    size_gb          = number
    unit_number      = number
    thin_provisioned = optional(bool, false)
    eagerly_scrub    = optional(bool, false)
  }))
  default = []
}

variable "storage_policy_name" {
  type    = string
  default = "" # Optional
}

variable "ssh_authorized_keys" {
  type    = list(string)
  default = []
}

variable "default_user" {
  type = string
}

variable "domain" {
  type = string
}

variable "dns_servers" {
  type    = list(string)
  default = []
}

variable "dns_search" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "disk0_gb_override" {
  type    = number
  default = 0
}

variable "cpu_override" {
  type    = number
  default = 0
}

variable "memory_gb_override" {
  type    = number
  default = 0
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
      thin_provisioned = optional(bool, false)
      eagerly_scrub    = optional(bool, false)
    }))
  }))
}