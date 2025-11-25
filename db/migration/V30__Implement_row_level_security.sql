-- Agent Mitra - Migration V29: Implement Row-Level Security (RLS)
-- This migration adds tenant-based row-level security policies

-- =====================================================
-- ENABLE ROW LEVEL SECURITY ON TENANT TABLES
-- =====================================================

-- Agents table
ALTER TABLE lic_schema.agents ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS tenant_agents_isolation ON lic_schema.agents;
CREATE POLICY tenant_agents_isolation ON lic_schema.agents
    FOR ALL USING (
        tenant_id = lic_schema.current_tenant_id()
        OR lic_schema.current_tenant_id() IS NULL  -- Allow super admin access
    );

-- Policyholders table
ALTER TABLE lic_schema.policyholders ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS tenant_policyholders_isolation ON lic_schema.policyholders;
CREATE POLICY tenant_policyholders_isolation ON lic_schema.policyholders
    FOR ALL USING (
        tenant_id = lic_schema.current_tenant_id()
        OR lic_schema.current_tenant_id() IS NULL
    );

-- Insurance policies table
ALTER TABLE lic_schema.insurance_policies ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS tenant_policies_isolation ON lic_schema.insurance_policies;
CREATE POLICY tenant_policies_isolation ON lic_schema.insurance_policies
    FOR ALL USING (
        tenant_id = lic_schema.current_tenant_id()
        OR lic_schema.current_tenant_id() IS NULL
    );

-- Premium payments table
ALTER TABLE lic_schema.premium_payments ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS tenant_payments_isolation ON lic_schema.premium_payments;
CREATE POLICY tenant_payments_isolation ON lic_schema.premium_payments
    FOR ALL USING (
        tenant_id = lic_schema.current_tenant_id()
        OR lic_schema.current_tenant_id() IS NULL
    );

-- Commissions table (if exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'commissions') THEN
        EXECUTE 'ALTER TABLE lic_schema.commissions ENABLE ROW LEVEL SECURITY';
        EXECUTE 'DROP POLICY IF EXISTS tenant_commissions_isolation ON lic_schema.commissions';
        EXECUTE 'CREATE POLICY tenant_commissions_isolation ON lic_schema.commissions
            FOR ALL USING (
                tenant_id = lic_schema.current_tenant_id()
                OR lic_schema.current_tenant_id() IS NULL
            )';
    END IF;
END $$;

-- Tenant users table (for user-tenant relationships)
ALTER TABLE lic_schema.tenant_users ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS tenant_tenant_users_isolation ON lic_schema.tenant_users;
CREATE POLICY tenant_tenant_users_isolation ON lic_schema.tenant_users
    FOR ALL USING (
        tenant_id = lic_schema.current_tenant_id()
        OR lic_schema.current_tenant_id() IS NULL
    );

-- Notifications table (if exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'notifications') THEN
        EXECUTE 'ALTER TABLE lic_schema.notifications ENABLE ROW LEVEL SECURITY';
        EXECUTE 'DROP POLICY IF EXISTS tenant_notifications_isolation ON lic_schema.notifications';
        EXECUTE 'CREATE POLICY tenant_notifications_isolation ON lic_schema.notifications
            FOR ALL USING (
                tenant_id = lic_schema.current_tenant_id()
                OR lic_schema.current_tenant_id() IS NULL
            )';
    END IF;
END $$;

-- Campaigns table (if exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'campaigns') THEN
        EXECUTE 'ALTER TABLE lic_schema.campaigns ENABLE ROW LEVEL SECURITY';
        EXECUTE 'DROP POLICY IF EXISTS tenant_campaigns_isolation ON lic_schema.campaigns';
        EXECUTE 'CREATE POLICY tenant_campaigns_isolation ON lic_schema.campaigns
            FOR ALL USING (
                tenant_id = lic_schema.current_tenant_id()
                OR lic_schema.current_tenant_id() IS NULL
            )';
    END IF;
END $$;

-- =====================================================
-- CREATE TENANT CONTEXT MANAGEMENT FUNCTIONS
-- =====================================================

-- Function to get current tenant context from session
CREATE OR REPLACE FUNCTION lic_schema.current_tenant_id()
RETURNS UUID AS $$
BEGIN
    RETURN NULLIF(current_setting('app.current_tenant_id', TRUE), '')::UUID;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Function to set tenant context for session
