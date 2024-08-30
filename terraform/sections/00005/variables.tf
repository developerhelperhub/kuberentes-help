#This is variable arguments while running the terraform scripts
variable "kind_cluster_name" {
    type = string
    description = "Kind cluster name"
}
variable "jfrog_domain_name" {
    type = string
    description = "Jfrog domain name"
    default = "jfrog.devops.com"
}