resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_in_days
  daily_quota_gb      = var.daily_quota_gb

  # Disable local auth; queries go through Entra ID.
  local_authentication_disabled = true

  tags = var.tags
}

resource "azurerm_monitor_action_group" "this" {
  name                = "ag-${var.name}"
  resource_group_name = var.resource_group_name
  short_name          = substr(replace(var.name, "/[^a-zA-Z0-9]/", ""), 0, 12)

  dynamic "email_receiver" {
    for_each = var.action_group_email_receivers
    content {
      name                    = email_receiver.key
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }

  tags = var.tags
}

# Example alert: spike in failed Entra ID sign-ins / Key Vault denied operations is
# operationalized via the AzureActivity table. Adjust the query to your needs.
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "activity_errors" {
  name                = "alert-${var.name}-activity-errors"
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = "PT15M"
  window_duration      = "PT15M"
  scopes               = [azurerm_log_analytics_workspace.this.id]
  severity             = 2

  criteria {
    query                   = <<-KQL
      AzureActivity
      | where ActivityStatusValue == "Failure"
      | summarize Count = count() by bin(TimeGenerated, 5m), OperationNameValue
    KQL
    time_aggregation_method = "Count"
    threshold               = 10
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.this.id]
  }

  tags = var.tags
}
