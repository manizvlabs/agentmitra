-- Seed comprehensive test data for API testing
-- This migration adds test data for all entities

-- =====================================================
-- SEED DATA: ADDITIONAL USERS FOR TESTING
-- =====================================================

INSERT INTO lic_schema.users (
    user_id,
    phone_number,
    email,
    first_name,
    last_name,
    display_name,
    password_hash,
    role,
    phone_verified,
    status,
    created_at,
    updated_at
)
VALUES
    -- Additional test users
    ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20'::uuid, '+919876543220', 'senior_agent@test.com', 'Senior', 'Agent', 'Senior Agent', '$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO', 'senior_agent', true, 'active', NOW(), NOW()),
    ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21'::uuid, '+919876543221', 'regional_manager@test.com', 'Regional', 'Manager', 'Regional Manager', '$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO', 'regional_manager', true, 'active', NOW(), NOW()),
    ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22'::uuid, '+919876543222', 'provider_admin@test.com', 'Provider', 'Admin', 'Provider Admin', '$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO', 'insurance_provider_admin', true, 'active', NOW(), NOW()),
    ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23'::uuid, '+919876543223', 'customer3@test.com', 'Customer', 'Three', 'Customer Three', '$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO', 'policyholder', true, 'active', NOW(), NOW()),
    ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24'::uuid, '+919876543224', 'customer4@test.com', 'Customer', 'Four', 'Customer Four', '$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO', 'policyholder', true, 'active', NOW(), NOW())
ON CONFLICT (user_id) DO NOTHING;

-- =====================================================
-- SEED DATA: ADDITIONAL AGENTS
-- =====================================================

INSERT INTO lic_schema.agents (
    agent_id,
    user_id,
    provider_id,
    agent_code,
    license_number,
    business_name,
    business_address,
    territory,
    experience_years,
    specializations,
    commission_rate,
    status,
    verification_status,
    created_at,
    updated_at
)
VALUES
    ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20'::uuid, 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20'::uuid, '01fa8d3a-5509-4f73-abeb-617fd547f16d'::uuid, 'AGENT002', 'LIC234567', 'Senior Insurance Solutions', '{"city": "Mumbai", "state": "Maharashtra", "pincode": "400001"}'::jsonb, 'Mumbai Central', 8, ARRAY['life_insurance', 'health_insurance'], 5.5, 'active', 'approved', NOW(), NOW()),
    ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21'::uuid, 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21'::uuid, '01fa8d3a-5509-4f73-abeb-617fd547f16d'::uuid, 'AGENT003', 'LIC345678', 'Regional Insurance Hub', '{"city": "Pune", "state": "Maharashtra", "pincode": "411001"}'::jsonb, 'Pune Region', 12, ARRAY['term_life', 'ulip', 'retirement'], 7.0, 'active', 'approved', NOW(), NOW())
ON CONFLICT (agent_id) DO NOTHING;

-- =====================================================
-- SEED DATA: POLICYHOLDERS
-- =====================================================

INSERT INTO lic_schema.policyholders (
    policyholder_id,
    user_id,
    agent_id,
    customer_id,
    salutation,
    marital_status,
    occupation,
    annual_income,
    education_level,
    risk_profile,
    preferred_language,
    onboarding_status,
    created_at,
    updated_at
)
VALUES
    ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10'::uuid, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12'::uuid, 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'CUST001', 'Mr.', 'married', 'Software Engineer', 1200000.00, 'graduate', '{"risk_tolerance": "moderate", "investment_horizon": "long_term"}'::jsonb, 'en', 'completed', NOW(), NOW()),
    ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13'::uuid, 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'CUST002', 'Ms.', 'single', 'Teacher', 450000.00, 'post_graduate', '{"risk_tolerance": "conservative", "investment_horizon": "medium_term"}'::jsonb, 'hi', 'completed', NOW(), NOW()),
    ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12'::uuid, 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23'::uuid, 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20'::uuid, 'CUST003', 'Mr.', 'married', 'Doctor', 2500000.00, 'post_graduate', '{"risk_tolerance": "low", "investment_horizon": "short_term"}'::jsonb, 'en', 'completed', NOW(), NOW()),
    ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13'::uuid, 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24'::uuid, 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21'::uuid, 'CUST004', 'Mrs.', 'married', 'Business Owner', 800000.00, 'graduate', '{"risk_tolerance": "high", "investment_horizon": "long_term"}'::jsonb, 'hi', 'completed', NOW(), NOW())
ON CONFLICT (policyholder_id) DO NOTHING;

-- =====================================================
-- SEED DATA: INSURANCE POLICIES
-- =====================================================

