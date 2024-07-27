# 00001 - Setup Kubernetes Cluster on Docker with help of Kind
This section provides a guide on using Terraform to set up a Kubernetes cluster on a Docker container using the Kind tool. This approach is useful for testing new services or Kubernetes versions locally, as it allows you to create and delete clusters quickly without affecting other environments. It helps in developing and testing without impacting the main Kubernetes clusters.

# Prerequisites

The following services need to be installed on your local system:

- Install Docker Desktop [https://docs.docker.com/desktop/](https://docs.docker.com/desktop/)
- Install Kubectl (Client Version: v1.30.2)
- Install Kind (v0.23.0 go1.21.10 darwin/amd6)
- Install Terrafrom (1.9.3 - amd6)

Note: Ensure that Terraform and Kind are installed and that the system architecture is consistent. I am using the “amd64” architecture.

We need to create the Terraform scripts first. These scripts should be placed in a folder named "kind" to organize all Kind-related scripts in one location.
```shell
mkdir kind
cd kind
```

## Create a `providers.tf` Terraform script

This script defines all the providers required to set up the Kubernetes cluster using the Kind tool.

Terraform providers are plugins that allow Terraform to interact with various APIs and services. Each provider enables Terraform to manage resources for a specific platform or service, such as AWS, Azure, Google Cloud, or Kubernetes. Providers are responsible for translating Terraform configuration into API requests and managing the lifecycle of resources.
```shell
terraform {
  required_providers {
    kind = {
      source = "tehcyx/kind"
      version = "0.5.1"
    }
  }
}

provider "kind" {}
```

## Create a `main.tf` Terraform script

This main script configures the resources to be installed on our system using Terraform. We need to define the `kind_cluster` resources within this main script file.
```shell
resource "kind_cluster" "default" {
    name            = "test-cluster"
    node_image      = "kindest/node:v1.30.2"
    wait_for_ready  = true

    kind_config {
      kind        = "Cluster"
      api_version = "kind.x-k8s.io/v1alpha4"

      node {
          role = "control-plane"
          extra_port_mappings {
              container_port = 80
              host_port      = 80
          }
      }
  }
}
```

- **resource "kind_cluster" "default"**: This declares a resource block for creating a Kind cluster with the name `default`.
- **name = "test-cluster"**: Specifies the name of the Kind cluster as `test-cluster`.
- **node_image = "kindest/node**
- **v1.27.1"**: Defines the Docker image for the Kubernetes nodes. In this case, it uses `kindest/node` with version `v1.27.1`.
- **wait_for_ready = true**: Instructs Terraform to wait until the cluster is fully ready before proceeding.
- **kind_config**: Configures the Kind cluster with additional settings:
    - **kind = "Cluster"**: Specifies the kind of Kubernetes object, which is a `Cluster`.
    - **api_version = "kind.x-k8s.io/v1alpha4"**: Indicates the API version used for Kind configuration.
    - **node**: Defines the nodes in the cluster:
        - **role = "control-plane"**: Marks this node as the control plane node.
            - The control-plane node is responsible for managing and maintaining the cluster, worker nodes run the actual applications and services. Other roles, like ingress controllers and load balancers, handle traffic management and external access, while storage, logging, and monitoring roles support the operational needs of the cluster.
        - **extra_port_mappings**: Maps port `80` on the container to port `80` on the host, allowing access to services running on port `80` inside the container.

This configuration sets up a basic Kind cluster with one control-plane node and one worker node, making it suitable for local testing and development.

## Create a `output.tf` Terraform script
We can creates the output script used to define the outputs from Terraform configuration that can printed / displayed after infrastructure is created. Outputs are often used to share information about your infrastructure with other Terraform configurations or with users.
```shell
output "kubeconfig" {
  value = kind_cluster.default.kubeconfig
}

output "endpoint" {
  value = kind_cluster.default.endpoint
}

output "client_key" {
  value = kind_cluster.default.client_key
}
```

**Apply the Updated Configuration**

**Initialise Terraform:**
```shell
terraform init
```

**Ensure Terraform is Initialised:**
To run a `terraform plan` and ensure your Terraform configuration is correct.
```shell
terraform plan
```

**Apply the Terraform Configuration:**
To apply your Terraform configuration and deploy your resources.
```shell
terraform apply
```

We verify the created Kubernetes cluster information using the following command:
```shell
kubectl cluster-info

Kubernetes control plane is running at https://127.0.0.1:54592
CoreDNS is running at https://127.0.0.1:54592/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

We verify the created node information using the following command:
```shell
kubectl get node -o wide

NAME                         STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION      CONTAINER-RUNTIME
test-cluster-control-plane   Ready    control-plane   59s   v1.30.2   172.18.0.2    <none>        Debian GNU/Linux 12 (bookworm)   5.10.124-linuxkit   containerd://1.7.15
```


