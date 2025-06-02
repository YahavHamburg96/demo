resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.k8s_namespace
    
  }
}

resource "kubernetes_secret" "postgres_auth" {
  metadata {
    name      = "postgresql-secret"
    namespace = var.k8s_namespace
  }

  data = {
    password = var.db_secret_value
    username = "postgres"
    host     = split(":", var.rds_endpoint)[0]
  }

  type = "Opaque"
  depends_on = [ kubernetes_namespace.namespace ]
}

resource "helm_release" "this" {
  name       = "dummy-app"
  chart      = "./helm-chart"
  create_namespace = var.helm_create_namespace
  namespace        = var.k8s_namespace
  values = [yamlencode(local.dummy_app_base_values)]

  depends_on = [ kubernetes_secret.postgres_auth ]
}


