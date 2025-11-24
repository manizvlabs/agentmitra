-- Agent Mitra - Migration V14: Fix Schema Foreign Key Constraints
-- This migration fixes the foreign key constraint issues that were preventing
-- proper seeding of data. The agents table was referencing shared.insurance_providers
-- instead of lic_schema.insurance_providers

DO $$
DECLARE
    current_count INTEGER;
    lic_provider_id UUID;
    shared_provider_id UUID;
BEGIN
    RAISE NOTICE 'Starting V16 migration: Fixing foreign key constraint issues...';

    -- =====================================================
    -- FIX FOREIGN KEY CONSTRAINT ISSUES
    -- =====================================================

    -- 1. Drop the incorrect foreign key constraint that references shared.insurance_providers
    ALTER TABLE lic_schema.agents DROP CONSTRAINT IF EXISTS agents_provider_id_fkey;

    -- 2. Add the correct foreign key constraint to lic_schema.insurance_providers
    ALTER TABLE lic_schema.agents ADD CONSTRAINT agents_provider_id_fkey
        FOREIGN KEY (provider_id) REFERENCES lic_schema.insurance_providers(provider_id);

    -- 3. Update existing agent records to reference providers in lic_schema instead of shared
    -- Get the mapping between shared and lic_schema provider IDs
    FOR shared_provider_id IN SELECT provider_id FROM shared.insurance_providers LOOP
        SELECT provider_id INTO lic_provider_id
        FROM lic_schema.insurance_providers
        WHERE provider_code = (SELECT provider_code FROM shared.insurance_providers WHERE provider_id = shared_provider_id);

        IF lic_provider_id IS NOT NULL THEN
            UPDATE lic_schema.agents
            SET provider_id = lic_provider_id
            WHERE provider_id = shared_provider_id;
        END IF;
    END LOOP;

    RAISE NOTICE 'Fixed foreign key constraints and updated agent provider references';

-- =====================================================
    -- ENSURE MINIMUM SEED DATA FOR CRITICAL TABLES
