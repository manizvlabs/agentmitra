-- Agent Mitra - Migration V1: Create Shared Schemas
-- This migration creates the core schemas for multi-tenant architecture

-- Enable required PostgreSQL extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For text search

-- Create schemas for multi-tenant architecture
CREATE SCHEMA IF NOT EXISTS shared;
CREATE SCHEMA IF NOT EXISTS lic_schema;
CREATE SCHEMA IF NOT EXISTS audit;

-- Grant permissions to agentmitra user
GRANT USAGE ON SCHEMA shared TO agentmitra;
GRANT USAGE ON SCHEMA lic_schema TO agentmitra;
GRANT USAGE ON SCHEMA audit TO agentmitra;

GRANT CREATE ON SCHEMA shared TO agentmitra;
GRANT CREATE ON SCHEMA lic_schema TO agentmitra;
GRANT CREATE ON SCHEMA audit TO agentmitra;

-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA shared GRANT ALL ON TABLES TO agentmitra;
ALTER DEFAULT PRIVILEGES IN SCHEMA lic_schema GRANT ALL ON TABLES TO agentmitra;
ALTER DEFAULT PRIVILEGES IN SCHEMA audit GRANT ALL ON TABLES TO agentmitra;

-- Comment on schemas
COMMENT ON SCHEMA shared IS 'Shared reference data and multi-tenant infrastructure';
COMMENT ON SCHEMA lic_schema IS 'LIC tenant-specific data and business entities';
COMMENT ON SCHEMA audit IS 'Audit logs and compliance tracking';

