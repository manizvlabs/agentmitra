-- Agent Mitra - Migration V31: Seed RBAC Test Data
-- This migration adds test data for RBAC system testing

-- =====================================================
-- FIX AUDIT FUNCTION FOR PROPER DATA TYPES
-- =====================================================

-- Recreate audit function with proper data types
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
        NULLIF(current_setting('app.client_ip', TRUE), '')::inet,
        NULLIF(current_setting('app.user_agent', TRUE), '')
    );

    RETURN CASE
        WHEN TG_OP = 'DELETE' THEN OLD
        ELSE NEW
    END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- SEED SUPER ADMIN USER FOR RBAC TESTING
-- =====================================================

-- Insert super admin user if not exists
INSERT INTO lic_schema.users (
    user_id,
    tenant_id,
    phone_number,
    email,
    password_hash,
    first_name,
    last_name,
    role,
    status,
    email_verified,
    phone_verified
)
SELECT
    '38ab082d-d602-40f3-b83d-a652f1425349'::uuid,
    t.tenant_id,
    '+919876543200',
    'superadmin@test.com',
    '$2b$12$L6OjHQp7n5fRKRvM9t3JeO3tJcKQZ3Z3Z3Z3Z3Z3Z3Z3Z3Z3Z3Z3',
    'Super',
    'Admin',
    'super_admin'::lic_schema.user_role_enum,
    'active',
    true,
    true
FROM lic_schema.tenants t
WHERE t.tenant_code = 'LIC'
AND NOT EXISTS (
    SELECT 1 FROM lic_schema.users
    WHERE phone_number = '+919876543200' OR email = 'superadmin@test.com'
)
LIMIT 1;

-- =====================================================
-- ASSIGN SUPER ADMIN ROLE
-- =====================================================

-- Assign super_admin role to the user
INSERT INTO lic_schema.user_roles (
    user_id,
    role_id,
    assigned_by
)
SELECT
    u.user_id,
    r.role_id,
    u.user_id  -- self-assigned
FROM lic_schema.users u
CROSS JOIN lic_schema.roles r
WHERE u.phone_number = '+919876543200'
  AND r.role_name = 'super_admin'
  AND NOT EXISTS (
      SELECT 1 FROM lic_schema.user_roles ur
      WHERE ur.user_id = u.user_id AND ur.role_id = r.role_id
  );

-- =====================================================
-- ASSIGN SUPER ADMIN TO TENANT
-- =====================================================

-- Assign super admin to LIC tenant
INSERT INTO lic_schema.tenant_users (
    tenant_id,
    user_id,
    role,
    status
)
SELECT
    t.tenant_id,
    u.user_id,
    'super_admin'::lic_schema.user_role_enum,
    'active'
FROM lic_schema.tenants t
CROSS JOIN lic_schema.users u
WHERE t.tenant_code = 'LIC'
  AND u.phone_number = '+919876543200'
  AND NOT EXISTS (
      SELECT 1 FROM lic_schema.tenant_users tu
      WHERE tu.tenant_id = t.tenant_id AND tu.user_id = u.user_id
  );

-- =====================================================
-- SEED TEST USERS FOR DIFFERENT ROLES
-- =====================================================

-- Test users for different roles (only if they don't exist)
INSERT INTO lic_schema.users (
    user_id,
    tenant_id,
    phone_number,
    email,
    password_hash,
    first_name,
    last_name,
    role,
    status,
    email_verified,
    phone_verified
)
SELECT
    gen_random_uuid(),
    t.tenant_id,
    phone_num,
    email_addr,
    '$2b$12$L6OjHQp7n5fRKRvM9t3JeO3tJcKQZ3Z3Z3Z3Z3Z3Z3Z3Z3Z3Z3Z3',
    first_n,
    last_n,
    role_name,
    'active',
    true,
    true
FROM lic_schema.tenants t
CROSS JOIN (
    VALUES
        ('+919876543201', 'provideradmin@test.com', 'Provider', 'Admin', 'insurance_provider_admin'::lic_schema.user_role_enum),
        ('+919876543202', 'regionalmgr@test.com', 'Regional', 'Manager', 'regional_manager'::lic_schema.user_role_enum),
        ('+919876543203', 'senioragent@test.com', 'Senior', 'Agent', 'senior_agent'::lic_schema.user_role_enum),
        ('+919876543204', 'junioragent@test.com', 'Junior', 'Agent', 'junior_agent'::lic_schema.user_role_enum),
        ('+919876543205', 'policyholder@test.com', 'Policy', 'Holder', 'policyholder'::lic_schema.user_role_enum),
        ('+919876543206', 'supportstaff@test.com', 'Support', 'Staff', 'support_staff'::lic_schema.user_role_enum)
) AS test_users(phone_num, email_addr, first_n, last_n, role_name)
WHERE t.tenant_code = 'LIC'
  AND NOT EXISTS (
      SELECT 1 FROM lic_schema.users u
      WHERE u.phone_number = phone_num
  );

-- =====================================================
-- ASSIGN ROLES TO TEST USERS
-- =====================================================

-- Assign roles to test users
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
WHERE u.phone_number IN (
    '+919876543201', '+919876543202', '+919876543203',
    '+919876543204', '+919876543205', '+919876543206'
)
  AND r.role_name = u.role::text
  AND sa.phone_number = '+919876543200'  -- super admin
  AND NOT EXISTS (
      SELECT 1 FROM lic_schema.user_roles ur
      WHERE ur.user_id = u.user_id AND ur.role_id = r.role_id
  );

-- =====================================================
-- ASSIGN TEST USERS TO TENANT
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
  AND u.phone_number IN (
      '+919876543200', '+919876543201', '+919876543202',
      '+919876543203', '+919876543204', '+919876543205',
      '+919876543206'
  )
  AND NOT EXISTS (
      SELECT 1 FROM lic_schema.tenant_users tu
      WHERE tu.tenant_id = t.tenant_id AND tu.user_id = u.user_id
  );

-- =====================================================
-- SEED SAMPLE AGENTS FOR TESTING
-- =====================================================

-- Create agent records for test users (only for agent roles)
INSERT INTO lic_schema.agents (
    user_id,
    tenant_id,
    agent_code,
    license_number,
    business_name,
    status,
    verification_status
)
SELECT
    u.user_id,
    t.tenant_id,
    'AGT' || substring(u.user_id::text, 1, 8),
    'LIC' || substring(u.user_id::text, 1, 8),
    u.first_name || ' ' || u.last_name || ' Agency',
    'active',
    'verified'
FROM lic_schema.users u
CROSS JOIN lic_schema.tenants t
WHERE t.tenant_code = 'LIC'
  AND u.role IN ('senior_agent', 'junior_agent')
  AND NOT EXISTS (
      SELECT 1 FROM lic_schema.agents a
      WHERE a.user_id = u.user_id
  );

-- =====================================================
-- SEED SAMPLE POLICYHOLDERS FOR TESTING
-- =====================================================

-- Create policyholder records for test users
INSERT INTO lic_schema.policyholders (
    user_id,
    tenant_id
)
SELECT
    u.user_id,
    t.tenant_id
FROM lic_schema.users u
CROSS JOIN lic_schema.tenants t
WHERE t.tenant_code = 'LIC'
  AND u.role = 'policyholder'::lic_schema.user_role_enum
  AND NOT EXISTS (
      SELECT 1 FROM lic_schema.policyholders p
      WHERE p.user_id = u.user_id
  );

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================

-- Add comment to migration
COMMENT ON DATABASE agentmitra IS 'Agent Mitra - Seeded RBAC test data including super admin and test users for all roles';
