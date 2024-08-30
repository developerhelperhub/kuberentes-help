
#This namespace is using to create the resources under DevOps cluster
output "namespace" {
  value = kubernetes_namespace.devops.metadata[0].name
}