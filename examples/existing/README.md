This example highlights the usage of an existing data collection rule.

## Usage

```hcl
naming = string

rule = object({
  name              = string
  location          = string
  resource_group    = string
  use_existing_rule = optional(bool)

  data_flow = map(object({
    streams      = list(string)
    destinations = list(string)
  }))

  destinations = object({
    log_analytics = optional(map(object({
      name                  = string
      workspace_resource_id = strin
    })))
  })

  associations = map(object({
    name               = string
    target_resource_id = string
    description        = option
  }))
})

endpoints = map(object({
  resource_group                = string
  location                      = string
  public_network_access_enabled = bool
  description                   = string

  associations = map(object({
    target_resource_id = string
    description        = optional(string)
  }))
}))
```
