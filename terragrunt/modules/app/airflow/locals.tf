locals {
  image_registry = format("%s.dkr.ecr.eu-west-1.amazonaws.com", var.aws_account_id)

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
        repository = "${local.image_registry}/airflow"
      }
      flower = {
        repository = "${local.image_registry}/airflow"
        
      }
      redis = {
        repository = "${local.image_registry}/redis"
      }
      statsd = {
        repository = "${local.image_registry}/prometheus/statsd-exporter"
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
    dags = {
      persistence = {
        enabled = false
      }

    }
    
    postgresql = {
      enabled = true
      primary = {
        tolerations  = local.airflow_tolerations
        nodeSelector = local.airflow_node_selector
      }
      image = {
        repository = "postgresql"
      }
      global = {
        imageRegistry = "${local.image_registry}"
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
      extraVolumes = [
        {
          name = "dag-cm"
          configMap = {
            name = "airflow-dags-cm"
          }
        }
      ]
      extraVolumeMounts = [
        {
          name      = "dag-cm"
          mountPath = "/opt/airflow/dags/dummy_app_api.py"
          subPath   = "dummy_app_api.py"
          readOnly  = true
        }
      ]
    }

    workers = {
      replicas     = 2
      tolerations  = local.airflow_tolerations
      nodeSelector = local.airflow_node_selector
      persistence = {
        storageClassName = "gp2"
        size = "20Gi"
      }
      extraVolumes = [
        {
          name = "dag-cm"
          configMap = {
            name = "airflow-dags-cm"
          }
        }
      ]
      extraVolumeMounts = [
        {
          name      = "dag-cm"
          mountPath = "/opt/airflow/dags/dummy_app_api.py"
          subPath   = "dummy_app_api.py"
          readOnly  = true
        }
      ]
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
      extraVolumes = [
        {
          name = "dag-cm"
          configMap = {
            name = "airflow-dags-cm"
          }
        }
      ]
      extraVolumeMounts = [
        {
          name      = "dag-cm"
          mountPath = "/opt/airflow/dags/dummy_app_api.py"
          subPath   = "dummy_app_api.py"
          readOnly  = true
        }
      ]
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
      extraVolumes = [
        {
          name = "dag-cm"
          configMap = {
            name = "airflow-dags-cm"
          }
        }
      ]
      extraVolumeMounts = [
        {
          name      = "dag-cm"
          mountPath = "/opt/airflow/dags/dummy_app_api.py"
          subPath   = "dummy_app_api.py"
          readOnly  = true
        }
      ]
    }

    triggerer = {
      tolerations  = local.airflow_tolerations
      nodeSelector = local.airflow_node_selector
      waitForMigrations = {
        enabled = false
      }
      extraVolumes = [
        {
          name = "dag-cm"
          configMap = {
            name = "airflow-dags-cm"
          }
        }
      ]
      extraVolumeMounts = [
        {
          name      = "dag-cm"
          mountPath = "/opt/airflow/dags/dummy_app_api.py"
          subPath   = "dummy_app_api.py"
          readOnly  = true
        }
      ]
      persistence = {
        storageClassName = "gp2"
        size = "20Gi"
      }
    }
    extraConfigMaps = {
      airflow-dags-cm = {
        labels = {
          "app.kubernetes.io/name" = "airflow-dags-cm"
        }
        data = <<-EOT
          dummy_app_api.py: |
            from airflow import DAG
            from airflow.providers.http.operators.http import HttpOperator
            from airflow.utils.dates import days_ago

            default_args = {
              'owner': 'airflow',
              'start_date': days_ago(1),
            }

            with DAG('dummy_app_api', default_args=default_args, schedule_interval="*/20 * * * *") as dag:
              task1 = HttpOperator(
                task_id='call_dummy_app_api',
                http_conn_id='dummy_app_api',
                endpoint='generate-data?count=10',
                method='GET',
                headers={"Content-Type": "application/json"},
              )
        EOT
      }
    }
  }

  airflow_config = {
    AIRFLOW__CORE__SQL_ALCHEMY_CONN     = "postgresql+psycopg2://postgres:${random_password.postgres_auth.result}@airflow-postgresql:5432/postgres"
    AIRFLOW__CELERY__RESULT_BACKEND     = "db+postgresql://postgres:${random_password.postgres_auth.result}@airflow-postgresql/postgres"
    #AIRFLOW__CELERY__BROKER_URL         = "redis://:%24{random_password.redis_password.result}@airflow-redis:6379/0"
  }
}
