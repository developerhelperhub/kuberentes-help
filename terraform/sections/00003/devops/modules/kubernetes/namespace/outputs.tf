output "namespace" {
  value = kubernetes_namespace.devops.metadata[0].name
}