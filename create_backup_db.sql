-- SQL commands to create backup database and required roles
-- Run these in Cloud SQL PostgreSQL console or via psql

-- Create the backup database
CREATE DATABASE agentmitra_dev_backup 
    WITH OWNER = manish 
    ENCODING = 'UTF8' 
    LC_COLLATE = 'en_US.UTF-8' 
    LC_CTYPE = 'en_US.UTF-8' 
    TEMPLATE = template0;

-- Connect to the backup database and create required roles
\c agentmitra_dev_backup;

-- Create agentmitra role with proper permissions
CREATE ROLE agentmitra LOGIN PASSWORD 'agentmitra_secure_password_2025!';
GRANT CONNECT ON DATABASE agentmitra_dev_backup TO agentmitra;
GRANT ALL PRIVILEGES ON DATABASE agentmitra_dev_backup TO agentmitra;
GRANT ALL ON SCHEMA public TO agentmitra;

-- Grant superuser-like permissions for schema operations
ALTER ROLE agentmitra CREATEROLE;
ALTER ROLE agentmitra CREATEDB;

-- Create any other roles that might be needed
-- (Add additional roles here if migrations require them)
