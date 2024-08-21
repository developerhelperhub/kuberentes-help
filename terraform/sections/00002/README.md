# 00002 - Setup Jenkins on Kubernetes with help of Terraform
This section helps to basic understand how can we install the Jenkins in the Kubernetes Cluster with help of Terraform

## Setup local environment
I use Docker containers to set up work environments for multiple applications([Setup Environment](https://dev.to/binoy_59380e698d318/setup-linux-box-on-local-with-docker-container-3k8)). This approach ensures fully isolated and maintainable environments for application development, allowing us to easily start and terminate these environments. Below is the Docker command to create the environment.
```shell
docker run -it --name test-jenkins-envornment-box -v ${HOME}/root/ -v ${PWD}/work -w /work --net host developerhelperhub/kub-terr-work-env-box sh
```
The container contains Docker, Kubectl, Helm, Terraform, Kind, Git

## Setup Jenkins on Kubernetes Cluster 

I have created all the Terraform scripts, which are available in the GitHub repository. You can download and set up Jenkins on a Kubernetes cluster, which runs locally in a Docker container.

**Clone the repository** onto your local Linux machine to get started.
```shell
git clone https://github.com/developerhelperhub/kuberentes-help.git
cd kuberentes-help/terraform/script/docs-scripts/0002
```

**Set up the Kubernetes cluster** in a Docker container using Kind, naming the cluster “devops-jenkins-cluster-control-plane” This cluster supports ingress and exposes ports 80 and 443 to allow access to services from outside the cluster.

Cluster create terraform script under kind folder
```shell
cd kind
terraform init #Install the required providers to set up the necessary resources.
terraform plan #Verify the resources that will be installed on the system.
terraform apply #Install resources on the system
```
Following command verify the cluster
```shell
kubectl cluster-info
kubectl get nodes -o wide
```

## Explain Terraform Script to setup Jenkins 

This section outlines the Terraform providers and resource scripts needed to set up Jenkins.

**Configure Terraform Providers for Helm and Kubernetes**
To configure Terraform to use Helm and Kubernetes providers, you'll need to set up a Terraform configuration file “terraform.tf”. Here is a step-by-step guide:

**Create a Terraform Configuration File (terraform.tf):**
```shell
terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.14"
    }
  }
}
provider "kubernetes" {
    config_path = "~/.kube/config"
}
provider "helm" {
    kubernetes {
        config_path = "~/.kube/config"
    }
}
```
**required_providers**: This block specifies the external providers that Terraform will use. Providers are plugins that enable interaction with external APIs or cloud providers.
**kubernetes** **provider**:

- **source**: Specifies the provider source, in this case, "hashicorp/kubernetes", indicating it's from HashiCorp.
- **version**: The version constraint `"~> 2.31"` means that Terraform will use the latest available version within the 2.x series starting from 2.31.

**helm** **provider**:

- **source**: Specifies the provider source, `"hashicorp/helm"`.
- **version**: The version constraint `"~> 2.14"` means that Terraform will use the latest available version within the 2.x series starting from 2.14.

**Create a main Configuration File (main.tf):**
This file allows us to configure the Helm settings for Jenkins and set up the Ingress resource configuration for the Jenkins service on Kubernetes.
```shell
resource "kubernetes_namespace" "devops" {
  metadata {
    name = "devops"
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "5.4.2"

  namespace = kubernetes_namespace.devops.metadata[0].name

  set {
    name  = "controller.servicePort"
    value = "8080"
  }

  set {
    name  = "controller.admin.password"
    value = "admin"
  }

  timeout = 600

  depends_on = [kubernetes_namespace.devops]
}


resource "kubernetes_ingress_v1" "jenkins-ingress" {
  metadata {
    name      = "jenkins-ingress"
    namespace = kubernetes_namespace.devops.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    rule {
      http {
        path {
          path     = "/"
          path_type = "Prefix"
          backend {
            service {
              name = helm_release.jenkins.name
              port {
                number = 8080
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
These Terraform scripts install and configure resources in the cluster:

- Create a namespace called "devops."
- Install Jenkins in the "devops" namespace using a Helm chart.
- Jenkins username and password default “admin” and “admin”
- Set up the Jenkins Ingress resource to connect the Ingress controller with the Jenkins service.
- Configure the Jenkins container to run on port 8080 and expose it to port 80 through the Ingress controller.

These scripts are available under “jenkins” folder
```shell
cd jenkins
terraform init #Install the required providers to set up the necessary resources.
terraform plan #Verify the resources that will be installed on the system.
terraform apply #Install resources on the system
```

Following command verify the Jenkins Service
```shell
kubectl get namespace #verify the devops namespace
kubectl get -n devops pod #verify jenkins server is running
kubectl get -n devops svc #verify jenkins service
```

**Setup Nginx ingress controller on Kubernetes cluster**
The NGINX Ingress Controller to manage the external access to services in a Kubernetes cluster. It acts as an entry point for your Kubernetes applications, routing external HTTP and HTTPS traffic to the appropriate services within the cluster.

Following command install the ingress controller on cluster

Cluster create terraform script under “ingress” folder
```shell
cd ingress
kubectl apply -f ingress-nginx.yaml
```

Following command verify the nginx ingress controller
```shell
kubectl get -n ingress-nginx pod
```
Output
```shell
NAME                                       READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-5mt2k       0/1     Completed   0          53s
ingress-nginx-admission-patch-w2rlk        0/1     Completed   0          53s
ingress-nginx-controller-d45d995d4-gl65h   1/1     Running     0          53s
```

Now we can open the “http://localhost” in browser to see the login screen of Jenkins

![](https://paper-attachments.dropboxusercontent.com/s_BA3BAE44DD4083A7F8698A3B07D54D5F29C93AE9DF365B514CDB45DDC32FE257_1723318588409_image.png)

##Reference
* [Git Rep Doc](https://github.com/developerhelperhub/kuberentes-help/blob/main/terraform/tutorials/00002_-_Setup_Jenkins_on_Kubernetes_with_help_of_T.md)
* [Git Repo Script](https://github.com/developerhelperhub/kuberentes-help/tree/main/terraform/script/docs-scripts/0002)
* [Setup Environment](https://dev.to/binoy_59380e698d318/setup-linux-box-on-local-with-docker-container-3k8)
* [Cluster creation with help Kind and Terrafrom](https://dev.to/binoy_59380e698d318/setup-linux-box-on-local-with-docker-container-3k8)