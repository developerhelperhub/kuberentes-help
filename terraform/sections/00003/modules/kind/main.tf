resource "kind_cluster" "default" {
    name           = var.name
    node_image = "kindest/node:v1.27.1"
    wait_for_ready = true

  kind_config {
      kind        = "Cluster"
      api_version = "kind.x-k8s.io/v1alpha4"

      node {
          role = "control-plane"

          kubeadm_config_patches = [
              "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
          ]

          extra_port_mappings {
              container_port = var.http_port
              host_port      = var.http_port
          }
          extra_port_mappings {
              container_port = var.https_port
              host_port      = var.https_port
          }
      }
  }
}
