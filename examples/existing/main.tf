module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.25"

  suffix = ["dcr", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name
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

module "network-weu" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 9.0"

  naming = local.naming

  vnet = {
    name                = module.naming.virtual_network.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    address_space       = ["10.18.0.0/16"]

    subnets = {
      int = {
        address_prefixes       = ["10.18.1.0/24"]
        network_security_group = {}
      }
    }
  }
}

module "network-uks" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 9.0"

  naming = local.naming

  vnet = {
    name                = "${module.naming.virtual_network.name}-uks"
    location            = "uksouth"
    resource_group_name = module.rg.groups.demo.name
    address_space       = ["10.18.0.0/16"]

    subnets = {
      int = {
        address_prefixes = ["10.18.1.0/24"]
        network_security_group = {
          name = "nsg-dcr-exis-int-uks"
        }
      }
    }
  }
}

module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 4.0"

  naming = local.naming

  vault = {
    name                = module.naming.key_vault.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}

module "vm" {
  source  = "cloudnationhq/vm/azure"
  version = "~> 6.0"

  keyvault   = module.kv.vault.id
  naming     = local.naming
  depends_on = [module.kv]

  instance = {
    type                = "linux"
    name                = module.naming.linux_virtual_machine.name
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location

    generate_ssh_key = {
      enable = true
    }

    source_image_reference = {
      offer     = "0001-com-ubuntu-server-jammy"
      publisher = "Canonical"
      sku       = "22_04-lts-gen2"
    }

    interfaces = {
      int = {
        ip_configurations = {
          config1 = {
            subnet_id = module.network-weu.subnets.int.id
            primary   = true
          }
        }
      }
    }
  }
}

module "vm2" {
  source  = "cloudnationhq/vm/azure"
  version = "~> 6.0"

  keyvault   = module.kv.vault.id
  naming     = local.naming
  depends_on = [module.kv]

  instance = {
    type                = "windows"
    name                = "${module.naming.windows_virtual_machine.name}2"
    resource_group_name = module.rg.groups.demo.name
    location            = "uksouth"

    generate_password = {
      enable = true
    }

    source_image_reference = {
      offer     = "WindowsServer"
      publisher = "MicrosoftWindowsServer"
      sku       = "2022-Datacenter"
    }

    interfaces = {
      int2 = {
        ip_configurations = {
          config1 = {
            subnet_id = module.network-uks.subnets.int.id
            primary   = true
          }
        }
      }
    }
  }
}

module "dcr" {
  source  = "cloudnationhq/dcr/azure"
  version = "~> 3.0"

  naming = local.naming

  rule = {
    name                = "dcr-demo-dev"
    location            = module.rg.groups.demo.location
    resource_group_name = "rg-demo-dev"

    use_existing_rule = true

    data_flow = {
      df1 = {
        streams      = ["Microsoft-InsightsMetrics"]
        destinations = ["destination-log-la1"]
      }
    }

    destinations = {
      log_analytics = {
        la1 = {
          name                  = "destination-log-la1"
          workspace_resource_id = module.law.workspace.id
        }
      }
    }

    associations = {
      vm = {
        name               = "association-dcr-vm"
        target_resource_id = module.vm.instance.id
        description        = "association dcr - vm"
      }

      vm2 = {
        name               = "association-dcr-vm2"
        target_resource_id = module.vm2.instance.id
        description        = "association dcr - vm2"
      }
    }
  }

  endpoints = {
    default = {
      resource_group_name           = module.rg.groups.demo.name
      location                      = module.rg.groups.demo.location
      public_network_access_enabled = true
      description                   = "default endpoint"

      associations = {
        vm = {
          target_resource_id = module.vm.instance.id
          description        = "association dce - vm"
        }
      }
    }

    additional = {
      resource_group_name           = module.rg.groups.demo.name
      location                      = module.vm2.instance.location
      public_network_access_enabled = true
      description                   = "additional endpoint"

      associations = {
        vm2 = {
          target_resource_id = module.vm2.instance.id
          description        = "association dce - vm2"
        }
      }
    }
  }
}
