resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.k8s_namespace
    
  }
}

# resource "kubernetes_secret" "dummy-app_metadata_db" {
#   metadata {
#     name = "custom-dummy-app-metadata-secret"
#     namespace = var.k8s_namespace
#   }

#   data = {
#     # base64-encoded connection string
#     connection = base64encode("postgresql+psycopg2://postgres:${var.db_secret_value}@${var.rds_endpoint}/dummy-app_db")
#   }

#   type = "Opaque"
#   depends_on = [ kubernetes_namespace.namespace ]
# }

resource "helm_release" "this" {
  name       = "dummy-app"
  chart      = "../../../charts/dummy-app"
  create_namespace = var.helm_create_namespace
  namespace        = var.k8s_namespace
  values = [
    
   data.utils_deep_merge_yaml.values[0].output
  ]
  #depends_on = [ kubernetes_secret.dummy-app_metadata_db ]
}