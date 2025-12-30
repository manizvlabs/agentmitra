-- Agent Mitra - Migration V71: Add LIC Tenant
-- This migration adds the Life Insurance Corporation of India as a primary insurance provider tenant

INSERT INTO lic_schema.tenants (
    tenant_id,
    tenant_code,
    tenant_name,
    tenant_type,
    status,
    subscription_plan,
    max_users,
    storage_limit_gb,
    api_rate_limit,
    contact_email,
    business_address,
    regulatory_approvals,
    metadata,
    created_at,
    updated_at
) VALUES (
    '11111111-1111-1111-1111-111111111111'::uuid,
    'LIC',
    'Life Insurance Corporation of India',
    'insurance_provider',
    'active',
    'enterprise',
    10000,
    1000,
    100000,
    'contact@licindia.com',
    '{"street": "Yogakshema, Jeevan Bima Marg", "city": "Mumbai", "state": "Maharashtra", "country": "India", "pincode": "400021"}',
    '{"irdai_approved": true, "licence_number": "LIC001", "compliance_status": "active"}',
    '{"description": "India''s largest life insurance company", "website": "https://www.licindia.in", "established": "1956"}',
    NOW(),
    NOW()
) ON CONFLICT (tenant_id) DO NOTHING;
