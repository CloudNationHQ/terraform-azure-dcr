module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.25"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "law" {
  source  = "cloudnationhq/law/azure"
  version = "~> 3.0"

  workspace = {
    name                = module.naming.log_analytics_workspace.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}

module "dcr_windows" {
  source  = "cloudnationhq/dcr/azure"
  version = "~> 3.0"

  rule = {
    name                = module.naming.data_collection_rule.name
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location

    destinations = {
      log_analytics = {
        la1 = {
          workspace_resource_id = module.law.workspace.id
        }
      }
    }

    data_flow = {
      df_perf = {
        streams      = ["Microsoft-Perf"]
        destinations = ["la1"]
      }
    }

    data_sources = {
      performance_counter = {
        cpu = {
          streams                       = ["Microsoft-Perf"]
          sampling_frequency_in_seconds = 60
          counter_specifiers = [
            "\\Processor(_Total)\\%% Processor Time",
            "\\Memory\\Available Bytes"
          ]
        }
        memory = {
          streams                       = ["Microsoft-Perf"]
          sampling_frequency_in_seconds = 30
          counter_specifiers = [
            "\\Memory\\Available Bytes",
            "\\Memory\\%% Committed Bytes In Use"
          ]
        }
      }
    }
  }
}
