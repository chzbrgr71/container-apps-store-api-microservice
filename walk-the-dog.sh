
export RG_NAME=$1
export LOCATION=$2
export SUFFIX=$3

start_time=$(date +%s)

# show all params
echo '****************************************************'
echo 'Starting Container Apps Demo deployment'
echo ''
echo 'Parameters:'
echo 'LOCATION: ' $LOCATION
echo 'RG_NAME: ' $RG_NAME
echo 'LOGFILE_NAME: ' $LOGFILE_NAME
echo '****************************************************'
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
az group create -n $RG -l $LOCATION

# Bicep deployment
echo ''
echo '****************************************************'
echo 'Starting Bicep deployment of resources'
echo '****************************************************'

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

# Deployment outputs
echo ''
echo 'Saving bicep outputs to a file'
az deployment group show -g $RG -n demo-app-deploy -o json --query properties.outputs > "./outputs/$RG_NAME-bicep-outputs.json"

echo ''
echo '****************************************************'
echo 'Demo successfully deployed'
echo ''
echo 'Details:'
echo ''
echo ''
echo '****************************************************'    

# elapsed time with second resolution
echo ''
end_time=$(date +%s)
elapsed=$(( end_time - start_time ))
eval "echo Script elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hours %M minutes %S seconds')"
