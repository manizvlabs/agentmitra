-- Seed Analytics and Chatbot Data for Testing
-- This migration adds test data for analytics, chatbot, and knowledge base features

-- =====================================================
-- BASIC SEED DATA
-- =====================================================

-- Insert basic policy analytics summary
INSERT INTO lic_schema.policy_analytics_summary (
    summary_date, summary_period, draft_policies, pending_policies,
    approved_policies, active_policies, lapsed_policies, cancelled_policies,
    life_policies, health_policies, general_policies,
    total_premium, average_premium
) VALUES
(CURRENT_DATE, 'daily', 10, 15, 135, 120, 5, 3, 80, 45, 25, 2500000.00, 16666.67)
ON CONFLICT (summary_date, summary_period) DO NOTHING;
