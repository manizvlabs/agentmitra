-- Agent Mitra - Migration V24: Seed Marketing Campaigns and Callback Requests Data
-- This migration seeds initial data for campaigns, templates, and callback requests

-- =====================================================
-- SEED CAMPAIGN TEMPLATES
-- =====================================================

-- Get a system user ID (assuming admin user exists)
DO $$
DECLARE
    system_user_id UUID;
    agent_id_val UUID;
BEGIN
    -- Get first user as system user
    SELECT user_id INTO system_user_id FROM lic_schema.users LIMIT 1;
    
    -- Get first agent as default agent
    SELECT agent_id INTO agent_id_val FROM lic_schema.agents LIMIT 1;
    
    -- Only proceed if we have a user
    IF system_user_id IS NOT NULL THEN
        
        -- Acquisition Campaign Templates
        INSERT INTO lic_schema.campaign_templates (
            template_id, template_name, description, category, 
            subject_template, message_template, personalization_tags, 
            suggested_channels, is_public, is_system_template, 
            usage_count, average_roi, created_by
        ) VALUES
        (
            gen_random_uuid(),
            'Welcome New Customer',
            'Template for welcoming new customers and introducing services',
            'acquisition',
            'Welcome to {{company_name}}!',
            'Dear {{customer_name}},\n\nWelcome to {{company_name}}! We''re thrilled to have you as part of our family.\n\nYour policy number {{policy_number}} is now active. Our team is here to support you every step of the way.\n\nBest regards,\n{{agent_name}}',
            ARRAY['{{customer_name}}', '{{company_name}}', '{{policy_number}}', '{{agent_name}}'],
            ARRAY['whatsapp', 'email'],
            true,
            true,
            0,
            0.0,
            system_user_id
        ),
        (
            gen_random_uuid(),
            'Policy Renewal Reminder',
            'Template for reminding customers about upcoming policy renewals',
            'retention',
            'Your Policy Renewal is Due Soon',
            'Dear {{customer_name}},\n\nThis is a friendly reminder that your policy {{policy_number}} is due for renewal on {{due_date}}.\n\nPremium Amount: ₹{{premium_amount}}\n\nRenew now to ensure continuous coverage. Click here to renew: {{renewal_link}}\n\nBest regards,\n{{agent_name}}',
            ARRAY['{{customer_name}}', '{{policy_number}}', '{{due_date}}', '{{premium_amount}}', '{{renewal_link}}', '{{agent_name}}'],
            ARRAY['whatsapp', 'sms'],
            true,
            true,
            0,
            0.0,
            system_user_id
        ),
        (
            gen_random_uuid(),
            'Upsell Premium Plan',
            'Template for upselling premium insurance plans',
            'upselling',
            'Upgrade to Premium Coverage',
            'Dear {{customer_name}},\n\nBased on your current coverage, we recommend upgrading to our Premium Plan for enhanced protection.\n\nBenefits:\n- Higher coverage amount\n- Additional benefits\n- Priority support\n\nCurrent Premium: ₹{{current_premium}}\nPremium Plan: ₹{{premium_amount}}\n\nInterested? Reply YES to learn more.\n\n{{agent_name}}',
            ARRAY['{{customer_name}}', '{{current_premium}}', '{{premium_amount}}', '{{agent_name}}'],
            ARRAY['whatsapp', 'email'],
            true,
            true,
            0,
            0.0,
            system_user_id
        ),
        (
            gen_random_uuid(),
            'Payment Reminder',
            'Template for payment due reminders',
            'behavioral',
            'Payment Reminder: {{policy_number}}',
            'Dear {{customer_name}},\n\nYour premium payment of ₹{{premium_amount}} for policy {{policy_number}} is due on {{due_date}}.\n\nPlease make the payment to avoid any service interruption.\n\nPayment Link: {{payment_link}}\n\nThank you,\n{{agent_name}}',
            ARRAY['{{customer_name}}', '{{policy_number}}', '{{premium_amount}}', '{{due_date}}', '{{payment_link}}', '{{agent_name}}'],
            ARRAY['whatsapp', 'sms'],
            true,
            true,
            0,
            0.0,
            system_user_id
        ),
        (
            gen_random_uuid(),
            'Claim Status Update',
            'Template for updating customers about claim status',
            'behavioral',
            'Update on Your Claim',
            'Dear {{customer_name}},\n\nWe have an update on your claim {{claim_number}}.\n\nStatus: {{claim_status}}\nAmount: ₹{{claim_amount}}\n\n{{additional_info}}\n\nIf you have any questions, please contact us.\n\n{{agent_name}}',
            ARRAY['{{customer_name}}', '{{claim_number}}', '{{claim_status}}', '{{claim_amount}}', '{{additional_info}}', '{{agent_name}}'],
            ARRAY['whatsapp', 'email'],
            true,
            true,
            0,
            0.0,
            system_user_id
        );

        -- Create sample campaigns if agent exists
        IF agent_id_val IS NOT NULL THEN
            
            -- Sample Active Campaign
            INSERT INTO lic_schema.campaigns (
                campaign_id, agent_id, campaign_name, campaign_type, campaign_goal,
                description, subject, message, primary_channel, channels,
                target_audience, estimated_reach, schedule_type, status,
                budget, estimated_cost, total_sent, total_delivered, total_opened,
                total_clicked, total_converted, total_revenue, roi_percentage,
                launched_at, created_by
            ) VALUES
            (
                gen_random_uuid(),
                agent_id_val,
                'Q1 2024 Renewal Drive',
                'retention',
                'renewal_rate',
                'Campaign to encourage policy renewals for Q1 2024',
                'Your Policy Renewal is Due',
                'Dear {{customer_name}}, Your policy {{policy_number}} is due for renewal. Renew now to ensure continuous coverage.',
                'whatsapp',
                ARRAY['whatsapp', 'sms'],
                'all',
                500,
                'immediate',
                'active',
                10000.00,
                8500.00,
                485,
                462,
                342,
                98,
                23,
                45000.00,
                350.00,
                NOW() - INTERVAL '15 days',
                system_user_id
            ),
            (
                gen_random_uuid(),
                agent_id_val,
                'New Customer Onboarding',
                'acquisition',
                'lead_generation',
                'Welcome campaign for new customers',
                'Welcome to Our Insurance Family',
                'Dear {{customer_name}}, Welcome! Your policy {{policy_number}} is now active. We''re here to help.',
                'whatsapp',
                ARRAY['whatsapp', 'email'],
                'all',
                200,
                'immediate',
                'draft',
                5000.00,
                4000.00,
                0,
                0,
                0,
                0,
                0,
                0.00,
                0.00,
                NULL,
                system_user_id
            );

        END IF;
        
    END IF;
