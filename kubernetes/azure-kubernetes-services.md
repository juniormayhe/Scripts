# Deploying to AKS - Azure Kubernetes Service

## Install python 3

https://www.python.org/downloads/

## Install azure CLI

https://docs.microsoft.com/bs-latn-ba/cli/azure/install-azure-cli-windows?view=azure-cli-latest

## Initialize tooling

### Login

After installing Azure CLI you must login to associate your account to Azure

```
az login
```

### Register required azure namespaces

Register namespaces to create and monitor your Kubernetes cluster.
There are three required namespaces that are not configured automatically:

```
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.OperationsManagement
```

This will avoid several error messages that will otherwise show up several minutes into the create cluster operation.

### Create a resource group

Before creating a resource group you must choose a location. In general you should choose a location geographically closest to you.
To list azure account locations, use:

```
az account list locations
```

To create a resource group, use:

```
az group create --name kube-demo --location westus
```

Then assign the namespaces to the resource group created

```
az aks create --resource-group=kube-demo --name=demo-cluster --node-vm-size=Standard_D1 --generate-ssh-keys
```

### Create a container registry

Sku = level of features and associated cost
```
az acr create --resource-group kube-demo --location westus --name registry-demo --sku Basic
or
az acr create -g kube-demo -l westus -n=demo-registry --sku=Basic
```

## Building and pushing images

### Push an image to Azure container registry

You must follow this name format
```
<registry-name>.azurecr.io/<namespace>/<image-name>:<tag>
```
- registry-name: the name of the registry to manage the images
- namespace: optional, to organize repository like a file system
- image-name: the name of the image

Before pushing the image to container registry, you must build a local image with docker build. 

The final dot indicates the Docker file to build the image is in the current directory.
```
docker build -t demo-registry.azurecr.io/examples/demo:1.0 .
```

Optionally you can test your image with `docker run -p <externa/nodel port>:<internal port> <container name>` or `docker exec -it <container name> sh`

To tag an existing image in container registry. Useful for versioning image.
```
docker tag 8e20 demo-registry.azurecr.io/examples/demo:1.1
```

Login to the the container registry you want to push the image
```
az acr login --name demo-registry
```

Push the local image to container registry
```
docker push demo-registry.azurecr.io/examples/demo:1.0
```

## Creating cluster

The creation can take several minutes to complete. It creates a kube master, infrastructure and the node pool.

node-vm-size: optional, but you might have to define if node type does not provide a default size
```
az aks create --resource-group kube-demo --name demo-cluster --node-vm-size Standard_D1 --generate-ssh-keys
or
az aks create -g kube-demo -n demo-cluster --node-vm-size Standard_D1 --generate-ssh-keys
```

## Create a deployment in cluster

### Give permissions
You need to set a few permissions. 

Get the cluster id with
```
az aks show -g kube-demo -n demo-cluster --query "servicePrincipalProfile.clientId" --output tsv
```
Get the container registry id with
```
az acr show -g kube-demo -n demo-registry --query "id" --output tsv
```

Give cluster permission to pull from container registry. The acrpull - **cluster pull access** allows cluster to pull images from registry.
```
az role assignment create --role acrpull --assignee <cluster id> --scope <container registry id>
```

Get credentials for kubectl to connect to this cluster.
```
az aks get-credentials -g kube-demo -n demo-cluster
```

To enable monitoring addon for your cluster
```
az aks enable-addons -a monitoring -g kube-demo -n demo-cluster
```

