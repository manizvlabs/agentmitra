-- Add missing audit columns to subscription tables
-- These columns are required by the AuditMixin but were missing from the original schema

-- Add audit columns to subscription_plans table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'lic_schema' AND table_name = 'subscription_plans' AND column_name = 'created_by') THEN
        ALTER TABLE lic_schema.subscription_plans ADD COLUMN created_by UUID REFERENCES lic_schema.users(user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'lic_schema' AND table_name = 'subscription_plans' AND column_name = 'updated_by') THEN
        ALTER TABLE lic_schema.subscription_plans ADD COLUMN updated_by UUID REFERENCES lic_schema.users(user_id);
    END IF;
END $$;

-- Add audit columns to user_subscriptions table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'lic_schema' AND table_name = 'user_subscriptions' AND column_name = 'created_by') THEN
        ALTER TABLE lic_schema.user_subscriptions ADD COLUMN created_by UUID REFERENCES lic_schema.users(user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'lic_schema' AND table_name = 'user_subscriptions' AND column_name = 'updated_by') THEN
        ALTER TABLE lic_schema.user_subscriptions ADD COLUMN updated_by UUID REFERENCES lic_schema.users(user_id);
    END IF;
END $$;

-- Add audit columns to subscription_billing_history table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'lic_schema' AND table_name = 'subscription_billing_history' AND column_name = 'created_by') THEN
        ALTER TABLE lic_schema.subscription_billing_history ADD COLUMN created_by UUID REFERENCES lic_schema.users(user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'lic_schema' AND table_name = 'subscription_billing_history' AND column_name = 'updated_by') THEN
        ALTER TABLE lic_schema.subscription_billing_history ADD COLUMN updated_by UUID REFERENCES lic_schema.users(user_id);
    END IF;
END $$;
