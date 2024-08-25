#This module is used to manage Jenkins-related resources, providers and Kubernetes ingress configuration. The Helm Jenkins support version 5.4.2.
resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "5.4.2"

  namespace = var.kubernetes_namespace

  set {
    name  = "controller.servicePort"
    value = var.service_port
  }

  set {
    name  = "controller.admin.username"
    value = var.admin_username
  }

  set {
    name  = "controller.admin.password"
    value = var.admin_password
  }

  timeout = 600

  depends_on = [var.kubernetes_namespace]
}

# Jenkins ingress configuration 
resource "kubernetes_ingress_v1" "jenkins-ingress" {
  metadata {
    name      = "jenkins-ingress"
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
              name = helm_release.jenkins.name
              port {
                number = var.service_port
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.jenkins]
}