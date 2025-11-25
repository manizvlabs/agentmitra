-- Agent Mitra - Migration V27: Add Tenant Management Permissions
-- This migration adds tenant management permissions to the authorization system

-- =====================================================
-- ADD TENANT MANAGEMENT PERMISSIONS
-- =====================================================

INSERT INTO lic_schema.permissions (permission_name, permission_description, resource_type, action)
VALUES
    ('tenants.create', 'Create new tenants', 'tenant', 'create'),
    ('tenants.read', 'Read tenant information', 'tenant', 'read'),
    ('tenants.update', 'Update tenant settings', 'tenant', 'update'),
    ('tenants.delete', 'Delete tenants', 'tenant', 'delete'),
    ('tenants.list', 'List all tenants', 'tenant', 'list'),
    ('tenants.manage_users', 'Manage tenant users', 'tenant', 'manage_users'),
    ('tenants.manage_config', 'Manage tenant configuration', 'tenant', 'manage_config')
ON CONFLICT (permission_name) DO NOTHING;

-- =====================================================
-- ASSIGN TENANT PERMISSIONS TO SUPER_ADMIN
-- =====================================================

INSERT INTO lic_schema.role_permissions (role_id, permission_id, granted_at)
SELECT
    r.role_id,
    p.permission_id,
    NOW()
FROM lic_schema.roles r
CROSS JOIN lic_schema.permissions p
WHERE r.role_name = 'super_admin'
  AND p.permission_name LIKE 'tenants.%'
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- =====================================================
-- ADD ADDITIONAL SYSTEM PERMISSIONS
-- =====================================================

INSERT INTO lic_schema.permissions (permission_name, permission_description, resource_type, action)
VALUES
    ('system.admin', 'Full system administration', 'system', 'admin'),
    ('system.config', 'System configuration management', 'system', 'config'),
    ('audit.read', 'Read audit logs', 'audit', 'read'),
    ('audit.export', 'Export audit data', 'audit', 'export'),
    ('reports.admin', 'Administrative reporting', 'report', 'admin'),
    ('compliance.admin', 'Compliance administration', 'compliance', 'admin')
ON CONFLICT (permission_name) DO NOTHING;

-- Assign system permissions to super_admin
INSERT INTO lic_schema.role_permissions (role_id, permission_id, granted_at)
SELECT
    r.role_id,
    p.permission_id,
    NOW()
FROM lic_schema.roles r
CROSS JOIN lic_schema.permissions p
WHERE r.role_name = 'super_admin'
  AND p.permission_name LIKE 'system.%'
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- Assign audit permissions to super_admin and compliance_officer
INSERT INTO lic_schema.role_permissions (role_id, permission_id, granted_at)
SELECT
    r.role_id,
    p.permission_id,
    NOW()
FROM lic_schema.roles r
CROSS JOIN lic_schema.permissions p
WHERE r.role_name IN ('super_admin', 'compliance_officer')
  AND p.permission_name LIKE 'audit.%'
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- =====================================================
-- UPDATE EXISTING ROLE PERMISSIONS
-- =====================================================

-- Ensure provider_admin has proper permissions
INSERT INTO lic_schema.role_permissions (role_id, permission_id, granted_at)
SELECT
    r.role_id,
    p.permission_id,
    NOW()
FROM lic_schema.roles r
CROSS JOIN lic_schema.permissions p
WHERE r.role_name = 'insurance_provider_admin'
  AND p.permission_name IN (
    'users.read', 'users.update', 'agents.*', 'policies.*', 'reports.read'
  )
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- Ensure regional_manager has proper permissions
INSERT INTO lic_schema.role_permissions (role_id, permission_id, granted_at)
SELECT
    r.role_id,
    p.permission_id,
    NOW()
FROM lic_schema.roles r
CROSS JOIN lic_schema.permissions p
WHERE r.role_name = 'regional_manager'
  AND p.permission_name IN (
    'agents.read', 'agents.update', 'policies.read', 'policies.update', 'reports.read'
  )
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================

-- Add comment to migration
COMMENT ON DATABASE agentmitra IS 'Agent Mitra - Database-driven authorization with tenant management permissions';
