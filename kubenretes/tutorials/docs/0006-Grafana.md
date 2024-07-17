# 0006-Grafana
This document guides how to setup the Grafana in the Kubernetes cluster to setup the a visualisation dashboard service in the Kubernetes cluster, it helps to visualise data from different source such Elasticsearch, Prometheus, InfluxDB, etc. We are running the Kubernetes in Docker container with help of Kind

# Create cluster with Kind

We’ll require an ingress controller to establish a connection between our local environment and the Kubernetes cluster.

Reference : https://kind.sigs.k8s.io/docs/user/ingress

Create the yaml file ngress-cluster-config.yaml. This file is created under kind folder


    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    nodes:
    - role: control-plane
      kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
      extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
## Create the cluster 
    kind create cluster --config kind/ingress-cluster-config.yaml --name grafana-testing

See cluster up and running:

    kubectl get nodes
    NAME                            STATUS   ROLES           AGE   VERSION
    grafana-testing-control-plane   Ready    control-plane   95s   v1.30.0


## Run a container to work in

**run Alpine Linux:**

    docker run -it --name testing-linux-box -v ${HOME}:/root/ -v ${PWD}:/work -w /work --net host alpine sh

**docker existing container shell access**


    docker exec -it testing-linux-box sh

**install some tools**

    # install curl 
    apk add --no-cache curl
    
    # install kubectl 
    curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    mv ./kubectl /usr/local/bin/kubectl
    
    # install helm 
    
    curl -o /tmp/helm.tar.gz -LO https://get.helm.sh/helm-v3.10.1-linux-amd64.tar.gz
    tar -C /tmp/ -zxvf /tmp/helm.tar.gz
    mv /tmp/linux-amd64/helm /usr/local/bin/helm
    chmod +x /usr/local/bin/helm


## NGINX Ingress Controller

Then, we’ll deploy the Kubernetes supported [ingress NGINX controller](https://git.k8s.io/ingress-nginx/README.md#readme) to work as a reverse proxy and load balancer:

We can download the file from git to local, currently this ingress service type is default. We are changing to LoadBalancer. In cloud, if we are running cluster,  the cloud provides the load balancer  ip to connect to ingress. 

This file is created under ingress folder

    curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml > ingress/ingress-nginx.yaml

Change the type NodePort to LoadBalancer in the file “ingress/ingress-nginx.yaml”

    spec:
      type: LoadBalancer

Deploy the ingress 

    kubectl apply -f ingress/ingress-nginx.yaml

Now the Ingress is all setup. Wait until is ready to process requests running:

    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=90s

**Check the installation pods**

    kubectl -n ingress-nginx get pods
    


    kubectl -n ingress-nginx get svc
    
    NAME                                        READY   STATUS      RESTARTS   AGE
    ingress-nginx-admission-create-5p2nf        0/1     Completed   0          59s
    ingress-nginx-admission-patch-427q8         0/1     Completed   2          59s
    ingress-nginx-controller-5fd8d8557c-smkss   1/1     Running     0          59s

Check the service of ingress controller, service type default NodePort, 


    kubectl get --namespace ingress-nginx svc
    NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
    ingress-nginx-controller             LoadBalancer   10.96.180.216   <pending>     80:32257/TCP,443:31909/TCP   15m
    ingress-nginx-controller-admission   ClusterIP      10.96.208.182   <none>        443/TCP                      15m

For testing purposes, we will simply setup `port-forward`ing
If you are running in the cloud, you will get a real IP address.


    kubectl -n ingress-nginx port-forward svc/ingress-nginx-controller 80

We can reach our controller on [http://localhost/](http://localhost/)
It's important to understand that Ingress runs on two ports `80` and `443`

NGINX Ingress creates a fake certificate which is served for default `HTTPS` traffic on port `443`.
If you look in the browser you will notice the name of the certificate `Common Name (CN) Kubernetes Ingress Controller Fake Certificate`


# Setup Grafana

**Add the Grafana Community Helm Repository**: First, you need to add the Grafana community Helm repository to your Helm client:

    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update

Create name space on Kubernetes

    kubectl create namespace devops


## Path Based Routing

This helps ingress resource routing to multiple application based on path routing

Create helm value YAML file “helm-value.yaml”, in this, we have to change the URI prefix of Grafana server

This file is created under grafana folder

    adminUser: admin
    adminPassword: admin
    service:
      type: ClusterIP
      port: 80
    grafana.ini:
      server:
        root_url: '%(protocol)s://%(domain)s:%(http_port)s/grafana/'
        serve_from_sub_path: true

Helm chart values https://github.com/grafana/helm-charts/blob/main/charts/grafana/values.yaml

Install Grafana 

    helm install grafana -n devops grafana/grafana -f grafana/helm-values.yaml

Create yaml ingress resource file ingress-resource.yaml.  The Jenkins URI Prefix and path should be same, if it is different, we have to add the rewrite annotation in the ingress resource

This file is created under grafana folder

    
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: jenkins-ingress
      namespace: devops
      annotations:
    spec:
      rules:
      - http:
          paths:
          - pathType: ImplementationSpecific
            path: /grafana
            backend:
              service:
                name: grafana
                port:
                  number: 80

Deploy

    kubectl apply -f grafana/ingress-resource.yaml

Execute the URL http://localhost/grafana in the browser

