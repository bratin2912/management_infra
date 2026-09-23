resource "azurerm_storage_account" "documents" {
  name = replace(
    lower("st${var.project_name}${var.environment}"),
    "-",
    ""
  )

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  # General-purpose v2 storage
  account_kind = "StorageV2"

  # ============================================================
  # SECURITY
  # ============================================================

  # Equivalent intent of DenyInsecureTransport.
  https_traffic_only_enabled = true

  min_tls_version = "TLS1_2"

  # Equivalent of S3 Block Public Access.
  allow_nested_items_to_be_public = false

  # Recommended if application authenticates using Azure AD /
  # Managed Identity instead of account keys.
  shared_access_key_enabled = false

  # ============================================================
  # BLOB VERSIONING
  # ============================================================

  blob_properties {
    versioning_enabled = true

    # Protection against accidental deletion.
    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }

  tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
    purpose     = "gst-invoice-archive"
  }

  lifecycle {
    prevent_destroy = true
  }
}


resource "azurerm_storage_container" "gst_documents" {
  name = "gst-documents"

  storage_account_id = azurerm_storage_account.documents.id

  container_access_type = "private"
}