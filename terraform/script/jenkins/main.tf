

resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "5.4.2"

  namespace = kubernetes_namespace.jenkins.metadata[0].name

  set {
    name  = "controller.servicePort"
    value = "8080"
  }

  set {
    name  = "controller.admin.password"
    value = "admin"
  }

  timeout = 600

  depends_on = [kubernetes_namespace.jenkins]
}


resource "kubernetes_ingress_v1" "jenkins-ingress" {
  metadata {
    name      = "jenkins-ingress"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    rule {
      http {
        path {
          path     = "/"
          path_type = "Prefix"
          backend {
            service {
              name = helm_release.jenkins.name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.jenkins]
}