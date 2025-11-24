-- Agent Mitra - Migration V19: Seed Phase 5 - Data Management and Integration
-- This migration adds seed data for data management tables: data imports, sync status,
-- import jobs, knowledge search logs, and tenant configuration
-- Ensures all data management tables have at least 10 records each

DO $$
DECLARE
    current_count INTEGER;
    i INTEGER;
    user_record RECORD;
BEGIN
    RAISE NOTICE 'Starting V19 migration: Adding Phase 5 data management seed data...';

    -- =====================================================
    -- DATA IMPORTS - Independent table
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.data_imports;
    IF current_count < 10 THEN
        -- Create data import records
        FOR i IN 1..10 LOOP
            INSERT INTO lic_schema.data_imports (
                file_name, import_type, status, total_records,
                processed_records, error_records, error_details,
                processing_started_at, processing_completed_at
            ) VALUES (
                'import_' || i || '_' || EXTRACT(epoch FROM NOW()) || '.csv',
                CASE (RANDOM() * 4)::INT
                    WHEN 0 THEN 'policies'
                    WHEN 1 THEN 'customers'
                    WHEN 2 THEN 'payments'
                    ELSE 'agents'
                END,
                CASE (RANDOM() * 3)::INT
                    WHEN 0 THEN 'completed'
                    WHEN 1 THEN 'failed'
                    ELSE 'processing'
                END,
                1000 + (RANDOM() * 9000)::INT,  -- 1000-10000 total records
                950 + (RANDOM() * 8950)::INT,   -- Processed records (95-99% success rate)
                (RANDOM() * 100)::INT,          -- 0-100 error records
                CASE WHEN RANDOM() < 0.3 THEN
                    '{"errors": ["5 invalid email formats", "3 missing phone numbers"]}'::jsonb
                ELSE NULL END,
                NOW() - INTERVAL '2 hours',
                CASE WHEN RANDOM() < 0.8 THEN NOW() - INTERVAL '30 minutes' ELSE NULL END
            );
        END LOOP;
        RAISE NOTICE 'Added data imports data';
    END IF;

    -- =====================================================
    -- DATA SYNC STATUS - Independent table
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.data_sync_status;
    IF current_count < 10 THEN
        -- Create data sync status records
        FOR i IN 1..10 LOOP
            INSERT INTO lic_schema.data_sync_status (
                sync_type, last_sync_at, sync_status, error_message,
                retry_count, next_retry_at
            ) VALUES (
                CASE (RANDOM() * 5)::INT
                    WHEN 0 THEN 'policies'
                    WHEN 1 THEN 'customers'
                    WHEN 2 THEN 'payments'
                    WHEN 3 THEN 'claims'
                    ELSE 'agents'
                END,
                NOW() - INTERVAL '1 hour' * (RANDOM() * 24)::INT,
                CASE (RANDOM() * 4)::INT
                    WHEN 0 THEN 'completed'
                    WHEN 1 THEN 'failed'
                    WHEN 2 THEN 'in_progress'
                    ELSE 'pending'
                END,
                CASE WHEN RANDOM() < 0.2 THEN
                    'Connection timeout after 30 seconds'
                ELSE NULL END,
                CASE WHEN RANDOM() < 0.3 THEN (RANDOM() * 5)::INT ELSE 0 END,  -- 0-5 retries
                CASE WHEN RANDOM() < 0.5 THEN NOW() + INTERVAL '1 hour' * (RANDOM() * 6)::INT ELSE NULL END
            );
        END LOOP;
        RAISE NOTICE 'Added data sync status data';
    END IF;

    -- =====================================================
    -- IMPORT JOBS - Independent table
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.import_jobs;
    IF current_count < 10 THEN
        -- Create import job records
        FOR i IN 1..10 LOOP
            INSERT INTO lic_schema.import_jobs (
                import_id, job_type, priority, status, retry_count,
                max_retries, error_message, started_at, completed_at
            ) VALUES (
                (SELECT import_id FROM lic_schema.data_imports ORDER BY RANDOM() LIMIT 1),
                CASE (RANDOM() * 3)::INT
                    WHEN 0 THEN 'validate'
                    WHEN 1 THEN 'process'
                    ELSE 'cleanup'
                END,
                CASE (RANDOM() * 3)::INT
                    WHEN 0 THEN 1
                    WHEN 1 THEN 3
                    ELSE 5
                END,  -- priority 1-5
                CASE (RANDOM() * 4)::INT
                    WHEN 0 THEN 'queued'
                    WHEN 1 THEN 'processing'
                    WHEN 2 THEN 'completed'
                    ELSE 'failed'
                END,
                CASE WHEN RANDOM() < 0.3 THEN (RANDOM() * 3)::INT ELSE 0 END,  -- 0-3 retries
                3,  -- max_retries
                CASE WHEN RANDOM() < 0.3 THEN
                    'Validation failed for 5 records'
                ELSE NULL END,
                CASE WHEN RANDOM() < 0.8 THEN NOW() - INTERVAL '1 hour' ELSE NULL END,
                CASE WHEN RANDOM() < 0.6 THEN NOW() - INTERVAL '30 minutes' ELSE NULL END
            );
        END LOOP;
        RAISE NOTICE 'Added import jobs data';
    END IF;

    -- =====================================================
    -- KNOWLEDGE SEARCH LOG - Independent table
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.knowledge_search_log;
    IF current_count < 10 THEN
        -- Create knowledge search log records
        FOR i IN 1..10 LOOP
            INSERT INTO lic_schema.knowledge_search_log (
                user_id, session_id, search_query, search_filters,
                results_count, clicked_article_id, search_time_ms, search_source, ip_address
            ) VALUES (
                (SELECT user_id FROM lic_schema.users ORDER BY RANDOM() LIMIT 1),
                CASE WHEN RANDOM() < 0.5 THEN
                    (SELECT session_id FROM lic_schema.chatbot_sessions ORDER BY RANDOM() LIMIT 1)
                ELSE NULL END,
                CASE (RANDOM() * 8)::INT
                    WHEN 0 THEN 'term life insurance benefits'
                    WHEN 1 THEN 'how to file a claim'
                    WHEN 2 THEN 'premium payment methods'
                    WHEN 3 THEN 'policy renewal process'
                    WHEN 4 THEN 'investment plans comparison'
                    WHEN 5 THEN 'health insurance coverage'
                    WHEN 6 THEN 'tax benefits on insurance'
                    ELSE 'agent commission structure'
                END,
                jsonb_build_object(
                    'category', CASE (RANDOM() * 4)::INT
                        WHEN 0 THEN 'life_insurance'
                        WHEN 1 THEN 'health_insurance'
                        WHEN 2 THEN 'investment'
                        ELSE 'general'
                    END,
                    'language', CASE WHEN RANDOM() < 0.8 THEN 'en' ELSE 'hi' END
                ),
                (RANDOM() * 50)::INT,  -- 0-50 results
                CASE WHEN RANDOM() < 0.7 THEN
                    (SELECT article_id FROM lic_schema.knowledge_base_articles ORDER BY RANDOM() LIMIT 1)
                ELSE NULL END,
                100 + (RANDOM() * 900)::INT,  -- 100-1000ms response time
                CASE (RANDOM() * 3)::INT
                    WHEN 0 THEN 'manual'
                    WHEN 1 THEN 'chatbot'
                    ELSE 'api'
                END,
                ('192.168.1.' || (RANDOM() * 255)::INT)::INET
            );
        END LOOP;
        RAISE NOTICE 'Added knowledge search log data';
    END IF;

    -- =====================================================
    -- TENANT CONFIG - Independent table
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.tenant_config;
    IF current_count < 10 THEN
        -- Create tenant configuration records
        FOR i IN 1..10 LOOP
            INSERT INTO lic_schema.tenant_config (
                tenant_id, config_key, config_value, config_type, is_encrypted
            ) VALUES
            -- Email configuration
            (
                (SELECT tenant_id FROM shared.tenants ORDER BY RANDOM() LIMIT 1),
                'email.smtp.host',
                '"smtp.gmail.com"'::jsonb,
                'string',
                false
            ),
            (
                (SELECT tenant_id FROM shared.tenants ORDER BY RANDOM() LIMIT 1),
                'email.templates.enabled',
                'true'::jsonb,
                'boolean',
                false
            ),
            -- WhatsApp configuration
            (
                (SELECT tenant_id FROM shared.tenants ORDER BY RANDOM() LIMIT 1),
                'whatsapp.business.number',
                '"+919876543210"'::jsonb,
                'string',
                false
            ),
            -- Payment configuration
            (
                (SELECT tenant_id FROM shared.tenants ORDER BY RANDOM() LIMIT 1),
                'payment.gateway.razorpay.key',
                ('"rzp_test_' || md5(random()::text) || '"')::jsonb,
                'string',
                true
            ),
            -- Feature flags
            (
                (SELECT tenant_id FROM shared.tenants ORDER BY RANDOM() LIMIT 1),
                'features.chatbot.enabled',
                'true'::jsonb,
                'boolean',
                false
            ),
            -- Analytics configuration
            (
                (SELECT tenant_id FROM shared.tenants ORDER BY RANDOM() LIMIT 1),
                'analytics.retention.days',
                '365'::jsonb,
                'integer',
                false
            )
            ON CONFLICT (tenant_id, config_key) DO NOTHING;
        END LOOP;
        RAISE NOTICE 'Added tenant config data';
    END IF;

    RAISE NOTICE 'V19 migration completed successfully! All Phase 5 data management tables now have minimum seed data.';
END $$;
