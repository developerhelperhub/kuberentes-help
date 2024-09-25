#This is variable arguments while running the terraform scripts
variable "kind_cluster_name" {
    type = string
    description = "Kind cluster name"
}

variable "keycloak_domain_name" {
    type = string
    description = "Keycloak domain name"
    default = "keycloak.myapp.com"
}