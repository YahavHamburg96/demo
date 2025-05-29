locals {
  values = yamlencode({
    "global" = {
      imageRegistry = format("%s.dkr.ecr.eu-west-1.amazonaws.com", var.aws_account_id)
      "security" = {
        allowInsecureImages = true
      }
    }
    workers = {
      logGroomerSidecar = {
        enabled = false
      }
    }
    migrateDatabaseJob = {
      enabled = false
    }
    data = {
      metadataSecretName = "custom-airflow-metadata-secret"
    }
    images = {
      airflow = {
        repository = format("%s.dkr.ecr.eu-west-1.amazonaws.com/airflow", var.aws_account_id)
      }
      redis = {
        repository = format("%s.dkr.ecr.eu-west-1.amazonaws.com/redis", var.aws_account_id)
      }
    }
  })
}
