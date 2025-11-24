-- Agent Mitra - Migration V15: Seed Phase 1 - Core Authentication and User Management Data
-- This migration adds seed data for user sessions, roles, permissions, notifications, and device tokens
-- Ensures all core authentication-related tables have at least 10 records each

DO $$
DECLARE
    current_count INTEGER;
    i INTEGER;
    user_record RECORD;
    role_record RECORD;
BEGIN
    RAISE NOTICE 'Starting V15 migration: Adding Phase 1 core authentication seed data...';

    -- =====================================================
    -- USER SESSIONS - Depend on users
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.user_sessions;
    IF current_count < 10 THEN
        -- Create sessions for existing users
        FOR user_record IN SELECT user_id FROM lic_schema.users LIMIT 10 LOOP
            INSERT INTO lic_schema.user_sessions (
                user_id, session_token, refresh_token, device_info, ip_address,
                user_agent, expires_at, last_activity_at, created_at
            ) VALUES
            (
                user_record.user_id,
                'session_token_' || user_record.user_id || '_' || EXTRACT(epoch FROM NOW()),
                'refresh_token_' || user_record.user_id || '_' || EXTRACT(epoch FROM NOW()),
                '{"device_type": "mobile", "os": "android", "app_version": "1.0.0"}'::jsonb,
                ('192.168.1.' || (RANDOM() * 255)::INT)::INET,
                'AgentMitra/1.0.0 (Android 12; SM-G998B)',
                NOW() + INTERVAL '24 hours',
                NOW() - INTERVAL '2 hours',
                NOW() - INTERVAL '8 hours'
            );
        END LOOP;
        RAISE NOTICE 'Added user sessions data';
    END IF;

    -- =====================================================
    -- USER ROLES - Depend on users and roles
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.user_roles;
    IF current_count < 10 THEN
        -- Assign roles to users based on their existing role in users table
        FOR user_record IN SELECT user_id, role FROM lic_schema.users WHERE role IS NOT NULL LIMIT 10 LOOP
            -- Find the corresponding role in roles table
            SELECT role_id INTO role_record FROM lic_schema.roles WHERE role_name = user_record.role::TEXT LIMIT 1;

            IF role_record.role_id IS NOT NULL THEN
                INSERT INTO lic_schema.user_roles (
                    user_id, role_id, assigned_by, assigned_at
                ) VALUES (
                    user_record.user_id,
                    role_record.role_id,
                    user_record.user_id, -- Self-assigned for seed data
                    NOW() - INTERVAL '30 days'
                ) ON CONFLICT (user_id, role_id) DO NOTHING;
            END IF;
        END LOOP;
        RAISE NOTICE 'Added user roles data';
    END IF;

    -- =====================================================
    -- ROLE PERMISSIONS - Depend on roles and permissions
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.role_permissions;
    IF current_count < 10 THEN
        -- Assign permissions to roles
        FOR role_record IN SELECT role_id, role_name FROM lic_schema.roles LIMIT 8 LOOP
            -- Assign multiple permissions to each role
            FOR i IN 1..5 LOOP
                INSERT INTO lic_schema.role_permissions (
                    role_id, permission_id, granted_at
                )
                SELECT
                    role_record.role_id,
                    p.permission_id,
                    NOW() - INTERVAL '30 days'
                FROM lic_schema.permissions p
                WHERE p.permission_name LIKE
                    CASE
                        WHEN role_record.role_name = 'super_admin' THEN '%'
                        WHEN role_record.role_name = 'insurance_provider_admin' THEN '%.%'
                        WHEN role_record.role_name = 'regional_manager' THEN '%read'
                        WHEN role_record.role_name = 'senior_agent' THEN '%create'
                        WHEN role_record.role_name = 'junior_agent' THEN '%read'
                        WHEN role_record.role_name = 'policyholder' THEN '%read'
                        ELSE '%read'
                    END
                ORDER BY RANDOM()
                LIMIT 1
                ON CONFLICT (role_id, permission_id) DO NOTHING;
            END LOOP;
        END LOOP;
        RAISE NOTICE 'Added role permissions data';
    END IF;

    -- =====================================================
    -- NOTIFICATION SETTINGS - Depend on users
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.notification_settings;
    IF current_count < 10 THEN
        -- Create notification settings for users
        FOR user_record IN SELECT user_id FROM lic_schema.users LIMIT 10 LOOP
            INSERT INTO lic_schema.notification_settings (
                user_id, enable_push_notifications, enable_policy_notifications,
                enable_payment_reminders, enable_claim_updates, enable_renewal_notices,
                enable_marketing_notifications, enable_sound, enable_vibration,
                show_badge, quiet_hours_enabled, enabled_topics
            ) VALUES (
                user_record.user_id,
                true, true, true, true, true, false, true, true, true, false,
                '["general", "policies", "payments", "claims", "renewals"]'::jsonb
            ) ON CONFLICT (user_id) DO NOTHING;
        END LOOP;
        RAISE NOTICE 'Added notification settings data';
    END IF;

    -- =====================================================
    -- DEVICE TOKENS - Depend on users
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.device_tokens;
    IF current_count < 10 THEN
        -- Create device tokens for users
        FOR user_record IN SELECT user_id FROM lic_schema.users LIMIT 10 LOOP
            INSERT INTO lic_schema.device_tokens (
                user_id, token, device_type, created_at, last_used_at
            ) VALUES
            (
                user_record.user_id,
                'device_token_' || user_record.user_id || '_android_' || EXTRACT(epoch FROM NOW()),
                'android',
                NOW() - INTERVAL '7 days',
                NOW() - INTERVAL '2 hours'
            ),
            (
                user_record.user_id,
                'device_token_' || user_record.user_id || '_ios_' || EXTRACT(epoch FROM NOW()),
                'ios',
                NOW() - INTERVAL '5 days',
                NOW() - INTERVAL '1 day'
            )
            ON CONFLICT (token) DO NOTHING;
        END LOOP;
        RAISE NOTICE 'Added device tokens data';
    END IF;

    RAISE NOTICE 'V15 migration completed successfully! All Phase 1 core authentication tables now have minimum seed data.';
END $$;
