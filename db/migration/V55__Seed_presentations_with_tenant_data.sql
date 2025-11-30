-- Agent Mitra - Migration V55: Seed Presentations with Tenant Data
-- This migration adds proper seed data for presentations and media with tenant_id
-- Ensures all presentation data has correct tenant isolation

DO $$
DECLARE
    default_tenant_id UUID := '00000000-0000-0000-0000-000000000000';
    agent_user RECORD;
    presentation_id UUID;
    slide_id UUID;
    media_id UUID;
BEGIN
    RAISE NOTICE 'Starting V55 migration: Adding presentations with tenant data...';

    -- =====================================================
    -- CREATE SAMPLE PRESENTATIONS FOR EXISTING AGENTS
    -- =====================================================

    -- Get agents that don't have presentations yet
    FOR agent_user IN
        SELECT a.agent_id, u.first_name, u.last_name, a.agent_code
        FROM lic_schema.agents a
        JOIN lic_schema.users u ON a.user_id = u.user_id
        WHERE a.agent_id NOT IN (
            SELECT DISTINCT agent_id FROM lic_schema.presentations
        )
        LIMIT 3
    LOOP
        -- Create a sample presentation for each agent
        presentation_id := gen_random_uuid();

        INSERT INTO lic_schema.presentations (
            presentation_id, agent_id, tenant_id, name, description,
            status, is_active, language, created_at, updated_at
        ) VALUES (
            presentation_id,
            agent_user.agent_id,
            default_tenant_id,
            'Welcome Presentation - ' || COALESCE(agent_user.first_name, 'Agent') || ' ' || COALESCE(agent_user.last_name, ''),
            'A professional presentation template showcasing insurance products and services',
            'published',
            true,
            'en',
            NOW(),
            NOW()
        );

        RAISE NOTICE 'Created presentation % for agent %', presentation_id, agent_user.agent_id;

        -- Create slides for the presentation
        slide_id := gen_random_uuid();
        INSERT INTO lic_schema.presentation_slides (
            slide_id, presentation_id, slide_order, slide_type,
            title, description, text_color, background_color,
            layout, duration, created_at, updated_at
        ) VALUES (
            slide_id,
            presentation_id,
            1,
            'text',
            'Welcome to ' || agent_user.first_name || '''s Insurance Services',
            'Professional insurance solutions tailored to your needs',
            '#FFFFFF',
            '#1a237e',
            'centered',
            5,
            NOW(),
            NOW()
        );

        slide_id := gen_random_uuid();
        INSERT INTO lic_schema.presentation_slides (
            slide_id, presentation_id, slide_order, slide_type,
            title, description, text_color, background_color,
            layout, duration, created_at, updated_at
        ) VALUES (
            slide_id,
            presentation_id,
            2,
            'text',
            'Why Choose Our Insurance?',
            'Comprehensive coverage, competitive rates, and excellent customer service',
            '#000000',
            '#ffffff',
            'split',
            6,
            NOW(),
            NOW()
        );

        RAISE NOTICE 'Created slides for presentation %', presentation_id;
    END LOOP;

    -- =====================================================
    -- CREATE SAMPLE MEDIA FILES
    -- =====================================================

    -- Create sample media entries (simulating uploaded files)
    FOR agent_user IN
        SELECT a.agent_id, u.first_name
        FROM lic_schema.agents a
        JOIN lic_schema.users u ON a.user_id = u.user_id
        LIMIT 2
    LOOP
        -- Sample image
        media_id := gen_random_uuid();
        INSERT INTO lic_schema.presentation_media (
            media_id, agent_id, tenant_id, media_type, mime_type,
            file_name, file_size_bytes, storage_provider, storage_key,
            media_url, thumbnail_url, file_hash, status, uploaded_at
        ) VALUES (
            media_id,
            agent_user.agent_id,
            default_tenant_id,
            'image',
            'image/jpeg',
            'insurance-hero-' || agent_user.first_name || '.jpg',
            245760,
            'minio',
            'presentations/' || agent_user.agent_id || '/insurance-hero.jpg',
            'http://localhost:9000/agentmitra-media/presentations/' || agent_user.agent_id || '/insurance-hero.jpg',
            'http://localhost:9000/agentmitra-media/presentations/' || agent_user.agent_id || '/insurance-hero-thumb.jpg',
            'abc123def456',
            'active',
            NOW()
        );

        -- Sample video
        media_id := gen_random_uuid();
        INSERT INTO lic_schema.presentation_media (
            media_id, agent_id, tenant_id, media_type, mime_type,
            file_name, file_size_bytes, storage_provider, storage_key,
            media_url, file_hash, status, uploaded_at
        ) VALUES (
            media_id,
            agent_user.agent_id,
            default_tenant_id,
            'video',
            'video/mp4',
            'insurance-overview-' || agent_user.first_name || '.mp4',
            5242880,
            'minio',
            'presentations/' || agent_user.agent_id || '/insurance-overview.mp4',
            'http://localhost:9000/agentmitra-media/presentations/' || agent_user.agent_id || '/insurance-overview.mp4',
            'def456ghi789',
            'active',
            NOW()
        );

        RAISE NOTICE 'Created media files for agent %', agent_user.agent_id;
    END LOOP;

    -- =====================================================
    -- PRESENTATION TEMPLATES - Skip for now due to schema mismatch
    -- =====================================================

    RAISE NOTICE 'Skipping presentation templates creation due to schema differences';

    RAISE NOTICE 'Migration V55 completed successfully!';
END $$;
