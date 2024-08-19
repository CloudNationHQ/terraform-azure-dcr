module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

  suffix = ["dcr", "def"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 0.1"

  groups = {
    demo = {
      name   = module.naming.resource_group.name
      region = "westeurope"
    }
  }
}

module "law" {
  source  = "cloudnationhq/law/azure"
  version = "~> 1.0"

  workspace = {
    name           = module.naming.log_analytics_workspace.name
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
  }
}

module "dcr" {
  # source  = "cloudnationhq/dcr/azure"
  # version = "~> 0.1"

  source = "../../"

  rule = {
    name           = module.naming.data_collection_rule.name
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name

    data_flow = {
      df1 = {
        streams      = ["Microsoft-InsightsMetrics"]
        destinations = ["la1"]
      }
    }

    destinations = {
      log_analytics = {
        la1 = {
          workspace_resource_id = module.law.workspace.id
        }
      }
    }
  }
}
