

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
    password = random_password.redis_password.result
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
    username = "postgres"
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
    connection = "redis://:${random_password.redis_password.result}@airflow-redis:6379/0"
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
    connection = "postgresql+psycopg2://postgres:${random_password.postgres_auth.result}@airflow-postgresql/postgres"
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
  wait             = false
  cleanup_on_fail  = true
  values = [yamlencode(local.airflow_base_values)]

  set {
    name  = "airflow.config"
    value = jsonencode(local.airflow_config)
  }

  depends_on = [
    kubernetes_secret.airflow_metadata_db
  ]
  force_update = true
}


resource "kubernetes_config_map" "airflow_dags" {
  metadata {
    name      = "airflow-dag-dummy-app-api"
    namespace = var.k8s_namespace
  }

  data = {
    "dummy_app_api.py" = <<-EOT
      from airflow import DAG
      from airflow.providers.http.operators.http import HttpOperator  # Fixed import
      from airflow.utils.dates import days_ago
      
      with DAG(
          dag_id="trigger_generate_data",
          start_date=days_ago(1),
          schedule_interval=None,
          catchup=False,
      ) as dag:
      
          trigger_generate_data = HttpOperator(  # Fixed class name
              task_id="call_generate_data",
              http_conn_id="dummy_app_api",
              endpoint="generate-data?count=10",
              method="GET",
              log_response=True,
          )
    EOT
  }

  depends_on = [
    helm_release.airflow
  ]
}

resource "kubernetes_job" "create_airflow_connection" {
  metadata {
    name      = "create-airflow-connection"
    namespace = var.k8s_namespace
  }

  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "create-connection"
          image   = "${local.image_registry}/airflow:2.10.5"  # Use the same version as your Airflow deployment
          command = ["/bin/bash", "-c"]
          args    = [
            <<-EOT
              airflow connections add dummy_app_api \
                --conn-type http \
                --conn-host http://dummy-app.dummy-app.svc:5000
            EOT
          ]
          env {
            name  = "AIRFLOW__CORE__SQL_ALCHEMY_CONN"
            value = "postgresql+psycopg2://postgres:${random_password.postgres_auth.result}@airflow-postgresql:5432/postgres"
          }
        }
        restart_policy = "OnFailure"
      }
    }
    backoff_limit = 3
  }

  depends_on = [
    helm_release.airflow, kubernetes_config_map.airflow_dags
  ]
}