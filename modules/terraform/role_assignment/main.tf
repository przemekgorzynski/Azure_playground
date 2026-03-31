terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm]
    }
  }
}

resource "azurerm_role_assignment" "this" {
  scope                = var.scope
  principal_id         = var.principal_id
  role_definition_id   = "/providers/Microsoft.Authorization/roleDefinitions/${var.role_definition_id}"
  principal_type       = var.principal_type
}