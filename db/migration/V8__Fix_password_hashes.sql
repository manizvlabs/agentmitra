-- Fix password hashes for test users
-- This migration updates the invalid password hashes with proper bcrypt hashes

-- Update test agent password hash (password: password123)
UPDATE lic_schema.users
SET password_hash = '$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO'
WHERE user_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid;

-- Update test customer password hash (password: password123)
UPDATE lic_schema.users
SET password_hash = '$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO'
WHERE user_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12'::uuid;

-- Update test customer 2 password hash (password: password123)
UPDATE lic_schema.users
SET password_hash = '$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO'
WHERE user_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13'::uuid;

-- Note: All test users now use password 'password123' with proper bcrypt hash
