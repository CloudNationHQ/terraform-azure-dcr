data "azurerm_monitor_data_collection_rule" "existing" {
  for_each = lookup(var.rule, "use_existing_rule", false) == true ? { default = var.rule } : {}

  name                = each.value.name
  resource_group_name = each.value.resource_group
}

resource "azurerm_monitor_data_collection_rule" "dcr" {
  for_each = lookup(var.rule, "use_existing_rule", null) == null ? { default = var.rule } : {}

  name                        = var.rule.name
  resource_group_name         = coalesce(lookup(var.rule, "resource_group", null), var.resource_group)
  location                    = coalesce(lookup(var.rule, "location", null), var.location)
  description                 = try(var.rule.description, null)
  data_collection_endpoint_id = try(var.endpoints, {}) != {} ? try(azurerm_monitor_data_collection_endpoint.dce["default"].id, null) : null
  kind                        = try(var.rule.kind, null)

  destinations {
    dynamic "azure_monitor_metrics" {
      for_each = try(var.rule.destinations.azure_monitor_metrics, null) != null ? { default = var.rule.destinations.azure_monitor_metrics } : {}

      content {
        name = azure_monitor_metrics.value.name
      }
    }

    dynamic "log_analytics" {
      for_each = { for key, la in try(var.rule.destinations.log_analytics, {}) : key => la }

      content {
        workspace_resource_id = log_analytics.value.workspace_resource_id
        name                  = try(log_analytics.value.name, log_analytics.key)
      }
    }

    dynamic "monitor_account" {
      for_each = { for key, ma in try(var.rule.destinations.monitor_account, {}) : key => ma }

      content {
        monitor_account_id = monitor_account.value.monitor_account_id
        name               = try(monitor_account.value.name, monitor_account.key)
      }
    }

    dynamic "event_hub" {
      for_each = { for key, eh in try(var.rule.destinations.event_hub, {}) : key => eh }

      content {
        event_hub_id = event_hub.value.event_hub_id
        name         = try(event_hub.value.name, event_hub.key)
      }
    }

    dynamic "event_hub_direct" {
      for_each = { for key, eh in try(var.rule.destinations.event_hub_direct, {}) : key => eh }

      content {
        event_hub_id = event_hub_direct.value.event_hub_id
        name         = try(event_hub_direct.value.name, event_hub_direct.key)
      }
    }

    dynamic "storage_blob" {
      for_each = { for key, sb in try(var.rule.destinations.storage_blob, {}) : key => sb }

      content {
        storage_account_id = storage_blob.value.storage_account_id
        container_name     = storage_blob.value.container_name
        name               = try(storage_blob.value.name, storage_blob.key)
      }
    }

    dynamic "storage_blob_direct" {
      for_each = { for key, sb in try(var.rule.destinations.storage_blob_direct, {}) : key => sb }

      content {
        storage_account_id = storage_blob_direct.value.storage_account_id
        container_name     = storage_blob_direct.value.container_name
        name               = try(storage_blob_direct.value.name, storage_blob_direct.key)
      }
    }

    dynamic "storage_table_direct" {
      for_each = { for key, st in try(var.rule.destinations.storage_table_direct, {}) : key => st }

      content {
        storage_account_id = storage_table_direct.value.storage_account_id
        table_name         = storage_table_direct.value.table_name
        name               = try(storage_table_direct.value.name, storage_table_direct.key)
      }
    }
  }

  dynamic "data_flow" {
    for_each = var.rule.data_flow

    content {
      streams            = data_flow.value.streams
      destinations       = data_flow.value.destinations
      built_in_transform = try(data_flow.value.built_in_transform, null)
      output_stream      = try(data_flow.value.output_stream, null)
      transform_kql      = try(data_flow.value.transform_kql, null)
    }
  }

  dynamic "data_sources" {
    for_each = length(try(var.rule.data_sources, {})) > 0 ? [1] : []
    content {
      dynamic "data_import" {
        for_each = try(var.rule.data_sources.data_import, null) != null ? { default = var.rule.data_sources.data_import } : {}
        content {
          event_hub_data_source {
            name           = data_import.value.event_hub_data_source.name
            stream         = data_import.value.event_hub_data_source.stream
            consumer_group = data_import.value.event_hub_data_source.consumer_group
          }
        }
      }

      dynamic "syslog" {
        for_each = { for key, sl in try(var.rule.data_sources.syslog, {}) : key => sl }
        content {
          facility_names = syslog.value.facility_names
          log_levels     = syslog.value.log_levels
          name           = try(syslog.value.name, syslog.key)
          streams        = syslog.value.streams
        }
      }

      dynamic "iis_log" {
        for_each = { for key, il in try(var.rule.data_sources.iis_log, {}) : key => il }
        content {
          streams         = iis_log.value.streams
          name            = try(iis_log.value.name, iis_log.key)
          log_directories = try(iis_log.value.log_directories, [])
        }
      }

      dynamic "log_file" {
        for_each = { for key, lf in try(var.rule.data_sources.log_file, {}) : key => lf }
        content {
          streams       = log_file.value.streams
          name          = try(log_file.value.name, log_file.key)
          format        = log_file.value.format
          file_patterns = log_file.value.file_patterns
          dynamic "settings" {
            for_each = { for key, se in try(log_file.value.settings, {}) : key => se }
            content {
              text {
                record_start_timestamp_format = settings.value.text.record_start_timestamp_format
              }
            }
          }
        }
      }

      dynamic "performance_counter" {
        for_each = { for key, pc in try(var.rule.data_sources.performance_counter, {}) : key => pc }
        content {
          streams                       = performance_counter.value.streams
          sampling_frequency_in_seconds = performance_counter.value.sampling_frequency_in_seconds
          counter_specifiers            = performance_counter.value.counter_specifiers
          name                          = try(performance_counter.value.name, performance_counter.key)
        }
      }

      dynamic "platform_telemetry" {
        for_each = { for key, pt in try(data_sources.value.platform_telemetry, {}) : key => pt }
        content {
          streams = platform_telemetry.value.streams
          name    = try(platform_telemetry.value.name, platform_telemetry.key)
        }
      }

      dynamic "prometheus_forwarder" {
        for_each = { for key, pf in try(var.rule.data_sources.prometheus_forwarder, {}) : key => pf }
        content {
          streams = prometheus_forwarder.value.streams
          name    = try(prometheus_forwarder.value.name, prometheus_forwarder.key)

          dynamic "label_include_filter" {
            for_each = { for key, lf in try(prometheus_forwarder.value.label_include_filter, {}) : key => lf }
            content {
              label = label_include_filter.value.name
              value = label_include_filter.value.value
            }
          }
        }
      }

      dynamic "windows_event_log" {
        for_each = { for key, wel in try(var.rule.data_sources.windows_event_log, {}) : key => wel }
        content {
          streams        = windows_event_log.value.streams
          x_path_queries = windows_event_log.value.x_path_queries
          name           = try(windows_event_log.value.name, windows_event_log.key)
        }
      }

      dynamic "windows_firewall_log" {
        for_each = { for key, wfl in try(var.rule.data_sources.windows_firewall_log, {}) : key => wfl }
        content {
          streams = windows_firewall_log.value.streams
          name    = try(windows_firewall_log.value.name, windows_firewall_log.key)
        }
      }

      dynamic "extension" {
        for_each = { for key, ex in try(var.rule.data_sources.extension, {}) : key => ex }
        content {
          streams            = extension.value.streams
          input_data_sources = extension.value.input_data_sources
          extension_name     = extension.value.extension_name
          extension_json     = jsonencode(extension.value.extension_json)
          name               = try(extension.value.name, extension.key)
        }
      }
    }
  }

  dynamic "stream_declaration" {
    for_each = try(var.rule.stream_declaration, null) != null ? { default = var.rule.stream_declaration } : {}

    content {
      stream_name = stream_declaration.value.stream_name

      dynamic "column" {
        for_each = stream_declaration.value.column

        content {
          name = column.value.name
          type = column.value.type
        }
      }
    }
  }

  dynamic "identity" {
    for_each = try(var.rule.identity, null) != null ? { default = var.rule.identity } : {}

    content {
      type         = identity.value.type
      identity_ids = try(each.value.identity_ids, [])
    }
  }

  tags = try(var.rule.tags, var.tags, {})
}

resource "azurerm_monitor_data_collection_endpoint" "dce" {
  for_each = {
    for key, dce in var.endpoints : key => dce
  }
  name                          = try(each.value.name, join("-", [var.naming.data_collection_endpoint, each.key]))
  resource_group_name           = try(each.value.resource_group, var.resource_group)
  location                      = try(each.value.location, var.location)
  kind                          = try(each.value.kind, null)
  public_network_access_enabled = try(each.value.public_network_access_enabled, true)
  description                   = try(each.value.description, null)
  tags                          = try(each.value.tags, var.tags, {})
}

resource "azurerm_monitor_data_collection_rule_association" "dca" {
  for_each = {
    for key, dca in local.merged_associations : key => dca
  }

  name                        = each.value.name
  target_resource_id          = each.value.target_resource_id
  data_collection_rule_id     = try(each.value.data_collection_rule_id, null)
  data_collection_endpoint_id = try(each.value.data_collection_endpoint_id, null)
  description                 = each.value.description
}
