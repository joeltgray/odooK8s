import psycopg2
import time

while True:
    try:
        conn = psycopg2.connect(
            host="postgres-service",
            port=5432,
            user="odoo",
            password="odoo",
            database="odoo"
        )
        print("Successfully connected to PostgreSQL")
        conn.close()
    except Exception as e:
        print("Connection to PostgreSQL failed:", e)

    time.sleep(5)
