-- Customer Portal Analytics and Engagement Tracking
CREATE TABLE IF NOT EXISTS lic_schema.customer_portal_sessions (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    session_start TIMESTAMP DEFAULT NOW(),
    session_end TIMESTAMP,
    duration_minutes INTEGER,
    device_info JSONB,
    ip_address INET,
    user_agent TEXT,
    pages_viewed JSONB, -- Array of page paths visited
    actions_taken JSONB, -- Array of actions performed
    created_at TIMESTAMP DEFAULT NOW()
);

-- Customer engagement metrics
CREATE TABLE IF NOT EXISTS lic_schema.customer_engagement_metrics (
    metric_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    metric_date DATE DEFAULT CURRENT_DATE,
    login_count INTEGER DEFAULT 0,
    page_views INTEGER DEFAULT 0,
    feature_usage JSONB, -- Count of feature usages
    session_duration_avg DECIMAL(8,2), -- Average session duration in minutes
    bounce_rate DECIMAL(5,2), -- Percentage of single-page sessions
    conversion_actions INTEGER DEFAULT 0, -- Number of conversion actions taken
    support_requests INTEGER DEFAULT 0,
    feedback_score DECIMAL(3,1), -- Average feedback score 1-5
    created_at TIMESTAMP DEFAULT NOW()
);

-- Customer portal preferences and personalization
CREATE TABLE IF NOT EXISTS lic_schema.customer_portal_preferences (
    preference_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    theme_preference VARCHAR(20) DEFAULT 'light',
    language_preference VARCHAR(10) DEFAULT 'en',
    notification_preferences JSONB,
    dashboard_layout JSONB, -- Saved dashboard widget positions
    quick_actions JSONB, -- User's favorite quick actions
    accessibility_settings JSONB, -- Screen reader, font size, etc.
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Customer feedback and satisfaction tracking
CREATE TABLE IF NOT EXISTS lic_schema.customer_feedback (
    feedback_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    session_id UUID REFERENCES lic_schema.customer_portal_sessions(session_id),
    feedback_type VARCHAR(50), -- 'rating', 'survey', 'complaint', 'suggestion'
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    feedback_text TEXT,
    category VARCHAR(100), -- 'usability', 'performance', 'features', 'support'
    page_context VARCHAR(255), -- Which page/screen the feedback is about
    user_mood VARCHAR(50), -- 'satisfied', 'neutral', 'frustrated'
    submitted_at TIMESTAMP DEFAULT NOW(),
    resolved BOOLEAN DEFAULT false,
    resolution_notes TEXT,
    resolved_at TIMESTAMP,
    resolved_by UUID REFERENCES lic_schema.users(user_id)
);

-- Customer journey tracking
CREATE TABLE IF NOT EXISTS lic_schema.customer_journey_events (
    event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    session_id UUID REFERENCES lic_schema.customer_portal_sessions(session_id),
    event_type VARCHAR(100), -- 'page_view', 'button_click', 'form_submit', 'feature_use'
    event_name VARCHAR(255), -- Specific event identifier
    page_url VARCHAR(500),
    element_identifier VARCHAR(255), -- CSS selector or component ID
    event_data JSONB, -- Additional event-specific data
    timestamp TIMESTAMP DEFAULT NOW(),
    user_journey_stage VARCHAR(50) -- 'onboarding', 'exploration', 'engagement', 'conversion'
);

-- Customer retention and churn prediction data
CREATE TABLE IF NOT EXISTS lic_schema.customer_retention_metrics (
    retention_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    metric_date DATE DEFAULT CURRENT_DATE,
    days_since_last_login INTEGER,
    login_frequency_score DECIMAL(5,2), -- 0-100 scale
    engagement_score DECIMAL(5,2), -- 0-100 scale
    feature_adoption_score DECIMAL(5,2), -- 0-100 scale
    support_ticket_count INTEGER DEFAULT 0,
    negative_feedback_count INTEGER DEFAULT 0,
    churn_risk_score DECIMAL(5,2), -- 0-100 scale, higher = more likely to churn
    predicted_churn_date DATE,
    retention_actions_taken JSONB, -- Array of retention actions applied
    created_at TIMESTAMP DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_customer_sessions_user_id ON lic_schema.customer_portal_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_customer_sessions_start ON lic_schema.customer_portal_sessions(session_start DESC);
CREATE INDEX IF NOT EXISTS idx_customer_sessions_end ON lic_schema.customer_portal_sessions(session_end);

CREATE INDEX IF NOT EXISTS idx_engagement_metrics_user_id ON lic_schema.customer_engagement_metrics(user_id);
CREATE INDEX IF NOT EXISTS idx_engagement_metrics_date ON lic_schema.customer_engagement_metrics(metric_date DESC);

CREATE INDEX IF NOT EXISTS idx_customer_preferences_user_id ON lic_schema.customer_portal_preferences(user_id);

CREATE INDEX IF NOT EXISTS idx_customer_feedback_user_id ON lic_schema.customer_feedback(user_id);
CREATE INDEX IF NOT EXISTS idx_customer_feedback_type ON lic_schema.customer_feedback(feedback_type);
CREATE INDEX IF NOT EXISTS idx_customer_feedback_rating ON lic_schema.customer_feedback(rating);
CREATE INDEX IF NOT EXISTS idx_customer_feedback_resolved ON lic_schema.customer_feedback(resolved);

CREATE INDEX IF NOT EXISTS idx_journey_events_user_id ON lic_schema.customer_journey_events(user_id);
CREATE INDEX IF NOT EXISTS idx_journey_events_session_id ON lic_schema.customer_journey_events(session_id);
CREATE INDEX IF NOT EXISTS idx_journey_events_type ON lic_schema.customer_journey_events(event_type);
CREATE INDEX IF NOT EXISTS idx_journey_events_timestamp ON lic_schema.customer_journey_events(timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_retention_metrics_user_id ON lic_schema.customer_retention_metrics(user_id);
CREATE INDEX IF NOT EXISTS idx_retention_metrics_date ON lic_schema.customer_retention_metrics(metric_date DESC);
CREATE INDEX IF NOT EXISTS idx_retention_metrics_churn_risk ON lic_schema.customer_retention_metrics(churn_risk_score DESC);

-- Updated at triggers
CREATE OR REPLACE FUNCTION update_customer_preferences_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_customer_preferences_updated_at
    BEFORE UPDATE ON lic_schema.customer_portal_preferences
    FOR EACH ROW
    EXECUTE FUNCTION update_customer_preferences_updated_at();

-- Insert sample customer portal preferences (skip if no users exist - will be populated when users register)
-- This migration creates the tables but doesn't insert sample data that would violate foreign key constraints
-- Sample data can be inserted via application seeding or separate migration after users are created
