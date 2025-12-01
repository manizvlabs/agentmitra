-- Seed comprehensive presentation test data for API testing
-- This migration adds presentations, templates, and media for all test agents

-- =====================================================
-- STEP 1: Seed Presentation Templates
-- =====================================================

INSERT INTO lic_schema.presentation_templates (
    template_id,
    name,
    description,
    category,
    is_public,
    preview_image_url,
    slides,
    created_at,
    updated_at
)
VALUES
    -- Term Insurance Templates
    ('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a01'::uuid,
     'Term Life Insurance Basic',
     'Basic template for term life insurance presentations',
     'term_insurance',
     true,
     'http://localhost:9000/agentmitra-media/templates/term-basic.jpg',
     '[
       {
         "slide_order": 1,
         "slide_type": "image",
         "title": "Secure Your Family''s Future",
         "subtitle": "Term Life Insurance Made Simple",
         "layout": "centered",
         "duration": 5,
         "text_color": "#FFFFFF",
         "background_color": "#000000",
         "cta_button": {"text": "Get Quote", "action": "contact"}
       },
       {
         "slide_order": 2,
         "slide_type": "text",
         "title": "Why Choose Term Insurance?",
         "subtitle": "Affordable Protection for Your Loved Ones",
         "layout": "top",
         "duration": 4,
         "text_color": "#000000",
         "background_color": "#FFFFFF"
       }
     ]'::jsonb,
     NOW(),
     NOW()),

    ('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a02'::uuid,
     'Health Insurance Comprehensive',
     'Comprehensive health insurance presentation template',
     'health_insurance',
     true,
     'http://localhost:9000/agentmitra-media/templates/health-comprehensive.jpg',
     '[
       {
         "slide_order": 1,
         "slide_type": "image",
         "title": "Your Health, Our Priority",
         "subtitle": "Comprehensive Health Coverage",
         "layout": "centered",
         "duration": 5,
         "text_color": "#FFFFFF",
         "background_color": "#0066CC"
       },
       {
         "slide_order": 2,
         "slide_type": "text",
         "title": "Complete Health Protection",
         "subtitle": "From Hospitalization to Preventive Care",
         "layout": "centered",
         "duration": 4,
         "text_color": "#000000",
         "background_color": "#FFFFFF"
       }
     ]'::jsonb,
     NOW(),
     NOW()),

    ('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a03'::uuid,
     'Investment Plans Starter',
     'Beginner-friendly investment plans template',
     'investment',
     true,
     'http://localhost:9000/agentmitra-media/templates/investment-starter.jpg',
     '[
       {
         "slide_order": 1,
         "slide_type": "image",
         "title": "Grow Your Wealth",
         "subtitle": "Smart Investment Solutions",
         "layout": "centered",
         "duration": 5,
         "text_color": "#FFFFFF",
         "background_color": "#228B22"
       }
     ]'::jsonb,
     NOW(),
     NOW())
ON CONFLICT (template_id) DO NOTHING;

-- =====================================================
-- STEP 2: Seed Presentations for Test Agents
-- =====================================================

-- Get the agent IDs from our test users
-- Senior Agent (user_id: a473bf8a-32ce-41b9-8419-3400f1a1165b)
INSERT INTO lic_schema.presentations (
    presentation_id,
    agent_id,
    tenant_id,
    name,
    description,
    status,
    is_active,
    template_id,
    tags,
    created_at,
    updated_at
)
SELECT
    'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380b01'::uuid,
    a.agent_id,
    '00000000-0000-0000-0000-000000000000'::uuid,
    'Senior Agent Daily Presentation',
    'Active daily presentation for senior agent dashboard carousel',
    'published',
    true,
    'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a01'::uuid,
    ARRAY['daily', 'carousel', 'featured', 'term_insurance'],
    NOW(),
    NOW()
