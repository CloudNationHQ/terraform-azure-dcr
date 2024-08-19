# Default 
This example illustrates the default data collection rule setup, with a log analytics workspace as destination.

## Types

```hcl
rule = object({
  name           = string                 # Name of the data collection rule
  location       = string                 # Location where the resource is deployed
  resource_group = string                 # Resource group containing the data collection rule

  data_flow = map(object({                # Map of data flows for the rule
    streams      = list(string)           # List of data streams (e.g., "Microsoft-InsightsMetrics")
    destinations = list(string)           # List of destination references (e.g., "la1")
  }))

  destinations = object({                 # Object defining the destinations for the data collection rule
    log_analytics = optional(map(object({ # Map of log analytics destination type
      workspace_resource_id = string      # Resource ID of the Log Analytics workspace
    })))
  })
})
```
