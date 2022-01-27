param location string = resourceGroup().location
param environmentId string
param storeImage string
param storePort int
param isStoreExternalIngress bool
param env array = []
param daprComponents array = []
param storeMinReplicas int = 0

var containerAppName = 'store-service'
var cpu = json('0.5')
var memory = '500Mi'

resource storeContainerApp 'Microsoft.Web/containerApps@2021-03-01' = {
  name: containerAppName
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: environmentId
    configuration: {
      // activeRevisionsMode: revisionMode
      // secrets: secrets
      ingress: {
        external: isStoreExternalIngress
        targetPort: storePort
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
          image: storeImage
          name: containerAppName
          env: env
          // resources: {
          //   cpu: cpu
          //   memory: memory
          // }
        }
      ]
      scale: {
        minReplicas: storeMinReplicas
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
        appPort: storePort
        appId: containerAppName
        components: daprComponents
      }
    }
  }
}

output fqdn string = storeContainerApp.properties.configuration.ingress.fqdn
