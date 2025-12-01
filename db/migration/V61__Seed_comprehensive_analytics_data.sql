-- Agent Mitra - Migration V61: Simple Analytics Seed Data
-- This migration adds minimal analytics data for testing

-- Add a few more policies with existing data
INSERT INTO lic_schema.insurance_policies (
    policy_id, tenant_id, policy_number, provider_policy_id, policyholder_id, agent_id, provider_id,
    policy_type, plan_name, plan_code, category, sum_assured, premium_amount, premium_frequency,
    application_date, start_date, maturity_date, status, created_at, updated_at
) VALUES
('d1e2f3a4-b5c6-7890-def1-234567890abc', 'bf0b6627-c595-4fd8-93c2-cb0e9cdc86bc', 'POLTEST001', 'EXTT001', 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10', '7b501e0e-4393-4b5a-8de7-25fe384e91da', '550e8400-e29b-41d4-a716-446655440021', 'term_life', 'Test Term', 'TLTEST', 'life', 1000000.00, 15000.00, 'yearly', CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE - INTERVAL '25 days', CURRENT_DATE + INTERVAL '15 years', 'active', CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE - INTERVAL '30 days'),
('d1e2f3a4-b5c6-7890-def1-234567890abd', 'bf0b6627-c595-4fd8-93c2-cb0e9cdc86bc', 'POLTEST002', 'EXTT002', 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '550e8400-e29b-41d4-a716-446655440022', 'health', 'Test Health', 'HSTEST', 'health', 500000.00, 8000.00, 'yearly', CURRENT_DATE - INTERVAL '15 days', CURRENT_DATE - INTERVAL '10 days', CURRENT_DATE + INTERVAL '1 year', 'active', CURRENT_DATE - INTERVAL '15 days', CURRENT_DATE - INTERVAL '15 days');

-- Add corresponding payments
INSERT INTO lic_schema.premium_payments (
    payment_id, policy_id, policyholder_id, amount, currency, payment_date,
    due_date, payment_method, payment_gateway, gateway_transaction_id,
    status, reconciled, created_at, updated_at, tenant_id
) VALUES
('e2f3a4b5-c6d7-8901-efa2-34567890abcd', 'd1e2f3a4-b5c6-7890-def1-234567890abc', 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10', 15000.00, 'INR', CURRENT_DATE - INTERVAL '25 days', CURRENT_DATE - INTERVAL '25 days', 'upi', 'razorpay', 'rzp_test_001', 'completed', true, CURRENT_DATE - INTERVAL '25 days', CURRENT_DATE - INTERVAL '25 days', 'bf0b6627-c595-4fd8-93c2-cb0e9cdc86bc'),
('e2f3a4b5-c6d7-8901-efa2-34567890abce', 'd1e2f3a4-b5c6-7890-def1-234567890abd', 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 8000.00, 'INR', CURRENT_DATE - INTERVAL '10 days', CURRENT_DATE - INTERVAL '10 days', 'net_banking', 'paytm', 'ptm_test_001', 'completed', true, CURRENT_DATE - INTERVAL '10 days', CURRENT_DATE - INTERVAL '10 days', 'bf0b6627-c595-4fd8-93c2-cb0e9cdc86bc');

-- Add a few leads
INSERT INTO lic_schema.leads (
    lead_id, agent_id, customer_name, contact_number, email, location,
    lead_source, lead_status, priority, insurance_type, budget_range,
    coverage_required, potential_premium, created_at, updated_at
) VALUES
('f3a4b5c6-d7e8-9012-fab3-45678901cdef', '7b501e0e-4393-4b5a-8de7-25fe384e91da', 'Test Lead1', '+919876543250', 'test.lead1@email.com', 'Mumbai', 'website', 'qualified', 'high', 'term_life', '50000-100000', 500000.00, 15000.00, CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE - INTERVAL '3 days'),
('f3a4b5c6-d7e8-9012-fab3-45678901cdef', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Test Lead2', '+919876543251', 'test.lead2@email.com', 'Delhi', 'referral', 'contacted', 'medium', 'health', '20000-50000', 200000.00, 8000.00, CURRENT_DATE - INTERVAL '7 days', CURRENT_DATE - INTERVAL '5 days');

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================
