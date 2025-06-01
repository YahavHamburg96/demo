locals {
  airflow_tolerations = [
    {
      key      = "dedicated"
      operator = "Equal"
      value    = "airflow"
      effect   = "NoSchedule"
    }
  ]

  airflow_node_selector = {
    "airflow" = "true"
  }

  airflow_base_values = {
    images = {
      airflow = {
        repository = format("%s.dkr.ecr.eu-west-1.amazonaws.com", var.aws_account_id)/airflow
      }
      flower = {
        repository = format("%s.dkr.ecr.eu-west-1.amazonaws.com", var.aws_account_id)/airflow
        
      }
      redis = {
        repository = format("%s.dkr.ecr.eu-west-1.amazonaws.com", var.aws_account_id)/redis
      }
      celery = {
        repository = format("%s.dkr.ecr.eu-west-1.amazonaws.com", var.aws_account_id)/airflow
      }
    }


    redis = {
      enabled      = true
      tolerations  = local.airflow_tolerations
      nodeSelector = local.airflow_node_selector
      passwordSecretName = "airflow-redis-auth"
      
      persistence = {
        storageClassName = "gp2"
      }
      
    }
    data = {
      brokerUrlSecretName = "airflow-broker-url"
    }
    postgresql = {
      enabled = false
    }

    flower = {
      enabled      = true
      tolerations  = local.airflow_tolerations
      nodeSelector = local.airflow_node_selector
    }

    workers = {
      replicas     = 2
      tolerations  = local.airflow_tolerations
      nodeSelector = local.airflow_node_selector
    }

    web = {
      port         = 8080
      tolerations  = local.airflow_tolerations
      nodeSelector = local.airflow_node_selector
    }

    scheduler = {
      tolerations  = local.airflow_tolerations
      nodeSelector = local.airflow_node_selector
    }

    createUserJob = {
      tolerations  = local.airflow_tolerations
      nodeSelector = local.airflow_node_selector
    }

    migrateDatabaseJob = {
      tolerations  = local.airflow_tolerations
      nodeSelector = local.airflow_node_selector
    }

    triggerer = {
      tolerations  = local.airflow_tolerations
      nodeSelector = local.airflow_node_selector
    }
  }

  airflow_config = {
    AIRFLOW__CORE__SQL_ALCHEMY_CONN     = "postgresql+psycopg2://user:pass@host:5432/airflow"
    AIRFLOW__CELERY__RESULT_BACKEND     = "db+postgresql://user:pass@host:5432/airflow"
    AIRFLOW__CELERY__BROKER_URL         = "redis://:redis@redis:6379/0"
  }
}
