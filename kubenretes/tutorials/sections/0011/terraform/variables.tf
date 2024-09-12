#This is variable arguments while running the terraform scripts
variable "kind_cluster_name" {
    type = string
    description = "Kind cluster name"
}

variable "prometheus_domain_name" {
    type = string
    description = "Prometheus domain name"
    default = "prometheus.devops.com"
}

variable "grafana_domain_name" {
    type = string
    description = "Grafana domain name"
    default = "grafana.devops.com"
}

