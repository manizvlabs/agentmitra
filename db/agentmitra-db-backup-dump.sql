--
-- PostgreSQL database dump
--

\restrict wDymkuz3ibbc5QqLhlA2dhFK37y2WxhReOMNo31gQF7I0Tf4tahqKXTseA715Ge

-- Dumped from database version 16.10 (Homebrew)
-- Dumped by pg_dump version 16.10 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP POLICY IF EXISTS tenant_users_isolation ON lic_schema.tenant_users;
DROP POLICY IF EXISTS tenant_tenant_users_isolation ON lic_schema.tenant_users;
DROP POLICY IF EXISTS tenant_policyholders_isolation ON lic_schema.policyholders;
DROP POLICY IF EXISTS tenant_policies_isolation ON lic_schema.insurance_policies;
DROP POLICY IF EXISTS tenant_payments_isolation ON lic_schema.premium_payments;
DROP POLICY IF EXISTS tenant_notifications_isolation ON lic_schema.notifications;
DROP POLICY IF EXISTS tenant_commissions_isolation ON lic_schema.commissions;
DROP POLICY IF EXISTS tenant_campaigns_isolation ON lic_schema.campaigns;
DROP POLICY IF EXISTS tenant_agents_isolation ON lic_schema.agents;
ALTER TABLE IF EXISTS ONLY lic_schema.whatsapp_messages DROP CONSTRAINT IF EXISTS whatsapp_messages_sender_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.whatsapp_messages DROP CONSTRAINT IF EXISTS whatsapp_messages_recipient_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.whatsapp_messages DROP CONSTRAINT IF EXISTS whatsapp_messages_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.video_tutorials DROP CONSTRAINT IF EXISTS video_tutorials_content_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.video_recommendations DROP CONSTRAINT IF EXISTS video_recommendations_video_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.video_progress DROP CONSTRAINT IF EXISTS video_progress_video_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.video_content DROP CONSTRAINT IF EXISTS video_content_moderated_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.video_content DROP CONSTRAINT IF EXISTS video_content_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.video_categories DROP CONSTRAINT IF EXISTS video_categories_parent_category_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.video_analytics DROP CONSTRAINT IF EXISTS video_analytics_video_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.video_analytics DROP CONSTRAINT IF EXISTS video_analytics_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_subscriptions DROP CONSTRAINT IF EXISTS user_subscriptions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_subscriptions DROP CONSTRAINT IF EXISTS user_subscriptions_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_subscriptions DROP CONSTRAINT IF EXISTS user_subscriptions_plan_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_subscriptions DROP CONSTRAINT IF EXISTS user_subscriptions_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_sessions DROP CONSTRAINT IF EXISTS user_sessions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_roles DROP CONSTRAINT IF EXISTS user_roles_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_roles DROP CONSTRAINT IF EXISTS user_roles_role_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_roles DROP CONSTRAINT IF EXISTS user_roles_assigned_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_payment_methods DROP CONSTRAINT IF EXISTS user_payment_methods_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_journeys DROP CONSTRAINT IF EXISTS user_journeys_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_journeys DROP CONSTRAINT IF EXISTS user_journeys_session_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.trial_subscriptions DROP CONSTRAINT IF EXISTS trial_subscriptions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.trial_subscriptions DROP CONSTRAINT IF EXISTS trial_subscriptions_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.trial_subscriptions DROP CONSTRAINT IF EXISTS trial_subscriptions_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.trial_engagement DROP CONSTRAINT IF EXISTS trial_engagement_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.trial_engagement DROP CONSTRAINT IF EXISTS trial_engagement_trial_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.trial_engagement DROP CONSTRAINT IF EXISTS trial_engagement_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.tenants DROP CONSTRAINT IF EXISTS tenants_parent_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.tenant_users DROP CONSTRAINT IF EXISTS tenant_users_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.tenant_users DROP CONSTRAINT IF EXISTS tenant_users_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.tenant_usage DROP CONSTRAINT IF EXISTS tenant_usage_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.tenant_config DROP CONSTRAINT IF EXISTS tenant_config_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.subscription_plans DROP CONSTRAINT IF EXISTS subscription_plans_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.subscription_plans DROP CONSTRAINT IF EXISTS subscription_plans_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.subscription_changes DROP CONSTRAINT IF EXISTS subscription_changes_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.subscription_changes DROP CONSTRAINT IF EXISTS subscription_changes_to_plan_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.subscription_changes DROP CONSTRAINT IF EXISTS subscription_changes_subscription_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.subscription_changes DROP CONSTRAINT IF EXISTS subscription_changes_initiated_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.subscription_changes DROP CONSTRAINT IF EXISTS subscription_changes_from_plan_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.subscription_billing_history DROP CONSTRAINT IF EXISTS subscription_billing_history_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.subscription_billing_history DROP CONSTRAINT IF EXISTS subscription_billing_history_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.subscription_billing_history DROP CONSTRAINT IF EXISTS subscription_billing_history_subscription_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.subscription_billing_history DROP CONSTRAINT IF EXISTS subscription_billing_history_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_role_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_permission_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.revenue_forecasts DROP CONSTRAINT IF EXISTS revenue_forecasts_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.revenue_forecasts DROP CONSTRAINT IF EXISTS revenue_forecasts_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.revenue_forecast_scenarios DROP CONSTRAINT IF EXISTS revenue_forecast_scenarios_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.retention_actions DROP CONSTRAINT IF EXISTS retention_actions_retention_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.retention_actions DROP CONSTRAINT IF EXISTS retention_actions_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.rbac_audit_log DROP CONSTRAINT IF EXISTS rbac_audit_log_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.rbac_audit_log DROP CONSTRAINT IF EXISTS rbac_audit_log_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.rbac_audit_log DROP CONSTRAINT IF EXISTS rbac_audit_log_target_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.rbac_audit_log DROP CONSTRAINT IF EXISTS rbac_audit_log_target_role_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.rbac_audit_log DROP CONSTRAINT IF EXISTS rbac_audit_log_target_permission_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.rbac_audit_log DROP CONSTRAINT IF EXISTS rbac_audit_log_target_flag_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.quote_performance DROP CONSTRAINT IF EXISTS quote_performance_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.quote_performance DROP CONSTRAINT IF EXISTS quote_performance_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.quote_performance DROP CONSTRAINT IF EXISTS quote_performance_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentations DROP CONSTRAINT IF EXISTS presentations_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentations DROP CONSTRAINT IF EXISTS presentations_published_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentations DROP CONSTRAINT IF EXISTS presentations_parent_presentation_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentations DROP CONSTRAINT IF EXISTS presentations_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentations DROP CONSTRAINT IF EXISTS presentations_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentation_templates DROP CONSTRAINT IF EXISTS presentation_templates_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentation_slides DROP CONSTRAINT IF EXISTS presentation_slides_presentation_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentation_media DROP CONSTRAINT IF EXISTS presentation_media_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentation_analytics DROP CONSTRAINT IF EXISTS presentation_analytics_viewer_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentation_analytics DROP CONSTRAINT IF EXISTS presentation_analytics_slide_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentation_analytics DROP CONSTRAINT IF EXISTS presentation_analytics_presentation_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentation_analytics DROP CONSTRAINT IF EXISTS presentation_analytics_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.premium_payments DROP CONSTRAINT IF EXISTS premium_payments_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.premium_payments DROP CONSTRAINT IF EXISTS premium_payments_reconciled_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.premium_payments DROP CONSTRAINT IF EXISTS premium_payments_policyholder_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.premium_payments DROP CONSTRAINT IF EXISTS premium_payments_policy_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.predictive_insights DROP CONSTRAINT IF EXISTS predictive_insights_customer_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.predictive_insights DROP CONSTRAINT IF EXISTS predictive_insights_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.predictive_insights DROP CONSTRAINT IF EXISTS predictive_insights_acknowledged_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.policyholders DROP CONSTRAINT IF EXISTS policyholders_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.policyholders DROP CONSTRAINT IF EXISTS policyholders_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.policyholders DROP CONSTRAINT IF EXISTS policyholders_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.notifications DROP CONSTRAINT IF EXISTS notifications_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.leads DROP CONSTRAINT IF EXISTS leads_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.leads DROP CONSTRAINT IF EXISTS leads_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.leads DROP CONSTRAINT IF EXISTS leads_converted_policy_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.leads DROP CONSTRAINT IF EXISTS leads_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.lead_interactions DROP CONSTRAINT IF EXISTS lead_interactions_lead_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.lead_interactions DROP CONSTRAINT IF EXISTS lead_interactions_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.kyc_manual_reviews DROP CONSTRAINT IF EXISTS kyc_manual_reviews_reviewer_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.kyc_manual_reviews DROP CONSTRAINT IF EXISTS kyc_manual_reviews_document_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.kyc_documents DROP CONSTRAINT IF EXISTS kyc_documents_verified_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.kyc_documents DROP CONSTRAINT IF EXISTS kyc_documents_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.knowledge_search_log DROP CONSTRAINT IF EXISTS knowledge_search_log_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.knowledge_search_log DROP CONSTRAINT IF EXISTS knowledge_search_log_session_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.knowledge_search_log DROP CONSTRAINT IF EXISTS knowledge_search_log_clicked_article_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.knowledge_base_articles DROP CONSTRAINT IF EXISTS knowledge_base_articles_moderated_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.knowledge_base_articles DROP CONSTRAINT IF EXISTS knowledge_base_articles_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.insurance_policies DROP CONSTRAINT IF EXISTS insurance_policies_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.insurance_policies DROP CONSTRAINT IF EXISTS insurance_policies_policyholder_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.insurance_policies DROP CONSTRAINT IF EXISTS insurance_policies_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.insurance_policies DROP CONSTRAINT IF EXISTS insurance_policies_approved_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.insurance_policies DROP CONSTRAINT IF EXISTS insurance_policies_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.import_jobs DROP CONSTRAINT IF EXISTS import_jobs_import_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.video_tutorials DROP CONSTRAINT IF EXISTS fk_video_tutorials_content_id;
ALTER TABLE IF EXISTS ONLY lic_schema.video_recommendations DROP CONSTRAINT IF EXISTS fk_video_recommendations_video_id;
ALTER TABLE IF EXISTS ONLY lic_schema.video_progress DROP CONSTRAINT IF EXISTS fk_video_progress_video_id;
ALTER TABLE IF EXISTS ONLY lic_schema.subscription_changes DROP CONSTRAINT IF EXISTS fk_subscription_changes_user;
ALTER TABLE IF EXISTS ONLY lic_schema.subscription_changes DROP CONSTRAINT IF EXISTS fk_subscription_changes_initiated_by;
ALTER TABLE IF EXISTS ONLY lic_schema.quote_sharing_analytics DROP CONSTRAINT IF EXISTS fk_quote_sharing_analytics_quote;
ALTER TABLE IF EXISTS ONLY lic_schema.quote_sharing_analytics DROP CONSTRAINT IF EXISTS fk_quote_sharing_analytics_agent;
ALTER TABLE IF EXISTS ONLY lic_schema.quote_performance DROP CONSTRAINT IF EXISTS fk_quote_performance_quote;
ALTER TABLE IF EXISTS ONLY lic_schema.leads DROP CONSTRAINT IF EXISTS fk_leads_converted_policy;
ALTER TABLE IF EXISTS ONLY lic_schema.daily_quotes DROP CONSTRAINT IF EXISTS fk_daily_quotes_agent;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_retention_analytics DROP CONSTRAINT IF EXISTS fk_customer_retention_customer;
ALTER TABLE IF EXISTS ONLY lic_schema.feature_flags DROP CONSTRAINT IF EXISTS feature_flags_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.feature_flags DROP CONSTRAINT IF EXISTS feature_flags_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.feature_flags DROP CONSTRAINT IF EXISTS feature_flags_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.feature_flag_overrides DROP CONSTRAINT IF EXISTS feature_flag_overrides_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.feature_flag_overrides DROP CONSTRAINT IF EXISTS feature_flag_overrides_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.feature_flag_overrides DROP CONSTRAINT IF EXISTS feature_flag_overrides_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.feature_flag_overrides DROP CONSTRAINT IF EXISTS feature_flag_overrides_role_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.feature_flag_overrides DROP CONSTRAINT IF EXISTS feature_flag_overrides_flag_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.emergency_contacts DROP CONSTRAINT IF EXISTS emergency_contacts_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.emergency_contact_verifications DROP CONSTRAINT IF EXISTS emergency_contact_verifications_contact_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.document_ocr_results DROP CONSTRAINT IF EXISTS document_ocr_results_document_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.data_export_log DROP CONSTRAINT IF EXISTS data_export_log_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.daily_quotes DROP CONSTRAINT IF EXISTS daily_quotes_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.daily_quotes DROP CONSTRAINT IF EXISTS daily_quotes_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_retention_metrics DROP CONSTRAINT IF EXISTS customer_retention_metrics_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_retention_analytics DROP CONSTRAINT IF EXISTS customer_retention_analytics_customer_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_retention_analytics DROP CONSTRAINT IF EXISTS customer_retention_analytics_assigned_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_portal_sessions DROP CONSTRAINT IF EXISTS customer_portal_sessions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_portal_preferences DROP CONSTRAINT IF EXISTS customer_portal_preferences_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_journey_events DROP CONSTRAINT IF EXISTS customer_journey_events_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_journey_events DROP CONSTRAINT IF EXISTS customer_journey_events_session_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_feedback DROP CONSTRAINT IF EXISTS customer_feedback_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_feedback DROP CONSTRAINT IF EXISTS customer_feedback_session_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_feedback DROP CONSTRAINT IF EXISTS customer_feedback_resolved_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_engagement_metrics DROP CONSTRAINT IF EXISTS customer_engagement_metrics_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_data_mapping DROP CONSTRAINT IF EXISTS customer_data_mapping_import_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_behavior_metrics DROP CONSTRAINT IF EXISTS customer_behavior_metrics_customer_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.content DROP CONSTRAINT IF EXISTS content_uploader_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.content DROP CONSTRAINT IF EXISTS content_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.content DROP CONSTRAINT IF EXISTS content_owner_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.content DROP CONSTRAINT IF EXISTS content_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.commissions DROP CONSTRAINT IF EXISTS commissions_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.commissions DROP CONSTRAINT IF EXISTS commissions_policy_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.commissions DROP CONSTRAINT IF EXISTS commissions_payment_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.commissions DROP CONSTRAINT IF EXISTS commissions_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.chatbot_sessions DROP CONSTRAINT IF EXISTS chatbot_sessions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.chatbot_intents DROP CONSTRAINT IF EXISTS chatbot_intents_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.chat_messages DROP CONSTRAINT IF EXISTS chat_messages_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.chat_messages DROP CONSTRAINT IF EXISTS chat_messages_session_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.campaigns DROP CONSTRAINT IF EXISTS campaigns_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.campaigns DROP CONSTRAINT IF EXISTS campaigns_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.campaigns DROP CONSTRAINT IF EXISTS campaigns_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.campaigns DROP CONSTRAINT IF EXISTS campaigns_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.campaign_triggers DROP CONSTRAINT IF EXISTS campaign_triggers_campaign_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.campaign_templates DROP CONSTRAINT IF EXISTS campaign_templates_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.campaign_responses DROP CONSTRAINT IF EXISTS campaign_responses_policyholder_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.campaign_responses DROP CONSTRAINT IF EXISTS campaign_responses_execution_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.campaign_responses DROP CONSTRAINT IF EXISTS campaign_responses_campaign_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.campaign_executions DROP CONSTRAINT IF EXISTS campaign_executions_policyholder_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.campaign_executions DROP CONSTRAINT IF EXISTS campaign_executions_campaign_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.callback_requests DROP CONSTRAINT IF EXISTS callback_requests_policyholder_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.callback_requests DROP CONSTRAINT IF EXISTS callback_requests_last_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.callback_requests DROP CONSTRAINT IF EXISTS callback_requests_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.callback_requests DROP CONSTRAINT IF EXISTS callback_requests_completed_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.callback_requests DROP CONSTRAINT IF EXISTS callback_requests_assigned_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.callback_requests DROP CONSTRAINT IF EXISTS callback_requests_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.callback_activities DROP CONSTRAINT IF EXISTS callback_activities_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.callback_activities DROP CONSTRAINT IF EXISTS callback_activities_callback_request_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.callback_activities DROP CONSTRAINT IF EXISTS callback_activities_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.analytics_query_log DROP CONSTRAINT IF EXISTS analytics_query_log_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.agents DROP CONSTRAINT IF EXISTS agents_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.agents DROP CONSTRAINT IF EXISTS agents_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.agents DROP CONSTRAINT IF EXISTS agents_provider_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.agents DROP CONSTRAINT IF EXISTS agents_parent_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.agents DROP CONSTRAINT IF EXISTS agents_approved_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.agent_presentation_preferences DROP CONSTRAINT IF EXISTS agent_presentation_preferences_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.agent_monthly_summary DROP CONSTRAINT IF EXISTS agent_monthly_summary_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.agent_daily_metrics DROP CONSTRAINT IF EXISTS agent_daily_metrics_agent_id_fkey;
DROP TRIGGER IF EXISTS update_video_tutorials_updated_at ON lic_schema.video_tutorials;
DROP TRIGGER IF EXISTS update_video_recommendations_updated_at ON lic_schema.video_recommendations;
DROP TRIGGER IF EXISTS update_video_progress_updated_at ON lic_schema.video_progress;
DROP TRIGGER IF EXISTS update_video_categories_updated_at ON lic_schema.video_categories;
DROP TRIGGER IF EXISTS update_learning_paths_updated_at ON lic_schema.learning_paths;
DROP TRIGGER IF EXISTS update_lead_score_on_change ON lic_schema.leads;
DROP TRIGGER IF EXISTS update_customer_risk_on_change ON lic_schema.customer_retention_analytics;
DROP TRIGGER IF EXISTS update_agent_metrics_trigger ON lic_schema.insurance_policies;
DROP TRIGGER IF EXISTS trigger_update_user_subscriptions_updated_at ON lic_schema.user_subscriptions;
DROP TRIGGER IF EXISTS trigger_update_trial_subscription_updated_at ON lic_schema.trial_subscriptions;
DROP TRIGGER IF EXISTS trigger_update_trial_status ON lic_schema.trial_subscriptions;
DROP TRIGGER IF EXISTS trigger_update_trial_engagement_updated_at ON lic_schema.trial_engagement;
DROP TRIGGER IF EXISTS trigger_update_subscription_plans_updated_at ON lic_schema.subscription_plans;
DROP TRIGGER IF EXISTS trigger_update_notification_settings_updated_at ON lic_schema.notification_settings;
DROP TRIGGER IF EXISTS trigger_update_kyc_documents_updated_at ON lic_schema.kyc_documents;
DROP TRIGGER IF EXISTS trigger_update_emergency_contacts_updated_at ON lic_schema.emergency_contacts;
DROP TRIGGER IF EXISTS trigger_update_device_tokens_last_used_at ON lic_schema.device_tokens;
DROP TRIGGER IF EXISTS trigger_update_daily_quotes_updated_at ON lic_schema.daily_quotes;
DROP TRIGGER IF EXISTS trigger_update_customer_preferences_updated_at ON lic_schema.customer_portal_preferences;
DROP TRIGGER IF EXISTS trigger_set_trial_end_date ON lic_schema.trial_subscriptions;
DROP TRIGGER IF EXISTS slide_media_usage_trigger ON lic_schema.presentation_slides;
DROP TRIGGER IF EXISTS presentation_analytics_summary_trigger ON lic_schema.presentation_analytics;
DROP TRIGGER IF EXISTS audit_tenant_data_changes_trigger ON lic_schema.users;
DROP TRIGGER IF EXISTS audit_tenant_data_changes_trigger ON lic_schema.policyholders;
DROP TRIGGER IF EXISTS audit_tenant_data_changes_trigger ON lic_schema.insurance_policies;
DROP TRIGGER IF EXISTS audit_tenant_data_changes_trigger ON lic_schema.agents;
DROP TRIGGER IF EXISTS audit_policies_changes ON lic_schema.insurance_policies;
DROP TRIGGER IF EXISTS audit_agents_changes ON lic_schema.agents;
DROP INDEX IF EXISTS lic_schema.idx_whatsapp_messages_agent;
DROP INDEX IF EXISTS lic_schema.idx_video_tutorials_video_id;
DROP INDEX IF EXISTS lic_schema.idx_video_tutorials_search_title;
DROP INDEX IF EXISTS lic_schema.idx_video_tutorials_search_tags;
DROP INDEX IF EXISTS lic_schema.idx_video_tutorials_search_description;
DROP INDEX IF EXISTS lic_schema.idx_video_tutorials_processing_status;
DROP INDEX IF EXISTS lic_schema.idx_video_tutorials_language;
DROP INDEX IF EXISTS lic_schema.idx_video_tutorials_featured;
DROP INDEX IF EXISTS lic_schema.idx_video_tutorials_created_at;
DROP INDEX IF EXISTS lic_schema.idx_video_tutorials_category;
DROP INDEX IF EXISTS lic_schema.idx_video_tutorials_agent_id;
DROP INDEX IF EXISTS lic_schema.idx_video_recommendations_video_id;
DROP INDEX IF EXISTS lic_schema.idx_video_recommendations_user_video;
DROP INDEX IF EXISTS lic_schema.idx_video_recommendations_user_id;
DROP INDEX IF EXISTS lic_schema.idx_video_recommendations_type;
DROP INDEX IF EXISTS lic_schema.idx_video_recommendations_relevance;
DROP INDEX IF EXISTS lic_schema.idx_video_progress_video_id;
DROP INDEX IF EXISTS lic_schema.idx_video_progress_user_video;
DROP INDEX IF EXISTS lic_schema.idx_video_progress_user_id;
DROP INDEX IF EXISTS lic_schema.idx_video_progress_last_watched;
DROP INDEX IF EXISTS lic_schema.idx_video_progress_completed;
DROP INDEX IF EXISTS lic_schema.idx_video_content_agent;
DROP INDEX IF EXISTS lic_schema.idx_video_categories_parent;
DROP INDEX IF EXISTS lic_schema.idx_video_categories_category_id;
DROP INDEX IF EXISTS lic_schema.idx_video_categories_active;
DROP INDEX IF EXISTS lic_schema.idx_video_analytics_watch_session;
DROP INDEX IF EXISTS lic_schema.idx_video_analytics_video_id;
DROP INDEX IF EXISTS lic_schema.idx_video_analytics_user_id;
DROP INDEX IF EXISTS lic_schema.idx_video_analytics_started_at;
DROP INDEX IF EXISTS lic_schema.idx_video_analytics_completed;
DROP INDEX IF EXISTS lic_schema.idx_users_tenant_status;
DROP INDEX IF EXISTS lic_schema.idx_users_role_status;
DROP INDEX IF EXISTS lic_schema.idx_users_phone_verified;
DROP INDEX IF EXISTS lic_schema.idx_users_phone;
DROP INDEX IF EXISTS lic_schema.idx_users_email;
DROP INDEX IF EXISTS lic_schema.idx_users_created_at;
DROP INDEX IF EXISTS lic_schema.idx_user_subscriptions_user_id;
DROP INDEX IF EXISTS lic_schema.idx_user_subscriptions_user;
DROP INDEX IF EXISTS lic_schema.idx_user_subscriptions_status;
DROP INDEX IF EXISTS lic_schema.idx_user_subscriptions_plan;
DROP INDEX IF EXISTS lic_schema.idx_user_subscriptions_end;
DROP INDEX IF EXISTS lic_schema.idx_user_sessions_token;
DROP INDEX IF EXISTS lic_schema.idx_user_sessions_active;
DROP INDEX IF EXISTS lic_schema.idx_user_journeys_user_id;
DROP INDEX IF EXISTS lic_schema.idx_user_journeys_type_status;
DROP INDEX IF EXISTS lic_schema.idx_user_journeys_step_history;
DROP INDEX IF EXISTS lic_schema.idx_user_journeys_status;
DROP INDEX IF EXISTS lic_schema.idx_user_journeys_started_at;
DROP INDEX IF EXISTS lic_schema.idx_user_journeys_journey_data;
DROP INDEX IF EXISTS lic_schema.idx_user_journeys_converted;
DROP INDEX IF EXISTS lic_schema.idx_trial_subscriptions_user_id;
DROP INDEX IF EXISTS lic_schema.idx_trial_subscriptions_updated_by;
DROP INDEX IF EXISTS lic_schema.idx_trial_subscriptions_updated_at;
DROP INDEX IF EXISTS lic_schema.idx_trial_subscriptions_status;
DROP INDEX IF EXISTS lic_schema.idx_trial_subscriptions_end_date;
DROP INDEX IF EXISTS lic_schema.idx_trial_subscriptions_created_by;
DROP INDEX IF EXISTS lic_schema.idx_trial_engagement_updated_by;
DROP INDEX IF EXISTS lic_schema.idx_trial_engagement_updated_at;
DROP INDEX IF EXISTS lic_schema.idx_trial_engagement_type;
DROP INDEX IF EXISTS lic_schema.idx_trial_engagement_trial_id;
DROP INDEX IF EXISTS lic_schema.idx_trial_engagement_timestamp;
DROP INDEX IF EXISTS lic_schema.idx_trial_engagement_feature;
DROP INDEX IF EXISTS lic_schema.idx_trial_engagement_created_by;
DROP INDEX IF EXISTS lic_schema.idx_tenants_tenant_code;
DROP INDEX IF EXISTS lic_schema.idx_tenants_status;
DROP INDEX IF EXISTS lic_schema.idx_tenant_users_user_id;
DROP INDEX IF EXISTS lic_schema.idx_tenant_users_tenant_id;
DROP INDEX IF EXISTS lic_schema.idx_tenant_users_status;
DROP INDEX IF EXISTS lic_schema.idx_tenant_usage_tenant_period;
DROP INDEX IF EXISTS lic_schema.idx_tenant_usage_metric;
DROP INDEX IF EXISTS lic_schema.idx_tenant_config_tenant_id;
DROP INDEX IF EXISTS lic_schema.idx_templates_status;
DROP INDEX IF EXISTS lic_schema.idx_templates_slides;
DROP INDEX IF EXISTS lic_schema.idx_templates_category_public;
DROP INDEX IF EXISTS lic_schema.idx_subscription_plans_type;
DROP INDEX IF EXISTS lic_schema.idx_subscription_plans_active;
DROP INDEX IF EXISTS lic_schema.idx_subscription_changes_user_id;
DROP INDEX IF EXISTS lic_schema.idx_subscription_changes_subscription_id;
DROP INDEX IF EXISTS lic_schema.idx_subscription_changes_subscription;
DROP INDEX IF EXISTS lic_schema.idx_slides_type;
DROP INDEX IF EXISTS lic_schema.idx_slides_presentation_order;
DROP INDEX IF EXISTS lic_schema.idx_slides_cta_button;
DROP INDEX IF EXISTS lic_schema.idx_slides_agent_branding;
DROP INDEX IF EXISTS lic_schema.idx_revenue_forecast_date;
DROP INDEX IF EXISTS lic_schema.idx_revenue_forecast_agent;
DROP INDEX IF EXISTS lic_schema.idx_retention_plan;
DROP INDEX IF EXISTS lic_schema.idx_retention_metrics_user_id;
DROP INDEX IF EXISTS lic_schema.idx_retention_metrics_date;
DROP INDEX IF EXISTS lic_schema.idx_retention_metrics_churn_risk;
DROP INDEX IF EXISTS lic_schema.idx_retention_actions_scheduled;
DROP INDEX IF EXISTS lic_schema.idx_retention_actions_retention;
DROP INDEX IF EXISTS lic_schema.idx_retention_actions_due;
DROP INDEX IF EXISTS lic_schema.idx_retention_actions_agent;
DROP INDEX IF EXISTS lic_schema.idx_rbac_audit_user;
DROP INDEX IF EXISTS lic_schema.idx_rbac_audit_timestamp;
DROP INDEX IF EXISTS lic_schema.idx_rbac_audit_tenant_timestamp;
DROP INDEX IF EXISTS lic_schema.idx_rbac_audit_target_user;
DROP INDEX IF EXISTS lic_schema.idx_rbac_audit_action;
DROP INDEX IF EXISTS lic_schema.idx_quote_sharing_quote_id;
DROP INDEX IF EXISTS lic_schema.idx_quote_sharing_platform;
DROP INDEX IF EXISTS lic_schema.idx_quote_sharing_analytics_quote_id;
DROP INDEX IF EXISTS lic_schema.idx_quote_sharing_analytics_agent_id;
DROP INDEX IF EXISTS lic_schema.idx_quote_sharing_agent_id;
DROP INDEX IF EXISTS lic_schema.idx_quote_performance_quote_id;
DROP INDEX IF EXISTS lic_schema.idx_quote_performance_date;
DROP INDEX IF EXISTS lic_schema.idx_quote_performance_agent_id;
DROP INDEX IF EXISTS lic_schema.idx_presentations_tenant_id;
DROP INDEX IF EXISTS lic_schema.idx_presentations_template;
DROP INDEX IF EXISTS lic_schema.idx_presentations_published;
DROP INDEX IF EXISTS lic_schema.idx_presentations_agent_status;
DROP INDEX IF EXISTS lic_schema.idx_presentations_active;
DROP INDEX IF EXISTS lic_schema.idx_presentation_media_tenant_id;
DROP INDEX IF EXISTS lic_schema.idx_predictive_insights_valid;
DROP INDEX IF EXISTS lic_schema.idx_predictive_insights_type;
DROP INDEX IF EXISTS lic_schema.idx_predictive_insights_customer;
DROP INDEX IF EXISTS lic_schema.idx_predictive_insights_agent;
DROP INDEX IF EXISTS lic_schema.idx_policy_analytics_period;
DROP INDEX IF EXISTS lic_schema.idx_policy_analytics_date;
DROP INDEX IF EXISTS lic_schema.idx_policies_status_dates;
DROP INDEX IF EXISTS lic_schema.idx_policies_policyholder_status;
DROP INDEX IF EXISTS lic_schema.idx_policies_dates_status;
DROP INDEX IF EXISTS lic_schema.idx_policies_agent_provider;
DROP INDEX IF EXISTS lic_schema.idx_payments_status_date;
DROP INDEX IF EXISTS lic_schema.idx_payments_policy_status;
DROP INDEX IF EXISTS lic_schema.idx_payments_policy_date;
DROP INDEX IF EXISTS lic_schema.idx_payments_date_amount;
DROP INDEX IF EXISTS lic_schema.idx_ocr_results_status;
DROP INDEX IF EXISTS lic_schema.idx_ocr_results_document_id;
DROP INDEX IF EXISTS lic_schema.idx_notifications_user_read;
DROP INDEX IF EXISTS lic_schema.idx_notifications_user_id;
DROP INDEX IF EXISTS lic_schema.idx_notifications_type;
DROP INDEX IF EXISTS lic_schema.idx_notifications_tenant_id;
DROP INDEX IF EXISTS lic_schema.idx_notifications_is_read;
DROP INDEX IF EXISTS lic_schema.idx_notifications_created_at;
DROP INDEX IF EXISTS lic_schema.idx_notification_settings_user_id;
DROP INDEX IF EXISTS lic_schema.idx_media_type;
DROP INDEX IF EXISTS lic_schema.idx_media_hash;
DROP INDEX IF EXISTS lic_schema.idx_media_agent_status;
DROP INDEX IF EXISTS lic_schema.idx_manual_reviews_status;
DROP INDEX IF EXISTS lic_schema.idx_manual_reviews_reviewer_id;
DROP INDEX IF EXISTS lic_schema.idx_manual_reviews_document_id;
DROP INDEX IF EXISTS lic_schema.idx_learning_paths_path_id;
DROP INDEX IF EXISTS lic_schema.idx_learning_paths_agent;
DROP INDEX IF EXISTS lic_schema.idx_learning_paths_active;
DROP INDEX IF EXISTS lic_schema.idx_leads_source_type;
DROP INDEX IF EXISTS lic_schema.idx_leads_risk_factors;
DROP INDEX IF EXISTS lic_schema.idx_leads_priority_score;
DROP INDEX IF EXISTS lic_schema.idx_leads_next_followup;
DROP INDEX IF EXISTS lic_schema.idx_leads_created_at;
DROP INDEX IF EXISTS lic_schema.idx_leads_converted_policy_id;
DROP INDEX IF EXISTS lic_schema.idx_leads_agent_status;
DROP INDEX IF EXISTS lic_schema.idx_lead_interactions_lead;
DROP INDEX IF EXISTS lic_schema.idx_lead_interactions_created;
DROP INDEX IF EXISTS lic_schema.idx_lead_interactions_agent;
DROP INDEX IF EXISTS lic_schema.idx_languages_language_code;
DROP INDEX IF EXISTS lic_schema.idx_kyc_documents_user_id;
DROP INDEX IF EXISTS lic_schema.idx_kyc_documents_type;
DROP INDEX IF EXISTS lic_schema.idx_kyc_documents_status;
DROP INDEX IF EXISTS lic_schema.idx_kb_search_user;
DROP INDEX IF EXISTS lic_schema.idx_kb_search_query;
DROP INDEX IF EXISTS lic_schema.idx_kb_articles_tags;
DROP INDEX IF EXISTS lic_schema.idx_kb_articles_category;
DROP INDEX IF EXISTS lic_schema.idx_journey_events_user_id;
DROP INDEX IF EXISTS lic_schema.idx_journey_events_type;
DROP INDEX IF EXISTS lic_schema.idx_journey_events_timestamp;
DROP INDEX IF EXISTS lic_schema.idx_journey_events_session_id;
DROP INDEX IF EXISTS lic_schema.idx_insurance_providers_provider_code;
DROP INDEX IF EXISTS lic_schema.idx_insurance_categories_category_code;
DROP INDEX IF EXISTS lic_schema.idx_insights_actions;
DROP INDEX IF EXISTS lic_schema.idx_import_jobs_status;
DROP INDEX IF EXISTS lic_schema.idx_forecast_scenarios_type;
DROP INDEX IF EXISTS lic_schema.idx_forecast_scenarios_agent;
DROP INDEX IF EXISTS lic_schema.idx_forecast_assumptions;
DROP INDEX IF EXISTS lic_schema.idx_feature_flags_tenant;
DROP INDEX IF EXISTS lic_schema.idx_feature_flags_name;
DROP INDEX IF EXISTS lic_schema.idx_feature_flag_overrides_user;
DROP INDEX IF EXISTS lic_schema.idx_feature_flag_overrides_role;
DROP INDEX IF EXISTS lic_schema.idx_feature_flag_overrides_flag;
DROP INDEX IF EXISTS lic_schema.idx_engagement_metrics_user_id;
DROP INDEX IF EXISTS lic_schema.idx_engagement_metrics_date;
DROP INDEX IF EXISTS lic_schema.idx_emergency_verifications_verified;
DROP INDEX IF EXISTS lic_schema.idx_emergency_verifications_contact_id;
DROP INDEX IF EXISTS lic_schema.idx_emergency_contacts_verification_status;
DROP INDEX IF EXISTS lic_schema.idx_emergency_contacts_user_id;
DROP INDEX IF EXISTS lic_schema.idx_emergency_contacts_primary;
DROP INDEX IF EXISTS lic_schema.idx_device_tokens_user_id;
DROP INDEX IF EXISTS lic_schema.idx_device_tokens_token;
DROP INDEX IF EXISTS lic_schema.idx_data_sync_status_agent;
DROP INDEX IF EXISTS lic_schema.idx_data_imports_agent_status;
DROP INDEX IF EXISTS lic_schema.idx_data_export_user;
DROP INDEX IF EXISTS lic_schema.idx_daily_quotes_scheduled;
DROP INDEX IF EXISTS lic_schema.idx_daily_quotes_category;
DROP INDEX IF EXISTS lic_schema.idx_daily_quotes_agent_id;
DROP INDEX IF EXISTS lic_schema.idx_daily_quotes_active;
DROP INDEX IF EXISTS lic_schema.idx_daily_kpis_date;
DROP INDEX IF EXISTS lic_schema.idx_customer_sessions_user_id;
DROP INDEX IF EXISTS lic_schema.idx_customer_sessions_start;
DROP INDEX IF EXISTS lic_schema.idx_customer_sessions_end;
DROP INDEX IF EXISTS lic_schema.idx_customer_retention_updated;
DROP INDEX IF EXISTS lic_schema.idx_customer_retention_status;
DROP INDEX IF EXISTS lic_schema.idx_customer_retention_risk;
DROP INDEX IF EXISTS lic_schema.idx_customer_retention_customer_id;
DROP INDEX IF EXISTS lic_schema.idx_customer_retention_customer;
DROP INDEX IF EXISTS lic_schema.idx_customer_retention_agent;
DROP INDEX IF EXISTS lic_schema.idx_customer_preferences_user_id;
DROP INDEX IF EXISTS lic_schema.idx_customer_feedback_user_id;
DROP INDEX IF EXISTS lic_schema.idx_customer_feedback_type;
DROP INDEX IF EXISTS lic_schema.idx_customer_feedback_resolved;
DROP INDEX IF EXISTS lic_schema.idx_customer_feedback_rating;
DROP INDEX IF EXISTS lic_schema.idx_customer_data_mapping_import;
DROP INDEX IF EXISTS lic_schema.idx_customer_behavior_date;
DROP INDEX IF EXISTS lic_schema.idx_customer_behavior_customer;
DROP INDEX IF EXISTS lic_schema.idx_countries_country_code;
DROP INDEX IF EXISTS lic_schema.idx_commissions_tenant_id;
DROP INDEX IF EXISTS lic_schema.idx_commissions_status;
DROP INDEX IF EXISTS lic_schema.idx_commissions_policy_id;
DROP INDEX IF EXISTS lic_schema.idx_commissions_payment_id;
DROP INDEX IF EXISTS lic_schema.idx_commissions_agent_id;
DROP INDEX IF EXISTS lic_schema.idx_chatbot_sessions_user;
DROP INDEX IF EXISTS lic_schema.idx_chatbot_intents_active;
DROP INDEX IF EXISTS lic_schema.idx_chatbot_analytics_date;
DROP INDEX IF EXISTS lic_schema.idx_campaigns_type_status;
DROP INDEX IF EXISTS lic_schema.idx_campaigns_tenant_id;
DROP INDEX IF EXISTS lic_schema.idx_campaigns_targeting_rules;
DROP INDEX IF EXISTS lic_schema.idx_campaigns_scheduled;
DROP INDEX IF EXISTS lic_schema.idx_campaigns_created_at;
DROP INDEX IF EXISTS lic_schema.idx_campaigns_agent_status;
DROP INDEX IF EXISTS lic_schema.idx_campaigns_active;
DROP INDEX IF EXISTS lic_schema.idx_campaign_triggers_campaign;
DROP INDEX IF EXISTS lic_schema.idx_campaign_triggers_active;
DROP INDEX IF EXISTS lic_schema.idx_campaign_templates_public;
DROP INDEX IF EXISTS lic_schema.idx_campaign_templates_category;
DROP INDEX IF EXISTS lic_schema.idx_campaign_responses_type;
DROP INDEX IF EXISTS lic_schema.idx_campaign_responses_execution;
DROP INDEX IF EXISTS lic_schema.idx_campaign_responses_campaign;
DROP INDEX IF EXISTS lic_schema.idx_campaign_executions_status;
DROP INDEX IF EXISTS lic_schema.idx_campaign_executions_sent_at;
DROP INDEX IF EXISTS lic_schema.idx_campaign_executions_policyholder;
DROP INDEX IF EXISTS lic_schema.idx_campaign_executions_personalized_content;
DROP INDEX IF EXISTS lic_schema.idx_campaign_executions_campaign;
DROP INDEX IF EXISTS lic_schema.idx_callback_requests_tenant_id;
DROP INDEX IF EXISTS lic_schema.idx_callback_requests_status;
DROP INDEX IF EXISTS lic_schema.idx_callback_requests_priority;
DROP INDEX IF EXISTS lic_schema.idx_callback_requests_policyholder;
DROP INDEX IF EXISTS lic_schema.idx_callback_requests_pending;
DROP INDEX IF EXISTS lic_schema.idx_callback_requests_high_priority;
DROP INDEX IF EXISTS lic_schema.idx_callback_requests_due_at;
DROP INDEX IF EXISTS lic_schema.idx_callback_requests_created_at;
DROP INDEX IF EXISTS lic_schema.idx_callback_requests_agent;
DROP INDEX IF EXISTS lic_schema.idx_callback_activities_tenant_id;
DROP INDEX IF EXISTS lic_schema.idx_callback_activities_metadata;
DROP INDEX IF EXISTS lic_schema.idx_callback_activities_created_at;
DROP INDEX IF EXISTS lic_schema.idx_callback_activities_callback;
DROP INDEX IF EXISTS lic_schema.idx_callback_activities_agent;
DROP INDEX IF EXISTS lic_schema.idx_billing_history_user;
DROP INDEX IF EXISTS lic_schema.idx_billing_history_subscription;
DROP INDEX IF EXISTS lic_schema.idx_analytics_slide;
DROP INDEX IF EXISTS lic_schema.idx_analytics_query_user;
DROP INDEX IF EXISTS lic_schema.idx_analytics_query_type;
DROP INDEX IF EXISTS lic_schema.idx_analytics_presentation;
DROP INDEX IF EXISTS lic_schema.idx_analytics_event_type;
DROP INDEX IF EXISTS lic_schema.idx_analytics_event_data;
DROP INDEX IF EXISTS lic_schema.idx_analytics_agent;
DROP INDEX IF EXISTS lic_schema.idx_agents_user_status;
DROP INDEX IF EXISTS lic_schema.idx_agents_territory;
DROP INDEX IF EXISTS lic_schema.idx_agents_provider;
DROP INDEX IF EXISTS lic_schema.idx_agents_code_status;
DROP INDEX IF EXISTS lic_schema.idx_agent_summary_month;
DROP INDEX IF EXISTS lic_schema.idx_agent_summary_agent_month;
DROP INDEX IF EXISTS lic_schema.idx_agent_metrics_date;
DROP INDEX IF EXISTS lic_schema.idx_agent_metrics_agent_date;
DROP INDEX IF EXISTS lic_schema.idx_agent_leaderboard_rank;
DROP INDEX IF EXISTS lic_schema.flyway_schema_history_s_idx;
ALTER TABLE IF EXISTS ONLY lic_schema.whatsapp_templates DROP CONSTRAINT IF EXISTS whatsapp_templates_template_name_key;
ALTER TABLE IF EXISTS ONLY lic_schema.whatsapp_templates DROP CONSTRAINT IF EXISTS whatsapp_templates_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.whatsapp_messages DROP CONSTRAINT IF EXISTS whatsapp_messages_whatsapp_message_id_key;
ALTER TABLE IF EXISTS ONLY lic_schema.whatsapp_messages DROP CONSTRAINT IF EXISTS whatsapp_messages_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.video_tutorials DROP CONSTRAINT IF EXISTS video_tutorials_video_id_key;
ALTER TABLE IF EXISTS ONLY lic_schema.video_tutorials DROP CONSTRAINT IF EXISTS video_tutorials_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.video_recommendations DROP CONSTRAINT IF EXISTS video_recommendations_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.video_progress DROP CONSTRAINT IF EXISTS video_progress_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.video_content DROP CONSTRAINT IF EXISTS video_content_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.video_categories DROP CONSTRAINT IF EXISTS video_categories_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.video_categories DROP CONSTRAINT IF EXISTS video_categories_category_id_key;
ALTER TABLE IF EXISTS ONLY lic_schema.video_analytics DROP CONSTRAINT IF EXISTS video_analytics_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.users DROP CONSTRAINT IF EXISTS users_username_key;
ALTER TABLE IF EXISTS ONLY lic_schema.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.users DROP CONSTRAINT IF EXISTS users_phone_number_key;
ALTER TABLE IF EXISTS ONLY lic_schema.users DROP CONSTRAINT IF EXISTS users_email_key;
ALTER TABLE IF EXISTS ONLY lic_schema.user_subscriptions DROP CONSTRAINT IF EXISTS user_subscriptions_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_sessions DROP CONSTRAINT IF EXISTS user_sessions_session_token_key;
ALTER TABLE IF EXISTS ONLY lic_schema.user_sessions DROP CONSTRAINT IF EXISTS user_sessions_refresh_token_key;
ALTER TABLE IF EXISTS ONLY lic_schema.user_sessions DROP CONSTRAINT IF EXISTS user_sessions_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_roles DROP CONSTRAINT IF EXISTS user_roles_user_id_role_id_key;
ALTER TABLE IF EXISTS ONLY lic_schema.user_roles DROP CONSTRAINT IF EXISTS user_roles_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_payment_methods DROP CONSTRAINT IF EXISTS user_payment_methods_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_journeys DROP CONSTRAINT IF EXISTS user_journeys_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.emergency_contacts DROP CONSTRAINT IF EXISTS unique_primary_contact_per_user;
ALTER TABLE IF EXISTS ONLY lic_schema.trial_subscriptions DROP CONSTRAINT IF EXISTS trial_subscriptions_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.trial_engagement DROP CONSTRAINT IF EXISTS trial_engagement_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.tenants DROP CONSTRAINT IF EXISTS tenants_tenant_code_key;
ALTER TABLE IF EXISTS ONLY lic_schema.tenants DROP CONSTRAINT IF EXISTS tenants_schema_name_key;
ALTER TABLE IF EXISTS ONLY lic_schema.tenants DROP CONSTRAINT IF EXISTS tenants_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.tenant_users DROP CONSTRAINT IF EXISTS tenant_users_tenant_id_user_id_key;
ALTER TABLE IF EXISTS ONLY lic_schema.tenant_users DROP CONSTRAINT IF EXISTS tenant_users_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.tenant_usage DROP CONSTRAINT IF EXISTS tenant_usage_tenant_id_metric_type_period_start_key;
ALTER TABLE IF EXISTS ONLY lic_schema.tenant_usage DROP CONSTRAINT IF EXISTS tenant_usage_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.tenant_config DROP CONSTRAINT IF EXISTS tenant_config_tenant_id_config_key_key;
ALTER TABLE IF EXISTS ONLY lic_schema.tenant_config DROP CONSTRAINT IF EXISTS tenant_config_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.subscription_plans DROP CONSTRAINT IF EXISTS subscription_plans_plan_name_key;
ALTER TABLE IF EXISTS ONLY lic_schema.subscription_plans DROP CONSTRAINT IF EXISTS subscription_plans_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.subscription_changes DROP CONSTRAINT IF EXISTS subscription_changes_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.subscription_billing_history DROP CONSTRAINT IF EXISTS subscription_billing_history_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.roles DROP CONSTRAINT IF EXISTS roles_role_name_key;
ALTER TABLE IF EXISTS ONLY lic_schema.roles DROP CONSTRAINT IF EXISTS roles_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_role_id_permission_id_key;
ALTER TABLE IF EXISTS ONLY lic_schema.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.revenue_forecasts DROP CONSTRAINT IF EXISTS revenue_forecasts_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.revenue_forecast_scenarios DROP CONSTRAINT IF EXISTS revenue_forecast_scenarios_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.revenue_forecast_scenarios DROP CONSTRAINT IF EXISTS revenue_forecast_scenarios_agent_id_scenario_name_forecast__key;
ALTER TABLE IF EXISTS ONLY lic_schema.retention_actions DROP CONSTRAINT IF EXISTS retention_actions_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.rbac_audit_log DROP CONSTRAINT IF EXISTS rbac_audit_log_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.quote_sharing_analytics DROP CONSTRAINT IF EXISTS quote_sharing_analytics_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.quote_performance DROP CONSTRAINT IF EXISTS quote_performance_quote_id_metric_date_key;
ALTER TABLE IF EXISTS ONLY lic_schema.quote_performance DROP CONSTRAINT IF EXISTS quote_performance_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentations DROP CONSTRAINT IF EXISTS presentations_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentation_templates DROP CONSTRAINT IF EXISTS presentation_templates_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentation_slides DROP CONSTRAINT IF EXISTS presentation_slides_presentation_id_slide_order_key;
ALTER TABLE IF EXISTS ONLY lic_schema.presentation_slides DROP CONSTRAINT IF EXISTS presentation_slides_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentation_media DROP CONSTRAINT IF EXISTS presentation_media_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentation_analytics DROP CONSTRAINT IF EXISTS presentation_analytics_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.premium_payments DROP CONSTRAINT IF EXISTS premium_payments_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.predictive_insights DROP CONSTRAINT IF EXISTS predictive_insights_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.policyholders DROP CONSTRAINT IF EXISTS policyholders_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.policy_analytics_summary DROP CONSTRAINT IF EXISTS policy_analytics_summary_summary_date_summary_period_key;
ALTER TABLE IF EXISTS ONLY lic_schema.policy_analytics_summary DROP CONSTRAINT IF EXISTS policy_analytics_summary_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.permissions DROP CONSTRAINT IF EXISTS permissions_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.permissions DROP CONSTRAINT IF EXISTS permissions_permission_name_key;
ALTER TABLE IF EXISTS ONLY lic_schema.notifications DROP CONSTRAINT IF EXISTS notifications_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.notification_settings DROP CONSTRAINT IF EXISTS notification_settings_user_id_key;
ALTER TABLE IF EXISTS ONLY lic_schema.notification_settings DROP CONSTRAINT IF EXISTS notification_settings_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.learning_paths DROP CONSTRAINT IF EXISTS learning_paths_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.learning_paths DROP CONSTRAINT IF EXISTS learning_paths_path_id_key;
ALTER TABLE IF EXISTS ONLY lic_schema.leads DROP CONSTRAINT IF EXISTS leads_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.lead_interactions DROP CONSTRAINT IF EXISTS lead_interactions_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.languages DROP CONSTRAINT IF EXISTS languages_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.languages DROP CONSTRAINT IF EXISTS languages_language_code_key;
ALTER TABLE IF EXISTS ONLY lic_schema.kyc_manual_reviews DROP CONSTRAINT IF EXISTS kyc_manual_reviews_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.kyc_documents DROP CONSTRAINT IF EXISTS kyc_documents_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.knowledge_search_log DROP CONSTRAINT IF EXISTS knowledge_search_log_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.knowledge_base_articles DROP CONSTRAINT IF EXISTS knowledge_base_articles_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.insurance_providers DROP CONSTRAINT IF EXISTS insurance_providers_provider_code_key;
ALTER TABLE IF EXISTS ONLY lic_schema.insurance_providers DROP CONSTRAINT IF EXISTS insurance_providers_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.insurance_policies DROP CONSTRAINT IF EXISTS insurance_policies_policy_number_key;
ALTER TABLE IF EXISTS ONLY lic_schema.insurance_policies DROP CONSTRAINT IF EXISTS insurance_policies_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.insurance_categories DROP CONSTRAINT IF EXISTS insurance_categories_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.insurance_categories DROP CONSTRAINT IF EXISTS insurance_categories_category_code_key;
ALTER TABLE IF EXISTS ONLY lic_schema.import_jobs DROP CONSTRAINT IF EXISTS import_jobs_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.flyway_schema_history DROP CONSTRAINT IF EXISTS flyway_schema_history_pk;
ALTER TABLE IF EXISTS ONLY lic_schema.feature_flags DROP CONSTRAINT IF EXISTS feature_flags_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.feature_flags DROP CONSTRAINT IF EXISTS feature_flags_flag_name_key;
ALTER TABLE IF EXISTS ONLY lic_schema.feature_flag_overrides DROP CONSTRAINT IF EXISTS feature_flag_overrides_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.emergency_contacts DROP CONSTRAINT IF EXISTS emergency_contacts_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.emergency_contact_verifications DROP CONSTRAINT IF EXISTS emergency_contact_verifications_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.document_ocr_results DROP CONSTRAINT IF EXISTS document_ocr_results_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.device_tokens DROP CONSTRAINT IF EXISTS device_tokens_token_key;
ALTER TABLE IF EXISTS ONLY lic_schema.device_tokens DROP CONSTRAINT IF EXISTS device_tokens_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.data_sync_status DROP CONSTRAINT IF EXISTS data_sync_status_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.data_imports DROP CONSTRAINT IF EXISTS data_imports_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.data_export_log DROP CONSTRAINT IF EXISTS data_export_log_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.daily_quotes DROP CONSTRAINT IF EXISTS daily_quotes_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_retention_metrics DROP CONSTRAINT IF EXISTS customer_retention_metrics_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_retention_analytics DROP CONSTRAINT IF EXISTS customer_retention_analytics_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_portal_sessions DROP CONSTRAINT IF EXISTS customer_portal_sessions_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_portal_preferences DROP CONSTRAINT IF EXISTS customer_portal_preferences_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_journey_events DROP CONSTRAINT IF EXISTS customer_journey_events_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_feedback DROP CONSTRAINT IF EXISTS customer_feedback_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_engagement_metrics DROP CONSTRAINT IF EXISTS customer_engagement_metrics_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_data_mapping DROP CONSTRAINT IF EXISTS customer_data_mapping_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_behavior_metrics DROP CONSTRAINT IF EXISTS customer_behavior_metrics_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_behavior_metrics DROP CONSTRAINT IF EXISTS customer_behavior_metrics_customer_id_metric_date_key;
ALTER TABLE IF EXISTS ONLY lic_schema.countries DROP CONSTRAINT IF EXISTS countries_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.countries DROP CONSTRAINT IF EXISTS countries_country_code_key;
ALTER TABLE IF EXISTS ONLY lic_schema.content DROP CONSTRAINT IF EXISTS content_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.content DROP CONSTRAINT IF EXISTS content_content_id_key;
ALTER TABLE IF EXISTS ONLY lic_schema.commissions DROP CONSTRAINT IF EXISTS commissions_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.chatbot_sessions DROP CONSTRAINT IF EXISTS chatbot_sessions_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.chatbot_intents DROP CONSTRAINT IF EXISTS chatbot_intents_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.chatbot_intents DROP CONSTRAINT IF EXISTS chatbot_intents_intent_name_key;
ALTER TABLE IF EXISTS ONLY lic_schema.chatbot_analytics_summary DROP CONSTRAINT IF EXISTS chatbot_analytics_summary_summary_date_summary_period_key;
ALTER TABLE IF EXISTS ONLY lic_schema.chatbot_analytics_summary DROP CONSTRAINT IF EXISTS chatbot_analytics_summary_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.chat_messages DROP CONSTRAINT IF EXISTS chat_messages_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.campaigns DROP CONSTRAINT IF EXISTS campaigns_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.campaign_triggers DROP CONSTRAINT IF EXISTS campaign_triggers_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.campaign_templates DROP CONSTRAINT IF EXISTS campaign_templates_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.campaign_responses DROP CONSTRAINT IF EXISTS campaign_responses_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.campaign_executions DROP CONSTRAINT IF EXISTS campaign_executions_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.callback_requests DROP CONSTRAINT IF EXISTS callback_requests_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.callback_activities DROP CONSTRAINT IF EXISTS callback_activities_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.analytics_query_log DROP CONSTRAINT IF EXISTS analytics_query_log_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.agents DROP CONSTRAINT IF EXISTS agents_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.agents DROP CONSTRAINT IF EXISTS agents_license_number_key;
ALTER TABLE IF EXISTS ONLY lic_schema.agents DROP CONSTRAINT IF EXISTS agents_agent_code_key;
ALTER TABLE IF EXISTS ONLY lic_schema.agent_presentation_preferences DROP CONSTRAINT IF EXISTS agent_presentation_preferences_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.agent_presentation_preferences DROP CONSTRAINT IF EXISTS agent_presentation_preferences_agent_id_key;
ALTER TABLE IF EXISTS ONLY lic_schema.agent_monthly_summary DROP CONSTRAINT IF EXISTS agent_monthly_summary_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.agent_monthly_summary DROP CONSTRAINT IF EXISTS agent_monthly_summary_agent_id_summary_month_key;
ALTER TABLE IF EXISTS ONLY lic_schema.agent_daily_metrics DROP CONSTRAINT IF EXISTS agent_daily_metrics_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.agent_daily_metrics DROP CONSTRAINT IF EXISTS agent_daily_metrics_agent_id_metric_date_key;
ALTER TABLE IF EXISTS lic_schema.notification_settings ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS lic_schema.device_tokens ALTER COLUMN id DROP DEFAULT;
DROP TABLE IF EXISTS lic_schema.whatsapp_templates;
DROP TABLE IF EXISTS lic_schema.whatsapp_messages;
DROP TABLE IF EXISTS lic_schema.video_tutorials;
DROP TABLE IF EXISTS lic_schema.video_recommendations;
DROP TABLE IF EXISTS lic_schema.video_progress;
DROP TABLE IF EXISTS lic_schema.video_content;
DROP TABLE IF EXISTS lic_schema.video_categories;
DROP TABLE IF EXISTS lic_schema.video_analytics;
DROP TABLE IF EXISTS lic_schema.user_subscriptions;
DROP TABLE IF EXISTS lic_schema.user_sessions;
DROP TABLE IF EXISTS lic_schema.user_roles;
DROP TABLE IF EXISTS lic_schema.user_payment_methods;
DROP TABLE IF EXISTS lic_schema.user_journeys;
DROP TABLE IF EXISTS lic_schema.trial_subscriptions;
DROP TABLE IF EXISTS lic_schema.trial_engagement;
DROP TABLE IF EXISTS lic_schema.tenants;
DROP TABLE IF EXISTS lic_schema.tenant_users;
DROP TABLE IF EXISTS lic_schema.tenant_usage;
DROP TABLE IF EXISTS lic_schema.tenant_config;
DROP TABLE IF EXISTS lic_schema.subscription_plans;
DROP TABLE IF EXISTS lic_schema.subscription_changes;
DROP TABLE IF EXISTS lic_schema.subscription_billing_history;
DROP TABLE IF EXISTS lic_schema.roles;
DROP TABLE IF EXISTS lic_schema.role_permissions;
DROP TABLE IF EXISTS lic_schema.revenue_forecasts;
DROP TABLE IF EXISTS lic_schema.revenue_forecast_scenarios;
DROP TABLE IF EXISTS lic_schema.retention_actions;
DROP TABLE IF EXISTS lic_schema.rbac_audit_log;
DROP TABLE IF EXISTS lic_schema.quote_sharing_analytics;
DROP TABLE IF EXISTS lic_schema.quote_performance;
DROP TABLE IF EXISTS lic_schema.presentations;
DROP TABLE IF EXISTS lic_schema.presentation_templates;
DROP TABLE IF EXISTS lic_schema.presentation_slides;
DROP TABLE IF EXISTS lic_schema.presentation_media;
DROP TABLE IF EXISTS lic_schema.presentation_analytics;
DROP TABLE IF EXISTS lic_schema.premium_payments;
DROP TABLE IF EXISTS lic_schema.predictive_insights;
DROP TABLE IF EXISTS lic_schema.policy_analytics_summary;
DROP TABLE IF EXISTS lic_schema.permissions;
DROP TABLE IF EXISTS lic_schema.notifications;
DROP SEQUENCE IF EXISTS lic_schema.notification_settings_id_seq;
DROP TABLE IF EXISTS lic_schema.notification_settings;
DROP TABLE IF EXISTS lic_schema.learning_paths;
DROP TABLE IF EXISTS lic_schema.leads;
DROP TABLE IF EXISTS lic_schema.lead_interactions;
DROP TABLE IF EXISTS lic_schema.languages;
DROP TABLE IF EXISTS lic_schema.kyc_manual_reviews;
DROP TABLE IF EXISTS lic_schema.kyc_documents;
DROP TABLE IF EXISTS lic_schema.knowledge_search_log;
DROP TABLE IF EXISTS lic_schema.knowledge_base_articles;
DROP TABLE IF EXISTS lic_schema.insurance_providers;
DROP TABLE IF EXISTS lic_schema.insurance_categories;
DROP TABLE IF EXISTS lic_schema.import_jobs;
DROP TABLE IF EXISTS lic_schema.flyway_schema_history;
DROP TABLE IF EXISTS lic_schema.feature_flags;
DROP TABLE IF EXISTS lic_schema.feature_flag_overrides;
DROP TABLE IF EXISTS lic_schema.emergency_contacts;
DROP TABLE IF EXISTS lic_schema.emergency_contact_verifications;
DROP TABLE IF EXISTS lic_schema.document_ocr_results;
DROP SEQUENCE IF EXISTS lic_schema.device_tokens_id_seq;
DROP TABLE IF EXISTS lic_schema.device_tokens;
DROP TABLE IF EXISTS lic_schema.data_sync_status;
DROP TABLE IF EXISTS lic_schema.data_imports;
DROP TABLE IF EXISTS lic_schema.data_export_log;
DROP TABLE IF EXISTS lic_schema.daily_quotes;
DROP MATERIALIZED VIEW IF EXISTS lic_schema.daily_dashboard_kpis;
DROP TABLE IF EXISTS lic_schema.customer_retention_metrics;
DROP TABLE IF EXISTS lic_schema.customer_retention_analytics;
DROP TABLE IF EXISTS lic_schema.customer_portal_sessions;
DROP TABLE IF EXISTS lic_schema.customer_portal_preferences;
DROP TABLE IF EXISTS lic_schema.customer_journey_events;
DROP TABLE IF EXISTS lic_schema.customer_feedback;
DROP TABLE IF EXISTS lic_schema.customer_engagement_metrics;
DROP TABLE IF EXISTS lic_schema.customer_data_mapping;
DROP TABLE IF EXISTS lic_schema.customer_behavior_metrics;
DROP TABLE IF EXISTS lic_schema.countries;
DROP TABLE IF EXISTS lic_schema.content;
DROP TABLE IF EXISTS lic_schema.commissions;
DROP TABLE IF EXISTS lic_schema.chatbot_sessions;
DROP TABLE IF EXISTS lic_schema.chatbot_intents;
DROP TABLE IF EXISTS lic_schema.chatbot_analytics_summary;
DROP TABLE IF EXISTS lic_schema.chat_messages;
DROP TABLE IF EXISTS lic_schema.campaigns;
DROP TABLE IF EXISTS lic_schema.campaign_triggers;
DROP TABLE IF EXISTS lic_schema.campaign_templates;
DROP TABLE IF EXISTS lic_schema.campaign_responses;
DROP TABLE IF EXISTS lic_schema.campaign_executions;
DROP TABLE IF EXISTS lic_schema.callback_requests;
DROP TABLE IF EXISTS lic_schema.callback_activities;
DROP TABLE IF EXISTS lic_schema.analytics_query_log;
DROP TABLE IF EXISTS lic_schema.agent_presentation_preferences;
DROP TABLE IF EXISTS lic_schema.agent_monthly_summary;
DROP MATERIALIZED VIEW IF EXISTS lic_schema.agent_leaderboard;
DROP TABLE IF EXISTS lic_schema.users;
DROP TABLE IF EXISTS lic_schema.policyholders;
DROP TABLE IF EXISTS lic_schema.insurance_policies;
DROP TABLE IF EXISTS lic_schema.agents;
DROP TABLE IF EXISTS lic_schema.agent_daily_metrics;
DROP FUNCTION IF EXISTS lic_schema.validate_tenant_access(user_uuid uuid, tenant_uuid uuid);
DROP FUNCTION IF EXISTS lic_schema.update_user_subscriptions_updated_at();
DROP FUNCTION IF EXISTS lic_schema.update_updated_at_column();
DROP FUNCTION IF EXISTS lic_schema.update_trial_subscription_updated_at();
DROP FUNCTION IF EXISTS lic_schema.update_trial_status();
DROP FUNCTION IF EXISTS lic_schema.update_trial_engagement_updated_at();
DROP FUNCTION IF EXISTS lic_schema.update_subscription_plans_updated_at();
DROP FUNCTION IF EXISTS lic_schema.update_presentation_analytics_summary();
DROP FUNCTION IF EXISTS lic_schema.update_notification_settings_updated_at();
DROP FUNCTION IF EXISTS lic_schema.update_lead_score_trigger();
DROP FUNCTION IF EXISTS lic_schema.update_kyc_documents_updated_at();
DROP FUNCTION IF EXISTS lic_schema.update_emergency_contacts_updated_at();
DROP FUNCTION IF EXISTS lic_schema.update_device_tokens_last_used_at();
DROP FUNCTION IF EXISTS lic_schema.update_daily_quotes_updated_at();
DROP FUNCTION IF EXISTS lic_schema.update_customer_retention_trigger();
DROP FUNCTION IF EXISTS lic_schema.update_customer_preferences_updated_at();
DROP FUNCTION IF EXISTS lic_schema.update_agent_daily_metrics();
DROP FUNCTION IF EXISTS lic_schema.set_trial_end_date();
DROP FUNCTION IF EXISTS lic_schema.set_tenant_context(tenant_uuid uuid);
DROP FUNCTION IF EXISTS lic_schema.refresh_analytics_views();
DROP FUNCTION IF EXISTS lic_schema.log_analytics_query(p_user_id uuid, p_query_type character varying, p_query_params jsonb, p_execution_time integer, p_records_returned integer, p_ip_address inet, p_user_agent text);
DROP FUNCTION IF EXISTS lic_schema.increment_media_usage();
DROP FUNCTION IF EXISTS lic_schema.current_tenant_id();
DROP FUNCTION IF EXISTS lic_schema.calculate_lead_score(p_engagement_score numeric, p_lead_age_days integer, p_response_time_hours numeric, p_interaction_count integer, p_source_effectiveness numeric);
DROP FUNCTION IF EXISTS lic_schema.audit_tenant_data_changes();
DROP FUNCTION IF EXISTS lic_schema.assess_customer_risk(p_days_since_payment integer, p_engagement_score numeric, p_complaints_count integer, p_missed_payments integer, p_days_since_contact integer, p_policy_age_months integer);
DROP TYPE IF EXISTS lic_schema.user_status_enum;
DROP TYPE IF EXISTS lic_schema.user_role_enum;
DROP TYPE IF EXISTS lic_schema.retention_status_enum;
DROP TYPE IF EXISTS lic_schema.policy_status_enum;
DROP TYPE IF EXISTS lic_schema.payment_status_enum;
DROP TYPE IF EXISTS lic_schema.lead_status_enum;
DROP TYPE IF EXISTS lic_schema.lead_source_enum;
DROP TYPE IF EXISTS lic_schema.lead_priority_enum;
DROP TYPE IF EXISTS lic_schema.customer_risk_level_enum;
DROP TYPE IF EXISTS lic_schema.campaign_type_enum;
DROP TYPE IF EXISTS lic_schema.campaign_status_enum;
DROP TYPE IF EXISTS lic_schema.campaign_channel_enum;
DROP TYPE IF EXISTS lic_schema.callback_status;
DROP TYPE IF EXISTS lic_schema.callback_priority;
DROP TYPE IF EXISTS lic_schema.agent_status_enum;
DROP SCHEMA IF EXISTS lic_schema;
--
-- Name: lic_schema; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA lic_schema;


