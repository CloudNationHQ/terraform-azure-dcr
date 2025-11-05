variable "rule" {
  description = "contains all data collection rule configuration"
  type = object({
    name                = string
    resource_group_name = optional(string)
    location            = optional(string)
    description         = optional(string)
    kind                = optional(string)
    tags                = optional(map(string))
    use_existing_rule   = optional(bool, false)
    destinations = object({
      azure_monitor_metrics = optional(object({
        name = string
      }), null)
      log_analytics = optional(map(object({
        workspace_resource_id = string
        name                  = optional(string)
      })), {})
      monitor_account = optional(map(object({
        monitor_account_id = string
        name               = optional(string)
      })), {})
      event_hub = optional(map(object({
        event_hub_id = string
        name         = optional(string)
      })), {})
      event_hub_direct = optional(map(object({
        event_hub_id = string
        name         = optional(string)
      })), {})
      storage_blob = optional(map(object({
        storage_account_id = string
        container_name     = string
        name               = optional(string)
      })), {})
      storage_blob_direct = optional(map(object({
        storage_account_id = string
        container_name     = string
        name               = optional(string)
      })), {})
      storage_table_direct = optional(map(object({
        storage_account_id = string
        table_name         = string
        name               = optional(string)
      })), {})
    })
    data_flow = map(object({
      streams            = list(string)
      destinations       = list(string)
      built_in_transform = optional(string)
      output_stream      = optional(string)
      transform_kql      = optional(string)
    }))
    data_sources = optional(object({
      data_import = optional(object({
        event_hub_data_source = object({
          name           = string
          stream         = string
          consumer_group = optional(string)
        })
      }), null)
      syslog = optional(map(object({
        facility_names = list(string)
        log_levels     = list(string)
        name           = optional(string)
        streams        = list(string)
      })), {})
      iis_log = optional(map(object({
        streams         = list(string)
        name            = optional(string)
        log_directories = optional(list(string), [])
      })), {})
      log_file = optional(map(object({
        streams       = list(string)
        name          = optional(string)
        format        = string
        file_patterns = list(string)
        settings = optional(map(object({
          text = object({
            record_start_timestamp_format = string
          })
        })), {})
      })), {})
      performance_counter = optional(map(object({
        streams                       = list(string)
        sampling_frequency_in_seconds = number
        counter_specifiers            = list(string)
        name                          = optional(string)
      })), {})
      platform_telemetry = optional(map(object({
        streams = list(string)
        name    = optional(string)
      })), {})
      prometheus_forwarder = optional(map(object({
        streams = list(string)
        name    = optional(string)
        label_include_filter = optional(map(object({
          name  = string
          value = string
        })), {})
      })), {})
      windows_event_log = optional(map(object({
        streams        = list(string)
        x_path_queries = list(string)
        name           = optional(string)
      })), {})
      windows_firewall_log = optional(map(object({
        streams = list(string)
        name    = optional(string)
      })), {})
      extension = optional(map(object({
        streams            = list(string)
        input_data_sources = list(string)
        extension_name     = string
        extension_json     = any
        name               = optional(string)
      })), {})
    }), null)
    stream_declaration = optional(object({
      stream_name = string
      column = list(object({
        name = string
        type = string
      }))
    }), null)
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string), [])
    }), null)
    associations = optional(map(object({
      name               = string
      target_resource_id = string
      description        = optional(string)
    })), {})
  })

  validation {
    condition     = var.rule.resource_group_name != null || var.resource_group_name != null
    error_message = "Resource group name must be provided either in the rule object or as a separate variable."
  }

  validation {
    condition     = var.rule.location != null || var.location != null
    error_message = "Location must be provided either in the rule object or as a separate variable."
  }
}

variable "endpoints" {
  description = "contains all data collection endpoints configuration"
  type = map(object({
    name                          = optional(string)
    resource_group_name           = optional(string)
    location                      = optional(string)
    kind                          = optional(string)
    public_network_access_enabled = optional(bool, true)
    description                   = optional(string)
    tags                          = optional(map(string))
    associations = optional(map(object({
      name               = optional(string, "configurationAccessEndpoint")
      target_resource_id = string
      description        = optional(string)
    })), {})
  }))
  default = {}
}

variable "naming" {
  description = "contains naming convention"
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "default azure region to be used"
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "default resource group to be used"
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
