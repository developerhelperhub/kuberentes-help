module "microservices" {
  source = "git::https://github.com/developerhelperhub/microservices-terraform-module.git//microservices?ref=v1.1.0"

  kind_cluster_name = var.kind_cluster_name
  kind_http_port    = 80
  kind_https_port   = 443

  kubernetes_namespace = "microservices"

  keycloak_enable      = true
  keycloak_domain_name = var.keycloak_domain_name

  keycloak_admin_user     = "admin"
  keycloak_admin_password = "MyPassword2222@"

  keycloak_resources_requests_cpu    = "500m"
  keycloak_resources_requests_memory = "1024Mi"
  keycloak_resources_limit_cpu       = "500m"
  keycloak_resources_limit_memory    = "1024Mi"
  keycloak_db_password               = "MyPassword2222@"
  keycloak_db_admin_password         = "MyPassword2222@"
  keycloak_autoscaling_min_replicas  = 1
  keycloak_autoscaling_max_replicas  = 1
  keycloak_persistence_size          = "8Gi"

}