--
-- Name: SCHEMA lic_schema; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA lic_schema IS 'LIC tenant-specific data and business entities';


--
-- Name: agent_status_enum; Type: TYPE; Schema: lic_schema; Owner: -
--

CREATE TYPE lic_schema.agent_status_enum AS ENUM (
    'active',
    'inactive',
    'suspended',
    'pending_approval',
    'rejected'
);


--
-- Name: callback_priority; Type: TYPE; Schema: lic_schema; Owner: -
--

CREATE TYPE lic_schema.callback_priority AS ENUM (
    'high',
    'medium',
    'low'
);


--
-- Name: callback_status; Type: TYPE; Schema: lic_schema; Owner: -
--

CREATE TYPE lic_schema.callback_status AS ENUM (
    'pending',
    'assigned',
    'in_progress',
    'completed',
    'cancelled',
    'overdue'
);


--
-- Name: campaign_channel_enum; Type: TYPE; Schema: lic_schema; Owner: -
--

CREATE TYPE lic_schema.campaign_channel_enum AS ENUM (
    'whatsapp',
    'sms',
    'email',
    'push',
    'multi_channel'
);


--
-- Name: campaign_status_enum; Type: TYPE; Schema: lic_schema; Owner: -
--

CREATE TYPE lic_schema.campaign_status_enum AS ENUM (
    'draft',
    'scheduled',
    'active',
    'paused',
    'completed',
    'cancelled'
);


