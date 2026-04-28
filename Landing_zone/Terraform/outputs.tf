output "nva_private_ip" {
  description = "NVA private IP"
  value       = var.deploy_nva ? module.nva[0].private_ip : null
}

output "nva_public_ip" {
  description = "NVA public IP"
  value       = var.deploy_nva && var.nva_public_ip ? module.nva[0].public_ip : null
}

output "spoke1_vm_private_ip" {
  description = "Spoke1 VM private IP"
  value       = var.deploy_spoke1_vm ? module.spoke1_vm[0].private_ip : null
}

output "spoke1_vm_public_ip" {
  description = "Spoke1 VM public IP"
  value       = var.deploy_spoke1_vm && var.spoke1_vm_public_ip ? module.spoke1_vm[0].public_ip : null
}
