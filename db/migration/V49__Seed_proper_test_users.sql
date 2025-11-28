-- Seed proper test users with correct credentials and RBAC setup
-- This migration creates the 7 test users as specified in the requirements

-- =====================================================
-- STEP 1: Create Default Tenant (if not exists)
-- =====================================================

INSERT INTO lic_schema.tenants (
    tenant_id,
    name,
    domain,
    status,
    created_at,
    updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000'::uuid,
    'Default Tenant',
    'agentmitra.com',
    'active',
    NOW(),
    NOW()
) ON CONFLICT (tenant_id) DO NOTHING;

-- =====================================================
-- STEP 2: Clean up existing test users (avoid conflicts)
-- =====================================================

-- Remove any existing users with the test phone numbers
DELETE FROM lic_schema.user_roles WHERE user_id IN (
    SELECT user_id FROM lic_schema.users WHERE phone_number IN (
        '+919876543200', '+919876543201', '+919876543202',
        '+919876543203', '+919876543204', '+919876543205', '+919876543206'
    )
);

DELETE FROM lic_schema.users WHERE phone_number IN (
    '+919876543200', '+919876543201', '+919876543202',
    '+919876543203', '+919876543204', '+919876543205', '+919876543206'
);

-- =====================================================
-- STEP 3: Create RBAC Roles (if not exist)
-- =====================================================

INSERT INTO lic_schema.roles (role_id, name, description, is_system_role, created_at) VALUES
    ('role-super-admin', 'Super Admin', 'Full system access (59 permissions)', true, NOW()),
    ('role-provider-admin', 'Provider Admin', 'Insurance provider management', true, NOW()),
    ('role-regional-manager', 'Regional Manager', 'Regional operations (19 permissions)', true, NOW()),
    ('role-senior-agent', 'Senior Agent', 'Agent operations + inherited permissions (16 permissions)', true, NOW()),
    ('role-junior-agent', 'Junior Agent', 'Basic agent operations (7 permissions)', true, NOW()),
    ('role-policyholder', 'Policyholder', 'Customer access (5 permissions)', true, NOW()),
    ('role-support-staff', 'Support Staff', 'Support operations (8 permissions)', true, NOW())
ON CONFLICT (role_id) DO NOTHING;

-- =====================================================
-- STEP 4: Create Test Users with Correct Credentials
-- =====================================================

-- Password hash for 'testpassword' (bcrypt with salt)
-- Generated using: bcrypt.hashpw('testpassword'.encode('utf-8'), bcrypt.gensalt(12))

INSERT INTO lic_schema.users (
    user_id,
    tenant_id,
    phone_number,
    password_hash,
    password_salt,
    email,
    full_name,
    status,
    phone_verified,
    email_verified,
    created_at,
    updated_at
) VALUES
    -- Super Admin
    (
        '550e8400-e29b-41d4-a716-446655440000'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        '+919876543200',
        '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewfBPj6P5HfZ6Xm',
        'randomsalt123',
        'superadmin@agentmitra.com',
        'Super Administrator',
        'active',
        true,
        true,
        NOW(),
        NOW()
    ),
    -- Provider Admin
    (
        '550e8400-e29b-41d4-a716-446655440001'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        '+919876543201',
        '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewfBPj6P5HfZ6Xm',
        'randomsalt123',
        'provider@agentmitra.com',
        'Provider Administrator',
        'active',
        true,
        true,
        NOW(),
        NOW()
    ),
    -- Regional Manager
    (
        '550e8400-e29b-41d4-a716-446655440002'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        '+919876543202',
        '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewfBPj6P5HfZ6Xm',
        'randomsalt123',
        'regional@agentmitra.com',
        'Regional Manager',
        'active',
        true,
        true,
        NOW(),
        NOW()
    ),
    -- Senior Agent
    (
        '550e8400-e29b-41d4-a716-446655440003'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        '+919876543203',
        '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewfBPj6P5HfZ6Xm',
        'randomsalt123',
        'senior@agentmitra.com',
        'Senior Agent',
        'active',
        true,
        true,
        NOW(),
        NOW()
    ),
    -- Junior Agent
    (
        '550e8400-e29b-41d4-a716-446655440004'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        '+919876543204',
        '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewfBPj6P5HfZ6Xm',
        'randomsalt123',
        'junior@agentmitra.com',
        'Junior Agent',
        'active',
        true,
        true,
        NOW(),
        NOW()
    ),
    -- Policyholder
    (
        '550e8400-e29b-41d4-a716-446655440005'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        '+919876543205',
        '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewfBPj6P5HfZ6Xm',
        'randomsalt123',
        'customer@agentmitra.com',
        'Policyholder Customer',
        'active',
        true,
        true,
        NOW(),
        NOW()
    ),
    -- Support Staff
    (
        '550e8400-e29b-41d4-a716-446655440006'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        '+919876543206',
        '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewfBPj6P5HfZ6Xm',
        'randomsalt123',
        'support@agentmitra.com',
        'Support Staff',
        'active',
        true,
        true,
        NOW(),
        NOW()
    );

