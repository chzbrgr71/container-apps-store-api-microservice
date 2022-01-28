export RG=$1
export LOCATION=$2
export SUFFIX=$3

# show all params
echo '***************************************************************'
echo 'Starting Container Apps Demo deployment'
echo ''
echo 'Parameters:'
echo 'LOCATION: ' $LOCATION
echo 'RG: ' $RG
echo 'LOGFILE_NAME: ' $LOGFILE_NAME
echo '***************************************************************'
echo ''

# Check for Azure login
echo ''
echo 'Checking to ensure logged into Azure CLI'
AZURE_LOGIN=0 
# run a command against Azure to check if we are logged in already.
az group list -o table
# save the return code from above. Anything different than 0 means we need to login
AZURE_LOGIN=$?

if [[ ${AZURE_LOGIN} -ne 0 ]]; then
# not logged in. Initiate login process
    az login --use-device-code
    export AZURE_LOGIN
fi

# Create Azure Resource Group
echo ''
echo "Create Azure Resource Group"
az group create -n $RG -l $LOCATION -o table

# Bicep deployment
echo ''
echo '***************************************************************'
echo 'Starting Bicep deployment of resources'
echo '***************************************************************'

az deployment group create \
    --name demo-app-deploy \
    --resource-group $RG \
    --only-show-errors \
    --template-file ./deploy/main.bicep \
    --parameters \
        storeMinReplicas=1 \
        storeImage='ghcr.io/azure/container-apps-demo/store-service:latest' \
        storePort=3000 \
        isStoreExternalIngress=true \
        orderMinReplicas=1 \
        orderImage='ghcr.io/azure/container-apps-demo/order-service:latest' \
        orderPort=5000 \
        isOrderExternalIngress=true \
        inventoryMinReplicas=1 \
        inventoryImage='ghcr.io/azure/container-apps-demo/inventory-service:latest' \
        inventoryPort=8050 \
        isInventoryExternalIngress=true

# Deployment outputs
echo ''
echo 'Saving bicep outputs to a file'
az deployment group show -g $RG -n demo-app-deploy -o json --query properties.outputs > "./outputs/bicep-outputs-$RG.json"

export CONTAINER_APPS_DOMAIN=$(cat ./outputs/bicep-outputs-$RG.json | jq -r .defaultDomain.value)
export STORE_URL="https://"$(cat ./outputs/bicep-outputs-$RG.json | jq -r .storeFqdn.value)
export ORDER_URL="https://"$(cat ./outputs/bicep-outputs-$RG.json | jq -r .orderFqdn.value)
export INVENTORY_URL="https://"$(cat ./outputs/bicep-outputs-$RG.json | jq -r .inventoryFqdn.value)
export LOG_ANALYTICS=$(cat ./outputs/bicep-outputs-$RG.json | jq -r .logAnalyticsName.value)

echo ''
echo '***************************************************************'
echo 'Demo successfully deployed'
echo ''
echo 'Details:'
echo ''
echo 'Resource Group: ' $RG
echo 'Container Apps Env Domain: ' $CONTAINER_APPS_DOMAIN
echo 'Store: ' $STORE_URL
echo 'Order API: ' $ORDER_URL
echo 'Inventory API: ' $INVENTORY_URL
echo 'Log Analytics Name: ' $LOG_ANALYTICS
echo ''
echo '***************************************************************'   
