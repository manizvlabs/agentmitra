-- Seed comprehensive business data aligned with API requirements
-- This migration creates realistic insurance business data for testing

-- =====================================================
-- STEP 1: Seed Insurance Products
-- =====================================================

INSERT INTO lic_schema.insurance_products (
    product_id,
    tenant_id,
    name,
    type,
    category,
    coverage_amount,
    premium_range_min,
    premium_range_max,
    description,
    features,
    terms_conditions,
    is_active,
    created_at,
    updated_at
) VALUES
    -- Life Insurance Products
    (
        'prod-life-term-001'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        'Term Life Secure',
        'life',
        'term_life',
        5000000,
        1000,
        5000,
        'Comprehensive term life insurance coverage for 20-30 years',
        '["Death Benefit", "Terminal Illness Rider", "Accidental Death Benefit"]'::jsonb,
        'Standard term life insurance terms apply',
        true,
        NOW(),
        NOW()
    ),
    (
        'prod-life-whole-001'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        'Whole Life Plus',
        'life',
        'whole_life',
        10000000,
        5000,
        25000,
        'Permanent life insurance with cash value accumulation',
        '["Death Benefit", "Cash Value", "Loan Facility", "Guaranteed Surrender Value"]'::jsonb,
        'Whole life insurance terms apply',
        true,
        NOW(),
        NOW()
    ),

    -- Health Insurance Products
    (
        'prod-health-ind-001'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        'Health Shield Individual',
        'health',
        'individual_health',
        500000,
        3000,
        15000,
        'Comprehensive individual health insurance coverage',
        '["Hospitalization", "Day Care Procedures", "Ambulance Cover", "Emergency Assistance"]'::jsonb,
        'Individual health insurance terms apply',
        true,
        NOW(),
        NOW()
    ),
    (
        'prod-health-fam-001'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        'Family Health Protect',
        'health',
        'family_health',
        1000000,
        5000,
        30000,
        'Complete family health insurance coverage',
        '["Family Coverage", "Maternity Benefits", "Child Education Fund", "Critical Illness Cover"]'::jsonb,
        'Family floater health insurance terms apply',
        true,
        NOW(),
        NOW()
    ),

    -- Vehicle Insurance Products
    (
        'prod-vehicle-comp-001'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        'Vehicle Complete Protect',
        'vehicle',
        'comprehensive_vehicle',
        2000000,
        2000,
        10000,
        'Comprehensive vehicle insurance with all risks covered',
        '["Third Party Liability", "Own Damage", "Theft Protection", "Natural Calamities", "24/7 Assistance"]'::jsonb,
        'Comprehensive vehicle insurance terms apply',
        true,
        NOW(),
        NOW()
    )
ON CONFLICT (product_id) DO NOTHING;

-- =====================================================
-- STEP 2: Seed Sample Policies
-- =====================================================

INSERT INTO lic_schema.insurance_policies (
    policy_id,
    tenant_id,
    policy_number,
    product_id,
    policyholder_id,
    agent_id,
    status,
    premium_amount,
    coverage_amount,
    start_date,
    end_date,
    payment_frequency,
    next_premium_due,
    created_at,
    updated_at
) VALUES
    -- Policies for the seeded policyholder
    (
        'pol-001-1001'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        'POL0011001',
        'prod-life-term-001'::uuid,
        '770e8400-e29b-41d4-a716-446655440005'::uuid,
        '660e8400-e29b-41d4-a716-446655440003'::uuid,
        'active',
        25000,
        5000000,
        CURRENT_DATE,
        CURRENT_DATE + INTERVAL '20 years',
        'annual',
        CURRENT_DATE + INTERVAL '1 year',
        NOW(),
        NOW()
    ),
    (
        'pol-001-1002'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        'POL0011002',
        'prod-health-fam-001'::uuid,
        '770e8400-e29b-41d4-a716-446655440005'::uuid,
        '660e8400-e29b-41d4-a716-446655440003'::uuid,
        'active',
        15000,
        1000000,
        CURRENT_DATE,
        CURRENT_DATE + INTERVAL '1 year',
        'annual',
        CURRENT_DATE + INTERVAL '1 year',
        NOW(),
        NOW()
    ),

    -- Additional sample policies
    (
        'pol-002-2001'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        'POL0022001',
        'prod-life-whole-001'::uuid,
        NULL, -- No specific policyholder
        '660e8400-e29b-41d4-a716-446655440003'::uuid,
        'active',
        18000,
        10000000,
        CURRENT_DATE - INTERVAL '1 year',
        CURRENT_DATE + INTERVAL '19 years',
        'annual',
        CURRENT_DATE + INTERVAL '11 months',
        NOW() - INTERVAL '1 year',
        NOW()
    )
