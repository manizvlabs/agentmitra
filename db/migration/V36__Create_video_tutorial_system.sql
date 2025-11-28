-- ========================================
-- Video Tutorial System Migration
-- ========================================
-- Creates tables for comprehensive video tutorial management,
-- agent content creation, and learning path functionality

-- ========================================
-- Video Categories Table
-- ========================================
CREATE TABLE IF NOT EXISTS video_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    parent_category_id UUID REFERENCES video_categories(id),
    level INTEGER DEFAULT 1,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    video_count INTEGER DEFAULT 0,
    total_views INTEGER DEFAULT 0,
    icon_name VARCHAR(100),
    color_code VARCHAR(7),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- Video Tutorials Table
-- ========================================
CREATE TABLE IF NOT EXISTS video_tutorials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    video_id VARCHAR(255) UNIQUE NOT NULL,
    content_id UUID NOT NULL REFERENCES lic_schema.video_content(video_id) ON DELETE CASCADE,
    youtube_video_id VARCHAR(50),
    youtube_url VARCHAR(500),
    title VARCHAR(500) NOT NULL,
    description TEXT,
    duration_seconds INTEGER,
    language VARCHAR(10) DEFAULT 'en',
    category VARCHAR(100) NOT NULL,
    sub_category VARCHAR(100),
    difficulty_level VARCHAR(20) DEFAULT 'beginner',
    target_audience JSONB,
    policy_types JSONB,
    agent_id UUID NOT NULL,
    agent_name VARCHAR(255) NOT NULL,
    processing_status VARCHAR(50) DEFAULT 'pending',
    youtube_upload_status VARCHAR(50),
    transcription_status VARCHAR(50),
    view_count INTEGER DEFAULT 0,
    completion_rate DECIMAL(5,2) DEFAULT 0.00,
    average_watch_time DECIMAL(10,2),
    engagement_score DECIMAL(5,2) DEFAULT 0.00,
    rating DECIMAL(3,2),
    rating_count INTEGER DEFAULT 0,
    is_featured BOOLEAN DEFAULT false,
    learning_path_order INTEGER,
    prerequisites JSONB,
    original_language VARCHAR(10) DEFAULT 'en',
    available_languages JSONB,
    translation_status VARCHAR(50),
    search_tags JSONB,
    keywords JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_by UUID
);

-- ========================================
-- Video Progress Tracking Table
-- ========================================
CREATE TABLE IF NOT EXISTS video_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    video_id UUID NOT NULL REFERENCES video_tutorials(id) ON DELETE CASCADE,
    watch_time_seconds DECIMAL(10,2) DEFAULT 0.00,
    completion_percentage DECIMAL(5,2) DEFAULT 0.00,
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP WITH TIME ZONE,
    play_count INTEGER DEFAULT 0,
    last_watched_at TIMESTAMP WITH TIME ZONE,
    watch_sessions JSONB,
    learning_path_id VARCHAR(255),
    next_recommended_video_id UUID,
    user_rating INTEGER CHECK (user_rating >= 1 AND user_rating <= 5),
    is_bookmarked BOOLEAN DEFAULT false,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- Video Recommendations Table
-- ========================================
CREATE TABLE IF NOT EXISTS video_recommendations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    video_id UUID NOT NULL REFERENCES video_tutorials(id) ON DELETE CASCADE,
    recommendation_type VARCHAR(50) NOT NULL,
    trigger_source VARCHAR(50),
    trigger_query VARCHAR(500),
    relevance_score DECIMAL(5,2) DEFAULT 0.00,
    confidence_score DECIMAL(5,2) DEFAULT 0.00,
    ranking_position INTEGER,
    intent_match_score DECIMAL(5,2) DEFAULT 0.00,
    learning_history_score DECIMAL(5,2) DEFAULT 0.00,
    policy_context_score DECIMAL(5,2) DEFAULT 0.00,
    agent_expertise_score DECIMAL(5,2) DEFAULT 0.00,
    content_freshness_score DECIMAL(5,2) DEFAULT 0.00,
    was_viewed BOOLEAN DEFAULT false,
    viewed_at TIMESTAMP WITH TIME ZONE,
    was_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP WITH TIME ZONE,
    user_feedback VARCHAR(20),
    recommendation_context JSONB,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- Learning Paths Table
