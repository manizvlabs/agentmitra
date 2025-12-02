-- Agent Mitra - Migration V66: Fix Test User Passwords
-- This migration sets the correct password hash for 'testpassword' for all test users

-- =====================================================
-- UPDATE TEST USER PASSWORDS WITH CORRECT HASH
-- =====================================================

-- Update all test users to have the correct password hash for 'testpassword'
-- Hash generated using bcrypt: $2b$12$VCmGiyGxZl5Hx9Bh7nPQmegEgOy6pXtEv1jr4ZyJ5IERaM5Knmbj2
UPDATE lic_schema.users SET
    password_hash = '$2b$12$VCmGiyGxZl5Hx9Bh7nPQmegEgOy6pXtEv1jr4ZyJ5IERaM5Knmbj2'
WHERE phone_number IN (
    '+919876543200',  -- Super Admin
    '+919876543201',  -- Provider Admin
    '+919876543202',  -- Regional Manager
    '+919876543203',  -- Senior Agent
    '+919876543204',  -- Junior Agent
    '+919876543205',  -- Policyholder
    '+919876543206'   -- Support Staff
);

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================

-- Add comment to migration
COMMENT ON DATABASE agentmitra IS 'Agent Mitra - Fixed test user passwords to use correct hash for testpassword';
