module "microservices" {
  source = "git::https://github.com/developerhelperhub/microservices-terraform-module.git//microservices?ref=v1.0.0"

  kind_cluster_name = var.kind_cluster_name
  kind_http_port    = 80
  kind_https_port   = 443

  kubernetes_namespace = "microservices"

  kube_prometheus_stack_enable = false
  prometheus_service_port      = 9090
  prometheus_domain_name       = var.prometheus_domain_name

  grafana_service_port   = 80
  grafana_domain_name    = var.grafana_domain_name

  prometheus_alertmanager_enabled      = true
  prometheus_persistent_volume_enabled = true
  prometheus_persistent_volume_size    = "1Gi"
}
