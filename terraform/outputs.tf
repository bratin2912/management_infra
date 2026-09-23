output "vm_public_ip" {
  description = "Public IPv4 address of the application VM."
  value       = azurerm_public_ip.main.ip_address
}

output "vm_name" {
  description = "Application VM name."
  value       = azurerm_linux_virtual_machine.main.name
}

output "resource_group_name" {
  description = "Resource group containing this deployment."
  value       = azurerm_resource_group.main.name
}

output "storage_account_name" {
  description = "Storage account used by the application."
  value       = azurerm_storage_account.documents.name
}

output "gst_container_name" {
  description = "Private GST document container."
  value       = azurerm_storage_container.gst_documents.name
}

output "ssh_command" {
  description = "SSH command using your configured SSH agent or default key."
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
}

output "blob_endpoint" {
  description = "HTTPS endpoint for the document archive."
  value       = azurerm_storage_account.documents.primary_blob_endpoint
}
