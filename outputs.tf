output "endpoints" {
  description = "data collection endpoints configuration specifics"
  value       = azurerm_monitor_data_collection_endpoint.dce
}

output "rule" {
  description = "data collection rule configuration specifics"
  value       = azurerm_monitor_data_collection_rule.dcr
}

output "associations" {
  description = "data collection association configuration specifics"
  value       = azurerm_monitor_data_collection_rule_association.dca
}
