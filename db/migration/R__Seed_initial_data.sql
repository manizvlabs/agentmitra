-- Agent Mitra - Repeatable Migration: Seed Initial Data
-- This is a repeatable migration that seeds initial reference data
-- Run with: flyway migrate (will re-run if checksum changes)

-- =====================================================
-- SEED DATA: COUNTRIES
-- =====================================================

INSERT INTO shared.countries (country_code, country_name, currency_code, phone_code, timezone, status)
VALUES
    ('IND', 'India', 'INR', '+91', 'Asia/Kolkata', 'active'),
    ('USA', 'United States', 'USD', '+1', 'America/New_York', 'active'),
    ('GBR', 'United Kingdom', 'GBP', '+44', 'Europe/London', 'active')
ON CONFLICT (country_code) DO NOTHING;

-- =====================================================
-- SEED DATA: LANGUAGES
-- =====================================================

INSERT INTO shared.languages (language_code, language_name, native_name, rtl, status)
VALUES
    ('en', 'English', 'English', false, 'active'),
    ('hi', 'Hindi', 'हिन्दी', false, 'active'),
    ('te', 'Telugu', 'తెలుగు', false, 'active'),
    ('ta', 'Tamil', 'தமிழ்', false, 'active'),
    ('kn', 'Kannada', 'ಕನ್ನಡ', false, 'active'),
    ('mr', 'Marathi', 'मराठी', false, 'active'),
    ('gu', 'Gujarati', 'ગુજરાતી', false, 'active'),
    ('bn', 'Bengali', 'বাংলা', false, 'active'),
    ('ml', 'Malayalam', 'മലയാളം', false, 'active'),
    ('pa', 'Punjabi', 'ਪੰਜਾਬੀ', false, 'active')
ON CONFLICT (language_code) DO NOTHING;

-- =====================================================
-- SEED DATA: INSURANCE CATEGORIES
-- =====================================================

INSERT INTO shared.insurance_categories (category_code, category_name, category_type, description, status)
VALUES
    ('LIFE_TERM', 'Term Life Insurance', 'life', 'Pure life insurance coverage for a specific term period', 'active'),
    ('LIFE_WHOLE', 'Whole Life Insurance', 'life', 'Permanent life insurance with cash value accumulation', 'active'),
    ('LIFE_ULIP', 'Unit Linked Insurance Plan', 'life', 'Combination of insurance and investment', 'active'),
    ('HEALTH_INDIVIDUAL', 'Individual Health Insurance', 'health', 'Health coverage for individuals', 'active'),
    ('HEALTH_FAMILY', 'Family Health Insurance', 'health', 'Health coverage for entire family', 'active'),
    ('HEALTH_SENIOR', 'Senior Citizen Health Insurance', 'health', 'Health coverage for senior citizens', 'active'),
    ('CHILD_PLAN', 'Child Plan', 'life', 'Savings and insurance plan for children', 'active'),
    ('RETIREMENT', 'Retirement Plan', 'life', 'Pension and retirement savings plan', 'active'),
    ('MOTOR', 'Motor Insurance', 'general', 'Vehicle insurance coverage', 'active'),
    ('TRAVEL', 'Travel Insurance', 'general', 'Travel and medical coverage during trips', 'active')
ON CONFLICT (category_code) DO NOTHING;

-- =====================================================
-- SEED DATA: INSURANCE PROVIDERS
-- =====================================================

INSERT INTO shared.insurance_providers (
    provider_code,
    provider_name,
    provider_type,
    description,
    license_number,
    regulatory_authority,
    established_year,
    headquarters,
    supported_languages,
    status,
    integration_status
)
VALUES
    (
        'LIC',
        'Life Insurance Corporation of India',
        'life_insurance',
        'Largest life insurance company in India',
        'LIC-001',
        'IRDAI',
        1956,
        '{"city": "Mumbai", "state": "Maharashtra", "country": "India"}'::jsonb,
        ARRAY['en', 'hi', 'te', 'ta', 'kn', 'mr', 'gu', 'bn', 'ml', 'pa'],
        'active',
        'pending'
    ),
    (
        'HDFC_LIFE',
        'HDFC Life Insurance Company',
        'life_insurance',
        'Leading private life insurance provider',
        'HDFC-001',
        'IRDAI',
        2000,
        '{"city": "Mumbai", "state": "Maharashtra", "country": "India"}'::jsonb,
        ARRAY['en', 'hi'],
        'active',
        'pending'
    ),
    (
        'ICICI_PRUDENTIAL',
        'ICICI Prudential Life Insurance',
        'life_insurance',
        'Joint venture between ICICI Bank and Prudential',
        'ICICI-001',
        'IRDAI',
        2000,
        '{"city": "Mumbai", "state": "Maharashtra", "country": "India"}'::jsonb,
        ARRAY['en', 'hi'],
        'active',
        'pending'
    )
ON CONFLICT (provider_code) DO NOTHING;

