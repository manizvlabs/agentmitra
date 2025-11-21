-- Agent Mitra - Migration V4: Create Presentation Carousel Tables
-- This migration creates presentation carousel and editor tables

-- =====================================================
-- PRESENTATION CAROUSEL TABLES
-- =====================================================

-- Presentation carousel (agent promotional content)
CREATE TABLE lic_schema.presentations (
    presentation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.agents(agent_id) ON DELETE CASCADE,
    
    -- Presentation details
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'draft', -- 'draft', 'published', 'archived'
    is_active BOOLEAN DEFAULT false,
    
    -- Template reference
    template_id UUID, -- References presentation_templates if created from template
    template_category VARCHAR(100), -- 'term_insurance', 'health_insurance', 'child_plans', 'retirement'
    
    -- Version control
    version INTEGER DEFAULT 1,
    parent_presentation_id UUID REFERENCES lic_schema.presentations(presentation_id),
    
    -- Lifecycle timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    published_at TIMESTAMP,
    archived_at TIMESTAMP,
    
    -- Metadata
    tags TEXT[],
    target_audience TEXT[], -- 'prospects', 'existing_customers', 'senior_citizens'
    language VARCHAR(10) DEFAULT 'en',
    
    -- Analytics summary (denormalized for performance)
    total_views INTEGER DEFAULT 0,
    total_shares INTEGER DEFAULT 0,
    total_cta_clicks INTEGER DEFAULT 0,
    
    -- Audit fields
    created_by UUID REFERENCES lic_schema.users(user_id),
    published_by UUID REFERENCES lic_schema.users(user_id)
);

-- Presentation slides (individual carousel slides)
CREATE TABLE lic_schema.presentation_slides (
    slide_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    presentation_id UUID REFERENCES lic_schema.presentations(presentation_id) ON DELETE CASCADE,
    
    -- Slide ordering
    slide_order INTEGER NOT NULL,
    
    -- Media content
    slide_type VARCHAR(50) NOT NULL, -- 'image', 'video', 'text'
    media_url VARCHAR(500),
    media_type VARCHAR(50), -- 'image/jpeg', 'image/png', 'video/mp4'
    thumbnail_url VARCHAR(500),
    media_storage_key VARCHAR(500), -- S3/CDN storage key
    
    -- Text content
    title TEXT,
    subtitle TEXT,
    description TEXT,
    
    -- Styling
    text_color VARCHAR(7) DEFAULT '#FFFFFF', -- Hex color
    background_color VARCHAR(7) DEFAULT '#000000', -- Hex color
    overlay_opacity DECIMAL(3,2) DEFAULT 0.5,
    layout VARCHAR(50) DEFAULT 'centered', -- 'centered', 'left_aligned', 'grid', 'right_aligned'
    
    -- Display settings
    duration INTEGER DEFAULT 4, -- Seconds to display slide
    transition_effect VARCHAR(50) DEFAULT 'fade', -- 'fade', 'slide', 'zoom'
    
    -- Call-to-action button
    cta_button JSONB, -- {enabled: bool, text: str, action: str, backgroundColor: str, textColor: str}
    
    -- Agent branding
    agent_branding JSONB, -- {showLogo: bool, logoUrl: str, showContact: bool, contactText: str}
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    -- Ensure unique ordering within presentation
    UNIQUE(presentation_id, slide_order)
);

