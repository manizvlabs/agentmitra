-- Agent Mitra - Migration V33: Fix Test User Passwords
-- This migration updates the password hashes for all RBAC test users to use the correct hash for "testpassword"

-- =====================================================
-- UPDATE TEST USER PASSWORDS
-- =====================================================

-- Update password hash for all RBAC test users to use correct hash for "testpassword"
UPDATE lic_schema.users
SET password_hash = '$2b$12$5Gx2B73HnJgG96BDFcT9HeO/qBABldwv9LXQaviYJJp9jOQN6f0AW'
WHERE phone_number IN (
    '+919876543200', -- super_admin
    '+919876543201', -- insurance_provider_admin
    '+919876543202', -- regional_manager
    '+919876543203', -- senior_agent
    '+919876543204', -- junior_agent
    '+919876543205', -- policyholder
    '+919876543206'  -- support_staff
);

-- =====================================================
-- VERIFICATION
-- =====================================================

-- Add comment to verify the migration ran successfully
COMMENT ON DATABASE agentmitra IS 'Agent Mitra - Fixed test user passwords to use correct hash for "testpassword"';
