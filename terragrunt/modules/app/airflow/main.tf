resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.k8s_namespace
    
  }
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

# Create a local values.yaml file
resource "local_file" "helm_values" {
  content  = data.utils_deep_merge_yaml.values[0].output
  filename = "${path.module}/generated-values.yaml"
}

resource "null_resource" "helm_deploy" {
  triggers = {
    values_content = data.utils_deep_merge_yaml.values[0].output
    chart_path    = "../../../charts/airflow"
    namespace     = var.k8s_namespace
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Install helm chart using the generated values file
      helm upgrade --install airflow \
        ${self.triggers.chart_path} \
        --namespace ${self.triggers.namespace} ${var.helm_create_namespace ? "--create-namespace" : ""} \
        --values ${local_file.helm_values.filename} \
        --debug
    EOT
  }
  depends_on = [
    kubernetes_secret.airflow_metadata_db,
    local_file.helm_values
  ]
}