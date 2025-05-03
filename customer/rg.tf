resource "azurerm_resource_group" "main" {
  name     = "team-a-rg"
  location = var.location

  tags = {
    Environment = "Production"
    Purpose     = "Secret Rotation"
    ManagedBy   = "Terraform"
  }
}