-- =====================================================

    -- Ensure we have enough countries (reference data)
    SELECT COUNT(*) INTO current_count FROM lic_schema.countries;
    IF current_count < 10 THEN
        INSERT INTO lic_schema.countries (country_name, country_code, currency_code, phone_code, status) VALUES
        ('India', 'IN', 'INR', '+91', 'active'),
        ('United States', 'US', 'USD', '+1', 'active'),
        ('United Kingdom', 'GB', 'GBP', '+44', 'active'),
        ('Canada', 'CA', 'CAD', '+1', 'active'),
        ('Australia', 'AU', 'AUD', '+61', 'active'),
        ('Germany', 'DE', 'EUR', '+49', 'active'),
        ('France', 'FR', 'EUR', '+33', 'active'),
        ('Japan', 'JP', 'JPY', '+81', 'active'),
        ('China', 'CN', 'CNY', '+86', 'active'),
        ('Brazil', 'BR', 'BRL', '+55', 'active')
        ON CONFLICT (country_code) DO NOTHING;
        RAISE NOTICE 'Added countries data';
    END IF;

    -- Ensure we have enough insurance providers (critical for agents)
    SELECT COUNT(*) INTO current_count FROM lic_schema.insurance_providers;
    IF current_count < 10 THEN
        INSERT INTO lic_schema.insurance_providers (
            provider_code, provider_name, provider_type, description, status, created_at, updated_at
        ) VALUES
        ('SEED_LIC', 'Seed LIC Provider', 'life_insurance', 'Seed insurance provider for testing', 'active', NOW(), NOW()),
        ('SEED_HDFC', 'Seed HDFC Provider', 'life_insurance', 'Seed insurance provider for testing', 'active', NOW(), NOW()),
        ('SEED_ICICI', 'Seed ICICI Provider', 'life_insurance', 'Seed insurance provider for testing', 'active', NOW(), NOW()),
        ('SEED_BAJAJ', 'Seed Bajaj Provider', 'life_insurance', 'Seed insurance provider for testing', 'active', NOW(), NOW()),
        ('SEED_SBI', 'Seed SBI Provider', 'life_insurance', 'Seed insurance provider for testing', 'active', NOW(), NOW()),
        ('SEED_TATA', 'Seed Tata Provider', 'life_insurance', 'Seed insurance provider for testing', 'active', NOW(), NOW()),
        ('SEED_MAX', 'Seed Max Provider', 'life_insurance', 'Seed insurance provider for testing', 'active', NOW(), NOW()),
        ('SEED_PNB', 'Seed PNB Provider', 'life_insurance', 'Seed insurance provider for testing', 'active', NOW(), NOW()),
        ('SEED_ADITYA', 'Seed Aditya Provider', 'life_insurance', 'Seed insurance provider for testing', 'active', NOW(), NOW()),
        ('SEED_KOTAK', 'Seed Kotak Provider', 'life_insurance', 'Seed insurance provider for testing', 'active', NOW(), NOW())
        ON CONFLICT (provider_code) DO NOTHING;
        RAISE NOTICE 'Added insurance providers data';
    END IF;

    -- Ensure we have enough users (required for agents and policyholders)
    SELECT COUNT(*) INTO current_count FROM lic_schema.users;
    IF current_count < 10 THEN
        INSERT INTO lic_schema.users (
            email, phone_number, username, password_hash, first_name, last_name,
            display_name, language_preference, timezone, theme_preference,
            email_verified, phone_verified, status, role, created_at, updated_at
        ) VALUES
        ('seed_user_1@agentmitra.com', '+919876543230', 'seed_user_1', '$2b$10$example.hash', 'Seed', 'User1', 'Seed User 1', 'en', 'Asia/Kolkata', 'light', true, true, 'active', 'policyholder', NOW() - INTERVAL '30 days', NOW()),
        ('seed_user_2@agentmitra.com', '+919876543231', 'seed_user_2', '$2b$10$example.hash', 'Seed', 'User2', 'Seed User 2', 'en', 'Asia/Kolkata', 'light', true, true, 'active', 'policyholder', NOW() - INTERVAL '29 days', NOW()),
        ('seed_user_3@agentmitra.com', '+919876543232', 'seed_user_3', '$2b$10$example.hash', 'Seed', 'User3', 'Seed User 3', 'en', 'Asia/Kolkata', 'light', true, true, 'active', 'junior_agent', NOW() - INTERVAL '28 days', NOW()),
        ('seed_user_4@agentmitra.com', '+919876543233', 'seed_user_4', '$2b$10$example.hash', 'Seed', 'User4', 'Seed User 4', 'en', 'Asia/Kolkata', 'light', true, true, 'active', 'senior_agent', NOW() - INTERVAL '27 days', NOW()),
        ('seed_user_5@agentmitra.com', '+919876543234', 'seed_user_5', '$2b$10$example.hash', 'Seed', 'User5', 'Seed User 5', 'en', 'Asia/Kolkata', 'light', true, true, 'active', 'policyholder', NOW() - INTERVAL '26 days', NOW()),
        ('seed_user_6@agentmitra.com', '+919876543235', 'seed_user_6', '$2b$10$example.hash', 'Seed', 'User6', 'Seed User 6', 'en', 'Asia/Kolkata', 'light', true, true, 'active', 'policyholder', NOW() - INTERVAL '25 days', NOW()),
        ('seed_user_7@agentmitra.com', '+919876543236', 'seed_user_7', '$2b$10$example.hash', 'Seed', 'User7', 'Seed User 7', 'en', 'Asia/Kolkata', 'light', true, true, 'active', 'regional_manager', NOW() - INTERVAL '24 days', NOW()),
        ('seed_user_8@agentmitra.com', '+919876543237', 'seed_user_8', '$2b$10$example.hash', 'Seed', 'User8', 'Seed User 8', 'en', 'Asia/Kolkata', 'light', true, true, 'active', 'junior_agent', NOW() - INTERVAL '23 days', NOW()),
        ('seed_user_9@agentmitra.com', '+919876543238', 'seed_user_9', '$2b$10$example.hash', 'Seed', 'User9', 'Seed User 9', 'en', 'Asia/Kolkata', 'light', true, true, 'active', 'policyholder', NOW() - INTERVAL '22 days', NOW()),
        ('seed_user_10@agentmitra.com', '+919876543239', 'seed_user_10', '$2b$10$example.hash', 'Seed', 'User10', 'Seed User 10', 'en', 'Asia/Kolkata', 'light', true, true, 'active', 'policyholder', NOW() - INTERVAL '21 days', NOW())
        ON CONFLICT (email) DO NOTHING;
        RAISE NOTICE 'Added users data';
    END IF;

    RAISE NOTICE 'V14 migration completed successfully!';
END $$;
