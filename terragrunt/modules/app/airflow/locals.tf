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
        repository = "${var.aws_account_id}.dkr.ecr.eu-west-1.amazonaws.com/airflow"
      }
      flower = {
        repository = "${var.aws_account_id}.dkr.ecr.eu-west-1.amazonaws.com/airflow"
        
      }
      redis = {
        repository = "${var.aws_account_id}.dkr.ecr.eu-west-1.amazonaws.com/redis"
      }
      statsd = {
        repository = "${var.aws_account_id}.dkr.ecr.eu-west-1.amazonaws.com/prometheus/statsd-exporter"
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
    logs = {
      persistence = {
        storageClassName = "gp2"
      }
    }
    data = {
      brokerUrlSecretName = "airflow-broker-url"
      metadataSecretName  = "custom-airflow-metadata-secret"

    }
    postgresql = {
      enabled = true
      imaage = {
        repository = "${var.aws_account_id}.dkr.ecr.eu-west-1.amazonaws.com/postgresql"
      }
      global = {
        storageClass = "gp2"
        postgresql = {
          auth = {
            database = "postgres"
            existingSecret = "airflow-postgresql-secret"
            secretKeys = {
              adminPasswordKey = "password"
              userPasswordKey = "username"
              replicationPasswordKey = "password"
            }
          }
        }
      }
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
      persistence = {
        storageClassName = "gp2"
        size = "20Gi"
      }
      waitForMigrations = {
        enabled = false
      }
    }

    webserver = {
      tolerations  = local.airflow_tolerations
      nodeSelector = local.airflow_node_selector
      defaultUser = {
        password = "${random_password.web_server_auth.result}"
      }
      waitForMigrations = {
        enabled = false
      }
    }

    scheduler = {
      tolerations  = local.airflow_tolerations
      nodeSelector = local.airflow_node_selector
      waitForMigrations = {
        enabled = false
      }
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
      waitForMigrations = {
        enabled = false
      }
      persistence = {
        storageClassName = "gp2"
        size = "20Gi"
      }
    }
  }

  airflow_config = {
    AIRFLOW__CORE__SQL_ALCHEMY_CONN     = "postgresql+psycopg2://postgresql:${random_password.postgres_auth.result}@airflow-postgresql:5432/airflow"
    AIRFLOW__CELERY__RESULT_BACKEND     = "db+postgresql://postgresql:${random_password.postgres_auth.result}@airflow-postgresql/airflow"
    AIRFLOW__CELERY__BROKER_URL         = "redis://:${random_password.redis_password.result}@airflow-redis:6379/0"
  }
}
