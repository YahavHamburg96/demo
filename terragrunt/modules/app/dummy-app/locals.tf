locals {
  image_registry = format("%s.dkr.ecr.eu-west-1.amazonaws.com", var.aws_account_id)

  dummy_app_base_values = {
    image = {
      repository = "${local.image_registry}/dummy-app"
      tag        = "latest"
    }
    database = {
      secretName = "postgresql-secret"
    }

  }

}