INSERT INTO lic_schema.insurance_policies (
    policy_id,
    policy_number,
    policyholder_id,
    agent_id,
    provider_id,
    policy_type,
    plan_name,
    plan_code,
    category,
    sum_assured,
    premium_amount,
    premium_frequency,
    application_date,
    start_date,
    status,
    created_by,
    created_at,
    updated_at
)
VALUES
    ('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10'::uuid, 'POL001001', 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10'::uuid, 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '01fa8d3a-5509-4f73-abeb-617fd547f16d'::uuid, 'term_life', 'LIC Term Plan', 'TERM2024', 'life', 5000000.00, 15000.00, 'annual', CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE, 'active', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, NOW(), NOW()),
    ('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'POL001002', 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '01fa8d3a-5509-4f73-abeb-617fd547f16d'::uuid, 'health_insurance', 'LIC Health Shield', 'HEALTH2024', 'health', 300000.00, 8500.00, 'annual', CURRENT_DATE - INTERVAL '15 days', CURRENT_DATE, 'active', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, NOW(), NOW()),
    ('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12'::uuid, 'POL002001', 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12'::uuid, 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20'::uuid, '01fa8d3a-5509-4f73-abeb-617fd547f16d'::uuid, 'ulip', 'LIC ULIP Plan', 'ULIP2024', 'life', 2000000.00, 25000.00, 'annual', CURRENT_DATE - INTERVAL '20 days', CURRENT_DATE, 'pending_approval', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20'::uuid, NOW(), NOW()),
    ('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13'::uuid, 'POL003001', 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13'::uuid, 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21'::uuid, '01fa8d3a-5509-4f73-abeb-617fd547f16d'::uuid, 'retirement', 'LIC Retirement Plan', 'RETIRE2024', 'life', 10000000.00, 50000.00, 'annual', CURRENT_DATE - INTERVAL '10 days', CURRENT_DATE + INTERVAL '5 days', 'draft', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21'::uuid, NOW(), NOW()),
    ('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14'::uuid, 'POL001003', 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10'::uuid, 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '01fa8d3a-5509-4f73-abeb-617fd547f16d'::uuid, 'child_plan', 'LIC Child Plan', 'CHILD2024', 'life', 1000000.00, 12000.00, 'annual', CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE, 'approved', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, NOW(), NOW())
ON CONFLICT (policy_id) DO NOTHING;

-- =====================================================
-- SEED DATA: PREMIUM PAYMENTS
-- =====================================================

INSERT INTO lic_schema.premium_payments (
    payment_id,
    policy_id,
    policyholder_id,
    amount,
    payment_date,
    due_date,
    payment_method,
    status,
    created_at
)
VALUES
    (gen_random_uuid(), 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10'::uuid, 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10'::uuid, 15000.00, CURRENT_DATE - INTERVAL '1 day', CURRENT_DATE, 'online', 'completed', NOW()),
    (gen_random_uuid(), 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 8500.00, CURRENT_DATE - INTERVAL '2 days', CURRENT_DATE, 'bank_transfer', 'completed', NOW()),
    (gen_random_uuid(), 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12'::uuid, 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12'::uuid, 25000.00, CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days', 'online', 'pending', NOW())
ON CONFLICT (payment_id) DO NOTHING;

-- =====================================================
-- UPDATE AGENT PERFORMANCE METRICS
-- =====================================================

UPDATE lic_schema.agents
SET total_policies_sold = 3,
    total_premium_collected = 43500.00,
    active_policyholders = 2,
    customer_satisfaction_score = 4.5
WHERE agent_id = 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid;

UPDATE lic_schema.agents
SET total_policies_sold = 2,
    total_premium_collected = 75000.00,
    active_policyholders = 2,
    customer_satisfaction_score = 4.7
WHERE agent_id = 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20'::uuid;

UPDATE lic_schema.agents
SET total_policies_sold = 1,
    total_premium_collected = 50000.00,
    active_policyholders = 1,
    customer_satisfaction_score = 4.8
WHERE agent_id = 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21'::uuid;

-- =====================================================
-- NOTE: Feature flags table doesn't exist yet
-- This will be added in a future migration
-- =====================================================

-- =====================================================
-- SEED DATA: WHATSAPP TEMPLATES (additional for testing)
-- =====================================================

INSERT INTO shared.whatsapp_templates (
    template_name,
    category,
    language,
    content,
    variables,
    approval_status
)
VALUES
    ('payment_reminder', 'utility', 'en', 'Hi {{customer_name}}, your premium payment of ₹{{amount}} for policy {{policy_number}} is due on {{due_date}}. Please pay on time to avoid policy lapse.', '["customer_name", "amount", "policy_number", "due_date"]'::jsonb, 'approved'),
    ('policy_renewal_success', 'utility', 'en', 'Congratulations {{customer_name}}! Your policy {{policy_number}} has been successfully renewed. Coverage continues until {{end_date}}.', '["customer_name", "policy_number", "end_date"]'::jsonb, 'approved'),
    ('agent_callback_request', 'utility', 'en', 'Hi {{customer_name}}, {{agent_name}} from {{agency_name}} would like to discuss insurance options with you. Please call back at {{phone_number}}.', '["customer_name", "agent_name", "agency_name", "phone_number"]'::jsonb, 'approved')
ON CONFLICT (template_name) DO NOTHING;
