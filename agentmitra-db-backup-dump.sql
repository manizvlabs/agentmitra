--
-- PostgreSQL database dump
--

\restrict V87L0OrgafmADxhSMRZpL83xEh0twO5ve1bp3JQXMFfsP2IqmtE5op83fqFySPu

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

ALTER TABLE IF EXISTS ONLY shared.tenants DROP CONSTRAINT IF EXISTS tenants_parent_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY shared.tenant_config DROP CONSTRAINT IF EXISTS tenant_config_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY shared.import_jobs DROP CONSTRAINT IF EXISTS import_jobs_import_id_fkey;
ALTER TABLE IF EXISTS ONLY shared.customer_data_mapping DROP CONSTRAINT IF EXISTS customer_data_mapping_import_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_sessions DROP CONSTRAINT IF EXISTS user_sessions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.slides DROP CONSTRAINT IF EXISTS slides_presentation_id_fkey;
ALTER TABLE IF EXISTS ONLY public.presentations DROP CONSTRAINT IF EXISTS presentations_template_id_fkey;
ALTER TABLE IF EXISTS ONLY public.presentations DROP CONSTRAINT IF EXISTS presentations_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.whatsapp_messages DROP CONSTRAINT IF EXISTS whatsapp_messages_sender_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.whatsapp_messages DROP CONSTRAINT IF EXISTS whatsapp_messages_recipient_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.whatsapp_messages DROP CONSTRAINT IF EXISTS whatsapp_messages_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.video_content DROP CONSTRAINT IF EXISTS video_content_moderated_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.video_content DROP CONSTRAINT IF EXISTS video_content_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_sessions DROP CONSTRAINT IF EXISTS user_sessions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_roles DROP CONSTRAINT IF EXISTS user_roles_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_roles DROP CONSTRAINT IF EXISTS user_roles_role_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_roles DROP CONSTRAINT IF EXISTS user_roles_assigned_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_payment_methods DROP CONSTRAINT IF EXISTS user_payment_methods_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_role_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_permission_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.revenue_forecasts DROP CONSTRAINT IF EXISTS revenue_forecasts_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.revenue_forecasts DROP CONSTRAINT IF EXISTS revenue_forecasts_agent_id_fkey;
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
ALTER TABLE IF EXISTS ONLY lic_schema.premium_payments DROP CONSTRAINT IF EXISTS premium_payments_reconciled_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.premium_payments DROP CONSTRAINT IF EXISTS premium_payments_policyholder_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.premium_payments DROP CONSTRAINT IF EXISTS premium_payments_policy_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.policyholders DROP CONSTRAINT IF EXISTS policyholders_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.policyholders DROP CONSTRAINT IF EXISTS policyholders_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.knowledge_search_log DROP CONSTRAINT IF EXISTS knowledge_search_log_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.knowledge_search_log DROP CONSTRAINT IF EXISTS knowledge_search_log_session_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.knowledge_search_log DROP CONSTRAINT IF EXISTS knowledge_search_log_clicked_article_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.knowledge_base_articles DROP CONSTRAINT IF EXISTS knowledge_base_articles_moderated_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.knowledge_base_articles DROP CONSTRAINT IF EXISTS knowledge_base_articles_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.insurance_policies DROP CONSTRAINT IF EXISTS insurance_policies_provider_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.insurance_policies DROP CONSTRAINT IF EXISTS insurance_policies_policyholder_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.insurance_policies DROP CONSTRAINT IF EXISTS insurance_policies_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.insurance_policies DROP CONSTRAINT IF EXISTS insurance_policies_approved_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.insurance_policies DROP CONSTRAINT IF EXISTS insurance_policies_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.data_export_log DROP CONSTRAINT IF EXISTS data_export_log_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_behavior_metrics DROP CONSTRAINT IF EXISTS customer_behavior_metrics_customer_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.chatbot_sessions DROP CONSTRAINT IF EXISTS chatbot_sessions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.chatbot_intents DROP CONSTRAINT IF EXISTS chatbot_intents_created_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.chat_messages DROP CONSTRAINT IF EXISTS chat_messages_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.chat_messages DROP CONSTRAINT IF EXISTS chat_messages_session_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.analytics_query_log DROP CONSTRAINT IF EXISTS analytics_query_log_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.agents DROP CONSTRAINT IF EXISTS agents_user_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.agents DROP CONSTRAINT IF EXISTS agents_provider_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.agents DROP CONSTRAINT IF EXISTS agents_parent_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.agents DROP CONSTRAINT IF EXISTS agents_approved_by_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.agent_presentation_preferences DROP CONSTRAINT IF EXISTS agent_presentation_preferences_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.agent_monthly_summary DROP CONSTRAINT IF EXISTS agent_monthly_summary_agent_id_fkey;
ALTER TABLE IF EXISTS ONLY lic_schema.agent_daily_metrics DROP CONSTRAINT IF EXISTS agent_daily_metrics_agent_id_fkey;
DROP TRIGGER IF EXISTS update_agent_metrics_trigger ON lic_schema.insurance_policies;
DROP TRIGGER IF EXISTS slide_media_usage_trigger ON lic_schema.presentation_slides;
DROP TRIGGER IF EXISTS presentation_analytics_summary_trigger ON lic_schema.presentation_analytics;
DROP INDEX IF EXISTS shared.idx_tenants_tenant_code;
DROP INDEX IF EXISTS shared.idx_tenants_status;
DROP INDEX IF EXISTS shared.idx_tenant_config_tenant_id;
DROP INDEX IF EXISTS shared.idx_languages_language_code;
DROP INDEX IF EXISTS shared.idx_insurance_providers_provider_code;
DROP INDEX IF EXISTS shared.idx_insurance_categories_category_code;
DROP INDEX IF EXISTS shared.idx_import_jobs_status;
DROP INDEX IF EXISTS shared.idx_data_sync_status_agent;
DROP INDEX IF EXISTS shared.idx_data_imports_agent_status;
DROP INDEX IF EXISTS shared.idx_customer_data_mapping_import;
DROP INDEX IF EXISTS shared.idx_countries_country_code;
DROP INDEX IF EXISTS shared.flyway_schema_history_s_idx;
DROP INDEX IF EXISTS public.ix_users_phone_number;
DROP INDEX IF EXISTS public.ix_users_email;
DROP INDEX IF EXISTS public.ix_users_agent_code;
DROP INDEX IF EXISTS public.ix_user_sessions_user_id;
DROP INDEX IF EXISTS public.ix_slides_presentation_id;
DROP INDEX IF EXISTS public.ix_presentations_is_active;
DROP INDEX IF EXISTS public.ix_presentations_agent_id;
DROP INDEX IF EXISTS lic_schema.idx_whatsapp_messages_agent;
DROP INDEX IF EXISTS lic_schema.idx_video_content_agent;
DROP INDEX IF EXISTS lic_schema.idx_users_tenant_status;
DROP INDEX IF EXISTS lic_schema.idx_users_role_status;
DROP INDEX IF EXISTS lic_schema.idx_users_phone_verified;
DROP INDEX IF EXISTS lic_schema.idx_users_phone;
DROP INDEX IF EXISTS lic_schema.idx_users_email;
DROP INDEX IF EXISTS lic_schema.idx_users_created_at;
DROP INDEX IF EXISTS lic_schema.idx_user_sessions_token;
DROP INDEX IF EXISTS lic_schema.idx_user_sessions_active;
DROP INDEX IF EXISTS lic_schema.idx_templates_status;
DROP INDEX IF EXISTS lic_schema.idx_templates_slides;
DROP INDEX IF EXISTS lic_schema.idx_templates_category_public;
DROP INDEX IF EXISTS lic_schema.idx_slides_type;
DROP INDEX IF EXISTS lic_schema.idx_slides_presentation_order;
DROP INDEX IF EXISTS lic_schema.idx_slides_cta_button;
DROP INDEX IF EXISTS lic_schema.idx_slides_agent_branding;
DROP INDEX IF EXISTS lic_schema.idx_revenue_forecast_date;
DROP INDEX IF EXISTS lic_schema.idx_revenue_forecast_agent;
DROP INDEX IF EXISTS lic_schema.idx_presentations_template;
DROP INDEX IF EXISTS lic_schema.idx_presentations_published;
DROP INDEX IF EXISTS lic_schema.idx_presentations_agent_status;
DROP INDEX IF EXISTS lic_schema.idx_presentations_active;
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
DROP INDEX IF EXISTS lic_schema.idx_media_type;
DROP INDEX IF EXISTS lic_schema.idx_media_hash;
DROP INDEX IF EXISTS lic_schema.idx_media_agent_status;
DROP INDEX IF EXISTS lic_schema.idx_kb_search_user;
DROP INDEX IF EXISTS lic_schema.idx_kb_search_query;
DROP INDEX IF EXISTS lic_schema.idx_kb_articles_tags;
DROP INDEX IF EXISTS lic_schema.idx_kb_articles_category;
DROP INDEX IF EXISTS lic_schema.idx_data_export_user;
DROP INDEX IF EXISTS lic_schema.idx_daily_kpis_date;
DROP INDEX IF EXISTS lic_schema.idx_customer_behavior_date;
DROP INDEX IF EXISTS lic_schema.idx_customer_behavior_customer;
DROP INDEX IF EXISTS lic_schema.idx_chatbot_sessions_user;
DROP INDEX IF EXISTS lic_schema.idx_chatbot_intents_active;
DROP INDEX IF EXISTS lic_schema.idx_chatbot_analytics_date;
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
ALTER TABLE IF EXISTS ONLY shared.whatsapp_templates DROP CONSTRAINT IF EXISTS whatsapp_templates_template_name_key;
ALTER TABLE IF EXISTS ONLY shared.whatsapp_templates DROP CONSTRAINT IF EXISTS whatsapp_templates_pkey;
ALTER TABLE IF EXISTS ONLY shared.tenants DROP CONSTRAINT IF EXISTS tenants_tenant_code_key;
ALTER TABLE IF EXISTS ONLY shared.tenants DROP CONSTRAINT IF EXISTS tenants_schema_name_key;
ALTER TABLE IF EXISTS ONLY shared.tenants DROP CONSTRAINT IF EXISTS tenants_pkey;
ALTER TABLE IF EXISTS ONLY shared.tenant_config DROP CONSTRAINT IF EXISTS tenant_config_tenant_id_config_key_key;
ALTER TABLE IF EXISTS ONLY shared.tenant_config DROP CONSTRAINT IF EXISTS tenant_config_pkey;
ALTER TABLE IF EXISTS ONLY shared.languages DROP CONSTRAINT IF EXISTS languages_pkey;
ALTER TABLE IF EXISTS ONLY shared.languages DROP CONSTRAINT IF EXISTS languages_language_code_key;
ALTER TABLE IF EXISTS ONLY shared.insurance_providers DROP CONSTRAINT IF EXISTS insurance_providers_provider_code_key;
ALTER TABLE IF EXISTS ONLY shared.insurance_providers DROP CONSTRAINT IF EXISTS insurance_providers_pkey;
ALTER TABLE IF EXISTS ONLY shared.insurance_categories DROP CONSTRAINT IF EXISTS insurance_categories_pkey;
ALTER TABLE IF EXISTS ONLY shared.insurance_categories DROP CONSTRAINT IF EXISTS insurance_categories_category_code_key;
ALTER TABLE IF EXISTS ONLY shared.import_jobs DROP CONSTRAINT IF EXISTS import_jobs_pkey;
ALTER TABLE IF EXISTS ONLY shared.flyway_schema_history DROP CONSTRAINT IF EXISTS flyway_schema_history_pk;
ALTER TABLE IF EXISTS ONLY shared.data_sync_status DROP CONSTRAINT IF EXISTS data_sync_status_pkey;
ALTER TABLE IF EXISTS ONLY shared.data_imports DROP CONSTRAINT IF EXISTS data_imports_pkey;
ALTER TABLE IF EXISTS ONLY shared.customer_data_mapping DROP CONSTRAINT IF EXISTS customer_data_mapping_pkey;
ALTER TABLE IF EXISTS ONLY shared.countries DROP CONSTRAINT IF EXISTS countries_pkey;
ALTER TABLE IF EXISTS ONLY shared.countries DROP CONSTRAINT IF EXISTS countries_country_code_key;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.user_sessions DROP CONSTRAINT IF EXISTS user_sessions_pkey;
ALTER TABLE IF EXISTS ONLY public.slides DROP CONSTRAINT IF EXISTS slides_pkey;
ALTER TABLE IF EXISTS ONLY public.presentations DROP CONSTRAINT IF EXISTS presentations_pkey;
ALTER TABLE IF EXISTS ONLY public.presentation_templates DROP CONSTRAINT IF EXISTS presentation_templates_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.whatsapp_messages DROP CONSTRAINT IF EXISTS whatsapp_messages_whatsapp_message_id_key;
ALTER TABLE IF EXISTS ONLY lic_schema.whatsapp_messages DROP CONSTRAINT IF EXISTS whatsapp_messages_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.video_content DROP CONSTRAINT IF EXISTS video_content_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.users DROP CONSTRAINT IF EXISTS users_username_key;
ALTER TABLE IF EXISTS ONLY lic_schema.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.users DROP CONSTRAINT IF EXISTS users_phone_number_key;
ALTER TABLE IF EXISTS ONLY lic_schema.users DROP CONSTRAINT IF EXISTS users_email_key;
ALTER TABLE IF EXISTS ONLY lic_schema.user_sessions DROP CONSTRAINT IF EXISTS user_sessions_session_token_key;
ALTER TABLE IF EXISTS ONLY lic_schema.user_sessions DROP CONSTRAINT IF EXISTS user_sessions_refresh_token_key;
ALTER TABLE IF EXISTS ONLY lic_schema.user_sessions DROP CONSTRAINT IF EXISTS user_sessions_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_roles DROP CONSTRAINT IF EXISTS user_roles_user_id_role_id_key;
ALTER TABLE IF EXISTS ONLY lic_schema.user_roles DROP CONSTRAINT IF EXISTS user_roles_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.user_payment_methods DROP CONSTRAINT IF EXISTS user_payment_methods_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.roles DROP CONSTRAINT IF EXISTS roles_role_name_key;
ALTER TABLE IF EXISTS ONLY lic_schema.roles DROP CONSTRAINT IF EXISTS roles_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_role_id_permission_id_key;
ALTER TABLE IF EXISTS ONLY lic_schema.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.revenue_forecasts DROP CONSTRAINT IF EXISTS revenue_forecasts_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentations DROP CONSTRAINT IF EXISTS presentations_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentation_templates DROP CONSTRAINT IF EXISTS presentation_templates_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentation_slides DROP CONSTRAINT IF EXISTS presentation_slides_presentation_id_slide_order_key;
ALTER TABLE IF EXISTS ONLY lic_schema.presentation_slides DROP CONSTRAINT IF EXISTS presentation_slides_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentation_media DROP CONSTRAINT IF EXISTS presentation_media_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.presentation_analytics DROP CONSTRAINT IF EXISTS presentation_analytics_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.premium_payments DROP CONSTRAINT IF EXISTS premium_payments_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.policyholders DROP CONSTRAINT IF EXISTS policyholders_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.policy_analytics_summary DROP CONSTRAINT IF EXISTS policy_analytics_summary_summary_date_summary_period_key;
ALTER TABLE IF EXISTS ONLY lic_schema.policy_analytics_summary DROP CONSTRAINT IF EXISTS policy_analytics_summary_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.permissions DROP CONSTRAINT IF EXISTS permissions_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.permissions DROP CONSTRAINT IF EXISTS permissions_permission_name_key;
ALTER TABLE IF EXISTS ONLY lic_schema.notifications DROP CONSTRAINT IF EXISTS notifications_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.notification_settings DROP CONSTRAINT IF EXISTS notification_settings_user_id_key;
ALTER TABLE IF EXISTS ONLY lic_schema.notification_settings DROP CONSTRAINT IF EXISTS notification_settings_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.knowledge_search_log DROP CONSTRAINT IF EXISTS knowledge_search_log_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.knowledge_base_articles DROP CONSTRAINT IF EXISTS knowledge_base_articles_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.insurance_policies DROP CONSTRAINT IF EXISTS insurance_policies_policy_number_key;
ALTER TABLE IF EXISTS ONLY lic_schema.insurance_policies DROP CONSTRAINT IF EXISTS insurance_policies_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.device_tokens DROP CONSTRAINT IF EXISTS device_tokens_token_key;
ALTER TABLE IF EXISTS ONLY lic_schema.device_tokens DROP CONSTRAINT IF EXISTS device_tokens_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.data_export_log DROP CONSTRAINT IF EXISTS data_export_log_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_behavior_metrics DROP CONSTRAINT IF EXISTS customer_behavior_metrics_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.customer_behavior_metrics DROP CONSTRAINT IF EXISTS customer_behavior_metrics_customer_id_metric_date_key;
ALTER TABLE IF EXISTS ONLY lic_schema.chatbot_sessions DROP CONSTRAINT IF EXISTS chatbot_sessions_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.chatbot_intents DROP CONSTRAINT IF EXISTS chatbot_intents_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.chatbot_intents DROP CONSTRAINT IF EXISTS chatbot_intents_intent_name_key;
ALTER TABLE IF EXISTS ONLY lic_schema.chatbot_analytics_summary DROP CONSTRAINT IF EXISTS chatbot_analytics_summary_summary_date_summary_period_key;
ALTER TABLE IF EXISTS ONLY lic_schema.chatbot_analytics_summary DROP CONSTRAINT IF EXISTS chatbot_analytics_summary_pkey;
ALTER TABLE IF EXISTS ONLY lic_schema.chat_messages DROP CONSTRAINT IF EXISTS chat_messages_pkey;
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
DROP TABLE IF EXISTS shared.whatsapp_templates;
DROP TABLE IF EXISTS shared.tenants;
DROP TABLE IF EXISTS shared.tenant_config;
DROP TABLE IF EXISTS shared.languages;
DROP TABLE IF EXISTS shared.insurance_providers;
DROP TABLE IF EXISTS shared.insurance_categories;
DROP TABLE IF EXISTS shared.import_jobs;
DROP TABLE IF EXISTS shared.flyway_schema_history;
DROP TABLE IF EXISTS shared.data_sync_status;
DROP TABLE IF EXISTS shared.data_imports;
DROP TABLE IF EXISTS shared.customer_data_mapping;
DROP TABLE IF EXISTS shared.countries;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.user_sessions;
DROP TABLE IF EXISTS public.slides;
DROP TABLE IF EXISTS public.presentations;
DROP TABLE IF EXISTS public.presentation_templates;
DROP TABLE IF EXISTS lic_schema.whatsapp_messages;
DROP TABLE IF EXISTS lic_schema.video_content;
DROP TABLE IF EXISTS lic_schema.user_sessions;
DROP TABLE IF EXISTS lic_schema.user_roles;
DROP TABLE IF EXISTS lic_schema.user_payment_methods;
DROP TABLE IF EXISTS lic_schema.roles;
DROP TABLE IF EXISTS lic_schema.role_permissions;
DROP TABLE IF EXISTS lic_schema.revenue_forecasts;
DROP TABLE IF EXISTS lic_schema.presentations;
DROP TABLE IF EXISTS lic_schema.presentation_templates;
DROP TABLE IF EXISTS lic_schema.presentation_slides;
DROP TABLE IF EXISTS lic_schema.presentation_media;
DROP TABLE IF EXISTS lic_schema.presentation_analytics;
DROP TABLE IF EXISTS lic_schema.premium_payments;
DROP TABLE IF EXISTS lic_schema.policy_analytics_summary;
DROP TABLE IF EXISTS lic_schema.permissions;
DROP TABLE IF EXISTS lic_schema.notifications;
DROP SEQUENCE IF EXISTS lic_schema.notification_settings_id_seq;
DROP TABLE IF EXISTS lic_schema.notification_settings;
DROP TABLE IF EXISTS lic_schema.knowledge_search_log;
DROP TABLE IF EXISTS lic_schema.knowledge_base_articles;
DROP SEQUENCE IF EXISTS lic_schema.device_tokens_id_seq;
DROP TABLE IF EXISTS lic_schema.device_tokens;
DROP TABLE IF EXISTS lic_schema.data_export_log;
DROP MATERIALIZED VIEW IF EXISTS lic_schema.daily_dashboard_kpis;
DROP TABLE IF EXISTS lic_schema.customer_behavior_metrics;
DROP TABLE IF EXISTS lic_schema.chatbot_sessions;
DROP TABLE IF EXISTS lic_schema.chatbot_intents;
DROP TABLE IF EXISTS lic_schema.chatbot_analytics_summary;
DROP TABLE IF EXISTS lic_schema.chat_messages;
DROP TABLE IF EXISTS lic_schema.analytics_query_log;
DROP TABLE IF EXISTS lic_schema.agent_presentation_preferences;
DROP TABLE IF EXISTS lic_schema.agent_monthly_summary;
DROP MATERIALIZED VIEW IF EXISTS lic_schema.agent_leaderboard;
DROP TABLE IF EXISTS lic_schema.users;
DROP TABLE IF EXISTS lic_schema.policyholders;
DROP TABLE IF EXISTS lic_schema.insurance_policies;
DROP TABLE IF EXISTS lic_schema.agents;
DROP TABLE IF EXISTS lic_schema.agent_daily_metrics;
DROP FUNCTION IF EXISTS shared.update_notification_settings_updated_at();
DROP FUNCTION IF EXISTS shared.update_device_tokens_last_used_at();
DROP FUNCTION IF EXISTS public.update_notification_settings_updated_at();
DROP FUNCTION IF EXISTS public.update_device_tokens_last_used_at();
DROP FUNCTION IF EXISTS lic_schema.update_presentation_analytics_summary();
DROP FUNCTION IF EXISTS lic_schema.update_agent_daily_metrics();
DROP FUNCTION IF EXISTS lic_schema.refresh_analytics_views();
DROP FUNCTION IF EXISTS lic_schema.log_analytics_query(p_user_id uuid, p_query_type character varying, p_query_params jsonb, p_execution_time integer, p_records_returned integer, p_ip_address inet, p_user_agent text);
DROP FUNCTION IF EXISTS lic_schema.increment_media_usage();
DROP TYPE IF EXISTS lic_schema.user_status_enum;
DROP TYPE IF EXISTS lic_schema.user_role_enum;
DROP TYPE IF EXISTS lic_schema.policy_status_enum;
DROP TYPE IF EXISTS lic_schema.payment_status_enum;
DROP TYPE IF EXISTS lic_schema.agent_status_enum;
DROP EXTENSION IF EXISTS "uuid-ossp";
DROP EXTENSION IF EXISTS pgcrypto;
DROP EXTENSION IF EXISTS pg_trgm;
DROP SCHEMA IF EXISTS shared;
DROP SCHEMA IF EXISTS lic_schema;
DROP SCHEMA IF EXISTS audit;
--
-- Name: audit; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA audit;


