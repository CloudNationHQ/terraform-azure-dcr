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

module "storage" {
  source  = "cloudnationhq/sa/azure"
  version = "~> 4.0"

  storage = {
    name                = module.naming.storage_account.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    blob_properties = {
      containers = {
        dcr = {
          access_type = "private"
        }
      }
    }

    tables = {
      dcrlogs = {}
    }
  }
}

module "eventhub" {
  source  = "cloudnationhq/evh/azure"
  version = "~> 3.0"

  naming = local.naming

  namespace = {
    name                = module.naming.eventhub_namespace.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    eventhubs = {
      dcrlogs = {
        partition_count   = 2
        message_retention = 1
      }
    }
  }
}

module "dcr" {
  source  = "cloudnationhq/dcr/azure"
  version = "~> 3.0"

  rule = {
    name                = module.naming.data_collection_rule.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    kind                = "AgentDirectToStore"

    data_flow = {
      df1 = {
        streams      = ["Microsoft-Syslog"]
        destinations = ["evh1", "blob1", "table1"]
      }
    }

    data_sources = {
      syslog = {
        sys1 = {
          facility_names = ["daemon"]
          log_levels     = ["Info"]
          streams        = ["Microsoft-Syslog"]
        }
      }
    }

    destinations = {
      event_hub_direct = {
        evh1 = {
          event_hub_id = module.eventhub.eventhubs.dcrlogs.id
        }
      }

      storage_blob_direct = {
        blob1 = {
          storage_account_id = module.storage.account.id
          container_name     = "dcr"
        }
      }

      storage_table_direct = {
        table1 = {
          storage_account_id = module.storage.account.id
          table_name         = "dcrlogs"
        }
      }
    }
  }
}
