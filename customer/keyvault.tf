resource "azurerm_key_vault" "main" {
  name                        = "team-a-kv"
  location                    = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  enabled_for_disk_encryption = true
  tenant_id                  = var.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  sku_name                   = "standard"

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = {
    Environment = "Production"
    Purpose     = "Secret Rotation"
    ManagedBy   = "Terraform"
  }
}

data "azurerm_log_analytics_workspace" "platform" {
  name                = "secret-rotation-law"
  resource_group_name = "secret-rotation-rg"
}

resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  name                       = "keyVaultAuditLogs"
  target_resource_id         = azurerm_key_vault.main.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.platform.id

  enabled_log {
    category = "AuditEvent"
  }
}