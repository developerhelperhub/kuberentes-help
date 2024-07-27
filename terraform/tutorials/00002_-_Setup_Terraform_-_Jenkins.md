# 00002 - Setup Terraform - Jenkins
This section helps to basic understand how can we install the Jenkins in the Kubernetes Cluster with help of Terraform

Understand basic following topics available in the section 

- Kubernetes/0002-Kind  - Setup the cluster
- Kubernetes/0004-Jenkins - Setup the Jenkins in Kubernetes cluster

**Check the helm chart version of Jenkins**

Identify the latest helm chart version Jenkins and use the latest version in the Terraform script.
****
    helm search repo jenkins

**Configure Terraform Providers for Helm and Kubernetes**
To configure Terraform to use Helm and Kubernetes providers, you'll need to set up a Terraform configuration file “terraform.tf”. Here is a step-by-step guide:

**Create a Terraform Configuration File (terraform.tf):**

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

**Create a main Configuration File (main.tf):**
This file we can configure the helm related configuration of the Jenkins and configure the ingress resource configuration for the Jenkins service of Kubernetes.

    
    
    resource "kubernetes_namespace" "jenkins" {
      metadata {
        name = "jenkins"
      }
    }
    
    resource "helm_release" "jenkins" {
      name       = "jenkins"
      repository = "https://charts.jenkins.io"
      chart      = "jenkins"
      version    = "5.4.2"
    
      namespace = kubernetes_namespace.jenkins.metadata[0].name
    
      set {
        name  = "controller.servicePort"
        value = "8080"
      }
    
      set {
        name  = "controller.admin.password"
        value = "admin"
      }
    
      timeout = 600
    
      depends_on = [kubernetes_namespace.jenkins]
    }
    
    
    resource "kubernetes_ingress_v1" "jenkins-ingress" {
      metadata {
        name      = "jenkins-ingress"
        namespace = kubernetes_namespace.jenkins.metadata[0].name
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

**Apply the Updated Configuration**

**Initialise Terraform:**

    terraform init

**Ensure Terraform is Initialised:**
To run a `terraform plan` and ensure your Terraform configuration is correct.


    terraform plan

**Apply the Terraform Configuration:**
To apply your Terraform configuration and deploy your resources.


    terraform apply

Execute the URL http://localhost in the browser

