-- Migration V35: Create Analytics Leads and Retention Tables
-- This migration adds tables for lead scoring, customer retention analytics, and advanced ROI calculations

-- =====================================================
-- LEADS AND OPPORTUNITIES MANAGEMENT
-- =====================================================

-- Lead status enumeration
CREATE TYPE lic_schema.lead_status_enum AS ENUM (
    'new', 'contacted', 'qualified', 'quoted', 'converted', 'lost', 'inactive'
);

-- Lead source enumeration
CREATE TYPE lic_schema.lead_source_enum AS ENUM (
    'website', 'referral', 'cold_call', 'social_media', 'email_campaign',
    'whatsapp_campaign', 'event', 'partner', 'walk_in', 'other'
);

-- Lead priority enumeration
CREATE TYPE lic_schema.lead_priority_enum AS ENUM ('high', 'medium', 'low');

-- Leads table
CREATE TABLE lic_schema.leads (
    lead_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.agents(agent_id),

    -- Customer information
    customer_name VARCHAR(255) NOT NULL,
    contact_number VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    location VARCHAR(255),

    -- Lead details
    lead_source lic_schema.lead_source_enum NOT NULL,
    lead_status lic_schema.lead_status_enum DEFAULT 'new',
    priority lic_schema.lead_priority_enum DEFAULT 'medium',

    -- Insurance requirements
    insurance_type VARCHAR(100), -- 'term_life', 'health', 'ulip', 'comprehensive', etc.
    budget_range VARCHAR(50), -- 'low', 'medium', 'high'
    coverage_required DECIMAL(15,2),

    -- Lead scoring and analytics
    conversion_score DECIMAL(5,2) DEFAULT 0, -- 0-100 scale
    engagement_score DECIMAL(5,2) DEFAULT 0, -- 0-100 scale
    potential_premium DECIMAL(12,2) DEFAULT 0,

    -- Lead qualification
    is_qualified BOOLEAN DEFAULT false,
    qualification_notes TEXT,
    disqualification_reason TEXT,

    -- Timeline tracking
    created_at TIMESTAMP DEFAULT NOW(),
    first_contact_at TIMESTAMP,
    last_contact_at TIMESTAMP,
    last_contact_method VARCHAR(50), -- 'phone', 'whatsapp', 'email', 'in_person'

    -- Follow-up scheduling
    next_followup_at TIMESTAMP,
    followup_count INTEGER DEFAULT 0,
    response_time_hours DECIMAL(6,2), -- Hours to first response

    -- Conversion tracking
    converted_at TIMESTAMP,
    converted_policy_id UUID REFERENCES lic_schema.insurance_policies(policy_id),
    conversion_value DECIMAL(12,2),

    -- Audit fields
    created_by UUID REFERENCES lic_schema.users(user_id),
    updated_by UUID REFERENCES lic_schema.users(user_id),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Lead interactions table
CREATE TABLE lic_schema.lead_interactions (
    interaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lead_id UUID REFERENCES lic_schema.leads(lead_id) ON DELETE CASCADE,

    -- Interaction details
    interaction_type VARCHAR(50) NOT NULL, -- 'call', 'whatsapp', 'email', 'meeting', 'quote_sent'
    interaction_method VARCHAR(50), -- 'outbound', 'inbound'
    duration_minutes INTEGER,
    outcome VARCHAR(100), -- 'interested', 'not_interested', 'follow_up_needed', 'converted'

    -- Content
    notes TEXT,
    next_action TEXT,
    next_action_date TIMESTAMP,

    -- Agent information
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- CUSTOMER RETENTION AND CHURN ANALYSIS
-- =====================================================

-- Customer risk level enumeration
CREATE TYPE lic_schema.customer_risk_level_enum AS ENUM ('high', 'medium', 'low');

-- Customer retention status enumeration
CREATE TYPE lic_schema.retention_status_enum AS ENUM (
    'active', 'at_risk', 'churned', 'recovered', 'lost'
);

-- Customer retention analytics table
CREATE TABLE lic_schema.customer_retention_analytics (
    retention_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES lic_schema.policyholders(policyholder_id),

    -- Risk assessment
    risk_level lic_schema.customer_risk_level_enum DEFAULT 'low',
    risk_score DECIMAL(5,2) DEFAULT 0, -- 0-100 scale (higher = more risky)
    churn_probability DECIMAL(5,2) DEFAULT 0, -- 0-100 percentage

    -- Risk factors (JSON array for flexibility)
    risk_factors JSONB DEFAULT '[]',
    engagement_score DECIMAL(5,2) DEFAULT 0,

    -- Financial metrics
    premium_value DECIMAL(12,2),
    lifetime_value DECIMAL(15,2),
    days_since_last_payment INTEGER DEFAULT 0,

    -- Activity metrics
    days_since_last_contact INTEGER DEFAULT 0,
    complaints_count INTEGER DEFAULT 0,
    support_queries_count INTEGER DEFAULT 0,
    missed_payments_count INTEGER DEFAULT 0,

    -- Policy information
    policy_age_months INTEGER,
    policy_count INTEGER DEFAULT 1,
    policy_type VARCHAR(100),

    -- Retention actions
    last_retention_action_at TIMESTAMP,
    retention_plan JSONB, -- Structured retention plan
    retention_success_probability DECIMAL(5,2) DEFAULT 0,

    -- Status tracking
    status lic_schema.retention_status_enum DEFAULT 'active',
    status_changed_at TIMESTAMP DEFAULT NOW(),

    -- Agent assignment
    assigned_agent_id UUID REFERENCES lic_schema.agents(agent_id),

    -- Audit fields
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Retention action log
CREATE TABLE lic_schema.retention_actions (
    action_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    retention_id UUID REFERENCES lic_schema.customer_retention_analytics(retention_id) ON DELETE CASCADE,

    -- Action details
    action_type VARCHAR(100) NOT NULL, -- 'call', 'email', 'whatsapp', 'meeting', 'discount_offer'
    action_description TEXT,
    action_priority VARCHAR(20) DEFAULT 'medium', -- 'high', 'medium', 'low'

    -- Scheduling
    scheduled_at TIMESTAMP,
    completed_at TIMESTAMP,
    due_at TIMESTAMP,

    -- Outcome tracking
    outcome VARCHAR(100), -- 'successful', 'unsuccessful', 'pending', 'cancelled'
    outcome_notes TEXT,
    retention_value DECIMAL(12,2), -- Value saved through retention

    -- Agent information
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- ENHANCED ANALYTICS TABLES
-- =====================================================

-- Revenue forecasting scenarios
CREATE TABLE lic_schema.revenue_forecast_scenarios (
    scenario_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.agents(agent_id),

    -- Scenario details
    scenario_name VARCHAR(255) NOT NULL,
    scenario_type VARCHAR(50) NOT NULL, -- 'best_case', 'base_case', 'worst_case'
    forecast_period VARCHAR(20) NOT NULL, -- '1m', '3m', '6m', '1y'

    -- Forecast data
    projected_revenue DECIMAL(15,2) NOT NULL,
    revenue_growth_rate DECIMAL(5,2), -- percentage
    confidence_level DECIMAL(5,2), -- percentage

    -- Scenario parameters
    assumptions JSONB, -- Key assumptions for the scenario
    risk_factors JSONB, -- Risk factors considered
    mitigation_strategies JSONB, -- Mitigation strategies

    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    UNIQUE(agent_id, scenario_name, forecast_period)
);

-- Predictive insights table
CREATE TABLE lic_schema.predictive_insights (
    insight_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    customer_id UUID REFERENCES lic_schema.policyholders(policyholder_id),

    -- Insight details
    insight_type VARCHAR(100) NOT NULL, -- 'opportunity', 'warning', 'trend', 'recommendation'
    title VARCHAR(500) NOT NULL,
    description TEXT,
    confidence DECIMAL(5,2), -- 0-100 percentage
    impact_level VARCHAR(20), -- 'high', 'medium', 'low'

    -- Actionable data
    recommended_actions JSONB,
    potential_value DECIMAL(12,2),
    deadline TIMESTAMP,

    -- Status tracking
    is_acknowledged BOOLEAN DEFAULT false,
    acknowledged_at TIMESTAMP,
    acknowledged_by UUID REFERENCES lic_schema.users(user_id),

    -- Validity period
    valid_from TIMESTAMP DEFAULT NOW(),
    valid_until TIMESTAMP,

    -- Audit fields
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Leads table indexes
CREATE INDEX idx_leads_agent_status ON lic_schema.leads(agent_id, lead_status);
CREATE INDEX idx_leads_priority_score ON lic_schema.leads(priority, conversion_score DESC);
CREATE INDEX idx_leads_created_at ON lic_schema.leads(created_at DESC);
CREATE INDEX idx_leads_next_followup ON lic_schema.leads(next_followup_at) WHERE next_followup_at IS NOT NULL;
CREATE INDEX idx_leads_source_type ON lic_schema.leads(lead_source, insurance_type);

-- Lead interactions indexes
CREATE INDEX idx_lead_interactions_lead ON lic_schema.lead_interactions(lead_id);
CREATE INDEX idx_lead_interactions_agent ON lic_schema.lead_interactions(agent_id);
CREATE INDEX idx_lead_interactions_created ON lic_schema.lead_interactions(created_at DESC);

-- Customer retention indexes
CREATE INDEX idx_customer_retention_customer ON lic_schema.customer_retention_analytics(customer_id);
CREATE INDEX idx_customer_retention_risk ON lic_schema.customer_retention_analytics(risk_level, risk_score DESC);
CREATE INDEX idx_customer_retention_status ON lic_schema.customer_retention_analytics(status);
CREATE INDEX idx_customer_retention_agent ON lic_schema.customer_retention_analytics(assigned_agent_id);
CREATE INDEX idx_customer_retention_updated ON lic_schema.customer_retention_analytics(updated_at DESC);

-- Retention actions indexes
CREATE INDEX idx_retention_actions_retention ON lic_schema.retention_actions(retention_id);
CREATE INDEX idx_retention_actions_agent ON lic_schema.retention_actions(agent_id);
CREATE INDEX idx_retention_actions_scheduled ON lic_schema.retention_actions(scheduled_at);
CREATE INDEX idx_retention_actions_due ON lic_schema.retention_actions(due_at);

-- Revenue forecast scenarios indexes
CREATE INDEX idx_forecast_scenarios_agent ON lic_schema.revenue_forecast_scenarios(agent_id);
CREATE INDEX idx_forecast_scenarios_type ON lic_schema.revenue_forecast_scenarios(scenario_type, forecast_period);

-- Predictive insights indexes
CREATE INDEX idx_predictive_insights_agent ON lic_schema.predictive_insights(agent_id);
CREATE INDEX idx_predictive_insights_customer ON lic_schema.predictive_insights(customer_id);
CREATE INDEX idx_predictive_insights_type ON lic_schema.predictive_insights(insight_type);
CREATE INDEX idx_predictive_insights_valid ON lic_schema.predictive_insights(valid_until) WHERE valid_until IS NOT NULL;

-- JSONB indexes for complex queries
CREATE INDEX idx_leads_risk_factors ON lic_schema.customer_retention_analytics USING GIN(risk_factors);
CREATE INDEX idx_retention_plan ON lic_schema.customer_retention_analytics USING GIN(retention_plan);
CREATE INDEX idx_forecast_assumptions ON lic_schema.revenue_forecast_scenarios USING GIN(assumptions);
CREATE INDEX idx_insights_actions ON lic_schema.predictive_insights USING GIN(recommended_actions);

-- =====================================================
-- FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to calculate lead conversion score
CREATE OR REPLACE FUNCTION lic_schema.calculate_lead_score(
    p_engagement_score DECIMAL,
    p_lead_age_days INTEGER,
    p_response_time_hours DECIMAL,
    p_interaction_count INTEGER,
    p_source_effectiveness DECIMAL DEFAULT 1.0
) RETURNS DECIMAL AS $$
DECLARE
    age_score DECIMAL;
    response_score DECIMAL;
    interaction_score DECIMAL;
    conversion_score DECIMAL;
BEGIN
    -- Calculate individual scores (0-100 scale)
    age_score := GREATEST(0, 100 - (p_lead_age_days * 3));
    response_score := GREATEST(0, 100 - (p_response_time_hours * 2));
    interaction_score := LEAST(100, p_interaction_count * 15);

    -- Calculate overall conversion score
    conversion_score := (
        p_engagement_score * 0.25 +      -- 25% weight
        age_score * 0.20 +               -- 20% weight
        response_score * 0.15 +          -- 15% weight
        interaction_score * 0.15 +       -- 15% weight
        (p_source_effectiveness * 20)    -- 25% weight combined
    );

    RETURN LEAST(100, GREATEST(0, conversion_score));
END;
$$ LANGUAGE plpgsql;

-- Function to assess customer churn risk
CREATE OR REPLACE FUNCTION lic_schema.assess_customer_risk(
    p_days_since_payment INTEGER,
    p_engagement_score DECIMAL,
    p_complaints_count INTEGER,
    p_missed_payments INTEGER,
    p_days_since_contact INTEGER,
    p_policy_age_months INTEGER
) RETURNS JSONB AS $$
DECLARE
    payment_risk DECIMAL;
    engagement_risk DECIMAL;
    support_risk DECIMAL;
    age_risk DECIMAL;
    contact_risk DECIMAL;
    overall_risk DECIMAL;
    risk_level VARCHAR(20);
    risk_factors TEXT[] := ARRAY[]::TEXT[];
BEGIN
    -- Calculate risk factors
    payment_risk := LEAST(100, p_days_since_payment * 2);
    engagement_risk := 100 - p_engagement_score;
    support_risk := LEAST(100, (p_complaints_count * 10));
    age_risk := GREATEST(0, 100 - (p_policy_age_months * 2));
    contact_risk := LEAST(100, p_days_since_contact * 1.5);

    -- Calculate overall risk score
    overall_risk := (
        payment_risk * 0.25 +
        engagement_risk * 0.20 +
        support_risk * 0.15 +
        age_risk * 0.15 +
        contact_risk * 0.10 +
        (p_missed_payments * 25) * 0.15
    );

    overall_risk := LEAST(100, GREATEST(0, overall_risk));

    -- Determine risk level
    IF overall_risk >= 70 THEN
        risk_level := 'high';
    ELSIF overall_risk >= 40 THEN
        risk_level := 'medium';
    ELSE
        risk_level := 'low';
    END IF;

    -- Build risk factors array
    IF payment_risk > 50 THEN
        risk_factors := risk_factors || ARRAY['Overdue payments'];
    END IF;
    IF engagement_risk > 60 THEN
        risk_factors := risk_factors || ARRAY['Low engagement'];
    END IF;
    IF support_risk > 40 THEN
        risk_factors := risk_factors || ARRAY['High support queries'];
    END IF;
    IF age_risk > 50 THEN
        risk_factors := risk_factors || ARRAY['Recent policy holder'];
    END IF;
    IF p_missed_payments > 0 THEN
        risk_factors := risk_factors || ARRAY['Payment history issues'];
    END IF;
    IF contact_risk > 40 THEN
        risk_factors := risk_factors || ARRAY['Long time since contact'];
    END IF;

    IF array_length(risk_factors, 1) IS NULL OR array_length(risk_factors, 1) = 0 THEN
        risk_factors := ARRAY['General monitoring'];
    END IF;

    RETURN jsonb_build_object(
        'risk_score', ROUND(overall_risk, 1),
        'risk_level', risk_level,
        'risk_factors', risk_factors,
        'payment_risk', ROUND(payment_risk, 1),
        'engagement_risk', ROUND(engagement_risk, 1),
        'support_risk', ROUND(support_risk, 1),
        'age_risk', ROUND(age_risk, 1),
        'contact_risk', ROUND(contact_risk, 1)
    );
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update lead conversion scores
CREATE OR REPLACE FUNCTION lic_schema.update_lead_score_trigger()
RETURNS TRIGGER AS $$
BEGIN
    -- Calculate and update conversion score when lead data changes
    IF NEW.engagement_score IS NOT NULL AND NEW.created_at IS NOT NULL THEN
        NEW.conversion_score := lic_schema.calculate_lead_score(
            COALESCE(NEW.engagement_score, 0),
            EXTRACT(EPOCH FROM (NOW() - NEW.created_at))::INTEGER / 86400, -- days
            COALESCE(NEW.response_time_hours, 24), -- default 24 hours
            COALESCE(NEW.followup_count, 0),
            CASE NEW.lead_source
                WHEN 'referral' THEN 1.4
                WHEN 'partner' THEN 1.3
                WHEN 'website' THEN 1.2
                WHEN 'whatsapp_campaign' THEN 1.1
                WHEN 'email_campaign' THEN 1.0
                WHEN 'social_media' THEN 0.9
                ELSE 0.8
            END
        );

        -- Update priority based on score
        NEW.priority := CASE
            WHEN NEW.conversion_score >= 80 THEN 'high'::lic_schema.lead_priority_enum
            WHEN NEW.conversion_score >= 60 THEN 'medium'::lic_schema.lead_priority_enum
            ELSE 'low'::lic_schema.lead_priority_enum
        END;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_lead_score_on_change
    BEFORE INSERT OR UPDATE ON lic_schema.leads
    FOR EACH ROW
    EXECUTE FUNCTION lic_schema.update_lead_score_trigger();

-- Trigger to update customer retention analytics
CREATE OR REPLACE FUNCTION lic_schema.update_customer_retention_trigger()
RETURNS TRIGGER AS $$
DECLARE
    risk_assessment JSONB;
BEGIN
    -- Calculate risk assessment
    risk_assessment := lic_schema.assess_customer_risk(
        COALESCE(NEW.days_since_last_payment, 0),
        COALESCE(NEW.engagement_score, 50),
        COALESCE(NEW.complaints_count, 0),
        COALESCE(NEW.missed_payments_count, 0),
        COALESCE(NEW.days_since_last_contact, 30),
        COALESCE(NEW.policy_age_months, 12)
    );

    -- Update risk fields
    NEW.risk_score := (risk_assessment->>'risk_score')::DECIMAL;
    NEW.risk_level := (risk_assessment->>'risk_level')::lic_schema.customer_risk_level_enum;
    NEW.risk_factors := (risk_assessment->>'risk_factors')::JSONB;
    NEW.churn_probability := NEW.risk_score; -- Simplified mapping

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_customer_risk_on_change
    BEFORE INSERT OR UPDATE ON lic_schema.customer_retention_analytics
    FOR EACH ROW
    EXECUTE FUNCTION lic_schema.update_customer_retention_trigger();

-- =====================================================
-- DATA POPULATION (SAMPLE DATA)
-- =====================================================

-- Insert sample leads
INSERT INTO lic_schema.leads (
    agent_id, customer_name, contact_number, email, location,
    lead_source, insurance_type, budget_range, coverage_required,
    engagement_score, followup_count, response_time_hours,
    created_at, last_contact_at
) VALUES
(
    (SELECT agent_id FROM lic_schema.agents LIMIT 1),
    'Rajesh Kumar', '+91-9876543210', 'rajesh.kumar@email.com', 'Mumbai, Maharashtra',
    'whatsapp_campaign', 'term_life', 'high', 5000000,
    85, 3, 1.5,
    NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day'
),
(
    (SELECT agent_id FROM lic_schema.agents LIMIT 1),
    'Priya Sharma', '+91-9876543211', 'priya.sharma@email.com', 'Bangalore, Karnataka',
    'website', 'health', 'medium', 300000,
    72, 1, 4.2,
    NOW() - INTERVAL '5 days', NOW() - INTERVAL '3 days'
),
(
    (SELECT agent_id FROM lic_schema.agents LIMIT 1),
    'Amit Patel', '+91-9876543212', 'amit.patel@email.com', 'Ahmedabad, Gujarat',
    'referral', 'ulip', 'high', 1000000,
    90, 5, 0.8,
    NOW() - INTERVAL '1 day', NOW() - INTERVAL '12 hours'
);

-- Insert sample customer retention data
INSERT INTO lic_schema.customer_retention_analytics (
    customer_id, risk_level, engagement_score, premium_value,
    days_since_last_payment, days_since_last_contact, complaints_count,
    support_queries_count, missed_payments_count, policy_age_months,
    policy_type, status, assigned_agent_id
) VALUES
(
    (SELECT policyholder_id FROM lic_schema.policyholders LIMIT 1 OFFSET 0),
    'high', 25, 25000, 45, 35, 3, 8, 2, 24, 'term_life', 'at_risk',
    (SELECT agent_id FROM lic_schema.agents LIMIT 1)
),
(
    (SELECT policyholder_id FROM lic_schema.policyholders LIMIT 1 OFFSET 1),
    'medium', 65, 50000, 15, 20, 1, 2, 1, 36, 'ulip', 'active',
    (SELECT agent_id FROM lic_schema.agents LIMIT 1)
),
(
    (SELECT policyholder_id FROM lic_schema.policyholders LIMIT 1 OFFSET 2),
    'low', 75, 12000, 10, 15, 0, 1, 0, 8, 'health', 'active',
    (SELECT agent_id FROM lic_schema.agents LIMIT 1)
);

-- =====================================================
-- COMMENTS FOR DOCUMENTATION
-- =====================================================

COMMENT ON TABLE lic_schema.leads IS 'Lead management and scoring system for agent opportunities';
COMMENT ON TABLE lic_schema.lead_interactions IS 'Detailed interaction log for lead follow-up and conversion tracking';
COMMENT ON TABLE lic_schema.customer_retention_analytics IS 'Customer churn risk assessment and retention analytics';
COMMENT ON TABLE lic_schema.retention_actions IS 'Retention action planning and execution tracking';
COMMENT ON TABLE lic_schema.revenue_forecast_scenarios IS 'Revenue forecasting scenarios with risk assessment';
COMMENT ON TABLE lic_schema.predictive_insights IS 'AI-generated insights and recommendations for agents';
