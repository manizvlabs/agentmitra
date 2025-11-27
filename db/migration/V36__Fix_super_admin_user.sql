-- Fix super admin user configuration
-- Remove duplicate policyholder user and update super_admin phone number

-- Step 1: Delete the duplicate policyholder user with phone '9876543200'
DELETE FROM lic_schema.users
WHERE phone_number = '9876543200' AND role = 'policyholder';

-- Step 2: Update super_admin user phone number to '9876543200'
UPDATE lic_schema.users
SET phone_number = '9876543200'
WHERE role = 'super_admin' AND email = 'superadmin@test.com';

-- Step 3: Ensure super_admin user exists with correct data (if not already present)
INSERT INTO lic_schema.users (
    user_id,
    phone_number,
    email,
    first_name,
    last_name,
    password_hash,
    role,
    phone_verified,
    email_verified,
    status,
    created_at,
    updated_at
) VALUES (
    '38ab082d-d602-40f3-b83d-a652f1425349'::uuid,
    '9876543200',
    'superadmin@test.com',
    'Super',
    'Admin',
    '$2b$12$5Gx2B73HnJgG96BDFcT9HeO/qBABldwv9LXQaviYJJp9jOQN6f0AW',
    'super_admin',
    true,
    false,
    'active',
    NOW(),
    NOW()
) ON CONFLICT (user_id) DO UPDATE SET
    phone_number = EXCLUDED.phone_number,
    updated_at = NOW();
