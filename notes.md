## Notes

https://github.com/chzbrgr71/container-apps-store-api-microservice
https://docs.microsoft.com/en-us/azure/container-apps/overview

#### Build and Push container images

```bash

export GITHUB_CR_PAT='' # in zsh profile
docker login ghcr.io -u chzbrgr71 -p $GITHUB_CR_PAT

export TAG='v1'

docker build -t chzbrgr71/store-service:$TAG ./store-service
docker build -t chzbrgr71/inventory-service:$TAG ./inventory-service
docker build -t chzbrgr71/order-service:$TAG ./order-service

docker tag chzbrgr71/store-service:$TAG ghcr.io/chzbrgr71/store-service:$TAG
docker tag chzbrgr71/inventory-service:$TAG ghcr.io/chzbrgr71/inventory-service:$TAG
docker tag chzbrgr71/order-service:$TAG ghcr.io/chzbrgr71/order-service:$TAG

docker push ghcr.io/chzbrgr71/store-service:$TAG
docker push ghcr.io/chzbrgr71/inventory-service:$TAG
docker push ghcr.io/chzbrgr71/order-service:$TAG

```

> Note: Manually mark images as public here: https://github.com/chzbrgr71?tab=packages


#### Deploy via Bicep

```bash

export PREFIX=$USER
export SUFFIX=$RANDOM
export RG=$PREFIX-container-app-$SUFFIX
export LOCATION='canadacentral'

az group create -n $RG -l $LOCATION

az deployment group create \
    --name demo-app-deploy \
    --resource-group $RG \
    --only-show-errors \
    --template-file ./deploy/main.bicep \
    --parameters \
        storeMinReplicas=1 \
        storeImage='ghcr.io/chzbrgr71/store-service:v1' \
        storePort=3000 \
        isStoreExternalIngress=true \
        orderMinReplicas=1 \
        orderImage='ghcr.io/chzbrgr71/order-service:v1' \
        orderPort=5000 \
        isOrderExternalIngress=true \
        inventoryMinReplicas=1 \
        inventoryImage='ghcr.io/chzbrgr71/inventory-service:v1' \
        inventoryPort=8050 \
        isInventoryExternalIngress=true

az deployment group show -g $RG -n demo-app-deploy -o json --query properties.outputs 
 
```

#### Test the app

http://store-service.kindsea-fb0aa535.canadacentral.azurecontainerapps.io

https://store-service.kindsea-fb0aa535.canadacentral.azurecontainerapps.io/order?id=1
https://store-service.kindsea-fb0aa535.canadacentral.azurecontainerapps.io/order?id=undefined 

Order payload:
{"id":"1","item":"Thule Roof Rack System","location":"Denver","priority":"Standard"}
{"id":"2","item":"Ski carrier","location":"Denver","priority":"Standard"}
{"id":"3","item":"Bike carrier","location":"Denver","priority":"Standard"}
{"id":"4","item":"Kayak carrier","location":"Denver","priority":"Standard"}
{"id":"5","item":"Rack locking system","location":"Denver","priority":"Standard"}

```bash

export DOMAINSUFFIX=kindsea-fb0aa535.canadacentral.azurecontainerapps.io

echo "curl -X GET http://store-service.${DOMAINSUFFIX}/order?id=1"

curl -X GET "http://inventory-app.kindsea-fb0aa535.canadacentral.azurecontainerapps.io/inventory"

curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"2","item":"Ski Carrier","location":"Seattle","priority":"Standard"}' \
  https://store-service.ambitiousocean-857a519b.canadacentral.azurecontainerapps.io/order?id=undefined  


while true; do curl -X GET "https://strava-app-7vrxff5djq-uc.a.run.app/athlete/profile" && echo "\ntesting..." ; sleep 3; done
```

#### Logs

```bash
export RG='brianr-container-app-demo-2305'
export LOG_ANALYTICS_WORKSPACE='logs-env-wdogdjsbuok3c'

export LOG_ANALYTICS_WORKSPACE_CLIENT_ID=`az monitor log-analytics workspace show --query customerId -g $RG -n $LOG_ANALYTICS_WORKSPACE --out tsv`

az monitor log-analytics query \
  --workspace $LOG_ANALYTICS_WORKSPACE_CLIENT_ID \
  --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == 'store-service' | project ContainerAppName_s, Log_s, TimeGenerated " \
  --out table

az monitor log-analytics query \
  --workspace $LOG_ANALYTICS_WORKSPACE_CLIENT_ID \
  --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == 'order-service' | project ContainerAppName_s, Log_s, TimeGenerated " \
  --out table

az monitor log-analytics query \
  --workspace $LOG_ANALYTICS_WORKSPACE_CLIENT_ID \
  --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == 'inventory-service' | project ContainerAppName_s, Log_s, TimeGenerated " \
  --out table
```