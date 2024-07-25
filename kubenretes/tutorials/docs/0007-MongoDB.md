# 0007-MongoDB
This document guides help us, how can we setup the MongoDB in the Kubernetes cluster. This is basic tutorial where developer can setup MongoDB on Kubernetes which run in a local machine.

# Perquisites 
- Install Docker Desktop https://docs.docker.com/desktop/
- Install the Kind for creating Kubernetes cluster inside Docker. This helps us easily test our application on your local environment and easily clean / delete cluster once testing completed and it will not effect existing working environment
# Create cluster with Kind

We’ll require an ingress controller to establish a connection between our local environment and the Kubernetes cluster. We are exposing the NodePort to connect the MongoDB. While developing or testing better to use the Kubernetes service type is “NodePort”. This helps us easily test our application in the cluster.

Reference : https://kind.sigs.k8s.io/docs/user/ingress

Create the yaml file cluster-config.yaml. This file is created under mongodb folder. 


    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    nodes:
    - role: control-plane
      extraPortMappings:
      - containerPort: 31252
        hostPort: 31252
        listenAddress: "0.0.0.0"
        protocol: TCP
## Create the cluster 
    kind create cluster --config mongodb/cluster-config.yaml --name mongodb-testing

See cluster up and running:

    kubectl get nodes
    NAME                            STATUS     ROLES           AGE   VERSION
    mongodb-testing-control-plane   NotReady   control-plane   16s   v1.30.0

I am using the a small linux box which can run inside docker, it helps me to install my relevant tools for setup the working environment. We can stop / delete this container after testing is completed. For this, I am using Alpine Linux and it is very small container in local machine.

## Run Alpine Linux:
    docker run -it --name testing-linux-box -v ${HOME}:/root/ -v ${PWD}:/work -w /work --net host alpine sh

The Docker command you've provided runs an interactive shell session in an Alpine Linux container with the following details:


- **Container Name**: `testing-linux-box`
- **Volume Mounts**:
    - `${HOME}:/root/`: This mounts the user's home directory on the host machine to the `/root` directory in the container.
    - `${PWD}:/work`: This mounts the current working directory on the host machine to the `/work` directory in the container.
- **Working Directory**: The working directory inside the container is set to `/work`.
- **Network Mode**: The container uses the host's network stack (`--net host`).

This setup is useful for testing and development, especially if you need access to files on your host machine or want to run network operations without worrying about port mapping.

SH into running container command:
****
    docker exec -it testing-linux-box sh

We should install following tools to setup MongoDB in our cluster.

- Install “curl” : This helps us to download the files from internet inside cluster


    apk add --no-cache curl


- Install “Kubectl”: `kubectl` is the command-line tool for interacting with Kubernetes clusters. It allows you to deploy applications, manage cluster resources, and troubleshoot running applications.


    curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
    
    chmod +x ./kubectl
    
    mv ./kubectl /usr/local/bin/kubectl


- Install Helm: Helm is a package manager for Kubernetes, allowing you to define, install, and manage Kubernetes applications using charts. Helm charts are pre-configured Kubernetes resources that can be easily deployed and versioned.


    curl -o /tmp/helm.tar.gz -LO https://get.helm.sh/helm-v3.10.1-linux-amd64.tar.gz
    tar -C /tmp/ -zxvf /tmp/helm.tar.gz
    
    mv /tmp/linux-amd64/helm /usr/local/bin/helm
    
    chmod +x /usr/local/bin/helm
# Setup MongoDB

**Add the MongoDB Community Helm Repository**: First, you need to add the MongoDB community Helm repository to your Helm client:

    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update

Create name space on Kubernetes

    kubectl create namespace database


## Install MongoDB in the Kubernetes Cluster

Create helm value YAML file “helm-value.yaml”, where we can provided the configuration for MongoDB database.

This file is created under mongodb folder “mongodb/helm-value.yaml”

    replicaSet:
      enabled: true
      name: rs0
      replicas:
        secondary: 1
        arbiter: 1
    
    auth:
      enabled: true
      rootPassword: myRootPassword
      username: myUser
      password: myPassword
      database: myDatabase
    
    service:
      type: NodePort
      nodePorts:
        mongodb: 31252
      ports:
        mongodb: 27017
    
    persistence:
      enabled: true
      size: 1Gi
      storageClass: "standard"

MongoDB helm chart values: https://github.com/bitnami/charts/blob/main/bitnami/mongodb/values.yaml
**Note:** Kind cluster configuration container port and mongodb node port should be same

Install MongoDB 

    helm install my-mongodb -f mongodb/helm-value.yaml bitnami/mongodb --namespace database

We can check the service the node port and service type is configured properly

    kubectl get svc -n database
    
    NAME         TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)           AGE
    my-mongodb   NodePort   10.96.136.248   <none>        27017:31252/TCP   9m54s

We can install MongoDB Compass for testing the Mongo Db connection and create the database and collections

## Host Configuration
![](https://paper-attachments.dropboxusercontent.com/s_DB39112FCA5B40991E1F5FBD452106ED103D616BE13230B31BC03D387CD046A3_1721932307206_image.png)

## Authentication Configuration
![](https://paper-attachments.dropboxusercontent.com/s_DB39112FCA5B40991E1F5FBD452106ED103D616BE13230B31BC03D387CD046A3_1721932331980_image.png)



