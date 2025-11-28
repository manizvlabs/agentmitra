-- Daily Motivational Quotes System
CREATE TABLE IF NOT EXISTS lic_schema.daily_quotes (
    quote_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    quote_text TEXT NOT NULL,
    author VARCHAR(255),
    category VARCHAR(100) DEFAULT 'motivation',
    tags JSONB,
    branding_settings JSONB, -- font, colors, background image, logo placement
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true,
    scheduled_date DATE,
    published_at TIMESTAMP,
    is_global BOOLEAN DEFAULT false -- allows quotes without specific agent assignment
);

-- Quote sharing analytics
CREATE TABLE IF NOT EXISTS lic_schema.quote_sharing_analytics (
    share_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quote_id UUID REFERENCES lic_schema.daily_quotes(quote_id) ON DELETE CASCADE,
    agent_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    platform VARCHAR(50), -- whatsapp, sms, email, social_media
    recipient_count INTEGER DEFAULT 1,
    delivery_status VARCHAR(50) DEFAULT 'sent',
    engagement_metrics JSONB, -- views, likes, shares, responses
    shared_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Quote performance tracking
CREATE TABLE IF NOT EXISTS lic_schema.quote_performance (
    performance_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quote_id UUID REFERENCES lic_schema.daily_quotes(quote_id) ON DELETE CASCADE,
    agent_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    metric_date DATE DEFAULT CURRENT_DATE,
    views_count INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0,
    likes_count INTEGER DEFAULT 0,
    responses_count INTEGER DEFAULT 0,
    conversion_count INTEGER DEFAULT 0, -- leads generated from quote
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(quote_id, metric_date)
);

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_daily_quotes_agent_id ON lic_schema.daily_quotes(agent_id);
CREATE INDEX IF NOT EXISTS idx_daily_quotes_category ON lic_schema.daily_quotes(category);
CREATE INDEX IF NOT EXISTS idx_daily_quotes_active ON lic_schema.daily_quotes(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_daily_quotes_scheduled ON lic_schema.daily_quotes(scheduled_date);

CREATE INDEX IF NOT EXISTS idx_quote_sharing_quote_id ON lic_schema.quote_sharing_analytics(quote_id);
CREATE INDEX IF NOT EXISTS idx_quote_sharing_agent_id ON lic_schema.quote_sharing_analytics(agent_id);
CREATE INDEX IF NOT EXISTS idx_quote_sharing_platform ON lic_schema.quote_sharing_analytics(platform);

CREATE INDEX IF NOT EXISTS idx_quote_performance_quote_id ON lic_schema.quote_performance(quote_id);
CREATE INDEX IF NOT EXISTS idx_quote_performance_agent_id ON lic_schema.quote_performance(agent_id);
CREATE INDEX IF NOT EXISTS idx_quote_performance_date ON lic_schema.quote_performance(metric_date);

-- Updated at triggers
CREATE OR REPLACE FUNCTION update_daily_quotes_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_daily_quotes_updated_at
    BEFORE UPDATE ON lic_schema.daily_quotes
    FOR EACH ROW
    EXECUTE FUNCTION update_daily_quotes_updated_at();

-- Insert sample motivational quotes (global quotes without specific agent assignment)
INSERT INTO lic_schema.daily_quotes (quote_text, author, category, tags, branding_settings, is_global) VALUES
('Success is not final, failure is not fatal: It is the courage to continue that counts.', 'Winston Churchill', 'motivation', '["success", "failure", "courage"]', '{"font_family": "Roboto", "font_size": 18, "text_color": "#FFFFFF", "background_color": "#1E3A8A", "logo_position": "bottom_right"}', true),
('The only way to do great work is to love what you do.', 'Steve Jobs', 'work', '["work", "passion", "excellence"]', '{"font_family": "Poppins", "font_size": 20, "text_color": "#000000", "background_gradient": ["#F59E0B", "#D97706"], "logo_position": "top_left"}', true),
('Your time is limited, so don''t waste it living someone else''s life.', 'Steve Jobs', 'life', '["time", "life", "authenticity"]', '{"font_family": "Inter", "font_size": 19, "text_color": "#FFFFFF", "background_image": "inspirational_mountains.jpg", "logo_position": "center"}', true)
ON CONFLICT DO NOTHING;
