param location string = resourceGroup().location
param environmentName string = 'env-${uniqueString(resourceGroup().id)}'

// store service
param storeMinReplicas int = 1
param storeImage string = 'ghcr.io/azure/container-apps-demo/store-service:latest'
param storePort int = 3000
param isStoreExternalIngress bool = true

// order service
param orderMinReplicas int = 1
param orderImage string = 'ghcr.io/azure/container-apps-demo/order-service:latest'
param orderPort int = 5000
param isOrderExternalIngress bool = false

// inventory service
param inventoryMinReplicas int = 1
param inventoryImage string = 'ghcr.io/azure/container-apps-demo/inventory-service:latest'
param inventoryPort int = 8050
param isInventoryExternalIngress bool = false

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
    storeImage: storeImage
    storePort: storePort
    isStoreExternalIngress: isStoreExternalIngress
    storeMinReplicas: storeMinReplicas
    env: [
      {
        name: 'ORDER_SERVICE_NAME'
        value: 'order-service'
      }
      {
        name: 'INVENTORY_SERVICE_NAME'
        value: 'inventory-service'
      }
    ]
  }
}

// container app: order-service
module orderService 'order-service.bicep' = {
  name: 'order-service'
  params: {
    location: location
    environmentId: environment.outputs.environmentId
    orderImage: orderImage
    orderPort: orderPort
    isOrderExternalIngress: isOrderExternalIngress
    orderMinReplicas: orderMinReplicas
    secrets: [
      {
        name: 'masterkey'
        value: cosmosdb.outputs.primaryMasterKey
      }
    ]    
    daprComponents: [
      {
        name: 'orders'
        type: 'state.azure.cosmosdb'
        version: 'v1'
        metadata: [
          {
            name: 'url'
            value: cosmosdb.outputs.documentEndpoint
          }
          {
            name: 'database'
            value: 'ordersDb'
          }
          {
            name: 'collection'
            value: 'orders'
          }
          {
            name: 'masterkey'
            secretRef: 'masterkey'
          }
        ]
      }
    ]
  }
}

// container app: inventory-service
module inventoryService 'inventory-service.bicep' = {
  name: 'inventory-service'
  params: {
    location: location
    environmentId: environment.outputs.environmentId
    inventoryImage: inventoryImage
    inventoryPort: inventoryPort
    isInventoryExternalIngress: isInventoryExternalIngress
    inventoryMinReplicas: inventoryMinReplicas
  }
}

output storeFqdn string = storeService.outputs.fqdn
output orderFqdn string = orderService.outputs.fqdn
output inventoryFqdn string = inventoryService.outputs.fqdn
output environmentId string = environment.outputs.environmentId
output defaultDomain string = environment.outputs.defaultDomain
output appInsightsInstrumentationKey string = environment.outputs.appInsightsInstrumentationKey
output logAnalyticsName string = environment.outputs.logAnalyticsName