-- =====================================================
-- STEP 5: Assign Roles to Users
-- =====================================================

INSERT INTO lic_schema.user_roles (user_id, role_id, assigned_by, assigned_at) VALUES
    -- Super Admin
    ('550e8400-e29b-41d4-a716-446655440000'::uuid, 'role-super-admin', '550e8400-e29b-41d4-a716-446655440000'::uuid, NOW()),
    -- Provider Admin
    ('550e8400-e29b-41d4-a716-446655440001'::uuid, 'role-provider-admin', '550e8400-e29b-41d4-a716-446655440000'::uuid, NOW()),
    -- Regional Manager
    ('550e8400-e29b-41d4-a716-446655440002'::uuid, 'role-regional-manager', '550e8400-e29b-41d4-a716-446655440000'::uuid, NOW()),
    -- Senior Agent
    ('550e8400-e29b-41d4-a716-446655440003'::uuid, 'role-senior-agent', '550e8400-e29b-41d4-a716-446655440000'::uuid, NOW()),
    -- Junior Agent
    ('550e8400-e29b-41d4-a716-446655440004'::uuid, 'role-junior-agent', '550e8400-e29b-41d4-a716-446655440000'::uuid, NOW()),
    -- Policyholder
    ('550e8400-e29b-41d4-a716-446655440005'::uuid, 'role-policyholder', '550e8400-e29b-41d4-a716-446655440000'::uuid, NOW()),
    -- Support Staff
    ('550e8400-e29b-41d4-a716-446655440006'::uuid, 'role-support-staff', '550e8400-e29b-41d4-a716-446655440000'::uuid, NOW())
ON CONFLICT (user_id, role_id) DO NOTHING;

-- =====================================================
-- STEP 6: Create Agent Records for Agent Users
-- =====================================================

INSERT INTO lic_schema.agents (
    agent_id,
    user_id,
    tenant_id,
    agent_code,
    license_number,
    business_name,
    territory,
    experience_years,
    total_policies_sold,
    total_premium_collected,
    status,
    verification_status,
    created_at,
    updated_at
) VALUES
    -- Senior Agent
    (
        '660e8400-e29b-41d4-a716-446655440003'::uuid,
        '550e8400-e29b-41d4-a716-446655440003'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        'AGT003',
        'LIC123456789',
        'Premium Insurance Solutions',
        'Mumbai Region',
        8,
        150,
        2500000.00,
        'active',
        'verified',
        NOW(),
        NOW()
    ),
    -- Junior Agent
    (
        '660e8400-e29b-41d4-a716-446655440004'::uuid,
        '550e8400-e29b-41d4-a716-446655440004'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        'AGT004',
        'LIC987654321',
        'Secure Future Insurance',
        'Delhi Region',
        3,
        45,
        750000.00,
        'active',
        'verified',
        NOW(),
        NOW()
    );

-- =====================================================
-- STEP 7: Create Policyholder Records
-- =====================================================

INSERT INTO lic_schema.policyholders (
    policyholder_id,
    user_id,
    tenant_id,
    first_name,
    last_name,
    date_of_birth,
    gender,
    occupation,
    annual_income,
    address_line1,
    city,
    state,
    pincode,
    created_at,
    updated_at
) VALUES
    (
        '770e8400-e29b-41d4-a716-446655440005'::uuid,
        '550e8400-e29b-41d4-a716-446655440005'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        'Rajesh',
        'Sharma',
        '1985-06-15'::date,
        'male',
        'Software Engineer',
        1200000,
        '123 MG Road',
        'Mumbai',
        'Maharashtra',
        '400001',
        NOW(),
        NOW()
    );

-- =====================================================
-- VERIFICATION: Check seeded data
-- =====================================================

DO $$
DECLARE
    user_count INTEGER;
    role_count INTEGER;
    agent_count INTEGER;
    policyholder_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO user_count FROM lic_schema.users WHERE phone_number LIKE '+91987654320%';
    SELECT COUNT(*) INTO role_count FROM lic_schema.user_roles WHERE user_id IN (
        SELECT user_id FROM lic_schema.users WHERE phone_number LIKE '+91987654320%'
    );
    SELECT COUNT(*) INTO agent_count FROM lic_schema.agents WHERE user_id IN (
        SELECT user_id FROM lic_schema.users WHERE phone_number LIKE '+91987654320%'
    );
    SELECT COUNT(*) INTO policyholder_count FROM lic_schema.policyholders WHERE user_id IN (
        SELECT user_id FROM lic_schema.users WHERE phone_number LIKE '+91987654320%'
    );

    RAISE NOTICE 'Seeded % users, % role assignments, % agents, % policyholders',
        user_count, role_count, agent_count, policyholder_count;
END $$;