--
-- Name: campaign_type_enum; Type: TYPE; Schema: lic_schema; Owner: -
--

CREATE TYPE lic_schema.campaign_type_enum AS ENUM (
    'acquisition',
    'retention',
    'upselling',
    'behavioral'
);


--
-- Name: customer_risk_level_enum; Type: TYPE; Schema: lic_schema; Owner: -
--

CREATE TYPE lic_schema.customer_risk_level_enum AS ENUM (
    'high',
    'medium',
    'low'
);


--
-- Name: lead_priority_enum; Type: TYPE; Schema: lic_schema; Owner: -
--

CREATE TYPE lic_schema.lead_priority_enum AS ENUM (
    'high',
    'medium',
    'low'
);


--
-- Name: lead_source_enum; Type: TYPE; Schema: lic_schema; Owner: -
--

CREATE TYPE lic_schema.lead_source_enum AS ENUM (
    'website',
    'referral',
    'cold_call',
    'social_media',
    'email_campaign',
    'whatsapp_campaign',
    'event',
    'partner',
    'walk_in',
    'other'
);


--
-- Name: lead_status_enum; Type: TYPE; Schema: lic_schema; Owner: -
--

CREATE TYPE lic_schema.lead_status_enum AS ENUM (
    'new',
    'contacted',
    'qualified',
    'quoted',
    'converted',
    'lost',
    'inactive'
);


--
-- Name: payment_status_enum; Type: TYPE; Schema: lic_schema; Owner: -
--

CREATE TYPE lic_schema.payment_status_enum AS ENUM (
    'pending',
    'processing',
    'completed',
    'failed',
    'refunded',
    'cancelled'
);


--
-- Name: policy_status_enum; Type: TYPE; Schema: lic_schema; Owner: -
--

CREATE TYPE lic_schema.policy_status_enum AS ENUM (
    'draft',
    'pending_approval',
    'under_review',
    'approved',
    'active',
    'lapsed',
    'surrendered',
    'matured',
    'claimed',
    'cancelled'
);


--
-- Name: retention_status_enum; Type: TYPE; Schema: lic_schema; Owner: -
--

CREATE TYPE lic_schema.retention_status_enum AS ENUM (
    'active',
    'at_risk',
    'churned',
    'recovered',
    'lost'
);


--
-- Name: user_role_enum; Type: TYPE; Schema: lic_schema; Owner: -
--

CREATE TYPE lic_schema.user_role_enum AS ENUM (
    'super_admin',
    'insurance_provider_admin',
    'regional_manager',
    'senior_agent',
    'junior_agent',
    'policyholder',
    'support_staff',
    'guest'
);


--
-- Name: user_status_enum; Type: TYPE; Schema: lic_schema; Owner: -
--

CREATE TYPE lic_schema.user_status_enum AS ENUM (
    'active',
    'inactive',
    'suspended',
    'pending_verification',
    'deactivated'
);


