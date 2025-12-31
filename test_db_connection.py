import psycopg2
import sys

# Database connection parameters
DB_CONFIG = {
    'host': '35.228.130.213',
    'port': 5432,
    'database': 'agentmitra_dev',
    'user': 'manish',
    'password': 'uuq>9M"hp}t.ZQ@A'
}

def test_connection():
    try:
        print("Attempting to connect to Cloud SQL database...")
        print(f"Host: {DB_CONFIG['host']}")
        print(f"Port: {DB_CONFIG['port']}")
        print(f"Database: {DB_CONFIG['database']}")
        print(f"User: {DB_CONFIG['user']}")

        # Connect to the database
        conn = psycopg2.connect(**DB_CONFIG)

        # Create a cursor
        cursor = conn.cursor()

        # Execute a simple query
        cursor.execute("SELECT version();")

        # Fetch the result
        version = cursor.fetchone()

        print("SUCCESS: Connection successful!")
        print(f"PostgreSQL Version: {version[0]}")

        # Close the cursor and connection
        cursor.close()
        conn.close()

        return True

    except psycopg2.OperationalError as e:
        print(f"FAILED: Connection failed - Operational Error: {e}")
        return False
    except psycopg2.Error as e:
        print(f"FAILED: Connection failed - Database Error: {e}")
        return False
    except Exception as e:
        print(f"FAILED: Connection failed - Unexpected Error: {e}")
        return False

if __name__ == "__main__":
    success = test_connection()
    sys.exit(0 if success else 1)
