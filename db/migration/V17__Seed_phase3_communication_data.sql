-- Agent Mitra - Migration V17: Seed Phase 3 - Communication and Chat Data
-- This migration adds seed data for communication tables: chatbot sessions, chat messages,
-- whatsapp messages, and notifications
-- Ensures all communication-related tables have at least 10 records each

DO $$
DECLARE
    current_count INTEGER;
    i INTEGER;
    j INTEGER;
    user_record RECORD;
    agent_record RECORD;
    customer_record RECORD;
    session_record RECORD;
    current_session_id UUID;
BEGIN
    RAISE NOTICE 'Starting V17 migration: Adding Phase 3 communication seed data...';

    -- =====================================================
    -- CHATBOT SESSIONS - Depend on users
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.chatbot_sessions;
    IF current_count < 10 THEN
        -- Create chatbot sessions for users
        FOR user_record IN SELECT user_id FROM lic_schema.users LIMIT 10 LOOP
            INSERT INTO lic_schema.chatbot_sessions (
                user_id, conversation_id, started_at, ended_at, duration_seconds,
                message_count, resolution_status, average_response_time, user_satisfaction_score,
                escalation_reason, device_info, ip_address, user_agent
            ) VALUES (
                user_record.user_id,
                'conv_' || user_record.user_id || '_' || EXTRACT(epoch FROM NOW()),
                NOW() - INTERVAL '2 hours',
                CASE WHEN RANDOM() < 0.7 THEN NOW() - INTERVAL '30 minutes' ELSE NULL END,
                CASE WHEN RANDOM() < 0.7 THEN (1800 + RANDOM() * 3600)::INT ELSE NULL END,  -- 30min-90min
                3 + (RANDOM() * 15)::INT,  -- 3-18 messages
                CASE (RANDOM() * 4)::INT
                    WHEN 0 THEN 'resolved'
                    WHEN 1 THEN 'escalated'
                    WHEN 2 THEN 'abandoned'
                    ELSE 'in_progress'
                END,
                (1 + RANDOM() * 5)::DECIMAL(6,2),  -- 1-6 seconds response time
                CASE WHEN RANDOM() < 0.8 THEN (3 + RANDOM() * 2)::INT ELSE NULL END,  -- 3-5 star rating
                CASE WHEN RANDOM() < 0.2 THEN 'Technical issue beyond chatbot capability' ELSE NULL END,
                '{"device_type": "mobile", "os": "android", "browser": "Chrome"}'::jsonb,
                ('192.168.1.' || (RANDOM() * 255)::INT)::INET,
                'AgentMitra-Chat/1.0.0'
            );
        END LOOP;
        RAISE NOTICE 'Added chatbot sessions data';
    END IF;

    -- =====================================================
    -- CHAT MESSAGES - Depend on chatbot_sessions and users
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.chat_messages;
    IF current_count < 10 THEN
        -- Create chat messages for each session
        FOR session_record IN SELECT session_id, user_id FROM lic_schema.chatbot_sessions LIMIT 10 LOOP
            -- Create conversation messages (back and forth)
            FOR j IN 1..(2 + (RANDOM() * 8)::INT) LOOP  -- 2-10 messages per session
                INSERT INTO lic_schema.chat_messages (
                    session_id, user_id, message_type, content, is_from_user,
                    intent_detected, confidence_score, entities_detected,
                    response_generated, response_time_ms, suggested_actions
                ) VALUES (
                    session_record.session_id,
                    session_record.user_id,
                    'text',
                    CASE
                        WHEN j % 2 = 1 THEN
                            CASE (RANDOM() * 5)::INT
                                WHEN 0 THEN 'What is the premium for term life insurance?'
                                WHEN 1 THEN 'How do I renew my policy?'
                                WHEN 2 THEN 'I need to update my contact details'
                                WHEN 3 THEN 'Can you help me with a claim?'
                                ELSE 'What documents do I need for policy purchase?'
                            END
                        ELSE
                            CASE (RANDOM() * 5)::INT
                                WHEN 0 THEN 'Term life insurance premiums vary based on age, coverage amount, and health. Would you like me to provide a quote?'
                                WHEN 1 THEN 'You can renew your policy online through our portal. I can guide you through the process.'
                                WHEN 2 THEN 'I can help you update your contact details. Please provide your policy number and the new information.'
                                WHEN 3 THEN 'For claims, please contact our claims department at 1800-XXX-XXXX or visit our claims portal.'
                                ELSE 'For policy purchase, you will need: ID proof, address proof, income proof, and medical reports.'
                            END
                    END,
                    j % 2 = 1,  -- Alternate between user and bot messages
                    CASE WHEN j % 2 = 1 THEN
                        CASE (RANDOM() * 4)::INT
                            WHEN 0 THEN 'premium_inquiry'
                            WHEN 1 THEN 'policy_renewal'
                            WHEN 2 THEN 'contact_update'
                            ELSE 'general_inquiry'
                        END
                    ELSE NULL END,
                    CASE WHEN j % 2 = 1 THEN (0.7 + RANDOM() * 0.3)::DECIMAL(3,2) ELSE NULL END,  -- 70-100% confidence
                    CASE WHEN j % 2 = 1 THEN
                        jsonb_build_object('policy_type', 'term_life', 'amount', '500000')
                    ELSE NULL END,
                    CASE WHEN j % 2 = 0 THEN
                        CASE (RANDOM() * 3)::INT
                            WHEN 0 THEN 'Please provide more details about your requirements.'
                            WHEN 1 THEN 'Would you like me to connect you with an agent?'
                            ELSE 'I can help you with the next steps.'
                        END
                    ELSE NULL END,
                    CASE WHEN j % 2 = 0 THEN (500 + RANDOM() * 2000)::INT ELSE NULL END,  -- 500-2500ms response time
                    CASE WHEN j % 2 = 0 THEN
                        jsonb_build_array(
                            jsonb_build_object('action', 'get_quote', 'label', 'Get Quote'),
                            jsonb_build_object('action', 'contact_agent', 'label', 'Contact Agent')
                        )
                    ELSE NULL END
                );
            END LOOP;
        END LOOP;
        RAISE NOTICE 'Added chat messages data';
    END IF;

    -- =====================================================
    -- WHATSAPP MESSAGES - Depend on users and agents
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.whatsapp_messages;
    IF current_count < 10 THEN
        -- Create whatsapp messages between agents and customers
        FOR i IN 1..10 LOOP
            -- Get random agent and user
            SELECT a.agent_id, a.user_id INTO agent_record FROM lic_schema.agents a ORDER BY RANDOM() LIMIT 1;
            SELECT user_id INTO user_record FROM lic_schema.users WHERE role = 'policyholder' ORDER BY RANDOM() LIMIT 1;

            INSERT INTO lic_schema.whatsapp_messages (
                whatsapp_message_id, sender_id, recipient_id, agent_id,
                message_type, content, media_url, whatsapp_template_id,
                whatsapp_template_name, whatsapp_status, conversation_id,
                message_sequence, is_from_customer, sent_at, delivered_at, read_at
            ) VALUES (
                'wa_' || EXTRACT(epoch FROM NOW()) || '_' || i,
                CASE WHEN RANDOM() < 0.5 THEN user_record.user_id ELSE agent_record.user_id END,
                CASE WHEN RANDOM() < 0.5 THEN agent_record.user_id ELSE user_record.user_id END,
                agent_record.agent_id,
                CASE (RANDOM() * 3)::INT
                    WHEN 0 THEN 'text'
                    WHEN 1 THEN 'image'
                    ELSE 'document'
                END,
                CASE (RANDOM() * 5)::INT
                    WHEN 0 THEN 'Hi, I need help with my policy renewal.'
                    WHEN 1 THEN 'Please send me the premium payment link.'
                    WHEN 2 THEN 'Can you explain the coverage details?'
                    WHEN 3 THEN 'I have a query about my claim status.'
                    ELSE 'Thank you for your assistance.'
                END,
                CASE WHEN RANDOM() < 0.3 THEN 'https://example.com/media/file_' || i || '.jpg' ELSE NULL END,
                CASE WHEN RANDOM() < 0.4 THEN 'template_' || (RANDOM() * 6 + 1)::INT ELSE NULL END,
                CASE WHEN RANDOM() < 0.4 THEN 'payment_reminder' ELSE NULL END,
                CASE (RANDOM() * 3)::INT
                    WHEN 0 THEN 'sent'
                    WHEN 1 THEN 'delivered'
                    ELSE 'read'
                END,
                gen_random_uuid(),
                i,
                RANDOM() < 0.6,  -- 60% from customer
                NOW() - INTERVAL '1 hour' * (RANDOM() * 24)::INT,
                CASE WHEN RANDOM() < 0.8 THEN NOW() - INTERVAL '30 minutes' * (RANDOM() * 24)::INT ELSE NULL END,
                CASE WHEN RANDOM() < 0.6 THEN NOW() - INTERVAL '15 minutes' * (RANDOM() * 24)::INT ELSE NULL END
            );
        END LOOP;
        RAISE NOTICE 'Added whatsapp messages data';
    END IF;

    -- =====================================================
    -- NOTIFICATIONS - Depend on users
    -- =====================================================

    SELECT COUNT(*) INTO current_count FROM lic_schema.notifications;
    IF current_count < 10 THEN
        -- Create notifications for users
        FOR user_record IN SELECT user_id FROM lic_schema.users LIMIT 10 LOOP
            FOR j IN 1..3 LOOP  -- 3 notifications per user
                INSERT INTO lic_schema.notifications (
                    user_id, title, body, type, priority, is_read, read_at,
                    action_url, action_route, action_text, data, created_at
                ) VALUES (
                    user_record.user_id,
                    CASE j
                        WHEN 1 THEN 'Policy Renewal Reminder'
                        WHEN 2 THEN 'Premium Payment Due'
                        ELSE 'New Feature Available'
                    END,
                    CASE j
                        WHEN 1 THEN 'Your LIC policy #12345 is due for renewal in 15 days. Renew now to avoid lapse.'
                        WHEN 2 THEN 'Premium payment of ₹2,500 is due tomorrow. Pay now to maintain coverage.'
                        ELSE 'Check out our new digital claim submission feature for faster processing.'
                    END,
                    CASE j
                        WHEN 1 THEN 'renewal'
                        WHEN 2 THEN 'payment'
                        ELSE 'feature'
                    END,
                    CASE j
                        WHEN 2 THEN 'high'
                        ELSE 'medium'
                    END,
                    CASE WHEN RANDOM() < 0.7 THEN true ELSE false END,
                    CASE WHEN RANDOM() < 0.7 THEN NOW() - INTERVAL '2 hours' ELSE NULL END,
                    CASE j
                        WHEN 1 THEN '/policies/12345/renew'
                        WHEN 2 THEN '/payments/pay?policy=12345'
                        ELSE '/features/claims'
                    END,
                    CASE j
                        WHEN 1 THEN '/policies'
                        WHEN 2 THEN '/payments'
                        ELSE '/features'
                    END,
                    CASE j
                        WHEN 1 THEN 'Renew Now'
                        WHEN 2 THEN 'Pay Premium'
                        ELSE 'Learn More'
                    END,
                    jsonb_build_object(
                        'policy_id', '12345',
                        'amount', 2500,
                        'due_date', CURRENT_DATE + INTERVAL '1 day'
                    ),
                    NOW() - INTERVAL '1 day' * j
                );
            END LOOP;
        END LOOP;
        RAISE NOTICE 'Added notifications data';
    END IF;

    RAISE NOTICE 'V17 migration completed successfully! All Phase 3 communication tables now have minimum seed data.';
END $$;
