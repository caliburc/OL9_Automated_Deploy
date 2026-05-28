output "vm_ids" {
  description = "vSphere IDs for all created VMs"
  value = {
    for name, mod in module.vm : name => mod.vm_id
  }
}

output "vm_names" {
  description = "Names of all created VMs"
  value       = keys(var.vms)
}