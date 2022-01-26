## Notes

https://github.com/chzbrgr71/container-apps-store-api-microservice
https://docs.microsoft.com/en-us/azure/container-apps/overview

#### Build images

```bash

export GITHUB_CR_PAT='' # in zsh profile

docker login ghcr.io -u chzbrgr71 -p $GITHUB_CR_PAT

docker build -t chzbrgr71/node-service:v1 ./node-service
docker build -t chzbrgr71/go-service:v1 ./go-service
docker build -t chzbrgr71/python-service:v1 ./python-service

docker tag chzbrgr71/node-service:v1 ghcr.io/chzbrgr71/node-service:v1
docker push ghcr.io/chzbrgr71/node-service:v1

docker tag chzbrgr71/go-service:v1 ghcr.io/chzbrgr71/go-service:v1
docker push ghcr.io/chzbrgr71/go-service:v1

docker tag chzbrgr71/python-service:v1 ghcr.io/chzbrgr71/python-service:v1
docker push ghcr.io/chzbrgr71/python-service:v1
```

#### Deploy via Bicep

```bash

export PREFIX='briar'
export SUFFIX=$RANDOM
export RG=$PREFIX-container-app-demo-$SUFFIX
export LOCATION='canadacentral'

az group create -n $RG -l $LOCATION

az deployment group create \
    --name demo-app-deploy \
    --resource-group $RG \
    --only-show-errors \
    -f ./deploy/main.bicep \
    -p \
    minReplicas=1 \
    nodeImage='ghcr.io/chzbrgr71/node-service:v1' \
    nodePort=3000 \
    isNodeExternalIngress=true \
    pythonImage='ghcr.io/chzbrgr71/python-service:v1' \
    pythonPort=5000 \
    isPythonExternalIngress=false \
    goImage='ghcr.io/chzbrgr71/go-service:v1' \
    goPort=8050 \
    isGoExternalIngress=false \
    containerRegistry=ghcr.io \
    containerRegistryUsername=chzbrgr71 \
    containerRegistryPassword=$GITHUB_CR_PAT

az deployment group show -g $RG -n demo-app-deploy -o json --query properties.outputs 
 
```

#### Test the app

http://node-app.happyisland-133ccc57.canadacentral.azurecontainerapps.io

https://node-app.happyisland-133ccc57.canadacentral.azurecontainerapps.io/order?id=1
https://node-app.happyisland-133ccc57.canadacentral.azurecontainerapps.io/order?id=undefined 

Order payload:
{"id":"2","item":"Ski Carrier","location":"Seattle","priority":"Standard"}


#### Logs

```bash
export RG='briar-container-app-demo-28548'
export LOG_ANALYTICS_WORKSPACE='logs-env-k53vvbq5z5zui'
export APP='node-app'

export LOG_ANALYTICS_WORKSPACE_CLIENT_ID=`az monitor log-analytics workspace show --query customerId -g $RG -n $LOG_ANALYTICS_WORKSPACE --out tsv`

az monitor log-analytics query \
  --workspace $LOG_ANALYTICS_WORKSPACE_CLIENT_ID \
  --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == 'node-app' | project ContainerAppName_s, Log_s, TimeGenerated " \
  --out table

az monitor log-analytics query \
  --workspace $LOG_ANALYTICS_WORKSPACE_CLIENT_ID \
  --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == 'python-app' | project ContainerAppName_s, Log_s, TimeGenerated " \
  --out table

az monitor log-analytics query \
  --workspace $LOG_ANALYTICS_WORKSPACE_CLIENT_ID \
  --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == 'go-app' | project ContainerAppName_s, Log_s, TimeGenerated " \
  --out table
```