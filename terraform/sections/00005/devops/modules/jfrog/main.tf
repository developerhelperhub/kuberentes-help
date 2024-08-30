#This module is used to manage Artifactory-related resources, providers and Kubernetes ingress configuration. The Helm Artifactory support version 107.90.8.
resource "helm_release" "artifactory-oss" {
  name       = "jfrog-artifactory-oss"
  repository = "https://charts.jfrog.io"
  chart      = "artifactory-oss"
  version    = "107.90.8"

  namespace = var.kubernetes_namespace

  set {
    name  = "artifactory.postgresql.postgresqlPassword"
    value = var.postgresql_password
  }

  set {
    name  = "artifactory.nginx.enabled"
    value = false
  }

  set {
    name  = "artifactory.ingress.enabled"
    value = false
  }

  timeout = 600

  depends_on = [var.kubernetes_namespace]
}

# Artifactory ingress configuration 
resource "kubernetes_ingress_v1" "artifactory-oss-ingress" {
  metadata {
    name      = "artifactory-oss-ingress"
    namespace = var.kubernetes_namespace
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    rule {
      host = var.domain_name
      http {
        path {
          path     = "/"
          path_type = "Prefix"
          backend {
            service {
              name = helm_release.artifactory-oss.name
              port {
                number = var.service_port
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.artifactory-oss]
}