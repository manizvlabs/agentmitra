-- Agent Mitra - Migration V63: Fix RBAC Audit Log Table
-- This migration ensures the rbac_audit_log table exists with correct structure

-- =====================================================
-- ENSURE RBAC AUDIT LOG TABLE EXISTS
-- =====================================================

-- Drop table if it exists with wrong structure (to avoid conflicts)
DROP TABLE IF EXISTS lic_schema.rbac_audit_log CASCADE;

-- Create the rbac_audit_log table with correct structure
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

-- =====================================================
-- ADD INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_rbac_audit_tenant_timestamp ON lic_schema.rbac_audit_log(tenant_id, timestamp);
CREATE INDEX IF NOT EXISTS idx_rbac_audit_user ON lic_schema.rbac_audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_rbac_audit_action ON lic_schema.rbac_audit_log(action);
CREATE INDEX IF NOT EXISTS idx_rbac_audit_target_user ON lic_schema.rbac_audit_log(target_user_id);
CREATE INDEX IF NOT EXISTS idx_rbac_audit_timestamp ON lic_schema.rbac_audit_log(timestamp DESC);

-- =====================================================
-- SEED INITIAL AUDIT LOG ENTRIES FOR TESTING
-- =====================================================

-- Add some test audit entries to ensure the table works
INSERT INTO lic_schema.rbac_audit_log (
    tenant_id,
    user_id,
    action,
    details,
    success,
    timestamp
)
SELECT
    t.tenant_id,
    u.user_id,
    'system_initialization',
    jsonb_build_object(
        'description', 'RBAC system initialized',
        'version', 'v63',
        'user_role', u.role
    ),
    true,
    NOW()
FROM lic_schema.tenants t
CROSS JOIN lic_schema.users u
WHERE t.tenant_code = 'LIC'
  AND u.phone_number = '+919876543200'  -- Super Admin
  AND NOT EXISTS (
      SELECT 1 FROM lic_schema.rbac_audit_log
      WHERE action = 'system_initialization'
  )
LIMIT 1;

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================

-- Add comment to migration
COMMENT ON TABLE lic_schema.rbac_audit_log IS 'RBAC audit log for tracking authorization actions and role/permission changes';
