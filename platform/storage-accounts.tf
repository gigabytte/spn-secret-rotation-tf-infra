resource "azurerm_storage_account" "function_storage" {
  name                     = "secretrotationfnstore"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  tags = {
    Environment = "Production"
    Purpose     = "Secret Rotation"
    ManagedBy   = "Terraform"
  }
}