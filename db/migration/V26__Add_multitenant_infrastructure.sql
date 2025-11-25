-- Agent Mitra - Migration V26: Add Core Multitenant Infrastructure
-- This migration adds the essential tenant-related tables and RLS policies for multitenancy

-- =====================================================
-- CREATE MISSING TENANT TABLES
-- =====================================================

-- Tenant users many-to-many relationship
CREATE TABLE IF NOT EXISTS lic_schema.tenant_users (
    tenant_user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES lic_schema.tenants(tenant_id),
    user_id UUID NOT NULL REFERENCES lic_schema.users(user_id),
    role VARCHAR(50) NOT NULL,
    permissions JSONB,
    is_primary BOOLEAN DEFAULT false,
    joined_at TIMESTAMP DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'active',

    UNIQUE(tenant_id, user_id)
);

-- Commission tracking table
CREATE TABLE IF NOT EXISTS lic_schema.commissions (
    commission_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES lic_schema.tenants(tenant_id),

    -- Commission details
    agent_id UUID NOT NULL REFERENCES lic_schema.agents(agent_id),
    policy_id UUID NOT NULL REFERENCES lic_schema.insurance_policies(policy_id),
    payment_id UUID NOT NULL REFERENCES lic_schema.premium_payments(payment_id),

    -- Commission calculation
    commission_amount DECIMAL(10, 2) NOT NULL,
    commission_rate DECIMAL(5, 2), -- Percentage
    commission_type VARCHAR(20) NOT NULL, -- 'first_year', 'renewal', 'bonus'

    -- Payment status
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'paid', 'cancelled'
    paid_date TIMESTAMP,
    payment_reference VARCHAR(255),

    -- Audit
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- ADD TENANT_ID COLUMNS TO EXISTING TABLES
-- =====================================================

-- Add tenant_id to agents table (if not exists)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_schema = 'lic_schema'
                   AND table_name = 'agents'
                   AND column_name = 'tenant_id') THEN
        ALTER TABLE lic_schema.agents ADD COLUMN tenant_id UUID REFERENCES lic_schema.tenants(tenant_id);
        -- Set default tenant_id for existing data
        UPDATE lic_schema.agents SET tenant_id = (SELECT tenant_id FROM lic_schema.tenants WHERE tenant_code = 'LIC' LIMIT 1) WHERE tenant_id IS NULL;
        ALTER TABLE lic_schema.agents ALTER COLUMN tenant_id SET NOT NULL;
    END IF;
END $$;

-- Add tenant_id to policyholders table (if not exists)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_schema = 'lic_schema'
                   AND table_name = 'policyholders'
                   AND column_name = 'tenant_id') THEN
        ALTER TABLE lic_schema.policyholders ADD COLUMN tenant_id UUID REFERENCES lic_schema.tenants(tenant_id);
        -- Set default tenant_id for existing data
        UPDATE lic_schema.policyholders SET tenant_id = (SELECT tenant_id FROM lic_schema.tenants WHERE tenant_code = 'LIC' LIMIT 1) WHERE tenant_id IS NULL;
        ALTER TABLE lic_schema.policyholders ALTER COLUMN tenant_id SET NOT NULL;
    END IF;
END $$;

-- Add tenant_id to insurance_policies table (if not exists)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_schema = 'lic_schema'
                   AND table_name = 'insurance_policies'
                   AND column_name = 'tenant_id') THEN
        ALTER TABLE lic_schema.insurance_policies ADD COLUMN tenant_id UUID REFERENCES lic_schema.tenants(tenant_id);
        -- Set default tenant_id for existing data
        UPDATE lic_schema.insurance_policies SET tenant_id = (SELECT tenant_id FROM lic_schema.tenants WHERE tenant_code = 'LIC' LIMIT 1) WHERE tenant_id IS NULL;
        ALTER TABLE lic_schema.insurance_policies ALTER COLUMN tenant_id SET NOT NULL;
    END IF;
END $$;

-- Add tenant_id to premium_payments table (if not exists)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_schema = 'lic_schema'
                   AND table_name = 'premium_payments'
                   AND column_name = 'tenant_id') THEN
        ALTER TABLE lic_schema.premium_payments ADD COLUMN tenant_id UUID REFERENCES lic_schema.tenants(tenant_id);
        -- Set default tenant_id for existing data
        UPDATE lic_schema.premium_payments SET tenant_id = (SELECT tenant_id FROM lic_schema.tenants WHERE tenant_code = 'LIC' LIMIT 1) WHERE tenant_id IS NULL;
        ALTER TABLE lic_schema.premium_payments ALTER COLUMN tenant_id SET NOT NULL;
    END IF;
END $$;

-- =====================================================
-- TENANT CONTEXT FUNCTIONS
-- =====================================================

-- Function to get current tenant context
CREATE OR REPLACE FUNCTION lic_schema.current_tenant_id()
RETURNS UUID AS $$
BEGIN
    RETURN NULLIF(current_setting('app.current_tenant_id', TRUE), '')::UUID;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Function to set tenant context
