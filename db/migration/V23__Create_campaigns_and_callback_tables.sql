-- Agent Mitra - Migration V23: Create Marketing Campaigns and Callback Management Tables
-- This migration creates tables for marketing campaigns, campaign automation, and callback request management

-- =====================================================
-- CAMPAIGN MANAGEMENT TABLES
-- =====================================================

-- Campaign status enumeration
CREATE TYPE lic_schema.campaign_status_enum AS ENUM (
    'draft', 'scheduled', 'active', 'paused', 'completed', 'cancelled'
);

-- Campaign type enumeration
CREATE TYPE lic_schema.campaign_type_enum AS ENUM (
    'acquisition', 'retention', 'upselling', 'behavioral'
);

-- Campaign channel enumeration
CREATE TYPE lic_schema.campaign_channel_enum AS ENUM (
    'whatsapp', 'sms', 'email', 'push', 'multi_channel'
);

-- Marketing campaigns table
CREATE TABLE IF NOT EXISTS lic_schema.campaigns (
    campaign_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.agents(agent_id) ON DELETE CASCADE,
    
    -- Campaign basic information
    campaign_name VARCHAR(255) NOT NULL,
    campaign_type lic_schema.campaign_type_enum NOT NULL,
    campaign_goal VARCHAR(100), -- 'lead_generation', 'policy_sales', 'renewal_rate', 'engagement'
    description TEXT,
    
    -- Campaign content
    subject VARCHAR(500), -- For email/SMS
    message TEXT NOT NULL,
    message_template_id UUID, -- Reference to template if used
    personalization_tags TEXT[], -- Available tags like {{customer_name}}
    attachments JSONB, -- Array of attachment URLs/metadata
    
    -- Channel configuration
    primary_channel lic_schema.campaign_channel_enum NOT NULL DEFAULT 'whatsapp',
    channels TEXT[], -- Multi-channel campaigns
    
    -- Targeting and segmentation
    target_audience VARCHAR(50) DEFAULT 'all', -- 'all', 'active', 'lapsed', 'prospects'
    selected_segments TEXT[], -- Customer segment IDs
    targeting_rules JSONB, -- Advanced targeting rules
    estimated_reach INTEGER DEFAULT 0,
    
    -- Scheduling
    schedule_type VARCHAR(50) DEFAULT 'immediate', -- 'immediate', 'scheduled', 'automated'
    scheduled_at TIMESTAMP,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    
    -- Automation
    is_automated BOOLEAN DEFAULT false,
    automation_triggers JSONB, -- Trigger conditions
    
    -- Budget and cost
    budget DECIMAL(12,2) DEFAULT 0,
    estimated_cost DECIMAL(12,2) DEFAULT 0,
    cost_per_recipient DECIMAL(10,4) DEFAULT 0,
    
    -- A/B Testing
    ab_testing_enabled BOOLEAN DEFAULT false,
    ab_test_variants JSONB, -- A/B test variants
    
    -- Status and lifecycle
    status lic_schema.campaign_status_enum DEFAULT 'draft',
    launched_at TIMESTAMP,
    paused_at TIMESTAMP,
    completed_at TIMESTAMP,
    
    -- Performance metrics (denormalized for quick access)
    total_sent INTEGER DEFAULT 0,
    total_delivered INTEGER DEFAULT 0,
    total_opened INTEGER DEFAULT 0,
    total_clicked INTEGER DEFAULT 0,
    total_converted INTEGER DEFAULT 0,
    total_revenue DECIMAL(15,2) DEFAULT 0,
    roi_percentage DECIMAL(5,2) DEFAULT 0,
    
    -- Audit fields
    created_by UUID REFERENCES lic_schema.users(user_id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_by UUID REFERENCES lic_schema.users(user_id),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Campaign triggers (for automation)
CREATE TABLE IF NOT EXISTS lic_schema.campaign_triggers (
    trigger_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID REFERENCES lic_schema.campaigns(campaign_id) ON DELETE CASCADE,
    
    -- Trigger configuration
    trigger_type VARCHAR(100) NOT NULL, -- 'event_type', 'policy_renewal', 'birthday', 'payment_overdue', etc.
    trigger_value VARCHAR(255), -- Trigger-specific value
    additional_conditions JSONB, -- Additional conditions for trigger
    
    -- Trigger status
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Campaign executions (tracks individual campaign sends)
CREATE TABLE IF NOT EXISTS lic_schema.campaign_executions (
    execution_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID REFERENCES lic_schema.campaigns(campaign_id) ON DELETE CASCADE,
    policyholder_id UUID REFERENCES lic_schema.policyholders(policyholder_id),
    
    -- Execution details
    channel lic_schema.campaign_channel_enum NOT NULL,
    personalized_content JSONB, -- Personalized message content
    sent_at TIMESTAMP,
    delivered_at TIMESTAMP,
    opened_at TIMESTAMP,
    clicked_at TIMESTAMP,
    
    -- Status tracking
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'sent', 'delivered', 'opened', 'clicked', 'converted', 'failed'
    failure_reason TEXT,
    
    -- Conversion tracking
    converted BOOLEAN DEFAULT false,
    conversion_value DECIMAL(12,2),
    conversion_type VARCHAR(100), -- 'policy_purchase', 'renewal', 'inquiry', etc.
    
    -- Device and context
    device_info JSONB,
    ip_address INET,
    user_agent TEXT,
    
    created_at TIMESTAMP DEFAULT NOW()
);

-- Campaign templates (pre-built campaign templates)
CREATE TABLE IF NOT EXISTS lic_schema.campaign_templates (
    template_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Template details
    template_name VARCHAR(255) NOT NULL,
    description TEXT,
    category lic_schema.campaign_type_enum NOT NULL,
    
    -- Template content
    subject_template VARCHAR(500),
    message_template TEXT NOT NULL,
    personalization_tags TEXT[], -- Available tags
    suggested_channels TEXT[],
    
    -- Template metadata
    usage_count INTEGER DEFAULT 0,
    average_roi DECIMAL(5,2),
    total_ratings INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2),
    
    -- Preview
    preview_image_url VARCHAR(500),
    
    -- Availability
    is_public BOOLEAN DEFAULT false,
    is_system_template BOOLEAN DEFAULT false,
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'archived'
    
    created_by UUID REFERENCES lic_schema.users(user_id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Campaign customer responses (tracks customer interactions)
CREATE TABLE IF NOT EXISTS lic_schema.campaign_responses (
    response_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    execution_id UUID REFERENCES lic_schema.campaign_executions(execution_id) ON DELETE CASCADE,
    campaign_id UUID REFERENCES lic_schema.campaigns(campaign_id),
    policyholder_id UUID REFERENCES lic_schema.policyholders(policyholder_id),
    
    -- Response details
    response_type VARCHAR(50) NOT NULL, -- 'interested', 'question', 'complaint', 'unsubscribe', 'conversion'
    response_text TEXT,
    response_channel VARCHAR(50), -- 'whatsapp', 'email', 'phone', 'in_app'
    
    -- Metadata
    sentiment_score DECIMAL(3,2), -- -1 to 1 (negative to positive)
    requires_followup BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- CALLBACK REQUEST MANAGEMENT TABLES
-- =====================================================

-- Callback request priority levels
CREATE TYPE lic_schema.callback_priority AS ENUM ('high', 'medium', 'low');

-- Callback request status
CREATE TYPE lic_schema.callback_status AS ENUM ('pending', 'assigned', 'in_progress', 'completed', 'cancelled', 'overdue');

-- Main callback requests table
CREATE TABLE IF NOT EXISTS lic_schema.callback_requests (
    callback_request_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    policyholder_id UUID REFERENCES lic_schema.policyholders(policyholder_id),
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    
    -- Request details
    request_type VARCHAR(100) NOT NULL, -- 'policy_issue', 'payment_problem', 'claim_assistance', etc.
    description TEXT NOT NULL,
    priority lic_schema.callback_priority DEFAULT 'low',
    priority_score DECIMAL(5,2) DEFAULT 0.00, -- Calculated priority score 0-100
    status lic_schema.callback_status DEFAULT 'pending',
    
    -- Customer contact information (cached for performance)
    customer_name VARCHAR(200) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    customer_email VARCHAR(255),
    
    -- SLA and time management
    sla_hours INTEGER DEFAULT 24, -- Service Level Agreement in hours
    created_at TIMESTAMP DEFAULT NOW(),
    assigned_at TIMESTAMP,
    scheduled_at TIMESTAMP, -- When callback is scheduled
    due_at TIMESTAMP, -- Calculated due date based on SLA
    started_at TIMESTAMP, -- When agent starts working on callback
    completed_at TIMESTAMP,
    
    -- Source tracking
    source VARCHAR(50) DEFAULT 'mobile', -- 'portal', 'whatsapp', 'mobile', 'api'
    source_reference_id VARCHAR(200), -- Reference ID from source system
    
    -- Metadata and categorization
    tags TEXT[] DEFAULT '{}', -- Array of tags for categorization
    category VARCHAR(100), -- 'technical', 'billing', 'policy', 'general'
    urgency_level VARCHAR(20) DEFAULT 'medium', -- 'critical', 'high', 'medium', 'low'
    customer_value VARCHAR(20) DEFAULT 'bronze', -- 'bronze', 'silver', 'gold', 'platinum'
    
    -- Resolution details
    resolution TEXT, -- How the callback was resolved
    resolution_category VARCHAR(100), -- 'resolved', 'escalated', 'transferred', 'cancelled'
    satisfaction_rating INTEGER CHECK (satisfaction_rating >= 1 AND satisfaction_rating <= 5),
    
    -- Audit fields
    created_by UUID REFERENCES lic_schema.users(user_id),
    assigned_by UUID REFERENCES lic_schema.users(user_id),
    completed_by UUID REFERENCES lic_schema.users(user_id),
    last_updated_by UUID REFERENCES lic_schema.users(user_id),
    last_updated_at TIMESTAMP DEFAULT NOW()
);

-- Callback activity log (tracks all interactions)
CREATE TABLE IF NOT EXISTS lic_schema.callback_activities (
    callback_activity_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    callback_request_id UUID REFERENCES lic_schema.callback_requests(callback_request_id) ON DELETE CASCADE,
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    
    -- Activity details
    activity_type VARCHAR(50) NOT NULL, -- 'created', 'assigned', 'called', 'completed', 'escalated', 'cancelled', etc.
    description TEXT NOT NULL,
    duration_minutes INTEGER, -- Duration of the activity in minutes
    contact_method VARCHAR(50), -- 'phone', 'whatsapp', 'email', 'sms', 'in_person'
    contact_outcome VARCHAR(100), -- 'successful', 'no_answer', 'wrong_number', 'voicemail', etc.
    notes TEXT, -- Additional notes from agent
    metadata JSONB DEFAULT '{}', -- Flexible metadata storage
    
    created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Campaign indexes
CREATE INDEX IF NOT EXISTS idx_campaigns_agent_status ON lic_schema.campaigns(agent_id, status);
CREATE INDEX IF NOT EXISTS idx_campaigns_type_status ON lic_schema.campaigns(campaign_type, status);
CREATE INDEX IF NOT EXISTS idx_campaigns_scheduled ON lic_schema.campaigns(scheduled_at) WHERE scheduled_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_campaigns_created_at ON lic_schema.campaigns(created_at DESC);

-- Campaign trigger indexes
CREATE INDEX IF NOT EXISTS idx_campaign_triggers_campaign ON lic_schema.campaign_triggers(campaign_id);
CREATE INDEX IF NOT EXISTS idx_campaign_triggers_active ON lic_schema.campaign_triggers(is_active) WHERE is_active = true;

-- Campaign execution indexes
CREATE INDEX IF NOT EXISTS idx_campaign_executions_campaign ON lic_schema.campaign_executions(campaign_id);
CREATE INDEX IF NOT EXISTS idx_campaign_executions_policyholder ON lic_schema.campaign_executions(policyholder_id);
CREATE INDEX IF NOT EXISTS idx_campaign_executions_status ON lic_schema.campaign_executions(status);
CREATE INDEX IF NOT EXISTS idx_campaign_executions_sent_at ON lic_schema.campaign_executions(sent_at DESC);

-- Campaign template indexes
CREATE INDEX IF NOT EXISTS idx_campaign_templates_category ON lic_schema.campaign_templates(category);
CREATE INDEX IF NOT EXISTS idx_campaign_templates_public ON lic_schema.campaign_templates(is_public) WHERE is_public = true;

-- Campaign response indexes
CREATE INDEX IF NOT EXISTS idx_campaign_responses_execution ON lic_schema.campaign_responses(execution_id);
CREATE INDEX IF NOT EXISTS idx_campaign_responses_campaign ON lic_schema.campaign_responses(campaign_id);
CREATE INDEX IF NOT EXISTS idx_campaign_responses_type ON lic_schema.campaign_responses(response_type);

-- Callback request indexes
CREATE INDEX IF NOT EXISTS idx_callback_requests_status ON lic_schema.callback_requests(status);
CREATE INDEX IF NOT EXISTS idx_callback_requests_priority ON lic_schema.callback_requests(priority);
CREATE INDEX IF NOT EXISTS idx_callback_requests_policyholder ON lic_schema.callback_requests(policyholder_id);
CREATE INDEX IF NOT EXISTS idx_callback_requests_agent ON lic_schema.callback_requests(agent_id);
CREATE INDEX IF NOT EXISTS idx_callback_requests_due_at ON lic_schema.callback_requests(due_at);
CREATE INDEX IF NOT EXISTS idx_callback_requests_created_at ON lic_schema.callback_requests(created_at DESC);

-- Callback activity indexes
CREATE INDEX IF NOT EXISTS idx_callback_activities_callback ON lic_schema.callback_activities(callback_request_id);
CREATE INDEX IF NOT EXISTS idx_callback_activities_agent ON lic_schema.callback_activities(agent_id);
CREATE INDEX IF NOT EXISTS idx_callback_activities_created_at ON lic_schema.callback_activities(created_at DESC);

-- Partial indexes for common queries
CREATE INDEX IF NOT EXISTS idx_campaigns_active ON lic_schema.campaigns(campaign_id) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_callback_requests_pending ON lic_schema.callback_requests(callback_request_id) WHERE status = 'pending';
-- Note: Overdue callbacks index removed - use query with WHERE due_at < CURRENT_TIMESTAMP instead
CREATE INDEX IF NOT EXISTS idx_callback_requests_high_priority ON lic_schema.callback_requests(callback_request_id)
    WHERE priority = 'high' AND status NOT IN ('completed', 'cancelled');

-- JSONB indexes for flexible queries
CREATE INDEX IF NOT EXISTS idx_campaigns_targeting_rules ON lic_schema.campaigns USING GIN(targeting_rules) WHERE targeting_rules IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_campaign_executions_personalized_content ON lic_schema.campaign_executions USING GIN(personalized_content);
CREATE INDEX IF NOT EXISTS idx_callback_activities_metadata ON lic_schema.callback_activities USING GIN(metadata);

-- Comments for documentation
COMMENT ON TABLE lic_schema.campaigns IS 'Marketing campaigns for customer acquisition, retention, upselling, and behavioral engagement';
COMMENT ON TABLE lic_schema.campaign_triggers IS 'Automation triggers for campaign execution based on customer events';
COMMENT ON TABLE lic_schema.campaign_executions IS 'Individual campaign message executions to customers';
COMMENT ON TABLE lic_schema.campaign_templates IS 'Pre-built campaign templates for quick campaign creation';
COMMENT ON TABLE lic_schema.campaign_responses IS 'Customer responses and interactions with campaign messages';
COMMENT ON TABLE lic_schema.callback_requests IS 'Callback requests from customers requiring agent follow-up';
COMMENT ON TABLE lic_schema.callback_activities IS 'Activity log for callback request interactions and status changes';

