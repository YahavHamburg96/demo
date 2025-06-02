from airflow import DAG
from airflow.providers.http.operators.http import HttpOperator  # Fixed import
from airflow.utils.dates import days_ago

with DAG(
    dag_id="trigger_generate_data",
    start_date=days_ago(1),
    schedule_interval=None,
    catchup=False,
) as dag:

    trigger_generate_data = HttpOperator(  # Fixed class name
        task_id="call_generate_data",
        http_conn_id="dummy_app_api",
        endpoint="generate-data?count=10",
        method="GET",
        log_response=True,
    )