ON CONFLICT (policy_id) DO NOTHING;

-- =====================================================
-- STEP 3: Seed Premium Payments
-- =====================================================

INSERT INTO lic_schema.premium_payments (
    payment_id,
    tenant_id,
    policy_id,
    policyholder_id,
    amount,
    payment_date,
    due_date,
    payment_method,
    transaction_id,
    payment_gateway,
    status,
    payment_details,
    created_at
) VALUES
    -- Payments for the first policy
    (
        'pay-001-1001'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        'pol-001-1001'::uuid,
        '770e8400-e29b-41d4-a716-446655440005'::uuid,
        25000,
        CURRENT_DATE,
        CURRENT_DATE,
        'online',
        'TXN0011001',
        'razorpay',
        'completed',
        '{"gateway_response": {"order_id": "order_0011001", "payment_id": "pay_0011001"}}'::jsonb,
        NOW()
    ),
    (
        'pay-001-1002'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        'pol-001-1002'::uuid,
        '770e8400-e29b-41d4-a716-446655440005'::uuid,
        15000,
        CURRENT_DATE,
        CURRENT_DATE,
        'online',
        'TXN0011002',
        'razorpay',
        'completed',
        '{"gateway_response": {"order_id": "order_0011002", "payment_id": "pay_0011002"}}'::jsonb,
        NOW()
    ),

    -- Payment for the second policy
    (
        'pay-002-2001'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        'pol-002-2001'::uuid,
        NULL,
        18000,
        CURRENT_DATE - INTERVAL '1 year',
        CURRENT_DATE - INTERVAL '1 year',
        'bank_transfer',
        'TXN0022001',
        NULL,
        'completed',
        '{"bank_reference": "BTR0022001"}'::jsonb,
        NOW() - INTERVAL '1 year'
    )
ON CONFLICT (payment_id) DO NOTHING;

-- =====================================================
-- STEP 4: Seed Sample Leads
-- =====================================================

INSERT INTO lic_schema.leads (
    lead_id,
    tenant_id,
    agent_id,
    first_name,
    last_name,
    phone_number,
    email,
    source,
    status,
    priority,
    estimated_value,
    requirements,
    follow_up_date,
    notes,
    converted_policy_id,
    created_at,
    updated_at
) VALUES
    -- Leads for senior agent
    (
        'lead-001-3001'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        '660e8400-e29b-41d4-a716-446655440003'::uuid,
        'Amit',
        'Patel',
        '+919876543210',
        'amit.patel@email.com',
        'website',
        'qualified',
        'high',
        50000,
        '["Life Insurance", "Health Insurance"]'::jsonb,
        CURRENT_DATE + INTERVAL '3 days',
        'Interested in family coverage',
        NULL,
        NOW(),
        NOW()
    ),
    (
        'lead-001-3002'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        '660e8400-e29b-41d4-a716-446655440003'::uuid,
        'Priya',
        'Sharma',
        '+919876543211',
        'priya.sharma@email.com',
        'referral',
        'contacted',
        'medium',
        25000,
        '["Vehicle Insurance"]'::jsonb,
        CURRENT_DATE + INTERVAL '1 week',
        'Referred by existing customer',
        NULL,
        NOW(),
        NOW()
    ),

    -- Leads for junior agent
    (
        'lead-002-4001'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        '660e8400-e29b-41d4-a716-446655440004'::uuid,
        'Rahul',
        'Verma',
        '+919876543212',
        'rahul.verma@email.com',
        'cold_call',
        'new',
        'low',
        15000,
        '["Term Life Insurance"]'::jsonb,
        CURRENT_DATE + INTERVAL '2 weeks',
        'First contact made',
        NULL,
        NOW(),
        NOW()
    )
ON CONFLICT (lead_id) DO NOTHING;

-- =====================================================
-- STEP 5: Seed Analytics Data
-- =====================================================

