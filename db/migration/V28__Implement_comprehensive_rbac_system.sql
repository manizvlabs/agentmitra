-- Agent Mitra - Migration V28: Implement Comprehensive RBAC System
-- This migration implements the complete Role-Based Access Control system per the design document

-- =====================================================
-- UPDATE EXISTING ROLES TO MATCH RBAC DESIGN
-- =====================================================

-- Update existing roles with proper descriptions and hierarchy
UPDATE lic_schema.roles SET
    role_description = 'Super Administrator with full system access',
    is_system_role = true
WHERE role_name = 'super_admin';

UPDATE lic_schema.roles SET
    role_description = 'Insurance Provider Administrator',
    is_system_role = true
WHERE role_name = 'insurance_provider_admin';

UPDATE lic_schema.roles SET
    role_description = 'Regional Manager',
    is_system_role = true
WHERE role_name = 'regional_manager';

UPDATE lic_schema.roles SET
    role_description = 'Senior Insurance Agent',
    is_system_role = true
WHERE role_name = 'senior_agent';

UPDATE lic_schema.roles SET
    role_description = 'Junior Insurance Agent',
    is_system_role = true
WHERE role_name = 'junior_agent';

UPDATE lic_schema.roles SET
    role_description = 'Policyholder/Customer',
    is_system_role = true
WHERE role_name = 'policyholder';

UPDATE lic_schema.roles SET
    role_description = 'Customer Support Staff',
    is_system_role = true
WHERE role_name = 'support_staff';

UPDATE lic_schema.roles SET
    role_description = 'Guest User',
    is_system_role = true
WHERE role_name = 'guest';

-- =====================================================
-- ADD MISSING ROLES FROM RBAC DESIGN
-- =====================================================

INSERT INTO lic_schema.roles (role_name, role_description, is_system_role)
VALUES
    ('compliance_officer', 'Ensures regulatory compliance and audits', true),
    ('customer_support_lead', 'Leads customer support team', true)
ON CONFLICT (role_name) DO UPDATE SET
    role_description = EXCLUDED.role_description,
    is_system_role = EXCLUDED.is_system_role;

-- =====================================================
-- COMPREHENSIVE PERMISSIONS SETUP
-- =====================================================

-- Insert all permissions from RBAC design document
INSERT INTO lic_schema.permissions (permission_name, permission_description, resource_type, action)
VALUES
    -- User Management
    ('users.create', 'Create users', 'user', 'create'),
    ('users.read', 'Read users', 'user', 'read'),
    ('users.update', 'Update users', 'user', 'update'),
    ('users.delete', 'Delete users', 'user', 'delete'),
    ('users.search', 'Search users', 'user', 'search'),

    -- Agent Management
    ('agents.create', 'Create agents', 'agent', 'create'),
    ('agents.read', 'Read agents', 'agent', 'read'),
    ('agents.update', 'Update agents', 'agent', 'update'),
    ('agents.delete', 'Delete agents', 'agent', 'delete'),
    ('agents.approve', 'Approve agents', 'agent', 'approve'),

    -- Policy Management
    ('policies.create', 'Create policies', 'policy', 'create'),
    ('policies.read', 'Read policies', 'policy', 'read'),
    ('policies.update', 'Update policies', 'policy', 'update'),
    ('policies.delete', 'Delete policies', 'policy', 'delete'),
    ('policies.approve', 'Approve policies', 'policy', 'approve'),

    -- Customer Management
    ('customers.create', 'Create customers', 'customer', 'create'),
    ('customers.read', 'Read customers', 'customer', 'read'),
    ('customers.update', 'Update customers', 'customer', 'update'),
    ('customers.delete', 'Delete customers', 'customer', 'delete'),

    -- Payment Management
    ('payments.create', 'Create payments', 'payment', 'create'),
    ('payments.read', 'Read payments', 'payment', 'read'),
    ('payments.update', 'Update payments', 'payment', 'update'),
    ('payments.process', 'Process payments', 'payment', 'process'),

    -- Reporting & Analytics
    ('reports.read', 'Read reports', 'report', 'read'),
    ('reports.create', 'Create reports', 'report', 'create'),
    ('reports.admin', 'Administrative reporting', 'report', 'admin'),
    ('analytics.read', 'Read analytics', 'analytics', 'read'),

    -- Campaign Management
    ('campaigns.create', 'Create campaigns', 'campaign', 'create'),
    ('campaigns.read', 'Read campaigns', 'campaign', 'read'),
    ('campaigns.update', 'Update campaigns', 'campaign', 'update'),
    ('campaigns.delete', 'Delete campaigns', 'campaign', 'delete'),

    -- Content & Presentations
    ('presentations.create', 'Create presentations', 'presentation', 'create'),
    ('presentations.read', 'Read presentations', 'presentation', 'read'),
    ('presentations.update', 'Update presentations', 'presentation', 'update'),
    ('presentations.publish', 'Publish presentations', 'presentation', 'publish'),

    -- Communication & Notifications
    ('notifications.send', 'Send notifications', 'notification', 'send'),
    ('notifications.manage', 'Manage notifications', 'notification', 'manage'),

    -- Support & Tickets
    ('tickets.read', 'Read support tickets', 'ticket', 'read'),
    ('tickets.create', 'Create support tickets', 'ticket', 'create'),
    ('tickets.update', 'Update support tickets', 'ticket', 'update'),
    ('tickets.close', 'Close support tickets', 'ticket', 'close'),
    ('tickets.manage', 'Manage all tickets', 'ticket', 'manage'),

    -- System Administration
    ('system.admin', 'Full system administration', 'system', 'admin'),
    ('system.config', 'System configuration', 'system', 'config'),

    -- Audit & Compliance
    ('audit.read', 'Read audit logs', 'audit', 'read'),
    ('audit.export', 'Export audit data', 'audit', 'export'),
    ('compliance.read', 'Read compliance data', 'compliance', 'read'),
    ('compliance.write', 'Write compliance data', 'compliance', 'write'),
    ('compliance.admin', 'Compliance administration', 'compliance', 'admin'),

    -- Tenant Management (Super Admin Only)
    ('tenants.create', 'Create new tenants', 'tenant', 'create'),
    ('tenants.read', 'Read tenant information', 'tenant', 'read'),
    ('tenants.update', 'Update tenant settings', 'tenant', 'update'),
    ('tenants.delete', 'Delete tenants', 'tenant', 'delete'),
    ('tenants.list', 'List all tenants', 'tenant', 'list'),
    ('tenants.manage_users', 'Manage tenant users', 'tenant', 'manage_users'),
    ('tenants.manage_config', 'Manage tenant configuration', 'tenant', 'manage_config'),

    -- Feature Flag Management
    ('feature_flags.read', 'Read feature flags', 'feature_flag', 'read'),
    ('feature_flags.update', 'Update feature flags', 'feature_flag', 'update'),
    ('feature_flags.admin', 'Administer feature flags', 'feature_flag', 'admin')
