-- Migration V7: Database Performance Indexes
-- This migration adds performance indexes for production use

-- =====================================================
-- ADDITIONAL INDEXES FOR PERFORMANCE
-- =====================================================

-- Composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_users_role_status
ON lic_schema.users(role, status) WHERE status = 'active';

CREATE INDEX IF NOT EXISTS idx_users_phone_verified
ON lic_schema.users(phone_number, phone_verified) WHERE phone_verified = true;

CREATE INDEX IF NOT EXISTS idx_agents_code_status
ON lic_schema.agents(agent_code, status) WHERE status = 'active';

-- Performance indexes for session management
CREATE INDEX IF NOT EXISTS idx_user_sessions_active
ON lic_schema.user_sessions(user_id, expires_at DESC);

CREATE INDEX IF NOT EXISTS idx_user_sessions_token
ON lic_schema.user_sessions(session_token);

-- Policy performance indexes
CREATE INDEX IF NOT EXISTS idx_policies_dates_status
ON lic_schema.insurance_policies(start_date, maturity_date, status)
WHERE status IN ('active', 'pending_approval');

-- Payment performance indexes
CREATE INDEX IF NOT EXISTS idx_payments_policy_date
ON lic_schema.premium_payments(policy_id, payment_date DESC);

CREATE INDEX IF NOT EXISTS idx_payments_status_date
ON lic_schema.premium_payments(status, payment_date DESC)
WHERE status = 'completed';