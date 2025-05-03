resource "azuread_application" "spn" {
  display_name = "team-a-spn"
}

resource "azuread_service_principal" "spn" {
  client_id = azuread_application.spn.client_id
}
// We create an SPN password with a 7-day expiration to
//  ensure both near expiry and expiry events are triggered by the AKV
resource "azuread_application_password" "spn" {
  application_id = azuread_application.spn.object_id
  end_date       = timeadd(timestamp(), "168h") # 7 days from now
  display_name   = "secret"
  // We only want to use TF to define the SPN secret NOT rotate it
  lifecycle {
    ignore_changes = [
      end_date,
      value
    ]
  }
}
