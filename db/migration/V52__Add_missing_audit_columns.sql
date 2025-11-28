-- Add missing audit columns to existing tables
-- These columns are defined in AuditMixin but missing from some tables

-- Add audit columns to daily_quotes table
ALTER TABLE lic_schema.daily_quotes
ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES lic_schema.users(user_id),
ADD COLUMN IF NOT EXISTS updated_by UUID REFERENCES lic_schema.users(user_id);

-- Add audit columns to subscription_plans table if missing
ALTER TABLE lic_schema.subscription_plans
ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES lic_schema.users(user_id),
ADD COLUMN IF NOT EXISTS updated_by UUID REFERENCES lic_schema.users(user_id);

-- Add audit columns to user_subscriptions table if missing
ALTER TABLE lic_schema.user_subscriptions
ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES lic_schema.users(user_id),
ADD COLUMN IF NOT EXISTS updated_by UUID REFERENCES lic_schema.users(user_id);

-- Add missing currency column to subscription_plans
ALTER TABLE lic_schema.subscription_plans
ADD COLUMN IF NOT EXISTS currency VARCHAR(10) DEFAULT 'INR';

-- Add missing subscription_end_date column to user_subscriptions
ALTER TABLE lic_schema.user_subscriptions
ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMP;
