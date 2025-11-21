-- Migration V10: Create Advanced Analytics Tables
-- This migration adds comprehensive analytics tables for business intelligence and reporting

-- =====================================================
-- ANALYTICS AGGREGATION TABLES
-- =====================================================

-- Daily agent performance metrics (materialized view for fast queries)
CREATE TABLE lic_schema.agent_daily_metrics (
    metric_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    metric_date DATE NOT NULL,

    -- Performance metrics
    policies_sold INTEGER DEFAULT 0,
    premium_collected DECIMAL(15,2) DEFAULT 0,
    active_policyholders INTEGER DEFAULT 0,
    new_customers INTEGER DEFAULT 0,

    -- Financial metrics
    commission_earned DECIMAL(12,2) DEFAULT 0,
    target_achievement DECIMAL(5,2) DEFAULT 0, -- percentage

    -- Customer metrics
    customer_satisfaction_score DECIMAL(3,2),
    conversion_rate DECIMAL(5,2), -- percentage

    -- Activity metrics
    presentations_viewed INTEGER DEFAULT 0,
    cta_clicks INTEGER DEFAULT 0,
    whatsapp_messages_sent INTEGER DEFAULT 0,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    UNIQUE(agent_id, metric_date)
);

-- Monthly agent performance summary
CREATE TABLE lic_schema.agent_monthly_summary (
    summary_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    summary_month DATE NOT NULL, -- first day of month

    -- Aggregated metrics
    total_policies INTEGER DEFAULT 0,
    total_premium DECIMAL(15,2) DEFAULT 0,
    total_commission DECIMAL(12,2) DEFAULT 0,
    active_customers INTEGER DEFAULT 0,

    -- Trends
    growth_rate DECIMAL(5,2), -- percentage month-over-month
    retention_rate DECIMAL(5,2), -- percentage

    -- Rankings
    rank_by_premium INTEGER,
    rank_by_policies INTEGER,

    created_at TIMESTAMP DEFAULT NOW(),

    UNIQUE(agent_id, summary_month)
);

-- Revenue forecasting table
CREATE TABLE lic_schema.revenue_forecasts (
    forecast_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    forecast_period VARCHAR(20) NOT NULL, -- 'monthly', 'quarterly', 'yearly'
    forecast_date DATE NOT NULL,
    target_date DATE NOT NULL,

    -- Forecast data
    predicted_revenue DECIMAL(15,2) NOT NULL,
    predicted_commission DECIMAL(12,2),
    confidence_level DECIMAL(3,2), -- 0-1

    -- Actual vs predicted (filled after period ends)
    actual_revenue DECIMAL(15,2),
    actual_commission DECIMAL(12,2),
    forecast_accuracy DECIMAL(5,2), -- percentage

    -- Metadata
    forecast_method VARCHAR(50) DEFAULT 'linear_regression',
    created_by UUID REFERENCES lic_schema.users(user_id),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Policy analytics aggregation
CREATE TABLE lic_schema.policy_analytics_summary (
    summary_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    summary_date DATE NOT NULL,
    summary_period VARCHAR(20) DEFAULT 'daily', -- 'daily', 'weekly', 'monthly'

    -- Policy status counts
    draft_policies INTEGER DEFAULT 0,
    pending_policies INTEGER DEFAULT 0,
    approved_policies INTEGER DEFAULT 0,
    active_policies INTEGER DEFAULT 0,
    lapsed_policies INTEGER DEFAULT 0,
    cancelled_policies INTEGER DEFAULT 0,

    -- Category breakdown
    life_policies INTEGER DEFAULT 0,
    health_policies INTEGER DEFAULT 0,
    general_policies INTEGER DEFAULT 0,

    -- Premium metrics
    total_premium DECIMAL(15,2) DEFAULT 0,
    average_premium DECIMAL(12,2) DEFAULT 0,

    -- Conversion metrics
    applications_received INTEGER DEFAULT 0,
    applications_approved INTEGER DEFAULT 0,
    conversion_rate DECIMAL(5,2) DEFAULT 0,

    created_at TIMESTAMP DEFAULT NOW(),

    UNIQUE(summary_date, summary_period)
);

-- Customer behavior analytics
CREATE TABLE lic_schema.customer_behavior_metrics (
    metric_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES lic_schema.policyholders(policyholder_id),
    metric_date DATE NOT NULL,

    -- Engagement metrics
    login_count INTEGER DEFAULT 0,
    page_views INTEGER DEFAULT 0,
    session_duration INTEGER DEFAULT 0, -- seconds

    -- Policy interactions
    policy_views INTEGER DEFAULT 0,
    premium_payments INTEGER DEFAULT 0,
    claims_submitted INTEGER DEFAULT 0,

    -- Communication preferences
    email_opens INTEGER DEFAULT 0,
    whatsapp_messages INTEGER DEFAULT 0,
    support_tickets INTEGER DEFAULT 0,

    -- Risk metrics
    churn_probability DECIMAL(3,2),
    upgrade_probability DECIMAL(3,2),

    created_at TIMESTAMP DEFAULT NOW(),

    UNIQUE(customer_id, metric_date)
);

-- =====================================================
-- AUDIT AND COMPLIANCE TABLES
-- =====================================================

-- Analytics query audit log
CREATE TABLE lic_schema.analytics_query_log (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id),
    query_type VARCHAR(50) NOT NULL, -- 'dashboard', 'report', 'export'
    query_parameters JSONB,

    -- Performance metrics
    execution_time_ms INTEGER,
    records_returned INTEGER,

    -- Security
    ip_address INET,
    user_agent TEXT,

    -- Compliance
    data_classification VARCHAR(20) DEFAULT 'internal', -- 'public', 'internal', 'confidential'
    access_reason TEXT,

    created_at TIMESTAMP DEFAULT NOW()
);