-- ========================================
CREATE TABLE IF NOT EXISTS learning_paths (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    path_id VARCHAR(255) UNIQUE NOT NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    target_audience JSONB,
    policy_types JSONB,
    difficulty_level VARCHAR(20) DEFAULT 'beginner',
    estimated_duration_hours DECIMAL(5,2),
    video_sequence JSONB,
    prerequisites JSONB,
    is_active BOOLEAN DEFAULT true,
    total_enrollments INTEGER DEFAULT 0,
    completion_rate DECIMAL(5,2) DEFAULT 0.00,
    average_completion_days DECIMAL(5,2),
    created_by_agent_id UUID NOT NULL,
    last_updated_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- Indexes for Performance
-- ========================================
-- Video Tutorials Indexes
CREATE INDEX IF NOT EXISTS idx_video_tutorials_video_id ON video_tutorials(video_id);
CREATE INDEX IF NOT EXISTS idx_video_tutorials_agent_id ON video_tutorials(agent_id);
CREATE INDEX IF NOT EXISTS idx_video_tutorials_category ON video_tutorials(category);
CREATE INDEX IF NOT EXISTS idx_video_tutorials_language ON video_tutorials(language);
CREATE INDEX IF NOT EXISTS idx_video_tutorials_processing_status ON video_tutorials(processing_status);
CREATE INDEX IF NOT EXISTS idx_video_tutorials_featured ON video_tutorials(is_featured) WHERE is_featured = true;
CREATE INDEX IF NOT EXISTS idx_video_tutorials_created_at ON video_tutorials(created_at DESC);

-- Video Progress Indexes
CREATE INDEX IF NOT EXISTS idx_video_progress_user_id ON video_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_video_progress_video_id ON video_progress(video_id);
CREATE INDEX IF NOT EXISTS idx_video_progress_user_video ON video_progress(user_id, video_id);
CREATE INDEX IF NOT EXISTS idx_video_progress_completed ON video_progress(is_completed) WHERE is_completed = true;
CREATE INDEX IF NOT EXISTS idx_video_progress_last_watched ON video_progress(last_watched_at DESC);

-- Video Recommendations Indexes
CREATE INDEX IF NOT EXISTS idx_video_recommendations_user_id ON video_recommendations(user_id);
CREATE INDEX IF NOT EXISTS idx_video_recommendations_video_id ON video_recommendations(video_id);
CREATE INDEX IF NOT EXISTS idx_video_recommendations_user_video ON video_recommendations(user_id, video_id);
CREATE INDEX IF NOT EXISTS idx_video_recommendations_type ON video_recommendations(recommendation_type);
CREATE INDEX IF NOT EXISTS idx_video_recommendations_relevance ON video_recommendations(relevance_score DESC);

-- Video Categories Indexes
CREATE INDEX IF NOT EXISTS idx_video_categories_category_id ON video_categories(category_id);
CREATE INDEX IF NOT EXISTS idx_video_categories_parent ON video_categories(parent_category_id);
CREATE INDEX IF NOT EXISTS idx_video_categories_active ON video_categories(is_active) WHERE is_active = true;

-- Learning Paths Indexes
CREATE INDEX IF NOT EXISTS idx_learning_paths_path_id ON learning_paths(path_id);
CREATE INDEX IF NOT EXISTS idx_learning_paths_active ON learning_paths(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_learning_paths_agent ON learning_paths(created_by_agent_id);

-- ========================================
-- Full Text Search Indexes
-- ========================================
-- Video Tutorials Full Text Search
CREATE INDEX IF NOT EXISTS idx_video_tutorials_search_title ON video_tutorials USING gin(to_tsvector('english', title));
CREATE INDEX IF NOT EXISTS idx_video_tutorials_search_description ON video_tutorials USING gin(to_tsvector('english', description));
CREATE INDEX IF NOT EXISTS idx_video_tutorials_search_tags ON video_tutorials USING gin(search_tags);

-- ========================================
-- Foreign Key Constraints
-- ========================================
-- Ensure foreign key constraints are properly set
ALTER TABLE video_progress DROP CONSTRAINT IF EXISTS fk_video_progress_video_id;
ALTER TABLE video_progress ADD CONSTRAINT fk_video_progress_video_id 
    FOREIGN KEY (video_id) REFERENCES video_tutorials(id) ON DELETE CASCADE;

ALTER TABLE video_recommendations DROP CONSTRAINT IF EXISTS fk_video_recommendations_video_id;
ALTER TABLE video_recommendations ADD CONSTRAINT fk_video_recommendations_video_id 
    FOREIGN KEY (video_id) REFERENCES video_tutorials(id) ON DELETE CASCADE;

ALTER TABLE video_tutorials DROP CONSTRAINT IF EXISTS fk_video_tutorials_content_id;
ALTER TABLE video_tutorials ADD CONSTRAINT fk_video_tutorials_content_id
    FOREIGN KEY (content_id) REFERENCES lic_schema.video_content(video_id) ON DELETE CASCADE;

-- ========================================
-- Triggers for Updated At
-- ========================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers for updated_at columns
DROP TRIGGER IF EXISTS update_video_tutorials_updated_at ON video_tutorials;
CREATE TRIGGER update_video_tutorials_updated_at
    BEFORE UPDATE ON video_tutorials
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_video_progress_updated_at ON video_progress;
CREATE TRIGGER update_video_progress_updated_at
    BEFORE UPDATE ON video_progress
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_video_recommendations_updated_at ON video_recommendations;
CREATE TRIGGER update_video_recommendations_updated_at
    BEFORE UPDATE ON video_recommendations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_learning_paths_updated_at ON learning_paths;
CREATE TRIGGER update_learning_paths_updated_at
    BEFORE UPDATE ON learning_paths
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_video_categories_updated_at ON video_categories;
CREATE TRIGGER update_video_categories_updated_at
    BEFORE UPDATE ON video_categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- Seed Initial Video Categories
-- ========================================
INSERT INTO video_categories (category_id, name, description, level, sort_order, icon_name, color_code) VALUES
('insurance_fundamentals', 'Insurance Fundamentals', 'Core concepts and basics of insurance', 1, 1, 'book-open', '#3B82F6'),
('policy_management', 'Policy Management', 'Managing and maintaining insurance policies', 1, 2, 'clipboard-list', '#10B981'),
('financial_planning', 'Financial Planning', 'Investment strategies and financial planning', 1, 3, 'trending-up', '#F59E0B'),
('technical_support', 'Technical Support', 'App usage and technical assistance', 1, 4, 'support', '#EF4444'),
('agent_content', 'Agent Content', 'Custom content created by insurance agents', 1, 5, 'user-circle', '#8B5CF6')
ON CONFLICT (category_id) DO NOTHING;

-- ========================================
-- Permissions for Video Tutorial System
-- ========================================
-- Note: RBAC permissions should be added through the RBAC system
-- This migration creates the database structure only
