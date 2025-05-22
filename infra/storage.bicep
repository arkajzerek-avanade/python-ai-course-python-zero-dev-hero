param location string = resourceGroup().location

@minLength(3)
@maxLength(24)
param storageAccountName string

resource sa 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

