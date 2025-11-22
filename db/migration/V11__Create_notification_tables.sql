-- Create notification tables for push notifications and in-app notifications
-- Migration: V11__Create_notification_tables.sql

-- Create notifications table
CREATE TABLE IF NOT EXISTS lic_schema.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    priority VARCHAR(20) NOT NULL DEFAULT 'medium',
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,

    -- Action fields for interactive notifications
    action_url VARCHAR(500),
    action_route VARCHAR(200),
    action_text VARCHAR(100),
    image_url VARCHAR(500),

    -- Additional data (JSON)
    data JSONB DEFAULT '{}'::jsonb,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    scheduled_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes for notifications table
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON lic_schema.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON lic_schema.notifications(type);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON lic_schema.notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON lic_schema.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON lic_schema.notifications(user_id, is_read);

-- Create lic_schema.notification_settings table
CREATE TABLE IF NOT EXISTS lic_schema.lic_schema.notification_settings (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE,

    -- Push notification settings
    enable_push_notifications BOOLEAN NOT NULL DEFAULT TRUE,

    -- Notification type preferences
    enable_policy_notifications BOOLEAN NOT NULL DEFAULT TRUE,
    enable_payment_reminders BOOLEAN NOT NULL DEFAULT TRUE,
    enable_claim_updates BOOLEAN NOT NULL DEFAULT TRUE,
    enable_renewal_notices BOOLEAN NOT NULL DEFAULT TRUE,
    enable_marketing_notifications BOOLEAN NOT NULL DEFAULT FALSE,

    -- Device settings
    enable_sound BOOLEAN NOT NULL DEFAULT TRUE,
    enable_vibration BOOLEAN NOT NULL DEFAULT TRUE,
    show_badge BOOLEAN NOT NULL DEFAULT TRUE,

    -- Quiet hours
    quiet_hours_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    quiet_hours_start VARCHAR(5), -- HH:MM format
    quiet_hours_end VARCHAR(5),   -- HH:MM format

    -- Topics/Channels
    enabled_topics JSONB DEFAULT '["general", "policies", "payments"]'::jsonb,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create index for lic_schema.notification_settings table
CREATE INDEX IF NOT EXISTS idx_lic_schema.notification_settings_user_id ON lic_schema.lic_schema.notification_settings(user_id);

-- Create lic_schema.device_tokens table for push notifications
CREATE TABLE IF NOT EXISTS lic_schema.lic_schema.device_tokens (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    device_type VARCHAR(20) NOT NULL, -- ios, android

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for lic_schema.device_tokens table
CREATE INDEX IF NOT EXISTS idx_lic_schema.device_tokens_user_id ON lic_schema.lic_schema.device_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_lic_schema.device_tokens_token ON lic_schema.lic_schema.device_tokens(token);

-- Create trigger to update updated_at timestamp for lic_schema.notification_settings
CREATE OR REPLACE FUNCTION update_lic_schema.notification_settings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_update_lic_schema.notification_settings_updated_at
    BEFORE UPDATE ON lic_schema.notification_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_lic_schema.notification_settings_updated_at();

-- Create trigger to update last_used_at for lic_schema.device_tokens
CREATE OR REPLACE FUNCTION update_lic_schema.device_tokens_last_used_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_used_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_update_lic_schema.device_tokens_last_used_at
    BEFORE UPDATE ON lic_schema.device_tokens
    FOR EACH ROW
    EXECUTE FUNCTION update_lic_schema.device_tokens_last_used_at();

-- Insert default notification settings for existing users (DISABLED)
-- -- INSERT INTO lic_schema.notification_settings (
--     user_id,
--     enable_push_notifications,
--     enable_policy_notifications,
--     enable_payment_reminders,
--     enable_claim_updates,
--     enable_renewal_notices,
--     enable_marketing_notifications,
--     enable_sound,
--     enable_vibration,
--     show_badge,
--     quiet_hours_enabled,
--     enabled_topics
-- )
-- SELECT
--     u.user_id,
--     TRUE as enable_push_notifications,
--     TRUE as enable_policy_notifications,
--     TRUE as enable_payment_reminders,
--     TRUE as enable_claim_updates,
--     TRUE as enable_renewal_notices,
--     FALSE as enable_marketing_notifications,
--     TRUE as enable_sound,
--     TRUE as enable_vibration,
--     TRUE as show_badge,
--     FALSE as quiet_hours_enabled,
--     '["general", "policies", "payments"]'::jsonb as enabled_topics
-- FROM lic_schema.users u
-- WHERE NOT EXISTS (
--     SELECT 1 FROM lic_schema.notification_settings ns WHERE ns.user_id = u.user_id
-- );
-- 
-- -- Insert some sample notifications for testing
-- -- -- INSERT INTO notifications (
-- --     id,
-- --     user_id,
-- --     title,
-- --     body,
-- --     type,
-- --     priority,
-- --     is_read,
-- --     created_at
-- -- ) VALUES
-- -- ('550e8400-e29b-41d4-a716-446655440001', (SELECT user_id::uuid FROM users LIMIT 1), 'Welcome to Agent Mitra!', 'Thank you for joining Agent Mitra. Your account is now active.', 'system', 'low', false, CURRENT_TIMESTAMP),
-- -- ('550e8400-e29b-41d4-a716-446655440002', (SELECT user_id::uuid FROM users LIMIT 1), 'Policy Update Available', 'New policy templates have been added to your dashboard.', 'policy', 'medium', false, CURRENT_TIMESTAMP - INTERVAL '2 hours'),
-- -- ('550e8400-e29b-41d4-a716-446655440003', (SELECT user_id::uuid FROM users LIMIT 1), 'Payment Reminder', 'Your premium payment of ₹2,500 is due in 3 days.', 'payment', 'high', false, CURRENT_TIMESTAMP - INTERVAL '1 day'),
-- -- ('550e8400-e29b-41d4-a716-446655440004', (SELECT user_id::uuid FROM users LIMIT 1), 'Claim Processed', 'Your claim #CLM-2024-001 has been approved for ₹15,000.', 'claim', 'high', true, CURRENT_TIMESTAMP - INTERVAL '3 days'),
-- -- ('550e8400-e29b-41d4-a716-446655440005', (SELECT user_id::uuid FROM users LIMIT 1), 'Renewal Due Soon', 'Policy LIC-12345 renewal is due in 15 days.', 'renewal', 'medium', false, CURRENT_TIMESTAMP - INTERVAL '6 hours');
-- -- 
-- -- -- Add comments for documentation
-- -- COMMENT ON TABLE notifications IS 'User notifications including push notifications and in-app messages';
-- -- COMMENT ON TABLE lic_schema.notification_settings IS 'User preferences for notification delivery and types';
-- -- COMMENT ON TABLE lic_schema.device_tokens IS 'FCM device tokens for push notification delivery';
-- -- 
-- -- COMMENT ON COLUMN notifications.type IS 'Type of notification: policy, payment, claim, renewal, general, marketing, system';
-- -- COMMENT ON COLUMN notifications.priority IS 'Priority level: low, medium, high, critical';
-- -- COMMENT ON COLUMN lic_schema.device_tokens.device_type IS 'Device platform: ios, android';
