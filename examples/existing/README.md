This example highlights the usage of an existing data collection rule.

## Usage

```hcl
naming = string  # Reference to the naming convention used

rule = object({
  name              = string                # Name of the data collection rule
  location          = string                # Location where the resource is deployed
  resource_group    = string                # Resource group containing the data collection rule
  use_existing_rule = optional(bool)        # Optional flag to indicate if an existing rule should be used

  data_flow = map(object({                  # Map of data flows for the rule
    streams      = list(string)             # List of data streams (e.g., "Microsoft-InsightsMetrics")
    destinations = list(string)             # List of destination references (e.g., "la1")
  }))

  destinations = object({                   # Object defining the destinations for the data collection rule
    log_analytics = optional(map(object({
      name                  = string        # Name of the log analytics destination
      workspace_resource_id = string        # Resource ID of the Log Analytics workspace
    })))
  })

  associations = map(object({               # Map of associations for the rule
    name               = string             # Name of the association
    target_resource_id = string             # Resource ID of the target resource (e.g., VM)
    description        = optional(string)   # Optional description of the association
  }))
})

endpoints = map(object({                    # Map of endpoints for the deployment
  resource_group                = string    # Resource group containing the endpoint
  location                      = string    # Location where the endpoint is deployed
  public_network_access_enabled = bool      # Flag indicating if public network access is enabled
  description                   = string    # Description of the endpoint

  associations = map(object({               # Map of associations for the endpoint
    target_resource_id = string             # Resource ID of the target resource (e.g., VM)
    description        = optional(string)   # Optional description of the association
  }))
}))
```