ON CONFLICT (permission_name) DO NOTHING;

-- =====================================================
-- ROLE-PERMISSION ASSIGNMENTS (Based on RBAC Matrix)
-- =====================================================

-- Clear existing role permissions and rebuild based on RBAC design
DELETE FROM lic_schema.role_permissions;

-- Super Admin - ALL permissions
INSERT INTO lic_schema.role_permissions (role_id, permission_id, granted_at)
SELECT r.role_id, p.permission_id, NOW()
FROM lic_schema.roles r
CROSS JOIN lic_schema.permissions p
WHERE r.role_name = 'super_admin';

-- Insurance Provider Admin
INSERT INTO lic_schema.role_permissions (role_id, permission_id, granted_at)
SELECT r.role_id, p.permission_id, NOW()
FROM lic_schema.roles r
CROSS JOIN lic_schema.permissions p
WHERE r.role_name = 'insurance_provider_admin'
  AND p.permission_name IN (
    'users.read', 'users.update', 'users.search',
    'agents.create', 'agents.read', 'agents.update', 'agents.approve',
    'policies.create', 'policies.read', 'policies.update', 'policies.approve',
    'customers.read', 'customers.update',
    'payments.read', 'payments.process',
    'reports.read', 'analytics.read',
    'campaigns.create', 'campaigns.read', 'campaigns.update',
    'presentations.create', 'presentations.read', 'presentations.update', 'presentations.publish',
    'tickets.read', 'tickets.manage',
    'audit.read', 'compliance.read'
  );

-- Regional Manager
INSERT INTO lic_schema.role_permissions (role_id, permission_id, granted_at)
SELECT r.role_id, p.permission_id, NOW()
FROM lic_schema.roles r
CROSS JOIN lic_schema.permissions p
WHERE r.role_name = 'regional_manager'
  AND p.permission_name IN (
    'agents.read', 'agents.update',
    'policies.read', 'policies.update', 'policies.approve',
    'customers.read', 'customers.update',
    'payments.read',
    'reports.read', 'analytics.read',
    'campaigns.create', 'campaigns.read', 'campaigns.update',
    'presentations.read', 'presentations.publish',
    'tickets.read', 'tickets.update', 'tickets.close',
    'users.search'
  );