-- =====================================================
-- SEED DATA: DEFAULT TENANT (LIC)
-- =====================================================

INSERT INTO shared.tenants (
    tenant_code,
    tenant_name,
    tenant_type,
    schema_name,
    status,
    subscription_plan,
    max_users,
    storage_limit_gb,
    api_rate_limit
)
VALUES
    (
        'LIC',
        'Life Insurance Corporation of India',
        'insurance_provider',
        'lic_schema',
        'active',
        'enterprise',
        10000,
        1000,
        10000
    )
ON CONFLICT (tenant_code) DO NOTHING;

-- =====================================================
-- SEED DATA: DEFAULT ROLES
-- =====================================================

INSERT INTO lic_schema.roles (role_name, role_description, is_system_role, permissions)
VALUES
    (
        'super_admin',
        'Super Administrator with full system access',
        true,
        '["*"]'::jsonb
    ),
    (
        'insurance_provider_admin',
        'Insurance Provider Administrator',
        true,
        '["users.*", "agents.*", "policies.*", "reports.*"]'::jsonb
    ),
    (
        'regional_manager',
        'Regional Manager',
        true,
        '["agents.read", "agents.update", "policies.read", "reports.read"]'::jsonb
    ),
    (
        'senior_agent',
        'Senior Insurance Agent',
        true,
        '["policies.create", "policies.read", "policies.update", "customers.*"]'::jsonb
    ),
    (
        'junior_agent',
        'Junior Insurance Agent',
        true,
        '["policies.read", "customers.read"]'::jsonb
    ),
    (
        'policyholder',
        'Policyholder/Customer',
        true,
        '["policies.read", "payments.create", "payments.read"]'::jsonb
    ),
    (
        'support_staff',
        'Customer Support Staff',
        true,
        '["customers.read", "policies.read", "tickets.*"]'::jsonb
    ),
    (
        'guest',
        'Guest User',
        true,
        '["policies.read"]'::jsonb
    )
ON CONFLICT (role_name) DO NOTHING;

-- =====================================================
-- SEED DATA: DEFAULT PERMISSIONS
-- =====================================================

INSERT INTO lic_schema.permissions (permission_name, permission_description, resource_type, action)
VALUES
    ('users.create', 'Create users', 'user', 'create'),
    ('users.read', 'Read users', 'user', 'read'),
    ('users.update', 'Update users', 'user', 'update'),
    ('users.delete', 'Delete users', 'user', 'delete'),
    ('agents.create', 'Create agents', 'agent', 'create'),
    ('agents.read', 'Read agents', 'agent', 'read'),
    ('agents.update', 'Update agents', 'agent', 'update'),
    ('policies.create', 'Create policies', 'policy', 'create'),
    ('policies.read', 'Read policies', 'policy', 'read'),
    ('policies.update', 'Update policies', 'policy', 'update'),
    ('policies.delete', 'Delete policies', 'policy', 'delete'),
    ('customers.create', 'Create customers', 'customer', 'create'),
    ('customers.read', 'Read customers', 'customer', 'read'),
    ('customers.update', 'Update customers', 'customer', 'update'),
    ('payments.create', 'Create payments', 'payment', 'create'),
    ('payments.read', 'Read payments', 'payment', 'read'),
    ('reports.read', 'Read reports', 'report', 'read'),
    ('presentations.create', 'Create presentations', 'presentation', 'create'),
    ('presentations.read', 'Read presentations', 'presentation', 'read'),
    ('presentations.update', 'Update presentations', 'presentation', 'update'),
    ('presentations.publish', 'Publish presentations', 'presentation', 'publish')
ON CONFLICT (permission_name) DO NOTHING;

-- =====================================================
-- SEED DATA: WHATSAPP TEMPLATES
-- =====================================================

INSERT INTO shared.whatsapp_templates (template_name, category, language, content, variables, approval_status)
VALUES
    (
        'policy_renewal_reminder',
        'utility',
        'en',
        'Dear {{customer_name}}, Your policy {{policy_number}} is due for renewal on {{renewal_date}}. Please renew to continue coverage. Contact your agent {{agent_name}} at {{agent_phone}}.',
        '["customer_name", "policy_number", "renewal_date", "agent_name", "agent_phone"]'::jsonb,
        'pending'
    ),
    (
        'premium_payment_reminder',
        'utility',
        'en',
        'Hello {{customer_name}}, Your premium payment of ₹{{amount}} for policy {{policy_number}} is due on {{due_date}}. Please pay to avoid policy lapse.',
        '["customer_name", "amount", "policy_number", "due_date"]'::jsonb,
        'pending'
    ),
    (
        'policy_approval_notification',
        'utility',
        'en',
        'Congratulations {{customer_name}}! Your policy {{policy_number}} has been approved. Policy document will be sent to your registered email.',
        '["customer_name", "policy_number"]'::jsonb,
        'pending'
    )
ON CONFLICT (template_name) DO NOTHING;

