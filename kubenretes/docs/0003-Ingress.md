# 0003-Ingress

https://www.baeldung.com/ops/kubernetes-kind


## Create cluster with Kind

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
    kind create cluster --config kind/ngress-cluster-config.yaml --name nginx-ingress-testing

See cluster up and running:

    kubectl get nodes
    NAME                  STATUS   ROLES                  AGE     VERSION
    nginx-ingress-control-plane   Ready    control-plane,master   2m12s   v1.23.5


## Run a container to work in

**run Alpine Linux:**

    docker run -it --name l -v ${HOME}:/root/ -v ${PWD}:/work -w /work --net host alpine sh

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

Change the type NodePort to LoadBalancer in the file “ingress-nginx.yaml”

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


## Sample Application

Create sample application and route the request through the ingress controller to the application

Create yaml file test-example.yaml. This file is created under test-example folder

    kind: Pod
    apiVersion: v1
    metadata:
      name: foo-app
      labels:
        app: foo
    spec:
      containers:
      - command:
        - /agnhost
        - netexec
        - --http-port
        - "8080"
        image: registry.k8s.io/e2e-test-images/agnhost:2.39
        name: foo-app
    ---
    kind: Service
    apiVersion: v1
    metadata:
      name: foo-service
    spec:
      selector:
        app: foo
      ports:
      # Default port used by the image
      - port: 8080
    ---
    kind: Pod
    apiVersion: v1
    metadata:
      name: bar-app
      labels:
        app: bar
    spec:
      containers:
      - command:
        - /agnhost
        - netexec
        - --http-port
        - "8080"
        image: registry.k8s.io/e2e-test-images/agnhost:2.39
        name: bar-app
    ---
    kind: Service
    apiVersion: v1
    metadata:
      name: bar-service
    spec:
      selector:
        app: bar
      ports:
      # Default port used by the image
      - port: 8080
    ---
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: example-ingress
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /$2
    spec:
      rules:
      - http:
          paths:
          - pathType: Prefix
            path: /foo(/|$)(.*)
            backend:
              service:
                name: foo-service
                port:
                  number: 8080
          - pathType: Prefix
            path: /bar(/|$)(.*)
            backend:
              service:
                name: bar-service
                port:
                  number: 8080
    ---

Deploy the application and ingress resource

    kubectl apply -f test-example/test-example.yaml

Execute the URL http://localhost/bar and http://localhost/foo in the browser, We can see the response 


    NOW: 2024-07-13 12:04:13.464536381 +0000 UTC m=+54.535936818



# References
https://github.com/marcel-dempers/docker-development-youtube-series/tree/master/kubernetes/ingress/controller/nginx

https://www.youtube.com/watch?v=72zYxSxifpM&


[https://youtu.be/72zYxSxifpM](https://youtu.be/72zYxSxifpM)

