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
      metadataSecretName = "custom-dummy-app-metadata-secret"
    }
    images = {
      dummy-app = {
        repository = format("%s.dkr.ecr.eu-west-1.amazonaws.com/dummy-app", var.aws_account_id)
      }
      redis = {
        repository = format("%s.dkr.ecr.eu-west-1.amazonaws.com/redis", var.aws_account_id)
      }
    }
  })
}
