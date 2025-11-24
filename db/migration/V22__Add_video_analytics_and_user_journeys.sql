-- Agent Mitra - Migration V22: Add Video Analytics and User Journeys Tables
-- This migration adds the missing video_analytics and user_journeys tables from the design document

-- =====================================================
-- VIDEO ANALYTICS TABLE
-- =====================================================

-- Video watch analytics (tracks individual video watch sessions)
CREATE TABLE IF NOT EXISTS lic_schema.video_analytics (
    analytics_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    video_id UUID REFERENCES lic_schema.video_content(video_id) ON DELETE CASCADE,
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE SET NULL,

    -- Watch session
    watch_session_id UUID,
    started_at TIMESTAMP DEFAULT NOW(),
    ended_at TIMESTAMP,
    watch_duration_seconds INTEGER,

    -- Engagement metrics
    completed BOOLEAN DEFAULT false,
    paused_count INTEGER DEFAULT 0,
    seek_count INTEGER DEFAULT 0,
    quality_changes INTEGER DEFAULT 0,

    -- Device and context
    device_info JSONB,
    network_type VARCHAR(50),
    playback_quality VARCHAR(20),
    
    -- Additional metadata
    ip_address INET,
    user_agent TEXT,
    location_info JSONB,
    
    created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for video_analytics
CREATE INDEX IF NOT EXISTS idx_video_analytics_video_id ON lic_schema.video_analytics(video_id);
CREATE INDEX IF NOT EXISTS idx_video_analytics_user_id ON lic_schema.video_analytics(user_id);
CREATE INDEX IF NOT EXISTS idx_video_analytics_started_at ON lic_schema.video_analytics(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_video_analytics_watch_session ON lic_schema.video_analytics(watch_session_id) WHERE watch_session_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_video_analytics_completed ON lic_schema.video_analytics(completed, video_id);

-- =====================================================
-- USER JOURNEYS TABLE
-- =====================================================

-- User journey tracking (tracks user journeys through various processes)
CREATE TABLE IF NOT EXISTS lic_schema.user_journeys (
    journey_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,

    -- Journey metadata
    journey_type VARCHAR(100) NOT NULL, -- 'onboarding', 'policy_purchase', 'claim_process', 'profile_setup', etc.
    started_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP,
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'completed', 'abandoned', 'failed'

    -- Journey steps
    current_step INTEGER DEFAULT 1,
    total_steps INTEGER,
    step_history JSONB, -- Array of step objects with timestamps and metadata

    -- Conversion tracking
    converted BOOLEAN DEFAULT false,
    conversion_value DECIMAL(12,2),
    drop_off_step INTEGER,
    drop_off_reason TEXT,
    
    -- Additional metadata
    journey_data JSONB, -- Flexible storage for journey-specific data
    session_id UUID REFERENCES lic_schema.user_sessions(session_id) ON DELETE SET NULL,
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for user_journeys
CREATE INDEX IF NOT EXISTS idx_user_journeys_user_id ON lic_schema.user_journeys(user_id);
CREATE INDEX IF NOT EXISTS idx_user_journeys_type_status ON lic_schema.user_journeys(journey_type, status);
CREATE INDEX IF NOT EXISTS idx_user_journeys_started_at ON lic_schema.user_journeys(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_journeys_converted ON lic_schema.user_journeys(converted, journey_type) WHERE converted = true;
CREATE INDEX IF NOT EXISTS idx_user_journeys_status ON lic_schema.user_journeys(status) WHERE status = 'active';

-- JSONB indexes for flexible queries
CREATE INDEX IF NOT EXISTS idx_user_journeys_step_history ON lic_schema.user_journeys USING GIN(step_history) WHERE step_history IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_user_journeys_journey_data ON lic_schema.user_journeys USING GIN(journey_data) WHERE journey_data IS NOT NULL;

-- Comments for documentation
COMMENT ON TABLE lic_schema.video_analytics IS 'Tracks individual video watch sessions and engagement metrics';
COMMENT ON TABLE lic_schema.user_journeys IS 'Tracks user journeys through various processes like onboarding, policy purchase, etc.';

COMMENT ON COLUMN lic_schema.video_analytics.watch_session_id IS 'Unique identifier for a watch session (can be used to group multiple analytics records)';
COMMENT ON COLUMN lic_schema.video_analytics.completed IS 'Whether the user watched the video to completion';
COMMENT ON COLUMN lic_schema.video_analytics.paused_count IS 'Number of times the video was paused';
COMMENT ON COLUMN lic_schema.video_analytics.seek_count IS 'Number of times the user seeked/jumped in the video';

COMMENT ON COLUMN lic_schema.user_journeys.journey_type IS 'Type of journey: onboarding, policy_purchase, claim_process, etc.';
COMMENT ON COLUMN lic_schema.user_journeys.step_history IS 'JSONB array tracking each step with timestamp, action, and metadata';
COMMENT ON COLUMN lic_schema.user_journeys.converted IS 'Whether the journey resulted in a conversion (e.g., policy purchase)';
COMMENT ON COLUMN lic_schema.user_journeys.drop_off_step IS 'Step number where user abandoned the journey';

