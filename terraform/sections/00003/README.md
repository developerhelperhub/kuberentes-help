# 00003 - Module Design Jenkins Deployment in Kubernetes
This section provides a basic understanding of how to implement modularised scripts in the Terraform development lifecycle, as well as the problems and challenges this approach aims to address. I will explain this using an example of deploying Jenkins on a Kubernetes cluster with the help of the Kind tool. Additionally, I have published another post that demonstrates how to deploy Jenkins without using the modular concept.

## Objective 

In software architecture, it is important to consider qualities like modularity, maintainability, agility, and readability when building source code. These design considerations help enhance the overall quality of the application.

## Why we have to consider the Terraform Module in DevOps

The following benefits can be achieved by implementing the module concept in Terraform development:

- **Encapsulate and Reuse Code**: By defining a module, you can reuse the same configuration in different places, promoting consistency and reducing redundancy.
- **Encapsulate Complex Resources**: For example, instead of defining an entire VPC configuration in the root module, you can create a `vpc` module that simplifies the creation and management of VPCs.
- **Organize Code**: Breaking down a complex infrastructure into smaller, more manageable parts can make the configuration easier to read and maintain.

When setting up resources in a DevOps infrastructure, the following problems and challenges are addressed:

- How can we group providers for specific resources?
- How can we reuse resource scripts to set up multiple environments, such as production and development, where only the names and configurations differ for each environment?
- How can we randomly generate passwords, securely store them during development, and prevent them from being exposed publicly?
- How can we ensure the same setup module is used across multiple project teams?
    - How can we manage module versions, especially when different projects require different resource versions and configurations, ensuring that changes in one module do not affect other project teams?
- How can we pass arguments when creating resources or infrastructure?
- How can we maintain the Terraform state across multiple environments when setting up multiple environments?

Following module / folder structure, I am maintain the Jenkins installation setup in the Kubernetes cluster

