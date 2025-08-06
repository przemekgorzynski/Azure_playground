# Azure_playground
Azure_playground


## Backend_Subscription

Subscription used for backend support such as Terraform state storage.

## 🔍 List available subscriptions

```bash
az account list --output table
```

## 🔄 Set active subscription

```bash
az account set --subscription "Backend_Subscription"
```

## 🗄️ Create Storage Account for Terraform state

```bash
az storage account create \
  --name sa4tfstates \
  --resource-group sa-4-terraform-states \
  --location polandcentral \
  --sku Standard_LRS \
  --kind Storage
```
