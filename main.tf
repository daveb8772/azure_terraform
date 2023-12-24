resource "azurerm_user_assigned_identity" "my_managed_identity" {
  name                = "my-tf-managed-identity"
  location            = "westeurope" # Replace with your managed identity location
  resource_group_name = "k8s-resource-group"
}



# Configure Azure provider
provider "azurerm" {
  features {}

}

terraform {
  backend "azurerm" {
    storage_account_name = "mystorage1701447817" # Replace with your storage account name
    container_name       = "mycontainer123"      # Replace with your container name
    key                  = "terraform.tfstate"
    resource_group_name  = "k8s-resource-group" # Replace with your resource group name

  }
}

# Resource Group
resource "azurerm_resource_group" "k8s_rg" {
  name     = "k8s-resource-group"
  location = "West Europe" # Updated location
}

# Virtual Network and Subnet
resource "azurerm_virtual_network" "k8s_vnet" {
  name                = "k8s-virtual-network"
  location            = azurerm_resource_group.k8s_rg.location
  resource_group_name = azurerm_resource_group.k8s_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "k8s_subnet" {
  name                 = "k8s-subnet"
  resource_group_name  = azurerm_resource_group.k8s_rg.name
  virtual_network_name = azurerm_virtual_network.k8s_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}



# Azure Kubernetes Service (AKS) Cluster
resource "azurerm_kubernetes_cluster" "k8s_cluster" {
  name                = "my-aks-cluster"
  location            = azurerm_resource_group.k8s_rg.location
  resource_group_name = azurerm_resource_group.k8s_rg.name
  dns_prefix          = "myaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2" # Choose a suitable VM size
  }


  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "learning"
  }
}

# Azure Storage Account
resource "azurerm_storage_account" "storage_account" {
  name                     = "mystorage1701447817"
  resource_group_name      = azurerm_resource_group.k8s_rg.name
  location                 = azurerm_resource_group.k8s_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}



resource "azurerm_role_definition" "role_assignment_contributor" {
  name = "Role Assignment Owner"
  #scope       = azurerm_management_group.root.id
  scope = "/subscriptions/fa2afcb7-6cbe-4c32-9cda-2b621a34c7e7"

  description = "A role designed for writing and deleting role assignments"

  permissions {
    actions = [
      "Microsoft.Authorization/roleAssignments/write",
      "Microsoft.Authorization/roleAssignments/delete",
    ]
    not_actions = []
  }

  assignable_scopes = [
    "/subscriptions/fa2afcb7-6cbe-4c32-9cda-2b621a34c7e7"
  ]
}


# resource "azurerm_role_assignment" "blob_storage_access" {
#   scope              = "/subscriptions/fa2afcb7-6cbe-4c32-9cda-2b621a34c7e7/resourceGroups/k8s-resource-group/providers/Microsoft.Storage/storageAccounts/mystorage1701447817" # Replace with your storage account scope
#   role_definition_id = azurerm_role_definition.role_assignment_contributor.id
#   principal_id       = var.principal_id # Replace with the principalId obtained


# }

# resource "azurerm_role_assignment" "aks_to_storage" {
#   scope              = "/subscriptions/fa2afcb7-6cbe-4c32-9cda-2b621a34c7e7/resourcegroups/k8s-resource-group/providers/Microsoft.Storage/storageAccounts/mystorage1701447817" # Replace with the ID of the target resource
#   role_definition_id = azurerm_role_definition.role_assignment_contributor.id                                                                                                  # Replace with the desired role name
#   principal_id       = var.principal_id                                                                                                                                        # Replace with the principalId obtained

# }



# Blob Container
resource "azurerm_storage_container" "storage_container" {
  name                  = "mycontainer123"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}



# Azure Key Vault using variables
resource "azurerm_key_vault" "example_kv" {
  name                = "mykeyvault1701447817"
  location            = azurerm_resource_group.k8s_rg.location
  resource_group_name = azurerm_resource_group.k8s_rg.name
  sku_name            = "standard"
  tenant_id           = var.tenant_id


  # Define the key vault access policy separately
  purge_protection_enabled   = false
}

data "azurerm_key_vault_secret" "example_kv_secret" {
  name         = "postgres"
  key_vault_id = azurerm_key_vault.example_kv.id
}

resource "azurerm_postgresql_server" "example" {
  name                = "example-psql-server"  # Replace with your desired name
  location            = azurerm_resource_group.k8s_rg.location
  resource_group_name = azurerm_resource_group.k8s_rg.name
  sku_name = "B_Gen5_1" # Basic Tier (B_Gen5_1):  cost-effective option - 1 vCore and 5 GB of storage.

  storage_mb                   = 5120          # Adjust the storage size as needed
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "postgres"   # Replace with your admin username
  administrator_login_password = data.azurerm_key_vault_secret.example_kv_secret.value

  version                      = "11"          # Specify your PostgreSQL version
  ssl_enforcement_enabled      = true          # Set to true or false as needed
}



# Reference the access policy defined in a separate file
module "key_vault_access_policy" {
  source = "./access_policy" # Assuming the access policy is defined in a separate folder named "access_policy"

}


# Output for Virtual Network ID:
output "virtual_network_id" {
  value = azurerm_virtual_network.k8s_vnet.id
}

# Output for Subnet ID:
output "subnet_id" {
  value = azurerm_subnet.k8s_subnet.id
}

# Output for Storage Account ID:
output "storage_account_id" {
  value = azurerm_storage_account.storage_account.id
}

# Output for Key Vault ID:
output "key_vault_id" {
  value = azurerm_key_vault.example_kv.id
}

# Output for Resource Group ID:
output "resource_group_id" {
  value = azurerm_resource_group.k8s_rg.id
}

# Output AKS Cluster Details
output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.k8s_cluster.id
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.k8s_cluster.name
}
