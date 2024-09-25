This example highlights the complete data collection rule setup, with a log analytics workspace as destination and associations set for both data collection rule and data collection endpoints.

## Usage

```hcl
naming = string

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

  associations = optional(map(object({
    name               = string
    target_resource_id = string
    description        = optional(string)
  })))
})

endpoints = optional(map(object({
  resource_group                = string
  location                      = string
  public_network_access_enabled = bool
  description                   = string

  associations = optional(map(object({
    target_resource_id = string
    description        = optional(string)
  })))
})))
```