-- Data export log for compliance
CREATE TABLE lic_schema.data_export_log (
    export_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id),
    export_type VARCHAR(50) NOT NULL, -- 'csv', 'pdf', 'excel'

    -- Export details
    record_count INTEGER NOT NULL,
    data_types TEXT[], -- array of exported data types
    date_range TSRANGE,

    -- Security
    encryption_used BOOLEAN DEFAULT true,
    ip_address INET,

    -- Compliance
    purpose VARCHAR(100),
    retention_period_days INTEGER DEFAULT 90,

    -- File tracking
    file_name VARCHAR(255),
    file_size_bytes BIGINT,
    storage_location VARCHAR(500),

    created_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP
);

-- =====================================================
-- KNOWLEDGE BASE TABLES
-- =====================================================

-- Knowledge base articles (enhanced)
CREATE TABLE lic_schema.knowledge_base_articles (
    article_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(500) NOT NULL,
    content TEXT NOT NULL,
    summary TEXT, -- auto-generated summary

    -- Categorization
    category VARCHAR(100) NOT NULL,
    sub_category VARCHAR(100),
    tags TEXT[],

    -- Content metadata
    content_type VARCHAR(50) DEFAULT 'text', -- 'text', 'faq', 'guide', 'video'
    language VARCHAR(10) DEFAULT 'en',
    difficulty_level VARCHAR(20) DEFAULT 'intermediate', -- 'beginner', 'intermediate', 'advanced'

    -- AI metadata (stored as JSONB for flexibility)
    embedding_vector JSONB, -- OpenAI ada-002 embedding as JSON array
    keywords_extracted TEXT[],
    related_articles UUID[],

    -- Usage tracking
    view_count INTEGER DEFAULT 0,
    helpful_votes INTEGER DEFAULT 0,
    total_votes INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2),

    -- Status
    is_active BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    moderation_status VARCHAR(20) DEFAULT 'approved', -- 'pending', 'approved', 'rejected'

    -- Audit
    created_by UUID REFERENCES lic_schema.users(user_id),
    moderated_by UUID REFERENCES lic_schema.users(user_id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    published_at TIMESTAMP
);

-- Knowledge base search log
CREATE TABLE lic_schema.knowledge_search_log (
    search_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id),
    session_id UUID REFERENCES lic_schema.chatbot_sessions(session_id),

    -- Search details
    search_query TEXT NOT NULL,
    search_filters JSONB, -- category, language, etc.

    -- Results
    results_count INTEGER DEFAULT 0,
    clicked_article_id UUID REFERENCES lic_schema.knowledge_base_articles(article_id),
    search_time_ms INTEGER,

    -- Context
    search_source VARCHAR(50) DEFAULT 'manual', -- 'manual', 'chatbot', 'api'
    ip_address INET,

    created_at TIMESTAMP DEFAULT NOW()
);

