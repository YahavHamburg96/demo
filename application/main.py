from flask import Flask, jsonify, request
from faker import Faker
import random
import psycopg2
from psycopg2.extras import execute_values
import os
from psycopg2 import sql

app = Flask(__name__)
fake = Faker()

# Read PostgreSQL connection settings from environment variables (no defaults)
DB_HOST = os.getenv('DB_HOST')
DB_PORT = os.getenv('DB_PORT')
DB_NAME = os.getenv('DB_NAME')
DB_USER = os.getenv('DB_USER')
DB_PASS = os.getenv('DB_PASS')

if not all([DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASS]):
    raise ValueError("Missing required environment variables for database connection.")

def ensure_database_exists():
    # Connect to the default 'postgres' database to check if DB exists
    conn = psycopg2.connect(
        host=DB_HOST, port=DB_PORT, dbname='postgres', user=DB_USER, password=DB_PASS
    )
    conn.autocommit = True
    cur = conn.cursor()
    # Check if the database exists
    cur.execute("SELECT 1 FROM pg_database WHERE datname = %s;", (DB_NAME,))
    exists = cur.fetchone()
    if not exists:
        cur.execute(sql.SQL("CREATE DATABASE {}").format(sql.Identifier(DB_NAME)))
        print(f"Database '{DB_NAME}' created.")
    else:
        print(f"Database '{DB_NAME}' already exists.")
    cur.close()
    conn.close()

def insert_into_postgres(records):
    conn = psycopg2.connect(
        host=DB_HOST, port=DB_PORT, dbname=DB_NAME, user=DB_USER, password=DB_PASS
    )
    cur = conn.cursor()
    sql_query = """
        INSERT INTO dummy_data (id, name, email, address, amount, timestamp)
        VALUES %s
    """
    values = [(r['id'], r['name'], r['email'], r['address'], r['amount'], r['timestamp']) for r in records]
    execute_values(cur, sql_query, values)
    conn.commit()
    cur.close()
    conn.close()

@app.route('/generate-data', methods=['GET'])
def generate_data():
    count = int(request.args.get('count', 10))  # Default 10 records
    data = []
    for _ in range(count):
        record = {
            'id': fake.uuid4(),
            'name': fake.name(),
            'email': fake.email(),
            'address': fake.address(),
            'amount': round(random.uniform(10.0, 1000.0), 2),
            'timestamp': fake.iso8601()
        }
        data.append(record)
    insert_into_postgres(data)
    return jsonify({'status': 'success', 'records_inserted': len(data)})

if __name__ == '__main__':
    ensure_database_exists()
    app.run(port=5000, debug=True)
