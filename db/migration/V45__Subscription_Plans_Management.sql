-- Subscription Plans and Billing Management
CREATE TABLE IF NOT EXISTS lic_schema.subscription_plans (
    plan_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_name VARCHAR(100) NOT NULL UNIQUE,
    plan_type VARCHAR(50) NOT NULL, -- 'agent', 'customer', 'enterprise'
    display_name VARCHAR(255) NOT NULL,
    description TEXT,
    price_monthly DECIMAL(10,2),
    price_yearly DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'INR',
    features JSONB, -- Array of feature names included
    limitations JSONB, -- Usage limits and restrictions
    max_users INTEGER,
    max_storage_gb INTEGER,
    max_policies INTEGER,
    is_active BOOLEAN DEFAULT true,
    is_popular BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    trial_days INTEGER DEFAULT 14,
    stripe_price_id_monthly VARCHAR(255),
    stripe_price_id_yearly VARCHAR(255),
    razorpay_plan_id_monthly VARCHAR(255),
    razorpay_plan_id_yearly VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- User subscriptions table
CREATE TABLE IF NOT EXISTS lic_schema.user_subscriptions (
    subscription_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    plan_id UUID REFERENCES lic_schema.subscription_plans(plan_id),
    billing_cycle VARCHAR(20) DEFAULT 'monthly', -- 'monthly', 'yearly'
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'past_due', 'canceled', 'incomplete'
    current_period_start TIMESTAMP,
    current_period_end TIMESTAMP,
    trial_start TIMESTAMP,
    trial_end TIMESTAMP,
    cancel_at_period_end BOOLEAN DEFAULT false,
    canceled_at TIMESTAMP,
    stripe_subscription_id VARCHAR(255),
    razorpay_subscription_id VARCHAR(255),
    payment_method_id VARCHAR(255),
    last_payment_date TIMESTAMP,
    next_payment_date TIMESTAMP,
    amount DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'INR',
    discount_amount DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Subscription billing history
CREATE TABLE IF NOT EXISTS lic_schema.subscription_billing_history (
    billing_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID REFERENCES lic_schema.user_subscriptions(subscription_id) ON DELETE CASCADE,
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    billing_date TIMESTAMP DEFAULT NOW(),
    billing_period_start TIMESTAMP,
    billing_period_end TIMESTAMP,
    payment_gateway VARCHAR(50), -- 'stripe', 'razorpay', 'manual'
    gateway_transaction_id VARCHAR(255),
    status VARCHAR(50) DEFAULT 'paid', -- 'paid', 'failed', 'pending', 'refunded'
    invoice_url VARCHAR(500),
    receipt_url VARCHAR(500),
    failure_reason TEXT,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Subscription upgrade/downgrade history
CREATE TABLE IF NOT EXISTS lic_schema.subscription_changes (
    change_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID REFERENCES lic_schema.user_subscriptions(subscription_id) ON DELETE CASCADE,
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    from_plan_id UUID REFERENCES lic_schema.subscription_plans(plan_id),
    to_plan_id UUID REFERENCES lic_schema.subscription_plans(plan_id),
    change_type VARCHAR(50), -- 'upgrade', 'downgrade', 'plan_change'
    effective_date TIMESTAMP DEFAULT NOW(),
    proration_amount DECIMAL(10,2),
    billing_cycle_change BOOLEAN DEFAULT false,
    initiated_by UUID REFERENCES lic_schema.users(user_id),
    reason TEXT,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_subscription_plans_type ON lic_schema.subscription_plans(plan_type);
CREATE INDEX IF NOT EXISTS idx_subscription_plans_active ON lic_schema.subscription_plans(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user_id ON lic_schema.user_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_status ON lic_schema.user_subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_end ON lic_schema.user_subscriptions(current_period_end);
CREATE INDEX IF NOT EXISTS idx_billing_history_subscription ON lic_schema.subscription_billing_history(subscription_id);
CREATE INDEX IF NOT EXISTS idx_billing_history_user ON lic_schema.subscription_billing_history(user_id);
CREATE INDEX IF NOT EXISTS idx_subscription_changes_subscription ON lic_schema.subscription_changes(subscription_id);

-- Updated at triggers
CREATE OR REPLACE FUNCTION update_subscription_plans_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_subscription_plans_updated_at
    BEFORE UPDATE ON lic_schema.subscription_plans
    FOR EACH ROW
    EXECUTE FUNCTION update_subscription_plans_updated_at();

CREATE OR REPLACE FUNCTION update_user_subscriptions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_user_subscriptions_updated_at
    BEFORE UPDATE ON lic_schema.user_subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION update_user_subscriptions_updated_at();

-- Insert default subscription plans
INSERT INTO lic_schema.subscription_plans (
    plan_name, plan_type, display_name, description, price_monthly, price_yearly,
    features, limitations, max_users, max_storage_gb, max_policies, trial_days, sort_order
) VALUES
('agent_starter', 'agent', 'Agent Starter', 'Perfect for new insurance agents', 999.00, 9999.00,
 '["basic_dashboard", "policy_management", "customer_crm", "basic_analytics", "email_support"]',
 '{"max_customers": 100, "max_policies": 500, "max_storage_gb": 5}',
 1, 5, 500, 14, 1),

('agent_professional', 'agent', 'Agent Professional', 'For growing insurance agencies', 2499.00, 24999.00,
 '["advanced_dashboard", "policy_management", "customer_crm", "advanced_analytics", "presentation_tools", "video_tutorials", "priority_support"]',
 '{"max_customers": 500, "max_policies": 2000, "max_storage_gb": 25}',
 3, 25, 2000, 14, 2),

('agent_enterprise', 'agent', 'Agent Enterprise', 'Complete solution for large agencies', 4999.00, 49999.00,
 '["enterprise_dashboard", "policy_management", "customer_crm", "advanced_analytics", "presentation_tools", "video_tutorials", "api_access", "white_label", "dedicated_support"]',
 '{"max_customers": 5000, "max_policies": 50000, "max_storage_gb": 100}',
 10, 100, 50000, 30, 3),

('customer_basic', 'customer', 'Customer Basic', 'Essential policy management', 99.00, 999.00,
 '["policy_view", "claim_tracking", "document_storage", "basic_support"]',
 '{"max_policies": 5, "max_storage_gb": 1}',
 1, 1, 5, 7, 1),

('customer_premium', 'customer', 'Customer Premium', 'Complete policy management suite', 299.00, 2999.00,
 '["policy_view", "claim_tracking", "document_storage", "advanced_analytics", "priority_support", "family_accounts"]',
 '{"max_policies": 20, "max_storage_gb": 10}',
 5, 10, 20, 14, 2);
