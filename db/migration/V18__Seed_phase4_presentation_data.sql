-- Agent Mitra - Migration V18: Seed Phase 4 - Presentation and Media Data
-- This migration adds seed data for presentation tables: presentation analytics, media,
-- agent presentation preferences, and video content
-- Ensures all presentation-related tables have at least 10 records each

DO $$
DECLARE
    current_count INTEGER;
    i INTEGER;
    agent_record RECORD;
    presentation_record RECORD;
BEGIN
    RAISE NOTICE 'Starting V18 migration: Adding Phase 4 presentation seed data...';

    -- =====================================================
    -- PRESENTATION ANALYTICS - Depend on presentations, slides, agents
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.presentation_analytics;
    IF current_count < 10 THEN
        -- Create analytics events for presentations
        FOR presentation_record IN SELECT presentation_id FROM lic_schema.presentations LIMIT 5 LOOP
            FOR i IN 1..20 LOOP  -- Multiple events per presentation
                INSERT INTO lic_schema.presentation_analytics (
                    presentation_id, slide_id, agent_id, event_type, event_category,
                    viewer_id, viewer_type, event_data, cta_action, share_method,
                    device_info, ip_address, user_agent, event_timestamp
                ) VALUES (
                    presentation_record.presentation_id,
                    CASE WHEN RANDOM() < 0.7 THEN
                        (SELECT slide_id FROM lic_schema.presentation_slides
                         WHERE presentation_id = presentation_record.presentation_id
                         ORDER BY RANDOM() LIMIT 1)
                    ELSE NULL END,
                    (SELECT agent_id FROM lic_schema.presentations WHERE presentation_id = presentation_record.presentation_id),
                    CASE (RANDOM() * 6)::INT
                        WHEN 0 THEN 'view'
                        WHEN 1 THEN 'cta_click'
                        WHEN 2 THEN 'share'
                        WHEN 3 THEN 'interest'
                        WHEN 4 THEN 'slide_change'
                        ELSE 'completion'
                    END,
                    CASE (RANDOM() * 3)::INT
                        WHEN 0 THEN 'engagement'
                        WHEN 1 THEN 'conversion'
                        ELSE 'navigation'
                    END,
                    CASE WHEN RANDOM() < 0.3 THEN
                        (SELECT user_id FROM lic_schema.users ORDER BY RANDOM() LIMIT 1)
                    ELSE NULL END,
                    CASE WHEN RANDOM() < 0.3 THEN 'customer' ELSE 'prospect' END,
                    jsonb_build_object(
                        'duration', (5 + RANDOM() * 30)::INT,
                        'slide_number', 1 + (RANDOM() * 5)::INT,
                        'interaction_type', 'click'
                    ),
                    CASE WHEN RANDOM() < 0.2 THEN 'contact_agent' ELSE NULL END,
                    CASE WHEN RANDOM() < 0.15 THEN
                        CASE (RANDOM() * 3)::INT
                            WHEN 0 THEN 'whatsapp'
                            WHEN 1 THEN 'email'
                            ELSE 'link'
                        END
                    ELSE NULL END,
                    '{"device_type": "mobile", "os": "android", "browser": "Chrome"}'::jsonb,
                    ('192.168.1.' || (RANDOM() * 255)::INT)::INET,
                    'Mozilla/5.0 (Android) AgentMitra/1.0.0',
                    NOW() - INTERVAL '1 day' * (RANDOM() * 30)::INT
                );
            END LOOP;
        END LOOP;
        RAISE NOTICE 'Added presentation analytics data';
    END IF;

    -- =====================================================
    -- PRESENTATION MEDIA - Depend on agents
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.presentation_media;
    IF current_count < 10 THEN
        -- Create media files for agents
        FOR agent_record IN SELECT agent_id FROM lic_schema.agents LIMIT 10 LOOP
            FOR i IN 1..2 LOOP  -- 2 media files per agent
                INSERT INTO lic_schema.presentation_media (
                    agent_id, media_type, mime_type, file_name, file_size_bytes,
                    storage_provider, storage_key, media_url, thumbnail_url,
                    width, height, duration_seconds, file_hash, usage_count,
                    status, uploaded_at
                ) VALUES (
                    agent_record.agent_id,
                    CASE WHEN i % 2 = 1 THEN 'image' ELSE 'video' END,
                    CASE WHEN i % 2 = 1 THEN 'image/jpeg' ELSE 'video/mp4' END,
                    'media_' || agent_record.agent_id || '_' || i || CASE WHEN i % 2 = 1 THEN '.jpg' ELSE '.mp4' END,
                    CASE WHEN i % 2 = 1 THEN 2048000 + (RANDOM() * 2048000)::BIGINT ELSE 10485760 + (RANDOM() * 20971520)::BIGINT END,  -- 2-4MB images, 10-30MB videos
                    's3',
                    'presentations/' || agent_record.agent_id || '/media_' || i,
                    'https://cdn.agentmitra.com/presentations/' || agent_record.agent_id || '/media_' || i,
                    CASE WHEN i % 2 = 0 THEN 'https://cdn.agentmitra.com/thumbnails/' || agent_record.agent_id || '/thumb_' || i || '.jpg' ELSE NULL END,
                    CASE WHEN i % 2 = 1 THEN 1920 ELSE NULL END,  -- Image width
                    CASE WHEN i % 2 = 1 THEN 1080 ELSE NULL END,  -- Image height
                    CASE WHEN i % 2 = 0 THEN (30 + RANDOM() * 300)::INT ELSE NULL END,  -- Video duration 30s-5min
                    'hash_' || agent_record.agent_id || '_' || i || '_' || EXTRACT(epoch FROM NOW()),
                    (RANDOM() * 10)::INT,  -- 0-10 usage count
                    CASE (RANDOM() * 3)::INT
                        WHEN 0 THEN 'processing'
                        WHEN 1 THEN 'active'
                        ELSE 'archived'
                    END,
                    NOW() - INTERVAL '1 day' * (RANDOM() * 30)::INT
                );
            END LOOP;
        END LOOP;
        RAISE NOTICE 'Added presentation media data';
    END IF;

    -- =====================================================
    -- AGENT PRESENTATION PREFERENCES - Depend on agents
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.agent_presentation_preferences;
    IF current_count < 10 THEN
        -- Create presentation preferences for agents
        FOR agent_record IN SELECT agent_id FROM lic_schema.agents LIMIT 10 LOOP
            INSERT INTO lic_schema.agent_presentation_preferences (
                agent_id, default_text_color, default_background_color, default_layout,
                default_duration, logo_url, brand_colors, auto_add_logo,
                auto_add_contact_cta, contact_cta_text, editor_theme,
                show_preview_by_default, auto_save_enabled, auto_save_interval_seconds
            ) VALUES (
                agent_record.agent_id,
                CASE (RANDOM() * 3)::INT
                    WHEN 0 THEN '#FFFFFF'
                    WHEN 1 THEN '#000000'
                    ELSE '#333333'
                END,
                CASE (RANDOM() * 3)::INT
                    WHEN 0 THEN '#000000'
                    WHEN 1 THEN '#1a365d'
                    ELSE '#2d3748'
                END,
                CASE (RANDOM() * 3)::INT
                    WHEN 0 THEN 'centered'
                    WHEN 1 THEN 'left_aligned'
                    ELSE 'grid'
                END,
                3 + (RANDOM() * 4)::INT,  -- 3-7 seconds
                CASE WHEN RANDOM() < 0.7 THEN 'https://cdn.agentmitra.com/logos/' || agent_record.agent_id || '.png' ELSE NULL END,
                jsonb_build_array(
                    '#1a365d', '#2d3748', '#4a5568', '#718096', '#e2e8f0'
                ),
                RANDOM() < 0.8,  -- 80% auto add logo
                RANDOM() < 0.9,  -- 90% auto add CTA
                CASE (RANDOM() * 3)::INT
                    WHEN 0 THEN 'Contact Me'
                    WHEN 1 THEN 'Get Quote'
                    ELSE 'Talk to Agent'
                END,
                CASE WHEN RANDOM() < 0.6 THEN 'light' ELSE 'dark' END,
                RANDOM() < 0.7,  -- 70% show preview by default
                true,  -- Auto save always enabled
                30 + (RANDOM() * 60)::INT  -- 30-90 seconds
            ) ON CONFLICT (agent_id) DO NOTHING;
        END LOOP;
        RAISE NOTICE 'Added agent presentation preferences data';
    END IF;

    -- =====================================================
    -- VIDEO CONTENT - Depend on agents
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.video_content;
    IF current_count < 10 THEN
        -- Create video content for agents
        FOR agent_record IN SELECT agent_id FROM lic_schema.agents LIMIT 10 LOOP
            INSERT INTO lic_schema.video_content (
                agent_id, title, description, video_url, thumbnail_url,
                duration_seconds, category, tags, language, difficulty_level,
                target_audience, view_count, unique_viewers, avg_watch_time,
                completion_rate, engagement_rate, average_rating, total_ratings,
                featured, status, moderation_status, created_at
            ) VALUES (
                agent_record.agent_id,
                CASE (RANDOM() * 5)::INT
                    WHEN 0 THEN 'Understanding Term Life Insurance'
                    WHEN 1 THEN 'Investment Plans for Your Future'
                    WHEN 2 THEN 'Health Insurance Made Simple'
                    WHEN 3 THEN 'Retirement Planning Guide'
                    ELSE 'Insurance Claims Process'
                END,
                CASE (RANDOM() * 5)::INT
                    WHEN 0 THEN 'Learn about term life insurance coverage and benefits'
                    WHEN 1 THEN 'Comprehensive guide to investment-linked insurance plans'
                    WHEN 2 THEN 'Everything you need to know about health insurance'
                    WHEN 3 THEN 'Plan your retirement with confidence using insurance'
                    ELSE 'Step-by-step guide to filing and processing insurance claims'
                END,
                'https://cdn.agentmitra.com/videos/' || agent_record.agent_id || '/video_' || EXTRACT(epoch FROM NOW()) || '.mp4',
                'https://cdn.agentmitra.com/thumbnails/' || agent_record.agent_id || '/thumb_' || EXTRACT(epoch FROM NOW()) || '.jpg',
                (180 + RANDOM() * 420)::INT,  -- 3-10 minutes
                CASE (RANDOM() * 4)::INT
                    WHEN 0 THEN 'life_insurance'
                    WHEN 1 THEN 'health_insurance'
                    WHEN 2 THEN 'investment'
                    ELSE 'general'
                END,
                CASE (RANDOM() * 4)::INT
                    WHEN 0 THEN ARRAY['term_life', 'insurance', 'coverage']
                    WHEN 1 THEN ARRAY['ulip', 'investment', 'savings']
                    WHEN 2 THEN ARRAY['health', 'medical', 'hospital']
                    ELSE ARRAY['retirement', 'pension', 'planning']
                END,
                CASE WHEN RANDOM() < 0.8 THEN 'en' ELSE 'hi' END,
                CASE (RANDOM() * 3)::INT
                    WHEN 0 THEN 'beginner'
                    WHEN 1 THEN 'intermediate'
                    ELSE 'advanced'
                END,
                CASE (RANDOM() * 3)::INT
                    WHEN 0 THEN ARRAY['policyholders', 'families']
                    WHEN 1 THEN ARRAY['young_professionals', 'investors']
                    ELSE ARRAY['senior_citizens', 'retirees']
                END,
                (100 + RANDOM() * 5000)::INT,  -- 100-5100 views
                (50 + RANDOM() * 3000)::INT,  -- 50-3050 unique viewers
                (60 + RANDOM() * 240)::DECIMAL(6,2),  -- 1-5 min avg watch time
                (20 + RANDOM() * 60)::DECIMAL(5,2),  -- 20-80% completion rate
                (10 + RANDOM() * 30)::DECIMAL(5,2),  -- 10-40% engagement rate
                (3.5 + RANDOM() * 1.5)::DECIMAL(3,2),  -- 3.5-5.0 rating
                (5 + RANDOM() * 100)::INT,  -- 5-105 ratings
                RANDOM() < 0.2,  -- 20% featured
                CASE (RANDOM() * 3)::INT
                    WHEN 0 THEN 'processing'
                    WHEN 1 THEN 'published'
                    ELSE 'rejected'
                END,
                'approved',
                NOW() - INTERVAL '1 day' * (RANDOM() * 90)::INT
            );
        END LOOP;
        RAISE NOTICE 'Added video content data';
    END IF;

    RAISE NOTICE 'V18 migration completed successfully! All Phase 4 presentation tables now have minimum seed data.';
END $$;
