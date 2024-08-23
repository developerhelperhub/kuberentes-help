module "kind_cluster" {
  source = "./modules/kind"

  name = "test-cluster"
  http_port = 80
  https_port = 443
}

provider "kubernetes" {

  host                   = module.kind_cluster.endpoint
  client_certificate     = module.kind_cluster.client_certificate
  client_key             = module.kind_cluster.client_key
  cluster_ca_certificate = module.kind_cluster.cluster_ca_certificate
}

module "kind_ingress" {
  source = "./modules/kind/ingress"

  kube_endpoint = module.kind_cluster.endpoint
  kube_client_key = module.kind_cluster.client_key
  kube_client_certificate = module.kind_cluster.client_certificate
  kube_cluster_ca_certificate = module.kind_cluster.cluster_ca_certificate

  depends_on = [module.kind_cluster]
}

provider "helm" {
    kubernetes {
        host                   = module.kind_cluster.endpoint
        client_certificate     = module.kind_cluster.client_certificate
        client_key             = module.kind_cluster.client_key
        cluster_ca_certificate = module.kind_cluster.cluster_ca_certificate
    }
}

module "kubernetes_namespace" {
  source = "./modules/kubernetes/namespace"

  namespace_name = "devops"

  depends_on = [module.kind_ingress]
}

module "jenkins" {
  source = "./modules/jenkins"
  
  kubernetes_namespace = module.kubernetes_namespace.namespace
  service_port = 8080

  depends_on = [module.kubernetes_namespace]
}