-- Agent Mitra - Migration V62: Seed Campaign Analytics and Execution Data
-- This migration adds sample campaign execution data and analytics for testing

-- =====================================================
-- INSERT CAMPAIGN EXECUTION DATA
-- =====================================================

DO $$
DECLARE
    campaign_record RECORD;
    policyholder_record RECORD;
    execution_count INTEGER := 0;
    tenant_id_val UUID := '00000000-0000-0000-0000-000000000000';
BEGIN

    -- Get existing campaigns
    FOR campaign_record IN
        SELECT campaign_id, agent_id, campaign_name, status
        FROM lic_schema.campaigns
        WHERE status IN ('active', 'completed')
        LIMIT 3
    LOOP
        -- Get some policyholders for this agent
        FOR policyholder_record IN
            SELECT policyholder_id, first_name, phone_number
            FROM lic_schema.policyholders
            WHERE agent_id = campaign_record.agent_id
            LIMIT 10
        LOOP
            -- Insert campaign execution
            INSERT INTO lic_schema.campaign_executions (
                execution_id, tenant_id, campaign_id, policyholder_id,
                channel, personalized_content, sent_at, delivered_at,
                opened_at, clicked_at, status, converted, conversion_value
            ) VALUES (
                gen_random_uuid(),
                tenant_id_val,
                campaign_record.campaign_id,
                policyholder_record.policyholder_id,
                'whatsapp',
                json_build_object(
                    'subject', campaign_record.campaign_name,
                    'message', 'Personalized campaign message for ' || policyholder_record.first_name,
                    'channel', 'whatsapp'
                ),
                NOW() - INTERVAL '5 days',
                CASE WHEN random() > 0.1 THEN NOW() - INTERVAL '5 days' + INTERVAL '1 hour' ELSE NULL END,
                CASE WHEN random() > 0.3 THEN NOW() - INTERVAL '5 days' + INTERVAL '2 hours' ELSE NULL END,
                CASE WHEN random() > 0.7 THEN NOW() - INTERVAL '5 days' + INTERVAL '3 hours' ELSE NULL END,
                CASE
                    WHEN random() > 0.8 THEN 'converted'
                    WHEN random() > 0.6 THEN 'clicked'
                    WHEN random() > 0.4 THEN 'opened'
                    WHEN random() > 0.2 THEN 'delivered'
                    ELSE 'sent'
                END,
                CASE WHEN random() > 0.8 THEN true ELSE false END,
                CASE WHEN random() > 0.8 THEN random() * 5000 ELSE 0 END
            );

            execution_count := execution_count + 1;
        END LOOP;
    END LOOP;

    RAISE NOTICE 'Inserted % campaign executions', execution_count;

END $$;

-- =====================================================
-- UPDATE CAMPAIGN METRICS BASED ON EXECUTIONS
-- =====================================================

DO $$
DECLARE
    campaign_record RECORD;
BEGIN

    -- Update campaign metrics based on executions
    FOR campaign_record IN
        SELECT
            c.campaign_id,
            COUNT(ce.execution_id) as total_sent,
            COUNT(CASE WHEN ce.delivered_at IS NOT NULL THEN 1 END) as total_delivered,
            COUNT(CASE WHEN ce.opened_at IS NOT NULL THEN 1 END) as total_opened,
            COUNT(CASE WHEN ce.clicked_at IS NOT NULL THEN 1 END) as total_clicked,
            COUNT(CASE WHEN ce.converted = true THEN 1 END) as total_converted,
            COALESCE(SUM(ce.conversion_value), 0) as total_revenue
        FROM lic_schema.campaigns c
        LEFT JOIN lic_schema.campaign_executions ce ON c.campaign_id = ce.campaign_id
        WHERE c.status IN ('active', 'completed')
        GROUP BY c.campaign_id
    LOOP
        -- Calculate ROI (assuming budget is set)
        UPDATE lic_schema.campaigns
        SET
            total_sent = campaign_record.total_sent,
            total_delivered = campaign_record.total_delivered,
            total_opened = campaign_record.total_opened,
            total_clicked = campaign_record.total_clicked,
            total_converted = campaign_record.total_converted,
            total_revenue = campaign_record.total_revenue,
            roi_percentage = CASE
                WHEN budget > 0 THEN ((campaign_record.total_revenue - budget) / budget) * 100
                ELSE 0
            END
        WHERE campaign_id = campaign_record.campaign_id;

        RAISE NOTICE 'Updated metrics for campaign %: sent=%, delivered=%, revenue=%',
            campaign_record.campaign_id, campaign_record.total_sent,
            campaign_record.total_delivered, campaign_record.total_revenue;
    END LOOP;

END $$;

-- =====================================================
-- ADD CAMPAIGN RESPONSE DATA
-- =====================================================

DO $$
DECLARE
    execution_record RECORD;
    response_count INTEGER := 0;
BEGIN

    -- Add responses for some executions
    FOR execution_record IN
        SELECT execution_id, campaign_id, policyholder_id, status
        FROM lic_schema.campaign_executions
        WHERE status IN ('opened', 'clicked', 'converted')
        AND random() > 0.5  -- Only add responses for half the executions
        LIMIT 20
    LOOP
        INSERT INTO lic_schema.campaign_responses (
            response_id, execution_id, campaign_id, policyholder_id,
            response_type, response_text, response_channel, sentiment_score
        ) VALUES (
            gen_random_uuid(),
            execution_record.execution_id,
            execution_record.campaign_id,
            execution_record.policyholder_id,
            CASE
                WHEN execution_record.status = 'converted' THEN 'interested'
                WHEN random() > 0.5 THEN 'question'
                ELSE 'complaint'
            END,
            CASE
                WHEN execution_record.status = 'converted' THEN 'Interested in premium upgrade'
                WHEN random() > 0.5 THEN 'Can you provide more details?'
                ELSE 'Having issues with the payment link'
            END,
            'whatsapp',
            CASE
                WHEN random() > 0.6 THEN 0.8
                WHEN random() > 0.3 THEN 0.0
                ELSE -0.5
            END
        );

        response_count := response_count + 1;
    END LOOP;

    RAISE NOTICE 'Inserted % campaign responses', response_count;

END $$;

-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
DECLARE
    execution_count INTEGER;
    response_count INTEGER;
    campaign_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO execution_count FROM lic_schema.campaign_executions;
    SELECT COUNT(*) INTO response_count FROM lic_schema.campaign_responses;
    SELECT COUNT(*) INTO campaign_count FROM lic_schema.campaigns WHERE total_sent > 0;

    RAISE NOTICE 'Migration V62 verification:';
    RAISE NOTICE '  Campaign executions: %', execution_count;
    RAISE NOTICE '  Campaign responses: %', response_count;
    RAISE NOTICE '  Campaigns with metrics: %', campaign_count;
END $$;
