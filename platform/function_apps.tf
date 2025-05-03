data "azurerm_client_config" "current" {}

resource "azurerm_linux_function_app" "event_processor" {
  name                       = "event-processor-ctrl"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  service_plan_id            = azurerm_service_plan.main.id
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      use_custom_runtime = true
    }
    use_32_bit_worker = false
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "custom"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }

  tags = {
    Environment = "Production"
    Purpose     = "Secret Rotation"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_linux_function_app" "event_consumer" {
  name                       = "event-consumer-ctrl"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  service_plan_id            = azurerm_service_plan.main.id
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      use_custom_runtime = true
    }
    use_32_bit_worker = false
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "custom"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }

  tags = {
    Environment = "Production"
    Purpose     = "Secret Rotation"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_linux_function_app" "webhooks" {
  name                       = "secret-rotation-webhooks"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  service_plan_id            = azurerm_service_plan.main.id
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      use_custom_runtime = true
    }
    use_32_bit_worker = false
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"                 = "custom"
    "WEBSITE_RUN_FROM_PACKAGE"                 = "1"
    "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET" = azuread_application_password.webhook_auth.value
  }

  auth_settings_v2 {
    auth_enabled = true

    active_directory_v2 {
      client_id                  = azuread_application.webhook_auth.client_id
      tenant_auth_endpoint       = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0"
      client_secret_setting_name = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"

      allowed_applications = [
        azuread_application.webhook_auth.client_id
      ]

    }

    login {}

    require_authentication = true
    unauthenticated_action = "Return401"
    default_provider       = "AzureActiveDirectory"
  }

  tags = {
    Environment = "Production"
    Purpose     = "Secret Rotation"
    ManagedBy   = "Terraform"
  }
}