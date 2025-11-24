-- Agent Mitra - Migration V21: Seed Final Remaining Tables in lic_schema
-- This migration adds seed data for the final tables in lic_schema that have less than 10 records:
-- presentation_slides (needs 7 more), chatbot_analytics_summary (needs 10)
-- Note: agent_leaderboard is a materialized view that auto-populates from other tables
-- Ensures all lic_schema tables meet the minimum 10-record requirement

DO $$
DECLARE
    current_count INTEGER;
    i INTEGER;
    presentation_record RECORD;
    agent_record RECORD;
BEGIN
    RAISE NOTICE 'Starting V21 migration: Adding final remaining table data...';

    -- =====================================================
    -- PRESENTATION SLIDES - Currently 3 records, needs 7 more
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.presentation_slides;
    IF current_count < 10 THEN
        -- Get existing presentations and add more slides
        FOR presentation_record IN SELECT presentation_id, template_id FROM lic_schema.presentations LIMIT 3 LOOP
            FOR i IN 4..7 LOOP  -- Add slides 4-7 to reach 10 total
                INSERT INTO lic_schema.presentation_slides (
                    presentation_id, slide_order, slide_type, title, subtitle,
                    text_color, background_color, layout, duration, cta_button,
                    created_at, updated_at
                ) VALUES (
                    presentation_record.presentation_id,
                    i,
                    CASE (i % 3)
                        WHEN 0 THEN 'image'
                        WHEN 1 THEN 'text'
                        ELSE 'video'
                    END,
                    CASE i
                        WHEN 4 THEN 'Investment Benefits'
                        WHEN 5 THEN 'Risk Coverage'
                        WHEN 6 THEN 'Claim Process'
                        ELSE 'Contact Information'
                    END,
                    CASE i
                        WHEN 4 THEN 'Why Choose LIC Investments'
                        WHEN 5 THEN 'Complete Protection Plans'
                        WHEN 6 THEN 'Easy Claim Settlement'
                        ELSE 'Get Your Quote Today'
                    END,
                    '#FFFFFF',
                    CASE (i % 2)
                        WHEN 0 THEN '#1a365d'
                        ELSE '#2d3748'
                    END,
                    'centered',
                    5,
                    jsonb_build_object(
                        'text', 'Learn More',
                        'action', 'contact_agent',
                        'backgroundColor', '#3182ce',
                        'textColor', '#FFFFFF'
                    ),
                    NOW() - INTERVAL '1 day' * i,
                    NOW() - INTERVAL '1 day' * i
                );
            END LOOP;
        END LOOP;
        RAISE NOTICE 'Added presentation slides data';
    END IF;

    -- =====================================================
    -- AGENT LEADERBOARD - Skipped (materialized view auto-populates from agents/policies data)
    -- =====================================================

    -- =====================================================
    -- CHATBOT ANALYTICS SUMMARY - Currently 0 records, needs 10
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.chatbot_analytics_summary;
    IF current_count < 10 THEN
        -- Add chatbot analytics summary for different time periods
        FOR i IN 1..10 LOOP
            INSERT INTO lic_schema.chatbot_analytics_summary (
                summary_date, summary_period, total_sessions, completed_sessions,
                abandoned_sessions, total_messages, average_messages_per_session,
                average_response_time_ms, resolution_rate, escalation_rate,
                average_satisfaction, satisfaction_responses, top_intents
            ) VALUES (
                CURRENT_DATE - i,
                'daily',
                50 + (RANDOM() * 200)::INT,  -- 50-250 total sessions
                35 + (RANDOM() * 150)::INT,  -- 35-185 completed sessions
                5 + (RANDOM() * 50)::INT,    -- 5-55 abandoned sessions
                150 + (RANDOM() * 600)::INT, -- 150-750 total messages
                (3 + RANDOM() * 10)::DECIMAL(5,2), -- 3-13 avg messages per session
                (1000 + RANDOM() * 4000)::INT, -- 1000-5000ms avg response time
                (75 + RANDOM() * 20)::DECIMAL(5,2), -- 75-95% resolution rate
                (5 + RANDOM() * 20)::DECIMAL(5,2), -- 5-25% escalation rate
                (3.5 + RANDOM() * 1.5)::DECIMAL(3,2), -- 3.5-5.0 avg satisfaction
                20 + (RANDOM() * 80)::INT, -- 20-100 satisfaction responses
                jsonb_build_object(
                    'policy_inquiry', 25 + (RANDOM() * 50)::INT,
                    'premium_payment', 15 + (RANDOM() * 30)::INT,
                    'claim_process', 10 + (RANDOM() * 25)::INT,
                    'renewal_info', 8 + (RANDOM() * 20)::INT,
                    'general_help', 12 + (RANDOM() * 35)::INT
                )
            ) ON CONFLICT (summary_date, summary_period) DO NOTHING;
        END LOOP;
        RAISE NOTICE 'Added chatbot analytics summary data';
    END IF;

    RAISE NOTICE 'V21 migration completed successfully! All remaining lic_schema tables now have minimum seed data.';
END $$;
