locals {
  image_registry = format("%s.dkr.ecr.eu-west-1.amazonaws.com", var.aws_account_id)
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true
  timeout    = 300

  values = [yamlencode({
    global = {
      image = {
        registry = "${local.image_registry}"
      }
    }


    controller = {
      image = {
         digest = "sha256:1b493796f5dfbfd2e00a255b7fc32af849bc416ad45b31558540a951d1afa3ba"
      }
      admissionWebhooks = {       

        patch = {
          image = {
            digest = "sha256:8178d256be118c19488a9e8bbd46bdeb8a984c30f0e275a1695cbbd0d75b384b"
          }
        }
      }
      service = {
        type = "LoadBalancer"
        annotations = {
          "service.beta.kubernetes.io/aws-load-balancer-scheme"                  = "internet-facing"
          "service.beta.kubernetes.io/aws-load-balancer-type"                    = "nlb"  # or "classic"
          "service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout" = "3600"
          "service.beta.kubernetes.io/aws-load-balancer-security-groups"         = "${var.security_group_alb}" 
          "service.beta.kubernetes.io/aws-load-balancer-backend-protocol"        = "http"
        }
                
      }
    }
  })]
}



resource "kubernetes_ingress_v1" "this" {
  metadata {
    name      = "airflow-ingress"
    namespace = "airflow"
    annotations = {
  
      "nginx.ingress.kubernetes.io/ssl-redirect"      = "true"
      "nginx.ingress.kubernetes.io/backend-protocol"  = "HTTP"
    }
  }

  spec {
    ingress_class_name = "nginx"
    tls {
      hosts      = ["*.elb.${var.aws_region}.amazonaws.com"]
      secret_name = kubernetes_secret.tls.metadata[0].name
    }
    rule {
      host = "*.elb.${var.aws_region}.amazonaws.com"
      http {
        path {
          path     = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "airflow-webserver"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.nginx_ingress,kubernetes_secret.tls]
}
