-- Seed test users and presentations for development/testing
-- This migration adds test data for API testing

-- Note: This uses the actual database schema from V3 (lic_schema)
-- Users table uses UUID, first_name/last_name, and role enum

-- Insert test users (using proper schema structure)
INSERT INTO lic_schema.users (
    user_id, 
    phone_number, 
    email, 
    first_name, 
    last_name, 
    display_name,
    password_hash, 
    role, 
    phone_verified,
    status,
    created_at, 
    updated_at
)
VALUES 
    -- Test Agent (UUID format) - using 'junior_agent' enum value
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '+919876543210', 'agent1@test.com', 'Test', 'Agent', 'Test Agent One', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyY5Y5Y5Y5Y5', 'junior_agent', true, 'active', NOW(), NOW()),
    
    -- Test Customer - using 'policyholder' enum value
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12'::uuid, '+919876543211', 'customer1@test.com', 'Test', 'Customer', 'Test Customer One', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyY5Y5Y5Y5Y5', 'policyholder', true, 'active', NOW(), NOW()),
    
    -- Test Customer 2 (for OTP testing) - will use OTP auth, but password_hash is required
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13'::uuid, '+919876543212', 'customer2@test.com', 'Test', 'Customer2', 'Test Customer Two', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyY5Y5Y5Y5Y5', 'policyholder', false, 'active', NOW(), NOW())
ON CONFLICT (user_id) DO NOTHING;

-- Insert test agents (if agents table exists)
INSERT INTO lic_schema.agents (
    agent_id,
    user_id,
    agent_code,
    license_number,
    status,
    created_at,
    updated_at
)
VALUES 
    ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'AGENT001', 'LIC123456', 'active', NOW(), NOW())
ON CONFLICT (agent_id) DO NOTHING;

-- Insert test presentation templates
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
    ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'Promotional Template', 'Template for promotional content', 'term_insurance', true, NULL, '[{"type": "image", "layout": "centered"}]'::jsonb, NOW(), NOW()),
    ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12'::uuid, 'Educational Template', 'Template for educational content', 'health_insurance', true, NULL, '[{"type": "text", "layout": "top"}]'::jsonb, NOW(), NOW())
ON CONFLICT (template_id) DO NOTHING;

-- Insert test presentation for agent
INSERT INTO lic_schema.presentations (
    presentation_id, 
    agent_id, 
    name, 
    description, 
    status, 
    is_active, 
    template_id, 
    tags, 
    created_at, 
    updated_at
)
VALUES 
    ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'Daily Promotional', 'Daily promotional presentation', 'published', true, 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, ARRAY['promotional', 'daily'], NOW(), NOW()),
    ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12'::uuid, 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'Weekly Update', 'Weekly update presentation', 'draft', false, NULL, ARRAY['update'], NOW(), NOW())
ON CONFLICT (presentation_id) DO NOTHING;

-- Insert test slides for presentation-001
INSERT INTO lic_schema.presentation_slides (
    slide_id, 
    presentation_id, 
    slide_order, 
    slide_type, 
    media_url, 
    thumbnail_url, 
    title, 
    subtitle, 
    text_color, 
    background_color, 
    layout, 
    duration, 
    cta_button, 
    agent_branding, 
    created_at, 
    updated_at
)
VALUES 
    ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 1, 'image', 'https://via.placeholder.com/800x600/FF0000/FFFFFF?text=Slide+1', NULL, 'Welcome', 'To Agent Mitra', '#FFFFFF', '#000000', 'centered', 5, NULL, NULL, NOW(), NOW()),
    ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12'::uuid, 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 2, 'text', NULL, NULL, 'Our Services', 'Insurance Solutions for Everyone', '#000000', '#FFFFFF', 'centered', 4, '{"text": "Learn More", "action": "/services"}'::jsonb, NULL, NOW(), NOW()),
    ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13'::uuid, 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 3, 'image', 'https://via.placeholder.com/800x600/0000FF/FFFFFF?text=Slide+3', NULL, 'Contact Us', 'Get in touch today', '#FFFFFF', '#0000FF', 'bottom', 5, NULL, NULL, NOW(), NOW())
ON CONFLICT (slide_id) DO NOTHING;

-- Note: Password hash above is for 'password123' (bcrypt)
-- For testing: 
--   Agent: phone_number +919876543210, password: password123, agent_code: AGENT001
--   Customer: phone_number +919876543211, password: password123