-- Presentation templates (pre-built templates for agents)
CREATE TABLE lic_schema.presentation_templates (
    template_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Template details
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL, -- 'term_insurance', 'health_insurance', 'child_plans', 'retirement'
    
    -- Template content (JSONB array of slide definitions)
    slides JSONB NOT NULL, -- Array of slide objects with template variables
    
    -- Template metadata
    is_default BOOLEAN DEFAULT false,
    is_public BOOLEAN DEFAULT false, -- Public templates available to all agents
    is_system_template BOOLEAN DEFAULT false, -- System-created templates
    
    -- Usage tracking
    usage_count INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2),
    total_ratings INTEGER DEFAULT 0,
    
    -- Preview
    preview_image_url VARCHAR(500),
    preview_video_url VARCHAR(500),
    
    -- Availability
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'archived', 'deprecated'
    available_from TIMESTAMP,
    available_until TIMESTAMP,
    
    -- Audit fields
    created_by UUID REFERENCES lic_schema.users(user_id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Presentation analytics (tracking views, engagement, etc.)
CREATE TABLE lic_schema.presentation_analytics (
    analytics_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    presentation_id UUID REFERENCES lic_schema.presentations(presentation_id) ON DELETE CASCADE,
    slide_id UUID REFERENCES lic_schema.presentation_slides(slide_id) ON DELETE SET NULL,
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    
    -- Event details
    event_type VARCHAR(50) NOT NULL, -- 'view', 'cta_click', 'share', 'forward', 'interest'
    event_category VARCHAR(50), -- 'engagement', 'conversion', 'navigation'
    
    -- User context (if available)
    viewer_id UUID REFERENCES lic_schema.users(user_id), -- Nullable for anonymous views
    viewer_type VARCHAR(50), -- 'agent', 'customer', 'prospect', 'anonymous'
    
    -- Event metadata
    event_data JSONB, -- Additional event-specific data
    cta_action VARCHAR(100), -- If event_type is 'cta_click', what action was triggered
    share_method VARCHAR(50), -- 'whatsapp', 'email', 'sms', 'link' if event_type is 'share'
    
    -- Device and context
    device_info JSONB,
    ip_address INET,
    user_agent TEXT,
    location_info JSONB,
    
    -- Timestamps
    event_timestamp TIMESTAMP DEFAULT NOW()
);

-- Presentation media storage (tracking uploaded media files)
CREATE TABLE lic_schema.presentation_media (
    media_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    
    -- Media details
    media_type VARCHAR(50) NOT NULL, -- 'image', 'video'
    mime_type VARCHAR(100), -- 'image/jpeg', 'video/mp4'
    file_name VARCHAR(255),
    file_size_bytes BIGINT,
    
    -- Storage locations
    storage_provider VARCHAR(50) DEFAULT 's3', -- 's3', 'firebase', 'cdn'
    storage_key VARCHAR(500) NOT NULL, -- S3 key or storage path
    media_url VARCHAR(500) NOT NULL, -- Public CDN URL
    thumbnail_url VARCHAR(500), -- Thumbnail URL for videos
    
    -- Media metadata
    width INTEGER, -- Image/video width in pixels
    height INTEGER, -- Image/video height in pixels
    duration_seconds INTEGER, -- Video duration
    file_hash VARCHAR(64), -- SHA-256 hash for deduplication
    
    -- Usage tracking
    usage_count INTEGER DEFAULT 0, -- How many slides use this media
    last_used_at TIMESTAMP,
    
    -- Status
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'archived', 'deleted'
    is_optimized BOOLEAN DEFAULT false,
    
    -- Timestamps
    uploaded_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Agent presentation preferences (customization settings)
CREATE TABLE lic_schema.agent_presentation_preferences (
    preference_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.agents(agent_id) UNIQUE,
    
    -- Branding preferences
    default_text_color VARCHAR(7) DEFAULT '#FFFFFF',
    default_background_color VARCHAR(7) DEFAULT '#000000',
    default_layout VARCHAR(50) DEFAULT 'centered',
    default_duration INTEGER DEFAULT 4,
    
    -- Branding assets
    logo_url VARCHAR(500),
    brand_colors JSONB, -- Array of brand color hex codes
    
    -- Auto-branding settings
    auto_add_logo BOOLEAN DEFAULT true,
    auto_add_contact_cta BOOLEAN DEFAULT true,
    contact_cta_text VARCHAR(100) DEFAULT 'Talk to me',
    
    -- Editor preferences
    editor_theme VARCHAR(20) DEFAULT 'light', -- 'light', 'dark'
    show_preview_by_default BOOLEAN DEFAULT true,
    auto_save_enabled BOOLEAN DEFAULT true,
    auto_save_interval_seconds INTEGER DEFAULT 60,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- INDEXES
-- =====================================================

CREATE INDEX idx_presentations_agent_status ON lic_schema.presentations(agent_id, status);
CREATE INDEX idx_presentations_active ON lic_schema.presentations(agent_id, is_active) WHERE is_active = true;
CREATE INDEX idx_presentations_template ON lic_schema.presentations(template_id) WHERE template_id IS NOT NULL;
CREATE INDEX idx_presentations_published ON lic_schema.presentations(published_at DESC) WHERE status = 'published';

CREATE INDEX idx_slides_presentation_order ON lic_schema.presentation_slides(presentation_id, slide_order);
CREATE INDEX idx_slides_type ON lic_schema.presentation_slides(slide_type);

CREATE INDEX idx_templates_category_public ON lic_schema.presentation_templates(category, is_public) WHERE is_public = true;
CREATE INDEX idx_templates_status ON lic_schema.presentation_templates(status) WHERE status = 'active';

CREATE INDEX idx_analytics_presentation ON lic_schema.presentation_analytics(presentation_id, event_timestamp DESC);
CREATE INDEX idx_analytics_slide ON lic_schema.presentation_analytics(slide_id, event_type) WHERE slide_id IS NOT NULL;
CREATE INDEX idx_analytics_agent ON lic_schema.presentation_analytics(agent_id, event_timestamp DESC);
CREATE INDEX idx_analytics_event_type ON lic_schema.presentation_analytics(event_type, event_timestamp DESC);

CREATE INDEX idx_media_agent_status ON lic_schema.presentation_media(agent_id, status);
CREATE INDEX idx_media_hash ON lic_schema.presentation_media(file_hash) WHERE file_hash IS NOT NULL;
CREATE INDEX idx_media_type ON lic_schema.presentation_media(media_type);

-- JSONB indexes for flexible queries
CREATE INDEX idx_slides_cta_button ON lic_schema.presentation_slides USING GIN(cta_button) WHERE cta_button IS NOT NULL;
CREATE INDEX idx_slides_agent_branding ON lic_schema.presentation_slides USING GIN(agent_branding) WHERE agent_branding IS NOT NULL;
CREATE INDEX idx_analytics_event_data ON lic_schema.presentation_analytics USING GIN(event_data);
CREATE INDEX idx_templates_slides ON lic_schema.presentation_templates USING GIN(slides);

-- =====================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================

-- Function to update presentation analytics summary
CREATE OR REPLACE FUNCTION lic_schema.update_presentation_analytics_summary()
RETURNS TRIGGER AS $$
BEGIN
    -- Update presentation summary when analytics events occur
    IF NEW.event_type = 'view' THEN
        UPDATE lic_schema.presentations
        SET total_views = total_views + 1
        WHERE presentation_id = NEW.presentation_id;
    ELSIF NEW.event_type = 'share' THEN
        UPDATE lic_schema.presentations
        SET total_shares = total_shares + 1
        WHERE presentation_id = NEW.presentation_id;
    ELSIF NEW.event_type = 'cta_click' THEN
        UPDATE lic_schema.presentations
        SET total_cta_clicks = total_cta_clicks + 1
        WHERE presentation_id = NEW.presentation_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER presentation_analytics_summary_trigger
    AFTER INSERT ON lic_schema.presentation_analytics
    FOR EACH ROW
    EXECUTE FUNCTION lic_schema.update_presentation_analytics_summary();

-- Function to increment media usage count
CREATE OR REPLACE FUNCTION lic_schema.increment_media_usage()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.media_url IS NOT NULL THEN
        UPDATE lic_schema.presentation_media
        SET usage_count = usage_count + 1,
            last_used_at = NOW()
        WHERE media_url = NEW.media_url;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER slide_media_usage_trigger
    AFTER INSERT OR UPDATE ON lic_schema.presentation_slides
    FOR EACH ROW
    EXECUTE FUNCTION lic_schema.increment_media_usage();

