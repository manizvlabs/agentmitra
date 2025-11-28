-- Fix SQLAlchemy relationship constraints
-- This migration addresses the foreign key relationship issues that cause mapper initialization failures

-- =====================================================
-- FIX 1: Add missing foreign key constraints for subscription_changes
-- =====================================================

-- Ensure subscription_changes table has proper foreign key constraints
DO $$
BEGIN
    -- Add foreign key constraint for user_id if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_subscription_changes_user'
        AND table_schema = 'lic_schema'
    ) THEN
        ALTER TABLE lic_schema.subscription_changes
        ADD CONSTRAINT fk_subscription_changes_user
        FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;
    END IF;

    -- Add foreign key constraint for initiated_by if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_subscription_changes_initiated_by'
        AND table_schema = 'lic_schema'
    ) THEN
        ALTER TABLE lic_schema.subscription_changes
        ADD CONSTRAINT fk_subscription_changes_initiated_by
        FOREIGN KEY (initiated_by) REFERENCES lic_schema.users(user_id) ON DELETE SET NULL;
    END IF;
END $$;

-- =====================================================
-- FIX 2: Fix leads table foreign key constraints
-- =====================================================

DO $$
BEGIN
    -- Add foreign key constraint for converted_policy_id if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_leads_converted_policy'
        AND table_schema = 'lic_schema'
    ) THEN
        ALTER TABLE lic_schema.leads
        ADD CONSTRAINT fk_leads_converted_policy
        FOREIGN KEY (converted_policy_id) REFERENCES lic_schema.insurance_policies(policy_id) ON DELETE SET NULL;
    END IF;
END $$;

-- =====================================================
-- FIX 3: Fix customer_retention_analytics table foreign key
-- =====================================================

DO $$
BEGIN
    -- Add foreign key constraint for customer_id if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_customer_retention_customer'
        AND table_schema = 'lic_schema'
    ) THEN
        ALTER TABLE lic_schema.customer_retention_analytics
        ADD CONSTRAINT fk_customer_retention_customer
        FOREIGN KEY (customer_id) REFERENCES lic_schema.policyholders(policyholder_id) ON DELETE CASCADE;
    END IF;
END $$;

-- =====================================================
-- FIX 4: Add missing foreign key constraints for quotes
-- =====================================================

DO $$
BEGIN
    -- Add foreign key constraint for daily_quote_id in quote_sharing_analytics
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_quote_sharing_analytics_quote'
        AND table_schema = 'lic_schema'
    ) THEN
        ALTER TABLE lic_schema.quote_sharing_analytics
        ADD CONSTRAINT fk_quote_sharing_analytics_quote
        FOREIGN KEY (daily_quote_id) REFERENCES lic_schema.daily_quotes(daily_quote_id) ON DELETE CASCADE;
    END IF;
END $$;

-- =====================================================
-- FIX 5: Ensure all tables have tenant_id foreign keys where applicable
-- =====================================================

DO $$
BEGIN
    -- Add tenant foreign key constraints for tables that reference tenants
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_users_tenant'
        AND table_schema = 'lic_schema'
    ) THEN
        ALTER TABLE lic_schema.users
        ADD CONSTRAINT fk_users_tenant
        FOREIGN KEY (tenant_id) REFERENCES lic_schema.tenants(tenant_id) ON DELETE CASCADE;
    END IF;
END $$;

-- =====================================================
-- FIX 6: Add missing indexes for performance
-- =====================================================

-- Create indexes on commonly queried foreign key columns
CREATE INDEX IF NOT EXISTS idx_subscription_changes_user_id ON lic_schema.subscription_changes(user_id);
CREATE INDEX IF NOT EXISTS idx_subscription_changes_subscription_id ON lic_schema.subscription_changes(subscription_id);
CREATE INDEX IF NOT EXISTS idx_leads_converted_policy_id ON lic_schema.leads(converted_policy_id);
CREATE INDEX IF NOT EXISTS idx_customer_retention_customer_id ON lic_schema.customer_retention_analytics(customer_id);
CREATE INDEX IF NOT EXISTS idx_quote_sharing_analytics_quote_id ON lic_schema.quote_sharing_analytics(daily_quote_id);

-- =====================================================
-- VERIFICATION: Check for any remaining orphaned records
-- =====================================================

-- Log any potential data integrity issues (this won't fail the migration)
DO $$
DECLARE
    orphaned_count INTEGER;
BEGIN
    -- Check for subscription_changes with invalid user_id
    SELECT COUNT(*) INTO orphaned_count
    FROM lic_schema.subscription_changes sc
    LEFT JOIN lic_schema.users u ON sc.user_id = u.user_id
    WHERE u.user_id IS NULL;

    IF orphaned_count > 0 THEN
        RAISE WARNING 'Found % orphaned subscription_changes records with invalid user_id', orphaned_count;
    END IF;

    -- Check for leads with invalid converted_policy_id
    SELECT COUNT(*) INTO orphaned_count
    FROM lic_schema.leads l
    LEFT JOIN lic_schema.insurance_policies ip ON l.converted_policy_id = ip.policy_id
    WHERE l.converted_policy_id IS NOT NULL AND ip.policy_id IS NULL;

    IF orphaned_count > 0 THEN
        RAISE WARNING 'Found % orphaned leads records with invalid converted_policy_id', orphaned_count;
    END IF;
END $$;
