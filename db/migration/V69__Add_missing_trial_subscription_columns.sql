-- Add missing columns to trial_subscriptions table to match SQLAlchemy model
-- The model inherits from TimestampMixin and AuditMixin which require these columns

-- Add updated_at column (from TimestampMixin)
ALTER TABLE lic_schema.trial_subscriptions
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();

-- Add created_by and updated_by columns (from AuditMixin)
ALTER TABLE lic_schema.trial_subscriptions
ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES lic_schema.users(user_id);

ALTER TABLE lic_schema.trial_subscriptions
ADD COLUMN IF NOT EXISTS updated_by UUID REFERENCES lic_schema.users(user_id);

-- Add indexes for the new columns
CREATE INDEX IF NOT EXISTS idx_trial_subscriptions_created_by ON lic_schema.trial_subscriptions(created_by);
CREATE INDEX IF NOT EXISTS idx_trial_subscriptions_updated_by ON lic_schema.trial_subscriptions(updated_by);
CREATE INDEX IF NOT EXISTS idx_trial_subscriptions_updated_at ON lic_schema.trial_subscriptions(updated_at);

-- Update existing records to have updated_at = created_at initially
UPDATE lic_schema.trial_subscriptions
SET updated_at = created_at
WHERE updated_at IS NULL;

-- Create a trigger to automatically update the updated_at column
CREATE OR REPLACE FUNCTION update_trial_subscription_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_trial_subscription_updated_at
    BEFORE UPDATE ON lic_schema.trial_subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION update_trial_subscription_updated_at();