CREATE OR REPLACE FUNCTION lic_schema.set_tenant_context(tenant_uuid UUID)
RETURNS VOID AS $$
BEGIN
    PERFORM set_config('app.current_tenant_id', tenant_uuid::TEXT, FALSE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to validate tenant access for user
CREATE OR REPLACE FUNCTION lic_schema.validate_tenant_access(user_uuid UUID, tenant_uuid UUID)
RETURNS BOOLEAN AS $$
DECLARE
    has_access BOOLEAN := FALSE;
    user_role TEXT;
BEGIN
    -- Check if user is assigned to tenant
    SELECT EXISTS(
        SELECT 1 FROM lic_schema.tenant_users tu
        WHERE tu.user_id = user_uuid
        AND tu.tenant_id = tenant_uuid
        AND tu.status = 'active'
    ) INTO has_access;

    -- If user is assigned to tenant, allow access
    IF has_access THEN
        RETURN TRUE;
    END IF;

    -- Check if user has super_admin role (can access all tenants)
    SELECT r.role_name INTO user_role
    FROM lic_schema.user_roles ur
    JOIN lic_schema.roles r ON ur.role_id = r.role_id
    WHERE ur.user_id = user_uuid
    AND r.role_name = 'super_admin'
    LIMIT 1;

    RETURN user_role IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- CREATE AUDIT TRIGGER FOR TENANT DATA CHANGES
-- =====================================================

-- Function to audit tenant data changes
CREATE OR REPLACE FUNCTION lic_schema.audit_tenant_data_changes()
RETURNS TRIGGER AS $$
DECLARE
    current_tenant UUID;
    current_user_id UUID;
BEGIN
    -- Get current tenant and user from context
    current_tenant := lic_schema.current_tenant_id();
    current_user_id := NULLIF(current_setting('app.current_user_id', TRUE), '')::UUID;

    -- Insert audit record
    INSERT INTO lic_schema.rbac_audit_log (
        tenant_id, user_id, action, target_user_id,
        details, success, ip_address, user_agent
    ) VALUES (
        current_tenant,
        current_user_id,
        CASE
            WHEN TG_OP = 'INSERT' THEN 'data_created'
            WHEN TG_OP = 'UPDATE' THEN 'data_updated'
            WHEN TG_OP = 'DELETE' THEN 'data_deleted'
        END,
        CASE
            WHEN TG_OP = 'DELETE' THEN (OLD.user_id)
            ELSE (NEW.user_id)
        END,
        jsonb_build_object(
            'table', TG_TABLE_NAME,
            'operation', TG_OP,
            'record_id', CASE
                WHEN TG_OP = 'DELETE' THEN (OLD.agent_id)
                ELSE (NEW.agent_id)
            END
        ),
        TRUE,
        NULLIF(current_setting('app.client_ip', TRUE), ''),
        NULLIF(current_setting('app.user_agent', TRUE), '')
    );

    RETURN CASE
        WHEN TG_OP = 'DELETE' THEN OLD
        ELSE NEW
    END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add audit triggers to key tables
DROP TRIGGER IF EXISTS audit_agents_changes ON lic_schema.agents;
CREATE TRIGGER audit_agents_changes
    AFTER INSERT OR UPDATE OR DELETE ON lic_schema.agents
    FOR EACH ROW EXECUTE FUNCTION lic_schema.audit_tenant_data_changes();

DROP TRIGGER IF EXISTS audit_policies_changes ON lic_schema.insurance_policies;
CREATE TRIGGER audit_policies_changes
    AFTER INSERT OR UPDATE OR DELETE ON lic_schema.insurance_policies
    FOR EACH ROW EXECUTE FUNCTION lic_schema.audit_tenant_data_changes();

-- =====================================================
-- UPDATE EXISTING DATA WITH TENANT ASSIGNMENTS
-- =====================================================

-- Assign existing data to the default LIC tenant
UPDATE lic_schema.agents
SET tenant_id = (SELECT tenant_id FROM lic_schema.tenants WHERE tenant_code = 'LIC' LIMIT 1)
WHERE tenant_id IS NULL;

UPDATE lic_schema.policyholders
SET tenant_id = (SELECT tenant_id FROM lic_schema.tenants WHERE tenant_code = 'LIC' LIMIT 1)
WHERE tenant_id IS NULL;

UPDATE lic_schema.insurance_policies
SET tenant_id = (SELECT tenant_id FROM lic_schema.tenants WHERE tenant_code = 'LIC' LIMIT 1)
WHERE tenant_id IS NULL;

UPDATE lic_schema.premium_payments
SET tenant_id = (SELECT tenant_id FROM lic_schema.tenants WHERE tenant_code = 'LIC' LIMIT 1)
WHERE tenant_id IS NULL;

-- Assign tenant users for existing users
INSERT INTO lic_schema.tenant_users (user_id, tenant_id, role, status)
SELECT DISTINCT
    u.user_id,
    t.tenant_id,
    'member',
    'active'
FROM lic_schema.users u
CROSS JOIN lic_schema.tenants t
WHERE u.role IN ('junior_agent', 'senior_agent', 'regional_manager', 'insurance_provider_admin')
AND NOT EXISTS (
    SELECT 1 FROM lic_schema.tenant_users tu
    WHERE tu.user_id = u.user_id AND tu.tenant_id = t.tenant_id
)
ON CONFLICT (tenant_id, user_id) DO NOTHING;

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================

-- Add comment to migration
COMMENT ON DATABASE agentmitra IS 'Agent Mitra - Row-Level Security implemented for complete tenant isolation';
