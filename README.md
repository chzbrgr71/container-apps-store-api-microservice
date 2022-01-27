# Container App Store Microservice Sample (Forked)

This is a sample microservice solution for Azure Container Apps.  It will create a series of microservices for managing orders and inventory. Dapr is used to secure communication and calls between services and Azure Cosmos DB is created alongside the microservices.

> Note: This solution is a fork from the original. It's been changed a lot, but thanks to the original team who put this together!


## Quickstart

Deployment is done via Bicep with a simple bash script to get you started. You can fork the repo and run the below script in bash or GitHub Codespaces. 

Just run the `./start.sh` script to deploy everything. You can edit the `LOCATION` variable in the script if needed.


## Building container images (optional)

```bash

export GITHUB_CR_PAT='' # set in bash profile
docker login ghcr.io -u chzbrgr71 -p $GITHUB_CR_PAT

export TAG='v1.0'

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


## Solution Overview

![image of architecture](./assets/arch.png)

There are three main microservices in the solution.  

#### Store API (`store-service`)
The [`store-service`](./store-service) is an express.js API that exposes three endpoints.  `/` will return the primary index page, `/order` will return details on an order (retrieved from the **order service**), and `/inventory` will return details on an inventory item (retrieved from the **inventory service**).

#### Order Service (`order-service`)
The [`order-service`](./order-service) is a Python flask app that will retrieve and store the state of orders.  It uses [Dapr state management](https://docs.dapr.io/developing-applications/building-blocks/state-management/state-management-overview/) to store the state of the orders.  When deployed in Container Apps, Dapr is configured to point to an Azure Cosmos DB to back the state. 

#### Inventory Service (`inventory-service`)
The [`inventory-service`](./inventory-service) is a Go mux app that will retrieve and store the state of inventory.