INSERT INTO lic_schema.customer_retention_analytics (
    retention_id,
    tenant_id,
    customer_id,
    risk_level,
    risk_score,
    churn_probability,
    risk_factors,
    engagement_score,
    last_policy_renewal,
    next_renewal_due,
    lifetime_value,
    created_at,
    updated_at
) VALUES
    (
        'ret-001-5001'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        '770e8400-e29b-41d4-a716-446655440005'::uuid,
        'low',
        15.5,
        0.05,
        '["Regular payments", "Multiple policies", "Long-term customer"]'::jsonb,
        85.0,
        CURRENT_DATE,
        CURRENT_DATE + INTERVAL '1 year',
        125000.00,
        NOW(),
        NOW()
    )
ON CONFLICT (retention_id) DO NOTHING;

-- =====================================================
-- STEP 6: Seed Sample Quotes
-- =====================================================

INSERT INTO lic_schema.quotes (
    quote_id,
    tenant_id,
    agent_id,
    customer_name,
    customer_email,
    customer_phone,
    product_type,
    coverage_amount,
    premium_amount,
    quote_details,
    valid_until,
    status,
    created_at,
    updated_at
) VALUES
    (
        'quote-001-6001'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        '660e8400-e29b-41d4-a716-446655440003'::uuid,
        'Vikram Singh',
        'vikram.singh@email.com',
        '+919876543213',
        'life',
        3000000,
        18000,
        '{"product": "Term Life Secure", "term": 25, "benefits": ["Death benefit", "Terminal illness"]}'::jsonb,
        CURRENT_DATE + INTERVAL '30 days',
        'sent',
        NOW(),
        NOW()
    ),
    (
        'quote-001-6002'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        '660e8400-e29b-41d4-a716-446655440004'::uuid,
        'Anjali Gupta',
        'anjali.gupta@email.com',
        '+919876543214',
        'health',
        500000,
        8000,
        '{"product": "Health Shield Individual", "sum_insured": 500000, "deductible": 1000}'::jsonb,
        CURRENT_DATE + INTERVAL '15 days',
        'draft',
        NOW(),
        NOW()
    )
ON CONFLICT (quote_id) DO NOTHING;

-- =====================================================
-- STEP 7: Seed Daily Quotes for Testing
-- =====================================================

INSERT INTO public.daily_quotes (
    quote_id,
    agent_id,
    quote_text,
    author,
    category,
    tags,
    is_active,
    created_at,
    updated_at
) VALUES
    (
        'dquote-001-7001'::uuid,
        '550e8400-e29b-41d4-a716-446655440003'::uuid,
        'Success is not final, failure is not fatal: It is the courage to continue that counts.',
        'Winston Churchill',
        'motivation',
        '["success", "failure", "courage"]'::jsonb,
        true,
        NOW(),
        NOW()
    ),
    (
        'dquote-001-7002'::uuid,
        '550e8400-e29b-41d4-a716-446655440004'::uuid,
        'The only way to do great work is to love what you do.',
        'Steve Jobs',
        'career',
        '["work", "passion", "excellence"]'::jsonb,
        true,
        NOW(),
        NOW()
    )
ON CONFLICT (quote_id) DO NOTHING;

-- =====================================================
-- VERIFICATION: Count seeded records
-- =====================================================

DO $$
DECLARE
    product_count INTEGER;
    policy_count INTEGER;
    payment_count INTEGER;
    lead_count INTEGER;
    retention_count INTEGER;
    quote_count INTEGER;
    daily_quote_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO product_count FROM lic_schema.insurance_products;
    SELECT COUNT(*) INTO policy_count FROM lic_schema.insurance_policies;
    SELECT COUNT(*) INTO payment_count FROM lic_schema.premium_payments;
    SELECT COUNT(*) INTO lead_count FROM lic_schema.leads;
    SELECT COUNT(*) INTO retention_count FROM lic_schema.customer_retention_analytics;
    SELECT COUNT(*) INTO quote_count FROM lic_schema.quotes;
    SELECT COUNT(*) INTO daily_quote_count FROM public.daily_quotes;

    RAISE NOTICE 'Seeded: % products, % policies, % payments, % leads, % retention records, % quotes, % daily quotes',
        product_count, policy_count, payment_count, lead_count, retention_count, quote_count, daily_quote_count;
END $$;
