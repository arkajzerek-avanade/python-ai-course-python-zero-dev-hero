@description('The location for the resources.')
param location string = resourceGroup().location

@description('A base name for the resources.')
@minLength(3)
param baseName string = 'n8napp${uniqueString(resourceGroup().id)}'

@description('The n8n Docker image to deploy.')
param n8nImage string = 'n8nio/n8n:latest'

@description('The target port for ingress.')
param targetPort int = 5678

var logAnalyticsWorkspaceName = '${baseName}-logs'
var containerAppEnvName = '${baseName}-env'
var containerAppName = '${baseName}-ca'

// Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// Storage Account
var storageAccountName = replace('${baseName}st', '-', '')
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

// File Share
var fileShareName = 'n8ndata'
resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = {
  name: '${storageAccount.name}/default/${fileShareName}'
}

// Container App Environment
resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: containerAppEnvName
  location: location
  sku: {
    name: 'Consumption'
  }
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

resource n8nstorage 'Microsoft.App/managedEnvironments/storages@2023-05-01' = {
  parent: containerAppEnv
  name: 'n8nstorage'
  properties: {
    azureFile: {
      accountName: storageAccount.name
      shareName: fileShareName
      accountKey: storageAccount.listKeys().keys[0].value
      accessMode: 'ReadWrite'
    }
  }
}

// Container App
resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: targetPort
        transport: 'auto'
        allowInsecure: false // Enforce HTTPS
      }
    }
    template: {
      volumes: [
        {
          name: 'n8n-data'
          mountOptions: 'nobrl'
          storageName: 'n8nstorage'
          storageType: 'azureFile'
        }
      ]
      containers: [
        {
          name: 'n8n'
          image: n8nImage
          resources: {
            cpu: json('1') // Adjust as needed
            memory: '2.0Gi' // Adjust as needed
          }
          volumeMounts: [
            {
              volumeName: 'n8n-data'
              mountPath: '/home/node/.n8n'
            }
          ]
          env: [
            {
              name: 'N8N_HOST'
              value: '${containerAppName}.${containerAppEnv.properties.defaultDomain}'
            }
            {
              name: 'WEBHOOK_URL'
              value: 'https://${containerAppName}.${containerAppEnv.properties.defaultDomain}/'
            }
            {
              name: 'N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS'
              value: 'true'
            }
            {
              name: 'N8N_PERSISTENCE_FOLDER'
              value: '/home/node/.n8n'
            }
            {
              name: 'DATA_FOLDER'
              value: '/home/node/.n8n'
            }
            {
              name: 'N8N_RUNNERS_ENABLED'
              value: 'true'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1 // Adjust as needed for scaling
      }
    }
    // Define the storage configuration linked to the volume
    workloadProfileName: null // Use consumption profile
  }
  dependsOn: [
    n8nstorage
  ]
}

// Outputs
output containerAppFqdn string = containerApp.properties.configuration.ingress.fqdn
