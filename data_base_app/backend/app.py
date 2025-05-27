from flask import jsonify
import logging
from flask import Flask, request
from flask_cors import CORS
import psycopg2
import os

logging.basicConfig(level=logging.INFO)

app = Flask(__name__)
CORS(app)

# Ensure table is created at startup
try:
    logging.info("Ensuring 'users' table exists...")
    conn = psycopg2.connect(
        host=os.getenv("DB_HOST"),
        user="postgres",
        password=os.getenv("DB_PASSWORD"),
        database="postgres",
        port=5432
    )
    cur = conn.cursor()
    cur.execute("""
    CREATE TABLE IF NOT EXISTS users (
        name TEXT,
        email TEXT
    )
    """)
    conn.commit()
    cur.close()
    conn.close()
    logging.info("'users' table ready.")
except Exception as e:
    logging.error("Error ensuring users table exists")
    logging.error(e)

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    try:
        logging.info(f"Connecting to DB at host: {os.getenv('DB_HOST')}")
        conn = psycopg2.connect(
            host=os.getenv("DB_HOST"),
            user="postgres",
            password=os.getenv("DB_PASSWORD"),
            database="postgres",
            port=5432
        )
        cur = conn.cursor()
        cur.execute("INSERT INTO users (name, email) VALUES (%s, %s)", (data['name'], data['email']))
        conn.commit()
        cur.close()
        conn.close()
        return {"status": "success"}
    except Exception as e:
        logging.error("Error connecting to DB or inserting data")
        logging.error(e)
        return {"status": "error", "message": str(e)}, 500

@app.route('/')
def home():
    logging.info("Health check endpoint hit.")
    return "Flask App is Running"

@app.route('/users', methods=['GET'])
def get_users():
    try:
        logging.info(f"Fetching all users from DB at host: {os.getenv('DB_HOST')}")
        conn = psycopg2.connect(
            host=os.getenv("DB_HOST"),
            user="postgres",
            password=os.getenv("DB_PASSWORD"),
            database="postgres",
            port=5432
        )
        cur = conn.cursor()
        cur.execute("SELECT name, email FROM users")
        rows = cur.fetchall()
        cur.close()
        conn.close()
        users = [{"name": row[0], "email": row[1]} for row in rows]
        return jsonify(users)
    except Exception as e:
        logging.error("Error retrieving users from DB")
        logging.error(e)
        return {"status": "error", "message": str(e)}, 500

if __name__ == '__main__':
    logging.info("Starting Flask App on port 3000")
    app.run(host='0.0.0.0', port=3000)
