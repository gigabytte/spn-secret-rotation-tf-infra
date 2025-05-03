resource "azurerm_monitor_action_group" "secret_alerts" {
  name                = "az-func-entsr-queue-feeder"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "entsrqf"

  event_hub_receiver {
    name                    = "secret-expiration-receiver"
    event_hub_name         = azurerm_eventhub.log_query_alerts.name
    event_hub_namespace    = azurerm_eventhub_namespace.main.name
    subscription_id        = var.subscription_id
    use_common_alert_schema = true
  }

  tags = {
    Environment = "Production"
    Purpose     = "Secret Rotation"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "secret_expiration" {
  name                = "corp-dev-001-secret-lifecycle-exp-alert"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  evaluation_frequency = "PT1H"
  window_duration     = "PT1H"
  scopes              = [azurerm_log_analytics_workspace.main.id]
  severity            = 1
  description         = "Alert every hour if the query returns results"
  enabled             = true

  criteria {
    query                   = <<-QUERY
      AzureDiagnostics
      | where OperationName == "SecretExpiredEventGridNotification" or OperationName == "SecretNearExpiryEventGridNotification"
      | extend SecretVersionId = tostring(split(eventGridEventProperties_data_Id_s, "/")[-1])
      | where TimeGenerated >= ago(1h)
      | project
          TimeGenerated,
          EventType = OperationName,
          ResourceGroup,
          SubscriptionId,
          KeyVaultName = Resource,
          SecretName = eventGridEventProperties_data_ObjectName_s,
          SecretVersionId
    QUERY
    time_aggregation_method = "Count"
    operator               = "GreaterThan"
    threshold              = 0
  }

  auto_mitigation_enabled = true

  action {
    action_groups = [azurerm_monitor_action_group.secret_alerts.id]
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
    Purpose     = "Secret Rotation"
    ManagedBy   = "Terraform"
  }
}