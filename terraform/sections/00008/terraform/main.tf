module "microservices" {
  source = "git::https://github.com/developerhelperhub/microservices-terraform-module.git//microservices?ref=dev"

  kind_cluster_name = var.kind_cluster_name
  kind_http_port    = 80
  kind_https_port   = 443

  kubernetes_namespace = "microservices"

  kong_enable            = true
  kong_admin_domain_name = var.kong_admin_domain_name
  kong_proxy_domain_name = var.kong_proxy_domain_name

  kong_db_user           = "mykong"
  kong_db_name           = "mykongdb"
  kong_db_password       = "MyPassword2222@"
  kong_db_admin_password = "MyPassword2222@"
  kong_persistence_size  = "5Gi"
}
