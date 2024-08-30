# 00005 - JFrog Deployment in Kubernetes
This section explains the deployment of JFrog on a Kubernetes cluster using Terraform. The module design principles were previously explained in the [Jenkins Section](https://dev.to/binoy_59380e698d318/terraform-module-design-jenkins-deployment-in-kubernetes-3276), which covered how to build module design in Terraform. Here, the focus is specifically on configuring JFrog resources and integrating these configurations into the main DevOps module.

## “devops.modules.jfrog” module

This module is used to manage Jfrog-related resources, providers and Kubernetes ingress configuration. The Helm JFrog support version 107.90.8.
Script `main.tf`
```shell
#This module is used to manage Artifactory-related resources, providers and Kubernetes ingress configuration. The Helm Artifactory support version 107.90.8.
resource "helm_release" "artifactory-oss" {
    name       = "jfrog-artifactory-oss"
    repository = "https://charts.jfrog.io"
    chart      = "artifactory-oss"
    version    = "107.90.8"
    namespace = var.kubernetes_namespace
    set {
    name  = "artifactory.postgresql.postgresqlPassword"
    value = var.postgresql_password
    }
    set {
    name  = "artifactory.nginx.enabled"
    value = false
    }
    set {
    name  = "artifactory.ingress.enabled"
    value = false
    }
    timeout = 600
    depends_on = [var.kubernetes_namespace]
}
# Artifactory ingress configuration 
resource "kubernetes_ingress_v1" "artifactory-oss-ingress" {
    metadata {
    name      = "artifactory-oss-ingress"
    namespace = var.kubernetes_namespace
    annotations = {
        "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
    }
    spec {
    rule {
        host = var.domain_name
        http {
        path {
            path     = "/"
            path_type = "Prefix"
            backend {
            service {
                name = helm_release.artifactory-oss.name
                port {
                number = var.service_port
                }
            }
            }
        }
        }
    }
    }
    depends_on = [helm_release.artifactory-oss]
}
```
Script `variabiles.tf`
```shell
variable "kubernetes_namespace" {
    description = "Namepace of kubernetes the service need to install"
}
variable "service_port" {
    description = "Jfrog service port"
}
variable "postgresql_password" {
    description = "Postgresql password"
}
variable "domain_name" {
    description = "Jfrog domain name"
}
```
## “devops” module

This is the main module for managing all DevOps-related modules and includes the installation steps for services that need to be deployed on the Kubernetes cluster. In this example, we configure DevOps tools required for the application, such as Kind Cluster, Kind Ingress Controller, Kubernetes provider and namespace, Helm provider, and JFrog.

Script `main.tf`
```shell
#Installing the cluster in Docker
module "kind_cluster" {
    source = "./modules/kind"
    name = var.kind_cluster_name
    http_port = 80
    https_port = 443
}
#Configuring the kubenretes provider based on the cluster information
provider "kubernetes" {
    host                   = module.kind_cluster.endpoint
    client_certificate     = module.kind_cluster.client_certificate
    client_key             = module.kind_cluster.client_key
    cluster_ca_certificate = module.kind_cluster.cluster_ca_certificate
}
#Installing the ingress controller in the cluster, this ingress support by kind. This ingress controller will be different based on the clusters such as AWS, Azure, Etc.
module "kind_ingress" {
    source = "./modules/kind/ingress"
    kube_endpoint = module.kind_cluster.endpoint
    kube_client_key = module.kind_cluster.client_key
    kube_client_certificate = module.kind_cluster.client_certificate
    kube_cluster_ca_certificate = module.kind_cluster.cluster_ca_certificate
    depends_on = [module.kind_cluster]
}
#Configuring the helm provider based on the cluster information
provider "helm" {
    kubernetes {
        host                   = module.kind_cluster.endpoint
        client_certificate     = module.kind_cluster.client_certificate
        client_key             = module.kind_cluster.client_key
        cluster_ca_certificate = module.kind_cluster.cluster_ca_certificate
    }
}
#Installing the namespace in the Kuberenetes cluster
module "kubernetes_namespace" {
    source = "./modules/kubernetes/namespace"
    namespace_name = var.kubernetes_namespace
    depends_on = [module.kind_ingress]
}
#Instaling the Jfrog Artifactory
module "jfrog" {
    source = "./modules/jfrog"
    
    kubernetes_namespace = module.kubernetes_namespace.namespace
    service_port = var.jfrog_service_port
    domain_name = var.jfrog_domain_name
    postgresql_password = "admin_password_postgress"
    
    depends_on = [module.kubernetes_namespace]
}
```
Script `variables.tf`
```shell
variable "kind_cluster_name" {
    description = "Kind cluster name"
}
variable "kind_http_port" {
    description = "Kind cluster http expose port"
}
variable "kind_https_port" {
    description = "Kind cluster https expose port"
}
variable "jfrog_service_port" {
    description = "Jfrog service port"
}
variable "kubernetes_namespace" {
    description = "Resources are installing in the Kubernetes namespace"
}
variable "jfrog_domain_name" {
    description = "Jfrog domain name"
}
```
**Root Main Terraform Script**
This is the main root script install the resources of DevOps 
Script `main.tf`
```shell
module "devops" {
    source = "./devops"
    kind_cluster_name = var.kind_cluster_name
    kind_http_port = 80
    kind_https_port = 443
    kubernetes_namespace = "devops"
    jfrog_service_port = 8082
    jfrog_domain_name = var.jfrog_domain_name
}
```
Script `variables.tf`
```shell
#This is variable arguments while running the terraform scripts
variable "kind_cluster_name" {
    type = string
    description = "Kind cluster name"
}
variable "jfrog_domain_name" {
    type = string
    description = "Jfrog domain name"
    default = "jfrog.devops.com"
}
```

## Setup local environment to build DevOps resources

I use docker containers to set up work environments for multiple applications([Setup Environment](https://dev.to/binoy_59380e698d318/setup-linux-box-on-local-with-docker-container-3k8)). This approach ensures fully isolated and maintainable environments for application development, allowing us to easily start and terminate these environments. Below is the Docker command to create the environment.
```shell
docker run -it --name test-jfrog-module-envornment-box -v ~/.kube/config:/work/.kube/config -e KUBECONFIG=/work/.kube/config -v ${HOME}/root/ -v ${PWD}/work -w /work --net host developerhelperhub/kub-terr-work-env-box
```
The container contains Docker, Kubectl, Helm, Terraform, Kind, Git

## Setup JFrog on Kubernetes Cluster 

I have created all the Terraform scripts, which are available in the GitHub repository. You can download and set up JFrog on a Kubernetes cluster, which runs locally in a Docker container.

**Clone the repository** onto your local Linux machine to get started.
```shell
git clone https://github.com/developerhelperhub/kuberentes-help.git
cd kuberentes-help/terraform/sections/00005/
```
Run the following commands to install the resources
```shell
terraform init

#Create the workspace to keep the separate the terraform state files of dev and production. This helps us to maintain multiple running in local
terraform workspace new devops_testing
terraform workspace select devops_testing

terraform plan
terraform apply  -var="kind_cluster_name=devops-test-cluster"
```
**Note:** The Terraform state file should be kept secure and encrypted (using encryption at rest) because it contains sensitive information, such as usernames, passwords, and Kubernetes cluster details etc.

Add our domain to the bottom of the `/etc/hosts` file on your local machine. This configuration should not be inside our working Linux box “test-jfrog-module-envornment-box”; it should be applied to your personal machine's `/etc/hosts` file. 
(you will need administrator access):
```shell
127.0.0.1 jfrog.devops.com
```
We can open the Jfrog UI in the browser “http://jfrog.devops.com/”
**Note**: Username and password are “admin” and “password”


## References
- https://github.com/developerhelperhub/kuberentes-help/tree/main/terraform/sections/00003
- https://github.com/developerhelperhub/kuberentes-help/tree/main/kubenretes/tutorials/sections/0009

