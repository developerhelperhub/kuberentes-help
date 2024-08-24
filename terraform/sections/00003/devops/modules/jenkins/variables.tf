variable "kubernetes_namespace" {
    description = "Namepace of kubernetes the service need to install"
}

variable "service_port" {
    description = "Jenkins service port"
}

variable "domain_name" {
  description = "Jenkins domain name"
}

variable "admin_username" {
  description = "Jenkins admin username"
}

variable "admin_password" {
  description = "Jenkins admin password"
#  sensitive = true 
}
