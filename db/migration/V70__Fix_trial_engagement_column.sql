-- Fix trial_engagement table column naming to match SQLAlchemy model
-- The model expects 'engagement_metadata' but migration created 'metadata'

-- First check if the old column exists and rename it, or add the correct column
DO $$
BEGIN
    -- If the old 'metadata' column exists, rename it to 'engagement_metadata'
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'lic_schema'
        AND table_name = 'trial_engagement'
        AND column_name = 'metadata'
    ) THEN
        ALTER TABLE lic_schema.trial_engagement
        RENAME COLUMN metadata TO engagement_metadata;
    END IF;

    -- If neither exists, add the correct column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'lic_schema'
        AND table_name = 'trial_engagement'
        AND column_name = 'engagement_metadata'
    ) THEN
        ALTER TABLE lic_schema.trial_engagement
        ADD COLUMN engagement_metadata JSONB;
    END IF;
END $$;

-- Add created_at and updated_at columns if they don't exist (from TimestampMixin)
ALTER TABLE lic_schema.trial_engagement
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT NOW();

ALTER TABLE lic_schema.trial_engagement
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();

-- Add created_by and updated_by columns if they don't exist (from AuditMixin)
ALTER TABLE lic_schema.trial_engagement
ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES lic_schema.users(user_id);

ALTER TABLE lic_schema.trial_engagement
ADD COLUMN IF NOT EXISTS updated_by UUID REFERENCES lic_schema.users(user_id);

-- Add indexes for the new columns
CREATE INDEX IF NOT EXISTS idx_trial_engagement_created_by ON lic_schema.trial_engagement(created_by);
CREATE INDEX IF NOT EXISTS idx_trial_engagement_updated_by ON lic_schema.trial_engagement(updated_by);
CREATE INDEX IF NOT EXISTS idx_trial_engagement_updated_at ON lic_schema.trial_engagement(updated_at);

-- Create a trigger to automatically update the updated_at column
CREATE OR REPLACE FUNCTION update_trial_engagement_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_trial_engagement_updated_at
    BEFORE UPDATE ON lic_schema.trial_engagement
    FOR EACH ROW
    EXECUTE FUNCTION update_trial_engagement_updated_at();
