from app.core.database import engine
from sqlalchemy import text

with engine.connect() as conn:
    result = conn.execute(text("SELECT user_id, phone_number, first_name, last_name, role, password_hash FROM lic_schema.users WHERE phone_number = '+919876543201'"))
    user = result.fetchone()
    if user:
        print(f"User ID: {user[0]}")
        print(f"Phone: {user[1]}")
        print(f"Name: {user[2]} {user[3]}")
        print(f"Role: {user[4]}")
        print(f"Password Hash: {user[5][:50]}...")
    else:
        print("User not found")
        
    # Also check all users with similar phone numbers
    print("\nAll users with phone starting with +919876543:")
    result = conn.execute(text("SELECT phone_number, first_name, last_name, role FROM lic_schema.users WHERE phone_number LIKE '+919876543%' ORDER BY phone_number"))
    for row in result.fetchall():
        print(f"  {row[0]}: {row[1]} {row[2]} ({row[3]})")