--
-- Name: SCHEMA audit; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA audit IS 'Audit logs and compliance tracking';


--
-- Name: lic_schema; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA lic_schema;


--
-- Name: SCHEMA lic_schema; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA lic_schema IS 'LIC tenant-specific data and business entities';


--
-- Name: shared; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA shared;


--
-- Name: SCHEMA shared; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA shared IS 'Shared reference data and multi-tenant infrastructure';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA shared;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA shared;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA shared;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


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
-- Name: update_device_tokens_last_used_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_device_tokens_last_used_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.last_used_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


--
-- Name: update_notification_settings_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_notification_settings_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


--
-- Name: update_device_tokens_last_used_at(); Type: FUNCTION; Schema: shared; Owner: -
--

CREATE FUNCTION shared.update_device_tokens_last_used_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.last_used_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


--
-- Name: update_notification_settings_updated_at(); Type: FUNCTION; Schema: shared; Owner: -
--

CREATE FUNCTION shared.update_notification_settings_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
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
    updated_at timestamp without time zone DEFAULT now()
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
    updated_at timestamp without time zone DEFAULT now()
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
    updated_at timestamp without time zone DEFAULT now()
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
    scheduled_at timestamp with time zone
);


--
-- Name: permissions; Type: TABLE; Schema: lic_schema; Owner: -
--

