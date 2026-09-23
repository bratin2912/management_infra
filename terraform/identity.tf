resource "azurerm_role_assignment" "vm_blob_access" {
  scope                = azurerm_storage_container.gst_documents.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_virtual_machine.main.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}