list the nodes for the cluster.
```
kubectl get nodes
``````

there are no pods yet created because we haven't deployed yet.
```
kubectl get pods
```

### Create deployment and service
With permission in place we can create deployment for our demo app.

Use kubectl to create and expose deployment
```
kubectl create deployment demo-app --image=demo-registry.azurecr.io/examples/demo:1.0
kubectl expose deployment demo-app --type=LoadBalancer --port 5000 --target-port=5000
```

We should have only one pod for now
```
kubectl get pods
```

Then try the service out by grabbing its EXTERNAL-IP address from load balancer service. So you can browse the service if its a web app.
```
kubectl get service
```

## Scale pods and nodes

To scale up or down only the pods
```
kubectl scale deployment demo-app --replicas=3
```

We should have now 3 pods / containers running
```
kubectl get pods
```

We should have 3 nodes running
```
kubectl get nodes
```

To scale down the number of cluster nodes to 1
```
az aks scale -g kube-demo -n demo-cluster -c 1
```

And then we should have 1 node running in Ready status
```
kubectl get nodes
```

The 1 node left was running one pod, and now has to provision 2 new pods as you can see in AGE. The existing pod will be the older, and two pods will be the new ones.
```
kubectl get pods
```

To scale back up the number of cluster nodes to 3. It may take a while when you run it.
```
az aks scale -g kube-demo -n demo-cluster -c 3
```

The existing pods will not restart because they will be kept running in the first node (the one we scaled down the cluster to 1 node). Two new nodes will be provisioned in cluster without pods running. Depending on the implementation of your cloud provider, it may or may not automatically rebalance the pods across all the 3 nodes.
```
kubectl get pods -o wide
```

## Update the application with local docker

We must build, tag and push a new image to the container repository.
```
docker build -t demo-registry.azurecr.io/examples/demo:2.0 .
docker push demo-registry.azurecr.io/examples/demo:2.0
```

once the image is in the container registry you can use kubectl to se the new version for the deployment. Here the container name is "demo"

```
kubectl set image deployment/demo-app demo=demo-registry.azurecr.io/examples/demo:2.0
```
## Update the application with remote cloud agent

You can also build images with the remote Cloud Agent Build, instead of using local docker build. So we avoid building the image in our computer and let the cloud agent push the new image to container registry.
- image: the name, namespace and tag of the image
- registry: where cloud agent will push the image on successful build
- file: the dockerfile 
- directory with source code to build the image (the tar will pack the code for upload)
```
az acr build --image examples/demo:2.0 --registry demo-registry --file dockerfile .
```
after building and pushing on cloud, we will not have version 2.0 image in our machine, because the process was done remotely. As seen with `docker images`

```
kubectl set image deployment/demo-app demo=demo-registry.azurecr.io/examples/demo:2.0
```
We can see with kubectl the 1.0 images being terminated and 2.0 being created. At the end we notice that the 3 replicas will be running the 2.0 version
```
kubectl get pods
```
The 3 new pods with 2.0 version image will be distributed across only two nodes (the newest ones without pods running). The older node will terminate running pods with 1.0 version. 
```
kubectl get nodes
```
## Azure portal

### Monitoring kubernetes cluster
To get information about clusters, go to home Microsoft Azure portal > Kubernetes services.

Select  demo-cluster > Monitor containers. 

In *Cluster* to see % node cpu, memory utilization, node cound and pod count.
In *Nodes* to see resources used
In *View workbooks* to see disk capacity, disk IO and network.
Under Monitoring in *Metrics* we can select metrics to have them plotted on graph. 
### Cluster
Under Kubernetes services > demo-cluster > Settings > Node pools we can click on *Node count*  to adjust the number of nodes in the pool. (Manual or autoscale).

You can also add a node pool to host more nodes. In the node pool we define pool name, OS type (Windows or Linux), Kubernetes version, node size and node count.

### Registry

In the search bar we can search for *container registries*. If we drill to it by clickin in demo-registry name, and scroll down to Services > Repositories we can see the image examples/demo with two tags 1.0 and 2.0.

If you click on the version 2.0, you can see the tag creation date, update date, OS platform, and manifest.

### Billing

If you search for Billing and select Serices > Cost Management + Billing, you can see the Cost analysis, Budgets, Invoices, Transactions, Payment history, Recurring charges, Azure subscriptions. And give user access to your billing account.

## Cleanup the cluster

Dèlete the load balancer service. Get the name
```
kubectl get service
```
and
```
kubectl delete service demo-app
```

Delete the azure kubernetes cluster, entering resource group and cluster name. This will probably take several minutes.
```
az aks delete --resource-group kube-demo --name demo-cluster
or
az aks delete -g kube-demo -n demo-cluster
```

If you no longer use images pushed to the registry
```
az acr repository delete --name demo-registry --image examples/demo:2.0
az acr repository delete -n demo-registry --image examples/demo:2.0
```

To clean up the entire resource group. It will erase container registry and container images in that group. This may take a few minutes.
```
az group delete --name kube-demo
az group delete -n kube-demo
```