CREATE TABLE lic_schema.permissions (
    permission_id uuid DEFAULT gen_random_uuid() NOT NULL,
    permission_name character varying(100) NOT NULL,
    permission_description text,
    resource_type character varying(50),
    action character varying(50),
    created_at timestamp without time zone DEFAULT now()
);


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
    updated_at timestamp without time zone DEFAULT now()
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
    updated_at timestamp without time zone DEFAULT now()
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
    published_by uuid
);


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
-- Name: presentation_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.presentation_templates (
    template_id character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    category character varying,
    is_public boolean NOT NULL,
    thumbnail_url character varying,
    template_data json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: presentations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.presentations (
    presentation_id character varying NOT NULL,
    agent_id character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    status character varying NOT NULL,
    is_active boolean NOT NULL,
    template_id character varying,
    tags json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: slides; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.slides (
    slide_id character varying NOT NULL,
    presentation_id character varying NOT NULL,
    slide_order integer NOT NULL,
    slide_type character varying NOT NULL,
    media_url character varying,
    thumbnail_url character varying,
    title character varying,
    subtitle character varying,
    text_color character varying NOT NULL,
    background_color character varying NOT NULL,
    layout character varying NOT NULL,
    duration integer NOT NULL,
    cta_button json,
    agent_branding json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_sessions (
    session_id character varying NOT NULL,
    user_id character varying NOT NULL,
    access_token text NOT NULL,
    refresh_token text NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    device_info character varying,
    ip_address character varying,
    is_active boolean NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    user_id character varying NOT NULL,
    phone_number character varying NOT NULL,
    email character varying,
    full_name character varying,
    agent_code character varying,
    role character varying NOT NULL,
    is_verified boolean NOT NULL,
    password_hash character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: countries; Type: TABLE; Schema: shared; Owner: -
--

CREATE TABLE shared.countries (
    country_id uuid DEFAULT gen_random_uuid() NOT NULL,
    country_code character varying(3) NOT NULL,
    country_name character varying(100) NOT NULL,
    currency_code character varying(3),
    phone_code character varying(5),
    timezone character varying(50),
    status character varying(20) DEFAULT 'active'::character varying
);


--
-- Name: customer_data_mapping; Type: TABLE; Schema: shared; Owner: -
--

CREATE TABLE shared.customer_data_mapping (
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
-- Name: data_imports; Type: TABLE; Schema: shared; Owner: -
--

CREATE TABLE shared.data_imports (
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
-- Name: data_sync_status; Type: TABLE; Schema: shared; Owner: -
--

CREATE TABLE shared.data_sync_status (
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
-- Name: flyway_schema_history; Type: TABLE; Schema: shared; Owner: -
--

CREATE TABLE shared.flyway_schema_history (
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
-- Name: import_jobs; Type: TABLE; Schema: shared; Owner: -
--

CREATE TABLE shared.import_jobs (
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
-- Name: insurance_categories; Type: TABLE; Schema: shared; Owner: -
--

CREATE TABLE shared.insurance_categories (
    category_id uuid DEFAULT gen_random_uuid() NOT NULL,
    category_code character varying(20) NOT NULL,
    category_name character varying(100) NOT NULL,
    category_type character varying(50),
    description text,
    status character varying(20) DEFAULT 'active'::character varying
);


--
-- Name: insurance_providers; Type: TABLE; Schema: shared; Owner: -
--

CREATE TABLE shared.insurance_providers (
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
-- Name: languages; Type: TABLE; Schema: shared; Owner: -
--

CREATE TABLE shared.languages (
    language_id uuid DEFAULT gen_random_uuid() NOT NULL,
    language_code character varying(10) NOT NULL,
    language_name character varying(100) NOT NULL,
    native_name character varying(100),
    rtl boolean DEFAULT false,
    status character varying(20) DEFAULT 'active'::character varying
);


--
-- Name: tenant_config; Type: TABLE; Schema: shared; Owner: -
--

CREATE TABLE shared.tenant_config (
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
-- Name: tenants; Type: TABLE; Schema: shared; Owner: -
--

CREATE TABLE shared.tenants (
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
-- Name: whatsapp_templates; Type: TABLE; Schema: shared; Owner: -
--

CREATE TABLE shared.whatsapp_templates (
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
-- Name: data_export_log data_export_log_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.data_export_log
    ADD CONSTRAINT data_export_log_pkey PRIMARY KEY (export_id);


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
-- Name: video_content video_content_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.video_content
    ADD CONSTRAINT video_content_pkey PRIMARY KEY (video_id);


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
-- Name: presentation_templates presentation_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.presentation_templates
    ADD CONSTRAINT presentation_templates_pkey PRIMARY KEY (template_id);


--
-- Name: presentations presentations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.presentations
    ADD CONSTRAINT presentations_pkey PRIMARY KEY (presentation_id);


--
-- Name: slides slides_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slides
    ADD CONSTRAINT slides_pkey PRIMARY KEY (slide_id);


--
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (session_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: countries countries_country_code_key; Type: CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.countries
    ADD CONSTRAINT countries_country_code_key UNIQUE (country_code);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (country_id);


--
-- Name: customer_data_mapping customer_data_mapping_pkey; Type: CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.customer_data_mapping
    ADD CONSTRAINT customer_data_mapping_pkey PRIMARY KEY (mapping_id);


--
-- Name: data_imports data_imports_pkey; Type: CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.data_imports
    ADD CONSTRAINT data_imports_pkey PRIMARY KEY (import_id);


--
-- Name: data_sync_status data_sync_status_pkey; Type: CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.data_sync_status
    ADD CONSTRAINT data_sync_status_pkey PRIMARY KEY (sync_id);


--
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- Name: import_jobs import_jobs_pkey; Type: CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.import_jobs
    ADD CONSTRAINT import_jobs_pkey PRIMARY KEY (job_id);


--
-- Name: insurance_categories insurance_categories_category_code_key; Type: CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.insurance_categories
    ADD CONSTRAINT insurance_categories_category_code_key UNIQUE (category_code);


--
-- Name: insurance_categories insurance_categories_pkey; Type: CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.insurance_categories
    ADD CONSTRAINT insurance_categories_pkey PRIMARY KEY (category_id);


--
-- Name: insurance_providers insurance_providers_pkey; Type: CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.insurance_providers
    ADD CONSTRAINT insurance_providers_pkey PRIMARY KEY (provider_id);


--
-- Name: insurance_providers insurance_providers_provider_code_key; Type: CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.insurance_providers
    ADD CONSTRAINT insurance_providers_provider_code_key UNIQUE (provider_code);


--
-- Name: languages languages_language_code_key; Type: CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.languages
    ADD CONSTRAINT languages_language_code_key UNIQUE (language_code);


--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (language_id);


--
-- Name: tenant_config tenant_config_pkey; Type: CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.tenant_config
    ADD CONSTRAINT tenant_config_pkey PRIMARY KEY (config_id);


--
-- Name: tenant_config tenant_config_tenant_id_config_key_key; Type: CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.tenant_config
    ADD CONSTRAINT tenant_config_tenant_id_config_key_key UNIQUE (tenant_id, config_key);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (tenant_id);


--
-- Name: tenants tenants_schema_name_key; Type: CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.tenants
    ADD CONSTRAINT tenants_schema_name_key UNIQUE (schema_name);


--
-- Name: tenants tenants_tenant_code_key; Type: CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.tenants
    ADD CONSTRAINT tenants_tenant_code_key UNIQUE (tenant_code);


--
-- Name: whatsapp_templates whatsapp_templates_pkey; Type: CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.whatsapp_templates
    ADD CONSTRAINT whatsapp_templates_pkey PRIMARY KEY (template_id);


--
-- Name: whatsapp_templates whatsapp_templates_template_name_key; Type: CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.whatsapp_templates
    ADD CONSTRAINT whatsapp_templates_template_name_key UNIQUE (template_name);


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
-- Name: idx_customer_behavior_customer; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_customer_behavior_customer ON lic_schema.customer_behavior_metrics USING btree (customer_id, metric_date DESC);


--
-- Name: idx_customer_behavior_date; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_customer_behavior_date ON lic_schema.customer_behavior_metrics USING btree (metric_date DESC);


--
-- Name: idx_daily_kpis_date; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_daily_kpis_date ON lic_schema.daily_dashboard_kpis USING btree (report_date);


--
-- Name: idx_data_export_user; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_data_export_user ON lic_schema.data_export_log USING btree (user_id, created_at DESC);


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
-- Name: idx_user_sessions_active; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_user_sessions_active ON lic_schema.user_sessions USING btree (user_id, expires_at DESC);


--
-- Name: idx_user_sessions_token; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_user_sessions_token ON lic_schema.user_sessions USING btree (session_token);


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
-- Name: idx_video_content_agent; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_video_content_agent ON lic_schema.video_content USING btree (agent_id);


--
-- Name: idx_whatsapp_messages_agent; Type: INDEX; Schema: lic_schema; Owner: -
--

CREATE INDEX idx_whatsapp_messages_agent ON lic_schema.whatsapp_messages USING btree (agent_id);


--
-- Name: ix_presentations_agent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_presentations_agent_id ON public.presentations USING btree (agent_id);


--
-- Name: ix_presentations_is_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_presentations_is_active ON public.presentations USING btree (is_active);


--
-- Name: ix_slides_presentation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_slides_presentation_id ON public.slides USING btree (presentation_id);


--
-- Name: ix_user_sessions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_sessions_user_id ON public.user_sessions USING btree (user_id);


--
-- Name: ix_users_agent_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_users_agent_code ON public.users USING btree (agent_code);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_phone_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_users_phone_number ON public.users USING btree (phone_number);


--
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: shared; Owner: -
--

CREATE INDEX flyway_schema_history_s_idx ON shared.flyway_schema_history USING btree (success);


--
-- Name: idx_countries_country_code; Type: INDEX; Schema: shared; Owner: -
--

CREATE INDEX idx_countries_country_code ON shared.countries USING btree (country_code);


--
-- Name: idx_customer_data_mapping_import; Type: INDEX; Schema: shared; Owner: -
--

CREATE INDEX idx_customer_data_mapping_import ON shared.customer_data_mapping USING btree (import_id);


--
-- Name: idx_data_imports_agent_status; Type: INDEX; Schema: shared; Owner: -
--

CREATE INDEX idx_data_imports_agent_status ON shared.data_imports USING btree (agent_id, status);


--
-- Name: idx_data_sync_status_agent; Type: INDEX; Schema: shared; Owner: -
--

CREATE INDEX idx_data_sync_status_agent ON shared.data_sync_status USING btree (agent_id);


--
-- Name: idx_import_jobs_status; Type: INDEX; Schema: shared; Owner: -
--

CREATE INDEX idx_import_jobs_status ON shared.import_jobs USING btree (status);


--
-- Name: idx_insurance_categories_category_code; Type: INDEX; Schema: shared; Owner: -
--

CREATE INDEX idx_insurance_categories_category_code ON shared.insurance_categories USING btree (category_code);


--
-- Name: idx_insurance_providers_provider_code; Type: INDEX; Schema: shared; Owner: -
--

CREATE INDEX idx_insurance_providers_provider_code ON shared.insurance_providers USING btree (provider_code);


--
-- Name: idx_languages_language_code; Type: INDEX; Schema: shared; Owner: -
--

CREATE INDEX idx_languages_language_code ON shared.languages USING btree (language_code);


--
-- Name: idx_tenant_config_tenant_id; Type: INDEX; Schema: shared; Owner: -
--

CREATE INDEX idx_tenant_config_tenant_id ON shared.tenant_config USING btree (tenant_id);


--
-- Name: idx_tenants_status; Type: INDEX; Schema: shared; Owner: -
--

CREATE INDEX idx_tenants_status ON shared.tenants USING btree (status);


--
-- Name: idx_tenants_tenant_code; Type: INDEX; Schema: shared; Owner: -
--

CREATE INDEX idx_tenants_tenant_code ON shared.tenants USING btree (tenant_code);


--
-- Name: presentation_analytics presentation_analytics_summary_trigger; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER presentation_analytics_summary_trigger AFTER INSERT ON lic_schema.presentation_analytics FOR EACH ROW EXECUTE FUNCTION lic_schema.update_presentation_analytics_summary();


--
-- Name: presentation_slides slide_media_usage_trigger; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER slide_media_usage_trigger AFTER INSERT OR UPDATE ON lic_schema.presentation_slides FOR EACH ROW EXECUTE FUNCTION lic_schema.increment_media_usage();


--
-- Name: insurance_policies update_agent_metrics_trigger; Type: TRIGGER; Schema: lic_schema; Owner: -
--

CREATE TRIGGER update_agent_metrics_trigger AFTER INSERT OR DELETE OR UPDATE ON lic_schema.insurance_policies FOR EACH ROW EXECUTE FUNCTION lic_schema.update_agent_daily_metrics();


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
    ADD CONSTRAINT agents_provider_id_fkey FOREIGN KEY (provider_id) REFERENCES shared.insurance_providers(provider_id);


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
-- Name: customer_behavior_metrics customer_behavior_metrics_customer_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.customer_behavior_metrics
    ADD CONSTRAINT customer_behavior_metrics_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES lic_schema.policyholders(policyholder_id);


--
-- Name: data_export_log data_export_log_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.data_export_log
    ADD CONSTRAINT data_export_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id);


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
-- Name: insurance_policies insurance_policies_provider_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.insurance_policies
    ADD CONSTRAINT insurance_policies_provider_id_fkey FOREIGN KEY (provider_id) REFERENCES shared.insurance_providers(provider_id);


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
-- Name: policyholders policyholders_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.policyholders
    ADD CONSTRAINT policyholders_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: policyholders policyholders_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: -
--

ALTER TABLE ONLY lic_schema.policyholders
    ADD CONSTRAINT policyholders_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


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
-- Name: presentations presentations_agent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.presentations
    ADD CONSTRAINT presentations_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES public.users(user_id);


--
-- Name: presentations presentations_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.presentations
    ADD CONSTRAINT presentations_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.presentation_templates(template_id);


--
-- Name: slides slides_presentation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slides
    ADD CONSTRAINT slides_presentation_id_fkey FOREIGN KEY (presentation_id) REFERENCES public.presentations(presentation_id);


--
-- Name: user_sessions user_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: customer_data_mapping customer_data_mapping_import_id_fkey; Type: FK CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.customer_data_mapping
    ADD CONSTRAINT customer_data_mapping_import_id_fkey FOREIGN KEY (import_id) REFERENCES shared.data_imports(import_id);


--
-- Name: import_jobs import_jobs_import_id_fkey; Type: FK CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.import_jobs
    ADD CONSTRAINT import_jobs_import_id_fkey FOREIGN KEY (import_id) REFERENCES shared.data_imports(import_id);


--
-- Name: tenant_config tenant_config_tenant_id_fkey; Type: FK CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.tenant_config
    ADD CONSTRAINT tenant_config_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES shared.tenants(tenant_id);


--
-- Name: tenants tenants_parent_tenant_id_fkey; Type: FK CONSTRAINT; Schema: shared; Owner: -
--

ALTER TABLE ONLY shared.tenants
    ADD CONSTRAINT tenants_parent_tenant_id_fkey FOREIGN KEY (parent_tenant_id) REFERENCES shared.tenants(tenant_id);


--
-- PostgreSQL database dump complete
--

\unrestrict V87L0OrgafmADxhSMRZpL83xEh0twO5ve1bp3JQXMFfsP2IqmtE5op83fqFySPu