END $$;

-- =====================================================
-- SEED CALLBACK REQUESTS
-- =====================================================

DO $$
DECLARE
    system_user_id UUID;
    agent_id_val UUID;
    policyholder_id_val UUID;
    callback_id UUID;
    age_hours INTEGER;
    priority_score DECIMAL(5,2);
    priority_category VARCHAR(10);
    due_at_val TIMESTAMP;
BEGIN
    -- Get IDs
    SELECT user_id INTO system_user_id FROM lic_schema.users LIMIT 1;
    SELECT agent_id INTO agent_id_val FROM lic_schema.agents LIMIT 1;
    SELECT policyholder_id INTO policyholder_id_val FROM lic_schema.policyholders LIMIT 1;
    
    IF system_user_id IS NOT NULL AND policyholder_id_val IS NOT NULL THEN
        
        -- High Priority Callback - Policy Issue
        age_hours := 2;
        priority_score := 90.0 + (age_hours::DECIMAL / 4);
        priority_category := 'high';
        due_at_val := NOW() + INTERVAL '2 hours';
        
        callback_id := gen_random_uuid();
        INSERT INTO lic_schema.callback_requests (
            callback_request_id, policyholder_id, agent_id,
            request_type, description, priority, priority_score, status,
            customer_name, customer_phone, customer_email,
            sla_hours, due_at, source, urgency_level, customer_value,
            created_by
        ) VALUES (
            callback_id,
            policyholder_id_val,
            agent_id_val,
            'policy_issue',
            'Customer needs assistance with policy document discrepancies',
            priority_category,
            priority_score,
            'pending',
            'Rajesh Kumar',
            '+91-9876543210',
            'rajesh.kumar@example.com',
            2,
            due_at_val,
            'mobile',
            'high',
            'gold',
            system_user_id
        );
        
        -- Add activity
        INSERT INTO lic_schema.callback_activities (
            callback_request_id, activity_type, description, created_at
        ) VALUES (
            callback_id,
            'created',
            'Callback request created via mobile app',
            NOW() - INTERVAL '2 hours'
        );
        
        -- Medium Priority Callback - Payment Problem
        age_hours := 8;
        priority_score := 85.0 + (age_hours::DECIMAL / 4);
        priority_score := LEAST(100.0, priority_score);
        priority_category := 'medium';
        due_at_val := NOW() + INTERVAL '8 hours';
        
        callback_id := gen_random_uuid();
        INSERT INTO lic_schema.callback_requests (
            callback_request_id, policyholder_id, agent_id,
            request_type, description, priority, priority_score, status,
            customer_name, customer_phone, customer_email,
            sla_hours, due_at, source, urgency_level, customer_value,
            created_by
        ) VALUES (
            callback_id,
            policyholder_id_val,
            NULL,
            'payment_problem',
            'Customer unable to process premium payment online',
            priority_category,
            priority_score,
            'pending',
            'Priya Sharma',
            '+91-9876543211',
            'priya.sharma@example.com',
            8,
            due_at_val,
            'portal',
            'medium',
            'silver',
            system_user_id
        );
        
        -- Add activity
        INSERT INTO lic_schema.callback_activities (
            callback_request_id, activity_type, description, created_at
        ) VALUES (
            callback_id,
            'created',
            'Callback request created via portal',
            NOW() - INTERVAL '8 hours'
        );
        
        -- Low Priority Callback - General Inquiry
        age_hours := 24;
        priority_score := 60.0 + (age_hours::DECIMAL / 4);
        priority_score := LEAST(100.0, priority_score);
        priority_category := 'low';
        due_at_val := NOW() + INTERVAL '24 hours';
        
        callback_id := gen_random_uuid();
        INSERT INTO lic_schema.callback_requests (
            callback_request_id, policyholder_id, agent_id,
            request_type, description, priority, priority_score, status,
            customer_name, customer_phone, customer_email,
            sla_hours, due_at, source, urgency_level, customer_value,
            created_by
        ) VALUES (
            callback_id,
            policyholder_id_val,
            agent_id_val,
            'general_inquiry',
            'Customer wants to know about additional coverage options',
            priority_category,
            priority_score,
            'assigned',
            'Amit Singh',
            '+91-9876543212',
            'amit.singh@example.com',
            24,
            due_at_val,
            'whatsapp',
            'low',
            'bronze',
            system_user_id
        );
        
        -- Add activity
        INSERT INTO lic_schema.callback_activities (
            callback_request_id, agent_id, activity_type, description, created_at
        ) VALUES (
            callback_id,
            agent_id_val,
            'assigned',
            'Callback assigned to agent',
            NOW() - INTERVAL '1 hour'
        );
        
        -- Completed Callback
        callback_id := gen_random_uuid();
        INSERT INTO lic_schema.callback_requests (
            callback_request_id, policyholder_id, agent_id,
            request_type, description, priority, priority_score, status,
            customer_name, customer_phone, customer_email,
            sla_hours, due_at, source, urgency_level, customer_value,
            resolution, resolution_category, satisfaction_rating,
            assigned_at, completed_at, created_by, assigned_by, completed_by
        ) VALUES (
            callback_id,
            policyholder_id_val,
            agent_id_val,
            'claim_assistance',
            'Customer needed help filing a claim',
            'high',
            85.0,
            'completed',
            'Sneha Patel',
            '+91-9876543213',
            'sneha.patel@example.com',
            2,
            NOW() - INTERVAL '1 day',
            'mobile',
            'high',
            'platinum',
            'Claim filed successfully. Customer provided all required documents. Claim number: CLM-2024-001',
            'resolved',
            5,
            NOW() - INTERVAL '2 days',
            NOW() - INTERVAL '1 day',
            system_user_id,
            system_user_id,
            system_user_id
        );
        
        -- Add activities for completed callback
        INSERT INTO lic_schema.callback_activities (
            callback_request_id, agent_id, activity_type, description, 
            contact_method, contact_outcome, duration_minutes, created_at
        ) VALUES 
        (
            callback_id,
            agent_id_val,
            'created',
            'Callback request created',
            NULL,
            NULL,
            NULL,
            NOW() - INTERVAL '2 days'
        ),
        (
            callback_id,
            agent_id_val,
            'assigned',
            'Callback assigned to agent',
            NULL,
            NULL,
            NULL,
            NOW() - INTERVAL '2 days'
        ),
        (
            callback_id,
            agent_id_val,
            'called',
            'Called customer and discussed claim filing process',
            'phone',
            'successful',
            15,
            NOW() - INTERVAL '1 day'
        ),
        (
            callback_id,
            agent_id_val,
            'completed',
            'Claim filed successfully. Customer satisfied.',
            'phone',
            'successful',
            10,
            NOW() - INTERVAL '1 day'
        );
        
    END IF;
END $$;

-- =====================================================
-- VERIFICATION
-- =====================================================

-- Verify seed data
DO $$
DECLARE
    template_count INTEGER;
    campaign_count INTEGER;
    callback_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO template_count FROM lic_schema.campaign_templates;
    SELECT COUNT(*) INTO campaign_count FROM lic_schema.campaigns;
    SELECT COUNT(*) INTO callback_count FROM lic_schema.callback_requests;
    
    RAISE NOTICE 'Seed data verification:';
    RAISE NOTICE '  Campaign Templates: %', template_count;
    RAISE NOTICE '  Campaigns: %', campaign_count;
    RAISE NOTICE '  Callback Requests: %', callback_count;
END $$;

