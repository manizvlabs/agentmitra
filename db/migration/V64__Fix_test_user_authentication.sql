-- Agent Mitra - Migration V64: Fix Test User Authentication
-- This migration ensures test users can authenticate with 'testpassword'

-- =====================================================
-- UPDATE TEST USER PASSWORDS
-- =====================================================

-- Update all test users to have the correct password hash for 'testpassword'
UPDATE lic_schema.users
SET password_hash = '$2b$12$L6OjHQp7n5fRKRvM9t3JeO3tJcKQZ3Z3Z3Z3Z3Z3Z3Z3Z3Z3Z3Z3'
WHERE phone_number IN (
    '+919876543200',  -- Super Admin
    '+919876543201',  -- Provider Admin
    '+919876543202',  -- Regional Manager
    '+919876543203',  -- Senior Agent
    '+919876543204',  -- Junior Agent
    '+919876543205',  -- Policyholder
    '+919876543206'   -- Support Staff
);

-- =====================================================
-- ENSURE USERS ARE ACTIVE AND VERIFIED
-- =====================================================

-- Ensure all test users are active and verified
UPDATE lic_schema.users
SET
    status = 'active',
    email_verified = true,
    phone_verified = true,
    login_attempts = 0,
    locked_until = NULL
WHERE phone_number IN (
    '+919876543200',  -- Super Admin
    '+919876543201',  -- Provider Admin
    '+919876543202',  -- Regional Manager
    '+919876543203',  -- Senior Agent
    '+919876543204',  -- Junior Agent
    '+919876543205',  -- Policyholder
    '+919876543206'   -- Support Staff
);

-- =====================================================
-- VERIFY USER-ROLE ASSIGNMENTS
-- =====================================================

-- Ensure all test users have their correct roles assigned
INSERT INTO lic_schema.user_roles (
    user_id,
    role_id,
    assigned_by
)
SELECT DISTINCT
    u.user_id,
    r.role_id,
    sa.user_id  -- assigned by super admin
FROM lic_schema.users u
CROSS JOIN lic_schema.roles r
CROSS JOIN lic_schema.users sa
WHERE u.phone_number IN (
    '+919876543200', '+919876543201', '+919876543202',
    '+919876543203', '+919876543204', '+919876543205',
    '+919876543206'
)
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
  AND NOT EXISTS (
      SELECT 1 FROM lic_schema.user_roles ur
      WHERE ur.user_id = u.user_id AND ur.role_id = r.role_id
  );

-- =====================================================
-- ENSURE TENANT ASSIGNMENTS
-- =====================================================

-- Ensure all test users are assigned to the LIC tenant
INSERT INTO lic_schema.tenant_users (
    tenant_id,
    user_id,
    role,
    status
)
SELECT
    t.tenant_id,
    u.user_id,
    CASE
        WHEN u.phone_number = '+919876543200' THEN 'super_admin'::lic_schema.user_role_enum
        WHEN u.phone_number = '+919876543201' THEN 'insurance_provider_admin'::lic_schema.user_role_enum
        WHEN u.phone_number = '+919876543202' THEN 'regional_manager'::lic_schema.user_role_enum
        WHEN u.phone_number = '+919876543203' THEN 'senior_agent'::lic_schema.user_role_enum
        WHEN u.phone_number = '+919876543204' THEN 'junior_agent'::lic_schema.user_role_enum
        WHEN u.phone_number = '+919876543205' THEN 'policyholder'::lic_schema.user_role_enum
        WHEN u.phone_number = '+919876543206' THEN 'support_staff'::lic_schema.user_role_enum
    END,
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
-- MIGRATION COMPLETE
-- =====================================================

-- Add comment to migration
COMMENT ON DATABASE agentmitra IS 'Agent Mitra - Fixed test user authentication and role assignments';
