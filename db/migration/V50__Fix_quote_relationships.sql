-- Fix quote-related table relationships and foreign keys
-- This migration addresses the DailyQuote.sharing_analytics relationship issues

-- =====================================================
-- FIX 1: Correct foreign key reference for quote_sharing_analytics
-- =====================================================

-- Fix quote relationships - both tables are in lic_schema

DO $$
BEGIN
    -- Drop the incorrect foreign key constraint if it exists
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'quote_sharing_analytics_quote_id_fkey'
        AND table_schema = 'lic_schema'
    ) THEN
        ALTER TABLE lic_schema.quote_sharing_analytics
        DROP CONSTRAINT quote_sharing_analytics_quote_id_fkey;
    END IF;

    -- Add the correct foreign key constraint
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_quote_sharing_analytics_quote'
        AND table_schema = 'lic_schema'
    ) THEN
        ALTER TABLE lic_schema.quote_sharing_analytics
        ADD CONSTRAINT fk_quote_sharing_analytics_quote
        FOREIGN KEY (quote_id) REFERENCES lic_schema.daily_quotes(quote_id) ON DELETE CASCADE;
    END IF;
END $$;

-- =====================================================
-- FIX 2: Ensure daily_quotes table has proper agent relationship
-- =====================================================

DO $$
BEGIN
    -- Ensure the agent_id foreign key exists and is correct
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_daily_quotes_agent'
        AND table_schema = 'lic_schema'
    ) THEN
        -- First drop any existing incorrect constraint
        IF EXISTS (
            SELECT 1 FROM information_schema.table_constraints
            WHERE constraint_name = 'daily_quotes_agent_id_fkey'
            AND table_schema = 'lic_schema'
        ) THEN
            ALTER TABLE lic_schema.daily_quotes
            DROP CONSTRAINT daily_quotes_agent_id_fkey;
        END IF;

        -- Add the correct constraint
        ALTER TABLE lic_schema.daily_quotes
        ADD CONSTRAINT fk_daily_quotes_agent
        FOREIGN KEY (agent_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;
    END IF;
END $$;

-- =====================================================
-- FIX 3: Fix quote_sharing_analytics agent relationship
-- =====================================================

DO $$
BEGIN
    -- Ensure the agent_id foreign key exists and is correct
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_quote_sharing_analytics_agent'
        AND table_schema = 'lic_schema'
    ) THEN
        -- First drop any existing incorrect constraint
        IF EXISTS (
            SELECT 1 FROM information_schema.table_constraints
            WHERE constraint_name = 'quote_sharing_analytics_agent_id_fkey'
            AND table_schema = 'lic_schema'
        ) THEN
            ALTER TABLE lic_schema.quote_sharing_analytics
            DROP CONSTRAINT quote_sharing_analytics_agent_id_fkey;
        END IF;

        -- Add the correct constraint
        ALTER TABLE lic_schema.quote_sharing_analytics
        ADD CONSTRAINT fk_quote_sharing_analytics_agent
        FOREIGN KEY (agent_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;
    END IF;
END $$;

-- =====================================================
-- FIX 4: Ensure quote_performance table relationships
-- =====================================================

DO $$
BEGIN
    -- Ensure quote_performance has correct foreign key to daily_quotes
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_quote_performance_quote'
        AND table_schema = 'lic_schema'
    ) THEN
        -- First drop any existing incorrect constraint
        IF EXISTS (
            SELECT 1 FROM information_schema.table_constraints
            WHERE constraint_name = 'quote_performance_quote_id_fkey'
            AND table_schema = 'lic_schema'
        ) THEN
            ALTER TABLE lic_schema.quote_performance
            DROP CONSTRAINT quote_performance_quote_id_fkey;
        END IF;

        -- Add the correct constraint
        ALTER TABLE lic_schema.quote_performance
        ADD CONSTRAINT fk_quote_performance_quote
        FOREIGN KEY (quote_id) REFERENCES lic_schema.daily_quotes(quote_id) ON DELETE CASCADE;
    END IF;
END $$;

-- =====================================================
-- FIX 5: Add performance indexes
-- =====================================================

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_daily_quotes_agent_id ON lic_schema.daily_quotes(agent_id);
CREATE INDEX IF NOT EXISTS idx_quote_sharing_analytics_quote_id ON lic_schema.quote_sharing_analytics(quote_id);
CREATE INDEX IF NOT EXISTS idx_quote_sharing_analytics_agent_id ON lic_schema.quote_sharing_analytics(agent_id);
CREATE INDEX IF NOT EXISTS idx_quote_performance_quote_id ON lic_schema.quote_performance(quote_id);

-- =====================================================
-- VERIFICATION: Check for orphaned records
-- =====================================================

DO $$
DECLARE
    orphaned_count INTEGER;
BEGIN
    -- Check for quote_sharing_analytics with invalid quote_id
    SELECT COUNT(*) INTO orphaned_count
    FROM lic_schema.quote_sharing_analytics qsa
    LEFT JOIN lic_schema.daily_quotes dq ON qsa.quote_id = dq.quote_id
    WHERE dq.quote_id IS NULL;

    IF orphaned_count > 0 THEN
        RAISE WARNING 'Found % orphaned quote_sharing_analytics records with invalid quote_id', orphaned_count;
    END IF;

    -- Check for daily_quotes with invalid agent_id
    SELECT COUNT(*) INTO orphaned_count
    FROM lic_schema.daily_quotes dq
    LEFT JOIN lic_schema.users u ON dq.agent_id = u.user_id
    WHERE u.user_id IS NULL;

    IF orphaned_count > 0 THEN
        RAISE WARNING 'Found % orphaned daily_quotes records with invalid agent_id', orphaned_count;
    END IF;
END $$;
