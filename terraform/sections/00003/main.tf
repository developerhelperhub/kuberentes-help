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