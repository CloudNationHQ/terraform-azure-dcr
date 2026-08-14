moved {
  from = azurerm_monitor_data_collection_rule.dcr["default"]
  to   = azurerm_monitor_data_collection_rule.this["this"]
}

moved {
  from = azurerm_monitor_data_collection_endpoint.dce
  to   = azurerm_monitor_data_collection_endpoint.this
}

moved {
  from = azurerm_monitor_data_collection_rule_association.dca
  to   = azurerm_monitor_data_collection_rule_association.this
}
