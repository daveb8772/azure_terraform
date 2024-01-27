
# Terraform Infrastructure for Azure Kubernetes Service (AKS)

## Overview

This Terraform configuration sets up an Azure Kubernetes Service (AKS) environment. It provisions a range of resources in Azure to support a Kubernetes cluster, including networking components, storage, and a managed identity. This setup is ideal for running containerized applications in a scalable and managed Kubernetes environment.

## Infrastructure Components

- **Resource Group (`azurerm_resource_group`):** A resource group named 'k8s-resource-group' to organize all Azure resources.
- **Virtual Network (`azurerm_virtual_network`):** A virtual network named 'k8s-virtual-network' with an address space of `10.0.0.0/16`.
- **Subnet (`azurerm_subnet`):** A subnet named 'k8s-subnet' within the virtual network, with an address prefix of `10.0.1.0/24`.
- **Azure Kubernetes Service Cluster (`azurerm_kubernetes_cluster`):** An AKS cluster named 'my-aks-cluster' with a default node pool.
- **User Assigned Identity (`azurerm_user_assigned_identity`):** A managed identity for AKS named 'my-tf-managed-identity'.
- **Storage Account (`azurerm_storage_account`):** A storage account named 'mystorage1701447817' for blob storage.
- **Storage Container (`azurerm_storage_container`):** A private storage container named 'mycontainer123' in the storage account.
- **Azure Key Vault (`azurerm_key_vault`):** A Key Vault named 'mykeyvault1701447817' for secure storage of secrets.
- **Azure PostgreSQL Server (`azurerm_postgresql_server`):** A PostgreSQL server named 'example-psql-server' for database services.

## Azure Authentication and Key Vault Access

Before applying the Terraform configurations, authenticate with Azure using:

```bash
az login
```
A web browser will prompt for login credentials. Alternatively, use the device code flow with:

```bash
az login --use-device-code
``` 


For setting up the Key Vault access policy, run:

```bash
keyVaultName="mykeyvault1701447817"
objectId="61aa2c03-789a-4100-82ad-5f06d017d0b4"
subscriptionId="fa2afcb7-6cbe-4c32-9cda-2b621a34c7e7"

az keyvault set-policy --name $keyVaultName --object-id $objectId --secret-permissions get --subscription $subscriptionId
```

## Running Terraform

Ensure Terraform is installed and configured on your machine. Then, execute the following commands in your terminal:

```bash
terraform init
terraform plan
terraform apply
```

##Terraform  Apply Outputs:

- aks_cluster_id = "/subscriptions/fa2afcb7-6cbe-4c32-9cda-2b621a34c7e7/resourceGroups/k8s-resource-group/providers/Microsoft.ContainerService/managedClusters/my-aks-cluster"
- aks_cluster_name = "my-aks-cluster"
- key_vault_id = "/subscriptions/fa2afcb7-6cbe-4c32-9cda-2b621a34c7e7/resourceGroups/k8s-resource-group/providers/Microsoft.KeyVault/vaults/mykeyvault1701447817"
- resource_group_id = "/subscriptions/fa2afcb7-6cbe-4c32-9cda-2b621a34c7e7/resourceGroups/k8s-resource-group"
- storage_account_id = "/subscriptions/fa2afcb7-6cbe-4c32-9cda-2b621a34c7e7/resourceGroups/k8s-resource-group/providers/Microsoft.Storage/storageAccounts/mystorage1701447817"
- subnet_id = "/subscriptions/fa2afcb7-6cbe-4c32-9cda-2b621a34c7e7/resourceGroups/k8s-resource-group/providers/Microsoft.Network/virtualNetworks/k8s-virtual-network/subnets/k8s-subnet"
- virtual_network_id = "/subscriptions/fa2afcb7-6cbe-4c32-9cda-2b621a34c7e7/resourceGroups/k8s-resource-group/providers/Microsoft.Network/virtualNetworks/k8s-virtual-network"
