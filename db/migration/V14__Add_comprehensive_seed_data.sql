-- Agent Mitra - Migration V14: Add Comprehensive Seed Data
-- This migration ensures all remaining tables in lic_schema have at least 10 records
-- Data is inserted in dependency order to maintain referential integrity

DO $$
DECLARE
    current_count INTEGER;
    i INTEGER;
BEGIN
    RAISE NOTICE 'Starting V17 migration: Adding comprehensive seed data...';

    -- =====================================================
    -- AGENTS - Depend on users and insurance_providers
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.agents;
    IF current_count < 10 THEN
        INSERT INTO lic_schema.agents (
            agent_code, user_id, provider_id, license_number,
            license_expiry_date, territory, business_name, status, commission_rate,
            total_policies_sold, total_premium_collected, created_at, updated_at
        ) VALUES
        ('SEED_AG001', (SELECT user_id FROM lic_schema.users WHERE email = 'seed_user_3@agentmitra.com'), (SELECT provider_id FROM lic_schema.insurance_providers WHERE provider_code = 'SEED_LIC'), 'LIC_SEED_001', NOW() + INTERVAL '1 year', 'Mumbai', 'Seed Agency 1', 'active', 5.0, 25, 500000, NOW() - INTERVAL '60 days', NOW()),
        ('SEED_AG002', (SELECT user_id FROM lic_schema.users WHERE email = 'seed_user_4@agentmitra.com'), (SELECT provider_id FROM lic_schema.insurance_providers WHERE provider_code = 'SEED_HDFC'), 'HDFC_SEED_002', NOW() + INTERVAL '1 year', 'Delhi', 'Seed Agency 2', 'active', 7.5, 45, 900000, NOW() - INTERVAL '55 days', NOW()),
        ('SEED_AG003', (SELECT user_id FROM lic_schema.users WHERE email = 'seed_user_7@agentmitra.com'), (SELECT provider_id FROM lic_schema.insurance_providers WHERE provider_code = 'SEED_ICICI'), 'ICICI_SEED_003', NOW() + INTERVAL '1 year', 'Bangalore', 'Seed Agency 3', 'active', 10.0, 80, 1600000, NOW() - INTERVAL '50 days', NOW()),
        ('SEED_AG004', (SELECT user_id FROM lic_schema.users WHERE email = 'seed_user_8@agentmitra.com'), (SELECT provider_id FROM lic_schema.insurance_providers WHERE provider_code = 'SEED_BAJAJ'), 'BAJAJ_SEED_004', NOW() + INTERVAL '1 year', 'Chennai', 'Seed Agency 4', 'active', 4.5, 15, 300000, NOW() - INTERVAL '45 days', NOW()),
        ('SEED_AG005', (SELECT user_id FROM lic_schema.users WHERE email = 'seed_user_3@agentmitra.com'), (SELECT provider_id FROM lic_schema.insurance_providers WHERE provider_code = 'SEED_SBI'), 'SBI_SEED_005', NOW() + INTERVAL '1 year', 'Pune', 'Seed Agency 5', 'active', 6.5, 35, 700000, NOW() - INTERVAL '40 days', NOW()),
        ('SEED_AG006', (SELECT user_id FROM lic_schema.users WHERE email = 'seed_user_4@agentmitra.com'), (SELECT provider_id FROM lic_schema.insurance_providers WHERE provider_code = 'SEED_TATA'), 'TATA_SEED_006', NOW() + INTERVAL '1 year', 'Hyderabad', 'Seed Agency 6', 'active', 5.5, 28, 560000, NOW() - INTERVAL '35 days', NOW()),
        ('SEED_AG007', (SELECT user_id FROM lic_schema.users WHERE email = 'seed_user_7@agentmitra.com'), (SELECT provider_id FROM lic_schema.insurance_providers WHERE provider_code = 'SEED_MAX'), 'MAX_SEED_007', NOW() + INTERVAL '1 year', 'Kolkata', 'Seed Agency 7', 'active', 8.5, 65, 1300000, NOW() - INTERVAL '30 days', NOW()),
        ('SEED_AG008', (SELECT user_id FROM lic_schema.users WHERE email = 'seed_user_8@agentmitra.com'), (SELECT provider_id FROM lic_schema.insurance_providers WHERE provider_code = 'SEED_PNB'), 'PNB_SEED_008', NOW() + INTERVAL '1 year', 'Ahmedabad', 'Seed Agency 8', 'active', 7.0, 42, 840000, NOW() - INTERVAL '25 days', NOW()),
        ('SEED_AG009', (SELECT user_id FROM lic_schema.users WHERE email = 'seed_user_3@agentmitra.com'), (SELECT provider_id FROM lic_schema.insurance_providers WHERE provider_code = 'SEED_ADITYA'), 'ADITYA_SEED_009', NOW() + INTERVAL '1 year', 'Jaipur', 'Seed Agency 9', 'active', 5.0, 22, 440000, NOW() - INTERVAL '20 days', NOW()),
        ('SEED_AG010', (SELECT user_id FROM lic_schema.users WHERE email = 'seed_user_4@agentmitra.com'), (SELECT provider_id FROM lic_schema.insurance_providers WHERE provider_code = 'SEED_KOTAK'), 'KOTAK_SEED_010', NOW() + INTERVAL '1 year', 'Surat', 'Seed Agency 10', 'active', 6.0, 38, 760000, NOW() - INTERVAL '15 days', NOW())
        ON CONFLICT (agent_code) DO NOTHING;
        RAISE NOTICE 'Added agents data';
    END IF;

    -- =====================================================
    -- POLICYHOLDERS - Depend on users and agents
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.policyholders;
    IF current_count < 10 THEN
        INSERT INTO lic_schema.policyholders (
            user_id, agent_id, customer_id, salutation, marital_status, occupation,
            annual_income, family_members, communication_preferences
        ) VALUES
        ((SELECT user_id FROM lic_schema.users WHERE email = 'seed_user_1@agentmitra.com'), (SELECT agent_id FROM lic_schema.agents WHERE agent_code = 'SEED_AG001'), 'SEED_CUST001', 'Mr.', 'Married', 'Software Engineer', 1200000, '[{"name": "Mrs. Seed User1", "relation": "Spouse"}]', '{"email": true, "sms": true, "whatsapp": true, "calls": false}'),
        ((SELECT user_id FROM lic_schema.users WHERE email = 'seed_user_2@agentmitra.com'), (SELECT agent_id FROM lic_schema.agents WHERE agent_code = 'SEED_AG002'), 'SEED_CUST002', 'Mrs.', 'Single', 'Doctor', 1800000, '[]', '{"email": true, "sms": false, "whatsapp": true, "calls": true}'),
        ((SELECT user_id FROM lic_schema.users WHERE email = 'seed_user_5@agentmitra.com'), (SELECT agent_id FROM lic_schema.agents WHERE agent_code = 'SEED_AG003'), 'SEED_CUST003', 'Mr.', 'Married', 'Business Owner', 2500000, '[{"name": "Mrs. Seed User5", "relation": "Spouse"}, {"name": "Seed Child1", "relation": "Son", "age": 12}]', '{"email": true, "sms": true, "whatsapp": false, "calls": true}'),
        ((SELECT user_id FROM lic_schema.users WHERE email = 'seed_user_6@agentmitra.com'), (SELECT agent_id FROM lic_schema.agents WHERE agent_code = 'SEED_AG004'), 'SEED_CUST004', 'Mr.', 'Married', 'Teacher', 800000, '[{"name": "Mrs. Seed User6", "relation": "Spouse"}]', '{"email": false, "sms": true, "whatsapp": true, "calls": true}'),
        ((SELECT user_id FROM lic_schema.users WHERE email = 'seed_user_9@agentmitra.com'), (SELECT agent_id FROM lic_schema.agents WHERE agent_code = 'SEED_AG005'), 'SEED_CUST005', 'Mrs.', 'Widowed', 'Retired', 400000, '[{"name": "Seed Son1", "relation": "Son"}]', '{"email": false, "sms": true, "whatsapp": true, "calls": false}'),
        ((SELECT user_id FROM lic_schema.users WHERE email = 'seed_user_10@agentmitra.com'), (SELECT agent_id FROM lic_schema.agents WHERE agent_code = 'SEED_AG006'), 'SEED_CUST006', 'Mr.', 'Married', 'Accountant', 1500000, '[{"name": "Mrs. Seed User10", "relation": "Spouse"}, {"name": "Seed Daughter1", "relation": "Daughter", "age": 8}]', '{"email": true, "sms": true, "whatsapp": true, "calls": true}'),
        ((SELECT user_id FROM lic_schema.users WHERE email = 'seed_user_1@agentmitra.com'), (SELECT agent_id FROM lic_schema.agents WHERE agent_code = 'SEED_AG007'), 'SEED_CUST007', 'Mr.', 'Single', 'Engineer', 1000000, '[]', '{"email": true, "sms": false, "whatsapp": true, "calls": false}'),
        ((SELECT user_id FROM lic_schema.users WHERE email = 'seed_user_2@agentmitra.com'), (SELECT agent_id FROM lic_schema.agents WHERE agent_code = 'SEED_AG008'), 'SEED_CUST008', 'Mrs.', 'Married', 'Lawyer', 2000000, '[{"name": "Mr. Seed User2", "relation": "Spouse"}]', '{"email": true, "sms": true, "whatsapp": false, "calls": true}'),
        ((SELECT user_id FROM lic_schema.users WHERE email = 'seed_user_5@agentmitra.com'), (SELECT agent_id FROM lic_schema.agents WHERE agent_code = 'SEED_AG009'), 'SEED_CUST009', 'Mr.', 'Married', 'Manager', 1600000, '[{"name": "Mrs. Seed User5", "relation": "Spouse"}]', '{"email": true, "sms": true, "whatsapp": true, "calls": false}'),
        ((SELECT user_id FROM lic_schema.users WHERE email = 'seed_user_6@agentmitra.com'), (SELECT agent_id FROM lic_schema.agents WHERE agent_code = 'SEED_AG010'), 'SEED_CUST010', 'Mrs.', 'Single', 'Consultant', 2200000, '[]', '{"email": true, "sms": false, "whatsapp": true, "calls": true}')
        ;
        RAISE NOTICE 'Added policyholders data';
    END IF;

    -- =====================================================
    -- INSURANCE POLICIES - Depend on policyholders, agents, providers
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.insurance_policies;
    IF current_count < 10 THEN
        INSERT INTO lic_schema.insurance_policies (
            policy_number, policyholder_id, agent_id, provider_id, policy_type,
            plan_name, sum_assured, premium_amount, premium_frequency, application_date,
            start_date, status, coverage_details
        ) VALUES
        ('SEED_POL001', (SELECT policyholder_id FROM lic_schema.policyholders WHERE customer_id = 'SEED_CUST001'), (SELECT agent_id FROM lic_schema.agents WHERE agent_code = 'SEED_AG001'), (SELECT provider_id FROM lic_schema.insurance_providers WHERE provider_code = 'LIC'), 'term_life', 'Seed Term Plan', 5000000, 25000, 'annual', NOW() - INTERVAL '30 days', NOW() - INTERVAL '20 days', 'active', '{"riders": ["Critical Illness"], "term": 20}'),
        ('SEED_POL002', (SELECT policyholder_id FROM lic_schema.policyholders WHERE customer_id = 'SEED_CUST002'), (SELECT agent_id FROM lic_schema.agents WHERE agent_code = 'SEED_AG002'), (SELECT provider_id FROM lic_schema.insurance_providers WHERE provider_code = 'HDFC_LIFE'), 'whole_life', 'Seed Whole Life', 3000000, 30000, 'annual', NOW() - INTERVAL '25 days', NOW() - INTERVAL '15 days', 'active', '{"riders": ["Waiver of Premium"], "term": 30}'),
        ('SEED_POL003', (SELECT policyholder_id FROM lic_schema.policyholders WHERE customer_id = 'SEED_CUST003'), (SELECT agent_id FROM lic_schema.agents WHERE agent_code = 'SEED_AG003'), (SELECT provider_id FROM lic_schema.insurance_providers WHERE provider_code = 'ICICI_PRUDENTIAL'), 'ulip', 'Seed ULIP', 4000000, 35000, 'annual', NOW() - INTERVAL '20 days', NOW() - INTERVAL '10 days', 'active', '{"funds": ["Equity", "Debt"], "term": 15}'),
        ('SEED_POL004', (SELECT policyholder_id FROM lic_schema.policyholders WHERE customer_id = 'SEED_CUST004'), (SELECT agent_id FROM lic_schema.agents WHERE agent_code = 'SEED_AG004'), (SELECT provider_id FROM lic_schema.insurance_providers WHERE provider_code = 'LIC'), 'endowment', 'Seed Endowment', 2000000, 20000, 'annual', NOW() - INTERVAL '15 days', NOW() - INTERVAL '5 days', 'active', '{"riders": ["Accidental Death"], "term": 25}'),
        ('SEED_POL005', (SELECT policyholder_id FROM lic_schema.policyholders WHERE customer_id = 'SEED_CUST005'), (SELECT agent_id FROM lic_schema.agents WHERE agent_code = 'SEED_AG005'), (SELECT provider_id FROM lic_schema.insurance_providers WHERE provider_code = 'HDFC_LIFE'), 'term_life', 'Seed Term Plus', 2500000, 15000, 'annual', NOW() - INTERVAL '10 days', NOW(), 'active', '{"riders": [], "term": 15}'),
        ('SEED_POL006', (SELECT policyholder_id FROM lic_schema.policyholders WHERE customer_id = 'SEED_CUST006'), (SELECT agent_id FROM lic_schema.agents WHERE agent_code = 'SEED_AG006'), (SELECT provider_id FROM lic_schema.insurance_providers WHERE provider_code = 'ICICI_PRUDENTIAL'), 'whole_life', 'Seed Whole Plus', 3500000, 28000, 'annual', NOW() - INTERVAL '35 days', NOW() - INTERVAL '25 days', 'active', '{"riders": ["Critical Illness", "Waiver"], "term": 25}'),
        ('SEED_POL007', (SELECT policyholder_id FROM lic_schema.policyholders WHERE customer_id = 'SEED_CUST007'), (SELECT agent_id FROM lic_schema.agents WHERE agent_code = 'SEED_AG007'), (SELECT provider_id FROM lic_schema.insurance_providers WHERE provider_code = 'LIC'), 'ulip', 'Seed ULIP Pro', 4500000, 40000, 'annual', NOW() - INTERVAL '40 days', NOW() - INTERVAL '30 days', 'active', '{"funds": ["Equity", "Balanced"], "term": 20}'),
        ('SEED_POL008', (SELECT policyholder_id FROM lic_schema.policyholders WHERE customer_id = 'SEED_CUST008'), (SELECT agent_id FROM lic_schema.agents WHERE agent_code = 'SEED_AG008'), (SELECT provider_id FROM lic_schema.insurance_providers WHERE provider_code = 'HDFC_LIFE'), 'endowment', 'Seed Endowment Plus', 3000000, 25000, 'annual', NOW() - INTERVAL '45 days', NOW() - INTERVAL '35 days', 'active', '{"riders": ["Critical Illness"], "term": 30}'),
        ('SEED_POL009', (SELECT policyholder_id FROM lic_schema.policyholders WHERE customer_id = 'SEED_CUST009'), (SELECT agent_id FROM lic_schema.agents WHERE agent_code = 'SEED_AG009'), (SELECT provider_id FROM lic_schema.insurance_providers WHERE provider_code = 'ICICI_PRUDENTIAL'), 'term_life', 'Seed Term Elite', 6000000, 35000, 'annual', NOW() - INTERVAL '50 days', NOW() - INTERVAL '40 days', 'active', '{"riders": ["Critical Illness", "Waiver", "Accidental Death"], "term": 25}'),
        ('SEED_POL010', (SELECT policyholder_id FROM lic_schema.policyholders WHERE customer_id = 'SEED_CUST010'), (SELECT agent_id FROM lic_schema.agents WHERE agent_code = 'SEED_AG010'), (SELECT provider_id FROM lic_schema.insurance_providers WHERE provider_code = 'LIC'), 'whole_life', 'Seed Whole Elite', 5000000, 45000, 'annual', NOW() - INTERVAL '55 days', NOW() - INTERVAL '45 days', 'active', '{"riders": ["Waiver of Premium"], "term": 30}')
        ON CONFLICT (policy_number) DO NOTHING;
        RAISE NOTICE 'Added insurance policies data';
    END IF;

    -- =====================================================
    -- PREMIUM PAYMENTS - Depend on policies and policyholders
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.premium_payments;
    IF current_count < 10 THEN
        INSERT INTO lic_schema.premium_payments (
            policy_id, policyholder_id, amount, currency, payment_date, due_date,
            payment_method, payment_gateway, status
        ) VALUES
        ((SELECT policy_id FROM lic_schema.insurance_policies WHERE policy_number = 'SEED_POL001'), (SELECT policyholder_id FROM lic_schema.policyholders WHERE customer_id = 'SEED_CUST001'), 25000, 'INR', NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days', 'upi', 'razorpay', 'completed'),
        ((SELECT policy_id FROM lic_schema.insurance_policies WHERE policy_number = 'SEED_POL002'), (SELECT policyholder_id FROM lic_schema.policyholders WHERE customer_id = 'SEED_CUST002'), 30000, 'INR', NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days', 'credit_card', 'phonepe', 'completed'),
        ((SELECT policy_id FROM lic_schema.insurance_policies WHERE policy_number = 'SEED_POL003'), (SELECT policyholder_id FROM lic_schema.policyholders WHERE customer_id = 'SEED_CUST003'), 35000, 'INR', NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days', 'debit_card', 'razorpay', 'completed'),
        ((SELECT policy_id FROM lic_schema.insurance_policies WHERE policy_number = 'SEED_POL004'), (SELECT policyholder_id FROM lic_schema.policyholders WHERE customer_id = 'SEED_CUST004'), 20000, 'INR', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days', 'net_banking', 'phonepe', 'completed'),
        ((SELECT policy_id FROM lic_schema.insurance_policies WHERE policy_number = 'SEED_POL005'), (SELECT policyholder_id FROM lic_schema.policyholders WHERE customer_id = 'SEED_CUST005'), 15000, 'INR', NOW(), NOW(), 'upi', 'razorpay', 'pending'),
        ((SELECT policy_id FROM lic_schema.insurance_policies WHERE policy_number = 'SEED_POL006'), (SELECT policyholder_id FROM lic_schema.policyholders WHERE customer_id = 'SEED_CUST006'), 28000, 'INR', NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days', 'credit_card', 'phonepe', 'completed'),
        ((SELECT policy_id FROM lic_schema.insurance_policies WHERE policy_number = 'SEED_POL007'), (SELECT policyholder_id FROM lic_schema.policyholders WHERE customer_id = 'SEED_CUST007'), 40000, 'INR', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days', 'debit_card', 'razorpay', 'completed'),
        ((SELECT policy_id FROM lic_schema.insurance_policies WHERE policy_number = 'SEED_POL008'), (SELECT policyholder_id FROM lic_schema.policyholders WHERE customer_id = 'SEED_CUST008'), 25000, 'INR', NOW() - INTERVAL '35 days', NOW() - INTERVAL '35 days', 'net_banking', 'phonepe', 'completed'),
        ((SELECT policy_id FROM lic_schema.insurance_policies WHERE policy_number = 'SEED_POL009'), (SELECT policyholder_id FROM lic_schema.policyholders WHERE customer_id = 'SEED_CUST009'), 35000, 'INR', NOW() - INTERVAL '40 days', NOW() - INTERVAL '40 days', 'upi', 'razorpay', 'completed'),
        ((SELECT policy_id FROM lic_schema.insurance_policies WHERE policy_number = 'SEED_POL010'), (SELECT policyholder_id FROM lic_schema.policyholders WHERE customer_id = 'SEED_CUST010'), 45000, 'INR', NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days', 'credit_card', 'phonepe', 'completed')
        ON CONFLICT DO NOTHING;
        RAISE NOTICE 'Added premium payments data';
    END IF;

    RAISE NOTICE 'V14 migration completed successfully! All core tables now have minimum seed data.';
END $$;