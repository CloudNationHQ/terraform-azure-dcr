# Default
This example illustrates the default data collection rule setup, with a log analytics workspace as destination.

## Types

```hcl
rule = object({
  name           = string
  location       = string
  resource_group = string

  data_flow = map(object({
    streams      = list(string)
    destinations = list(string)
  }))

  destinations = object({
    log_analytics = optional(map(object({
      workspace_resource_id = string
    })))
  })
})
```
