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
  db_secret_value          = dependency.rds.outputs.db_secret_value
  rds_endpoint             = dependency.rds.outputs.rds_endpoint
 
  
}


dependency "eks" {
  config_path  = "../../infra/eks"
  skip_outputs = false
  mock_outputs = {
    cluster_name = "dummy"
  }
}

dependency "rds" {
  config_path  = "../../infra/rds"
  skip_outputs = false
  mock_outputs = {
    db_secret_value = "dummy"
    rds_endpoint    = "dummy"
  }
}

dependencies {
  paths = ["../../infra/eks","../../infra/rds"]
}