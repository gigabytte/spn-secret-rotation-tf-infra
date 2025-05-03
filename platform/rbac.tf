// Required RBAC for the Function Apps to access the Event Hub
resource "azurerm_role_assignment" "event_processor_receiver" {
  scope                = azurerm_eventhub_namespace.main.id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = azurerm_linux_function_app.event_processor.identity[0].principal_id
}

resource "azurerm_role_assignment" "event_processor_sender" {
  scope                = azurerm_eventhub_namespace.main.id
  role_definition_name = "Azure Event Hubs Data Sender"
  principal_id         = azurerm_linux_function_app.event_processor.identity[0].principal_id
}

resource "azurerm_role_assignment" "event_consumer_receiver" {
  scope                = azurerm_eventhub_namespace.main.id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = azurerm_linux_function_app.event_consumer.identity[0].principal_id
}
// -------------------------------------------------------
// Required RBAC for Alert group to send alerts to the Event Hub and create alerts in Az Monitor
resource "azurerm_role_assignment" "monitor_log_analytics" {
  scope                = azurerm_log_analytics_workspace.main.id
  role_definition_name = "Log Analytics Reader"
  principal_id         = azurerm_monitor_scheduled_query_rules_alert_v2.secret_expiration.identity[0].principal_id
}

resource "azurerm_role_assignment" "monitor_eventhub" {
  scope                = azurerm_eventhub_namespace.main.id
  role_definition_name = "Azure Event Hubs Data Sender"
  principal_id         = azurerm_monitor_scheduled_query_rules_alert_v2.secret_expiration.identity[0].principal_id
}

resource "azurerm_role_assignment" "monitor_contrib" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azurerm_monitor_scheduled_query_rules_alert_v2.secret_expiration.identity[0].principal_id
}
// -------------------------------------------------------