CREATE OR REPLACE FUNCTION lic_schema.set_tenant_context(tenant_uuid UUID)
RETURNS VOID AS $$
BEGIN
    PERFORM set_config('app.current_tenant_id', tenant_uuid::TEXT, FALSE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- ROW LEVEL SECURITY POLICIES (RLS)
-- =====================================================

-- Enable RLS on tenant-specific tables
ALTER TABLE lic_schema.agents ENABLE ROW LEVEL SECURITY;
ALTER TABLE lic_schema.policyholders ENABLE ROW LEVEL SECURITY;
ALTER TABLE lic_schema.insurance_policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE lic_schema.premium_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE lic_schema.commissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE lic_schema.tenant_users ENABLE ROW LEVEL SECURITY;

-- Create tenant isolation policies
CREATE POLICY tenant_agents_isolation ON lic_schema.agents
    FOR ALL USING (tenant_id = lic_schema.current_tenant_id());

CREATE POLICY tenant_policyholders_isolation ON lic_schema.policyholders
    FOR ALL USING (tenant_id = lic_schema.current_tenant_id());

CREATE POLICY tenant_policies_isolation ON lic_schema.insurance_policies
    FOR ALL USING (tenant_id = lic_schema.current_tenant_id());

CREATE POLICY tenant_payments_isolation ON lic_schema.premium_payments
    FOR ALL USING (tenant_id = lic_schema.current_tenant_id());

CREATE POLICY tenant_commissions_isolation ON lic_schema.commissions
    FOR ALL USING (tenant_id = lic_schema.current_tenant_id());

CREATE POLICY tenant_users_isolation ON lic_schema.tenant_users
    FOR ALL USING (tenant_id = lic_schema.current_tenant_id());

-- =====================================================
-- AUDIT LOGGING INFRASTRUCTURE
-- =====================================================

-- Create audit schema if not exists
CREATE SCHEMA IF NOT EXISTS audit;

-- Grant permissions
GRANT USAGE ON SCHEMA audit TO agentmitra;
GRANT CREATE ON SCHEMA audit TO agentmitra;
ALTER DEFAULT PRIVILEGES IN SCHEMA audit GRANT ALL ON TABLES TO agentmitra;

-- Create audit log table
CREATE TABLE IF NOT EXISTS audit.tenant_audit_log (
    audit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES lic_schema.tenants(tenant_id),
    user_id UUID REFERENCES lic_schema.users(user_id),
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id UUID,
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    compliance_flags JSONB,
    timestamp TIMESTAMP DEFAULT NOW()
);

-- Indexes for audit log
CREATE INDEX IF NOT EXISTS idx_audit_tenant_timestamp ON audit.tenant_audit_log(tenant_id, timestamp);
CREATE INDEX IF NOT EXISTS idx_audit_user_action ON audit.tenant_audit_log(user_id, action);
CREATE INDEX IF NOT EXISTS idx_audit_resource ON audit.tenant_audit_log(resource_type, resource_id);

-- =====================================================
-- TENANT USAGE MONITORING
-- =====================================================

-- Create tenant usage tracking table
CREATE TABLE IF NOT EXISTS lic_schema.tenant_usage (
    usage_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES lic_schema.tenants(tenant_id),
    metric_type VARCHAR(50) NOT NULL, -- 'api_calls', 'storage', 'users', 'policies'
    metric_value BIGINT NOT NULL,
    period_start TIMESTAMP NOT NULL,
    period_end TIMESTAMP NOT NULL,
    recorded_at TIMESTAMP DEFAULT NOW(),

    UNIQUE(tenant_id, metric_type, period_start)
);

-- Indexes for usage tracking
CREATE INDEX IF NOT EXISTS idx_tenant_usage_tenant_period ON lic_schema.tenant_usage(tenant_id, period_start, period_end);
CREATE INDEX IF NOT EXISTS idx_tenant_usage_metric ON lic_schema.tenant_usage(metric_type, period_start);

-- =====================================================
-- CREATE INDEXES FOR TENANT INFRASTRUCTURE
-- =====================================================

-- Indexes for tenant_users
CREATE INDEX IF NOT EXISTS idx_tenant_users_tenant_id ON lic_schema.tenant_users(tenant_id);
CREATE INDEX IF NOT EXISTS idx_tenant_users_user_id ON lic_schema.tenant_users(user_id);
CREATE INDEX IF NOT EXISTS idx_tenant_users_status ON lic_schema.tenant_users(status);

-- Indexes for commissions
CREATE INDEX IF NOT EXISTS idx_commissions_tenant_id ON lic_schema.commissions(tenant_id);
CREATE INDEX IF NOT EXISTS idx_commissions_agent_id ON lic_schema.commissions(agent_id);
CREATE INDEX IF NOT EXISTS idx_commissions_policy_id ON lic_schema.commissions(policy_id);
CREATE INDEX IF NOT EXISTS idx_commissions_payment_id ON lic_schema.commissions(payment_id);
CREATE INDEX IF NOT EXISTS idx_commissions_status ON lic_schema.commissions(status);

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================

-- Add comment to migration
COMMENT ON DATABASE agentmitra IS 'Agent Mitra - Multitenant Database with complete tenant isolation, RLS policies, and audit logging';