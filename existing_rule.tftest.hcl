mock_provider "azurerm" {
  mock_data "azurerm_monitor_data_collection_rule" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dcr/providers/Microsoft.Insights/dataCollectionRules/dcr-existing"
    }
  }
}

variables {
  location            = "westeurope"
  resource_group_name = "rg-fallback"
}

run "existing_rule_lookup" {
  command = plan

  variables {
    rule = {
      name                = "dcr-existing"
      resource_group_name = "rg-dcr"
      use_existing_rule   = true

      data_flow = {
        df1 = {
          streams      = ["Microsoft-Syslog"]
          destinations = ["law1"]
        }
      }

      destinations = {
        log_analytics = {
          law1 = {
            workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dcr/providers/Microsoft.OperationalInsights/workspaces/law-demo"
          }
        }
      }

      associations = {
        vm = {
          target_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dcr/providers/Microsoft.Compute/virtualMachines/vm-demo"
        }
      }
    }
  }

  assert {
    condition = length(data.azurerm_monitor_data_collection_rule.this) == 1 && length(azurerm_monitor_data_collection_rule.this) == 0
    error_message = format(
      "use_existing_rule must select the data source, got %d data source instance(s) and %d managed rule(s)",
      length(data.azurerm_monitor_data_collection_rule.this),
      length(azurerm_monitor_data_collection_rule.this),
    )
  }

  assert {
    condition = data.azurerm_monitor_data_collection_rule.this["this"].resource_group_name == "rg-dcr"
    error_message = format(
      "existing rule must be looked up in rule.resource_group_name (\"rg-dcr\"), got %q - %s",
      data.azurerm_monitor_data_collection_rule.this["this"].resource_group_name,
      data.azurerm_monitor_data_collection_rule.this["this"].resource_group_name == "rg-fallback" ? "the coalesce fell through to var.resource_group_name" : "unexpected resource group",
    )
  }

  assert {
    condition = azurerm_monitor_data_collection_rule_association.this["vm"].data_collection_rule_id == data.azurerm_monitor_data_collection_rule.this["this"].id
    error_message = format(
      "association must attach to the existing rule id, got %q",
      azurerm_monitor_data_collection_rule_association.this["vm"].data_collection_rule_id,
    )
  }

  assert {
    condition = azurerm_monitor_data_collection_rule_association.this["vm"].name == "vm"
    error_message = format(
      "association name must fall back to its map key, got %q",
      azurerm_monitor_data_collection_rule_association.this["vm"].name,
    )
  }
}

run "existing_rule_lookup_falls_back_to_module_resource_group" {
  command = plan

  variables {
    rule = {
      name              = "dcr-existing"
      use_existing_rule = true

      data_flow = {
        df1 = {
          streams      = ["Microsoft-Syslog"]
          destinations = ["law1"]
        }
      }

      destinations = {
        log_analytics = {
          law1 = {
            workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dcr/providers/Microsoft.OperationalInsights/workspaces/law-demo"
          }
        }
      }
    }
  }

  assert {
    condition = data.azurerm_monitor_data_collection_rule.this["this"].resource_group_name == "rg-fallback"
    error_message = format(
      "without rule.resource_group_name the lookup must use var.resource_group_name (\"rg-fallback\"), got %q",
      data.azurerm_monitor_data_collection_rule.this["this"].resource_group_name,
    )
  }
}

run "managed_rule_when_flag_not_set" {
  command = apply

  override_resource {
    target = azurerm_monitor_data_collection_rule.this["this"]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dcr/providers/Microsoft.Insights/dataCollectionRules/dcr-managed"
    }
  }

  override_resource {
    target = azurerm_monitor_data_collection_endpoint.this["primary"]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dcr/providers/Microsoft.Insights/dataCollectionEndpoints/dce-primary"
    }
  }

  variables {
    rule = {
      name = "dcr-managed"

      data_collection_endpoint_key = "primary"

      data_flow = {
        df1 = {
          streams      = ["Microsoft-Syslog"]
          destinations = ["law1"]
        }
      }

      destinations = {
        log_analytics = {
          law1 = {
            workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dcr/providers/Microsoft.OperationalInsights/workspaces/law-demo"
          }
        }
      }

      associations = {
        vm = {
          name               = "association-dcr-vm"
          target_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dcr/providers/Microsoft.Compute/virtualMachines/vm-demo"
        }
      }
    }

    endpoints = {
      primary = {
        associations = {
          vm = {
            target_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dcr/providers/Microsoft.Compute/virtualMachines/vm-demo"
          }
        }
      }
    }
  }

  assert {
    condition = length(data.azurerm_monitor_data_collection_rule.this) == 0 && length(azurerm_monitor_data_collection_rule.this) == 1
    error_message = format(
      "without use_existing_rule the rule must be created and nothing looked up, got %d data source instance(s) and %d managed rule(s)",
      length(data.azurerm_monitor_data_collection_rule.this),
      length(azurerm_monitor_data_collection_rule.this),
    )
  }

  assert {
    condition = azurerm_monitor_data_collection_rule.this["this"].data_collection_endpoint_id == azurerm_monitor_data_collection_endpoint.this["primary"].id
    error_message = format(
      "data_collection_endpoint_key must resolve to the endpoint id, got %q",
      azurerm_monitor_data_collection_rule.this["this"].data_collection_endpoint_id,
    )
  }

  assert {
    condition = azurerm_monitor_data_collection_rule_association.this["vm"].data_collection_rule_id == azurerm_monitor_data_collection_rule.this["this"].id
    error_message = format(
      "rule association must attach to the created rule id, got %q",
      azurerm_monitor_data_collection_rule_association.this["vm"].data_collection_rule_id,
    )
  }

  assert {
    condition = azurerm_monitor_data_collection_rule_association.this["primary.vm"].data_collection_endpoint_id == azurerm_monitor_data_collection_endpoint.this["primary"].id
    error_message = format(
      "endpoint associations must be keyed \"<endpoint>.<association>\" and attach to that endpoint, got %q",
      azurerm_monitor_data_collection_rule_association.this["primary.vm"].data_collection_endpoint_id,
    )
  }

  assert {
    condition = azurerm_monitor_data_collection_rule_association.this["primary.vm"].name == "configurationAccessEndpoint"
    error_message = format(
      "endpoint association name must default to \"configurationAccessEndpoint\" (the only name azure accepts), got %q",
      azurerm_monitor_data_collection_rule_association.this["primary.vm"].name,
    )
  }
}
