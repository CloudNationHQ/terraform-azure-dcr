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

module "dcr" {
  source  = "cloudnationhq/dcr/azure"
  version = "~> 3.0"

  naming = local.naming

  rule = {
    name                = module.naming.data_collection_rule.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    kind                = "WorkspaceTransforms"

    data_flow = {
      df1 = {
        streams       = ["Microsoft-Table-LAQueryLogs"]
        destinations  = ["la1"]
        transform_kql = "source | where QueryText !contains 'LAQueryLogs' | extend Context = parse_json(RequestContext) | extend Resources_CF = tostring(Context['workspaces'])"
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
