module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.32"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 3.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "law" {
  source  = "cloudnationhq/law/azure"
  version = "~> 4.0"

  workspace = {
    name                = module.naming.log_analytics_workspace.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 10.0"


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

module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 6.0"


  vault = {
    name                = module.naming.key_vault.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    secrets = {
      tls_keys = {
        vm1 = {
          algorithm = "RSA"
          rsa_bits  = 2048
        }
      }

      random_string = {
        vm2 = {
          length  = 24
          special = false
        }
      }
    }
  }
}

module "vm" {
  source  = "cloudnationhq/vm/azure"
  version = "~> 8.0"

  virtual_machine = {
    type                = "linux"
    name                = module.naming.linux_virtual_machine.name
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location
    size                = "Standard_D2s_v3"
    username            = "adminuser"
    public_key          = module.kv.tls_public_keys.vm1.value

    os_disk = {
      storage_account_type = "Standard_LRS"
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
            subnet_id = module.network.subnets.int.id
            primary   = true
          }
        }
      }
    }
  }
}

module "vm2" {
  source  = "cloudnationhq/vm/azure"
  version = "~> 8.0"

  virtual_machine = {
    type                = "windows"
    name                = "${module.naming.windows_virtual_machine.name}2"
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location
    size                = "Standard_D2s_v3"
    username            = "adminuser"
    password            = module.kv.secrets.vm2.value

    os_disk = {
      storage_account_type = "Standard_LRS"
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
            subnet_id = module.network.subnets.int.id
            primary   = true
          }
        }
      }
    }
  }
}

module "dcr" {
  source  = "cloudnationhq/dcr/azure"
  version = "~> 4.0"

  rule = {
    name                = module.naming.data_collection_rule.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    data_collection_endpoint_key = "default"

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

    associations = {
      vm = {
        name               = "association-dcr-vm"
        target_resource_id = module.vm.virtual_machine.id
        description        = "association dcr - vm"
      }

      vm2 = {
        name               = "association-dcr-vm2"
        target_resource_id = module.vm2.virtual_machine.id
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
          target_resource_id = module.vm.virtual_machine.id
          description        = "association dce - vm"
        }
      }
    }

    additional = {
      resource_group_name           = module.rg.groups.demo.name
      location                      = module.rg.groups.demo.location
      public_network_access_enabled = true
      description                   = "additional endpoint"

      associations = {
        vm2 = {
          target_resource_id = module.vm2.virtual_machine.id
          description        = "association dce - vm2"
        }
      }
    }
  }
}
