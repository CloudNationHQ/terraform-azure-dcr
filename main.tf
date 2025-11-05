# data source for existing rule
data "azurerm_monitor_data_collection_rule" "existing" {
  for_each = var.rule.use_existing_rule == true ? { default = var.rule } : {}

  resource_group_name = coalesce(
    lookup(var.rule, "resource_group_name", null),
    var.resource_group_name
  )

  name = each.value.name
}

# data collection rule
resource "azurerm_monitor_data_collection_rule" "dcr" {
  for_each = var.rule.use_existing_rule == false ? { default = var.rule } : {}

  resource_group_name = coalesce(
    lookup(
      var.rule, "resource_group_name", null
    ), var.resource_group_name
  )

  location = coalesce(
    lookup(var.rule, "location", null
    ), var.location
  )

  name                        = var.rule.name
  description                 = var.rule.description
  data_collection_endpoint_id = try(var.endpoints, {}) != {} ? try(azurerm_monitor_data_collection_endpoint.dce["default"].id, null) : null
  kind                        = var.rule.kind

  destinations {
    dynamic "azure_monitor_metrics" {
      for_each = var.rule.destinations.azure_monitor_metrics != null ? { default = var.rule.destinations.azure_monitor_metrics } : {}

      content {
        name = azure_monitor_metrics.value.name
      }
    }

    dynamic "log_analytics" {
      for_each = var.rule.destinations.log_analytics

      content {
        name = coalesce(
          log_analytics.value.name, log_analytics.key
        )

        workspace_resource_id = log_analytics.value.workspace_resource_id
      }
    }

    dynamic "monitor_account" {
      for_each = var.rule.destinations.monitor_account

      content {
        name = coalesce(
          monitor_account.value.name, monitor_account.key
        )

        monitor_account_id = monitor_account.value.monitor_account_id
      }
    }

    dynamic "event_hub" {
      for_each = var.rule.destinations.event_hub

      content {
        name = coalesce(
          event_hub.value.name, event_hub.key
        )

        event_hub_id = event_hub.value.event_hub_id
      }
    }

    dynamic "event_hub_direct" {
      for_each = var.rule.destinations.event_hub_direct

      content {
        name = coalesce(
          event_hub_direct.value.name, event_hub_direct.key
        )

        event_hub_id = event_hub_direct.value.event_hub_id
      }
    }

    dynamic "storage_blob" {
      for_each = var.rule.destinations.storage_blob

      content {
        name = coalesce(
          storage_blob.value.name, storage_blob.key
        )

        storage_account_id = storage_blob.value.storage_account_id
        container_name     = storage_blob.value.container_name
      }
    }

    dynamic "storage_blob_direct" {
      for_each = var.rule.destinations.storage_blob_direct

      content {
        name = coalesce(
          storage_blob_direct.value.name, storage_blob_direct.key
        )

        storage_account_id = storage_blob_direct.value.storage_account_id
        container_name     = storage_blob_direct.value.container_name
      }
    }

    dynamic "storage_table_direct" {
      for_each = var.rule.destinations.storage_table_direct

      content {
        name = coalesce(
          storage_table_direct.value.name, storage_table_direct.key
        )

        storage_account_id = storage_table_direct.value.storage_account_id
        table_name         = storage_table_direct.value.table_name
      }
    }
  }

  dynamic "data_flow" {
    for_each = var.rule.data_flow

    content {
      streams            = data_flow.value.streams
      destinations       = data_flow.value.destinations
      built_in_transform = data_flow.value.built_in_transform
      output_stream      = data_flow.value.output_stream
      transform_kql      = data_flow.value.transform_kql
    }
  }

  dynamic "data_sources" {
    for_each = var.rule.data_sources != null ? { default = var.rule.data_sources } : {}

    content {
      dynamic "data_import" {
        for_each = data_sources.value.data_import != null ? { default = data_sources.value.data_import } : {}

        content {
          event_hub_data_source {
            name           = data_import.value.event_hub_data_source.name
            stream         = data_import.value.event_hub_data_source.stream
            consumer_group = data_import.value.event_hub_data_source.consumer_group
          }
        }
      }

      dynamic "syslog" {
        for_each = data_sources.value.syslog

        content {
          name = coalesce(
            syslog.value.name, syslog.key
          )

          facility_names = syslog.value.facility_names
          log_levels     = syslog.value.log_levels
          streams        = syslog.value.streams
        }
      }

      dynamic "iis_log" {
        for_each = data_sources.value.iis_log

        content {
          name = coalesce(
            iis_log.value.name, iis_log.key
          )

          streams         = iis_log.value.streams
          log_directories = iis_log.value.log_directories
        }
      }

      dynamic "log_file" {
        for_each = data_sources.value.log_file

        content {
          name = coalesce(
            log_file.value.name, log_file.key
          )

          streams       = log_file.value.streams
          format        = log_file.value.format
          file_patterns = log_file.value.file_patterns

          dynamic "settings" {
            for_each = log_file.value.settings

            content {
              text {
                record_start_timestamp_format = settings.value.text.record_start_timestamp_format
              }
            }
          }
        }
      }

      dynamic "performance_counter" {
        for_each = data_sources.value.performance_counter

        content {
          name = coalesce(
            performance_counter.value.name, performance_counter.key
          )

          streams                       = performance_counter.value.streams
          sampling_frequency_in_seconds = performance_counter.value.sampling_frequency_in_seconds
          counter_specifiers            = performance_counter.value.counter_specifiers
        }
      }

      dynamic "platform_telemetry" {
        for_each = data_sources.value.platform_telemetry

        content {
          name = coalesce(
            platform_telemetry.value.name, platform_telemetry.key
          )

          streams = platform_telemetry.value.streams
        }
      }

      dynamic "prometheus_forwarder" {
        for_each = data_sources.value.prometheus_forwarder

        content {
          name = coalesce(
            prometheus_forwarder.value.name, prometheus_forwarder.key
          )

          streams = prometheus_forwarder.value.streams

          dynamic "label_include_filter" {
            for_each = prometheus_forwarder.value.label_include_filter

            content {
              label = label_include_filter.value.name
              value = label_include_filter.value.value
            }
          }
        }
      }

      dynamic "windows_event_log" {
        for_each = data_sources.value.windows_event_log

        content {
          name = coalesce(
            windows_event_log.value.name, windows_event_log.key
          )

          streams        = windows_event_log.value.streams
          x_path_queries = windows_event_log.value.x_path_queries
        }
      }

      dynamic "windows_firewall_log" {
        for_each = data_sources.value.windows_firewall_log

        content {
          name = coalesce(
            windows_firewall_log.value.name, windows_firewall_log.key
          )

          streams = windows_firewall_log.value.streams
        }
      }

      dynamic "extension" {
        for_each = data_sources.value.extension

        content {
          name = coalesce(
            extension.value.name, extension.key
          )

          streams            = extension.value.streams
          input_data_sources = extension.value.input_data_sources
          extension_name     = extension.value.extension_name
          extension_json     = try(extension.value.extension_json, null) != null ? jsonencode(extension.value.extension_json) : null
          name               = try(extension.value.name, extension.key)
        }
      }
    }
  }

  dynamic "stream_declaration" {
    for_each = var.rule.stream_declaration != null ? { default = var.rule.stream_declaration } : {}

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
    for_each = var.rule.identity != null ? { default = var.rule.identity } : {}

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  tags = coalesce(
    var.rule.tags, var.tags
  )
}

# data collection endpoints
resource "azurerm_monitor_data_collection_endpoint" "dce" {
  for_each = var.endpoints

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.data_collection_endpoint, each.key]), null),
    each.key
  )

  resource_group_name = coalesce(
    lookup(each.value, "resource_group_name", null),
    var.resource_group_name
  )

  location = coalesce(
    lookup(each.value, "location", null
    ), var.location
  )

  kind                          = each.value.kind
  public_network_access_enabled = each.value.public_network_access_enabled
  description                   = each.value.description

  tags = coalesce(
    var.rule.tags, var.tags
  )
}

# data collection rule associations
resource "azurerm_monitor_data_collection_rule_association" "dca" {
  for_each = merge(
    {
      for key, ra in var.rule.associations : key => {
        name               = ra.name
        target_resource_id = ra.target_resource_id
        description        = ra.description
        data_collection_rule_id = var.rule.use_existing_rule == false ? (
          azurerm_monitor_data_collection_rule.dcr["default"].id
          ) : (
          data.azurerm_monitor_data_collection_rule.existing["default"].id
        )
        data_collection_endpoint_id = null
      }
    },
    merge([
      for key_ep, ep in var.endpoints : {
        for key_ea, ea in ep.associations : key_ea => {
          name                        = ea.name
          target_resource_id          = ea.target_resource_id
          description                 = ea.description
          data_collection_rule_id     = null
          data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce[key_ep].id
        }
      }
    ]...)
  )

  name                        = each.value.name
  target_resource_id          = each.value.target_resource_id
  data_collection_rule_id     = each.value.data_collection_rule_id
  data_collection_endpoint_id = each.value.data_collection_endpoint_id
  description                 = each.value.description
}
