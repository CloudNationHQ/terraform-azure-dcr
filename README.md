# Data Collection Rule

This terraform module simplifies the process of creating and managing data collection rules on azure with customizable options and features, offering a flexible and powerful solution for managing azure data collection rules and endpoints through code.

## Features

Offers support for data collection rules, endpoints and their associations.

Provides multiple destination types including log analytics, event hub, storage blob, storage table, and monitor account.

Supports comprehensive data sources: performance counters, windows event logs, iis logs, syslog, platform telemetry, and custom log files.

Enables data transformation with KQL queries, built-in transforms, and custom stream declarations.

Allows associating target resources with both data collection endpoints and rules.

Utilization of terratest for robust validation.

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 4.0)

## Resources

The following resources are used by this module:

- [azurerm_monitor_data_collection_endpoint.dce](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_endpoint) (resource)
- [azurerm_monitor_data_collection_rule.dcr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule) (resource)
- [azurerm_monitor_data_collection_rule_association.dca](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) (resource)
- [azurerm_monitor_data_collection_rule.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_data_collection_rule) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_rule"></a> [rule](#input\_rule)

Description: contains all data collection rule configuration

Type:

```hcl
object({
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
        extension_json     = optional(any)
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
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_endpoints"></a> [endpoints](#input\_endpoints)

Description: contains all data collection endpoints configuration

Type:

```hcl
map(object({
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
```

Default: `{}`

### <a name="input_location"></a> [location](#input\_location)

Description: default azure region to be used

Type: `string`

Default: `null`

### <a name="input_naming"></a> [naming](#input\_naming)

Description: contains naming convention

Type: `map(string)`

Default: `{}`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: default resource group to be used

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: tags to be added to the resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_associations"></a> [associations](#output\_associations)

Description: data collection association configuration specifics

### <a name="output_endpoints"></a> [endpoints](#output\_endpoints)

Description: data collection endpoints configuration specifics

### <a name="output_rule"></a> [rule](#output\_rule)

Description: data collection rule configuration specifics
<!-- END_TF_DOCS -->

## Goals

For more information, please see our [goals and non-goals](./GOALS.md).

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

## Contributors

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md). <br><br>

<a href="https://github.com/cloudnationhq/terraform-azure-dcr/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cloudnationhq/terraform-azure-dcr" />
</a>

## Authors

Module is maintained by [these awesome contributors](https://github.com/cloudnationhq/terraform-azure-dcr/graphs/contributors).

## License

MIT Licensed. See [LICENSE](./LICENSE) for full details.

## References

- [Documentation](https://github.com/CloudNationHQ/terraform-azure-dcr#references)
    - [Collection Rules](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/data-collection-rule-overview)
    - [Collection Endpoints](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/data-collection-rule-overview)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/monitor/data-collection-rules)
- [Rest Api Specs](https://github.com/Azure/azure-rest-api-specs/tree/main/specification/monitor/resource-manager/Microsoft.Insights)