FROM lic_schema.agents a
WHERE a.user_id = 'a473bf8a-32ce-41b9-8419-3400f1a1165b'::uuid
ON CONFLICT (presentation_id) DO NOTHING;

-- Insert slides for senior agent presentation
INSERT INTO lic_schema.presentation_slides (
    slide_id,
    presentation_id,
    slide_order,
    slide_type,
    media_url,
    media_type,
    thumbnail_url,
    title,
    subtitle,
    description,
    text_color,
    background_color,
    overlay_opacity,
    layout,
    duration,
    cta_button,
    agent_branding,
    created_at,
    updated_at
)
VALUES
    ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380b01'::uuid,
     'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380b01'::uuid,
     1,
     'image',
     'http://localhost:9000/agentmitra-media/presentations/family-protection.jpg',
     'image',
     'http://localhost:9000/agentmitra-media/presentations/family-protection-thumb.jpg',
     'Protect Your Family',
     'Secure their future with term life insurance',
     'Comprehensive coverage at affordable rates',
     '#FFFFFF',
     '#000000',
     0.6,
     'centered',
     5,
     '{"text": "Get Protected", "action": "contact", "color": "#C62828"}'::jsonb,
     '{"logo_url": "http://localhost:9000/agentmitra-media/logos/agent-logo.png", "show_contact": true, "contact_info": {"phone": "+91-9876543203", "email": "senior@agentmitra.com"}}'::jsonb,
     NOW(),
     NOW()),

    ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380b02'::uuid,
     'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380b01'::uuid,
     2,
     'text',
     NULL,
     NULL,
     NULL,
     'Why Choose Us?',
     '25+ Years of Trust & Excellence',
     'Join thousands of satisfied customers who trust us with their insurance needs',
     '#000000',
     '#FFFFFF',
     0.0,
     'centered',
     4,
     '{"text": "Learn More", "action": "modal", "target": "benefits_modal"}'::jsonb,
     '{"show_contact": true}'::jsonb,
     NOW(),
     NOW()),

    ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380b03'::uuid,
     'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380b01'::uuid,
     3,
     'image',
     'http://localhost:9000/agentmitra-media/presentations/health-coverage.jpg',
     'image',
     'http://localhost:9000/agentmitra-media/presentations/health-coverage-thumb.jpg',
     'Health Insurance',
     'Complete medical coverage for you and your family',
     'Hospitalization, day care procedures, and preventive care included',
     '#FFFFFF',
     '#0066CC',
     0.5,
     'left',
     5,
     '{"text": "Compare Plans", "action": "navigate", "target": "/plans/health"}'::jsonb,
     '{"logo_url": "http://localhost:9000/agentmitra-media/logos/agent-logo.png"}'::jsonb,
     NOW(),
     NOW())
ON CONFLICT (slide_id) DO NOTHING;

-- Junior Agent Presentation (user_id: d095c266-111b-4b03-bd95-275baa93f577 from V9 seed data)
INSERT INTO lic_schema.presentations (
    presentation_id,
    agent_id,
    tenant_id,
    name,
    description,
    status,
    is_active,
    template_id,
    tags,
    created_at,
    updated_at
)
SELECT
    'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380b11'::uuid,
    a.agent_id,
    '00000000-0000-0000-0000-000000000000'::uuid,
    'Junior Agent Starter Kit',
    'Basic presentation for new junior agents',
    'published',
    false,
    'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a02'::uuid,
    ARRAY['starter', 'junior', 'health_insurance'],
    NOW(),
    NOW()
FROM lic_schema.agents a
WHERE a.user_id = 'd095c266-111b-4b03-bd95-275baa93f577'::uuid
ON CONFLICT (presentation_id) DO NOTHING;

