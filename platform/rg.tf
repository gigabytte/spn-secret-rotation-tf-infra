resource "azurerm_resource_group" "main" {
  name     = "secret-rotation-rg"
  location = var.location

  tags = {
    Environment = "Production"
    Purpose     = "Secret Rotation"
    ManagedBy   = "Terraform"
  }
}