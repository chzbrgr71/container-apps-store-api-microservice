param location string = resourceGroup().location
param environmentName string = 'env-${uniqueString(resourceGroup().id)}'

// store service
param storeMinReplicas int = 1
param storeImage string = 'repo/store-service:v1'
param storePort int = 3000
param isStoreExternalIngress bool = true

// param pythonImage string = 'nginx'
// param pythonPort int = 5000
// param isPythonExternalIngress bool = false
// param goImage string = 'nginx'
// param goPort int = 8050
// param isGoExternalIngress bool = false

// container app environment
module environment 'environment.bicep' = {
  name: 'container-app-environment'
  params: {
    environmentName: environmentName
    location: location
  }
}

// cosmosdb
module cosmosdb 'cosmosdb.bicep' = {
  name: 'cosmosdb'
  params: {
    location: location
    primaryRegion: location
  }
}

// container app: store-service
module storeService 'store-service.bicep' = {
  name: 'store-service'
  params: {
    location: location
    environmentId: environment.outputs.environmentId
    containerImage: storeImage
    containerPort: storePort
    isExternalIngress: isStoreExternalIngress
    minReplicas: storeMinReplicas
  }
}

output nodeFqdn string = storeService.outputs.fqdn
//output pythonFqdn string = pythonService.outputs.fqdn
//output goFqdn string = goService.outputs.fqdn
output environmentId string = environment.outputs.environmentId
output defaultDomain string = environment.outputs.defaultDomain
output appInsightsInstrumentationKey string = environment.outputs.appInsightsInstrumentationKey
output logAnalyticsName string = environment.outputs.logAnalyticsName
