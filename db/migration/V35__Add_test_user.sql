-- Add test user for development
INSERT INTO lic_schema.users (
    user_id, 
    phone_number, 
    password_hash, 
    phone_verified, 
    role, 
    created_at, 
    updated_at
) VALUES (
    gen_random_uuid(),
    '9876543200',
    '$2b$12$kXqzhSrOH3MdicUYc.VphuGcjQtVXiayT/5NIY4CLfmxNowr4NrCG',
    true,
    'policyholder',
    NOW(),
    NOW()
) ON CONFLICT (phone_number) DO NOTHING;