-- Senior Agent
INSERT INTO lic_schema.role_permissions (role_id, permission_id, granted_at)
SELECT r.role_id, p.permission_id, NOW()
FROM lic_schema.roles r
CROSS JOIN lic_schema.permissions p
WHERE r.role_name = 'senior_agent'
  AND p.permission_name IN (
    'policies.create', 'policies.read', 'policies.update',
    'customers.create', 'customers.read', 'customers.update',
    'payments.create', 'payments.read',
    'campaigns.create', 'campaigns.read', 'campaigns.update',
    'presentations.create', 'presentations.read', 'presentations.update',
    'analytics.read', 'reports.read'
  );

-- Junior Agent
INSERT INTO lic_schema.role_permissions (role_id, permission_id, granted_at)
SELECT r.role_id, p.permission_id, NOW()
FROM lic_schema.roles r
CROSS JOIN lic_schema.permissions p
WHERE r.role_name = 'junior_agent'
  AND p.permission_name IN (
    'policies.read', 'policies.create',
    'customers.read', 'customers.create',
    'payments.read',
    'campaigns.read',
    'presentations.read'
  );

-- Policyholder
INSERT INTO lic_schema.role_permissions (role_id, permission_id, granted_at)
SELECT r.role_id, p.permission_id, NOW()
FROM lic_schema.roles r
CROSS JOIN lic_schema.permissions p
WHERE r.role_name = 'policyholder'
  AND p.permission_name IN (
    'policies.read',
    'payments.create', 'payments.read',
    'tickets.create', 'tickets.read'
  );

-- Support Staff
INSERT INTO lic_schema.role_permissions (role_id, permission_id, granted_at)
SELECT r.role_id, p.permission_id, NOW()
FROM lic_schema.roles r
CROSS JOIN lic_schema.permissions p
WHERE r.role_name = 'support_staff'
  AND p.permission_name IN (
    'customers.read', 'customers.update',
    'policies.read',
    'tickets.read', 'tickets.create', 'tickets.update', 'tickets.close',
    'reports.read'
  );

-- Guest User (limited permissions)
INSERT INTO lic_schema.role_permissions (role_id, permission_id, granted_at)
SELECT r.role_id, p.permission_id, NOW()
FROM lic_schema.roles r
CROSS JOIN lic_schema.permissions p
WHERE r.role_name = 'guest'
  AND p.permission_name IN (
    'policies.read',
    'presentations.read'
  );

-- Compliance Officer
INSERT INTO lic_schema.role_permissions (role_id, permission_id, granted_at)
SELECT r.role_id, p.permission_id, NOW()
FROM lic_schema.roles r
CROSS JOIN lic_schema.permissions p
WHERE r.role_name = 'compliance_officer'
  AND p.permission_name IN (
    'compliance.read', 'compliance.write', 'compliance.admin',
    'audit.read', 'audit.export',
    'users.read', 'reports.read'
  );

-- Customer Support Lead
INSERT INTO lic_schema.role_permissions (role_id, permission_id, granted_at)
SELECT r.role_id, p.permission_id, NOW()
FROM lic_schema.roles r
CROSS JOIN lic_schema.permissions p
WHERE r.role_name = 'customer_support_lead'
  AND p.permission_name IN (
    'tickets.manage', 'tickets.read', 'tickets.create', 'tickets.update', 'tickets.close',
    'customers.read', 'customers.update',
    'users.read', 'reports.read'
  );

-- =====================================================
-- FEATURE FLAGS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS lic_schema.feature_flags (
    flag_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    flag_name VARCHAR(100) UNIQUE NOT NULL,
    flag_description TEXT,
    flag_type VARCHAR(20) DEFAULT 'boolean', -- 'boolean', 'string', 'number', 'json'
    default_value TEXT, -- Default value when flag is enabled
    is_enabled BOOLEAN DEFAULT true,
    tenant_id UUID REFERENCES lic_schema.tenants(tenant_id), -- NULL for global flags
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    created_by UUID REFERENCES lic_schema.users(user_id),
    updated_by UUID REFERENCES lic_schema.users(user_id)
);

-- Feature flag values for specific users/roles (overrides)
CREATE TABLE IF NOT EXISTS lic_schema.feature_flag_overrides (
    override_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    flag_id UUID REFERENCES lic_schema.feature_flags(flag_id) ON DELETE CASCADE,
    user_id UUID REFERENCES lic_schema.users(user_id), -- NULL for role-based
    role_id UUID REFERENCES lic_schema.roles(role_id), -- NULL for user-specific
    tenant_id UUID REFERENCES lic_schema.tenants(tenant_id), -- NULL for global
    override_value TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_by UUID REFERENCES lic_schema.users(user_id)
);