--
-- Name: assess_customer_risk(integer, numeric, integer, integer, integer, integer); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.assess_customer_risk(p_days_since_payment integer, p_engagement_score numeric, p_complaints_count integer, p_missed_payments integer, p_days_since_contact integer, p_policy_age_months integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    payment_risk DECIMAL;
    engagement_risk DECIMAL;
    support_risk DECIMAL;
    age_risk DECIMAL;
    contact_risk DECIMAL;
    overall_risk DECIMAL;
    risk_level VARCHAR(20);
    risk_factors TEXT[] := ARRAY[]::TEXT[];
BEGIN
    -- Calculate risk factors
    payment_risk := LEAST(100, p_days_since_payment * 2);
    engagement_risk := 100 - p_engagement_score;
    support_risk := LEAST(100, (p_complaints_count * 10));
    age_risk := GREATEST(0, 100 - (p_policy_age_months * 2));
    contact_risk := LEAST(100, p_days_since_contact * 1.5);

    -- Calculate overall risk score
    overall_risk := (
        payment_risk * 0.25 +
        engagement_risk * 0.20 +
        support_risk * 0.15 +
        age_risk * 0.15 +
        contact_risk * 0.10 +
        (p_missed_payments * 25) * 0.15
    );

    overall_risk := LEAST(100, GREATEST(0, overall_risk));

    -- Determine risk level
    IF overall_risk >= 70 THEN
        risk_level := 'high';
    ELSIF overall_risk >= 40 THEN
        risk_level := 'medium';
    ELSE
        risk_level := 'low';
    END IF;

    -- Build risk factors array
    IF payment_risk > 50 THEN
        risk_factors := risk_factors || ARRAY['Overdue payments'];
    END IF;
    IF engagement_risk > 60 THEN
        risk_factors := risk_factors || ARRAY['Low engagement'];
    END IF;
    IF support_risk > 40 THEN
        risk_factors := risk_factors || ARRAY['High support queries'];
    END IF;
    IF age_risk > 50 THEN
        risk_factors := risk_factors || ARRAY['Recent policy holder'];
    END IF;
    IF p_missed_payments > 0 THEN
        risk_factors := risk_factors || ARRAY['Payment history issues'];
    END IF;
    IF contact_risk > 40 THEN
        risk_factors := risk_factors || ARRAY['Long time since contact'];
    END IF;

    IF array_length(risk_factors, 1) IS NULL OR array_length(risk_factors, 1) = 0 THEN
        risk_factors := ARRAY['General monitoring'];
    END IF;

    RETURN jsonb_build_object(
        'risk_score', ROUND(overall_risk, 1),
        'risk_level', risk_level,
        'risk_factors', risk_factors,
        'payment_risk', ROUND(payment_risk, 1),
        'engagement_risk', ROUND(engagement_risk, 1),
        'support_risk', ROUND(support_risk, 1),
        'age_risk', ROUND(age_risk, 1),
        'contact_risk', ROUND(contact_risk, 1)
    );
END;
$$;


--
-- Name: audit_tenant_data_changes(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.audit_tenant_data_changes() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $_$
DECLARE
    current_tenant UUID;
    current_user_id UUID;
    record_id_field TEXT;
    record_id_value UUID;
    table_primary_key TEXT;
    client_ip_value INET;
    user_agent_value TEXT;
    target_user_value UUID;
BEGIN
    -- Get current tenant and user from context
    current_tenant := lic_schema.current_tenant_id();
    current_user_id := NULLIF(current_setting('app.current_user_id', TRUE), '')::UUID;

    -- Safely get context settings with fallbacks
    BEGIN
        client_ip_value := NULLIF(current_setting('app.client_ip', TRUE), '')::INET;
    EXCEPTION WHEN OTHERS THEN
        client_ip_value := NULL;
    END;

    BEGIN
        user_agent_value := NULLIF(current_setting('app.user_agent', TRUE), '');
    EXCEPTION WHEN OTHERS THEN
        user_agent_value := NULL;
    END;

    -- Determine primary key field name based on table
    CASE TG_TABLE_NAME
        WHEN 'insurance_policies' THEN
            table_primary_key := 'policy_id';
        WHEN 'agents' THEN
            table_primary_key := 'agent_id';
        WHEN 'users' THEN
            table_primary_key := 'user_id';
        WHEN 'policyholders' THEN
            table_primary_key := 'policyholder_id';
        WHEN 'payments' THEN
            table_primary_key := 'payment_id';
        WHEN 'claims' THEN
            table_primary_key := 'claim_id';
        WHEN 'providers' THEN
            table_primary_key := 'provider_id';
        ELSE
            table_primary_key := 'id'; -- fallback for tables with 'id' primary key
    END CASE;

    -- Get the record ID value
    IF TG_OP = 'DELETE' THEN
        -- For DELETE operations, use OLD record
        EXECUTE format('SELECT ($1).%I', table_primary_key) INTO record_id_value USING OLD;
    ELSE
        -- For INSERT/UPDATE operations, use NEW record
        EXECUTE format('SELECT ($1).%I', table_primary_key) INTO record_id_value USING NEW;
    END IF;

    -- Get target user ID safely
    target_user_value := NULL;
    IF TG_OP = 'DELETE' THEN
        -- For DELETE operations, try to get user_id from OLD record
        BEGIN
            CASE TG_TABLE_NAME
                WHEN 'users' THEN
                    EXECUTE 'SELECT ($1).user_id' INTO target_user_value USING OLD;
                WHEN 'agents' THEN
                    EXECUTE 'SELECT ($1).user_id' INTO target_user_value USING OLD;
                WHEN 'policyholders' THEN
                    EXECUTE 'SELECT ($1).user_id' INTO target_user_value USING OLD;
                -- For other tables, leave as NULL
                ELSE
                    target_user_value := NULL;
            END CASE;
        EXCEPTION WHEN OTHERS THEN
            target_user_value := NULL;
        END;
    ELSE
        -- For INSERT/UPDATE operations, try to get user_id from NEW record
        BEGIN
            CASE TG_TABLE_NAME
                WHEN 'users' THEN
                    EXECUTE 'SELECT ($1).user_id' INTO target_user_value USING NEW;
                WHEN 'agents' THEN
                    EXECUTE 'SELECT ($1).user_id' INTO target_user_value USING NEW;
                WHEN 'policyholders' THEN
                    EXECUTE 'SELECT ($1).user_id' INTO target_user_value USING NEW;
                -- For other tables, leave as NULL
                ELSE
                    target_user_value := NULL;
            END CASE;
        EXCEPTION WHEN OTHERS THEN
            target_user_value := NULL;
        END;
    END IF;

    -- Insert audit record
    INSERT INTO lic_schema.rbac_audit_log (
        tenant_id, user_id, action, target_user_id,
        details, success, ip_address, user_agent
    ) VALUES (
        current_tenant,
        current_user_id,
        CASE
            WHEN TG_OP = 'INSERT' THEN 'data_created'
            WHEN TG_OP = 'UPDATE' THEN 'data_updated'
            WHEN TG_OP = 'DELETE' THEN 'data_deleted'
        END,
        target_user_value,
        jsonb_build_object(
            'table', TG_TABLE_NAME,
            'operation', TG_OP,
            'record_id', record_id_value,
            'primary_key_field', table_primary_key
        ),
        TRUE,
        client_ip_value,
        user_agent_value
    );

    RETURN CASE
        WHEN TG_OP = 'DELETE' THEN OLD
        ELSE NEW
    END;
END;
$_$;


--
-- Name: calculate_lead_score(numeric, integer, numeric, integer, numeric); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.calculate_lead_score(p_engagement_score numeric, p_lead_age_days integer, p_response_time_hours numeric, p_interaction_count integer, p_source_effectiveness numeric DEFAULT 1.0) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    age_score DECIMAL;
    response_score DECIMAL;
    interaction_score DECIMAL;
    conversion_score DECIMAL;
BEGIN
    -- Calculate individual scores (0-100 scale)
    age_score := GREATEST(0, 100 - (p_lead_age_days * 3));
    response_score := GREATEST(0, 100 - (p_response_time_hours * 2));
    interaction_score := LEAST(100, p_interaction_count * 15);

    -- Calculate overall conversion score
    conversion_score := (
        p_engagement_score * 0.25 +      -- 25% weight
        age_score * 0.20 +               -- 20% weight
        response_score * 0.15 +          -- 15% weight
        interaction_score * 0.15 +       -- 15% weight
        (p_source_effectiveness * 20)    -- 25% weight combined
    );

    RETURN LEAST(100, GREATEST(0, conversion_score));
END;
$$;


--
-- Name: current_tenant_id(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.current_tenant_id() RETURNS uuid
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
BEGIN
    RETURN NULLIF(current_setting('app.current_tenant_id', TRUE), '')::UUID;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$;


--
-- Name: increment_media_usage(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.increment_media_usage() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.media_url IS NOT NULL THEN
        UPDATE lic_schema.presentation_media
        SET usage_count = usage_count + 1,
            last_used_at = NOW()
        WHERE media_url = NEW.media_url;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: log_analytics_query(uuid, character varying, jsonb, integer, integer, inet, text); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.log_analytics_query(p_user_id uuid, p_query_type character varying, p_query_params jsonb DEFAULT NULL::jsonb, p_execution_time integer DEFAULT NULL::integer, p_records_returned integer DEFAULT NULL::integer, p_ip_address inet DEFAULT NULL::inet, p_user_agent text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO lic_schema.analytics_query_log (
        user_id, query_type, query_parameters, execution_time_ms,
        records_returned, ip_address, user_agent
    ) VALUES (
        p_user_id, p_query_type, p_query_params, p_execution_time,
        p_records_returned, p_ip_address, p_user_agent
    );
END;
$$;


--
-- Name: refresh_analytics_views(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.refresh_analytics_views() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY lic_schema.daily_dashboard_kpis;
    REFRESH MATERIALIZED VIEW CONCURRENTLY lic_schema.agent_leaderboard;
END;
$$;


--
-- Name: set_tenant_context(uuid); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.set_tenant_context(tenant_uuid uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    PERFORM set_config('app.current_tenant_id', tenant_uuid::TEXT, FALSE);
END;
$$;


--
-- Name: set_trial_end_date(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.set_trial_end_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.trial_end_date IS NULL THEN
        NEW.trial_end_date = NEW.trial_start_date + INTERVAL '30 days';
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: update_agent_daily_metrics(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.update_agent_daily_metrics() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Update or insert daily metrics when policies are modified
    INSERT INTO lic_schema.agent_daily_metrics (
        agent_id, metric_date, policies_sold, premium_collected,
        active_policyholders, new_customers
    )
    SELECT
        p.agent_id,
        CURRENT_DATE,
        COUNT(CASE WHEN p.created_at::date = CURRENT_DATE THEN 1 END),
        COALESCE(SUM(CASE WHEN p.created_at::date = CURRENT_DATE THEN p.premium_amount END), 0),
        COUNT(DISTINCT ph.policyholder_id),
        COUNT(DISTINCT CASE WHEN p.start_date::date = CURRENT_DATE THEN ph.policyholder_id END)
    FROM lic_schema.insurance_policies p
    LEFT JOIN lic_schema.policyholders ph ON p.policyholder_id = ph.policyholder_id
    WHERE p.agent_id = COALESCE(NEW.agent_id, OLD.agent_id)
    AND p.status IN ('active', 'approved')
    GROUP BY p.agent_id
    ON CONFLICT (agent_id, metric_date)
    DO UPDATE SET
        policies_sold = EXCLUDED.policies_sold,
        premium_collected = EXCLUDED.premium_collected,
        active_policyholders = EXCLUDED.active_policyholders,
        new_customers = EXCLUDED.new_customers,
        updated_at = NOW();

    RETURN COALESCE(NEW, OLD);
END;
$$;


--
-- Name: update_customer_preferences_updated_at(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.update_customer_preferences_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_customer_retention_trigger(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.update_customer_retention_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    risk_assessment JSONB;
BEGIN
    -- Calculate risk assessment
    risk_assessment := lic_schema.assess_customer_risk(
        COALESCE(NEW.days_since_last_payment, 0),
        COALESCE(NEW.engagement_score, 50),
        COALESCE(NEW.complaints_count, 0),
        COALESCE(NEW.missed_payments_count, 0),
        COALESCE(NEW.days_since_last_contact, 30),
        COALESCE(NEW.policy_age_months, 12)
    );

    -- Update risk fields
    NEW.risk_score := (risk_assessment->>'risk_score')::DECIMAL;
    NEW.risk_level := (risk_assessment->>'risk_level')::lic_schema.customer_risk_level_enum;
    NEW.risk_factors := (risk_assessment->>'risk_factors')::JSONB;
    NEW.churn_probability := NEW.risk_score; -- Simplified mapping

    RETURN NEW;
END;
$$;


--
-- Name: update_daily_quotes_updated_at(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.update_daily_quotes_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_device_tokens_last_used_at(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.update_device_tokens_last_used_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.last_used_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


--
-- Name: update_emergency_contacts_updated_at(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.update_emergency_contacts_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_kyc_documents_updated_at(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.update_kyc_documents_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_lead_score_trigger(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.update_lead_score_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Calculate and update conversion score when lead data changes
    IF NEW.engagement_score IS NOT NULL AND NEW.created_at IS NOT NULL THEN
        NEW.conversion_score := lic_schema.calculate_lead_score(
            COALESCE(NEW.engagement_score, 0),
            EXTRACT(EPOCH FROM (NOW() - NEW.created_at))::INTEGER / 86400, -- days
            COALESCE(NEW.response_time_hours, 24), -- default 24 hours
            COALESCE(NEW.followup_count, 0),
            CASE NEW.lead_source
                WHEN 'referral' THEN 1.4
                WHEN 'partner' THEN 1.3
                WHEN 'website' THEN 1.2
                WHEN 'whatsapp_campaign' THEN 1.1
                WHEN 'email_campaign' THEN 1.0
                WHEN 'social_media' THEN 0.9
                ELSE 0.8
            END
        );

        -- Update priority based on score
        NEW.priority := CASE
            WHEN NEW.conversion_score >= 80 THEN 'high'::lic_schema.lead_priority_enum
            WHEN NEW.conversion_score >= 60 THEN 'medium'::lic_schema.lead_priority_enum
            ELSE 'low'::lic_schema.lead_priority_enum
        END;
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: update_notification_settings_updated_at(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.update_notification_settings_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


--
-- Name: update_presentation_analytics_summary(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.update_presentation_analytics_summary() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Update presentation summary when analytics events occur
    IF NEW.event_type = 'view' THEN
        UPDATE lic_schema.presentations
        SET total_views = total_views + 1
        WHERE presentation_id = NEW.presentation_id;
    ELSIF NEW.event_type = 'share' THEN
        UPDATE lic_schema.presentations
        SET total_shares = total_shares + 1
        WHERE presentation_id = NEW.presentation_id;
    ELSIF NEW.event_type = 'cta_click' THEN
        UPDATE lic_schema.presentations
        SET total_cta_clicks = total_cta_clicks + 1
        WHERE presentation_id = NEW.presentation_id;
    END IF;
    
    RETURN NEW;
END;
$$;


--
-- Name: update_subscription_plans_updated_at(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.update_subscription_plans_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_trial_engagement_updated_at(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.update_trial_engagement_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_trial_status(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.update_trial_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if trial has expired
    IF NEW.trial_status = 'active' AND NEW.trial_end_date < NOW() THEN
        NEW.trial_status = 'expired';
    END IF;

    -- Check if trial was converted
    IF NEW.actual_conversion_date IS NOT NULL AND NEW.trial_status = 'active' THEN
        NEW.trial_status = 'converted';
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: update_trial_subscription_updated_at(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.update_trial_subscription_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


--
-- Name: update_user_subscriptions_updated_at(); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.update_user_subscriptions_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: validate_tenant_access(uuid, uuid); Type: FUNCTION; Schema: lic_schema; Owner: -
--

CREATE FUNCTION lic_schema.validate_tenant_access(user_uuid uuid, tenant_uuid uuid) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    has_access BOOLEAN := FALSE;
    user_role TEXT;
BEGIN
    -- Check if user is assigned to tenant
    SELECT EXISTS(
        SELECT 1 FROM lic_schema.tenant_users tu
        WHERE tu.user_id = user_uuid
        AND tu.tenant_id = tenant_uuid
        AND tu.status = 'active'
    ) INTO has_access;

    -- If user is assigned to tenant, allow access
    IF has_access THEN
        RETURN TRUE;
    END IF;

    -- Check if user has super_admin role (can access all tenants)
    SELECT r.role_name INTO user_role
    FROM lic_schema.user_roles ur
    JOIN lic_schema.roles r ON ur.role_id = r.role_id
    WHERE ur.user_id = user_uuid
    AND r.role_name = 'super_admin'
    LIMIT 1;

    RETURN user_role IS NOT NULL;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: agent_daily_metrics; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.agent_daily_metrics (
    metric_id uuid DEFAULT gen_random_uuid() NOT NULL,
    agent_id uuid,
    metric_date date NOT NULL,
    policies_sold integer DEFAULT 0,
    premium_collected numeric(15,2) DEFAULT 0,
    active_policyholders integer DEFAULT 0,
    new_customers integer DEFAULT 0,
    commission_earned numeric(12,2) DEFAULT 0,
    target_achievement numeric(5,2) DEFAULT 0,
    customer_satisfaction_score numeric(3,2),
    conversion_rate numeric(5,2),
    presentations_viewed integer DEFAULT 0,
    cta_clicks integer DEFAULT 0,
    whatsapp_messages_sent integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE agent_daily_metrics; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON TABLE lic_schema.agent_daily_metrics IS 'Daily aggregated performance metrics for agents';


--
-- Name: agents; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.agents (
    agent_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    provider_id uuid,
    agent_code character varying(50) NOT NULL,
    license_number character varying(100),
    license_expiry_date date,
    license_issuing_authority character varying(100),
    business_name character varying(255),
    business_address jsonb,
    gst_number character varying(15),
    pan_number character varying(10),
    territory character varying(255),
    operating_regions text[],
    experience_years integer,
    specializations text[],
    commission_rate numeric(5,2),
    commission_structure jsonb,
    performance_bonus_structure jsonb,
    whatsapp_business_number character varying(15),
    business_email character varying(255),
    website character varying(500),
    total_policies_sold integer DEFAULT 0,
    total_premium_collected numeric(15,2) DEFAULT 0,
    active_policyholders integer DEFAULT 0,
    customer_satisfaction_score numeric(3,2),
    parent_agent_id uuid,
    hierarchy_level integer DEFAULT 1,
    sub_agents_count integer DEFAULT 0,
    status lic_schema.agent_status_enum DEFAULT 'active'::lic_schema.agent_status_enum,
    verification_status character varying(50) DEFAULT 'pending'::character varying,
    approved_at timestamp without time zone,
    approved_by uuid,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    tenant_id uuid NOT NULL
);


--
-- Name: insurance_policies; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.insurance_policies (
    policy_id uuid DEFAULT gen_random_uuid() NOT NULL,
    policy_number character varying(100) NOT NULL,
    provider_policy_id character varying(100),
    policyholder_id uuid,
    agent_id uuid,
    provider_id uuid,
    policy_type character varying(100) NOT NULL,
    plan_name character varying(255) NOT NULL,
    plan_code character varying(50),
    category character varying(50),
    sum_assured numeric(15,2) NOT NULL,
    premium_amount numeric(12,2) NOT NULL,
    premium_frequency character varying(20) NOT NULL,
    premium_mode character varying(20),
    application_date date NOT NULL,
    approval_date date,
    start_date date NOT NULL,
    maturity_date date,
    renewal_date date,
    status lic_schema.policy_status_enum DEFAULT 'pending_approval'::lic_schema.policy_status_enum,
    sub_status character varying(50),
    payment_status character varying(50) DEFAULT 'pending'::character varying,
    coverage_details jsonb,
    exclusions jsonb,
    terms_and_conditions jsonb,
    policy_document_url character varying(500),
    application_form_url character varying(500),
    medical_reports jsonb,
    nominee_details jsonb,
    assignee_details jsonb,
    created_by uuid,
    approved_by uuid,
    last_payment_date timestamp without time zone,
    next_payment_date timestamp without time zone,
    total_payments integer DEFAULT 0,
    outstanding_amount numeric(12,2) DEFAULT 0,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    tenant_id uuid NOT NULL
);


--
-- Name: policyholders; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.policyholders (
    policyholder_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    agent_id uuid,
    customer_id character varying(100),
    salutation character varying(10),
    marital_status character varying(20),
    occupation character varying(100),
    annual_income numeric(12,2),
    education_level character varying(50),
    risk_profile jsonb,
    investment_horizon character varying(20),
    communication_preferences jsonb,
    marketing_consent boolean DEFAULT true,
    family_members jsonb,
    nominee_details jsonb,
    bank_details jsonb,
    investment_portfolio jsonb,
    preferred_contact_time character varying(20),
    preferred_language character varying(10) DEFAULT 'en'::character varying,
    digital_literacy_score integer,
    engagement_score numeric(3,2),
    onboarding_status character varying(50) DEFAULT 'completed'::character varying,
    churn_risk_score numeric(3,2),
    last_interaction_at timestamp without time zone,
    total_interactions integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    tenant_id uuid NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.users (
    user_id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    email character varying(255),
    phone_number character varying(15),
    username character varying(100),
    password_hash character varying(255) NOT NULL,
    password_salt character varying(255),
    password_changed_at timestamp without time zone,
    first_name character varying(100),
    last_name character varying(100),
    display_name character varying(255),
    avatar_url character varying(500),
    date_of_birth date,
    gender character varying(20),
    address jsonb,
    emergency_contact jsonb,
    language_preference character varying(10) DEFAULT 'en'::character varying,
    timezone character varying(50) DEFAULT 'Asia/Kolkata'::character varying,
    theme_preference character varying(20) DEFAULT 'light'::character varying,
    notification_preferences jsonb,
    email_verified boolean DEFAULT false,
    phone_verified boolean DEFAULT false,
    email_verification_token character varying(255),
    email_verification_expires timestamp without time zone,
    password_reset_token character varying(255),
    password_reset_expires timestamp without time zone,
    mfa_enabled boolean DEFAULT false,
    mfa_secret character varying(255),
    biometric_enabled boolean DEFAULT false,
    last_login_at timestamp without time zone,
    login_attempts integer DEFAULT 0,
    locked_until timestamp without time zone,
    role lic_schema.user_role_enum NOT NULL,
    status lic_schema.user_status_enum DEFAULT 'active'::lic_schema.user_status_enum,
    trial_end_date timestamp without time zone,
    subscription_plan character varying(50),
    subscription_status character varying(20) DEFAULT 'trial'::character varying,
    created_by uuid,
    created_at timestamp without time zone DEFAULT now(),
    updated_by uuid,
    updated_at timestamp without time zone DEFAULT now(),
    deactivated_at timestamp without time zone,
    deactivated_reason text
);


--
-- Name: agent_leaderboard; Type: MATERIALIZED VIEW; Schema: lic_schema; Owner: -
--

CREATE MATERIALIZED VIEW lic_schema.agent_leaderboard AS
 SELECT a.agent_id,
    u.first_name,
    u.last_name,
    u.display_name,
    count(p.policy_id) AS total_policies,
    COALESCE(sum(p.premium_amount), (0)::numeric) AS total_premium,
    count(DISTINCT ph.policyholder_id) AS active_customers,
    row_number() OVER (ORDER BY (sum(p.premium_amount)) DESC NULLS LAST) AS rank_by_premium,
    row_number() OVER (ORDER BY (count(p.policy_id)) DESC) AS rank_by_policies
   FROM (((lic_schema.agents a
     JOIN lic_schema.users u ON ((a.user_id = u.user_id)))
     LEFT JOIN lic_schema.insurance_policies p ON (((a.agent_id = p.agent_id) AND (p.status = ANY (ARRAY['active'::lic_schema.policy_status_enum, 'approved'::lic_schema.policy_status_enum])))))
     LEFT JOIN lic_schema.policyholders ph ON ((p.policyholder_id = ph.policyholder_id)))
  WHERE (a.status = 'active'::lic_schema.agent_status_enum)
  GROUP BY a.agent_id, u.first_name, u.last_name, u.display_name
  WITH NO DATA;


--
-- Name: MATERIALIZED VIEW agent_leaderboard; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON MATERIALIZED VIEW lic_schema.agent_leaderboard IS 'Real-time agent performance rankings';


--
-- Name: agent_monthly_summary; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.agent_monthly_summary (
    summary_id uuid DEFAULT gen_random_uuid() NOT NULL,
    agent_id uuid,
    summary_month date NOT NULL,
    total_policies integer DEFAULT 0,
    total_premium numeric(15,2) DEFAULT 0,
    total_commission numeric(12,2) DEFAULT 0,
    active_customers integer DEFAULT 0,
    growth_rate numeric(5,2),
    retention_rate numeric(5,2),
    rank_by_premium integer,
    rank_by_policies integer,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: agent_presentation_preferences; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.agent_presentation_preferences (
    preference_id uuid DEFAULT gen_random_uuid() NOT NULL,
    agent_id uuid,
    default_text_color character varying(7) DEFAULT '#FFFFFF'::character varying,
    default_background_color character varying(7) DEFAULT '#000000'::character varying,
    default_layout character varying(50) DEFAULT 'centered'::character varying,
    default_duration integer DEFAULT 4,
    logo_url character varying(500),
    brand_colors jsonb,
    auto_add_logo boolean DEFAULT true,
    auto_add_contact_cta boolean DEFAULT true,
    contact_cta_text character varying(100) DEFAULT 'Talk to me'::character varying,
    editor_theme character varying(20) DEFAULT 'light'::character varying,
    show_preview_by_default boolean DEFAULT true,
    auto_save_enabled boolean DEFAULT true,
    auto_save_interval_seconds integer DEFAULT 60,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: analytics_query_log; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.analytics_query_log (
    log_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    query_type character varying(50) NOT NULL,
    query_parameters jsonb,
    execution_time_ms integer,
    records_returned integer,
    ip_address inet,
    user_agent text,
    data_classification character varying(20) DEFAULT 'internal'::character varying,
    access_reason text,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: callback_activities; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.callback_activities (
    callback_activity_id uuid DEFAULT gen_random_uuid() NOT NULL,
    callback_request_id uuid,
    agent_id uuid,
    activity_type character varying(50) NOT NULL,
    description text NOT NULL,
    duration_minutes integer,
    contact_method character varying(50),
    contact_outcome character varying(100),
    notes text,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp without time zone DEFAULT now(),
    tenant_id uuid NOT NULL
);


--
-- Name: TABLE callback_activities; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON TABLE lic_schema.callback_activities IS 'Activity log for callback request interactions and status changes';


--
-- Name: callback_requests; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.callback_requests (
    callback_request_id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    policyholder_id uuid,
    agent_id uuid,
    request_type character varying(100) NOT NULL,
    description text NOT NULL,
    priority lic_schema.callback_priority DEFAULT 'low'::lic_schema.callback_priority,
    priority_score numeric(5,2) DEFAULT 0.00,
    status lic_schema.callback_status DEFAULT 'pending'::lic_schema.callback_status,
    customer_name character varying(200) NOT NULL,
    customer_phone character varying(20) NOT NULL,
    customer_email character varying(255),
    sla_hours integer DEFAULT 24,
    created_at timestamp without time zone DEFAULT now(),
    assigned_at timestamp without time zone,
    scheduled_at timestamp without time zone,
    due_at timestamp without time zone,
    started_at timestamp without time zone,
    completed_at timestamp without time zone,
    source character varying(50) DEFAULT 'mobile'::character varying,
    source_reference_id character varying(200),
    tags text[] DEFAULT '{}'::text[],
    category character varying(100),
    urgency_level character varying(20) DEFAULT 'medium'::character varying,
    customer_value character varying(20) DEFAULT 'bronze'::character varying,
    resolution text,
    resolution_category character varying(100),
    satisfaction_rating integer,
    created_by uuid,
    assigned_by uuid,
    completed_by uuid,
    last_updated_by uuid,
    last_updated_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT callback_requests_satisfaction_rating_check CHECK (((satisfaction_rating >= 1) AND (satisfaction_rating <= 5)))
);


--
-- Name: TABLE callback_requests; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON TABLE lic_schema.callback_requests IS 'Callback requests from customers requiring agent follow-up';


--
-- Name: campaign_executions; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.campaign_executions (
    execution_id uuid DEFAULT gen_random_uuid() NOT NULL,
    campaign_id uuid,
    policyholder_id uuid,
    channel lic_schema.campaign_channel_enum NOT NULL,
    personalized_content jsonb,
    sent_at timestamp without time zone,
    delivered_at timestamp without time zone,
    opened_at timestamp without time zone,
    clicked_at timestamp without time zone,
    status character varying(50) DEFAULT 'pending'::character varying,
    failure_reason text,
    converted boolean DEFAULT false,
    conversion_value numeric(12,2),
    conversion_type character varying(100),
    device_info jsonb,
    ip_address inet,
    user_agent text,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE campaign_executions; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON TABLE lic_schema.campaign_executions IS 'Individual campaign message executions to customers';


--
-- Name: campaign_responses; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.campaign_responses (
    response_id uuid DEFAULT gen_random_uuid() NOT NULL,
    execution_id uuid,
    campaign_id uuid,
    policyholder_id uuid,
    response_type character varying(50) NOT NULL,
    response_text text,
    response_channel character varying(50),
    sentiment_score numeric(3,2),
    requires_followup boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE campaign_responses; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON TABLE lic_schema.campaign_responses IS 'Customer responses and interactions with campaign messages';


--
-- Name: campaign_templates; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.campaign_templates (
    template_id uuid DEFAULT gen_random_uuid() NOT NULL,
    template_name character varying(255) NOT NULL,
    description text,
    category lic_schema.campaign_type_enum NOT NULL,
    subject_template character varying(500),
    message_template text NOT NULL,
    personalization_tags text[],
    suggested_channels text[],
    usage_count integer DEFAULT 0,
    average_roi numeric(5,2),
    total_ratings integer DEFAULT 0,
    average_rating numeric(3,2),
    preview_image_url character varying(500),
    is_public boolean DEFAULT false,
    is_system_template boolean DEFAULT false,
    status character varying(50) DEFAULT 'active'::character varying,
    created_by uuid,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE campaign_templates; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON TABLE lic_schema.campaign_templates IS 'Pre-built campaign templates for quick campaign creation';


--
-- Name: campaign_triggers; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.campaign_triggers (
    trigger_id uuid DEFAULT gen_random_uuid() NOT NULL,
    campaign_id uuid,
    trigger_type character varying(100) NOT NULL,
    trigger_value character varying(255),
    additional_conditions jsonb,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE campaign_triggers; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON TABLE lic_schema.campaign_triggers IS 'Automation triggers for campaign execution based on customer events';


--
-- Name: campaigns; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.campaigns (
    campaign_id uuid DEFAULT gen_random_uuid() NOT NULL,
    agent_id uuid,
    campaign_name character varying(255) NOT NULL,
    campaign_type lic_schema.campaign_type_enum NOT NULL,
    campaign_goal character varying(100),
    description text,
    subject character varying(500),
    message text NOT NULL,
    message_template_id uuid,
    personalization_tags text[],
    attachments jsonb,
    primary_channel lic_schema.campaign_channel_enum DEFAULT 'whatsapp'::lic_schema.campaign_channel_enum NOT NULL,
    channels text[],
    target_audience character varying(50) DEFAULT 'all'::character varying,
    selected_segments text[],
    targeting_rules jsonb,
    estimated_reach integer DEFAULT 0,
    schedule_type character varying(50) DEFAULT 'immediate'::character varying,
    scheduled_at timestamp without time zone,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    is_automated boolean DEFAULT false,
    automation_triggers jsonb,
    budget numeric(12,2) DEFAULT 0,
    estimated_cost numeric(12,2) DEFAULT 0,
    cost_per_recipient numeric(10,4) DEFAULT 0,
    ab_testing_enabled boolean DEFAULT false,
    ab_test_variants jsonb,
    status lic_schema.campaign_status_enum DEFAULT 'draft'::lic_schema.campaign_status_enum,
    launched_at timestamp without time zone,
    paused_at timestamp without time zone,
    completed_at timestamp without time zone,
    total_sent integer DEFAULT 0,
    total_delivered integer DEFAULT 0,
    total_opened integer DEFAULT 0,
    total_clicked integer DEFAULT 0,
    total_converted integer DEFAULT 0,
    total_revenue numeric(15,2) DEFAULT 0,
    roi_percentage numeric(5,2) DEFAULT 0,
    created_by uuid,
    created_at timestamp without time zone DEFAULT now(),
    updated_by uuid,
    updated_at timestamp without time zone DEFAULT now(),
    tenant_id uuid NOT NULL
);


--
-- Name: TABLE campaigns; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON TABLE lic_schema.campaigns IS 'Marketing campaigns for customer acquisition, retention, upselling, and behavioral engagement';


--
-- Name: chat_messages; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.chat_messages (
    message_id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid,
    user_id uuid,
    message_type character varying(50) DEFAULT 'text'::character varying,
    content text,
    is_from_user boolean DEFAULT true,
    intent_detected character varying(100),
    confidence_score numeric(3,2),
    entities_detected jsonb,
    response_generated text,
    response_time_ms integer,
    suggested_actions jsonb,
    "timestamp" timestamp without time zone DEFAULT now()
);


--
-- Name: chatbot_analytics_summary; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.chatbot_analytics_summary (
    analytics_id uuid DEFAULT gen_random_uuid() NOT NULL,
    summary_date date NOT NULL,
    summary_period character varying(20) DEFAULT 'daily'::character varying,
    total_sessions integer DEFAULT 0,
    completed_sessions integer DEFAULT 0,
    abandoned_sessions integer DEFAULT 0,
    total_messages integer DEFAULT 0,
    average_messages_per_session numeric(5,2),
    average_response_time_ms integer,
    resolution_rate numeric(5,2),
    escalation_rate numeric(5,2),
    average_satisfaction numeric(3,2),
    satisfaction_responses integer DEFAULT 0,
    top_intents jsonb,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE chatbot_analytics_summary; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON TABLE lic_schema.chatbot_analytics_summary IS 'Daily/weekly/monthly chatbot performance analytics';


--
-- Name: chatbot_intents; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.chatbot_intents (
    intent_id uuid DEFAULT gen_random_uuid() NOT NULL,
    intent_name character varying(100) NOT NULL,
    description text,
    training_examples text[] NOT NULL,
    response_templates text[] NOT NULL,
    confidence_threshold numeric(3,2) DEFAULT 0.7,
    is_active boolean DEFAULT true,
    usage_count integer DEFAULT 0,
    success_rate numeric(5,2),
    average_confidence numeric(3,2),
    created_by uuid,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: chatbot_sessions; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.chatbot_sessions (
    session_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    conversation_id character varying(255),
    started_at timestamp without time zone DEFAULT now(),
    ended_at timestamp without time zone,
    duration_seconds integer,
    message_count integer DEFAULT 0,
    resolution_status character varying(50),
    average_response_time numeric(6,2),
    user_satisfaction_score integer,
    escalation_reason text,
    device_info jsonb,
    ip_address inet,
    user_agent text
);


--
-- Name: commissions; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.commissions (
    commission_id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    agent_id uuid NOT NULL,
    policy_id uuid NOT NULL,
    payment_id uuid NOT NULL,
    commission_amount numeric(10,2) NOT NULL,
    commission_rate numeric(5,2),
    commission_type character varying(20) NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    paid_date timestamp without time zone,
    payment_reference character varying(255),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: content; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.content (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    content_id character varying(255) NOT NULL,
    filename character varying(255) NOT NULL,
    original_filename character varying(255) NOT NULL,
    storage_key character varying(500) NOT NULL,
    media_url character varying(1000) NOT NULL,
    file_hash character varying(64) NOT NULL,
    file_size bigint NOT NULL,
    mime_type character varying(100) NOT NULL,
    content_type character varying(50) NOT NULL,
    category character varying(100) NOT NULL,
    sub_category character varying(100),
    tags json,
    content_metadata json,
    description text,
    processing_status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    processing_started_at timestamp with time zone,
    processing_completed_at timestamp with time zone,
    processing_error text,
    video_duration double precision,
    video_resolution character varying(20),
    video_bitrate integer,
    video_codec character varying(50),
    page_count integer,
    word_count integer,
    text_content text,
    document_language character varying(10),
    image_width integer,
    image_height integer,
    image_color_depth integer,
    image_format character varying(20),
    uploader_id uuid NOT NULL,
    owner_id uuid NOT NULL,
    tenant_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    is_public boolean DEFAULT false,
    allowed_users json,
    share_token character varying(255),
    view_count integer DEFAULT 0 NOT NULL,
    download_count integer DEFAULT 0 NOT NULL,
    last_accessed_at timestamp with time zone,
    status character varying(50) DEFAULT 'active'::character varying,
    created_by uuid,
    updated_by uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    retention_policy character varying(50),
    deletion_date timestamp with time zone
);


--
-- Name: countries; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.countries (
    country_id uuid DEFAULT gen_random_uuid() NOT NULL,
    country_code character varying(3) NOT NULL,
    country_name character varying(100) NOT NULL,
    currency_code character varying(3),
    phone_code character varying(5),
    timezone character varying(50),
    status character varying(20) DEFAULT 'active'::character varying
);


--
-- Name: customer_behavior_metrics; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.customer_behavior_metrics (
    metric_id uuid DEFAULT gen_random_uuid() NOT NULL,
    customer_id uuid,
    metric_date date NOT NULL,
    login_count integer DEFAULT 0,
    page_views integer DEFAULT 0,
    session_duration integer DEFAULT 0,
    policy_views integer DEFAULT 0,
    premium_payments integer DEFAULT 0,
    claims_submitted integer DEFAULT 0,
    email_opens integer DEFAULT 0,
    whatsapp_messages integer DEFAULT 0,
    support_tickets integer DEFAULT 0,
    churn_probability numeric(3,2),
    upgrade_probability numeric(3,2),
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: customer_data_mapping; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.customer_data_mapping (
    mapping_id uuid DEFAULT gen_random_uuid() NOT NULL,
    import_id uuid,
    excel_row_number integer NOT NULL,
    customer_name character varying(255),
    phone_number character varying(15),
    email character varying(255),
    policy_number character varying(100),
    date_of_birth date,
    address jsonb,
    raw_excel_data jsonb,
    mapping_status character varying(50) DEFAULT 'pending'::character varying,
    validation_errors jsonb,
    created_customer_id uuid,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: customer_engagement_metrics; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.customer_engagement_metrics (
    metric_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    metric_date date DEFAULT CURRENT_DATE,
    login_count integer DEFAULT 0,
    page_views integer DEFAULT 0,
    feature_usage jsonb,
    session_duration_avg numeric(8,2),
    bounce_rate numeric(5,2),
    conversion_actions integer DEFAULT 0,
    support_requests integer DEFAULT 0,
    feedback_score numeric(3,1),
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: customer_feedback; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.customer_feedback (
    feedback_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    session_id uuid,
    feedback_type character varying(50),
    rating integer,
    feedback_text text,
    category character varying(100),
    page_context character varying(255),
    user_mood character varying(50),
    submitted_at timestamp without time zone DEFAULT now(),
    resolved boolean DEFAULT false,
    resolution_notes text,
    resolved_at timestamp without time zone,
    resolved_by uuid,
    CONSTRAINT customer_feedback_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


--
-- Name: customer_journey_events; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.customer_journey_events (
    event_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    session_id uuid,
    event_type character varying(100),
    event_name character varying(255),
    page_url character varying(500),
    element_identifier character varying(255),
    event_data jsonb,
    "timestamp" timestamp without time zone DEFAULT now(),
    user_journey_stage character varying(50)
);


--
-- Name: customer_portal_preferences; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.customer_portal_preferences (
    preference_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    theme_preference character varying(20) DEFAULT 'light'::character varying,
    language_preference character varying(10) DEFAULT 'en'::character varying,
    notification_preferences jsonb,
    dashboard_layout jsonb,
    quick_actions jsonb,
    accessibility_settings jsonb,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: customer_portal_sessions; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.customer_portal_sessions (
    session_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    session_start timestamp without time zone DEFAULT now(),
    session_end timestamp without time zone,
    duration_minutes integer,
    device_info jsonb,
    ip_address inet,
    user_agent text,
    pages_viewed jsonb,
    actions_taken jsonb,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: customer_retention_analytics; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.customer_retention_analytics (
    retention_id uuid DEFAULT gen_random_uuid() NOT NULL,
    customer_id uuid,
    risk_level lic_schema.customer_risk_level_enum DEFAULT 'low'::lic_schema.customer_risk_level_enum,
    risk_score numeric(5,2) DEFAULT 0,
    churn_probability numeric(5,2) DEFAULT 0,
    risk_factors jsonb DEFAULT '[]'::jsonb,
    engagement_score numeric(5,2) DEFAULT 0,
    premium_value numeric(12,2),
    lifetime_value numeric(15,2),
    days_since_last_payment integer DEFAULT 0,
    days_since_last_contact integer DEFAULT 0,
    complaints_count integer DEFAULT 0,
    support_queries_count integer DEFAULT 0,
    missed_payments_count integer DEFAULT 0,
    policy_age_months integer,
    policy_count integer DEFAULT 1,
    policy_type character varying(100),
    last_retention_action_at timestamp without time zone,
    retention_plan jsonb,
    retention_success_probability numeric(5,2) DEFAULT 0,
    status lic_schema.retention_status_enum DEFAULT 'active'::lic_schema.retention_status_enum,
    status_changed_at timestamp without time zone DEFAULT now(),
    assigned_agent_id uuid,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE customer_retention_analytics; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON TABLE lic_schema.customer_retention_analytics IS 'Customer churn risk assessment and retention analytics';


--
-- Name: customer_retention_metrics; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.customer_retention_metrics (
    retention_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    metric_date date DEFAULT CURRENT_DATE,
    days_since_last_login integer,
    login_frequency_score numeric(5,2),
    engagement_score numeric(5,2),
    feature_adoption_score numeric(5,2),
    support_ticket_count integer DEFAULT 0,
    negative_feedback_count integer DEFAULT 0,
    churn_risk_score numeric(5,2),
    predicted_churn_date date,
    retention_actions_taken jsonb,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: daily_dashboard_kpis; Type: MATERIALIZED VIEW; Schema: lic_schema; Owner: -
--

CREATE MATERIALIZED VIEW lic_schema.daily_dashboard_kpis AS
 SELECT CURRENT_DATE AS report_date,
    count(DISTINCT p.policy_id) AS total_policies,
    count(DISTINCT
        CASE
            WHEN (p.status = 'active'::lic_schema.policy_status_enum) THEN p.policy_id
            ELSE NULL::uuid
        END) AS active_policies,
    COALESCE(sum(
        CASE
            WHEN (p.status = ANY (ARRAY['active'::lic_schema.policy_status_enum, 'approved'::lic_schema.policy_status_enum])) THEN p.premium_amount
            ELSE NULL::numeric
        END), (0)::numeric) AS total_premium,
    count(DISTINCT ph.policyholder_id) AS total_customers,
    count(DISTINCT
        CASE
            WHEN (p.start_date >= (CURRENT_DATE - '30 days'::interval)) THEN ph.policyholder_id
            ELSE NULL::uuid
        END) AS new_customers_30d,
    count(DISTINCT
        CASE
            WHEN (p.start_date >= (CURRENT_DATE - '7 days'::interval)) THEN ph.policyholder_id
            ELSE NULL::uuid
        END) AS new_customers_7d
   FROM (lic_schema.insurance_policies p
     LEFT JOIN lic_schema.policyholders ph ON ((p.policyholder_id = ph.policyholder_id)))
  WHERE (p.created_at >= (CURRENT_DATE - '30 days'::interval))
  WITH NO DATA;


--
-- Name: MATERIALIZED VIEW daily_dashboard_kpis; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON MATERIALIZED VIEW lic_schema.daily_dashboard_kpis IS 'Pre-computed dashboard KPIs for fast loading';


--
-- Name: daily_quotes; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.daily_quotes (
    quote_id uuid DEFAULT gen_random_uuid() NOT NULL,
    agent_id uuid,
    quote_text text NOT NULL,
    author character varying(255),
    category character varying(100) DEFAULT 'motivation'::character varying,
    tags jsonb,
    branding_settings jsonb,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    is_active boolean DEFAULT true,
    scheduled_date date,
    published_at timestamp without time zone,
    is_global boolean DEFAULT false,
    created_by uuid,
    updated_by uuid
);


--
-- Name: data_export_log; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.data_export_log (
    export_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    export_type character varying(50) NOT NULL,
    record_count integer NOT NULL,
    data_types text[],
    date_range tsrange,
    encryption_used boolean DEFAULT true,
    ip_address inet,
    purpose character varying(100),
    retention_period_days integer DEFAULT 90,
    file_name character varying(255),
    file_size_bytes bigint,
    storage_location character varying(500),
    created_at timestamp without time zone DEFAULT now(),
    expires_at timestamp without time zone
);


--
-- Name: data_imports; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.data_imports (
    import_id uuid DEFAULT gen_random_uuid() NOT NULL,
    agent_id uuid,
    file_name character varying(255) NOT NULL,
    file_path character varying(500),
    file_size_bytes bigint,
    import_type character varying(50) DEFAULT 'customer_data'::character varying,
    status character varying(50) DEFAULT 'pending'::character varying,
    total_records integer DEFAULT 0,
    processed_records integer DEFAULT 0,
    error_records integer DEFAULT 0,
    error_details jsonb,
    processing_started_at timestamp without time zone,
    processing_completed_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: data_sync_status; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.data_sync_status (
    sync_id uuid DEFAULT gen_random_uuid() NOT NULL,
    agent_id uuid,
    customer_id uuid,
    last_sync_at timestamp without time zone DEFAULT now(),
    sync_status character varying(50) DEFAULT 'pending'::character varying,
    sync_type character varying(50) DEFAULT 'initial'::character varying,
    error_message text,
    retry_count integer DEFAULT 0,
    next_retry_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: device_tokens; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.device_tokens (
    id integer NOT NULL,
    user_id uuid NOT NULL,
    token character varying(255) NOT NULL,
    device_type character varying(20) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_used_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: device_tokens_id_seq; Type: SEQUENCE; Schema: lic_schema; Owner: -
--

CREATE SEQUENCE lic_schema.device_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: device_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: lic_schema; Owner: -
--

ALTER SEQUENCE lic_schema.device_tokens_id_seq OWNED BY lic_schema.device_tokens.id;


--
-- Name: document_ocr_results; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.document_ocr_results (
    ocr_id uuid DEFAULT gen_random_uuid() NOT NULL,
    document_id uuid,
    ocr_provider character varying(50),
    confidence_score numeric(5,2),
    extracted_fields jsonb,
    processing_status character varying(50) DEFAULT 'processing'::character varying,
    processed_at timestamp without time zone,
    error_message text,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: emergency_contact_verifications; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.emergency_contact_verifications (
    verification_id uuid DEFAULT gen_random_uuid() NOT NULL,
    contact_id uuid,
    verification_method character varying(50),
    verification_code character varying(10),
    attempts integer DEFAULT 0,
    verified boolean DEFAULT false,
    verified_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: emergency_contacts; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.emergency_contacts (
    contact_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    full_name character varying(255) NOT NULL,
    phone_number character varying(15) NOT NULL,
    email character varying(255),
    relationship character varying(50) NOT NULL,
    address jsonb,
    is_primary boolean DEFAULT false,
    verification_status character varying(50) DEFAULT 'unverified'::character varying,
    verified_at timestamp without time zone,
    priority integer DEFAULT 1,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: feature_flag_overrides; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.feature_flag_overrides (
    override_id uuid DEFAULT gen_random_uuid() NOT NULL,
    flag_id uuid,
    user_id uuid,
    role_id uuid,
    tenant_id uuid,
    override_value text,
    created_at timestamp without time zone DEFAULT now(),
    updated_by uuid
);


--
-- Name: feature_flags; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.feature_flags (
    flag_id uuid DEFAULT gen_random_uuid() NOT NULL,
    flag_name character varying(100) NOT NULL,
    flag_description text,
    flag_type character varying(20) DEFAULT 'boolean'::character varying,
    default_value text,
    is_enabled boolean DEFAULT true,
    tenant_id uuid,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by uuid,
    updated_by uuid
);


--
-- Name: flyway_schema_history; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


--
-- Name: import_jobs; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.import_jobs (
    job_id uuid DEFAULT gen_random_uuid() NOT NULL,
    import_id uuid,
    job_type character varying(50) NOT NULL,
    priority integer DEFAULT 1,
    status character varying(50) DEFAULT 'queued'::character varying,
    retry_count integer DEFAULT 0,
    max_retries integer DEFAULT 3,
    error_message text,
    started_at timestamp without time zone,
    completed_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: insurance_categories; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.insurance_categories (
    category_id uuid DEFAULT gen_random_uuid() NOT NULL,
    category_code character varying(20) NOT NULL,
    category_name character varying(100) NOT NULL,
    category_type character varying(50),
    description text,
    status character varying(20) DEFAULT 'active'::character varying
);


--
-- Name: insurance_providers; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.insurance_providers (
    provider_id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider_code character varying(20) NOT NULL,
    provider_name character varying(255) NOT NULL,
    provider_type character varying(50),
    description text,
    api_endpoint character varying(500),
    api_credentials jsonb,
    webhook_url character varying(500),
    webhook_secret character varying(255),
    license_number character varying(100),
    regulatory_authority character varying(100),
    established_year integer,
    headquarters jsonb,
    supported_languages text[] DEFAULT ARRAY['en'::text],
    business_hours jsonb,
    service_regions text[],
    commission_structure jsonb,
    status character varying(50) DEFAULT 'active'::character varying,
    integration_status character varying(50) DEFAULT 'pending'::character varying,
    last_sync_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: knowledge_base_articles; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.knowledge_base_articles (
    article_id uuid DEFAULT gen_random_uuid() NOT NULL,
    title character varying(500) NOT NULL,
    content text NOT NULL,
    summary text,
    category character varying(100) NOT NULL,
    sub_category character varying(100),
    tags text[],
    content_type character varying(50) DEFAULT 'text'::character varying,
    language character varying(10) DEFAULT 'en'::character varying,
    difficulty_level character varying(20) DEFAULT 'intermediate'::character varying,
    embedding_vector jsonb,
    keywords_extracted text[],
    related_articles uuid[],
    view_count integer DEFAULT 0,
    helpful_votes integer DEFAULT 0,
    total_votes integer DEFAULT 0,
    average_rating numeric(3,2),
    is_active boolean DEFAULT true,
    is_featured boolean DEFAULT false,
    moderation_status character varying(20) DEFAULT 'approved'::character varying,
    created_by uuid,
    moderated_by uuid,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    published_at timestamp without time zone
);


--
-- Name: TABLE knowledge_base_articles; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON TABLE lic_schema.knowledge_base_articles IS 'AI-powered knowledge base for chatbot and user support';


--
-- Name: knowledge_search_log; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.knowledge_search_log (
    search_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    session_id uuid,
    search_query text NOT NULL,
    search_filters jsonb,
    results_count integer DEFAULT 0,
    clicked_article_id uuid,
    search_time_ms integer,
    search_source character varying(50) DEFAULT 'manual'::character varying,
    ip_address inet,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: kyc_documents; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.kyc_documents (
    document_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    document_type character varying(50) NOT NULL,
    file_path character varying(500) NOT NULL,
    ocr_extracted_data jsonb,
    verification_status character varying(50) DEFAULT 'pending'::character varying,
    rejection_reason text,
    verified_at timestamp without time zone,
    verified_by uuid,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: kyc_manual_reviews; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.kyc_manual_reviews (
    review_id uuid DEFAULT gen_random_uuid() NOT NULL,
    document_id uuid,
    reviewer_id uuid,
    review_status character varying(50) DEFAULT 'pending'::character varying,
    review_notes text,
    reviewed_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: languages; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.languages (
    language_id uuid DEFAULT gen_random_uuid() NOT NULL,
    language_code character varying(10) NOT NULL,
    language_name character varying(100) NOT NULL,
    native_name character varying(100),
    rtl boolean DEFAULT false,
    status character varying(20) DEFAULT 'active'::character varying
);


--
-- Name: lead_interactions; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.lead_interactions (
    interaction_id uuid DEFAULT gen_random_uuid() NOT NULL,
    lead_id uuid,
    interaction_type character varying(50) NOT NULL,
    interaction_method character varying(50),
    duration_minutes integer,
    outcome character varying(100),
    notes text,
    next_action text,
    next_action_date timestamp without time zone,
    agent_id uuid,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE lead_interactions; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON TABLE lic_schema.lead_interactions IS 'Detailed interaction log for lead follow-up and conversion tracking';


--
-- Name: leads; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.leads (
    lead_id uuid DEFAULT gen_random_uuid() NOT NULL,
    agent_id uuid,
    customer_name character varying(255) NOT NULL,
    contact_number character varying(20) NOT NULL,
    email character varying(255),
    location character varying(255),
    lead_source lic_schema.lead_source_enum NOT NULL,
    lead_status lic_schema.lead_status_enum DEFAULT 'new'::lic_schema.lead_status_enum,
    priority lic_schema.lead_priority_enum DEFAULT 'medium'::lic_schema.lead_priority_enum,
    insurance_type character varying(100),
    budget_range character varying(50),
    coverage_required numeric(15,2),
    conversion_score numeric(5,2) DEFAULT 0,
    engagement_score numeric(5,2) DEFAULT 0,
    potential_premium numeric(12,2) DEFAULT 0,
    is_qualified boolean DEFAULT false,
    qualification_notes text,
    disqualification_reason text,
    created_at timestamp without time zone DEFAULT now(),
    first_contact_at timestamp without time zone,
    last_contact_at timestamp without time zone,
    last_contact_method character varying(50),
    next_followup_at timestamp without time zone,
    followup_count integer DEFAULT 0,
    response_time_hours numeric(6,2),
    converted_at timestamp without time zone,
    converted_policy_id uuid,
    conversion_value numeric(12,2),
    created_by uuid,
    updated_by uuid,
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE leads; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON TABLE lic_schema.leads IS 'Lead management and scoring system for agent opportunities';


--
-- Name: learning_paths; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.learning_paths (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    path_id character varying(255) NOT NULL,
    title character varying(500) NOT NULL,
    description text,
    target_audience jsonb,
    policy_types jsonb,
    difficulty_level character varying(20) DEFAULT 'beginner'::character varying,
    estimated_duration_hours numeric(5,2),
    video_sequence jsonb,
    prerequisites jsonb,
    is_active boolean DEFAULT true,
    total_enrollments integer DEFAULT 0,
    completion_rate numeric(5,2) DEFAULT 0.00,
    average_completion_days numeric(5,2),
    created_by_agent_id uuid NOT NULL,
    last_updated_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: notification_settings; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.notification_settings (
    id integer NOT NULL,
    user_id uuid NOT NULL,
    enable_push_notifications boolean DEFAULT true NOT NULL,
    enable_policy_notifications boolean DEFAULT true NOT NULL,
    enable_payment_reminders boolean DEFAULT true NOT NULL,
    enable_claim_updates boolean DEFAULT true NOT NULL,
    enable_renewal_notices boolean DEFAULT true NOT NULL,
    enable_marketing_notifications boolean DEFAULT false NOT NULL,
    enable_sound boolean DEFAULT true NOT NULL,
    enable_vibration boolean DEFAULT true NOT NULL,
    show_badge boolean DEFAULT true NOT NULL,
    quiet_hours_enabled boolean DEFAULT false NOT NULL,
    quiet_hours_start character varying(5),
    quiet_hours_end character varying(5),
    enabled_topics jsonb DEFAULT '["general", "policies", "payments"]'::jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: notification_settings_id_seq; Type: SEQUENCE; Schema: lic_schema; Owner: -
--

CREATE SEQUENCE lic_schema.notification_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notification_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: lic_schema; Owner: -
--

ALTER SEQUENCE lic_schema.notification_settings_id_seq OWNED BY lic_schema.notification_settings.id;


--
-- Name: notifications; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    body text NOT NULL,
    type character varying(50) NOT NULL,
    priority character varying(20) DEFAULT 'medium'::character varying NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    read_at timestamp with time zone,
    action_url character varying(500),
    action_route character varying(200),
    action_text character varying(100),
    image_url character varying(500),
    data jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    scheduled_at timestamp with time zone,
    tenant_id uuid NOT NULL
);


--
-- Name: permissions; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.permissions (
    permission_id uuid DEFAULT gen_random_uuid() NOT NULL,
    permission_name character varying(100) NOT NULL,
    permission_description text,
    resource character varying(50),
    action character varying(50),
    created_at timestamp without time zone DEFAULT now(),
    is_system_permission boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE permissions; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON TABLE lic_schema.permissions IS 'RBAC permissions table with resource and action columns matching ORM model';


--
-- Name: policy_analytics_summary; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.policy_analytics_summary (
    summary_id uuid DEFAULT gen_random_uuid() NOT NULL,
    summary_date date NOT NULL,
    summary_period character varying(20) DEFAULT 'daily'::character varying,
    draft_policies integer DEFAULT 0,
    pending_policies integer DEFAULT 0,
    approved_policies integer DEFAULT 0,
    active_policies integer DEFAULT 0,
    lapsed_policies integer DEFAULT 0,
    cancelled_policies integer DEFAULT 0,
    life_policies integer DEFAULT 0,
    health_policies integer DEFAULT 0,
    general_policies integer DEFAULT 0,
    total_premium numeric(15,2) DEFAULT 0,
    average_premium numeric(12,2) DEFAULT 0,
    applications_received integer DEFAULT 0,
    applications_approved integer DEFAULT 0,
    conversion_rate numeric(5,2) DEFAULT 0,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: predictive_insights; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.predictive_insights (
    insight_id uuid DEFAULT gen_random_uuid() NOT NULL,
    agent_id uuid,
    customer_id uuid,
    insight_type character varying(100) NOT NULL,
    title character varying(500) NOT NULL,
    description text,
    confidence numeric(5,2),
    impact_level character varying(20),
    recommended_actions jsonb,
    potential_value numeric(12,2),
    deadline timestamp without time zone,
    is_acknowledged boolean DEFAULT false,
    acknowledged_at timestamp without time zone,
    acknowledged_by uuid,
    valid_from timestamp without time zone DEFAULT now(),
    valid_until timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE predictive_insights; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON TABLE lic_schema.predictive_insights IS 'AI-generated insights and recommendations for agents';


--
-- Name: premium_payments; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.premium_payments (
    payment_id uuid DEFAULT gen_random_uuid() NOT NULL,
    policy_id uuid,
    policyholder_id uuid,
    amount numeric(12,2) NOT NULL,
    currency character varying(3) DEFAULT 'INR'::character varying,
    payment_date timestamp without time zone DEFAULT now(),
    due_date timestamp without time zone,
    grace_period_days integer DEFAULT 30,
    payment_method character varying(50),
    payment_gateway character varying(50),
    gateway_transaction_id character varying(255),
    gateway_response jsonb,
    status lic_schema.payment_status_enum DEFAULT 'pending'::lic_schema.payment_status_enum,
    failure_reason text,
    retry_count integer DEFAULT 0,
    reconciled boolean DEFAULT false,
    reconciled_at timestamp without time zone,
    reconciled_by uuid,
    ip_address inet,
    user_agent text,
    device_info jsonb,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    tenant_id uuid NOT NULL
);


--
-- Name: presentation_analytics; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.presentation_analytics (
    analytics_id uuid DEFAULT gen_random_uuid() NOT NULL,
    presentation_id uuid,
    slide_id uuid,
    agent_id uuid,
    event_type character varying(50) NOT NULL,
    event_category character varying(50),
    viewer_id uuid,
    viewer_type character varying(50),
    event_data jsonb,
    cta_action character varying(100),
    share_method character varying(50),
    device_info jsonb,
    ip_address inet,
    user_agent text,
    location_info jsonb,
    event_timestamp timestamp without time zone DEFAULT now()
);


--
-- Name: presentation_media; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.presentation_media (
    media_id uuid DEFAULT gen_random_uuid() NOT NULL,
    agent_id uuid,
    media_type character varying(50) NOT NULL,
    mime_type character varying(100),
    file_name character varying(255),
    file_size_bytes bigint,
    storage_provider character varying(50) DEFAULT 's3'::character varying,
    storage_key character varying(500) NOT NULL,
    media_url character varying(500) NOT NULL,
    thumbnail_url character varying(500),
    width integer,
    height integer,
    duration_seconds integer,
    file_hash character varying(64),
    usage_count integer DEFAULT 0,
    last_used_at timestamp without time zone,
    status character varying(50) DEFAULT 'active'::character varying,
    is_optimized boolean DEFAULT false,
    uploaded_at timestamp without time zone DEFAULT now(),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    tenant_id uuid
);


--
-- Name: presentation_slides; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.presentation_slides (
    slide_id uuid DEFAULT gen_random_uuid() NOT NULL,
    presentation_id uuid,
    slide_order integer NOT NULL,
    slide_type character varying(50) NOT NULL,
    media_url character varying(500),
    media_type character varying(50),
    thumbnail_url character varying(500),
    media_storage_key character varying(500),
    title text,
    subtitle text,
    description text,
    text_color character varying(7) DEFAULT '#FFFFFF'::character varying,
    background_color character varying(7) DEFAULT '#000000'::character varying,
    overlay_opacity numeric(3,2) DEFAULT 0.5,
    layout character varying(50) DEFAULT 'centered'::character varying,
    duration integer DEFAULT 4,
    transition_effect character varying(50) DEFAULT 'fade'::character varying,
    cta_button jsonb,
    agent_branding jsonb,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: presentation_templates; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.presentation_templates (
    template_id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    category character varying(100) NOT NULL,
    slides jsonb NOT NULL,
    is_default boolean DEFAULT false,
    is_public boolean DEFAULT false,
    is_system_template boolean DEFAULT false,
    usage_count integer DEFAULT 0,
    average_rating numeric(3,2),
    total_ratings integer DEFAULT 0,
    preview_image_url character varying(500),
    preview_video_url character varying(500),
    status character varying(50) DEFAULT 'active'::character varying,
    available_from timestamp without time zone,
    available_until timestamp without time zone,
    created_by uuid,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: presentations; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.presentations (
    presentation_id uuid DEFAULT gen_random_uuid() NOT NULL,
    agent_id uuid,
    name character varying(255) NOT NULL,
    description text,
    status character varying(50) DEFAULT 'draft'::character varying,
    is_active boolean DEFAULT false,
    template_id uuid,
    template_category character varying(100),
    version integer DEFAULT 1,
    parent_presentation_id uuid,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    published_at timestamp without time zone,
    archived_at timestamp without time zone,
    tags text[],
    target_audience text[],
    language character varying(10) DEFAULT 'en'::character varying,
    total_views integer DEFAULT 0,
    total_shares integer DEFAULT 0,
    total_cta_clicks integer DEFAULT 0,
    created_by uuid,
    published_by uuid,
    tenant_id uuid NOT NULL
);


--
-- Name: quote_performance; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.quote_performance (
    performance_id uuid DEFAULT gen_random_uuid() NOT NULL,
    quote_id uuid,
    agent_id uuid,
    metric_date date DEFAULT CURRENT_DATE,
    views_count integer DEFAULT 0,
    shares_count integer DEFAULT 0,
    likes_count integer DEFAULT 0,
    responses_count integer DEFAULT 0,
    conversion_count integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now(),
    created_by uuid,
    updated_by uuid
);


--
-- Name: quote_sharing_analytics; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.quote_sharing_analytics (
    share_id uuid DEFAULT gen_random_uuid() NOT NULL,
    quote_id uuid,
    agent_id uuid,
    platform character varying(50),
    recipient_count integer DEFAULT 1,
    delivery_status character varying(50) DEFAULT 'sent'::character varying,
    engagement_metrics jsonb,
    shared_at timestamp without time zone DEFAULT now(),
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: rbac_audit_log; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.rbac_audit_log (
    audit_id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    user_id uuid,
    action character varying(50) NOT NULL,
    target_user_id uuid,
    target_role_id uuid,
    target_permission_id uuid,
    target_flag_id uuid,
    details jsonb,
    success boolean DEFAULT true,
    ip_address inet,
    user_agent text,
    "timestamp" timestamp without time zone DEFAULT now()
);


--
-- Name: retention_actions; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.retention_actions (
    action_id uuid DEFAULT gen_random_uuid() NOT NULL,
    retention_id uuid,
    action_type character varying(100) NOT NULL,
    action_description text,
    action_priority character varying(20) DEFAULT 'medium'::character varying,
    scheduled_at timestamp without time zone,
    completed_at timestamp without time zone,
    due_at timestamp without time zone,
    outcome character varying(100),
    outcome_notes text,
    retention_value numeric(12,2),
    agent_id uuid,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE retention_actions; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON TABLE lic_schema.retention_actions IS 'Retention action planning and execution tracking';


--
-- Name: revenue_forecast_scenarios; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.revenue_forecast_scenarios (
    scenario_id uuid DEFAULT gen_random_uuid() NOT NULL,
    agent_id uuid,
    scenario_name character varying(255) NOT NULL,
    scenario_type character varying(50) NOT NULL,
    forecast_period character varying(20) NOT NULL,
    projected_revenue numeric(15,2) NOT NULL,
    revenue_growth_rate numeric(5,2),
    confidence_level numeric(5,2),
    assumptions jsonb,
    risk_factors jsonb,
    mitigation_strategies jsonb,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE revenue_forecast_scenarios; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON TABLE lic_schema.revenue_forecast_scenarios IS 'Revenue forecasting scenarios with risk assessment';


--
-- Name: revenue_forecasts; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.revenue_forecasts (
    forecast_id uuid DEFAULT gen_random_uuid() NOT NULL,
    agent_id uuid,
    forecast_period character varying(20) NOT NULL,
    forecast_date date NOT NULL,
    target_date date NOT NULL,
    predicted_revenue numeric(15,2) NOT NULL,
    predicted_commission numeric(12,2),
    confidence_level numeric(3,2),
    actual_revenue numeric(15,2),
    actual_commission numeric(12,2),
    forecast_accuracy numeric(5,2),
    forecast_method character varying(50) DEFAULT 'linear_regression'::character varying,
    created_by uuid,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE revenue_forecasts; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON TABLE lic_schema.revenue_forecasts IS 'Revenue and commission forecasting data';


--
-- Name: role_permissions; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.role_permissions (
    assignment_id uuid DEFAULT gen_random_uuid() NOT NULL,
    role_id uuid,
    permission_id uuid,
    granted_at timestamp without time zone DEFAULT now()
);


--
-- Name: roles; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.roles (
    role_id uuid DEFAULT gen_random_uuid() NOT NULL,
    role_name character varying(100) NOT NULL,
    role_description text,
    is_system_role boolean DEFAULT false,
    permissions jsonb,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: subscription_billing_history; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.subscription_billing_history (
    billing_id uuid DEFAULT gen_random_uuid() NOT NULL,
    subscription_id uuid,
    user_id uuid,
    amount numeric(10,2) NOT NULL,
    currency character varying(3) DEFAULT 'INR'::character varying,
    billing_date timestamp without time zone DEFAULT now(),
    billing_period_start timestamp without time zone,
    billing_period_end timestamp without time zone,
    payment_gateway character varying(50),
    gateway_transaction_id character varying(255),
    status character varying(50) DEFAULT 'paid'::character varying,
    invoice_url character varying(500),
    receipt_url character varying(500),
    failure_reason text,
    subscription_metadata jsonb,
    created_at timestamp without time zone DEFAULT now(),
    created_by uuid,
    updated_by uuid,
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: subscription_changes; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.subscription_changes (
    change_id uuid DEFAULT gen_random_uuid() NOT NULL,
    subscription_id uuid,
    user_id uuid,
    from_plan_id uuid,
    to_plan_id uuid,
    change_type character varying(50),
    effective_date timestamp without time zone DEFAULT now(),
    proration_amount numeric(10,2),
    billing_cycle_change boolean DEFAULT false,
    initiated_by uuid,
    reason text,
    subscription_metadata jsonb,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: subscription_plans; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.subscription_plans (
    plan_id uuid DEFAULT gen_random_uuid() NOT NULL,
    plan_name character varying(100) NOT NULL,
    plan_type character varying(50) NOT NULL,
    display_name character varying(255) NOT NULL,
    description text,
    price_monthly numeric(10,2),
    price_yearly numeric(10,2),
    currency character varying(3) DEFAULT 'INR'::character varying,
    features jsonb,
    limitations jsonb,
    max_users integer,
    max_storage_gb integer,
    max_policies integer,
    is_active boolean DEFAULT true,
    is_popular boolean DEFAULT false,
    sort_order integer DEFAULT 0,
    trial_days integer DEFAULT 14,
    stripe_price_id_monthly character varying(255),
    stripe_price_id_yearly character varying(255),
    razorpay_plan_id_monthly character varying(255),
    razorpay_plan_id_yearly character varying(255),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by uuid,
    updated_by uuid
);


--
-- Name: tenant_config; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.tenant_config (
    config_id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    config_key character varying(100) NOT NULL,
    config_value jsonb,
    config_type character varying(50) DEFAULT 'string'::character varying,
    is_encrypted boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: tenant_usage; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.tenant_usage (
    usage_id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    metric_type character varying(50) NOT NULL,
    metric_value bigint NOT NULL,
    period_start timestamp without time zone NOT NULL,
    period_end timestamp without time zone NOT NULL,
    recorded_at timestamp without time zone DEFAULT now()
);


--
-- Name: tenant_users; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.tenant_users (
    tenant_user_id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role character varying(50) NOT NULL,
    permissions jsonb,
    is_primary boolean DEFAULT false,
    joined_at timestamp without time zone DEFAULT now(),
    status character varying(20) DEFAULT 'active'::character varying
);


--
-- Name: tenants; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.tenants (
    tenant_id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_code character varying(20) NOT NULL,
    tenant_name character varying(255) NOT NULL,
    tenant_type character varying(50) NOT NULL,
    schema_name character varying(100),
    parent_tenant_id uuid,
    status character varying(20) DEFAULT 'active'::character varying,
    subscription_plan character varying(50),
    trial_end_date timestamp without time zone,
    max_users integer DEFAULT 1000,
    storage_limit_gb integer DEFAULT 10,
    api_rate_limit integer DEFAULT 1000,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: trial_engagement; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.trial_engagement (
    engagement_id uuid DEFAULT gen_random_uuid() NOT NULL,
    trial_id uuid,
    feature_used character varying(100),
    engagement_type character varying(50),
    engagement_metadata jsonb,
    engaged_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by uuid,
    updated_by uuid,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: trial_subscriptions; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.trial_subscriptions (
    trial_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    plan_type character varying(50) DEFAULT 'policyholder_trial'::character varying,
    trial_start_date timestamp without time zone DEFAULT now(),
    trial_end_date timestamp without time zone,
    actual_conversion_date timestamp without time zone,
    conversion_plan character varying(50),
    trial_status character varying(50) DEFAULT 'active'::character varying,
    extension_days integer DEFAULT 0,
    reminder_sent boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by uuid,
    updated_by uuid
);


--
-- Name: user_journeys; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.user_journeys (
    journey_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    journey_type character varying(100) NOT NULL,
    started_at timestamp without time zone DEFAULT now(),
    completed_at timestamp without time zone,
    status character varying(50) DEFAULT 'active'::character varying,
    current_step integer DEFAULT 1,
    total_steps integer,
    step_history jsonb,
    converted boolean DEFAULT false,
    conversion_value numeric(12,2),
    drop_off_step integer,
    drop_off_reason text,
    journey_data jsonb,
    session_id uuid,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE user_journeys; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON TABLE lic_schema.user_journeys IS 'Tracks user journeys through various processes like onboarding, policy purchase, etc.';


--
-- Name: COLUMN user_journeys.journey_type; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON COLUMN lic_schema.user_journeys.journey_type IS 'Type of journey: onboarding, policy_purchase, claim_process, etc.';


--
-- Name: COLUMN user_journeys.step_history; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON COLUMN lic_schema.user_journeys.step_history IS 'JSONB array tracking each step with timestamp, action, and metadata';


--
-- Name: COLUMN user_journeys.converted; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON COLUMN lic_schema.user_journeys.converted IS 'Whether the journey resulted in a conversion (e.g., policy purchase)';


--
-- Name: COLUMN user_journeys.drop_off_step; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON COLUMN lic_schema.user_journeys.drop_off_step IS 'Step number where user abandoned the journey';


--
-- Name: user_payment_methods; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.user_payment_methods (
    payment_method_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    method_type character varying(50) NOT NULL,
    method_name character varying(100),
    is_default boolean DEFAULT false,
    card_number_encrypted text,
    card_holder_name character varying(255),
    expiry_month integer,
    expiry_year integer,
    cvv_encrypted text,
    upi_id character varying(255),
    bank_account_number_encrypted text,
    bank_ifsc_code character varying(11),
    bank_name character varying(100),
    status character varying(20) DEFAULT 'active'::character varying,
    verification_status character varying(50) DEFAULT 'pending'::character varying,
    last_used_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: user_roles; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.user_roles (
    assignment_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    role_id uuid,
    assigned_by uuid,
    assigned_at timestamp without time zone DEFAULT now(),
    expires_at timestamp without time zone
);


--
-- Name: user_sessions; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.user_sessions (
    session_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    session_token text NOT NULL,
    refresh_token text,
    device_info jsonb,
    ip_address inet,
    user_agent text,
    location_info jsonb,
    expires_at timestamp without time zone NOT NULL,
    last_activity_at timestamp without time zone DEFAULT now(),
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: COLUMN user_sessions.session_token; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON COLUMN lic_schema.user_sessions.session_token IS 'JWT access token (stored as TEXT to accommodate full token length)';


--
-- Name: COLUMN user_sessions.refresh_token; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON COLUMN lic_schema.user_sessions.refresh_token IS 'JWT refresh token (stored as TEXT to accommodate full token length)';


--
-- Name: user_subscriptions; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.user_subscriptions (
    subscription_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    plan_id uuid,
    billing_cycle character varying(20) DEFAULT 'monthly'::character varying,
    status character varying(50) DEFAULT 'active'::character varying,
    current_period_start timestamp without time zone,
    current_period_end timestamp without time zone,
    trial_start timestamp without time zone,
    trial_end timestamp without time zone,
    cancel_at_period_end boolean DEFAULT false,
    canceled_at timestamp without time zone,
    stripe_subscription_id character varying(255),
    razorpay_subscription_id character varying(255),
    payment_method_id character varying(255),
    last_payment_date timestamp without time zone,
    next_payment_date timestamp without time zone,
    amount numeric(10,2),
    currency character varying(3) DEFAULT 'INR'::character varying,
    discount_amount numeric(10,2) DEFAULT 0,
    tax_amount numeric(10,2) DEFAULT 0,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by uuid,
    updated_by uuid,
    subscription_end_date timestamp without time zone
);


--
-- Name: video_analytics; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.video_analytics (
    analytics_id uuid DEFAULT gen_random_uuid() NOT NULL,
    video_id uuid,
    user_id uuid,
    watch_session_id uuid,
    started_at timestamp without time zone DEFAULT now(),
    ended_at timestamp without time zone,
    watch_duration_seconds integer,
    completed boolean DEFAULT false,
    paused_count integer DEFAULT 0,
    seek_count integer DEFAULT 0,
    quality_changes integer DEFAULT 0,
    device_info jsonb,
    network_type character varying(50),
    playback_quality character varying(20),
    ip_address inet,
    user_agent text,
    location_info jsonb,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE video_analytics; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON TABLE lic_schema.video_analytics IS 'Tracks individual video watch sessions and engagement metrics';


--
-- Name: COLUMN video_analytics.watch_session_id; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON COLUMN lic_schema.video_analytics.watch_session_id IS 'Unique identifier for a watch session (can be used to group multiple analytics records)';


--
-- Name: COLUMN video_analytics.completed; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON COLUMN lic_schema.video_analytics.completed IS 'Whether the user watched the video to completion';


--
-- Name: COLUMN video_analytics.paused_count; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON COLUMN lic_schema.video_analytics.paused_count IS 'Number of times the video was paused';


--
-- Name: COLUMN video_analytics.seek_count; Type: COMMENT; Schema: lic_schema; Owner: -
--

COMMENT ON COLUMN lic_schema.video_analytics.seek_count IS 'Number of times the user seeked/jumped in the video';


--
-- Name: video_categories; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.video_categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    category_id character varying(100) NOT NULL,
    name character varying(200) NOT NULL,
    description text,
    parent_category_id uuid,
    level integer DEFAULT 1,
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    video_count integer DEFAULT 0,
    total_views integer DEFAULT 0,
    icon_name character varying(100),
    color_code character varying(7),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: video_content; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.video_content (
    video_id uuid DEFAULT gen_random_uuid() NOT NULL,
    agent_id uuid,
    title character varying(255) NOT NULL,
    description text,
    video_url character varying(500) NOT NULL,
    thumbnail_url character varying(500),
    duration_seconds integer,
    category character varying(100),
    tags text[],
    language character varying(10) DEFAULT 'en'::character varying,
    difficulty_level character varying(20),
    target_audience text[],
    view_count integer DEFAULT 0,
    unique_viewers integer DEFAULT 0,
    avg_watch_time numeric(6,2),
    completion_rate numeric(5,2),
    engagement_rate numeric(5,2),
    average_rating numeric(3,2),
    total_ratings integer DEFAULT 0,
    featured boolean DEFAULT false,
    status character varying(50) DEFAULT 'processing'::character varying,
    moderation_status character varying(50) DEFAULT 'pending'::character varying,
    moderated_at timestamp without time zone,
    moderated_by uuid,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: video_progress; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.video_progress (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    video_id uuid NOT NULL,
    watch_time_seconds numeric(10,2) DEFAULT 0.00,
    completion_percentage numeric(5,2) DEFAULT 0.00,
    is_completed boolean DEFAULT false,
    completed_at timestamp with time zone,
    play_count integer DEFAULT 0,
    last_watched_at timestamp with time zone,
    watch_sessions jsonb,
    learning_path_id character varying(255),
    next_recommended_video_id uuid,
    user_rating integer,
    is_bookmarked boolean DEFAULT false,
    notes text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT video_progress_user_rating_check CHECK (((user_rating >= 1) AND (user_rating <= 5)))
);


--
-- Name: video_recommendations; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.video_recommendations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    video_id uuid NOT NULL,
    recommendation_type character varying(50) NOT NULL,
    trigger_source character varying(50),
    trigger_query character varying(500),
    relevance_score numeric(5,2) DEFAULT 0.00,
    confidence_score numeric(5,2) DEFAULT 0.00,
    ranking_position integer,
    intent_match_score numeric(5,2) DEFAULT 0.00,
    learning_history_score numeric(5,2) DEFAULT 0.00,
    policy_context_score numeric(5,2) DEFAULT 0.00,
    agent_expertise_score numeric(5,2) DEFAULT 0.00,
    content_freshness_score numeric(5,2) DEFAULT 0.00,
    was_viewed boolean DEFAULT false,
    viewed_at timestamp with time zone,
    was_completed boolean DEFAULT false,
    completed_at timestamp with time zone,
    user_feedback character varying(20),
    recommendation_context jsonb,
    expires_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: video_tutorials; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.video_tutorials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    video_id character varying(255) NOT NULL,
    content_id uuid NOT NULL,
    youtube_video_id character varying(50),
    youtube_url character varying(500),
    title character varying(500) NOT NULL,
    description text,
    duration_seconds integer,
    language character varying(10) DEFAULT 'en'::character varying,
    category character varying(100) NOT NULL,
    sub_category character varying(100),
    difficulty_level character varying(20) DEFAULT 'beginner'::character varying,
    target_audience jsonb,
    policy_types jsonb,
    agent_id uuid NOT NULL,
    agent_name character varying(255) NOT NULL,
    processing_status character varying(50) DEFAULT 'pending'::character varying,
    youtube_upload_status character varying(50),
    transcription_status character varying(50),
    view_count integer DEFAULT 0,
    completion_rate numeric(5,2) DEFAULT 0.00,
    average_watch_time numeric(10,2),
    engagement_score numeric(5,2) DEFAULT 0.00,
    rating numeric(3,2),
    rating_count integer DEFAULT 0,
    is_featured boolean DEFAULT false,
    learning_path_order integer,
    prerequisites jsonb,
    original_language character varying(10) DEFAULT 'en'::character varying,
    available_languages jsonb,
    translation_status character varying(50),
    search_tags jsonb,
    keywords jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_by uuid
);


--
-- Name: whatsapp_messages; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.whatsapp_messages (
    message_id uuid DEFAULT gen_random_uuid() NOT NULL,
    whatsapp_message_id character varying(255),
    sender_id uuid,
    recipient_id uuid,
    agent_id uuid,
    message_type character varying(50),
    content text,
    media_url character varying(500),
    media_type character varying(50),
    whatsapp_template_id character varying(255),
    whatsapp_template_name character varying(100),
    whatsapp_status character varying(50),
    conversation_id uuid,
    message_sequence integer,
    is_from_customer boolean DEFAULT true,
    sent_at timestamp without time zone,
    delivered_at timestamp without time zone,
    read_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: whatsapp_templates; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.whatsapp_templates (
    template_id uuid DEFAULT gen_random_uuid() NOT NULL,
    template_name character varying(100) NOT NULL,
    category character varying(50),
    language character varying(10) DEFAULT 'en'::character varying,
    content text NOT NULL,
    variables jsonb,
    approval_status character varying(50) DEFAULT 'pending'::character varying,
    whatsapp_template_id character varying(255),
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: device_tokens id; Type: DEFAULT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.device_tokens ALTER COLUMN id SET DEFAULT nextval('lic_schema.device_tokens_id_seq'::regclass);


--
-- Name: notification_settings id; Type: DEFAULT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.notification_settings ALTER COLUMN id SET DEFAULT nextval('lic_schema.notification_settings_id_seq'::regclass);


--
-- Name: agent_daily_metrics agent_daily_metrics_agent_id_metric_date_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.agent_daily_metrics
    ADD CONSTRAINT agent_daily_metrics_agent_id_metric_date_key UNIQUE (agent_id, metric_date);


--
-- Name: agent_daily_metrics agent_daily_metrics_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.agent_daily_metrics
    ADD CONSTRAINT agent_daily_metrics_pkey PRIMARY KEY (metric_id);


--
-- Name: agent_monthly_summary agent_monthly_summary_agent_id_summary_month_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.agent_monthly_summary
    ADD CONSTRAINT agent_monthly_summary_agent_id_summary_month_key UNIQUE (agent_id, summary_month);


--
-- Name: agent_monthly_summary agent_monthly_summary_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.agent_monthly_summary
    ADD CONSTRAINT agent_monthly_summary_pkey PRIMARY KEY (summary_id);


--
-- Name: agent_presentation_preferences agent_presentation_preferences_agent_id_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.agent_presentation_preferences
    ADD CONSTRAINT agent_presentation_preferences_agent_id_key UNIQUE (agent_id);


--
-- Name: agent_presentation_preferences agent_presentation_preferences_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.agent_presentation_preferences
    ADD CONSTRAINT agent_presentation_preferences_pkey PRIMARY KEY (preference_id);


--
-- Name: agents agents_agent_code_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.agents
    ADD CONSTRAINT agents_agent_code_key UNIQUE (agent_code);


--
-- Name: agents agents_license_number_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.agents
    ADD CONSTRAINT agents_license_number_key UNIQUE (license_number);


--
-- Name: agents agents_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.agents
    ADD CONSTRAINT agents_pkey PRIMARY KEY (agent_id);


--
-- Name: analytics_query_log analytics_query_log_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.analytics_query_log
    ADD CONSTRAINT analytics_query_log_pkey PRIMARY KEY (log_id);


--
-- Name: callback_activities callback_activities_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.callback_activities
    ADD CONSTRAINT callback_activities_pkey PRIMARY KEY (callback_activity_id);


--
-- Name: callback_requests callback_requests_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.callback_requests
    ADD CONSTRAINT callback_requests_pkey PRIMARY KEY (callback_request_id);


--
-- Name: campaign_executions campaign_executions_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.campaign_executions
    ADD CONSTRAINT campaign_executions_pkey PRIMARY KEY (execution_id);


--
-- Name: campaign_responses campaign_responses_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.campaign_responses
    ADD CONSTRAINT campaign_responses_pkey PRIMARY KEY (response_id);


--
-- Name: campaign_templates campaign_templates_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.campaign_templates
    ADD CONSTRAINT campaign_templates_pkey PRIMARY KEY (template_id);


--
-- Name: campaign_triggers campaign_triggers_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.campaign_triggers
    ADD CONSTRAINT campaign_triggers_pkey PRIMARY KEY (trigger_id);


--
-- Name: campaigns campaigns_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.campaigns
    ADD CONSTRAINT campaigns_pkey PRIMARY KEY (campaign_id);


--
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (message_id);


--
-- Name: chatbot_analytics_summary chatbot_analytics_summary_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.chatbot_analytics_summary
    ADD CONSTRAINT chatbot_analytics_summary_pkey PRIMARY KEY (analytics_id);


--
-- Name: chatbot_analytics_summary chatbot_analytics_summary_summary_date_summary_period_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.chatbot_analytics_summary
    ADD CONSTRAINT chatbot_analytics_summary_summary_date_summary_period_key UNIQUE (summary_date, summary_period);


--
-- Name: chatbot_intents chatbot_intents_intent_name_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.chatbot_intents
    ADD CONSTRAINT chatbot_intents_intent_name_key UNIQUE (intent_name);


--
-- Name: chatbot_intents chatbot_intents_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.chatbot_intents
    ADD CONSTRAINT chatbot_intents_pkey PRIMARY KEY (intent_id);


--
-- Name: chatbot_sessions chatbot_sessions_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.chatbot_sessions
    ADD CONSTRAINT chatbot_sessions_pkey PRIMARY KEY (session_id);


--
-- Name: commissions commissions_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.commissions
    ADD CONSTRAINT commissions_pkey PRIMARY KEY (commission_id);


--
-- Name: content content_content_id_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.content
    ADD CONSTRAINT content_content_id_key UNIQUE (content_id);


--
-- Name: content content_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.content
    ADD CONSTRAINT content_pkey PRIMARY KEY (id);


--
-- Name: countries countries_country_code_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.countries
    ADD CONSTRAINT countries_country_code_key UNIQUE (country_code);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (country_id);


--
-- Name: customer_behavior_metrics customer_behavior_metrics_customer_id_metric_date_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_behavior_metrics
    ADD CONSTRAINT customer_behavior_metrics_customer_id_metric_date_key UNIQUE (customer_id, metric_date);


--
-- Name: customer_behavior_metrics customer_behavior_metrics_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_behavior_metrics
    ADD CONSTRAINT customer_behavior_metrics_pkey PRIMARY KEY (metric_id);


--
-- Name: customer_data_mapping customer_data_mapping_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_data_mapping
    ADD CONSTRAINT customer_data_mapping_pkey PRIMARY KEY (mapping_id);


--
-- Name: customer_engagement_metrics customer_engagement_metrics_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_engagement_metrics
    ADD CONSTRAINT customer_engagement_metrics_pkey PRIMARY KEY (metric_id);


--
-- Name: customer_feedback customer_feedback_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_feedback
    ADD CONSTRAINT customer_feedback_pkey PRIMARY KEY (feedback_id);


--
-- Name: customer_journey_events customer_journey_events_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_journey_events
    ADD CONSTRAINT customer_journey_events_pkey PRIMARY KEY (event_id);


--
-- Name: customer_portal_preferences customer_portal_preferences_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_portal_preferences
    ADD CONSTRAINT customer_portal_preferences_pkey PRIMARY KEY (preference_id);


--
-- Name: customer_portal_sessions customer_portal_sessions_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_portal_sessions
    ADD CONSTRAINT customer_portal_sessions_pkey PRIMARY KEY (session_id);


--
-- Name: customer_retention_analytics customer_retention_analytics_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_retention_analytics
    ADD CONSTRAINT customer_retention_analytics_pkey PRIMARY KEY (retention_id);


--
-- Name: customer_retention_metrics customer_retention_metrics_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_retention_metrics
    ADD CONSTRAINT customer_retention_metrics_pkey PRIMARY KEY (retention_id);


--
-- Name: daily_quotes daily_quotes_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.daily_quotes
    ADD CONSTRAINT daily_quotes_pkey PRIMARY KEY (quote_id);


--
-- Name: data_export_log data_export_log_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.data_export_log
    ADD CONSTRAINT data_export_log_pkey PRIMARY KEY (export_id);


--
-- Name: data_imports data_imports_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.data_imports
    ADD CONSTRAINT data_imports_pkey PRIMARY KEY (import_id);


--
-- Name: data_sync_status data_sync_status_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.data_sync_status
    ADD CONSTRAINT data_sync_status_pkey PRIMARY KEY (sync_id);


--
-- Name: device_tokens device_tokens_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.device_tokens
    ADD CONSTRAINT device_tokens_pkey PRIMARY KEY (id);


--
-- Name: device_tokens device_tokens_token_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.device_tokens
    ADD CONSTRAINT device_tokens_token_key UNIQUE (token);


--
-- Name: document_ocr_results document_ocr_results_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.document_ocr_results
    ADD CONSTRAINT document_ocr_results_pkey PRIMARY KEY (ocr_id);


--
-- Name: emergency_contact_verifications emergency_contact_verifications_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.emergency_contact_verifications
    ADD CONSTRAINT emergency_contact_verifications_pkey PRIMARY KEY (verification_id);


--
-- Name: emergency_contacts emergency_contacts_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.emergency_contacts
    ADD CONSTRAINT emergency_contacts_pkey PRIMARY KEY (contact_id);


--
-- Name: feature_flag_overrides feature_flag_overrides_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.feature_flag_overrides
    ADD CONSTRAINT feature_flag_overrides_pkey PRIMARY KEY (override_id);


--
-- Name: feature_flags feature_flags_flag_name_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.feature_flags
    ADD CONSTRAINT feature_flags_flag_name_key UNIQUE (flag_name);


--
-- Name: feature_flags feature_flags_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.feature_flags
    ADD CONSTRAINT feature_flags_pkey PRIMARY KEY (flag_id);


--
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- Name: import_jobs import_jobs_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.import_jobs
    ADD CONSTRAINT import_jobs_pkey PRIMARY KEY (job_id);


--
-- Name: insurance_categories insurance_categories_category_code_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.insurance_categories
    ADD CONSTRAINT insurance_categories_category_code_key UNIQUE (category_code);


--
-- Name: insurance_categories insurance_categories_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.insurance_categories
    ADD CONSTRAINT insurance_categories_pkey PRIMARY KEY (category_id);


--
-- Name: insurance_policies insurance_policies_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.insurance_policies
    ADD CONSTRAINT insurance_policies_pkey PRIMARY KEY (policy_id);


--
-- Name: insurance_policies insurance_policies_policy_number_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.insurance_policies
    ADD CONSTRAINT insurance_policies_policy_number_key UNIQUE (policy_number);


--
-- Name: insurance_providers insurance_providers_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.insurance_providers
    ADD CONSTRAINT insurance_providers_pkey PRIMARY KEY (provider_id);


--
-- Name: insurance_providers insurance_providers_provider_code_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.insurance_providers
    ADD CONSTRAINT insurance_providers_provider_code_key UNIQUE (provider_code);


--
-- Name: knowledge_base_articles knowledge_base_articles_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.knowledge_base_articles
    ADD CONSTRAINT knowledge_base_articles_pkey PRIMARY KEY (article_id);


--
-- Name: knowledge_search_log knowledge_search_log_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.knowledge_search_log
    ADD CONSTRAINT knowledge_search_log_pkey PRIMARY KEY (search_id);


--
-- Name: kyc_documents kyc_documents_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.kyc_documents
    ADD CONSTRAINT kyc_documents_pkey PRIMARY KEY (document_id);


--
-- Name: kyc_manual_reviews kyc_manual_reviews_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.kyc_manual_reviews
    ADD CONSTRAINT kyc_manual_reviews_pkey PRIMARY KEY (review_id);


--
-- Name: languages languages_language_code_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.languages
    ADD CONSTRAINT languages_language_code_key UNIQUE (language_code);


--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (language_id);


--
-- Name: lead_interactions lead_interactions_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.lead_interactions
    ADD CONSTRAINT lead_interactions_pkey PRIMARY KEY (interaction_id);


--
-- Name: leads leads_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.leads
    ADD CONSTRAINT leads_pkey PRIMARY KEY (lead_id);


--
-- Name: learning_paths learning_paths_path_id_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.learning_paths
    ADD CONSTRAINT learning_paths_path_id_key UNIQUE (path_id);


--
-- Name: learning_paths learning_paths_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.learning_paths
    ADD CONSTRAINT learning_paths_pkey PRIMARY KEY (id);


--
-- Name: notification_settings notification_settings_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.notification_settings
    ADD CONSTRAINT notification_settings_pkey PRIMARY KEY (id);


--
-- Name: notification_settings notification_settings_user_id_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.notification_settings
    ADD CONSTRAINT notification_settings_user_id_key UNIQUE (user_id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_permission_name_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.permissions
    ADD CONSTRAINT permissions_permission_name_key UNIQUE (permission_name);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (permission_id);


--
-- Name: policy_analytics_summary policy_analytics_summary_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.policy_analytics_summary
    ADD CONSTRAINT policy_analytics_summary_pkey PRIMARY KEY (summary_id);


--
-- Name: policy_analytics_summary policy_analytics_summary_summary_date_summary_period_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.policy_analytics_summary
    ADD CONSTRAINT policy_analytics_summary_summary_date_summary_period_key UNIQUE (summary_date, summary_period);


--
-- Name: policyholders policyholders_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.policyholders
    ADD CONSTRAINT policyholders_pkey PRIMARY KEY (policyholder_id);


--
-- Name: predictive_insights predictive_insights_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.predictive_insights
    ADD CONSTRAINT predictive_insights_pkey PRIMARY KEY (insight_id);


--
-- Name: premium_payments premium_payments_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.premium_payments
    ADD CONSTRAINT premium_payments_pkey PRIMARY KEY (payment_id);


--
-- Name: presentation_analytics presentation_analytics_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.presentation_analytics
    ADD CONSTRAINT presentation_analytics_pkey PRIMARY KEY (analytics_id);


--
-- Name: presentation_media presentation_media_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.presentation_media
    ADD CONSTRAINT presentation_media_pkey PRIMARY KEY (media_id);


--
-- Name: presentation_slides presentation_slides_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.presentation_slides
    ADD CONSTRAINT presentation_slides_pkey PRIMARY KEY (slide_id);


--
-- Name: presentation_slides presentation_slides_presentation_id_slide_order_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.presentation_slides
    ADD CONSTRAINT presentation_slides_presentation_id_slide_order_key UNIQUE (presentation_id, slide_order);


--
-- Name: presentation_templates presentation_templates_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.presentation_templates
    ADD CONSTRAINT presentation_templates_pkey PRIMARY KEY (template_id);


--
-- Name: presentations presentations_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.presentations
    ADD CONSTRAINT presentations_pkey PRIMARY KEY (presentation_id);


--
-- Name: quote_performance quote_performance_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.quote_performance
    ADD CONSTRAINT quote_performance_pkey PRIMARY KEY (performance_id);


--
-- Name: quote_performance quote_performance_quote_id_metric_date_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.quote_performance
    ADD CONSTRAINT quote_performance_quote_id_metric_date_key UNIQUE (quote_id, metric_date);


--
-- Name: quote_sharing_analytics quote_sharing_analytics_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.quote_sharing_analytics
    ADD CONSTRAINT quote_sharing_analytics_pkey PRIMARY KEY (share_id);


--
-- Name: rbac_audit_log rbac_audit_log_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.rbac_audit_log
    ADD CONSTRAINT rbac_audit_log_pkey PRIMARY KEY (audit_id);


--
-- Name: retention_actions retention_actions_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.retention_actions
    ADD CONSTRAINT retention_actions_pkey PRIMARY KEY (action_id);


--
-- Name: revenue_forecast_scenarios revenue_forecast_scenarios_agent_id_scenario_name_forecast__key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.revenue_forecast_scenarios
    ADD CONSTRAINT revenue_forecast_scenarios_agent_id_scenario_name_forecast__key UNIQUE (agent_id, scenario_name, forecast_period);


--
-- Name: revenue_forecast_scenarios revenue_forecast_scenarios_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.revenue_forecast_scenarios
    ADD CONSTRAINT revenue_forecast_scenarios_pkey PRIMARY KEY (scenario_id);


--
-- Name: revenue_forecasts revenue_forecasts_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.revenue_forecasts
    ADD CONSTRAINT revenue_forecasts_pkey PRIMARY KEY (forecast_id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (assignment_id);


--
-- Name: role_permissions role_permissions_role_id_permission_id_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.role_permissions
    ADD CONSTRAINT role_permissions_role_id_permission_id_key UNIQUE (role_id, permission_id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role_id);


--
-- Name: roles roles_role_name_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.roles
    ADD CONSTRAINT roles_role_name_key UNIQUE (role_name);


--
-- Name: subscription_billing_history subscription_billing_history_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.subscription_billing_history
    ADD CONSTRAINT subscription_billing_history_pkey PRIMARY KEY (billing_id);


--
-- Name: subscription_changes subscription_changes_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.subscription_changes
    ADD CONSTRAINT subscription_changes_pkey PRIMARY KEY (change_id);


--
-- Name: subscription_plans subscription_plans_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.subscription_plans
    ADD CONSTRAINT subscription_plans_pkey PRIMARY KEY (plan_id);


--
-- Name: subscription_plans subscription_plans_plan_name_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.subscription_plans
    ADD CONSTRAINT subscription_plans_plan_name_key UNIQUE (plan_name);


--
-- Name: tenant_config tenant_config_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.tenant_config
    ADD CONSTRAINT tenant_config_pkey PRIMARY KEY (config_id);


--
-- Name: tenant_config tenant_config_tenant_id_config_key_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.tenant_config
    ADD CONSTRAINT tenant_config_tenant_id_config_key_key UNIQUE (tenant_id, config_key);


--
-- Name: tenant_usage tenant_usage_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.tenant_usage
    ADD CONSTRAINT tenant_usage_pkey PRIMARY KEY (usage_id);


--
-- Name: tenant_usage tenant_usage_tenant_id_metric_type_period_start_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.tenant_usage
    ADD CONSTRAINT tenant_usage_tenant_id_metric_type_period_start_key UNIQUE (tenant_id, metric_type, period_start);


--
-- Name: tenant_users tenant_users_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.tenant_users
    ADD CONSTRAINT tenant_users_pkey PRIMARY KEY (tenant_user_id);


--
-- Name: tenant_users tenant_users_tenant_id_user_id_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.tenant_users
    ADD CONSTRAINT tenant_users_tenant_id_user_id_key UNIQUE (tenant_id, user_id);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (tenant_id);


--
-- Name: tenants tenants_schema_name_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.tenants
    ADD CONSTRAINT tenants_schema_name_key UNIQUE (schema_name);


--
-- Name: tenants tenants_tenant_code_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.tenants
    ADD CONSTRAINT tenants_tenant_code_key UNIQUE (tenant_code);


--
-- Name: trial_engagement trial_engagement_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.trial_engagement
    ADD CONSTRAINT trial_engagement_pkey PRIMARY KEY (engagement_id);


--
-- Name: trial_subscriptions trial_subscriptions_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.trial_subscriptions
    ADD CONSTRAINT trial_subscriptions_pkey PRIMARY KEY (trial_id);


--
-- Name: emergency_contacts unique_primary_contact_per_user; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.emergency_contacts
    ADD CONSTRAINT unique_primary_contact_per_user EXCLUDE USING btree (user_id WITH =) WHERE ((is_primary = true));


--
-- Name: user_journeys user_journeys_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.user_journeys
    ADD CONSTRAINT user_journeys_pkey PRIMARY KEY (journey_id);


--
-- Name: user_payment_methods user_payment_methods_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.user_payment_methods
    ADD CONSTRAINT user_payment_methods_pkey PRIMARY KEY (payment_method_id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (assignment_id);


--
-- Name: user_roles user_roles_user_id_role_id_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.user_roles
    ADD CONSTRAINT user_roles_user_id_role_id_key UNIQUE (user_id, role_id);


--
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (session_id);


--
-- Name: user_sessions user_sessions_refresh_token_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.user_sessions
    ADD CONSTRAINT user_sessions_refresh_token_key UNIQUE (refresh_token);


--
-- Name: user_sessions user_sessions_session_token_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.user_sessions
    ADD CONSTRAINT user_sessions_session_token_key UNIQUE (session_token);


--
-- Name: user_subscriptions user_subscriptions_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.user_subscriptions
    ADD CONSTRAINT user_subscriptions_pkey PRIMARY KEY (subscription_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_number_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.users
    ADD CONSTRAINT users_phone_number_key UNIQUE (phone_number);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: video_analytics video_analytics_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.video_analytics
    ADD CONSTRAINT video_analytics_pkey PRIMARY KEY (analytics_id);


--
-- Name: video_categories video_categories_category_id_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.video_categories
    ADD CONSTRAINT video_categories_category_id_key UNIQUE (category_id);


--
-- Name: video_categories video_categories_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.video_categories
    ADD CONSTRAINT video_categories_pkey PRIMARY KEY (id);


--
-- Name: video_content video_content_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.video_content
    ADD CONSTRAINT video_content_pkey PRIMARY KEY (video_id);


--
-- Name: video_progress video_progress_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.video_progress
    ADD CONSTRAINT video_progress_pkey PRIMARY KEY (id);


--
-- Name: video_recommendations video_recommendations_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.video_recommendations
    ADD CONSTRAINT video_recommendations_pkey PRIMARY KEY (id);


--
-- Name: video_tutorials video_tutorials_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.video_tutorials
    ADD CONSTRAINT video_tutorials_pkey PRIMARY KEY (id);


--
-- Name: video_tutorials video_tutorials_video_id_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.video_tutorials
    ADD CONSTRAINT video_tutorials_video_id_key UNIQUE (video_id);


--
-- Name: whatsapp_messages whatsapp_messages_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.whatsapp_messages
    ADD CONSTRAINT whatsapp_messages_pkey PRIMARY KEY (message_id);


--
-- Name: whatsapp_messages whatsapp_messages_whatsapp_message_id_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.whatsapp_messages
    ADD CONSTRAINT whatsapp_messages_whatsapp_message_id_key UNIQUE (whatsapp_message_id);


--
-- Name: whatsapp_templates whatsapp_templates_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.whatsapp_templates
    ADD CONSTRAINT whatsapp_templates_pkey PRIMARY KEY (template_id);


--
-- Name: whatsapp_templates whatsapp_templates_template_name_key; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.whatsapp_templates
    ADD CONSTRAINT whatsapp_templates_template_name_key UNIQUE (template_name);


--
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX flyway_schema_history_s_idx ON lic_schema.flyway_schema_history USING btree (success);


--
-- Name: idx_agent_leaderboard_rank; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_agent_leaderboard_rank ON lic_schema.agent_leaderboard USING btree (rank_by_premium);


--
-- Name: idx_agent_metrics_agent_date; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_agent_metrics_agent_date ON lic_schema.agent_daily_metrics USING btree (agent_id, metric_date DESC);


--
-- Name: idx_agent_metrics_date; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_agent_metrics_date ON lic_schema.agent_daily_metrics USING btree (metric_date DESC);


--
-- Name: idx_agent_summary_agent_month; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_agent_summary_agent_month ON lic_schema.agent_monthly_summary USING btree (agent_id, summary_month DESC);


--
-- Name: idx_agent_summary_month; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_agent_summary_month ON lic_schema.agent_monthly_summary USING btree (summary_month DESC);


--
-- Name: idx_agents_code_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_agents_code_status ON lic_schema.agents USING btree (agent_code, status) WHERE (status = 'active'::lic_schema.agent_status_enum);


--
-- Name: idx_agents_provider; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_agents_provider ON lic_schema.agents USING btree (provider_id);


--
-- Name: idx_agents_territory; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_agents_territory ON lic_schema.agents USING btree (territory);


--
-- Name: idx_agents_user_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_agents_user_status ON lic_schema.agents USING btree (user_id, status);


--
-- Name: idx_analytics_agent; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_analytics_agent ON lic_schema.presentation_analytics USING btree (agent_id, event_timestamp DESC);


--
-- Name: idx_analytics_event_data; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_analytics_event_data ON lic_schema.presentation_analytics USING gin (event_data);


--
-- Name: idx_analytics_event_type; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_analytics_event_type ON lic_schema.presentation_analytics USING btree (event_type, event_timestamp DESC);


--
-- Name: idx_analytics_presentation; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_analytics_presentation ON lic_schema.presentation_analytics USING btree (presentation_id, event_timestamp DESC);


--
-- Name: idx_analytics_query_type; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_analytics_query_type ON lic_schema.analytics_query_log USING btree (query_type, created_at DESC);


--
-- Name: idx_analytics_query_user; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_analytics_query_user ON lic_schema.analytics_query_log USING btree (user_id, created_at DESC);


--
-- Name: idx_analytics_slide; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_analytics_slide ON lic_schema.presentation_analytics USING btree (slide_id, event_type) WHERE (slide_id IS NOT NULL);


--
-- Name: idx_billing_history_subscription; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_billing_history_subscription ON lic_schema.subscription_billing_history USING btree (subscription_id);


--
-- Name: idx_billing_history_user; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_billing_history_user ON lic_schema.subscription_billing_history USING btree (user_id);


--
-- Name: idx_callback_activities_agent; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_callback_activities_agent ON lic_schema.callback_activities USING btree (agent_id);


--
-- Name: idx_callback_activities_callback; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_callback_activities_callback ON lic_schema.callback_activities USING btree (callback_request_id);


--
-- Name: idx_callback_activities_created_at; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_callback_activities_created_at ON lic_schema.callback_activities USING btree (created_at DESC);


--
-- Name: idx_callback_activities_metadata; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_callback_activities_metadata ON lic_schema.callback_activities USING gin (metadata);


--
-- Name: idx_callback_activities_tenant_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_callback_activities_tenant_id ON lic_schema.callback_activities USING btree (tenant_id);


--
-- Name: idx_callback_requests_agent; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_callback_requests_agent ON lic_schema.callback_requests USING btree (agent_id);


--
-- Name: idx_callback_requests_created_at; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_callback_requests_created_at ON lic_schema.callback_requests USING btree (created_at DESC);


--
-- Name: idx_callback_requests_due_at; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_callback_requests_due_at ON lic_schema.callback_requests USING btree (due_at);


--
-- Name: idx_callback_requests_high_priority; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_callback_requests_high_priority ON lic_schema.callback_requests USING btree (callback_request_id) WHERE ((priority = 'high'::lic_schema.callback_priority) AND (status <> ALL (ARRAY['completed'::lic_schema.callback_status, 'cancelled'::lic_schema.callback_status])));


--
-- Name: idx_callback_requests_pending; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_callback_requests_pending ON lic_schema.callback_requests USING btree (callback_request_id) WHERE (status = 'pending'::lic_schema.callback_status);


--
-- Name: idx_callback_requests_policyholder; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_callback_requests_policyholder ON lic_schema.callback_requests USING btree (policyholder_id);


--
-- Name: idx_callback_requests_priority; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_callback_requests_priority ON lic_schema.callback_requests USING btree (priority);


--
-- Name: idx_callback_requests_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_callback_requests_status ON lic_schema.callback_requests USING btree (status);


--
-- Name: idx_callback_requests_tenant_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_callback_requests_tenant_id ON lic_schema.callback_requests USING btree (tenant_id);


--
-- Name: idx_campaign_executions_campaign; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_campaign_executions_campaign ON lic_schema.campaign_executions USING btree (campaign_id);


--
-- Name: idx_campaign_executions_personalized_content; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_campaign_executions_personalized_content ON lic_schema.campaign_executions USING gin (personalized_content);


--
-- Name: idx_campaign_executions_policyholder; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_campaign_executions_policyholder ON lic_schema.campaign_executions USING btree (policyholder_id);


--
-- Name: idx_campaign_executions_sent_at; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_campaign_executions_sent_at ON lic_schema.campaign_executions USING btree (sent_at DESC);


--
-- Name: idx_campaign_executions_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_campaign_executions_status ON lic_schema.campaign_executions USING btree (status);


--
-- Name: idx_campaign_responses_campaign; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_campaign_responses_campaign ON lic_schema.campaign_responses USING btree (campaign_id);


--
-- Name: idx_campaign_responses_execution; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_campaign_responses_execution ON lic_schema.campaign_responses USING btree (execution_id);


--
-- Name: idx_campaign_responses_type; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_campaign_responses_type ON lic_schema.campaign_responses USING btree (response_type);


--
-- Name: idx_campaign_templates_category; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_campaign_templates_category ON lic_schema.campaign_templates USING btree (category);


--
-- Name: idx_campaign_templates_public; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_campaign_templates_public ON lic_schema.campaign_templates USING btree (is_public) WHERE (is_public = true);


--
-- Name: idx_campaign_triggers_active; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_campaign_triggers_active ON lic_schema.campaign_triggers USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_campaign_triggers_campaign; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_campaign_triggers_campaign ON lic_schema.campaign_triggers USING btree (campaign_id);


--
-- Name: idx_campaigns_active; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_campaigns_active ON lic_schema.campaigns USING btree (campaign_id) WHERE (status = 'active'::lic_schema.campaign_status_enum);


--
-- Name: idx_campaigns_agent_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_campaigns_agent_status ON lic_schema.campaigns USING btree (agent_id, status);


--
-- Name: idx_campaigns_created_at; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_campaigns_created_at ON lic_schema.campaigns USING btree (created_at DESC);


--
-- Name: idx_campaigns_scheduled; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_campaigns_scheduled ON lic_schema.campaigns USING btree (scheduled_at) WHERE (scheduled_at IS NOT NULL);


--
-- Name: idx_campaigns_targeting_rules; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_campaigns_targeting_rules ON lic_schema.campaigns USING gin (targeting_rules) WHERE (targeting_rules IS NOT NULL);


--
-- Name: idx_campaigns_tenant_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_campaigns_tenant_id ON lic_schema.campaigns USING btree (tenant_id);


--
-- Name: idx_campaigns_type_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_campaigns_type_status ON lic_schema.campaigns USING btree (campaign_type, status);


--
-- Name: idx_chatbot_analytics_date; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_chatbot_analytics_date ON lic_schema.chatbot_analytics_summary USING btree (summary_date DESC);


--
-- Name: idx_chatbot_intents_active; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_chatbot_intents_active ON lic_schema.chatbot_intents USING btree (intent_name) WHERE (is_active = true);


--
-- Name: idx_chatbot_sessions_user; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_chatbot_sessions_user ON lic_schema.chatbot_sessions USING btree (user_id);


--
-- Name: idx_commissions_agent_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_commissions_agent_id ON lic_schema.commissions USING btree (agent_id);


--
-- Name: idx_commissions_payment_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_commissions_payment_id ON lic_schema.commissions USING btree (payment_id);


--
-- Name: idx_commissions_policy_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_commissions_policy_id ON lic_schema.commissions USING btree (policy_id);


--
-- Name: idx_commissions_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_commissions_status ON lic_schema.commissions USING btree (status);


--
-- Name: idx_commissions_tenant_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_commissions_tenant_id ON lic_schema.commissions USING btree (tenant_id);


--
-- Name: idx_countries_country_code; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_countries_country_code ON lic_schema.countries USING btree (country_code);


--
-- Name: idx_customer_behavior_customer; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_customer_behavior_customer ON lic_schema.customer_behavior_metrics USING btree (customer_id, metric_date DESC);


--
-- Name: idx_customer_behavior_date; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_customer_behavior_date ON lic_schema.customer_behavior_metrics USING btree (metric_date DESC);


--
-- Name: idx_customer_data_mapping_import; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_customer_data_mapping_import ON lic_schema.customer_data_mapping USING btree (import_id);


--
-- Name: idx_customer_feedback_rating; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_customer_feedback_rating ON lic_schema.customer_feedback USING btree (rating);


--
-- Name: idx_customer_feedback_resolved; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_customer_feedback_resolved ON lic_schema.customer_feedback USING btree (resolved);


--
-- Name: idx_customer_feedback_type; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_customer_feedback_type ON lic_schema.customer_feedback USING btree (feedback_type);


--
-- Name: idx_customer_feedback_user_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_customer_feedback_user_id ON lic_schema.customer_feedback USING btree (user_id);


--
-- Name: idx_customer_preferences_user_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_customer_preferences_user_id ON lic_schema.customer_portal_preferences USING btree (user_id);


--
-- Name: idx_customer_retention_agent; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_customer_retention_agent ON lic_schema.customer_retention_analytics USING btree (assigned_agent_id);


--
-- Name: idx_customer_retention_customer; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_customer_retention_customer ON lic_schema.customer_retention_analytics USING btree (customer_id);


--
-- Name: idx_customer_retention_customer_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_customer_retention_customer_id ON lic_schema.customer_retention_analytics USING btree (customer_id);


--
-- Name: idx_customer_retention_risk; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_customer_retention_risk ON lic_schema.customer_retention_analytics USING btree (risk_level, risk_score DESC);


--
-- Name: idx_customer_retention_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_customer_retention_status ON lic_schema.customer_retention_analytics USING btree (status);


--
-- Name: idx_customer_retention_updated; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_customer_retention_updated ON lic_schema.customer_retention_analytics USING btree (updated_at DESC);


--
-- Name: idx_customer_sessions_end; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_customer_sessions_end ON lic_schema.customer_portal_sessions USING btree (session_end);


--
-- Name: idx_customer_sessions_start; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_customer_sessions_start ON lic_schema.customer_portal_sessions USING btree (session_start DESC);


--
-- Name: idx_customer_sessions_user_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_customer_sessions_user_id ON lic_schema.customer_portal_sessions USING btree (user_id);


--
-- Name: idx_daily_kpis_date; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_daily_kpis_date ON lic_schema.daily_dashboard_kpis USING btree (report_date);


--
-- Name: idx_daily_quotes_active; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_daily_quotes_active ON lic_schema.daily_quotes USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_daily_quotes_agent_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_daily_quotes_agent_id ON lic_schema.daily_quotes USING btree (agent_id);


--
-- Name: idx_daily_quotes_category; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_daily_quotes_category ON lic_schema.daily_quotes USING btree (category);


--
-- Name: idx_daily_quotes_scheduled; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_daily_quotes_scheduled ON lic_schema.daily_quotes USING btree (scheduled_date);


--
-- Name: idx_data_export_user; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_data_export_user ON lic_schema.data_export_log USING btree (user_id, created_at DESC);


--
-- Name: idx_data_imports_agent_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_data_imports_agent_status ON lic_schema.data_imports USING btree (agent_id, status);


--
-- Name: idx_data_sync_status_agent; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_data_sync_status_agent ON lic_schema.data_sync_status USING btree (agent_id);


--
-- Name: idx_device_tokens_token; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_device_tokens_token ON lic_schema.device_tokens USING btree (token);


--
-- Name: idx_device_tokens_user_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_device_tokens_user_id ON lic_schema.device_tokens USING btree (user_id);


--
-- Name: idx_emergency_contacts_primary; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_emergency_contacts_primary ON lic_schema.emergency_contacts USING btree (user_id, is_primary);


--
-- Name: idx_emergency_contacts_user_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_emergency_contacts_user_id ON lic_schema.emergency_contacts USING btree (user_id);


--
-- Name: idx_emergency_contacts_verification_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_emergency_contacts_verification_status ON lic_schema.emergency_contacts USING btree (verification_status);


--
-- Name: idx_emergency_verifications_contact_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_emergency_verifications_contact_id ON lic_schema.emergency_contact_verifications USING btree (contact_id);


--
-- Name: idx_emergency_verifications_verified; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_emergency_verifications_verified ON lic_schema.emergency_contact_verifications USING btree (verified);


--
-- Name: idx_engagement_metrics_date; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_engagement_metrics_date ON lic_schema.customer_engagement_metrics USING btree (metric_date DESC);


--
-- Name: idx_engagement_metrics_user_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_engagement_metrics_user_id ON lic_schema.customer_engagement_metrics USING btree (user_id);


--
-- Name: idx_feature_flag_overrides_flag; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_feature_flag_overrides_flag ON lic_schema.feature_flag_overrides USING btree (flag_id);


--
-- Name: idx_feature_flag_overrides_role; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_feature_flag_overrides_role ON lic_schema.feature_flag_overrides USING btree (role_id);


--
-- Name: idx_feature_flag_overrides_user; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_feature_flag_overrides_user ON lic_schema.feature_flag_overrides USING btree (user_id);


--
-- Name: idx_feature_flags_name; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_feature_flags_name ON lic_schema.feature_flags USING btree (flag_name);


--
-- Name: idx_feature_flags_tenant; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_feature_flags_tenant ON lic_schema.feature_flags USING btree (tenant_id);


--
-- Name: idx_forecast_assumptions; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_forecast_assumptions ON lic_schema.revenue_forecast_scenarios USING gin (assumptions);


--
-- Name: idx_forecast_scenarios_agent; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_forecast_scenarios_agent ON lic_schema.revenue_forecast_scenarios USING btree (agent_id);


--
-- Name: idx_forecast_scenarios_type; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_forecast_scenarios_type ON lic_schema.revenue_forecast_scenarios USING btree (scenario_type, forecast_period);


--
-- Name: idx_import_jobs_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_import_jobs_status ON lic_schema.import_jobs USING btree (status);


--
-- Name: idx_insights_actions; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_insights_actions ON lic_schema.predictive_insights USING gin (recommended_actions);


--
-- Name: idx_insurance_categories_category_code; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_insurance_categories_category_code ON lic_schema.insurance_categories USING btree (category_code);


--
-- Name: idx_insurance_providers_provider_code; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_insurance_providers_provider_code ON lic_schema.insurance_providers USING btree (provider_code);


--
-- Name: idx_journey_events_session_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_journey_events_session_id ON lic_schema.customer_journey_events USING btree (session_id);


--
-- Name: idx_journey_events_timestamp; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_journey_events_timestamp ON lic_schema.customer_journey_events USING btree ("timestamp" DESC);


--
-- Name: idx_journey_events_type; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_journey_events_type ON lic_schema.customer_journey_events USING btree (event_type);


--
-- Name: idx_journey_events_user_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_journey_events_user_id ON lic_schema.customer_journey_events USING btree (user_id);


--
-- Name: idx_kb_articles_category; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_kb_articles_category ON lic_schema.knowledge_base_articles USING btree (category, is_active);


--
-- Name: idx_kb_articles_tags; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_kb_articles_tags ON lic_schema.knowledge_base_articles USING gin (tags);


--
-- Name: idx_kb_search_query; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_kb_search_query ON lic_schema.knowledge_search_log USING gin (to_tsvector('english'::regconfig, search_query));


--
-- Name: idx_kb_search_user; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_kb_search_user ON lic_schema.knowledge_search_log USING btree (user_id, created_at DESC);


--
-- Name: idx_kyc_documents_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_kyc_documents_status ON lic_schema.kyc_documents USING btree (verification_status);


--
-- Name: idx_kyc_documents_type; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_kyc_documents_type ON lic_schema.kyc_documents USING btree (document_type);


--
-- Name: idx_kyc_documents_user_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_kyc_documents_user_id ON lic_schema.kyc_documents USING btree (user_id);


--
-- Name: idx_languages_language_code; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_languages_language_code ON lic_schema.languages USING btree (language_code);


--
-- Name: idx_lead_interactions_agent; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_lead_interactions_agent ON lic_schema.lead_interactions USING btree (agent_id);


--
-- Name: idx_lead_interactions_created; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_lead_interactions_created ON lic_schema.lead_interactions USING btree (created_at DESC);


--
-- Name: idx_lead_interactions_lead; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_lead_interactions_lead ON lic_schema.lead_interactions USING btree (lead_id);


--
-- Name: idx_leads_agent_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_leads_agent_status ON lic_schema.leads USING btree (agent_id, lead_status);


--
-- Name: idx_leads_converted_policy_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_leads_converted_policy_id ON lic_schema.leads USING btree (converted_policy_id);


--
-- Name: idx_leads_created_at; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_leads_created_at ON lic_schema.leads USING btree (created_at DESC);


--
-- Name: idx_leads_next_followup; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_leads_next_followup ON lic_schema.leads USING btree (next_followup_at) WHERE (next_followup_at IS NOT NULL);


--
-- Name: idx_leads_priority_score; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_leads_priority_score ON lic_schema.leads USING btree (priority, conversion_score DESC);


--
-- Name: idx_leads_risk_factors; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_leads_risk_factors ON lic_schema.customer_retention_analytics USING gin (risk_factors);


--
-- Name: idx_leads_source_type; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_leads_source_type ON lic_schema.leads USING btree (lead_source, insurance_type);


--
-- Name: idx_learning_paths_active; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_learning_paths_active ON lic_schema.learning_paths USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_learning_paths_agent; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_learning_paths_agent ON lic_schema.learning_paths USING btree (created_by_agent_id);


--
-- Name: idx_learning_paths_path_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_learning_paths_path_id ON lic_schema.learning_paths USING btree (path_id);


--
-- Name: idx_manual_reviews_document_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_manual_reviews_document_id ON lic_schema.kyc_manual_reviews USING btree (document_id);


--
-- Name: idx_manual_reviews_reviewer_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_manual_reviews_reviewer_id ON lic_schema.kyc_manual_reviews USING btree (reviewer_id);


--
-- Name: idx_manual_reviews_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_manual_reviews_status ON lic_schema.kyc_manual_reviews USING btree (review_status);


--
-- Name: idx_media_agent_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_media_agent_status ON lic_schema.presentation_media USING btree (agent_id, status);


--
-- Name: idx_media_hash; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_media_hash ON lic_schema.presentation_media USING btree (file_hash) WHERE (file_hash IS NOT NULL);


--
-- Name: idx_media_type; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_media_type ON lic_schema.presentation_media USING btree (media_type);


--
-- Name: idx_notification_settings_user_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_notification_settings_user_id ON lic_schema.notification_settings USING btree (user_id);


--
-- Name: idx_notifications_created_at; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_notifications_created_at ON lic_schema.notifications USING btree (created_at DESC);


--
-- Name: idx_notifications_is_read; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_notifications_is_read ON lic_schema.notifications USING btree (is_read);


--
-- Name: idx_notifications_tenant_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_notifications_tenant_id ON lic_schema.notifications USING btree (tenant_id);


--
-- Name: idx_notifications_type; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_notifications_type ON lic_schema.notifications USING btree (type);


--
-- Name: idx_notifications_user_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_notifications_user_id ON lic_schema.notifications USING btree (user_id);


--
-- Name: idx_notifications_user_read; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_notifications_user_read ON lic_schema.notifications USING btree (user_id, is_read);


--
-- Name: idx_ocr_results_document_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_ocr_results_document_id ON lic_schema.document_ocr_results USING btree (document_id);


--
-- Name: idx_ocr_results_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_ocr_results_status ON lic_schema.document_ocr_results USING btree (processing_status);


--
-- Name: idx_payments_date_amount; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_payments_date_amount ON lic_schema.premium_payments USING btree (payment_date DESC, amount);


--
-- Name: idx_payments_policy_date; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_payments_policy_date ON lic_schema.premium_payments USING btree (policy_id, payment_date DESC);


--
-- Name: idx_payments_policy_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_payments_policy_status ON lic_schema.premium_payments USING btree (policy_id, status);


--
-- Name: idx_payments_status_date; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_payments_status_date ON lic_schema.premium_payments USING btree (status, payment_date DESC) WHERE (status = 'completed'::lic_schema.payment_status_enum);


--
-- Name: idx_policies_agent_provider; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_policies_agent_provider ON lic_schema.insurance_policies USING btree (agent_id, provider_id);


--
-- Name: idx_policies_dates_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_policies_dates_status ON lic_schema.insurance_policies USING btree (start_date, maturity_date, status) WHERE (status = ANY (ARRAY['active'::lic_schema.policy_status_enum, 'pending_approval'::lic_schema.policy_status_enum]));


--
-- Name: idx_policies_policyholder_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_policies_policyholder_status ON lic_schema.insurance_policies USING btree (policyholder_id, status);


--
-- Name: idx_policies_status_dates; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_policies_status_dates ON lic_schema.insurance_policies USING btree (status, start_date, maturity_date);


--
-- Name: idx_policy_analytics_date; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_policy_analytics_date ON lic_schema.policy_analytics_summary USING btree (summary_date DESC);


--
-- Name: idx_policy_analytics_period; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_policy_analytics_period ON lic_schema.policy_analytics_summary USING btree (summary_period, summary_date DESC);


--
-- Name: idx_predictive_insights_agent; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_predictive_insights_agent ON lic_schema.predictive_insights USING btree (agent_id);


--
-- Name: idx_predictive_insights_customer; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_predictive_insights_customer ON lic_schema.predictive_insights USING btree (customer_id);


--
-- Name: idx_predictive_insights_type; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_predictive_insights_type ON lic_schema.predictive_insights USING btree (insight_type);


--
-- Name: idx_predictive_insights_valid; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_predictive_insights_valid ON lic_schema.predictive_insights USING btree (valid_until) WHERE (valid_until IS NOT NULL);


--
-- Name: idx_presentation_media_tenant_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_presentation_media_tenant_id ON lic_schema.presentation_media USING btree (tenant_id);


--
-- Name: idx_presentations_active; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_presentations_active ON lic_schema.presentations USING btree (agent_id, is_active) WHERE (is_active = true);


--
-- Name: idx_presentations_agent_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_presentations_agent_status ON lic_schema.presentations USING btree (agent_id, status);


--
-- Name: idx_presentations_published; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_presentations_published ON lic_schema.presentations USING btree (published_at DESC) WHERE ((status)::text = 'published'::text);


--
-- Name: idx_presentations_template; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_presentations_template ON lic_schema.presentations USING btree (template_id) WHERE (template_id IS NOT NULL);


--
-- Name: idx_presentations_tenant_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_presentations_tenant_id ON lic_schema.presentations USING btree (tenant_id);


--
-- Name: idx_quote_performance_agent_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_quote_performance_agent_id ON lic_schema.quote_performance USING btree (agent_id);


--
-- Name: idx_quote_performance_date; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_quote_performance_date ON lic_schema.quote_performance USING btree (metric_date);


--
-- Name: idx_quote_performance_quote_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_quote_performance_quote_id ON lic_schema.quote_performance USING btree (quote_id);


--
-- Name: idx_quote_sharing_agent_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_quote_sharing_agent_id ON lic_schema.quote_sharing_analytics USING btree (agent_id);


--
-- Name: idx_quote_sharing_analytics_agent_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_quote_sharing_analytics_agent_id ON lic_schema.quote_sharing_analytics USING btree (agent_id);


--
-- Name: idx_quote_sharing_analytics_quote_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_quote_sharing_analytics_quote_id ON lic_schema.quote_sharing_analytics USING btree (quote_id);


--
-- Name: idx_quote_sharing_platform; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_quote_sharing_platform ON lic_schema.quote_sharing_analytics USING btree (platform);


--
-- Name: idx_quote_sharing_quote_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_quote_sharing_quote_id ON lic_schema.quote_sharing_analytics USING btree (quote_id);


--
-- Name: idx_rbac_audit_action; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_rbac_audit_action ON lic_schema.rbac_audit_log USING btree (action);


--
-- Name: idx_rbac_audit_target_user; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_rbac_audit_target_user ON lic_schema.rbac_audit_log USING btree (target_user_id);


--
-- Name: idx_rbac_audit_tenant_timestamp; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_rbac_audit_tenant_timestamp ON lic_schema.rbac_audit_log USING btree (tenant_id, "timestamp");


--
-- Name: idx_rbac_audit_timestamp; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_rbac_audit_timestamp ON lic_schema.rbac_audit_log USING btree ("timestamp" DESC);


--
-- Name: idx_rbac_audit_user; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_rbac_audit_user ON lic_schema.rbac_audit_log USING btree (user_id);


--
-- Name: idx_retention_actions_agent; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_retention_actions_agent ON lic_schema.retention_actions USING btree (agent_id);


--
-- Name: idx_retention_actions_due; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_retention_actions_due ON lic_schema.retention_actions USING btree (due_at);


--
-- Name: idx_retention_actions_retention; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_retention_actions_retention ON lic_schema.retention_actions USING btree (retention_id);


--
-- Name: idx_retention_actions_scheduled; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_retention_actions_scheduled ON lic_schema.retention_actions USING btree (scheduled_at);


--
-- Name: idx_retention_metrics_churn_risk; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_retention_metrics_churn_risk ON lic_schema.customer_retention_metrics USING btree (churn_risk_score DESC);


--
-- Name: idx_retention_metrics_date; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_retention_metrics_date ON lic_schema.customer_retention_metrics USING btree (metric_date DESC);


--
-- Name: idx_retention_metrics_user_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_retention_metrics_user_id ON lic_schema.customer_retention_metrics USING btree (user_id);


--
-- Name: idx_retention_plan; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_retention_plan ON lic_schema.customer_retention_analytics USING gin (retention_plan);


--
-- Name: idx_revenue_forecast_agent; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_revenue_forecast_agent ON lic_schema.revenue_forecasts USING btree (agent_id, forecast_date DESC);


--
-- Name: idx_revenue_forecast_date; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_revenue_forecast_date ON lic_schema.revenue_forecasts USING btree (forecast_date DESC);


--
-- Name: idx_slides_agent_branding; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_slides_agent_branding ON lic_schema.presentation_slides USING gin (agent_branding) WHERE (agent_branding IS NOT NULL);


--
-- Name: idx_slides_cta_button; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_slides_cta_button ON lic_schema.presentation_slides USING gin (cta_button) WHERE (cta_button IS NOT NULL);


--
-- Name: idx_slides_presentation_order; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_slides_presentation_order ON lic_schema.presentation_slides USING btree (presentation_id, slide_order);


--
-- Name: idx_slides_type; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_slides_type ON lic_schema.presentation_slides USING btree (slide_type);


--
-- Name: idx_subscription_changes_subscription; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_subscription_changes_subscription ON lic_schema.subscription_changes USING btree (subscription_id);


--
-- Name: idx_subscription_changes_subscription_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_subscription_changes_subscription_id ON lic_schema.subscription_changes USING btree (subscription_id);


--
-- Name: idx_subscription_changes_user_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_subscription_changes_user_id ON lic_schema.subscription_changes USING btree (user_id);


--
-- Name: idx_subscription_plans_active; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_subscription_plans_active ON lic_schema.subscription_plans USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_subscription_plans_type; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_subscription_plans_type ON lic_schema.subscription_plans USING btree (plan_type);


--
-- Name: idx_templates_category_public; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_templates_category_public ON lic_schema.presentation_templates USING btree (category, is_public) WHERE (is_public = true);


--
-- Name: idx_templates_slides; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_templates_slides ON lic_schema.presentation_templates USING gin (slides);


--
-- Name: idx_templates_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_templates_status ON lic_schema.presentation_templates USING btree (status) WHERE ((status)::text = 'active'::text);


--
-- Name: idx_tenant_config_tenant_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_tenant_config_tenant_id ON lic_schema.tenant_config USING btree (tenant_id);


--
-- Name: idx_tenant_usage_metric; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_tenant_usage_metric ON lic_schema.tenant_usage USING btree (metric_type, period_start);


--
-- Name: idx_tenant_usage_tenant_period; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_tenant_usage_tenant_period ON lic_schema.tenant_usage USING btree (tenant_id, period_start, period_end);


--
-- Name: idx_tenant_users_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_tenant_users_status ON lic_schema.tenant_users USING btree (status);


--
-- Name: idx_tenant_users_tenant_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_tenant_users_tenant_id ON lic_schema.tenant_users USING btree (tenant_id);


--
-- Name: idx_tenant_users_user_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_tenant_users_user_id ON lic_schema.tenant_users USING btree (user_id);


--
-- Name: idx_tenants_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_tenants_status ON lic_schema.tenants USING btree (status);


--
-- Name: idx_tenants_tenant_code; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_tenants_tenant_code ON lic_schema.tenants USING btree (tenant_code);


--
-- Name: idx_trial_engagement_created_by; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_trial_engagement_created_by ON lic_schema.trial_engagement USING btree (created_by);


--
-- Name: idx_trial_engagement_feature; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_trial_engagement_feature ON lic_schema.trial_engagement USING btree (feature_used);


--
-- Name: idx_trial_engagement_timestamp; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_trial_engagement_timestamp ON lic_schema.trial_engagement USING btree (engaged_at);


--
-- Name: idx_trial_engagement_trial_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_trial_engagement_trial_id ON lic_schema.trial_engagement USING btree (trial_id);


--
-- Name: idx_trial_engagement_type; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_trial_engagement_type ON lic_schema.trial_engagement USING btree (engagement_type);


--
-- Name: idx_trial_engagement_updated_at; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_trial_engagement_updated_at ON lic_schema.trial_engagement USING btree (updated_at);


--
-- Name: idx_trial_engagement_updated_by; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_trial_engagement_updated_by ON lic_schema.trial_engagement USING btree (updated_by);


--
-- Name: idx_trial_subscriptions_created_by; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_trial_subscriptions_created_by ON lic_schema.trial_subscriptions USING btree (created_by);


--
-- Name: idx_trial_subscriptions_end_date; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_trial_subscriptions_end_date ON lic_schema.trial_subscriptions USING btree (trial_end_date);


--
-- Name: idx_trial_subscriptions_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_trial_subscriptions_status ON lic_schema.trial_subscriptions USING btree (trial_status);


--
-- Name: idx_trial_subscriptions_updated_at; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_trial_subscriptions_updated_at ON lic_schema.trial_subscriptions USING btree (updated_at);


--
-- Name: idx_trial_subscriptions_updated_by; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_trial_subscriptions_updated_by ON lic_schema.trial_subscriptions USING btree (updated_by);


--
-- Name: idx_trial_subscriptions_user_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_trial_subscriptions_user_id ON lic_schema.trial_subscriptions USING btree (user_id);


--
-- Name: idx_user_journeys_converted; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_user_journeys_converted ON lic_schema.user_journeys USING btree (converted, journey_type) WHERE (converted = true);


--
-- Name: idx_user_journeys_journey_data; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_user_journeys_journey_data ON lic_schema.user_journeys USING gin (journey_data) WHERE (journey_data IS NOT NULL);


--
-- Name: idx_user_journeys_started_at; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_user_journeys_started_at ON lic_schema.user_journeys USING btree (started_at DESC);


--
-- Name: idx_user_journeys_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_user_journeys_status ON lic_schema.user_journeys USING btree (status) WHERE ((status)::text = 'active'::text);


--
-- Name: idx_user_journeys_step_history; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_user_journeys_step_history ON lic_schema.user_journeys USING gin (step_history) WHERE (step_history IS NOT NULL);


--
-- Name: idx_user_journeys_type_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_user_journeys_type_status ON lic_schema.user_journeys USING btree (journey_type, status);


--
-- Name: idx_user_journeys_user_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_user_journeys_user_id ON lic_schema.user_journeys USING btree (user_id);


--
-- Name: idx_user_sessions_active; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_user_sessions_active ON lic_schema.user_sessions USING btree (user_id, expires_at DESC);


--
-- Name: idx_user_sessions_token; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_user_sessions_token ON lic_schema.user_sessions USING btree (session_token);


--
-- Name: idx_user_subscriptions_end; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_user_subscriptions_end ON lic_schema.user_subscriptions USING btree (current_period_end);


--
-- Name: idx_user_subscriptions_plan; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_user_subscriptions_plan ON lic_schema.user_subscriptions USING btree (plan_id);


--
-- Name: idx_user_subscriptions_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_user_subscriptions_status ON lic_schema.user_subscriptions USING btree (status);


--
-- Name: idx_user_subscriptions_user; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_user_subscriptions_user ON lic_schema.user_subscriptions USING btree (user_id);


--
-- Name: idx_user_subscriptions_user_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_user_subscriptions_user_id ON lic_schema.user_subscriptions USING btree (user_id);


--
-- Name: idx_users_created_at; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_users_created_at ON lic_schema.users USING btree (created_at DESC);


--
-- Name: idx_users_email; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_users_email ON lic_schema.users USING btree (email) WHERE (email IS NOT NULL);


--
-- Name: idx_users_phone; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_users_phone ON lic_schema.users USING btree (phone_number) WHERE (phone_number IS NOT NULL);


--
-- Name: idx_users_phone_verified; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_users_phone_verified ON lic_schema.users USING btree (phone_number, phone_verified) WHERE (phone_verified = true);


--
-- Name: idx_users_role_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_users_role_status ON lic_schema.users USING btree (role, status) WHERE (status = 'active'::lic_schema.user_status_enum);


--
-- Name: idx_users_tenant_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_users_tenant_status ON lic_schema.users USING btree (tenant_id, status);


--
-- Name: idx_video_analytics_completed; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_analytics_completed ON lic_schema.video_analytics USING btree (completed, video_id);


--
-- Name: idx_video_analytics_started_at; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_analytics_started_at ON lic_schema.video_analytics USING btree (started_at DESC);


--
-- Name: idx_video_analytics_user_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_analytics_user_id ON lic_schema.video_analytics USING btree (user_id);


--
-- Name: idx_video_analytics_video_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_analytics_video_id ON lic_schema.video_analytics USING btree (video_id);


--
-- Name: idx_video_analytics_watch_session; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_analytics_watch_session ON lic_schema.video_analytics USING btree (watch_session_id) WHERE (watch_session_id IS NOT NULL);


--
-- Name: idx_video_categories_active; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_categories_active ON lic_schema.video_categories USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_video_categories_category_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_categories_category_id ON lic_schema.video_categories USING btree (category_id);


--
-- Name: idx_video_categories_parent; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_categories_parent ON lic_schema.video_categories USING btree (parent_category_id);


--
-- Name: idx_video_content_agent; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_content_agent ON lic_schema.video_content USING btree (agent_id);


--
-- Name: idx_video_progress_completed; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_progress_completed ON lic_schema.video_progress USING btree (is_completed) WHERE (is_completed = true);


--
-- Name: idx_video_progress_last_watched; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_progress_last_watched ON lic_schema.video_progress USING btree (last_watched_at DESC);


--
-- Name: idx_video_progress_user_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_progress_user_id ON lic_schema.video_progress USING btree (user_id);


--
-- Name: idx_video_progress_user_video; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_progress_user_video ON lic_schema.video_progress USING btree (user_id, video_id);


--
-- Name: idx_video_progress_video_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_progress_video_id ON lic_schema.video_progress USING btree (video_id);


--
-- Name: idx_video_recommendations_relevance; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_recommendations_relevance ON lic_schema.video_recommendations USING btree (relevance_score DESC);


--
-- Name: idx_video_recommendations_type; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_recommendations_type ON lic_schema.video_recommendations USING btree (recommendation_type);


--
-- Name: idx_video_recommendations_user_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_recommendations_user_id ON lic_schema.video_recommendations USING btree (user_id);


--
-- Name: idx_video_recommendations_user_video; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_recommendations_user_video ON lic_schema.video_recommendations USING btree (user_id, video_id);


--
-- Name: idx_video_recommendations_video_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_recommendations_video_id ON lic_schema.video_recommendations USING btree (video_id);


--
-- Name: idx_video_tutorials_agent_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_tutorials_agent_id ON lic_schema.video_tutorials USING btree (agent_id);


--
-- Name: idx_video_tutorials_category; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_tutorials_category ON lic_schema.video_tutorials USING btree (category);


--
-- Name: idx_video_tutorials_created_at; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_tutorials_created_at ON lic_schema.video_tutorials USING btree (created_at DESC);


--
-- Name: idx_video_tutorials_featured; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_tutorials_featured ON lic_schema.video_tutorials USING btree (is_featured) WHERE (is_featured = true);


--
-- Name: idx_video_tutorials_language; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_tutorials_language ON lic_schema.video_tutorials USING btree (language);


--
-- Name: idx_video_tutorials_processing_status; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_tutorials_processing_status ON lic_schema.video_tutorials USING btree (processing_status);


--
-- Name: idx_video_tutorials_search_description; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_tutorials_search_description ON lic_schema.video_tutorials USING gin (to_tsvector('english'::regconfig, description));


--
-- Name: idx_video_tutorials_search_tags; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_tutorials_search_tags ON lic_schema.video_tutorials USING gin (search_tags);


--
-- Name: idx_video_tutorials_search_title; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_tutorials_search_title ON lic_schema.video_tutorials USING gin (to_tsvector('english'::regconfig, (title)::text));


--
-- Name: idx_video_tutorials_video_id; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_tutorials_video_id ON lic_schema.video_tutorials USING btree (video_id);


--
-- Name: idx_whatsapp_messages_agent; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_whatsapp_messages_agent ON lic_schema.whatsapp_messages USING btree (agent_id);


--
-- Name: agents audit_agents_changes; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER audit_agents_changes AFTER INSERT OR DELETE OR UPDATE ON lic_schema.agents FOR EACH ROW EXECUTE FUNCTION lic_schema.audit_tenant_data_changes();


--
-- Name: insurance_policies audit_policies_changes; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER audit_policies_changes AFTER INSERT OR DELETE OR UPDATE ON lic_schema.insurance_policies FOR EACH ROW EXECUTE FUNCTION lic_schema.audit_tenant_data_changes();


--
-- Name: agents audit_tenant_data_changes_trigger; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER audit_tenant_data_changes_trigger AFTER INSERT OR DELETE OR UPDATE ON lic_schema.agents FOR EACH ROW EXECUTE FUNCTION lic_schema.audit_tenant_data_changes();


--
-- Name: insurance_policies audit_tenant_data_changes_trigger; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER audit_tenant_data_changes_trigger AFTER INSERT OR DELETE OR UPDATE ON lic_schema.insurance_policies FOR EACH ROW EXECUTE FUNCTION lic_schema.audit_tenant_data_changes();


--
-- Name: policyholders audit_tenant_data_changes_trigger; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER audit_tenant_data_changes_trigger AFTER INSERT OR DELETE OR UPDATE ON lic_schema.policyholders FOR EACH ROW EXECUTE FUNCTION lic_schema.audit_tenant_data_changes();


--
-- Name: users audit_tenant_data_changes_trigger; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER audit_tenant_data_changes_trigger AFTER INSERT OR DELETE OR UPDATE ON lic_schema.users FOR EACH ROW EXECUTE FUNCTION lic_schema.audit_tenant_data_changes();


--
-- Name: presentation_analytics presentation_analytics_summary_trigger; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER presentation_analytics_summary_trigger AFTER INSERT ON lic_schema.presentation_analytics FOR EACH ROW EXECUTE FUNCTION lic_schema.update_presentation_analytics_summary();


--
-- Name: presentation_slides slide_media_usage_trigger; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER slide_media_usage_trigger AFTER INSERT OR UPDATE ON lic_schema.presentation_slides FOR EACH ROW EXECUTE FUNCTION lic_schema.increment_media_usage();


--
-- Name: trial_subscriptions trigger_set_trial_end_date; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER trigger_set_trial_end_date BEFORE INSERT ON lic_schema.trial_subscriptions FOR EACH ROW EXECUTE FUNCTION lic_schema.set_trial_end_date();


--
-- Name: customer_portal_preferences trigger_update_customer_preferences_updated_at; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER trigger_update_customer_preferences_updated_at BEFORE UPDATE ON lic_schema.customer_portal_preferences FOR EACH ROW EXECUTE FUNCTION lic_schema.update_customer_preferences_updated_at();


--
-- Name: daily_quotes trigger_update_daily_quotes_updated_at; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER trigger_update_daily_quotes_updated_at BEFORE UPDATE ON lic_schema.daily_quotes FOR EACH ROW EXECUTE FUNCTION lic_schema.update_daily_quotes_updated_at();


--
-- Name: device_tokens trigger_update_device_tokens_last_used_at; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER trigger_update_device_tokens_last_used_at BEFORE UPDATE ON lic_schema.device_tokens FOR EACH ROW EXECUTE FUNCTION lic_schema.update_device_tokens_last_used_at();


--
-- Name: emergency_contacts trigger_update_emergency_contacts_updated_at; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER trigger_update_emergency_contacts_updated_at BEFORE UPDATE ON lic_schema.emergency_contacts FOR EACH ROW EXECUTE FUNCTION lic_schema.update_emergency_contacts_updated_at();


--
-- Name: kyc_documents trigger_update_kyc_documents_updated_at; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER trigger_update_kyc_documents_updated_at BEFORE UPDATE ON lic_schema.kyc_documents FOR EACH ROW EXECUTE FUNCTION lic_schema.update_kyc_documents_updated_at();


--
-- Name: notification_settings trigger_update_notification_settings_updated_at; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER trigger_update_notification_settings_updated_at BEFORE UPDATE ON lic_schema.notification_settings FOR EACH ROW EXECUTE FUNCTION lic_schema.update_notification_settings_updated_at();


--
-- Name: subscription_plans trigger_update_subscription_plans_updated_at; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER trigger_update_subscription_plans_updated_at BEFORE UPDATE ON lic_schema.subscription_plans FOR EACH ROW EXECUTE FUNCTION lic_schema.update_subscription_plans_updated_at();


--
-- Name: trial_engagement trigger_update_trial_engagement_updated_at; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER trigger_update_trial_engagement_updated_at BEFORE UPDATE ON lic_schema.trial_engagement FOR EACH ROW EXECUTE FUNCTION lic_schema.update_trial_engagement_updated_at();


--
-- Name: trial_subscriptions trigger_update_trial_status; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER trigger_update_trial_status BEFORE UPDATE ON lic_schema.trial_subscriptions FOR EACH ROW EXECUTE FUNCTION lic_schema.update_trial_status();


--
-- Name: trial_subscriptions trigger_update_trial_subscription_updated_at; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER trigger_update_trial_subscription_updated_at BEFORE UPDATE ON lic_schema.trial_subscriptions FOR EACH ROW EXECUTE FUNCTION lic_schema.update_trial_subscription_updated_at();


--
-- Name: user_subscriptions trigger_update_user_subscriptions_updated_at; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER trigger_update_user_subscriptions_updated_at BEFORE UPDATE ON lic_schema.user_subscriptions FOR EACH ROW EXECUTE FUNCTION lic_schema.update_user_subscriptions_updated_at();


--
-- Name: insurance_policies update_agent_metrics_trigger; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER update_agent_metrics_trigger AFTER INSERT OR DELETE OR UPDATE ON lic_schema.insurance_policies FOR EACH ROW EXECUTE FUNCTION lic_schema.update_agent_daily_metrics();


--
-- Name: customer_retention_analytics update_customer_risk_on_change; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER update_customer_risk_on_change BEFORE INSERT OR UPDATE ON lic_schema.customer_retention_analytics FOR EACH ROW EXECUTE FUNCTION lic_schema.update_customer_retention_trigger();


--
-- Name: leads update_lead_score_on_change; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER update_lead_score_on_change BEFORE INSERT OR UPDATE ON lic_schema.leads FOR EACH ROW EXECUTE FUNCTION lic_schema.update_lead_score_trigger();


--
-- Name: learning_paths update_learning_paths_updated_at; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER update_learning_paths_updated_at BEFORE UPDATE ON lic_schema.learning_paths FOR EACH ROW EXECUTE FUNCTION lic_schema.update_updated_at_column();


--
-- Name: video_categories update_video_categories_updated_at; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER update_video_categories_updated_at BEFORE UPDATE ON lic_schema.video_categories FOR EACH ROW EXECUTE FUNCTION lic_schema.update_updated_at_column();


--
-- Name: video_progress update_video_progress_updated_at; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER update_video_progress_updated_at BEFORE UPDATE ON lic_schema.video_progress FOR EACH ROW EXECUTE FUNCTION lic_schema.update_updated_at_column();


--
-- Name: video_recommendations update_video_recommendations_updated_at; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER update_video_recommendations_updated_at BEFORE UPDATE ON lic_schema.video_recommendations FOR EACH ROW EXECUTE FUNCTION lic_schema.update_updated_at_column();


--
-- Name: video_tutorials update_video_tutorials_updated_at; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER update_video_tutorials_updated_at BEFORE UPDATE ON lic_schema.video_tutorials FOR EACH ROW EXECUTE FUNCTION lic_schema.update_updated_at_column();


--
-- Name: agent_daily_metrics agent_daily_metrics_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.agent_daily_metrics
    ADD CONSTRAINT agent_daily_metrics_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: agent_monthly_summary agent_monthly_summary_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.agent_monthly_summary
    ADD CONSTRAINT agent_monthly_summary_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: agent_presentation_preferences agent_presentation_preferences_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.agent_presentation_preferences
    ADD CONSTRAINT agent_presentation_preferences_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: agents agents_approved_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.agents
    ADD CONSTRAINT agents_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES lic_schema.users(user_id);


--
-- Name: agents agents_parent_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.agents
    ADD CONSTRAINT agents_parent_agent_id_fkey FOREIGN KEY (parent_agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: agents agents_provider_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.agents
    ADD CONSTRAINT agents_provider_id_fkey FOREIGN KEY (provider_id) REFERENCES lic_schema.insurance_providers(provider_id);


--
-- Name: agents agents_tenant_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.agents
    ADD CONSTRAINT agents_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES lic_schema.tenants(tenant_id);


--
-- Name: agents agents_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.agents
    ADD CONSTRAINT agents_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: analytics_query_log analytics_query_log_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.analytics_query_log
    ADD CONSTRAINT analytics_query_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id);


--
-- Name: callback_activities callback_activities_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.callback_activities
    ADD CONSTRAINT callback_activities_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: callback_activities callback_activities_callback_request_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.callback_activities
    ADD CONSTRAINT callback_activities_callback_request_id_fkey FOREIGN KEY (callback_request_id) REFERENCES lic_schema.callback_requests(callback_request_id) ON DELETE CASCADE;


--
-- Name: callback_activities callback_activities_tenant_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.callback_activities
    ADD CONSTRAINT callback_activities_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES lic_schema.tenants(tenant_id);


--
-- Name: callback_requests callback_requests_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.callback_requests
    ADD CONSTRAINT callback_requests_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: callback_requests callback_requests_assigned_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.callback_requests
    ADD CONSTRAINT callback_requests_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES lic_schema.users(user_id);


--
-- Name: callback_requests callback_requests_completed_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.callback_requests
    ADD CONSTRAINT callback_requests_completed_by_fkey FOREIGN KEY (completed_by) REFERENCES lic_schema.users(user_id);


--
-- Name: callback_requests callback_requests_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.callback_requests
    ADD CONSTRAINT callback_requests_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: callback_requests callback_requests_last_updated_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.callback_requests
    ADD CONSTRAINT callback_requests_last_updated_by_fkey FOREIGN KEY (last_updated_by) REFERENCES lic_schema.users(user_id);


--
-- Name: callback_requests callback_requests_policyholder_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.callback_requests
    ADD CONSTRAINT callback_requests_policyholder_id_fkey FOREIGN KEY (policyholder_id) REFERENCES lic_schema.policyholders(policyholder_id);


--
-- Name: campaign_executions campaign_executions_campaign_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.campaign_executions
    ADD CONSTRAINT campaign_executions_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES lic_schema.campaigns(campaign_id) ON DELETE CASCADE;


--
-- Name: campaign_executions campaign_executions_policyholder_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.campaign_executions
    ADD CONSTRAINT campaign_executions_policyholder_id_fkey FOREIGN KEY (policyholder_id) REFERENCES lic_schema.policyholders(policyholder_id);


--
-- Name: campaign_responses campaign_responses_campaign_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.campaign_responses
    ADD CONSTRAINT campaign_responses_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES lic_schema.campaigns(campaign_id);


--
-- Name: campaign_responses campaign_responses_execution_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.campaign_responses
    ADD CONSTRAINT campaign_responses_execution_id_fkey FOREIGN KEY (execution_id) REFERENCES lic_schema.campaign_executions(execution_id) ON DELETE CASCADE;


--
-- Name: campaign_responses campaign_responses_policyholder_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.campaign_responses
    ADD CONSTRAINT campaign_responses_policyholder_id_fkey FOREIGN KEY (policyholder_id) REFERENCES lic_schema.policyholders(policyholder_id);


--
-- Name: campaign_templates campaign_templates_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.campaign_templates
    ADD CONSTRAINT campaign_templates_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: campaign_triggers campaign_triggers_campaign_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.campaign_triggers
    ADD CONSTRAINT campaign_triggers_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES lic_schema.campaigns(campaign_id) ON DELETE CASCADE;


--
-- Name: campaigns campaigns_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.campaigns
    ADD CONSTRAINT campaigns_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id) ON DELETE CASCADE;


--
-- Name: campaigns campaigns_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.campaigns
    ADD CONSTRAINT campaigns_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: campaigns campaigns_tenant_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.campaigns
    ADD CONSTRAINT campaigns_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES lic_schema.tenants(tenant_id);


--
-- Name: campaigns campaigns_updated_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.campaigns
    ADD CONSTRAINT campaigns_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES lic_schema.users(user_id);


--
-- Name: chat_messages chat_messages_session_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.chat_messages
    ADD CONSTRAINT chat_messages_session_id_fkey FOREIGN KEY (session_id) REFERENCES lic_schema.chatbot_sessions(session_id);


--
-- Name: chat_messages chat_messages_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.chat_messages
    ADD CONSTRAINT chat_messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id);


--
-- Name: chatbot_intents chatbot_intents_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.chatbot_intents
    ADD CONSTRAINT chatbot_intents_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: chatbot_sessions chatbot_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.chatbot_sessions
    ADD CONSTRAINT chatbot_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id);


--
-- Name: commissions commissions_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.commissions
    ADD CONSTRAINT commissions_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: commissions commissions_payment_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.commissions
    ADD CONSTRAINT commissions_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES lic_schema.premium_payments(payment_id);


--
-- Name: commissions commissions_policy_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.commissions
    ADD CONSTRAINT commissions_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES lic_schema.insurance_policies(policy_id);


--
-- Name: commissions commissions_tenant_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.commissions
    ADD CONSTRAINT commissions_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES lic_schema.tenants(tenant_id);


--
-- Name: content content_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.content
    ADD CONSTRAINT content_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: content content_owner_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.content
    ADD CONSTRAINT content_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES lic_schema.users(user_id);


--
-- Name: content content_updated_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.content
    ADD CONSTRAINT content_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES lic_schema.users(user_id);


--
-- Name: content content_uploader_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.content
    ADD CONSTRAINT content_uploader_id_fkey FOREIGN KEY (uploader_id) REFERENCES lic_schema.users(user_id);


--
-- Name: customer_behavior_metrics customer_behavior_metrics_customer_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_behavior_metrics
    ADD CONSTRAINT customer_behavior_metrics_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES lic_schema.policyholders(policyholder_id);


--
-- Name: customer_data_mapping customer_data_mapping_import_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_data_mapping
    ADD CONSTRAINT customer_data_mapping_import_id_fkey FOREIGN KEY (import_id) REFERENCES lic_schema.data_imports(import_id);


--
-- Name: customer_engagement_metrics customer_engagement_metrics_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_engagement_metrics
    ADD CONSTRAINT customer_engagement_metrics_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: customer_feedback customer_feedback_resolved_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_feedback
    ADD CONSTRAINT customer_feedback_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES lic_schema.users(user_id);


--
-- Name: customer_feedback customer_feedback_session_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_feedback
    ADD CONSTRAINT customer_feedback_session_id_fkey FOREIGN KEY (session_id) REFERENCES lic_schema.customer_portal_sessions(session_id);


--
-- Name: customer_feedback customer_feedback_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_feedback
    ADD CONSTRAINT customer_feedback_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: customer_journey_events customer_journey_events_session_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_journey_events
    ADD CONSTRAINT customer_journey_events_session_id_fkey FOREIGN KEY (session_id) REFERENCES lic_schema.customer_portal_sessions(session_id);


--
-- Name: customer_journey_events customer_journey_events_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_journey_events
    ADD CONSTRAINT customer_journey_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: customer_portal_preferences customer_portal_preferences_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_portal_preferences
    ADD CONSTRAINT customer_portal_preferences_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: customer_portal_sessions customer_portal_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_portal_sessions
    ADD CONSTRAINT customer_portal_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: customer_retention_analytics customer_retention_analytics_assigned_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_retention_analytics
    ADD CONSTRAINT customer_retention_analytics_assigned_agent_id_fkey FOREIGN KEY (assigned_agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: customer_retention_analytics customer_retention_analytics_customer_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_retention_analytics
    ADD CONSTRAINT customer_retention_analytics_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES lic_schema.policyholders(policyholder_id);


--
-- Name: customer_retention_metrics customer_retention_metrics_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_retention_metrics
    ADD CONSTRAINT customer_retention_metrics_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: daily_quotes daily_quotes_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.daily_quotes
    ADD CONSTRAINT daily_quotes_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: daily_quotes daily_quotes_updated_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.daily_quotes
    ADD CONSTRAINT daily_quotes_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES lic_schema.users(user_id);


--
-- Name: data_export_log data_export_log_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.data_export_log
    ADD CONSTRAINT data_export_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id);


--
-- Name: document_ocr_results document_ocr_results_document_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.document_ocr_results
    ADD CONSTRAINT document_ocr_results_document_id_fkey FOREIGN KEY (document_id) REFERENCES lic_schema.kyc_documents(document_id) ON DELETE CASCADE;


--
-- Name: emergency_contact_verifications emergency_contact_verifications_contact_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.emergency_contact_verifications
    ADD CONSTRAINT emergency_contact_verifications_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES lic_schema.emergency_contacts(contact_id) ON DELETE CASCADE;


--
-- Name: emergency_contacts emergency_contacts_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.emergency_contacts
    ADD CONSTRAINT emergency_contacts_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: feature_flag_overrides feature_flag_overrides_flag_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.feature_flag_overrides
    ADD CONSTRAINT feature_flag_overrides_flag_id_fkey FOREIGN KEY (flag_id) REFERENCES lic_schema.feature_flags(flag_id) ON DELETE CASCADE;


--
-- Name: feature_flag_overrides feature_flag_overrides_role_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.feature_flag_overrides
    ADD CONSTRAINT feature_flag_overrides_role_id_fkey FOREIGN KEY (role_id) REFERENCES lic_schema.roles(role_id);


--
-- Name: feature_flag_overrides feature_flag_overrides_tenant_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.feature_flag_overrides
    ADD CONSTRAINT feature_flag_overrides_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES lic_schema.tenants(tenant_id);


--
-- Name: feature_flag_overrides feature_flag_overrides_updated_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.feature_flag_overrides
    ADD CONSTRAINT feature_flag_overrides_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES lic_schema.users(user_id);


--
-- Name: feature_flag_overrides feature_flag_overrides_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.feature_flag_overrides
    ADD CONSTRAINT feature_flag_overrides_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id);


--
-- Name: feature_flags feature_flags_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.feature_flags
    ADD CONSTRAINT feature_flags_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: feature_flags feature_flags_tenant_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.feature_flags
    ADD CONSTRAINT feature_flags_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES lic_schema.tenants(tenant_id);


--
-- Name: feature_flags feature_flags_updated_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.feature_flags
    ADD CONSTRAINT feature_flags_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES lic_schema.users(user_id);


--
-- Name: customer_retention_analytics fk_customer_retention_customer; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_retention_analytics
    ADD CONSTRAINT fk_customer_retention_customer FOREIGN KEY (customer_id) REFERENCES lic_schema.policyholders(policyholder_id) ON DELETE CASCADE;


--
-- Name: daily_quotes fk_daily_quotes_agent; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.daily_quotes
    ADD CONSTRAINT fk_daily_quotes_agent FOREIGN KEY (agent_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: leads fk_leads_converted_policy; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.leads
    ADD CONSTRAINT fk_leads_converted_policy FOREIGN KEY (converted_policy_id) REFERENCES lic_schema.insurance_policies(policy_id) ON DELETE SET NULL;


--
-- Name: quote_performance fk_quote_performance_quote; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.quote_performance
    ADD CONSTRAINT fk_quote_performance_quote FOREIGN KEY (quote_id) REFERENCES lic_schema.daily_quotes(quote_id) ON DELETE CASCADE;


--
-- Name: quote_sharing_analytics fk_quote_sharing_analytics_agent; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.quote_sharing_analytics
    ADD CONSTRAINT fk_quote_sharing_analytics_agent FOREIGN KEY (agent_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: quote_sharing_analytics fk_quote_sharing_analytics_quote; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.quote_sharing_analytics
    ADD CONSTRAINT fk_quote_sharing_analytics_quote FOREIGN KEY (quote_id) REFERENCES lic_schema.daily_quotes(quote_id) ON DELETE CASCADE;


--
-- Name: subscription_changes fk_subscription_changes_initiated_by; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.subscription_changes
    ADD CONSTRAINT fk_subscription_changes_initiated_by FOREIGN KEY (initiated_by) REFERENCES lic_schema.users(user_id) ON DELETE SET NULL;


--
-- Name: subscription_changes fk_subscription_changes_user; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.subscription_changes
    ADD CONSTRAINT fk_subscription_changes_user FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: video_progress fk_video_progress_video_id; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.video_progress
    ADD CONSTRAINT fk_video_progress_video_id FOREIGN KEY (video_id) REFERENCES lic_schema.video_tutorials(id) ON DELETE CASCADE;


--
-- Name: video_recommendations fk_video_recommendations_video_id; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.video_recommendations
    ADD CONSTRAINT fk_video_recommendations_video_id FOREIGN KEY (video_id) REFERENCES lic_schema.video_tutorials(id) ON DELETE CASCADE;


--
-- Name: video_tutorials fk_video_tutorials_content_id; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.video_tutorials
    ADD CONSTRAINT fk_video_tutorials_content_id FOREIGN KEY (content_id) REFERENCES lic_schema.video_content(video_id) ON DELETE CASCADE;


--
-- Name: import_jobs import_jobs_import_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.import_jobs
    ADD CONSTRAINT import_jobs_import_id_fkey FOREIGN KEY (import_id) REFERENCES lic_schema.data_imports(import_id);


--
-- Name: insurance_policies insurance_policies_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.insurance_policies
    ADD CONSTRAINT insurance_policies_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: insurance_policies insurance_policies_approved_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.insurance_policies
    ADD CONSTRAINT insurance_policies_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES lic_schema.users(user_id);


--
-- Name: insurance_policies insurance_policies_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.insurance_policies
    ADD CONSTRAINT insurance_policies_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: insurance_policies insurance_policies_policyholder_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.insurance_policies
    ADD CONSTRAINT insurance_policies_policyholder_id_fkey FOREIGN KEY (policyholder_id) REFERENCES lic_schema.policyholders(policyholder_id);


--
-- Name: insurance_policies insurance_policies_tenant_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.insurance_policies
    ADD CONSTRAINT insurance_policies_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES lic_schema.tenants(tenant_id);


--
-- Name: knowledge_base_articles knowledge_base_articles_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.knowledge_base_articles
    ADD CONSTRAINT knowledge_base_articles_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: knowledge_base_articles knowledge_base_articles_moderated_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.knowledge_base_articles
    ADD CONSTRAINT knowledge_base_articles_moderated_by_fkey FOREIGN KEY (moderated_by) REFERENCES lic_schema.users(user_id);


--
-- Name: knowledge_search_log knowledge_search_log_clicked_article_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.knowledge_search_log
    ADD CONSTRAINT knowledge_search_log_clicked_article_id_fkey FOREIGN KEY (clicked_article_id) REFERENCES lic_schema.knowledge_base_articles(article_id);


--
-- Name: knowledge_search_log knowledge_search_log_session_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.knowledge_search_log
    ADD CONSTRAINT knowledge_search_log_session_id_fkey FOREIGN KEY (session_id) REFERENCES lic_schema.chatbot_sessions(session_id);


--
-- Name: knowledge_search_log knowledge_search_log_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.knowledge_search_log
    ADD CONSTRAINT knowledge_search_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id);


--
-- Name: kyc_documents kyc_documents_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.kyc_documents
    ADD CONSTRAINT kyc_documents_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: kyc_documents kyc_documents_verified_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.kyc_documents
    ADD CONSTRAINT kyc_documents_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES lic_schema.users(user_id);


--
-- Name: kyc_manual_reviews kyc_manual_reviews_document_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.kyc_manual_reviews
    ADD CONSTRAINT kyc_manual_reviews_document_id_fkey FOREIGN KEY (document_id) REFERENCES lic_schema.kyc_documents(document_id) ON DELETE CASCADE;


--
-- Name: kyc_manual_reviews kyc_manual_reviews_reviewer_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.kyc_manual_reviews
    ADD CONSTRAINT kyc_manual_reviews_reviewer_id_fkey FOREIGN KEY (reviewer_id) REFERENCES lic_schema.users(user_id);


--
-- Name: lead_interactions lead_interactions_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.lead_interactions
    ADD CONSTRAINT lead_interactions_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: lead_interactions lead_interactions_lead_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.lead_interactions
    ADD CONSTRAINT lead_interactions_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES lic_schema.leads(lead_id) ON DELETE CASCADE;


--
-- Name: leads leads_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.leads
    ADD CONSTRAINT leads_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: leads leads_converted_policy_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.leads
    ADD CONSTRAINT leads_converted_policy_id_fkey FOREIGN KEY (converted_policy_id) REFERENCES lic_schema.insurance_policies(policy_id);


--
-- Name: leads leads_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.leads
    ADD CONSTRAINT leads_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: leads leads_updated_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.leads
    ADD CONSTRAINT leads_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES lic_schema.users(user_id);


--
-- Name: notifications notifications_tenant_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.notifications
    ADD CONSTRAINT notifications_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES lic_schema.tenants(tenant_id);


--
-- Name: policyholders policyholders_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.policyholders
    ADD CONSTRAINT policyholders_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: policyholders policyholders_tenant_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.policyholders
    ADD CONSTRAINT policyholders_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES lic_schema.tenants(tenant_id);


--
-- Name: policyholders policyholders_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.policyholders
    ADD CONSTRAINT policyholders_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: predictive_insights predictive_insights_acknowledged_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.predictive_insights
    ADD CONSTRAINT predictive_insights_acknowledged_by_fkey FOREIGN KEY (acknowledged_by) REFERENCES lic_schema.users(user_id);


--
-- Name: predictive_insights predictive_insights_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.predictive_insights
    ADD CONSTRAINT predictive_insights_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: predictive_insights predictive_insights_customer_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.predictive_insights
    ADD CONSTRAINT predictive_insights_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES lic_schema.policyholders(policyholder_id);


--
-- Name: premium_payments premium_payments_policy_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.premium_payments
    ADD CONSTRAINT premium_payments_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES lic_schema.insurance_policies(policy_id);


--
-- Name: premium_payments premium_payments_policyholder_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.premium_payments
    ADD CONSTRAINT premium_payments_policyholder_id_fkey FOREIGN KEY (policyholder_id) REFERENCES lic_schema.policyholders(policyholder_id);


--
-- Name: premium_payments premium_payments_reconciled_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.premium_payments
    ADD CONSTRAINT premium_payments_reconciled_by_fkey FOREIGN KEY (reconciled_by) REFERENCES lic_schema.users(user_id);


--
-- Name: premium_payments premium_payments_tenant_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.premium_payments
    ADD CONSTRAINT premium_payments_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES lic_schema.tenants(tenant_id);


--
-- Name: presentation_analytics presentation_analytics_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.presentation_analytics
    ADD CONSTRAINT presentation_analytics_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: presentation_analytics presentation_analytics_presentation_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.presentation_analytics
    ADD CONSTRAINT presentation_analytics_presentation_id_fkey FOREIGN KEY (presentation_id) REFERENCES lic_schema.presentations(presentation_id) ON DELETE CASCADE;


--
-- Name: presentation_analytics presentation_analytics_slide_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.presentation_analytics
    ADD CONSTRAINT presentation_analytics_slide_id_fkey FOREIGN KEY (slide_id) REFERENCES lic_schema.presentation_slides(slide_id) ON DELETE SET NULL;


--
-- Name: presentation_analytics presentation_analytics_viewer_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.presentation_analytics
    ADD CONSTRAINT presentation_analytics_viewer_id_fkey FOREIGN KEY (viewer_id) REFERENCES lic_schema.users(user_id);


--
-- Name: presentation_media presentation_media_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.presentation_media
    ADD CONSTRAINT presentation_media_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: presentation_slides presentation_slides_presentation_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.presentation_slides
    ADD CONSTRAINT presentation_slides_presentation_id_fkey FOREIGN KEY (presentation_id) REFERENCES lic_schema.presentations(presentation_id) ON DELETE CASCADE;


--
-- Name: presentation_templates presentation_templates_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.presentation_templates
    ADD CONSTRAINT presentation_templates_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: presentations presentations_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.presentations
    ADD CONSTRAINT presentations_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id) ON DELETE CASCADE;


--
-- Name: presentations presentations_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.presentations
    ADD CONSTRAINT presentations_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: presentations presentations_parent_presentation_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.presentations
    ADD CONSTRAINT presentations_parent_presentation_id_fkey FOREIGN KEY (parent_presentation_id) REFERENCES lic_schema.presentations(presentation_id);


--
-- Name: presentations presentations_published_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.presentations
    ADD CONSTRAINT presentations_published_by_fkey FOREIGN KEY (published_by) REFERENCES lic_schema.users(user_id);


--
-- Name: presentations presentations_tenant_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.presentations
    ADD CONSTRAINT presentations_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES lic_schema.tenants(tenant_id);


--
-- Name: quote_performance quote_performance_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.quote_performance
    ADD CONSTRAINT quote_performance_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: quote_performance quote_performance_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.quote_performance
    ADD CONSTRAINT quote_performance_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: quote_performance quote_performance_updated_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.quote_performance
    ADD CONSTRAINT quote_performance_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES lic_schema.users(user_id);


--
-- Name: rbac_audit_log rbac_audit_log_target_flag_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.rbac_audit_log
    ADD CONSTRAINT rbac_audit_log_target_flag_id_fkey FOREIGN KEY (target_flag_id) REFERENCES lic_schema.feature_flags(flag_id);


--
-- Name: rbac_audit_log rbac_audit_log_target_permission_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.rbac_audit_log
    ADD CONSTRAINT rbac_audit_log_target_permission_id_fkey FOREIGN KEY (target_permission_id) REFERENCES lic_schema.permissions(permission_id);


--
-- Name: rbac_audit_log rbac_audit_log_target_role_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.rbac_audit_log
    ADD CONSTRAINT rbac_audit_log_target_role_id_fkey FOREIGN KEY (target_role_id) REFERENCES lic_schema.roles(role_id);


--
-- Name: rbac_audit_log rbac_audit_log_target_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.rbac_audit_log
    ADD CONSTRAINT rbac_audit_log_target_user_id_fkey FOREIGN KEY (target_user_id) REFERENCES lic_schema.users(user_id);


--
-- Name: rbac_audit_log rbac_audit_log_tenant_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.rbac_audit_log
    ADD CONSTRAINT rbac_audit_log_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES lic_schema.tenants(tenant_id);


--
-- Name: rbac_audit_log rbac_audit_log_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.rbac_audit_log
    ADD CONSTRAINT rbac_audit_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id);


--
-- Name: retention_actions retention_actions_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.retention_actions
    ADD CONSTRAINT retention_actions_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: retention_actions retention_actions_retention_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.retention_actions
    ADD CONSTRAINT retention_actions_retention_id_fkey FOREIGN KEY (retention_id) REFERENCES lic_schema.customer_retention_analytics(retention_id) ON DELETE CASCADE;


--
-- Name: revenue_forecast_scenarios revenue_forecast_scenarios_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.revenue_forecast_scenarios
    ADD CONSTRAINT revenue_forecast_scenarios_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: revenue_forecasts revenue_forecasts_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.revenue_forecasts
    ADD CONSTRAINT revenue_forecasts_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: revenue_forecasts revenue_forecasts_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.revenue_forecasts
    ADD CONSTRAINT revenue_forecasts_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES lic_schema.permissions(permission_id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES lic_schema.roles(role_id) ON DELETE CASCADE;


--
-- Name: subscription_billing_history subscription_billing_history_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.subscription_billing_history
    ADD CONSTRAINT subscription_billing_history_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: subscription_billing_history subscription_billing_history_subscription_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.subscription_billing_history
    ADD CONSTRAINT subscription_billing_history_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES lic_schema.user_subscriptions(subscription_id) ON DELETE CASCADE;


--
-- Name: subscription_billing_history subscription_billing_history_updated_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.subscription_billing_history
    ADD CONSTRAINT subscription_billing_history_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES lic_schema.users(user_id);


--
-- Name: subscription_billing_history subscription_billing_history_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.subscription_billing_history
    ADD CONSTRAINT subscription_billing_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: subscription_changes subscription_changes_from_plan_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.subscription_changes
    ADD CONSTRAINT subscription_changes_from_plan_id_fkey FOREIGN KEY (from_plan_id) REFERENCES lic_schema.subscription_plans(plan_id);


--
-- Name: subscription_changes subscription_changes_initiated_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.subscription_changes
    ADD CONSTRAINT subscription_changes_initiated_by_fkey FOREIGN KEY (initiated_by) REFERENCES lic_schema.users(user_id);


--
-- Name: subscription_changes subscription_changes_subscription_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.subscription_changes
    ADD CONSTRAINT subscription_changes_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES lic_schema.user_subscriptions(subscription_id) ON DELETE CASCADE;


--
-- Name: subscription_changes subscription_changes_to_plan_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.subscription_changes
    ADD CONSTRAINT subscription_changes_to_plan_id_fkey FOREIGN KEY (to_plan_id) REFERENCES lic_schema.subscription_plans(plan_id);


--
-- Name: subscription_changes subscription_changes_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.subscription_changes
    ADD CONSTRAINT subscription_changes_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: subscription_plans subscription_plans_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.subscription_plans
    ADD CONSTRAINT subscription_plans_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: subscription_plans subscription_plans_updated_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.subscription_plans
    ADD CONSTRAINT subscription_plans_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES lic_schema.users(user_id);


--
-- Name: tenant_config tenant_config_tenant_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.tenant_config
    ADD CONSTRAINT tenant_config_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES lic_schema.tenants(tenant_id);


--
-- Name: tenant_usage tenant_usage_tenant_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.tenant_usage
    ADD CONSTRAINT tenant_usage_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES lic_schema.tenants(tenant_id);


--
-- Name: tenant_users tenant_users_tenant_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.tenant_users
    ADD CONSTRAINT tenant_users_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES lic_schema.tenants(tenant_id);


--
-- Name: tenant_users tenant_users_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.tenant_users
    ADD CONSTRAINT tenant_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id);


--
-- Name: tenants tenants_parent_tenant_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.tenants
    ADD CONSTRAINT tenants_parent_tenant_id_fkey FOREIGN KEY (parent_tenant_id) REFERENCES lic_schema.tenants(tenant_id);


--
-- Name: trial_engagement trial_engagement_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.trial_engagement
    ADD CONSTRAINT trial_engagement_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: trial_engagement trial_engagement_trial_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.trial_engagement
    ADD CONSTRAINT trial_engagement_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES lic_schema.trial_subscriptions(trial_id) ON DELETE CASCADE;


--
-- Name: trial_engagement trial_engagement_updated_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.trial_engagement
    ADD CONSTRAINT trial_engagement_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES lic_schema.users(user_id);


--
-- Name: trial_subscriptions trial_subscriptions_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.trial_subscriptions
    ADD CONSTRAINT trial_subscriptions_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: trial_subscriptions trial_subscriptions_updated_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.trial_subscriptions
    ADD CONSTRAINT trial_subscriptions_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES lic_schema.users(user_id);


--
-- Name: trial_subscriptions trial_subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.trial_subscriptions
    ADD CONSTRAINT trial_subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: user_journeys user_journeys_session_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.user_journeys
    ADD CONSTRAINT user_journeys_session_id_fkey FOREIGN KEY (session_id) REFERENCES lic_schema.user_sessions(session_id) ON DELETE SET NULL;


--
-- Name: user_journeys user_journeys_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.user_journeys
    ADD CONSTRAINT user_journeys_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: user_payment_methods user_payment_methods_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.user_payment_methods
    ADD CONSTRAINT user_payment_methods_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_assigned_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.user_roles
    ADD CONSTRAINT user_roles_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES lic_schema.users(user_id);


--
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES lic_schema.roles(role_id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: user_sessions user_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.user_sessions
    ADD CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: user_subscriptions user_subscriptions_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.user_subscriptions
    ADD CONSTRAINT user_subscriptions_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: user_subscriptions user_subscriptions_plan_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.user_subscriptions
    ADD CONSTRAINT user_subscriptions_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES lic_schema.subscription_plans(plan_id);


--
-- Name: user_subscriptions user_subscriptions_updated_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.user_subscriptions
    ADD CONSTRAINT user_subscriptions_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES lic_schema.users(user_id);


--
-- Name: user_subscriptions user_subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.user_subscriptions
    ADD CONSTRAINT user_subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: video_analytics video_analytics_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.video_analytics
    ADD CONSTRAINT video_analytics_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE SET NULL;


--
-- Name: video_analytics video_analytics_video_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.video_analytics
    ADD CONSTRAINT video_analytics_video_id_fkey FOREIGN KEY (video_id) REFERENCES lic_schema.video_content(video_id) ON DELETE CASCADE;


--
-- Name: video_categories video_categories_parent_category_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.video_categories
    ADD CONSTRAINT video_categories_parent_category_id_fkey FOREIGN KEY (parent_category_id) REFERENCES lic_schema.video_categories(id);


--
-- Name: video_content video_content_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.video_content
    ADD CONSTRAINT video_content_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: video_content video_content_moderated_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.video_content
    ADD CONSTRAINT video_content_moderated_by_fkey FOREIGN KEY (moderated_by) REFERENCES lic_schema.users(user_id);


--
-- Name: video_progress video_progress_video_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.video_progress
    ADD CONSTRAINT video_progress_video_id_fkey FOREIGN KEY (video_id) REFERENCES lic_schema.video_tutorials(id) ON DELETE CASCADE;


--
-- Name: video_recommendations video_recommendations_video_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.video_recommendations
    ADD CONSTRAINT video_recommendations_video_id_fkey FOREIGN KEY (video_id) REFERENCES lic_schema.video_tutorials(id) ON DELETE CASCADE;


--
-- Name: video_tutorials video_tutorials_content_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.video_tutorials
    ADD CONSTRAINT video_tutorials_content_id_fkey FOREIGN KEY (content_id) REFERENCES lic_schema.video_content(video_id) ON DELETE CASCADE;


--
-- Name: whatsapp_messages whatsapp_messages_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.whatsapp_messages
    ADD CONSTRAINT whatsapp_messages_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: whatsapp_messages whatsapp_messages_recipient_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.whatsapp_messages
    ADD CONSTRAINT whatsapp_messages_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES lic_schema.users(user_id);


--
-- Name: whatsapp_messages whatsapp_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.whatsapp_messages
    ADD CONSTRAINT whatsapp_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES lic_schema.users(user_id);


--
-- Name: agents; Type: ROW SECURITY; Schema: lic_schema; Owner: -
--

ALTER TABLE lic_schema.agents ENABLE ROW LEVEL SECURITY;

--
-- Name: campaigns; Type: ROW SECURITY; Schema: lic_schema; Owner: -
--

ALTER TABLE lic_schema.campaigns ENABLE ROW LEVEL SECURITY;

--
-- Name: commissions; Type: ROW SECURITY; Schema: lic_schema; Owner: -
--

ALTER TABLE lic_schema.commissions ENABLE ROW LEVEL SECURITY;

--
-- Name: insurance_policies; Type: ROW SECURITY; Schema: lic_schema; Owner: -
--

ALTER TABLE lic_schema.insurance_policies ENABLE ROW LEVEL SECURITY;

--
-- Name: notifications; Type: ROW SECURITY; Schema: lic_schema; Owner: -
--

ALTER TABLE lic_schema.notifications ENABLE ROW LEVEL SECURITY;

--
-- Name: policyholders; Type: ROW SECURITY; Schema: lic_schema; Owner: -
--

ALTER TABLE lic_schema.policyholders ENABLE ROW LEVEL SECURITY;

--
-- Name: premium_payments; Type: ROW SECURITY; Schema: lic_schema; Owner: -
--

ALTER TABLE lic_schema.premium_payments ENABLE ROW LEVEL SECURITY;

--
-- Name: agents tenant_agents_isolation; Type: POLICY; Schema: lic_schema; Owner: -
--

CREATE POLICY tenant_agents_isolation ON lic_schema.agents USING (((tenant_id = lic_schema.current_tenant_id()) OR (lic_schema.current_tenant_id() IS NULL)));


--
-- Name: campaigns tenant_campaigns_isolation; Type: POLICY; Schema: lic_schema; Owner: -
--

CREATE POLICY tenant_campaigns_isolation ON lic_schema.campaigns USING (((tenant_id = lic_schema.current_tenant_id()) OR (lic_schema.current_tenant_id() IS NULL)));


--
-- Name: commissions tenant_commissions_isolation; Type: POLICY; Schema: lic_schema; Owner: -
--

CREATE POLICY tenant_commissions_isolation ON lic_schema.commissions USING (((tenant_id = lic_schema.current_tenant_id()) OR (lic_schema.current_tenant_id() IS NULL)));


--
-- Name: notifications tenant_notifications_isolation; Type: POLICY; Schema: lic_schema; Owner: -
--

CREATE POLICY tenant_notifications_isolation ON lic_schema.notifications USING (((tenant_id = lic_schema.current_tenant_id()) OR (lic_schema.current_tenant_id() IS NULL)));


--
-- Name: premium_payments tenant_payments_isolation; Type: POLICY; Schema: lic_schema; Owner: -
--

CREATE POLICY tenant_payments_isolation ON lic_schema.premium_payments USING (((tenant_id = lic_schema.current_tenant_id()) OR (lic_schema.current_tenant_id() IS NULL)));


--
-- Name: insurance_policies tenant_policies_isolation; Type: POLICY; Schema: lic_schema; Owner: -
--

CREATE POLICY tenant_policies_isolation ON lic_schema.insurance_policies USING (((tenant_id = lic_schema.current_tenant_id()) OR (lic_schema.current_tenant_id() IS NULL)));


--
-- Name: policyholders tenant_policyholders_isolation; Type: POLICY; Schema: lic_schema; Owner: -
--

CREATE POLICY tenant_policyholders_isolation ON lic_schema.policyholders USING (((tenant_id = lic_schema.current_tenant_id()) OR (lic_schema.current_tenant_id() IS NULL)));


--
-- Name: tenant_users tenant_tenant_users_isolation; Type: POLICY; Schema: lic_schema; Owner: -
--

CREATE POLICY tenant_tenant_users_isolation ON lic_schema.tenant_users USING (((tenant_id = lic_schema.current_tenant_id()) OR (lic_schema.current_tenant_id() IS NULL)));


--
-- Name: tenant_users; Type: ROW SECURITY; Schema: lic_schema; Owner: -
--

ALTER TABLE lic_schema.tenant_users ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_users tenant_users_isolation; Type: POLICY; Schema: lic_schema; Owner: -
--

CREATE POLICY tenant_users_isolation ON lic_schema.tenant_users USING ((tenant_id = lic_schema.current_tenant_id()));


--
-- PostgreSQL database dump complete
--

\unrestrict wDymkuz3ibbc5QqLhlA2dhFK37y2WxhReOMNo31gQF7I0Tf4tahqKXTseA715Ge

