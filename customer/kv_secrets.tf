resource "azurerm_key_vault_secret" "spn" {
  name         = "test-spn-credentials"
  value        = azuread_application_password.spn.value
  key_vault_id = azurerm_key_vault.main.id

  tags = {
    secret_type          = "spn"
    secret_object_id     = azuread_service_principal.spn.object_id
    secret_owner_mailbox = "team1@outlook.com"
  }

  depends_on = [azurerm_key_vault_access_policy.terraform]
}

# Add access policy for Terraform to manage secrets
resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = var.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete"
  ]
}

# Get current Azure context
data "azurerm_client_config" "current" {}
