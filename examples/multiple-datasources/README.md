This example highlights the complete data collection rule setup, with a log analytics workspace as destination and associations set for both data collection rule and data collection endpoints.

## Usage

```hcl
naming = string

rule = {
  name           = string
  location       = string
  resource_group = string

  data_flow = optional(map(object({
    streams            = list(string)
    destinations       = list(string)
    built_in_transform = optional(string)
    output_stream      = optional(string)
    transform_kql      = optional(string)
  })), {})

  data_sources = optional(object({
    iis_log = optional(map(object({
      streams         = list(string)
      log_directories = optional(list(string), [])
      name            = optional(string)
    })), {})
    log_file = optional(map(object({
      format        = string
      streams       = list(string)
      file_patterns = list(string)
      name          = optional(string)
      settings      = optional(map(object({
        text = object({
          record_start_timestamp_format = string
        })
      })), {})
    })), {})
    # Add additional types (syslog, performance_counter, etc.) as needed, following this pattern
  }), {})

  destinations = optional(object({
    log_analytics = optional(map(object({
      workspace_resource_id = string
      name                  = optional(string)
    })), {})
    # Add more destination types if needed (monitor_account, event_hub, etc.)
  }), {})

  # Add more fields here if your structure requires them (e.g., tags, description, etc.)
}
```
