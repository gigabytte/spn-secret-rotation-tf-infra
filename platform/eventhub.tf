resource "azurerm_eventhub_namespace" "main" {
  name                = "secret-rotation-events"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                = "Standard"
  capacity           = 1

  network_rulesets {
    default_action                 = "Deny"
    public_network_access_enabled  = true
    trusted_service_access_enabled = true
    
    virtual_network_rule {
      subnet_id = azurerm_subnet.function.id
    }
  }

  tags = {
    Environment = "Production"
    Purpose     = "Secret Rotation"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_eventhub" "log_query_alerts" {
  name                = "log-query-alert-events"
  namespace_id      = azurerm_eventhub_namespace.main.id
  partition_count     = 2
  message_retention   = 1  # Retention in days
}

resource "azurerm_eventhub" "secret_expiration" {
  name                = "secret-exp-events"
  namespace_id       = azurerm_eventhub_namespace.main.id
  partition_count     = 2
  message_retention   = 1  # Retention in days
}