-- Chatbot intent training data
CREATE TABLE lic_schema.chatbot_intents (
    intent_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    intent_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,

    -- Training data
    training_examples TEXT[] NOT NULL,
    response_templates TEXT[] NOT NULL,

    -- Configuration
    confidence_threshold DECIMAL(3,2) DEFAULT 0.7,
    is_active BOOLEAN DEFAULT true,

    -- Usage statistics
    usage_count INTEGER DEFAULT 0,
    success_rate DECIMAL(5,2),
    average_confidence DECIMAL(3,2),

    -- Metadata
    created_by UUID REFERENCES lic_schema.users(user_id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Enhanced chatbot analytics
CREATE TABLE lic_schema.chatbot_analytics_summary (
    analytics_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    summary_date DATE NOT NULL,
    summary_period VARCHAR(20) DEFAULT 'daily',

    -- Session metrics
    total_sessions INTEGER DEFAULT 0,
    completed_sessions INTEGER DEFAULT 0,
    abandoned_sessions INTEGER DEFAULT 0,

    -- Message metrics
    total_messages INTEGER DEFAULT 0,
    average_messages_per_session DECIMAL(5,2),

    -- Performance metrics
    average_response_time_ms INTEGER,
    resolution_rate DECIMAL(5,2),
    escalation_rate DECIMAL(5,2),

    -- User satisfaction
    average_satisfaction DECIMAL(3,2),
    satisfaction_responses INTEGER DEFAULT 0,

    -- Intent distribution (top 10)
    top_intents JSONB,

    created_at TIMESTAMP DEFAULT NOW(),

    UNIQUE(summary_date, summary_period)
);

-- =====================================================
-- MATERIALIZED VIEWS FOR PERFORMANCE
-- =====================================================

-- Daily dashboard KPIs (materialized view)
CREATE MATERIALIZED VIEW lic_schema.daily_dashboard_kpis AS
SELECT
    CURRENT_DATE as report_date,
    COUNT(DISTINCT p.policy_id) as total_policies,
    COUNT(DISTINCT CASE WHEN p.status = 'active' THEN p.policy_id END) as active_policies,
    COALESCE(SUM(CASE WHEN p.status IN ('active', 'approved') THEN p.premium_amount END), 0) as total_premium,
    COUNT(DISTINCT ph.policyholder_id) as total_customers,
    COUNT(DISTINCT CASE WHEN p.start_date >= CURRENT_DATE - INTERVAL '30 days' THEN ph.policyholder_id END) as new_customers_30d,
    COUNT(DISTINCT CASE WHEN p.start_date >= CURRENT_DATE - INTERVAL '7 days' THEN ph.policyholder_id END) as new_customers_7d
FROM lic_schema.insurance_policies p
LEFT JOIN lic_schema.policyholders ph ON p.policyholder_id = ph.policyholder_id
WHERE p.created_at >= CURRENT_DATE - INTERVAL '30 days';

-- Agent leaderboard (materialized view)
CREATE MATERIALIZED VIEW lic_schema.agent_leaderboard AS
SELECT
    a.agent_id,
    u.first_name,
    u.last_name,
    u.display_name,
    COUNT(p.policy_id) as total_policies,
    COALESCE(SUM(p.premium_amount), 0) as total_premium,
    COUNT(DISTINCT ph.policyholder_id) as active_customers,
    ROW_NUMBER() OVER (ORDER BY SUM(p.premium_amount) DESC NULLS LAST) as rank_by_premium,
    ROW_NUMBER() OVER (ORDER BY COUNT(p.policy_id) DESC) as rank_by_policies
FROM lic_schema.agents a
JOIN lic_schema.users u ON a.user_id = u.user_id
LEFT JOIN lic_schema.insurance_policies p ON a.agent_id = p.agent_id AND p.status IN ('active', 'approved')
LEFT JOIN lic_schema.policyholders ph ON p.policyholder_id = ph.policyholder_id
WHERE a.status = 'active'
GROUP BY a.agent_id, u.first_name, u.last_name, u.display_name;

-- =====================================================
-- INDEXES FOR ANALYTICS PERFORMANCE
-- =====================================================

-- Agent daily metrics indexes
CREATE INDEX idx_agent_metrics_date ON lic_schema.agent_daily_metrics(metric_date DESC);
CREATE INDEX idx_agent_metrics_agent_date ON lic_schema.agent_daily_metrics(agent_id, metric_date DESC);

-- Agent monthly summary indexes
CREATE INDEX idx_agent_summary_month ON lic_schema.agent_monthly_summary(summary_month DESC);
CREATE INDEX idx_agent_summary_agent_month ON lic_schema.agent_monthly_summary(agent_id, summary_month DESC);

-- Revenue forecast indexes
CREATE INDEX idx_revenue_forecast_date ON lic_schema.revenue_forecasts(forecast_date DESC);
CREATE INDEX idx_revenue_forecast_agent ON lic_schema.revenue_forecasts(agent_id, forecast_date DESC);

-- Policy analytics indexes
CREATE INDEX idx_policy_analytics_date ON lic_schema.policy_analytics_summary(summary_date DESC);
CREATE INDEX idx_policy_analytics_period ON lic_schema.policy_analytics_summary(summary_period, summary_date DESC);

-- Customer behavior indexes
CREATE INDEX idx_customer_behavior_date ON lic_schema.customer_behavior_metrics(metric_date DESC);
CREATE INDEX idx_customer_behavior_customer ON lic_schema.customer_behavior_metrics(customer_id, metric_date DESC);

-- Audit log indexes
CREATE INDEX idx_analytics_query_user ON lic_schema.analytics_query_log(user_id, created_at DESC);
CREATE INDEX idx_analytics_query_type ON lic_schema.analytics_query_log(query_type, created_at DESC);
CREATE INDEX idx_data_export_user ON lic_schema.data_export_log(user_id, created_at DESC);

-- Knowledge base indexes
CREATE INDEX idx_kb_articles_category ON lic_schema.knowledge_base_articles(category, is_active);
CREATE INDEX idx_kb_articles_tags ON lic_schema.knowledge_base_articles USING GIN(tags);
-- Note: For production, consider using pgvector extension for semantic search
-- CREATE INDEX idx_kb_articles_embedding ON lic_schema.knowledge_base_articles USING ivfflat(embedding_vector vector_cosine_ops) WITH (lists = 100);
CREATE INDEX idx_kb_search_query ON lic_schema.knowledge_search_log USING GIN(to_tsvector('english', search_query));
CREATE INDEX idx_kb_search_user ON lic_schema.knowledge_search_log(user_id, created_at DESC);

-- Chatbot analytics indexes
CREATE INDEX idx_chatbot_intents_active ON lic_schema.chatbot_intents(intent_name) WHERE is_active = true;
CREATE INDEX idx_chatbot_analytics_date ON lic_schema.chatbot_analytics_summary(summary_date DESC);

-- Materialized view refresh indexes
CREATE INDEX idx_daily_kpis_date ON lic_schema.daily_dashboard_kpis(report_date);
CREATE INDEX idx_agent_leaderboard_rank ON lic_schema.agent_leaderboard(rank_by_premium);

-- =====================================================
-- FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to update agent daily metrics
CREATE OR REPLACE FUNCTION lic_schema.update_agent_daily_metrics()
RETURNS TRIGGER AS $$
BEGIN
    -- Update or insert daily metrics when policies are modified
    INSERT INTO lic_schema.agent_daily_metrics (
        agent_id, metric_date, policies_sold, premium_collected,
        active_policyholders, new_customers
    )
    SELECT
        p.agent_id,
        CURRENT_DATE,
        COUNT(CASE WHEN p.created_at::date = CURRENT_DATE THEN 1 END),
        COALESCE(SUM(CASE WHEN p.created_at::date = CURRENT_DATE THEN p.premium_amount END), 0),
        COUNT(DISTINCT ph.policyholder_id),
        COUNT(DISTINCT CASE WHEN p.start_date::date = CURRENT_DATE THEN ph.policyholder_id END)
    FROM lic_schema.insurance_policies p
    LEFT JOIN lic_schema.policyholders ph ON p.policyholder_id = ph.policyholder_id
    WHERE p.agent_id = COALESCE(NEW.agent_id, OLD.agent_id)
    AND p.status IN ('active', 'approved')
    GROUP BY p.agent_id
    ON CONFLICT (agent_id, metric_date)
    DO UPDATE SET
        policies_sold = EXCLUDED.policies_sold,
        premium_collected = EXCLUDED.premium_collected,
        active_policyholders = EXCLUDED.active_policyholders,
        new_customers = EXCLUDED.new_customers,
        updated_at = NOW();

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Trigger to update agent metrics on policy changes
CREATE TRIGGER update_agent_metrics_trigger
    AFTER INSERT OR UPDATE OR DELETE ON lic_schema.insurance_policies
    FOR EACH ROW
    EXECUTE FUNCTION lic_schema.update_agent_daily_metrics();

-- Function to log analytics queries
CREATE OR REPLACE FUNCTION lic_schema.log_analytics_query(
    p_user_id UUID,
    p_query_type VARCHAR(50),
    p_query_params JSONB DEFAULT NULL,
    p_execution_time INTEGER DEFAULT NULL,
    p_records_returned INTEGER DEFAULT NULL,
    p_ip_address INET DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO lic_schema.analytics_query_log (
        user_id, query_type, query_parameters, execution_time_ms,
        records_returned, ip_address, user_agent
    ) VALUES (
        p_user_id, p_query_type, p_query_params, p_execution_time,
        p_records_returned, p_ip_address, p_user_agent
    );
END;
$$ LANGUAGE plpgsql;

-- Function to refresh materialized views
CREATE OR REPLACE FUNCTION lic_schema.refresh_analytics_views()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY lic_schema.daily_dashboard_kpis;
    REFRESH MATERIALIZED VIEW CONCURRENTLY lic_schema.agent_leaderboard;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- DATA POPULATION (INITIAL SEED)
-- =====================================================

-- Insert sample knowledge base articles
INSERT INTO lic_schema.knowledge_base_articles (
    title, content, category, tags, content_type, difficulty_level,
    is_featured, created_by
) VALUES
(
    'Life Insurance Basics: What You Need to Know',
    'Life insurance is a contract between you and an insurance company. In exchange for premium payments, the insurance company provides a lump-sum payment, known as a death benefit, to beneficiaries when the insured passes away...',
    'life_insurance',
    ARRAY['basics', 'fundamentals', 'beginners'],
    'guide',
    'beginner',
    true,
    (SELECT user_id FROM lic_schema.users WHERE role = 'super_admin' LIMIT 1)
),
(
    'How to File an Insurance Claim',
    'Filing an insurance claim can seem daunting, but following these steps will help you through the process smoothly...',
    'claims',
    ARRAY['claims', 'procedures', 'help'],
    'guide',
    'intermediate',
    true,
    (SELECT user_id FROM lic_schema.users WHERE role = 'super_admin' LIMIT 1)
);

-- Insert sample chatbot intents
INSERT INTO lic_schema.chatbot_intents (
    intent_name, description, training_examples, response_templates
) VALUES
(
    'policy_inquiry',
    'User is asking about policy details, status, or information',
    ARRAY[
        'What is the status of my policy?',
        'Can you tell me about my life insurance policy?',
        'I need information about policy number POL123',
        'When does my policy expire?'
    ],
    ARRAY[
        'I can help you with information about your policy. Could you please provide your policy number?',
        'To check your policy status, I need your policy number or some identifying information.',
        'I''d be happy to help you with your policy inquiry. What specific information are you looking for?'
    ]
),
(
    'premium_payment',
    'User wants to know about or make premium payments',
    ARRAY[
        'How do I pay my premium?',
        'When is my next premium due?',
        'I want to make a payment',
        'What payment methods do you accept?'
    ],
    ARRAY[
        'You can pay your premium through various methods including online banking, UPI, credit/debit cards, and cash at our branches.',
        'Your next premium payment is due on [date]. You can pay online through our portal or mobile app.',
        'We accept payments through net banking, UPI (Google Pay, PhonePe, Paytm), credit/debit cards, and cash payments.'
    ]
);

-- =====================================================
-- PERMISSIONS AND SECURITY
-- =====================================================

-- Note: Configure appropriate permissions based on your role-based access control setup
-- Example grants (uncomment and modify as needed):
-- GRANT SELECT ON lic_schema.agent_daily_metrics TO analyst_role;
-- GRANT SELECT ON lic_schema.knowledge_base_articles TO chatbot_role;
-- GRANT SELECT, INSERT, UPDATE ON lic_schema.analytics_query_log TO audit_role;

-- Comments for documentation
COMMENT ON TABLE lic_schema.agent_daily_metrics IS 'Daily aggregated performance metrics for agents';
COMMENT ON TABLE lic_schema.revenue_forecasts IS 'Revenue and commission forecasting data';
COMMENT ON TABLE lic_schema.knowledge_base_articles IS 'AI-powered knowledge base for chatbot and user support';
COMMENT ON TABLE lic_schema.chatbot_analytics_summary IS 'Daily/weekly/monthly chatbot performance analytics';
COMMENT ON MATERIALIZED VIEW lic_schema.daily_dashboard_kpis IS 'Pre-computed dashboard KPIs for fast loading';
COMMENT ON MATERIALIZED VIEW lic_schema.agent_leaderboard IS 'Real-time agent performance rankings';
