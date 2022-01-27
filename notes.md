## Notes

Docs. https://docs.microsoft.com/en-us/azure/container-apps/overview

#### Test the app

Sample order payloads:
{"id":"1","item":"Thule Roof Rack System","location":"Denver","priority":"Standard"}
{"id":"2","item":"Ski carrier","location":"Denver","priority":"Standard"}
{"id":"3","item":"Bike carrier","location":"Denver","priority":"Standard"}
{"id":"4","item":"Kayak carrier","location":"Denver","priority":"Standard"}
{"id":"5","item":"Rack locking system","location":"Denver","priority":"Standard"}

```bash

# store
curl -X GET https://store-service.wittyhill-cddf9e15.eastus.azurecontainerapps.io/order?id=1
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"2","item":"Ski Carrier","location":"Seattle","priority":"Standard"}' \
  https://store-service.wittyhill-cddf9e15.eastus.azurecontainerapps.io/order?id=undefined

# orders
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"3","item":"Bike Carrier","location":"Seattle","priority":"Standard"}' \
  https://order-service.wittyhill-cddf9e15.eastus.azurecontainerapps.io/order?id=undefined

curl --header "Content-Type: application/json" --request POST --data '{"id":"4","item":"Rack Locking System","location":"Denver","priority":"Standard"}' https://order-service.wittyhill-cddf9e15.eastus.azurecontainerapps.io/order?id=undefined

# inventory
curl -X GET https://inventory-service.wittyhill-cddf9e15.eastus.azurecontainerapps.io/
curl -X GET https://inventory-service.wittyhill-cddf9e15.eastus.azurecontainerapps.io/inventory

# looptid
while true; do curl --header "Content-Type: application/json" --request POST --data '{"id":"4","item":"Rack Locking System","location":"Denver","priority":"Standard"}' https://order-service.wittyhill-cddf9e15.eastus.azurecontainerapps.io/order?id=undefined && echo '' ; sleep 3; done

```

#### Logs

```bash

export RG='vscode-container-app-demo-25161'
export LOG_ANALYTICS_WORKSPACE='logs-env-tc7sg2rugmf44'

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