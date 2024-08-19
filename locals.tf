locals {
  rule_associations = flatten([
    for key, ra in lookup(var.rule, "associations", {}) : [
      {
        name                    = ra.name
        target_resource_id      = ra.target_resource_id
        description             = try(ra.description, null)
        data_collection_rule_id = lookup(var.rule, "use_existing_rule", null) == null ? azurerm_monitor_data_collection_rule.dcr["default"].id : data.azurerm_monitor_data_collection_rule.existing["default"].id
      }
    ]
  ])

  endpoint_associations = flatten([
    for key_ep, ep in var.endpoints : [
      for key_ea, ea in lookup(ep, "associations", {}) : [
        {
          key                         = key_ea
          name                        = "configurationAccessEndpoint" ## An association of data collection endpoint must be named 'configurationAccessEndpoint' 
          target_resource_id          = ea.target_resource_id
          description                 = try(ea.description, null)
          data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce[key_ep].id
        }
    ]]
  ])


  merged_associations = merge(
    { for key, as in local.rule_associations : as.name => as },
    { for key, as in local.endpoint_associations : as.key => as }
  )

}