-- =====================================================
-- FEATURE FLAGS SETUP (From RBAC Design)
-- =====================================================

-- Customer Portal Feature Flags
INSERT INTO lic_schema.feature_flags (flag_name, flag_description, flag_type, default_value, is_enabled)
VALUES
    ('customer_dashboard_enabled', 'Enable customer dashboard access', 'boolean', 'true', true),
    ('policy_management_enabled', 'Enable policy management features', 'boolean', 'true', true),
    ('premium_payments_enabled', 'Enable premium payment features', 'boolean', 'true', true),
    ('document_access_enabled', 'Enable document download/access', 'boolean', 'true', true),
    ('communication_tools_enabled', 'Enable chat, email, WhatsApp features', 'boolean', 'true', true),
    ('learning_center_enabled', 'Enable learning center access', 'boolean', 'true', true),
    ('profile_management_enabled', 'Enable profile management', 'boolean', 'true', true),
    ('whatsapp_integration_enabled', 'Enable WhatsApp integration', 'boolean', 'true', true),
    ('chatbot_assistance_enabled', 'Enable chatbot assistance', 'boolean', 'true', true),
    ('video_tutorials_enabled', 'Enable video tutorials', 'boolean', 'true', true)
ON CONFLICT (flag_name) DO NOTHING;

-- Agent Portal Feature Flags
INSERT INTO lic_schema.feature_flags (flag_name, flag_description, flag_type, default_value, is_enabled)
VALUES
    ('agent_dashboard_enabled', 'Enable agent dashboard access', 'boolean', 'true', true),
    ('customer_management_enabled', 'Enable customer management features', 'boolean', 'true', true),
    ('marketing_campaigns_enabled', 'Enable marketing campaign features', 'boolean', 'true', true),
    ('content_management_enabled', 'Enable content management features', 'boolean', 'true', true),
    ('roi_analytics_enabled', 'Enable ROI analytics features', 'boolean', 'true', true),
    ('commission_tracking_enabled', 'Enable commission tracking', 'boolean', 'true', true),
    ('lead_management_enabled', 'Enable lead management features', 'boolean', 'true', true),
    ('advanced_analytics_enabled', 'Enable advanced analytics', 'boolean', 'true', true),
    ('team_management_enabled', 'Enable team management features', 'boolean', 'true', true),
    ('regional_oversight_enabled', 'Enable regional oversight features', 'boolean', 'true', true)
ON CONFLICT (flag_name) DO NOTHING;

-- Administrative Feature Flags
INSERT INTO lic_schema.feature_flags (flag_name, flag_description, flag_type, default_value, is_enabled)
VALUES
    ('user_management_enabled', 'Enable user management features', 'boolean', 'true', true),
    ('feature_flag_control_enabled', 'Enable feature flag management', 'boolean', 'true', true),
    ('system_configuration_enabled', 'Enable system configuration', 'boolean', 'true', true),
    ('audit_compliance_enabled', 'Enable audit and compliance features', 'boolean', 'true', true),
    ('financial_management_enabled', 'Enable financial management features', 'boolean', 'true', true),
    ('tenant_management_enabled', 'Enable tenant management features', 'boolean', 'true', true),
    ('provider_administration_enabled', 'Enable provider administration', 'boolean', 'true', true)
ON CONFLICT (flag_name) DO NOTHING;

-- =====================================================
-- RBAC AUDIT LOGGING
-- =====================================================

-- Extend audit log to include RBAC-specific actions
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
-- INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_feature_flags_name ON lic_schema.feature_flags(flag_name);
CREATE INDEX IF NOT EXISTS idx_feature_flags_tenant ON lic_schema.feature_flags(tenant_id);
CREATE INDEX IF NOT EXISTS idx_feature_flag_overrides_flag ON lic_schema.feature_flag_overrides(flag_id);
CREATE INDEX IF NOT EXISTS idx_feature_flag_overrides_user ON lic_schema.feature_flag_overrides(user_id);
CREATE INDEX IF NOT EXISTS idx_feature_flag_overrides_role ON lic_schema.feature_flag_overrides(role_id);
CREATE INDEX IF NOT EXISTS idx_rbac_audit_tenant_timestamp ON lic_schema.rbac_audit_log(tenant_id, timestamp);
CREATE INDEX IF NOT EXISTS idx_rbac_audit_user ON lic_schema.rbac_audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_rbac_audit_action ON lic_schema.rbac_audit_log(action);

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================

-- Add comment to migration
COMMENT ON DATABASE agentmitra IS 'Agent Mitra - Complete RBAC System with roles, permissions, feature flags, and audit logging';
