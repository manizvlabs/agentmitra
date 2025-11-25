-- Agent Mitra - Migration V29: Add Tenant Columns for Row-Level Security
-- This migration adds tenant_id columns to all tables that need tenant isolation

-- =====================================================
-- ADD TENANT_ID COLUMNS TO TABLES
-- =====================================================

-- Notifications table
ALTER TABLE lic_schema.notifications
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES lic_schema.tenants(tenant_id);

-- Campaigns table (if exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'campaigns') THEN
        EXECUTE 'ALTER TABLE lic_schema.campaigns ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES lic_schema.tenants(tenant_id)';
    END IF;
END $$;

-- Commissions table (if exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'commissions') THEN
        EXECUTE 'ALTER TABLE lic_schema.commissions ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES lic_schema.tenants(tenant_id)';
    END IF;
END $$;

-- Callback requests table (if exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'callback_requests') THEN
        EXECUTE 'ALTER TABLE lic_schema.callback_requests ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES lic_schema.tenants(tenant_id)';
    END IF;
END $$;

-- Callback activities table (if exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'callback_activities') THEN
        EXECUTE 'ALTER TABLE lic_schema.callback_activities ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES lic_schema.tenants(tenant_id)';
    END IF;
END $$;

-- Presentations table (if exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'presentations') THEN
        EXECUTE 'ALTER TABLE lic_schema.presentations ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES lic_schema.tenants(tenant_id)';
    END IF;
END $$;

-- =====================================================
-- UPDATE EXISTING DATA WITH DEFAULT TENANT
-- =====================================================

-- Get default tenant (LIC)
CREATE OR REPLACE FUNCTION get_default_tenant_id()
RETURNS UUID AS $$
DECLARE
    default_tenant_id UUID;
BEGIN
    SELECT tenant_id INTO default_tenant_id
    FROM lic_schema.tenants
    WHERE tenant_code = 'LIC'
    LIMIT 1;

    RETURN default_tenant_id;
END;
$$ LANGUAGE plpgsql;

-- Update notifications with default tenant
UPDATE lic_schema.notifications
SET tenant_id = get_default_tenant_id()
WHERE tenant_id IS NULL;

-- Update campaigns with default tenant (if exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'campaigns') THEN
        EXECUTE 'UPDATE lic_schema.campaigns SET tenant_id = get_default_tenant_id() WHERE tenant_id IS NULL';
    END IF;
END $$;

-- Update commissions with default tenant (if exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'commissions') THEN
        EXECUTE 'UPDATE lic_schema.commissions SET tenant_id = get_default_tenant_id() WHERE tenant_id IS NULL';
    END IF;
END $$;

-- Update callback requests with default tenant (if exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'callback_requests') THEN
        EXECUTE 'UPDATE lic_schema.callback_requests SET tenant_id = get_default_tenant_id() WHERE tenant_id IS NULL';
    END IF;
END $$;

-- Update callback activities with default tenant (if exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'callback_activities') THEN
        EXECUTE 'UPDATE lic_schema.callback_activities SET tenant_id = get_default_tenant_id() WHERE tenant_id IS NULL';
    END IF;
END $$;

-- Update presentations with default tenant (if exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'presentations') THEN
        EXECUTE 'UPDATE lic_schema.presentations SET tenant_id = get_default_tenant_id() WHERE tenant_id IS NULL';
    END IF;
END $$;

-- Drop the helper function
DROP FUNCTION get_default_tenant_id();

-- =====================================================
-- ADD NOT NULL CONSTRAINTS AFTER DATA UPDATE
-- =====================================================

-- Make tenant_id NOT NULL for tables that need it
ALTER TABLE lic_schema.notifications
ALTER COLUMN tenant_id SET NOT NULL;

-- Make tenant_id NOT NULL for other tables (conditional)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'campaigns') THEN
        EXECUTE 'ALTER TABLE lic_schema.campaigns ALTER COLUMN tenant_id SET NOT NULL';
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'commissions') THEN
        EXECUTE 'ALTER TABLE lic_schema.commissions ALTER COLUMN tenant_id SET NOT NULL';
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'callback_requests') THEN
        EXECUTE 'ALTER TABLE lic_schema.callback_requests ALTER COLUMN tenant_id SET NOT NULL';
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'callback_activities') THEN
        EXECUTE 'ALTER TABLE lic_schema.callback_activities ALTER COLUMN tenant_id SET NOT NULL';
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'presentations') THEN
        EXECUTE 'ALTER TABLE lic_schema.presentations ALTER COLUMN tenant_id SET NOT NULL';
    END IF;
END $$;

-- =====================================================
-- CREATE INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_notifications_tenant_id ON lic_schema.notifications(tenant_id);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'campaigns') THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_campaigns_tenant_id ON lic_schema.campaigns(tenant_id)';
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'commissions') THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_commissions_tenant_id ON lic_schema.commissions(tenant_id)';
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'callback_requests') THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_callback_requests_tenant_id ON lic_schema.callback_requests(tenant_id)';
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'callback_activities') THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_callback_activities_tenant_id ON lic_schema.callback_activities(tenant_id)';
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lic_schema' AND table_name = 'presentations') THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_presentations_tenant_id ON lic_schema.presentations(tenant_id)';
    END IF;
END $$;

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================

-- Add comment to migration
COMMENT ON DATABASE agentmitra IS 'Agent Mitra - Added tenant_id columns to all tables for RLS implementation';
