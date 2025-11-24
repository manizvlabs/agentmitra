-- Agent Mitra - Migration V20: Enhance Existing Tables and Add Final Missing Data
-- This migration enhances tables with low records and adds data for remaining tables:
-- Enhances: policy_analytics_summary, tenants, chatbot_intents, knowledge_base_articles,
-- whatsapp_templates, roles
-- Adds: revenue_forecasts, user_payment_methods, customer_data_mapping

DO $$
DECLARE
    current_count INTEGER;
    i INTEGER;
    j INTEGER;
    agent_record RECORD;
    policyholder_record RECORD;
    user_record RECORD;
BEGIN
    RAISE NOTICE 'Starting V20 migration: Enhancing existing tables and adding final data...';

    -- =====================================================
    -- ENHANCE POLICY ANALYTICS SUMMARY (currently 1 record, need 10+)
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.policy_analytics_summary;
    IF current_count < 10 THEN
        -- Add more policy analytics summary records for different periods
        FOR i IN 1..9 LOOP  -- Add 9 more to reach 10
            INSERT INTO lic_schema.policy_analytics_summary (
                summary_date, summary_period, draft_policies, pending_policies,
                approved_policies, active_policies, lapsed_policies, cancelled_policies,
                life_policies, health_policies, general_policies,
                total_premium, average_premium, applications_received, applications_approved, conversion_rate
            ) VALUES (
                CURRENT_DATE - i,
                CASE (i % 3)
                    WHEN 0 THEN 'daily'
                    WHEN 1 THEN 'weekly'
                    ELSE 'monthly'
                END,
                5 + (RANDOM() * 15)::INT,   -- 5-20 draft policies
                8 + (RANDOM() * 20)::INT,   -- 8-28 pending policies
                120 + (RANDOM() * 50)::INT, -- 120-170 approved policies
                100 + (RANDOM() * 60)::INT, -- 100-160 active policies
                2 + (RANDOM() * 8)::INT,    -- 2-10 lapsed policies
                1 + (RANDOM() * 5)::INT,    -- 1-6 cancelled policies
                70 + (RANDOM() * 40)::INT,  -- 70-110 life policies
                35 + (RANDOM() * 25)::INT,  -- 35-60 health policies
                20 + (RANDOM() * 15)::INT,  -- 20-35 general policies
                2000000 + (RANDOM() * 2000000)::DECIMAL(15,2), -- 2M-4M total premium
                15000 + (RANDOM() * 5000)::DECIMAL(12,2),      -- 15k-20k average premium
                15 + (RANDOM() * 25)::INT,  -- 15-40 applications received
                12 + (RANDOM() * 20)::INT,  -- 12-32 applications approved
                75 + (RANDOM() * 20)::DECIMAL(5,2)  -- 75-95% conversion rate
            ) ON CONFLICT (summary_date, summary_period) DO NOTHING;
        END LOOP;
        RAISE NOTICE 'Enhanced policy analytics summary data';
    END IF;

    -- =====================================================
    -- ENHANCE TENANTS - Skipped (schema_name constraint prevents multiple tenants in shared schema)
    -- =====================================================
    -- Note: Tenants table already has 1 record. In a shared schema architecture,
    -- multiple tenants would typically use different schema names or database isolation.

    -- =====================================================
    -- ENHANCE CHATBOT INTENTS (currently 2 records, need 10+)
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.chatbot_intents;
    IF current_count < 10 THEN
        -- Add more chatbot intents
            INSERT INTO lic_schema.chatbot_intents (
            intent_name, description, training_examples, response_templates,
            confidence_threshold, is_active, usage_count, success_rate
        ) VALUES
        ('premium_calculation', 'Calculate insurance premium based on coverage and age', ARRAY['calculate premium', 'how much premium', 'cost of insurance'], ARRAY['I can help you calculate your premium. Please provide your age, coverage amount, and policy type.'], 0.8, true, 150, 0.85),
        ('claim_process', 'Guide through insurance claim filing process', ARRAY['how to file claim', 'claim procedure', 'make a claim'], ARRAY['To file a claim, you need: policy number, incident details, supporting documents. I can guide you through each step.'], 0.85, true, 200, 0.90),
        ('policy_comparison', 'Compare different insurance policies', ARRAY['compare policies', 'which policy is better', 'policy differences'], ARRAY['I can help you compare policies based on coverage, premium, and benefits. Which policies would you like to compare?'], 0.75, true, 120, 0.80),
        ('renewal_reminder', 'Handle policy renewal inquiries', ARRAY['renew policy', 'renewal date', 'when to renew'], ARRAY['Your policy renewal is due on {renewal_date}. You can renew online or contact your agent.'], 0.9, true, 180, 0.88),
        ('document_upload', 'Guide for uploading documents', ARRAY['upload documents', 'submit papers', 'required documents'], ARRAY['Please upload the following documents: ID proof, address proof, and policy-related documents.'], 0.8, true, 90, 0.82),
        ('payment_methods', 'Explain available payment options', ARRAY['payment options', 'how to pay', 'payment methods'], ARRAY['You can pay through: UPI, net banking, credit/debit cards, or cash at agent office.'], 0.85, true, 160, 0.87),
        ('coverage_details', 'Explain policy coverage details', ARRAY['what is covered', 'coverage details', 'policy benefits'], ARRAY['Your policy covers: {coverage_details}. For complete details, please refer to your policy document.'], 0.8, true, 140, 0.83),
        ('agent_contact', 'Help contact insurance agent', ARRAY['contact agent', 'speak to agent', 'agent details'], ARRAY['I can connect you with your agent. Please provide your policy number or customer ID.'], 0.9, true, 110, 0.89)
        ON CONFLICT (intent_name) DO NOTHING;
        RAISE NOTICE 'Enhanced chatbot intents data';
    END IF;

    -- =====================================================
    -- ENHANCE KNOWLEDGE BASE ARTICLES (currently 2 records, need 10+)
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.knowledge_base_articles;
    IF current_count < 10 THEN
        -- Add more knowledge base articles
        INSERT INTO lic_schema.knowledge_base_articles (
            title, content, category, tags, view_count, helpful_votes,
            total_votes, created_by
        ) VALUES
        ('Term Life Insurance Guide', 'Comprehensive guide explaining term life insurance, coverage options, premium calculation, and benefits...', 'life_insurance', ARRAY['term_life', 'coverage', 'premium'], 250, 45, 50, (SELECT user_id FROM lic_schema.users ORDER BY RANDOM() LIMIT 1)),
        ('Health Insurance Coverage Types', 'Detailed explanation of different health insurance coverage types including hospitalization, critical illness, and OPD...', 'health_insurance', ARRAY['health', 'coverage', 'hospitalization'], 180, 38, 42, (SELECT user_id FROM lic_schema.users ORDER BY RANDOM() LIMIT 1)),
        ('Investment Linked Insurance Plans', 'Guide to ULIP and other investment-linked insurance plans, fund options, and returns...', 'investment', ARRAY['ulip', 'investment', 'funds'], 320, 67, 72, (SELECT user_id FROM lic_schema.users ORDER BY RANDOM() LIMIT 1)),
        ('Retirement Planning with Insurance', 'How to use insurance products for retirement planning and pension benefits...', 'retirement', ARRAY['retirement', 'pension', 'planning'], 150, 28, 32, (SELECT user_id FROM lic_schema.users ORDER BY RANDOM() LIMIT 1)),
        ('Filing Insurance Claims', 'Step-by-step guide to filing different types of insurance claims...', 'claims', ARRAY['claims', 'procedure', 'documents'], 400, 89, 95, (SELECT user_id FROM lic_schema.users ORDER BY RANDOM() LIMIT 1)),
        ('Tax Benefits on Insurance', 'Complete guide to tax deductions available under Section 80C, 80D, and other provisions...', 'tax', ARRAY['tax', 'deductions', '80c'], 280, 52, 58, (SELECT user_id FROM lic_schema.users ORDER BY RANDOM() LIMIT 1)),
        ('Child Education Insurance Plans', 'Planning for child education using insurance policies and education funds...', 'child_plans', ARRAY['children', 'education', 'future'], 190, 41, 45, (SELECT user_id FROM lic_schema.users ORDER BY RANDOM() LIMIT 1)),
        ('Insurance Policy Renewal Process', 'Everything you need to know about renewing your insurance policies online and offline...', 'renewal', ARRAY['renewal', 'process', 'online'], 220, 48, 52, (SELECT user_id FROM lic_schema.users ORDER BY RANDOM() LIMIT 1))
        ON CONFLICT DO NOTHING;
        RAISE NOTICE 'Enhanced knowledge base articles data';
    END IF;

    -- =====================================================
    -- ENHANCE WHATSAPP TEMPLATES (currently 6 records, need 10+)
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM shared.whatsapp_templates;
    IF current_count < 10 THEN
        -- Add more WhatsApp templates
        INSERT INTO shared.whatsapp_templates (
            template_name, category, language, content, variables, approval_status
        ) VALUES
        ('claim_intimation', 'utility', 'en', 'Dear {{customer_name}}, your claim for policy {{policy_number}} amounting to ₹{{claim_amount}} has been processed and will be credited within 3 working days.', '["customer_name", "policy_number", "claim_amount"]'::JSONB, 'approved'),
        ('policy_maturity', 'utility', 'en', 'Congratulations {{customer_name}}! Your policy {{policy_number}} has matured. The maturity amount of ₹{{maturity_amount}} will be credited to your account.', '["customer_name", "policy_number", "maturity_amount"]'::JSONB, 'approved'),
        ('document_verification', 'utility', 'en', 'Hi {{customer_name}}, we need additional documents for your policy {{policy_number}}. Please upload them through the app or visit your nearest branch.', '["customer_name", "policy_number"]'::JSONB, 'approved'),
        ('agent_assigned', 'utility', 'en', 'Welcome {{customer_name}}! {{agent_name}} has been assigned as your insurance agent. Contact: {{agent_phone}}', '["customer_name", "agent_name", "agent_phone"]'::JSONB, 'pending'),
        ('premium_discount', 'marketing', 'en', 'Special offer for {{customer_name}}! Get {{discount_percentage}}% discount on your next premium payment. Valid till {{valid_date}}.', '["customer_name", "discount_percentage", "valid_date"]'::JSONB, 'pending'),
        ('policy_upgrade', 'marketing', 'en', 'Hi {{customer_name}}, upgrade your policy {{policy_number}} and get additional coverage at special rates. Contact us today!', '["customer_name", "policy_number"]'::JSONB, 'pending'),
        ('payment_failed', 'utility', 'en', 'Alert: Payment of ₹{{amount}} for policy {{policy_number}} failed. Please retry or contact support.', '["amount", "policy_number"]'::JSONB, 'approved')
        ON CONFLICT (template_name) DO NOTHING;
        RAISE NOTICE 'Enhanced WhatsApp templates data';
    END IF;

    -- =====================================================
    -- ENHANCE ROLES (currently 8 records, need 10+)
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.roles;
    IF current_count < 10 THEN
        -- Add more role definitions
        INSERT INTO lic_schema.roles (
            role_name, role_description, is_system_role, permissions
        ) VALUES
        ('compliance_officer', 'Ensures regulatory compliance and audits', true, '["compliance.read", "compliance.write", "audits.*", "reports.read"]'::jsonb),
        ('customer_support_lead', 'Leads customer support team', true, '["support.*", "customers.*", "reports.read", "tickets.manage"]'::jsonb)
        ON CONFLICT (role_name) DO NOTHING;
        RAISE NOTICE 'Enhanced roles data';
    END IF;

    -- =====================================================
    -- ADD REVENUE FORECASTS (new table)
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.revenue_forecasts;
    IF current_count < 10 THEN
        -- Add revenue forecasts for agents
        FOR agent_record IN SELECT agent_id FROM lic_schema.agents LIMIT 10 LOOP
            FOR i IN 1..3 LOOP  -- 3 forecasts per agent (monthly, quarterly, yearly)
                INSERT INTO lic_schema.revenue_forecasts (
                    agent_id, forecast_period, forecast_date, target_date,
                    predicted_revenue, predicted_commission, confidence_level,
                    forecast_method, created_by
                ) VALUES (
                    agent_record.agent_id,
                    CASE i
                        WHEN 1 THEN 'monthly'
                        WHEN 2 THEN 'quarterly'
                        ELSE 'yearly'
                    END,
                    CURRENT_DATE,
                    CASE i
                        WHEN 1 THEN CURRENT_DATE + INTERVAL '1 month'
                        WHEN 2 THEN CURRENT_DATE + INTERVAL '3 months'
                        ELSE CURRENT_DATE + INTERVAL '1 year'
                    END,
                    CASE i
                        WHEN 1 THEN 50000 + (RANDOM() * 100000)::DECIMAL(15,2)
                        WHEN 2 THEN 150000 + (RANDOM() * 300000)::DECIMAL(15,2)
                        ELSE 600000 + (RANDOM() * 1200000)::DECIMAL(15,2)
                    END,
                    CASE i
                        WHEN 1 THEN 5000 + (RANDOM() * 10000)::DECIMAL(12,2)
                        WHEN 2 THEN 15000 + (RANDOM() * 30000)::DECIMAL(12,2)
                        ELSE 60000 + (RANDOM() * 120000)::DECIMAL(12,2)
                    END,
                    0.7 + (RANDOM() * 0.25)::DECIMAL(3,2),  -- 70-95% confidence
                    CASE (RANDOM() * 3)::INT
                        WHEN 0 THEN 'linear_regression'
                        WHEN 1 THEN 'time_series'
                        ELSE 'machine_learning'
                    END,
                    (SELECT user_id FROM lic_schema.users ORDER BY RANDOM() LIMIT 1)
                );
            END LOOP;
        END LOOP;
        RAISE NOTICE 'Added revenue forecasts data';
    END IF;

    -- =====================================================
    -- ADD USER PAYMENT METHODS (new table)
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.user_payment_methods;
    IF current_count < 10 THEN
        -- Add payment methods for users
        FOR user_record IN SELECT user_id FROM lic_schema.users LIMIT 10 LOOP
            -- Add 1-3 payment methods per user
            FOR j IN 1..(1 + (RANDOM() * 2)::INT) LOOP
                INSERT INTO lic_schema.user_payment_methods (
                    user_id, method_type, method_name, is_default,
                    upi_id, bank_account_number_encrypted, bank_ifsc_code, bank_name,
                    status, verification_status, last_used_at
                ) VALUES (
                    user_record.user_id,
                    CASE j
                        WHEN 1 THEN 'upi'
                        WHEN 2 THEN 'net_banking'
                        ELSE 'credit_card'
                    END,
                    CASE j
                        WHEN 1 THEN 'Paytm UPI'
                        WHEN 2 THEN 'HDFC Net Banking'
                        ELSE 'HDFC Credit Card'
                    END,
                    CASE WHEN j = 1 THEN true ELSE false END,  -- First method is default
                    CASE WHEN j = 1 THEN user_record.user_id || '@paytm' ELSE NULL END,
                    CASE WHEN j = 2 THEN md5(random()::text || j::text) ELSE NULL END,
                    CASE WHEN j = 2 THEN 'HDFC0001234' ELSE NULL END,
                    CASE WHEN j = 2 THEN 'HDFC Bank' ELSE NULL END,
                    'active',
                    CASE WHEN RANDOM() < 0.8 THEN 'verified' ELSE 'pending' END,
                    CASE WHEN RANDOM() < 0.7 THEN NOW() - INTERVAL '1 day' * (RANDOM() * 30)::INT ELSE NULL END
                );
            END LOOP;
        END LOOP;
        RAISE NOTICE 'Added user payment methods data';
    END IF;

    -- =====================================================
    -- ADD CUSTOMER DATA MAPPING (new table)
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.customer_data_mapping;
    IF current_count < 10 THEN
        -- Add customer data mappings for policyholders
        FOR policyholder_record IN SELECT policyholder_id, user_id FROM lic_schema.policyholders LIMIT 10 LOOP
            INSERT INTO lic_schema.customer_data_mapping (
                import_id, excel_row_number, customer_name, phone_number,
                email, policy_number, mapping_status
            ) VALUES (
                (SELECT import_id FROM lic_schema.data_imports ORDER BY RANDOM() LIMIT 1),
                (RANDOM() * 1000)::INT + 1,  -- Excel row number
                'Customer ' || (RANDOM() * 1000)::INT,
                '+91' || (9000000000 + (RANDOM() * 999999999)::BIGINT)::TEXT,
                'customer' || (RANDOM() * 1000)::INT || '@example.com',
                'POL' || (RANDOM() * 10000)::INT,
                CASE (RANDOM() * 3)::INT
                    WHEN 0 THEN 'pending'
                    WHEN 1 THEN 'mapped'
                    ELSE 'error'
                END
            );
        END LOOP;
        RAISE NOTICE 'Added customer data mapping data';
    END IF;

    RAISE NOTICE 'V20 migration completed successfully! Enhanced existing tables and added final missing data.';
END $$;