-- Insert slides for junior agent presentation
INSERT INTO lic_schema.presentation_slides (
    slide_id,
    presentation_id,
    slide_order,
    slide_type,
    title,
    subtitle,
    text_color,
    background_color,
    layout,
    duration,
    cta_button,
    created_at,
    updated_at
)
VALUES
    ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380b11'::uuid,
     'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380b11'::uuid,
     1,
     'text',
     'Welcome to Insurance',
     'Your trusted partner for financial security',
     '#FFFFFF',
     '#C62828',
     'centered',
     4,
     '{"text": "Explore Products", "action": "navigate", "target": "/products"}'::jsonb,
     NOW(),
     NOW())
ON CONFLICT (slide_id) DO NOTHING;

-- =====================================================
-- STEP 3: Seed Presentation Media
-- =====================================================

-- Insert test media files for presentations
INSERT INTO lic_schema.presentation_media (
    media_id,
    agent_id,
    tenant_id,
    media_type,
    mime_type,
    file_name,
    file_size_bytes,
    storage_provider,
    storage_key,
    media_url,
    thumbnail_url,
    file_hash,
    status,
    uploaded_at
)
SELECT
    'm0eebc99-9c0b-4ef8-bb6d-6bb9bd380b01'::uuid,
    a.agent_id,
    '00000000-0000-0000-0000-000000000000'::uuid,
    'image',
    'image/jpeg',
    'family-protection.jpg',
    245760,
    'minio',
    'presentations/family-protection.jpg',
    'http://localhost:9000/agentmitra-media/presentations/family-protection.jpg',
    'http://localhost:9000/agentmitra-media/presentations/family-protection-thumb.jpg',
    'abc123def456',
    'active',
    NOW()
FROM lic_schema.agents a
WHERE a.user_id = 'a473bf8a-32ce-41b9-8419-3400f1a1165b'::uuid
ON CONFLICT (media_id) DO NOTHING;

-- =====================================================
-- STEP 4: Seed Agent Presentation Preferences
-- =====================================================

-- Insert preferences for senior agent
INSERT INTO lic_schema.agent_presentation_preferences (
    preference_id,
    agent_id,
    default_text_color,
    default_background_color,
    default_layout,
    default_duration,
    branding_logo_url,
    branding_primary_color,
    branding_secondary_color,
    show_contact_info,
    contact_phone,
    contact_email,
    created_at,
    updated_at
)
SELECT
    'p0eebc99-9c0b-4ef8-bb6d-6bb9bd380b01'::uuid,
    a.agent_id,
    '#FFFFFF',
    '#C62828',
    'centered',
    4,
    'http://localhost:9000/agentmitra-media/logos/agent-logo.png',
    '#C62828',
    '#FFFFFF',
    true,
    '+919876543203',
    'senior@agentmitra.com',
    NOW(),
    NOW()
FROM lic_schema.agents a
WHERE a.user_id = 'a473bf8a-32ce-41b9-8419-3400f1a1165b'::uuid
ON CONFLICT (agent_id) DO NOTHING;

-- =====================================================
-- STEP 5: Verification Queries
-- =====================================================

-- Count seeded data
DO $$
DECLARE
    template_count INTEGER;
    presentation_count INTEGER;
    slide_count INTEGER;
    media_count INTEGER;
    pref_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO template_count FROM lic_schema.presentation_templates;
    SELECT COUNT(*) INTO presentation_count FROM lic_schema.presentations;
    SELECT COUNT(*) INTO slide_count FROM lic_schema.presentation_slides;
    SELECT COUNT(*) INTO media_count FROM lic_schema.presentation_media;
    SELECT COUNT(*) INTO pref_count FROM lic_schema.agent_presentation_preferences;

    RAISE NOTICE 'Presentation seed data created:';
    RAISE NOTICE '  Templates: %', template_count;
    RAISE NOTICE '  Presentations: %', presentation_count;
    RAISE NOTICE '  Slides: %', slide_count;
    RAISE NOTICE '  Media files: %', media_count;
    RAISE NOTICE '  Preferences: %', pref_count;
END $$;

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================
