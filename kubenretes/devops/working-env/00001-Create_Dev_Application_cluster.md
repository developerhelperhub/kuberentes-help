# 00001-Create Dev Application cluster
We need to create Kubernetes cluster for our application resources need to be setup. This cluster is used to install following service for eg:

- Authentication Sever
- Api Gateway
- Microservices
- Database
- Monitoring Services
- Etc.

Create the folder to maintain the kind configuration file

    mkdir kind
    
    cd kind

Create configuration file “ngress-cluster-config.yaml”. This configuration to create cluster with enable the ingress and expose the 80 and 443 port

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

Execute the kind cluster creation command

    kind create cluster --config ngress-cluster-config.yaml --name mes-dev-application-cluster

Testing kubectl command in the “dev apline linux working env”

    docker exec -it mes-dev-devops-working-env sh # login in the linux box
    
    kubectl get node
    
    NAME                                        STATUS   ROLES           AGE     VERSION
    mes-dev-application-cluster-control-plane   Ready    control-plane   2m41s   v1.30.0

