param location string = resourceGroup().location

@minLength(3)
@maxLength(20)
@description('Provide a workloadName. Use only lower case letters and numbers.')
param workloadName string

@description('Username for the Virtual Machine.')
param adminUsername string

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

// Ensure VM name is within 15 character limit
var vmNamePrefix = 'vm-'
var maxVmNameLength = 15
var vmNameSuffixLength = min(length(workloadName), maxVmNameLength - length(vmNamePrefix))
var vmNameSuffix = substring(workloadName, 0, vmNameSuffixLength)
var vmName = '${vmNamePrefix}${vmNameSuffix}'

// Ensure storage account name is within 24 character limit
var storagePrefix = 'sa'
var maxStorageNameLength = 24
var storageNameSuffixLength = min(length(workloadName), maxStorageNameLength - length(storagePrefix))
var storageNameSuffix = substring(workloadName, 0, storageNameSuffixLength)
var storageAccountName = '${storagePrefix}${storageNameSuffix}'

var publicIpName = 'pip-${workloadName}'
var dnsLabelPrefix = 'dns-${workloadName}'

var vmSize = 'Standard_D2lds_v5'

module storageModule './storage.bicep' = {
  name: 'storageDeployment'
  params: {
    location: location
    storageAccountName: storageAccountName
  }
}

module vmModule './vm.bicep' = {
  name: 'vmDeployment'
  params: {
    location: location
    vmName: vmName
    publicIpName: publicIpName
    dnsLabelPrefix: dnsLabelPrefix
    storageAccountName: storageAccountName
    vmSize: vmSize
    workloadName: workloadName
    adminPassword: adminPassword
    adminUsername: adminUsername
  }
  dependsOn: [
    storageModule
  ]  
}

