This example highlights the complete data collection rule setup, with a log analytics workspace as destination and associations set for both data collection rule and data collection endpoints.

## Usage

```hcl
naming = string  # Reference to the naming convention used

rule = object({
  name           = string                # Name of the data collection rule
  location       = string                # Location where the resource is deployed
  resource_group = string                # Resource group containing the data collection rule

  data_flow = map(object({               # Map of data flows for the rule
    streams      = list(string)          # List of data streams (e.g., "Microsoft-InsightsMetrics")
    destinations = list(string)          # List of destination references as defined under the destinations block (e.g., "la1")
  }))

  destinations = object({                # Object defining the destinations for the data collection rule
    log_analytics = optional(map(object({
      workspace_resource_id = string     # Resource ID of the Log Analytics workspace
    })))
  })

  associations = optional(map(object({   # Map of associations for the data collection rule
    name               = string          # Name of the association
    target_resource_id = string          # Resource ID of the target resource (e.g., VM)
    description        = optional(string) # Optional description of the association
  })))
})

endpoints = optional(map(object({                 # Map of endpoints for the deployment
  resource_group                = string  # Resource group containing the endpoint
  location                      = string  # Location where the endpoint is deployed
  public_network_access_enabled = bool    # Flag indicating if public network access is enabled
  description                   = string  # Description of the endpoint

  associations = optional(map(object({             # Map of associations for the endpoint
    target_resource_id = string           # Resource ID of the target resource (e.g., VM)
    description        = optional(string) # Optional description of the association
  })))
})))
```
