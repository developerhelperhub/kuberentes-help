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