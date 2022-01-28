param location string = resourceGroup().location
param environmentId string
param inventoryImage string
param inventoryPort int
param isInventoryExternalIngress bool
param env array = []
param daprComponents array = []
param inventoryMinReplicas int = 0

var containerAppName = 'inventory-service'

resource inventoryContainerApp 'Microsoft.Web/containerApps@2021-03-01' = {
  name: containerAppName
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: environmentId
    configuration: {
      // activeRevisionsMode: revisionMode
      // secrets: secrets
      ingress: {
        external: isInventoryExternalIngress
        targetPort: inventoryPort
        transport: 'auto'
        // traffic: [
        //   {
        //     weight: 100
        //     latestRevision: true
        //   }
        // ]
      }
    }
    template: {
      // revisionSuffix: 'somevalue'
      containers: [
        {
          image: inventoryImage
          name: containerAppName
          env: env
          resources: {
            cpu: '0.25'
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: inventoryMinReplicas
      //  maxReplicas: 10
      //   rules: [{
      //     name: 'httpscale'
      //     http: {
      //       metadata: {
      //         concurrentRequests: 100
      //       }
      //     }
      //   }
      //   ]
      }
      dapr: {
        enabled: true
        appPort: inventoryPort
        appId: containerAppName
        components: daprComponents
      }
    }
  }
}

output fqdn string = inventoryContainerApp.properties.configuration.ingress.fqdn
