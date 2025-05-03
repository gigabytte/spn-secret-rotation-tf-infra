resource "azurerm_log_analytics_workspace" "main" {
  name                = "secret-rotation-law"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30 # Adjust retention period as needed

  tags = {
    Environment = "Production"
    Purpose     = "Secret Rotation"
    ManagedBy   = "Terraform"
  }
}