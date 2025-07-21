module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

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
  version = "~> 2.0"

  workspace = {
    name           = module.naming.log_analytics_workspace.name
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
  }
}

module "dcr" {
  source  = "cloudnationhq/dcr/azure"
  version = "~> 2.0"

  naming = local.naming

  rule = {
    name           = module.naming.data_collection_rule.name
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name

    data_flow = {
      df1 = {
        streams      = ["Microsoft-InsightsMetrics"]
        destinations = ["law1111"]
      }
    }

    data_sources = {
      iis_log = {
        iis_log1 = {
          streams         = ["Microsoft-W3CIISLog"]
          log_directories = ["C:\\inetpub\\logs\\LogFiles\\W3SVC1"]
        }
      }
      log_file = {
        custom_log_1 = {
          format        = "text"
          streams       = ["Custom-LogTable"]
          file_patterns = ["C:\\App\\logs\\*.log"]
        }
      }
    }

    destinations = {
      log_analytics = {
        law1111 = {
          workspace_resource_id = module.law.workspace.id
        }
      }
    }
  }
}