![](https://paper-attachments.dropboxusercontent.com/s_F00C8169C8ED33E298C0812395CE316D8299DAA948C0E6780B214A67FE8076EE_1724495679647_image.png)

## “devops.modules.common” module

This module is used to manage the common resources and providers needed in the root and child modules of "devops." In this example, we are using the "random_password" resource to generate a password for Jenkins.
Script `main.tf`
```shell
#This script is where we define the common module needed for the parent and child modules.
terraform {
    required_providers {
    random = {
        source = "hashicorp/random"
    }
    }
}

#This resource is designed to generate a 16-character password across the system to enhance security. It can be used to create passwords for users, ensuring that each password includes special characters, uppercase and lowercase letters, and default numbers. You can also specify which special characters should be included in the password.
resource "random_password" "random_password_16" {
    length           = 16
    special          = true
    upper            = true
    lower            = true
    override_special = "#$%&" # Only these special characters are allowed
}
```
Script `output.tf`
```shell
#This random_password_16 output used to access other module
output "random_password_16" {
    value = random_password.random_password_16.result
}
```
## “devops.modules.helm” module

This module is used to manage Helm-related resources and providers. The Helm support version 2.14 or above.
Script `terraform.tf`
```shell
terraform {
    required_providers {
    helm = {
        source = "hashicorp/helm"
        version = "~> 2.14"
    }
    }
}
```
## “devops.modules.jenkins” module

This module is used to manage Jenkins-related resources, providers and Kubernetes ingress configuration. The Helm Jenkins support version 5.4.2.
Script `main.tf`
```shell
#This module is used to manage Jenkins-related resources, providers and Kubernetes ingress configuration. The Helm Jenkins support version 5.4.2.
resource "helm_release" "jenkins" {
    name       = "jenkins"
    repository = "https://charts.jenkins.io"
    chart      = "jenkins"
    version    = "5.4.2"
    namespace = var.kubernetes_namespace
    set {
    name  = "controller.servicePort"
    value = var.service_port
    }
    set {
    name  = "controller.admin.username"
    value = var.admin_username
    }
    set {
    name  = "controller.admin.password"
    value = var.admin_password
    }
    timeout = 600
    depends_on = [var.kubernetes_namespace]
}
# Jenkins ingress configuration 
resource "kubernetes_ingress_v1" "jenkins-ingress" {
    metadata {
    name      = "jenkins-ingress"
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
                name = helm_release.jenkins.name
                port {
                number = var.service_port
                }
            }
            }
        }
        }
    }
    }
    depends_on = [helm_release.jenkins]
}
```
Script `variabiles.tf`
```shell
variable "kubernetes_namespace" {
    description = "Namepace of kubernetes the service need to install"
}
variable "service_port" {
    description = "Jenkins service port"
}
variable "domain_name" {
    description = "Jenkins domain name"
}
variable "admin_username" {
    description = "Jenkins admin username"
}
variable "admin_password" {
    description = "Jenkins admin password"
#  sensitive = true 
}
```
## “devops.modules.kind” module

This module is used to manage Kind-related resources, providers and kind ingress controller script file. The Kind support version 1.27.1
Script `main.tf`
```shell
resource "kind_cluster" "default" {
    name           = var.name
    node_image = "kindest/node:v1.27.1"
    wait_for_ready = true
    kind_config {
        kind        = "Cluster"
        api_version = "kind.x-k8s.io/v1alpha4"
        node {
            role = "control-plane"
            
            #Ingress enabledd
            kubeadm_config_patches = [
                "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
            ]
            # Exposing the ports are http and https in the cluster
            extra_port_mappings {
                container_port = var.http_port
                host_port      = var.http_port
            }
            extra_port_mappings {
                container_port = var.https_port
                host_port      = var.https_port
            }
        }
    }
}
```
Script `outputs.tf`
```shell
#These are variables used to configure in the Kubernetes and Helm configuration after creating the Kubernetes cluster
output "kubeconfig" {
    value = kind_cluster.default.kubeconfig
}
output "endpoint" {
    value = kind_cluster.default.endpoint
}
output "client_key" {
    value = kind_cluster.default.client_key
}
output "client_certificate" {
    value = kind_cluster.default.client_certificate
}
output "cluster_ca_certificate" {
    value = kind_cluster.default.cluster_ca_certificate
}
```
Script `terraform.tf`
```shell
#Kind resources version support 0.5.1
terraform {
    required_providers {
    kind = {
        source = "tehcyx/kind"
        version = "0.5.1"
    }
    }
}
```
Script `variables.tf`
```shell
variable "name" {
    description = "Cluster name"
}
variable "http_port" {
    description = "Exposing http port number"
}
variable "https_port" {
    description = "Exposing https port number"
}
```
## “devops.modules.kind.ingress” module

This module is used to manage Kind ingress controller resource and this resource installing by Kubernetes shell script command.
```shell
resource "null_resource" "apply_kubectl" {
    provisioner "local-exec" {
    # Service Type and Port are "LoadBalancer" and 80
    command = "kubectl apply -f ${path.module}/ingress-nginx.yaml"
    
    # Configuring the cluster information and these information getting from kind resource
    environment = {
        KUBERNETES_HOST       = var.kube_endpoint
        CLIENT_CERTIFICATE    = var.kube_client_certificate
        CLIENT_KEY            = var.kube_client_key
        CLUSTER_CA_CERTIFICATE = var.kube_cluster_ca_certificate
    }
    }
}
```
## “devops.modules.kubernetes” module

This module is used to manage Kubernetes-related resources, providers. The Kubernetes support version 2.31 or above
Script `terraform.tf`
```shell
terraform {
    required_providers {
    kubernetes = {
        source = "hashicorp/kubernetes"
        version = "~> 2.31"
    }
    }
}
```
## “devops.modules.kubernetes.namespace” module

This module is used to manage Kubernetes namespace-related resources, providers.
Script `main.tf`
```shell
resource "kubernetes_namespace" "devops" {
    metadata {
    name = var.namespace_name
    }
}
```
Script `outputs.tf`
```shell
#This namespace is using to create the resources under DevOps cluster
output "namespace" {
    value = kubernetes_namespace.devops.metadata[0].name
}
```

Script `variables.tf`
```shell
variable "namespace_name" {
    description = "Name of the kubernetes namespace"
}
```
## “devops” module

This is the main module for managing all DevOps-related modules and includes the installation steps for services that need to be deployed on the Kubernetes cluster. In this example, we configure DevOps tools required for the application, such as Kind Cluster, Kind Ingress Controller, Kubernetes provider and namespace, Helm provider, and Jenkins.
**Note:** You can add resource configurations to this main module to install additional services in the DevOps cluster, such as JFrog Artifactory, Prometheus, Grafana, and more.
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
#Instaling the jenkins
module "jenkins" {
    source = "./modules/jenkins"
    
    kubernetes_namespace = module.kubernetes_namespace.namespace
    service_port = var.jenkins_service_port
    domain_name = var.jenkins_domain_name
    admin_username = var.jenkins_admin_username
    admin_password = var.jenkins_admin_password
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
variable "jenkins_service_port" {
    description = "Kind cluster name"
}
variable "kubernetes_namespace" {
    description = "Resources are installing in the Kubernetes namespace"
}
variable "jenkins_domain_name" {
    description = "Jenkins domain name"
}
variable "jenkins_admin_username" {
    description = "Jenkins admin username"
}
variable "jenkins_admin_password" {
    description = "Jenkins admin password"
#    sensitive = true 
}
```
**Root Main Terraform Script**
This is the main root script install the resources of DevOps 
Script `main.tf`
```shell
module "common" {
    source = "./devops/modules/common"
}
module "devops" {
    source = "./devops"
    kind_cluster_name = var.kind_cluster_name
    kind_http_port = 80
    kind_https_port = 443
    kubernetes_namespace = "devops"
    jenkins_service_port = 8080
    jenkins_domain_name = var.jenkins_domain_name
    jenkins_admin_username = var.jenkins_admin_username
    jenkins_admin_password = module.common.random_password_16
}
```
Script `variables.tf`
```shell
#This is variable arguments while running the terraform scripts
variable "kind_cluster_name" {
    type = string
    description = "Kind cluster name"
}
variable "jenkins_domain_name" {
    type = string
    description = "Jenkins domain name"
    default = "jenkins.devops.com"
}
variable "jenkins_admin_username" {
    type = string
    description = "Jenkins admin username"
    default = "test_admin"
}
```

## Setup local environment to build DevOps resources

I use docker containers to set up work environments for multiple applications([Setup Environment](https://dev.to/binoy_59380e698d318/setup-linux-box-on-local-with-docker-container-3k8)). This approach ensures fully isolated and maintainable environments for application development, allowing us to easily start and terminate these environments. Below is the Docker command to create the environment.
```shell
docker run -it --name test-jenkins-module-envornment-box -v ~/.kube/config:/work/.kube/config -e KUBECONFIG=/work/.kube/config -v ${HOME}/root/ -v ${PWD}/work -w /work --net host developerhelperhub/kub-terr-work-env-box
```
The container contains Docker, Kubectl, Helm, Terraform, Kind, Git


## Setup Jenkins on Kubernetes Cluster 

I have created all the Terraform scripts, which are available in the GitHub repository. You can download and set up Jenkins on a Kubernetes cluster, which runs locally in a Docker container.

**Clone the repository** onto your local Linux machine to get started.
```shell
git clone https://github.com/developerhelperhub/kuberentes-help.git
cd kuberentes-help/terraform/sections/00003/
```
Run the following commands to install the resources
```shell
terraform init

#Create the workspace to keep the separate the terraform state files of dev and production. This helps us to maintain multiple running in local
terraform workspace new devops_testing
terraform workspace select devops_testing

terraform plan
terraform apply  -var="kind_cluster_name=devops-test-cluster"  -var="jenkins_admin_username=my_test_admin"
```
**Note:** The Terraform state file should be kept secure and encrypted (using encryption at rest) because it contains sensitive information, such as usernames, passwords, and Kubernetes cluster details etc.

Add our domain to the bottom of the `/etc/hosts` file on your local machine. This configuration should not be inside our working Linux box “test-jforg-envornment-box”; it should be applied to your personal machine's `/etc/hosts` file. 
(you will need administrator access):
```shell
127.0.0.1 jenkins.devops.com
```
We can open the artifactory UI in the browser “http://jenkins.devops.com/”
*Note:** Username and password will be available in the Terraform state file

**Destroy and clean the resources**
Following command can be used clean all resources which installed by Terraform and its supporting files

I have created a shell script which clean all terraform generated files and folders `terraform-clean.sh`
```shell
#!/bin/bash
# Remove the .terraform directory
echo "Removing .terraform directory..."
rm -rf .terraform
rm -rf .terraform.lock.hcl
# Remove Terraform state files
echo "Removing terraform.tfstate and terraform.tfstate.backup..."
rm -f terraform.tfstate terraform.tfstate.backup
rm -rf terraform.tfstate.d
# Remove Terraform plan files
echo "Removing *.plan files..."
rm -f *.plan

echo "Removing *-config files of kind..."
rm -f *-config
echo "Terraform cleanup completed."
```
Following command can be used to clean resources, folder and files
```shell
terraform destroy -var="kind_cluster_name=devops-test-cluster"
terraform workspace select default
terraform workspace delete devops_testing

chmod +x terraform-clean.sh
sh ./terraform-clean.sh
```

## References

* https://developer.hashicorp.com/terraform/tutorials/modules/pattern-module-creation
* https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d

