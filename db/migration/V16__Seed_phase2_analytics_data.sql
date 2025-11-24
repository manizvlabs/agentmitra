-- Agent Mitra - Migration V16: Seed Phase 2 - Analytics and Reporting Data
-- This migration adds seed data for analytics tables: agent monthly summaries, customer behavior metrics,
-- analytics query logs, and data export logs
-- Ensures all analytics-related tables have at least 10 records each

DO $$
DECLARE
    current_count INTEGER;
    i INTEGER;
    agent_record RECORD;
    customer_record RECORD;
    start_date DATE;
    end_date DATE;
BEGIN
    RAISE NOTICE 'Starting V16 migration: Adding Phase 2 analytics seed data...';

    -- Set date range for analytics data (last 6 months)
    start_date := CURRENT_DATE - INTERVAL '6 months';
    end_date := CURRENT_DATE;

    -- =====================================================
    -- AGENT MONTHLY SUMMARY - Depend on agents
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.agent_monthly_summary;
    IF current_count < 10 THEN
        -- Create monthly summaries for agents over the last 6 months
        FOR agent_record IN SELECT agent_id FROM lic_schema.agents LIMIT 5 LOOP
            FOR i IN 0..5 LOOP
                INSERT INTO lic_schema.agent_monthly_summary (
                    agent_id, summary_month, total_policies, total_premium,
                    total_commission, active_customers, growth_rate, rank_by_premium, rank_by_policies
                ) VALUES (
                    agent_record.agent_id,
                    DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month' * i),
                    5 + (RANDOM() * 15)::INT,  -- 5-20 policies
                    (50000 + RANDOM() * 200000)::DECIMAL(15,2),  -- 50k-250k premium
                    (5000 + RANDOM() * 25000)::DECIMAL(12,2),  -- 5k-30k commission
                    8 + (RANDOM() * 20)::INT,  -- 8-28 active customers
                    (RANDOM() * 20 - 10)::DECIMAL(5,2),  -- -10% to +10% growth
                    1 + (RANDOM() * 10)::INT,  -- Rank 1-10
                    1 + (RANDOM() * 10)::INT   -- Rank 1-10
                ) ON CONFLICT (agent_id, summary_month) DO NOTHING;
            END LOOP;
        END LOOP;
        RAISE NOTICE 'Added agent monthly summary data';
    END IF;

    -- =====================================================
    -- CUSTOMER BEHAVIOR METRICS - Depend on policyholders
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.customer_behavior_metrics;
    IF current_count < 10 THEN
        -- Create behavior metrics for customers over the last 30 days
        FOR customer_record IN SELECT policyholder_id FROM lic_schema.policyholders LIMIT 10 LOOP
            FOR i IN 0..29 LOOP
                INSERT INTO lic_schema.customer_behavior_metrics (
                    customer_id, metric_date, login_count, page_views, session_duration,
                    policy_views, premium_payments, claims_submitted, email_opens,
                    whatsapp_messages, support_tickets, churn_probability, upgrade_probability
                ) VALUES (
                    customer_record.policyholder_id,
                    CURRENT_DATE - i,
                    (RANDOM() * 5)::INT,  -- 0-5 logins
                    5 + (RANDOM() * 20)::INT,  -- 5-25 page views
                    (300 + RANDOM() * 1800)::INT,  -- 5-30 min sessions
                    (RANDOM() * 10)::INT,  -- 0-10 policy views
                    CASE WHEN RANDOM() < 0.1 THEN 1 ELSE 0 END,  -- 10% chance of payment
                    CASE WHEN RANDOM() < 0.05 THEN 1 ELSE 0 END,  -- 5% chance of claim
                    CASE WHEN RANDOM() < 0.3 THEN 1 + (RANDOM() * 3)::INT ELSE 0 END,  -- 30% chance of email opens
                    CASE WHEN RANDOM() < 0.2 THEN 1 + (RANDOM() * 2)::INT ELSE 0 END,  -- 20% chance of whatsapp
                    CASE WHEN RANDOM() < 0.05 THEN 1 ELSE 0 END,  -- 5% chance of support ticket
                    (RANDOM() * 9.99)::DECIMAL(3,2),  -- 0-9.99% churn probability
                    (RANDOM() * 9.99)::DECIMAL(3,2)   -- 0-9.99% upgrade probability
                ) ON CONFLICT (customer_id, metric_date) DO NOTHING;
            END LOOP;
        END LOOP;
        RAISE NOTICE 'Added customer behavior metrics data';
    END IF;

    -- =====================================================
    -- ANALYTICS QUERY LOG - Depend on users
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.analytics_query_log;
    IF current_count < 10 THEN
        -- Create analytics query logs for different users
        FOR i IN 1..10 LOOP
            INSERT INTO lic_schema.analytics_query_log (
                user_id, query_type, query_parameters, execution_time_ms,
                records_returned, ip_address, user_agent, data_classification, access_reason
            ) VALUES (
                (SELECT user_id FROM lic_schema.users ORDER BY RANDOM() LIMIT 1),
                CASE (RANDOM() * 3)::INT
                    WHEN 0 THEN 'dashboard'
                    WHEN 1 THEN 'report'
                    ELSE 'export'
                END,
                jsonb_build_object(
                    'filters', jsonb_build_object(
                        'date_range', 'last_30_days',
                        'agent_id', (SELECT agent_id FROM lic_schema.agents ORDER BY RANDOM() LIMIT 1),
                        'policy_type', 'term_life'
                    ),
                    'metrics', ARRAY['policies_sold', 'premium_collected', 'customer_satisfaction']
                ),
                500 + (RANDOM() * 2000)::INT,  -- 500-2500ms execution time
                50 + (RANDOM() * 500)::INT,  -- 50-550 records
                ('192.168.1.' || (RANDOM() * 255)::INT)::INET,
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                CASE (RANDOM() * 3)::INT
                    WHEN 0 THEN 'public'
                    WHEN 1 THEN 'internal'
                    ELSE 'confidential'
                END,
                'Business intelligence and performance monitoring'
            );
        END LOOP;
        RAISE NOTICE 'Added analytics query log data';
    END IF;

    -- =====================================================
    -- DATA EXPORT LOG - Depend on users
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.data_export_log;
    IF current_count < 10 THEN
        -- Create data export logs for different users
        FOR i IN 1..10 LOOP
            INSERT INTO lic_schema.data_export_log (
                user_id, export_type, record_count, data_types, date_range,
                encryption_used, ip_address, purpose, retention_period_days, file_name, file_size_bytes
            ) VALUES (
                (SELECT user_id FROM lic_schema.users ORDER BY RANDOM() LIMIT 1),
                CASE (RANDOM() * 3)::INT
                    WHEN 0 THEN 'csv'
                    WHEN 1 THEN 'pdf'
                    ELSE 'excel'
                END,
                100 + (RANDOM() * 900)::INT,  -- 100-1000 records
                CASE (RANDOM() * 3)::INT
                    WHEN 0 THEN ARRAY['policies', 'customers']
                    WHEN 1 THEN ARRAY['payments', 'commissions']
                    ELSE ARRAY['analytics', 'reports']
                END,
                tsrange(
                    CURRENT_DATE - INTERVAL '30 days',
                    CURRENT_DATE,
                    '[]'
                ),
                true,
                ('192.168.1.' || (RANDOM() * 255)::INT)::INET,
                CASE (RANDOM() * 3)::INT
                    WHEN 0 THEN 'Monthly reporting'
                    WHEN 1 THEN 'Compliance audit'
                    ELSE 'Performance analysis'
                END,
                90,
                'export_' || EXTRACT(epoch FROM NOW()) || '_' || i || '.csv',
                1024000 + (RANDOM() * 5242880)::BIGINT  -- 1MB-6MB file size
            );
        END LOOP;
        RAISE NOTICE 'Added data export log data';
    END IF;

    RAISE NOTICE 'V16 migration completed successfully! All Phase 2 analytics tables now have minimum seed data.';
END $$;
