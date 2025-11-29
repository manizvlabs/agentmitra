
import psycopg2
import os
from datetime import datetime

def create_flags():
    try:
        conn = psycopg2.connect(
            host='host.docker.internal',
            port=5432,
            user='pioneer',
            password='pioneer123',
            database='pioneer'
        )
        
        cursor = conn.cursor()
        
        flags = [
            ('dashboard_enabled', 'Enable main dashboard access', True),
            ('login_enabled', 'Enable login functionality', True),
            ('registration_enabled', 'Enable user registration', True),
            ('otp_verification_enabled', 'Enable OTP verification', True)
        ]
        
        for title, description, is_active in flags:
            cursor.execute('''
                INSERT INTO flags (title, description, is_active, version, rollout, updated_at, created_at) 
                VALUES (%s, %s, %s, 1, 100, %s, %s)
                ON CONFLICT (title) DO NOTHING
            ''', (title, description, is_active, datetime.now(), datetime.now()))
            print(f'Created flag: {title}')
        
        conn.commit()
        print('All flags created successfully!')
        
    except Exception as e:
        print(f'Error: {e}')
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()

if __name__ == '__main__':
    create_flags()

