resource "kubernetes_namespace" "devops" {
  metadata {
    name = var.namespace_name
  }
}
