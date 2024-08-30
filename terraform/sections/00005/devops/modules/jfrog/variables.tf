variable "kubernetes_namespace" {
    description = "Namepace of kubernetes the service need to install"
}

variable "service_port" {
    description = "Jfrog service port"
}

variable "postgresql_password" {
    description = "Postgresql password"
}

variable "domain_name" {
  description = "Jfrog domain name"
}

# variable "admin_username" {
#   description = "Jfrog admin username"
# }

# variable "admin_password" {
#   description = "Jfrog admin password"
# #  sensitive = true 
# }
