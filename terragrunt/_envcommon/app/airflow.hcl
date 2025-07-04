terraform {
  source = "${dirname(find_in_parent_folders())}//modules/app/airflow"
}

locals {
  # Automatically load environment-level variables
  environment_vars        = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  project                  = local.environment_vars.locals.project_name
  cluster_name             = dependency.eks.outputs.cluster_name
  aws_account_id           = local.environment_vars.locals.aws_account_id

}



dependency "eks" {
  config_path  = "../../infra/eks"
  skip_outputs = false
  mock_outputs = {
    cluster_name = "dummy"
    security_group_alb = "dummy"
  }
}

dependencies {
  paths = ["../../infra/eks"]
}