resource "null_resource" "apply_kubectl" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/ingress-nginx.yaml"
    
    environment = {
      KUBERNETES_HOST       = var.kube_endpoint
      CLIENT_CERTIFICATE    = var.kube_client_certificate
      CLIENT_KEY            = var.kube_client_key
      CLUSTER_CA_CERTIFICATE = var.kube_cluster_ca_certificate
    }
  }
}