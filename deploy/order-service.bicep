param location string = resourceGroup().location
param environmentId string
param orderImage string
param orderPort int
param isOrderExternalIngress bool
param env array = []
param daprComponents array = []
param orderMinReplicas int = 0
param secrets array = []

var containerAppName = 'order-service'

resource orderContainerApp 'Microsoft.Web/containerApps@2021-03-01' = {
  name: containerAppName
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: environmentId
    configuration: {
      // activeRevisionsMode: revisionMode
      secrets: secrets
      ingress: {
        external: isOrderExternalIngress
        targetPort: orderPort
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
          image: orderImage
          name: containerAppName
          env: env
          resources: {
            cpu: '0.75'
            memory: '1.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: orderMinReplicas
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
        appPort: orderPort
        appId: containerAppName
        components: daprComponents
      }
    }
  }
}

output fqdn string = orderContainerApp.properties.configuration.ingress.fqdn
