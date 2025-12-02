-- Agent Mitra - Migration V68: Add missing subscription table columns
-- This migration adds the missing updated_at columns to subscription tables

-- Add missing updated_at columns
ALTER TABLE lic_schema.subscription_billing_history ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();
ALTER TABLE lic_schema.subscription_changes ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();

-- Rename metadata columns to match model expectations (if they still exist)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'lic_schema' AND table_name = 'subscription_billing_history' AND column_name = 'metadata') THEN
        ALTER TABLE lic_schema.subscription_billing_history RENAME COLUMN metadata TO subscription_metadata;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'lic_schema' AND table_name = 'subscription_changes' AND column_name = 'metadata') THEN
        ALTER TABLE lic_schema.subscription_changes RENAME COLUMN metadata TO subscription_metadata;
    END IF;
END $$;
