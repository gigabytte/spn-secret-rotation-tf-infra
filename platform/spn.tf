resource "random_uuid" "webhook_access_all" {}

resource "azuread_application" "webhook_auth" {
  display_name            = "team-a-webhook-auth"
  group_membership_claims = ["ApplicationGroup"]
  owners                  = [data.azuread_client_config.current.object_id]

  web {
    redirect_uris = ["https://localhost/"]

    implicit_grant {
      access_token_issuance_enabled = true
    }
  }

  app_role {
    allowed_member_types = ["Application"]
    description          = "Allows access to the webhook function secret rotation functions"
    display_name         = "Secret Rotation Webhook Access"
    enabled              = true
    id                   = random_uuid.webhook_access_all.result
    value                = "WebhookAccess.All"
  }
}

resource "azuread_service_principal" "webhook_auth" {
  client_id = azuread_application.webhook_auth.client_id
}

resource "azuread_application_password" "webhook_auth" {
  application_id = azuread_application.webhook_auth.object_id
  end_date       = timeadd(timestamp(), "168h") # 7 days from now
  display_name   = "secret"
}

# Assign app roles to function apps
resource "azuread_app_role_assignment" "event_consumer" {
  app_role_id         = random_uuid.webhook_access_all.result
  principal_object_id = azurerm_linux_function_app.event_consumer.identity[0].principal_id
  resource_object_id  = azuread_service_principal.webhook_auth.object_id
}

# Get current Azure context if not already defined
data "azuread_client_config" "current" {}