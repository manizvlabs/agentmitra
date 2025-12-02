-- Agent Mitra - Migration V67: Setup Subscription System
-- This migration sets up the complete subscription system with plans, data, and relationships

-- =====================================================
-- CREATE SUBSCRIPTION TABLES (if not exist)
-- =====================================================

-- Subscription plans table
CREATE TABLE IF NOT EXISTS lic_schema.subscription_plans (
    plan_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_name VARCHAR(100) NOT NULL UNIQUE,
    plan_type VARCHAR(50) NOT NULL, -- 'agent', 'customer', 'enterprise'
    display_name VARCHAR(255) NOT NULL,
    description TEXT,
    price_monthly DECIMAL(10, 2),
    price_yearly DECIMAL(10, 2),
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
    updated_at TIMESTAMP DEFAULT NOW(),
    created_by UUID REFERENCES lic_schema.users(user_id),
    updated_by UUID REFERENCES lic_schema.users(user_id)
);

-- User subscriptions table
CREATE TABLE IF NOT EXISTS lic_schema.user_subscriptions (
    subscription_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES lic_schema.subscription_plans(plan_id),
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
    amount DECIMAL(10, 2),
    currency VARCHAR(3) DEFAULT 'INR',
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    tax_amount DECIMAL(10, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    created_by UUID REFERENCES lic_schema.users(user_id),
    updated_by UUID REFERENCES lic_schema.users(user_id)
);

-- Subscription billing history table
CREATE TABLE IF NOT EXISTS lic_schema.subscription_billing_history (
    billing_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID NOT NULL REFERENCES lic_schema.user_subscriptions(subscription_id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
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
    subscription_metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Subscription changes table
CREATE TABLE IF NOT EXISTS lic_schema.subscription_changes (
    change_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID NOT NULL REFERENCES lic_schema.user_subscriptions(subscription_id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    from_plan_id UUID REFERENCES lic_schema.subscription_plans(plan_id),
    to_plan_id UUID NOT NULL REFERENCES lic_schema.subscription_plans(plan_id),
    change_type VARCHAR(50), -- 'upgrade', 'downgrade', 'plan_change'
    effective_date TIMESTAMP DEFAULT NOW(),
    proration_amount DECIMAL(10, 2),
    billing_cycle_change BOOLEAN DEFAULT false,
    initiated_by UUID REFERENCES lic_schema.users(user_id),
    reason TEXT,
    subscription_metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- ADD INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_subscription_plans_active ON lic_schema.subscription_plans(is_active);
CREATE INDEX IF NOT EXISTS idx_subscription_plans_type ON lic_schema.subscription_plans(plan_type);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user ON lic_schema.user_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_status ON lic_schema.user_subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_plan ON lic_schema.user_subscriptions(plan_id);
CREATE INDEX IF NOT EXISTS idx_billing_history_subscription ON lic_schema.subscription_billing_history(subscription_id);
CREATE INDEX IF NOT EXISTS idx_billing_history_user ON lic_schema.subscription_billing_history(user_id);
CREATE INDEX IF NOT EXISTS idx_subscription_changes_subscription ON lic_schema.subscription_changes(subscription_id);

-- =====================================================
-- SETUP SUBSCRIPTION PLANS
-- =====================================================

-- Update existing plans and add missing ones

-- Update agent_starter
UPDATE lic_schema.subscription_plans SET
    display_name = 'Starter',
    description = 'Perfect for individual agents',
    price_monthly = 499.00,
    price_yearly = 4999.00,
    features = '["Advanced policy management", "Customer relationship tools", "Commission tracking", "Basic reporting", "Priority email support", "Mobile app access", "Document storage"]'::jsonb,
    limitations = '{"max_customers": 100, "max_policies": 500, "storage_gb": 5}'::jsonb,
    max_users = 1,
    max_storage_gb = 5,
    max_policies = 500,
    is_popular = false,
    sort_order = 2,
    trial_days = 14
WHERE plan_name = 'agent_starter';

-- Update agent_professional
UPDATE lic_schema.subscription_plans SET
    display_name = 'Professional',
    description = 'For growing agencies',
    price_monthly = 1499.00,
    price_yearly = 14999.00,
    features = '["All Starter features", "Team collaboration", "Advanced analytics", "Custom reporting", "API access", "Priority phone support", "White-label options", "Advanced document management"]'::jsonb,
    limitations = '{"max_customers": 1000, "max_policies": 5000, "storage_gb": 25}'::jsonb,
    max_users = 5,
    max_storage_gb = 25,
    max_policies = 5000,
    is_popular = true,
    sort_order = 3,
    trial_days = 30
WHERE plan_name = 'agent_professional';

-- Update agent_enterprise
UPDATE lic_schema.subscription_plans SET
    display_name = 'Enterprise',
    description = 'For large insurance agencies',
    price_monthly = 4999.00,
    price_yearly = 49999.00,
    features = '["All Professional features", "Unlimited team members", "Advanced AI insights", "Custom integrations", "Dedicated account manager", "24/7 phone support", "Advanced security", "Custom SLA", "Multi-tenant support"]'::jsonb,
    limitations = '{"max_customers": -1, "max_policies": -1, "storage_gb": -1}'::jsonb,
    max_users = -1,
    max_storage_gb = -1,
    max_policies = -1,
    is_popular = false,
    sort_order = 4,
    trial_days = 30
WHERE plan_name = 'agent_enterprise';

-- Update customer_basic
UPDATE lic_schema.subscription_plans SET
    display_name = 'Basic',
    description = 'Essential policy management',
    price_monthly = 99.00,
    price_yearly = 999.00,
    features = '["Policy tracking", "Premium reminders", "Document access", "Basic support", "Mobile app access"]'::jsonb,
    limitations = '{"max_policies": 5, "storage_gb": 1}'::jsonb,
    max_users = 1,
    max_storage_gb = 1,
    max_policies = 5,
    is_popular = false,
    sort_order = 1,
    trial_days = 7
WHERE plan_name = 'customer_basic';

-- Update customer_premium
UPDATE lic_schema.subscription_plans SET
    display_name = 'Premium',
    description = 'Enhanced policy management',
    price_monthly = 299.00,
    price_yearly = 2999.00,
    features = '["All Basic features", "Family policy management", "Advanced analytics", "Priority support", "Multi-device access", "Offline access", "Policy comparison tools"]'::jsonb,
    limitations = '{"max_policies": 20, "storage_gb": 5}'::jsonb,
    max_users = 5,
    max_storage_gb = 5,
    max_policies = 20,
    is_popular = true,
    sort_order = 2,
    trial_days = 14
WHERE plan_name = 'customer_premium';

-- Add missing agent_free plan
INSERT INTO lic_schema.subscription_plans (
    plan_name, plan_type, display_name, description,
    price_monthly, price_yearly, currency, features, limitations,
    max_users, max_storage_gb, max_policies, is_active, is_popular, sort_order, trial_days
) VALUES (
    'agent_free', 'agent', 'Free', 'Basic features for getting started',
    0.00, 0.00, 'INR',
    '["Basic policy management", "Customer profiles", "Email support", "Mobile app access"]'::jsonb,
    '{"max_customers": 10, "max_policies": 25, "storage_gb": 1}'::jsonb,
    1, 1, 25, true, false, 1, 14
) ON CONFLICT (plan_name) DO NOTHING;

-- Add missing customer_family plan
INSERT INTO lic_schema.subscription_plans (
    plan_name, plan_type, display_name, description,
    price_monthly, price_yearly, currency, features, limitations,
    max_users, max_storage_gb, max_policies, is_active, is_popular, sort_order, trial_days
) VALUES (
    'customer_family', 'customer', 'Family', 'Complete family protection',
    599.00, 5999.00, 'INR',
    '["All Premium features", "Family dashboard", "Emergency contacts", "Health tracking", "Investment insights", "Dedicated relationship manager", "Custom reporting"]'::jsonb,
    '{"max_policies": 50, "storage_gb": 10}'::jsonb,
    10, 10, 50, true, false, 3, 30
) ON CONFLICT (plan_name) DO NOTHING;

-- Customer Plans (for policyholders)
INSERT INTO lic_schema.subscription_plans (
    plan_id, plan_name, plan_type, display_name, description,
    price_monthly, price_yearly, currency, features, limitations,
    max_users, max_storage_gb, max_policies, is_active, is_popular, sort_order, trial_days
) VALUES
-- Customer Basic
(
    '00000000-0000-0000-0000-000000000101'::uuid,
    'customer_basic', 'customer', 'Basic', 'Essential policy management',
    99.00, 999.00, 'INR',
    '["Policy tracking", "Premium reminders", "Document access", "Basic support", "Mobile app access"]'::jsonb,
    '{"max_policies": 5, "storage_gb": 1}'::jsonb,
    1, 1, 5, true, false, 1, 7
),
-- Customer Premium
(
    '00000000-0000-0000-0000-000000000102'::uuid,
    'customer_premium', 'customer', 'Premium', 'Enhanced policy management',
    299.00, 2999.00, 'INR',
    '["All Basic features", "Family policy management", "Advanced analytics", "Priority support", "Multi-device access", "Offline access", "Policy comparison tools"]'::jsonb,
    '{"max_policies": 20, "storage_gb": 5}'::jsonb,
    5, 5, 20, true, true, 2, 14
),
-- Customer Family
(
    '00000000-0000-0000-0000-000000000103'::uuid,
    'customer_family', 'customer', 'Family', 'Complete family protection',
    599.00, 5999.00, 'INR',
    '["All Premium features", "Family dashboard", "Emergency contacts", "Health tracking", "Investment insights", "Dedicated relationship manager", "Custom reporting"]'::jsonb,
    '{"max_policies": 50, "storage_gb": 10}'::jsonb,
    10, 10, 50, true, false, 3, 30
)
ON CONFLICT (plan_name) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    price_monthly = EXCLUDED.price_monthly,
    price_yearly = EXCLUDED.price_yearly,
    features = EXCLUDED.features,
    limitations = EXCLUDED.limitations,
    max_users = EXCLUDED.max_users,
    max_storage_gb = EXCLUDED.max_storage_gb,
    max_policies = EXCLUDED.max_policies,
    is_popular = EXCLUDED.is_popular,
    sort_order = EXCLUDED.sort_order,
    trial_days = EXCLUDED.trial_days;

-- =====================================================
-- SETUP SAMPLE USER SUBSCRIPTIONS FOR TESTING
-- =====================================================

-- Create subscriptions for test users using actual plan IDs
INSERT INTO lic_schema.user_subscriptions (
    user_id, plan_id, billing_cycle, status, trial_start, trial_end,
    current_period_start, current_period_end, amount, currency
)
SELECT
    u.user_id,
    CASE
        WHEN u.phone_number = '+919876543200' THEN (SELECT plan_id FROM lic_schema.subscription_plans WHERE plan_name = 'agent_professional') -- Super Admin -> Professional plan
        WHEN u.phone_number = '+919876543201' THEN (SELECT plan_id FROM lic_schema.subscription_plans WHERE plan_name = 'agent_professional') -- Provider Admin -> Professional plan
        WHEN u.phone_number = '+919876543202' THEN (SELECT plan_id FROM lic_schema.subscription_plans WHERE plan_name = 'agent_starter') -- Regional Manager -> Starter plan
        WHEN u.phone_number = '+919876543203' THEN (SELECT plan_id FROM lic_schema.subscription_plans WHERE plan_name = 'agent_starter') -- Senior Agent -> Starter plan
        WHEN u.phone_number = '+919876543204' THEN (SELECT plan_id FROM lic_schema.subscription_plans WHERE plan_name = 'agent_free') -- Junior Agent -> Free plan
        WHEN u.phone_number = '+919876543205' THEN (SELECT plan_id FROM lic_schema.subscription_plans WHERE plan_name = 'customer_basic') -- Policyholder -> Customer Basic
        WHEN u.phone_number = '+919876543206' THEN (SELECT plan_id FROM lic_schema.subscription_plans WHERE plan_name = 'customer_basic') -- Support Staff -> Customer Basic
        ELSE (SELECT plan_id FROM lic_schema.subscription_plans WHERE plan_name = 'agent_free') -- Default to Free plan
    END,
    'monthly',
    'active',
    NOW(),
    NOW() + INTERVAL '14 days',
    NOW(),
    NOW() + INTERVAL '1 month',
    CASE
        WHEN u.phone_number = '+919876543200' THEN 1499.00
        WHEN u.phone_number = '+919876543201' THEN 1499.00
        WHEN u.phone_number = '+919876543202' THEN 499.00
        WHEN u.phone_number = '+919876543203' THEN 499.00
        WHEN u.phone_number = '+919876543204' THEN 0.00
        WHEN u.phone_number = '+919876543205' THEN 99.00
        WHEN u.phone_number = '+919876543206' THEN 99.00
        ELSE 0.00
    END,
    'INR'
FROM lic_schema.users u
WHERE u.phone_number IN (
    '+919876543200', '+919876543201', '+919876543202',
    '+919876543203', '+919876543204', '+919876543205', '+919876543206'
)
AND NOT EXISTS (
    SELECT 1 FROM lic_schema.user_subscriptions us
    WHERE us.user_id = u.user_id
);

-- =====================================================
-- ADD SAMPLE BILLING HISTORY
-- =====================================================

-- Add billing history for active subscriptions
INSERT INTO lic_schema.subscription_billing_history (
    subscription_id, user_id, amount, currency, billing_date,
    billing_period_start, billing_period_end, payment_gateway, status
)
SELECT
    us.subscription_id,
    us.user_id,
    us.amount,
    us.currency,
    NOW() - INTERVAL '30 days',
    NOW() - INTERVAL '60 days',
    NOW() - INTERVAL '30 days',
    'razorpay',
    'paid'
FROM lic_schema.user_subscriptions us
WHERE us.status = 'active' AND us.amount > 0
AND NOT EXISTS (
    SELECT 1 FROM lic_schema.subscription_billing_history bh
    WHERE bh.subscription_id = us.subscription_id
);

-- =====================================================
-- FIX MISSING COLUMNS
-- =====================================================

-- Add missing updated_at columns
ALTER TABLE lic_schema.subscription_billing_history ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();
ALTER TABLE lic_schema.subscription_changes ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();

-- Rename metadata columns to match model expectations
ALTER TABLE lic_schema.subscription_billing_history RENAME COLUMN metadata TO subscription_metadata;
ALTER TABLE lic_schema.subscription_changes RENAME COLUMN metadata TO subscription_metadata;

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================

-- Add comment to migration
COMMENT ON DATABASE agentmitra IS 'Agent Mitra - Complete subscription system with plans, user subscriptions, and billing history';
