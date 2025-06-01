

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.k8s_namespace
    
  }
}

# Redis 
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
    password = base64encode(random_password.redis_password.result)
  }

  type = "Opaque"
  depends_on = [ kubernetes_namespace.namespace ]
}

# Web Server Authentication
resource "random_password" "web_server_auth" {
  length  = 8
  special = true
}

resource "kubernetes_secret" "web_server_auth" {
  metadata {
    name      = "airflow-web-auth"
    namespace = var.k8s_namespace
  }

  data = {
    password = random_password.web_server_auth.result
  }

  type = "Opaque"
  depends_on = [ kubernetes_namespace.namespace ]
}

# Postgres
resource "random_password" "postgres_auth" {
  length  = 8
  special = false
}

resource "kubernetes_secret" "postgres_auth" {
  metadata {
    name      = "airflow-postgresql-secret"
    namespace = var.k8s_namespace
  }

  data = {
    password = random_password.postgres_auth.result
    username = "postgresql"
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
    connection = base64encode("redis://:$(REDIS_PASSWORD)@redis:6379/0")  # template
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
    connection = "postgresql+psycopg2://postgresql:${random_password.postgres_auth.result}@airflow-postgresql.airflow.svc.cluster.local/postgres"
  }

  type = "Opaque"
  depends_on = [ kubernetes_namespace.namespace ]
}



resource "helm_release" "airflow" {
  name             = "airflow"
  version          = var.helm_chart_version
  chart            = "airflow"
  repository       = "https://airflow.apache.org"
  create_namespace = var.helm_create_namespace
  namespace        = var.k8s_namespace
  timeout          = 180
  values = [yamlencode(local.airflow_base_values)]

  set {
    name  = "airflow.config"
    value = jsonencode(local.airflow_config)
  }

  depends_on = [
    kubernetes_secret.airflow_metadata_db
  ]
}