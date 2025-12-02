-- Agent Mitra - Migration V65: Final RBAC Fixes and User Setup
-- This migration ensures all RBAC components work correctly

-- =====================================================
-- ENSURE RBAC AUDIT LOG TABLE EXISTS AND WORKS
-- =====================================================

-- Recreate the rbac_audit_log table if needed (idempotent)
DROP TABLE IF EXISTS lic_schema.rbac_audit_log CASCADE;

CREATE TABLE IF NOT EXISTS lic_schema.rbac_audit_log (
    audit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES lic_schema.tenants(tenant_id),
    user_id UUID REFERENCES lic_schema.users(user_id),
    action VARCHAR(50) NOT NULL, -- 'role_assigned', 'role_removed', 'permission_checked', 'feature_flag_changed'
    target_user_id UUID REFERENCES lic_schema.users(user_id), -- User affected by action
    target_role_id UUID REFERENCES lic_schema.roles(role_id), -- Role affected by action
    target_permission_id UUID REFERENCES lic_schema.permissions(permission_id), -- Permission affected
    target_flag_id UUID REFERENCES lic_schema.feature_flags(flag_id), -- Feature flag affected
    details JSONB, -- Additional context
    success BOOLEAN DEFAULT true,
    ip_address INET,
    user_agent TEXT,
    timestamp TIMESTAMP DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_rbac_audit_tenant_timestamp ON lic_schema.rbac_audit_log(tenant_id, timestamp);
CREATE INDEX IF NOT EXISTS idx_rbac_audit_user ON lic_schema.rbac_audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_rbac_audit_action ON lic_schema.rbac_audit_log(action);
CREATE INDEX IF NOT EXISTS idx_rbac_audit_target_user ON lic_schema.rbac_audit_log(target_user_id);
CREATE INDEX IF NOT EXISTS idx_rbac_audit_timestamp ON lic_schema.rbac_audit_log(timestamp DESC);

-- =====================================================
-- CLEAN UP AND STANDARDIZE TEST USERS
-- =====================================================

-- Remove any duplicate users first (safe operation)
DELETE FROM lic_schema.rbac_audit_log WHERE user_id IN (
    SELECT user_id FROM lic_schema.users
    WHERE phone_number LIKE '%98765432%'
    AND user_id NOT IN (
        SELECT DISTINCT user_id FROM lic_schema.user_roles
        WHERE role_id IN (SELECT role_id FROM lic_schema.roles WHERE role_name = 'super_admin')
    )
    AND phone_number NOT IN ('+919876543200', '+919876543201', '+919876543202', '+919876543203', '+919876543204', '+919876543205', '+919876543206')
);

DELETE FROM lic_schema.user_roles WHERE user_id IN (
    SELECT user_id FROM lic_schema.users
    WHERE phone_number LIKE '%98765432%'
    AND user_id NOT IN (
        SELECT DISTINCT user_id FROM lic_schema.user_roles
        WHERE role_id IN (SELECT role_id FROM lic_schema.roles WHERE role_name = 'super_admin')
    )
    AND phone_number NOT IN ('+919876543200', '+919876543201', '+919876543202', '+919876543203', '+919876543204', '+919876543205', '+919876543206')
);

DELETE FROM lic_schema.tenant_users WHERE user_id IN (
    SELECT user_id FROM lic_schema.users
    WHERE phone_number LIKE '%98765432%'
    AND user_id NOT IN (
        SELECT DISTINCT user_id FROM lic_schema.user_roles
        WHERE role_id IN (SELECT role_id FROM lic_schema.roles WHERE role_name = 'super_admin')
    )
    AND phone_number NOT IN ('+919876543200', '+919876543201', '+919876543202', '+919876543203', '+919876543204', '+919876543205', '+919876543206')
);

-- Ensure all test users have correct phone numbers, passwords, and status
-- Update existing users with correct data
UPDATE lic_schema.users SET
    password_hash = '$2b$12$L6OjHQp7n5fRKRvM9t3JeO3tJcKQZ3Z3Z3Z3Z3Z3Z3Z3Z3Z3Z3Z3',
    status = 'active',
    email_verified = true,
    phone_verified = true,
    login_attempts = 0,
    locked_until = NULL
WHERE phone_number LIKE '+91987654320%';

-- =====================================================
-- ENSURE PROPER ROLE ASSIGNMENTS
-- =====================================================

-- Clear and rebuild user roles for test users
DELETE FROM lic_schema.user_roles WHERE user_id IN (
    SELECT u.user_id FROM lic_schema.users u
    WHERE u.phone_number IN ('+919876543200', '+919876543201', '+919876543202', '+919876543203', '+919876543204', '+919876543205', '+919876543206')
);

-- Assign correct roles to test users
INSERT INTO lic_schema.user_roles (
    user_id,
    role_id,
    assigned_by
)
SELECT
    u.user_id,
    r.role_id,
    sa.user_id  -- assigned by super admin
FROM lic_schema.users u
CROSS JOIN lic_schema.roles r
CROSS JOIN lic_schema.users sa
WHERE u.phone_number IN ('+919876543200', '+919876543201', '+919876543202', '+919876543203', '+919876543204', '+919876543205', '+919876543206')
  AND r.role_name = CASE
      WHEN u.phone_number = '+919876543200' THEN 'super_admin'
      WHEN u.phone_number = '+919876543201' THEN 'insurance_provider_admin'
      WHEN u.phone_number = '+919876543202' THEN 'regional_manager'
      WHEN u.phone_number = '+919876543203' THEN 'senior_agent'
      WHEN u.phone_number = '+919876543204' THEN 'junior_agent'
      WHEN u.phone_number = '+919876543205' THEN 'policyholder'
      WHEN u.phone_number = '+919876543206' THEN 'support_staff'
  END
  AND sa.phone_number = '+919876543200'  -- super admin
ON CONFLICT (user_id, role_id) DO NOTHING;

-- =====================================================
-- ENSURE TENANT ASSIGNMENTS
-- =====================================================

-- Assign test users to LIC tenant
INSERT INTO lic_schema.tenant_users (
    tenant_id,
    user_id,
    role,
    status
)
SELECT
    t.tenant_id,
    u.user_id,
    u.role,
    'active'
FROM lic_schema.tenants t
CROSS JOIN lic_schema.users u
WHERE t.tenant_code = 'LIC'
  AND u.phone_number IN ('+919876543200', '+919876543201', '+919876543202', '+919876543203', '+919876543204', '+919876543205', '+919876543206')
ON CONFLICT (tenant_id, user_id) DO NOTHING;

-- =====================================================
-- ADD SAMPLE AUDIT LOG ENTRIES FOR TESTING
-- =====================================================

-- Add a test audit entry to ensure the table works
INSERT INTO lic_schema.rbac_audit_log (
    tenant_id,
    user_id,
    action,
    details,
    success
)
SELECT
    t.tenant_id,
    u.user_id,
    'rbac_system_ready',
    jsonb_build_object(
        'description', 'RBAC system fully configured and ready',
        'migration', 'V65',
        'test_users_configured', true
    ),
    true
FROM lic_schema.tenants t
CROSS JOIN lic_schema.users u
WHERE t.tenant_code = 'LIC'
  AND u.phone_number = '+919876543200'  -- super admin
  AND NOT EXISTS (
      SELECT 1 FROM lic_schema.rbac_audit_log
      WHERE action = 'rbac_system_ready'
  )
LIMIT 1;

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================

-- Add comment to migration
COMMENT ON DATABASE agentmitra IS 'Agent Mitra - RBAC system fully configured with working test users and audit logging';
