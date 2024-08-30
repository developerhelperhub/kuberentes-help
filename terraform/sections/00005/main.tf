module "devops" {
  source = "./devops"

  kind_cluster_name = var.kind_cluster_name
  kind_http_port = 80
  kind_https_port = 443
  kubernetes_namespace = "devops"
  jfrog_service_port = 8082
  jfrog_domain_name = var.jfrog_domain_name
}