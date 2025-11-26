-- Agent Mitra - Migration V34: Fix Permissions Table Column Names
-- Fix mismatch between database schema and ORM model for permissions table

-- Rename resource_type column to resource to match the Permission model
ALTER TABLE lic_schema.permissions
RENAME COLUMN resource_type TO resource;

-- Add the is_system_permission column if it doesn't exist
ALTER TABLE lic_schema.permissions
ADD COLUMN IF NOT EXISTS is_system_permission BOOLEAN DEFAULT false;

-- Add updated_at column if it doesn't exist
ALTER TABLE lic_schema.permissions
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();

-- Update existing permissions to mark them as system permissions
UPDATE lic_schema.permissions SET is_system_permission = true WHERE is_system_permission IS NULL;

-- Add comment
COMMENT ON TABLE lic_schema.permissions IS 'RBAC permissions table with resource and action columns matching ORM model';
