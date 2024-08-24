variable "kind_cluster_name" {
    description = "Kind cluster name"
}

variable "kind_http_port" {
    description = "Kind cluster http expose port"
}

variable "kind_https_port" {
    description = "Kind cluster https expose port"
}

variable "jenkins_service_port" {
    description = "Kind cluster name"
}

variable "kubernetes_namespace" {
  description = "Resources are installing in the Kubernetes namespace"
}

variable "jenkins_domain_name" {
    description = "Jenkins domain name"
}

variable "jenkins_admin_username" {
    description = "Jenkins admin username"
}

variable "jenkins_admin_password" {
    description = "Jenkins admin password"
#    sensitive = true 
}