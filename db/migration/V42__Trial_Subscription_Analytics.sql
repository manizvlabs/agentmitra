-- Enhanced trial subscription tracking
CREATE TABLE IF NOT EXISTS lic_schema.trial_subscriptions (
    trial_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    plan_type VARCHAR(50) DEFAULT 'policyholder_trial', -- 'agent_trial', 'policyholder_trial'
    trial_start_date TIMESTAMP DEFAULT NOW(),
    trial_end_date TIMESTAMP,
    actual_conversion_date TIMESTAMP,
    conversion_plan VARCHAR(50),
    trial_status VARCHAR(50) DEFAULT 'active', -- 'active', 'expired', 'converted', 'cancelled'
    extension_days INTEGER DEFAULT 0,
    reminder_sent BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Add indexes for trial subscriptions
CREATE INDEX IF NOT EXISTS idx_trial_subscriptions_user_id ON lic_schema.trial_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_trial_subscriptions_status ON lic_schema.trial_subscriptions(trial_status);
CREATE INDEX IF NOT EXISTS idx_trial_subscriptions_end_date ON lic_schema.trial_subscriptions(trial_end_date);

-- Trial user engagement tracking
CREATE TABLE IF NOT EXISTS lic_schema.trial_engagement (
    engagement_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trial_id UUID REFERENCES lic_schema.trial_subscriptions(trial_id) ON DELETE CASCADE,
    feature_used VARCHAR(100), -- 'dashboard', 'policies', 'chatbot', etc.
    engagement_type VARCHAR(50), -- 'view', 'interaction', 'completion'
    metadata JSONB,
    engaged_at TIMESTAMP DEFAULT NOW()
);

-- Add indexes for trial engagement
CREATE INDEX IF NOT EXISTS idx_trial_engagement_trial_id ON lic_schema.trial_engagement(trial_id);
CREATE INDEX IF NOT EXISTS idx_trial_engagement_feature ON lic_schema.trial_engagement(feature_used);
CREATE INDEX IF NOT EXISTS idx_trial_engagement_type ON lic_schema.trial_engagement(engagement_type);
CREATE INDEX IF NOT EXISTS idx_trial_engagement_timestamp ON lic_schema.trial_engagement(engaged_at);

-- Function to automatically set trial end date (30 days from start)
CREATE OR REPLACE FUNCTION set_trial_end_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.trial_end_date IS NULL THEN
        NEW.trial_end_date = NEW.trial_start_date + INTERVAL '30 days';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_trial_end_date
    BEFORE INSERT ON lic_schema.trial_subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION set_trial_end_date();

-- Function to update trial status based on dates
CREATE OR REPLACE FUNCTION update_trial_status()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if trial has expired
    IF NEW.trial_status = 'active' AND NEW.trial_end_date < NOW() THEN
        NEW.trial_status = 'expired';
    END IF;

    -- Check if trial was converted
    IF NEW.actual_conversion_date IS NOT NULL AND NEW.trial_status = 'active' THEN
        NEW.trial_status = 'converted';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_trial_status
    BEFORE UPDATE ON lic_schema.trial_subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION update_trial_status();
