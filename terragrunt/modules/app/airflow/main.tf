

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.k8s_namespace
    
  }
}

resource "random_password" "redis_password" {
  length  = 16
  special = true
}

resource "kubernetes_secret" "redis_auth" {
  metadata {
    name      = "airflow-redis-auth"
    namespace = var.k8s_namespace
  }

  data = {
    redis-password = base64encode(random_password.redis_password.result)
  }

  type = "Opaque"
  depends_on = [ kubernetes_namespace.namespace ]
}

resource "kubernetes_secret" "broker_url" {
  metadata {
    name      = "airflow-broker-url"
    namespace = var.k8s_namespace
  }

  data = {
    broker-url = base64encode("redis://:$(REDIS_PASSWORD)@redis:6379/0")  # template
  }

  type = "Opaque"
  depends_on = [ kubernetes_namespace.namespace ]
}

resource "kubernetes_secret" "airflow_metadata_db" {
  metadata {
    name = "custom-airflow-metadata-secret"
    namespace = var.k8s_namespace
  }

  data = {
    # base64-encoded connection string
    connection = base64encode("postgresql+psycopg2://postgres:${var.db_secret_value}@${var.rds_endpoint}/airflow_db")
  }

  type = "Opaque"
  depends_on = [ kubernetes_namespace.namespace ]
}



resource "helm_release" "airflow" {
  name       = "airflow"
  version    = var.helm_chart_version
  chart      = "airflow"
  repository = "https://airflow.apache.org"
  create_namespace = var.helm_create_namespace
  namespace        = var.k8s_namespace

  values = [yamlencode(local.airflow_base_values)]

  set {
    name  = "airflow.config"
    value = jsonencode(local.airflow_config)
  }

  depends_on = [
    kubernetes_secret.airflow_metadata_db
  ]
}