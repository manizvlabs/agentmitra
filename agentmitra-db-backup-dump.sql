--
-- PostgreSQL database dump
--

\restrict 6unFOBg3CqVSDnvdu6VAjxTgWdHynQ3PsUvvMmFlfVULSGBfHwOjJkxc4NMRgqB

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

DROP DATABASE IF EXISTS agentmitra_dev;
--
-- Name: agentmitra_dev; Type: DATABASE; Schema: -; Owner: agentmitra
--

CREATE DATABASE agentmitra_dev WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C';


ALTER DATABASE agentmitra_dev OWNER TO agentmitra;

\unrestrict 6unFOBg3CqVSDnvdu6VAjxTgWdHynQ3PsUvvMmFlfVULSGBfHwOjJkxc4NMRgqB
\connect agentmitra_dev
\restrict 6unFOBg3CqVSDnvdu6VAjxTgWdHynQ3PsUvvMmFlfVULSGBfHwOjJkxc4NMRgqB

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

--
-- Name: audit; Type: SCHEMA; Schema: -; Owner: agentmitra
--

CREATE SCHEMA audit;


ALTER SCHEMA audit OWNER TO agentmitra;

--
-- Name: SCHEMA audit; Type: COMMENT; Schema: -; Owner: agentmitra
--

COMMENT ON SCHEMA audit IS 'Audit logs and compliance tracking';


--
-- Name: lic_schema; Type: SCHEMA; Schema: -; Owner: agentmitra
--

CREATE SCHEMA lic_schema;


ALTER SCHEMA lic_schema OWNER TO agentmitra;

--
-- Name: SCHEMA lic_schema; Type: COMMENT; Schema: -; Owner: agentmitra
--

COMMENT ON SCHEMA lic_schema IS 'LIC tenant-specific data and business entities';


--
-- Name: shared; Type: SCHEMA; Schema: -; Owner: agentmitra
--

CREATE SCHEMA shared;


ALTER SCHEMA shared OWNER TO agentmitra;

--
-- Name: SCHEMA shared; Type: COMMENT; Schema: -; Owner: agentmitra
--

COMMENT ON SCHEMA shared IS 'Shared reference data and multi-tenant infrastructure';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA shared;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA shared;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA shared;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: agent_status_enum; Type: TYPE; Schema: lic_schema; Owner: agentmitra
--

CREATE TYPE lic_schema.agent_status_enum AS ENUM (
    'active',
    'inactive',
    'suspended',
    'pending_approval',
    'rejected'
);


ALTER TYPE lic_schema.agent_status_enum OWNER TO agentmitra;

--
-- Name: payment_status_enum; Type: TYPE; Schema: lic_schema; Owner: agentmitra
--

CREATE TYPE lic_schema.payment_status_enum AS ENUM (
    'pending',
    'processing',
    'completed',
    'failed',
    'refunded',
    'cancelled'
);


ALTER TYPE lic_schema.payment_status_enum OWNER TO agentmitra;

--
-- Name: policy_status_enum; Type: TYPE; Schema: lic_schema; Owner: agentmitra
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


ALTER TYPE lic_schema.policy_status_enum OWNER TO agentmitra;

--
-- Name: user_role_enum; Type: TYPE; Schema: lic_schema; Owner: agentmitra
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


ALTER TYPE lic_schema.user_role_enum OWNER TO agentmitra;

--
-- Name: user_status_enum; Type: TYPE; Schema: lic_schema; Owner: agentmitra
--

CREATE TYPE lic_schema.user_status_enum AS ENUM (
    'active',
    'inactive',
    'suspended',
    'pending_verification',
    'deactivated'
);


ALTER TYPE lic_schema.user_status_enum OWNER TO agentmitra;

--
-- Name: increment_media_usage(); Type: FUNCTION; Schema: lic_schema; Owner: agentmitra
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


ALTER FUNCTION lic_schema.increment_media_usage() OWNER TO agentmitra;

--
-- Name: log_analytics_query(uuid, character varying, jsonb, integer, integer, inet, text); Type: FUNCTION; Schema: lic_schema; Owner: agentmitra
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


ALTER FUNCTION lic_schema.log_analytics_query(p_user_id uuid, p_query_type character varying, p_query_params jsonb, p_execution_time integer, p_records_returned integer, p_ip_address inet, p_user_agent text) OWNER TO agentmitra;

--
-- Name: refresh_analytics_views(); Type: FUNCTION; Schema: lic_schema; Owner: agentmitra
--

CREATE FUNCTION lic_schema.refresh_analytics_views() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY lic_schema.daily_dashboard_kpis;
    REFRESH MATERIALIZED VIEW CONCURRENTLY lic_schema.agent_leaderboard;
END;
$$;


ALTER FUNCTION lic_schema.refresh_analytics_views() OWNER TO agentmitra;

--
-- Name: update_agent_daily_metrics(); Type: FUNCTION; Schema: lic_schema; Owner: agentmitra
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


ALTER FUNCTION lic_schema.update_agent_daily_metrics() OWNER TO agentmitra;

--
-- Name: update_device_tokens_last_used_at(); Type: FUNCTION; Schema: lic_schema; Owner: agentmitra
--

CREATE FUNCTION lic_schema.update_device_tokens_last_used_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.last_used_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION lic_schema.update_device_tokens_last_used_at() OWNER TO agentmitra;

--
-- Name: update_notification_settings_updated_at(); Type: FUNCTION; Schema: lic_schema; Owner: agentmitra
--

CREATE FUNCTION lic_schema.update_notification_settings_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION lic_schema.update_notification_settings_updated_at() OWNER TO agentmitra;

--
-- Name: update_presentation_analytics_summary(); Type: FUNCTION; Schema: lic_schema; Owner: agentmitra
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


ALTER FUNCTION lic_schema.update_presentation_analytics_summary() OWNER TO agentmitra;

--
-- Name: update_device_tokens_last_used_at(); Type: FUNCTION; Schema: public; Owner: manish
--

CREATE FUNCTION public.update_device_tokens_last_used_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.last_used_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_device_tokens_last_used_at() OWNER TO manish;

--
-- Name: update_notification_settings_updated_at(); Type: FUNCTION; Schema: public; Owner: manish
--

CREATE FUNCTION public.update_notification_settings_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_notification_settings_updated_at() OWNER TO manish;

--
-- Name: update_device_tokens_last_used_at(); Type: FUNCTION; Schema: shared; Owner: manish
--

CREATE FUNCTION shared.update_device_tokens_last_used_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.last_used_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION shared.update_device_tokens_last_used_at() OWNER TO manish;

--
-- Name: update_notification_settings_updated_at(); Type: FUNCTION; Schema: shared; Owner: manish
--

CREATE FUNCTION shared.update_notification_settings_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION shared.update_notification_settings_updated_at() OWNER TO manish;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: agent_daily_metrics; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.agent_daily_metrics OWNER TO agentmitra;

--
-- Name: TABLE agent_daily_metrics; Type: COMMENT; Schema: lic_schema; Owner: agentmitra
--

COMMENT ON TABLE lic_schema.agent_daily_metrics IS 'Daily aggregated performance metrics for agents';


--
-- Name: agents; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.agents OWNER TO agentmitra;

--
-- Name: insurance_policies; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.insurance_policies OWNER TO agentmitra;

--
-- Name: policyholders; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.policyholders OWNER TO agentmitra;

--
-- Name: users; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.users OWNER TO agentmitra;

--
-- Name: agent_leaderboard; Type: MATERIALIZED VIEW; Schema: lic_schema; Owner: agentmitra
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


ALTER MATERIALIZED VIEW lic_schema.agent_leaderboard OWNER TO agentmitra;

--
-- Name: MATERIALIZED VIEW agent_leaderboard; Type: COMMENT; Schema: lic_schema; Owner: agentmitra
--

COMMENT ON MATERIALIZED VIEW lic_schema.agent_leaderboard IS 'Real-time agent performance rankings';


--
-- Name: agent_monthly_summary; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.agent_monthly_summary OWNER TO agentmitra;

--
-- Name: agent_presentation_preferences; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.agent_presentation_preferences OWNER TO agentmitra;

--
-- Name: analytics_query_log; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.analytics_query_log OWNER TO agentmitra;

--
-- Name: chat_messages; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.chat_messages OWNER TO agentmitra;

--
-- Name: chatbot_analytics_summary; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.chatbot_analytics_summary OWNER TO agentmitra;

--
-- Name: TABLE chatbot_analytics_summary; Type: COMMENT; Schema: lic_schema; Owner: agentmitra
--

COMMENT ON TABLE lic_schema.chatbot_analytics_summary IS 'Daily/weekly/monthly chatbot performance analytics';


--
-- Name: chatbot_intents; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.chatbot_intents OWNER TO agentmitra;

--
-- Name: chatbot_sessions; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.chatbot_sessions OWNER TO agentmitra;

--
-- Name: countries; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.countries OWNER TO agentmitra;

--
-- Name: customer_behavior_metrics; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.customer_behavior_metrics OWNER TO agentmitra;

--
-- Name: customer_data_mapping; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.customer_data_mapping OWNER TO agentmitra;

--
-- Name: daily_dashboard_kpis; Type: MATERIALIZED VIEW; Schema: lic_schema; Owner: agentmitra
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


ALTER MATERIALIZED VIEW lic_schema.daily_dashboard_kpis OWNER TO agentmitra;

--
-- Name: MATERIALIZED VIEW daily_dashboard_kpis; Type: COMMENT; Schema: lic_schema; Owner: agentmitra
--

COMMENT ON MATERIALIZED VIEW lic_schema.daily_dashboard_kpis IS 'Pre-computed dashboard KPIs for fast loading';


--
-- Name: data_export_log; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.data_export_log OWNER TO agentmitra;

--
-- Name: data_imports; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.data_imports OWNER TO agentmitra;

--
-- Name: data_sync_status; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.data_sync_status OWNER TO agentmitra;

--
-- Name: device_tokens; Type: TABLE; Schema: lic_schema; Owner: agentmitra
--

CREATE TABLE lic_schema.device_tokens (
    id integer NOT NULL,
    user_id uuid NOT NULL,
    token character varying(255) NOT NULL,
    device_type character varying(20) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_used_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE lic_schema.device_tokens OWNER TO agentmitra;

--
-- Name: device_tokens_id_seq; Type: SEQUENCE; Schema: lic_schema; Owner: agentmitra
--

CREATE SEQUENCE lic_schema.device_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE lic_schema.device_tokens_id_seq OWNER TO agentmitra;

--
-- Name: device_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: lic_schema; Owner: agentmitra
--

ALTER SEQUENCE lic_schema.device_tokens_id_seq OWNED BY lic_schema.device_tokens.id;


--
-- Name: flyway_schema_history; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.flyway_schema_history OWNER TO agentmitra;

--
-- Name: import_jobs; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.import_jobs OWNER TO agentmitra;

--
-- Name: insurance_categories; Type: TABLE; Schema: lic_schema; Owner: agentmitra
--

CREATE TABLE lic_schema.insurance_categories (
    category_id uuid DEFAULT gen_random_uuid() NOT NULL,
    category_code character varying(20) NOT NULL,
    category_name character varying(100) NOT NULL,
    category_type character varying(50),
    description text,
    status character varying(20) DEFAULT 'active'::character varying
);


ALTER TABLE lic_schema.insurance_categories OWNER TO agentmitra;

--
-- Name: insurance_providers; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.insurance_providers OWNER TO agentmitra;

--
-- Name: knowledge_base_articles; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.knowledge_base_articles OWNER TO agentmitra;

--
-- Name: TABLE knowledge_base_articles; Type: COMMENT; Schema: lic_schema; Owner: agentmitra
--

COMMENT ON TABLE lic_schema.knowledge_base_articles IS 'AI-powered knowledge base for chatbot and user support';


--
-- Name: knowledge_search_log; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.knowledge_search_log OWNER TO agentmitra;

--
-- Name: languages; Type: TABLE; Schema: lic_schema; Owner: agentmitra
--

CREATE TABLE lic_schema.languages (
    language_id uuid DEFAULT gen_random_uuid() NOT NULL,
    language_code character varying(10) NOT NULL,
    language_name character varying(100) NOT NULL,
    native_name character varying(100),
    rtl boolean DEFAULT false,
    status character varying(20) DEFAULT 'active'::character varying
);


ALTER TABLE lic_schema.languages OWNER TO agentmitra;

--
-- Name: notification_settings; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.notification_settings OWNER TO agentmitra;

--
-- Name: notification_settings_id_seq; Type: SEQUENCE; Schema: lic_schema; Owner: agentmitra
--

CREATE SEQUENCE lic_schema.notification_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE lic_schema.notification_settings_id_seq OWNER TO agentmitra;

--
-- Name: notification_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: lic_schema; Owner: agentmitra
--

ALTER SEQUENCE lic_schema.notification_settings_id_seq OWNED BY lic_schema.notification_settings.id;


--
-- Name: notifications; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.notifications OWNER TO agentmitra;

--
-- Name: permissions; Type: TABLE; Schema: lic_schema; Owner: agentmitra
--

CREATE TABLE lic_schema.permissions (
    permission_id uuid DEFAULT gen_random_uuid() NOT NULL,
    permission_name character varying(100) NOT NULL,
    permission_description text,
    resource_type character varying(50),
    action character varying(50),
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE lic_schema.permissions OWNER TO agentmitra;

--
-- Name: policy_analytics_summary; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.policy_analytics_summary OWNER TO agentmitra;

--
-- Name: premium_payments; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.premium_payments OWNER TO agentmitra;

--
-- Name: presentation_analytics; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.presentation_analytics OWNER TO agentmitra;

--
-- Name: presentation_media; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.presentation_media OWNER TO agentmitra;

--
-- Name: presentation_slides; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.presentation_slides OWNER TO agentmitra;

--
-- Name: presentation_templates; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.presentation_templates OWNER TO agentmitra;

--
-- Name: presentations; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.presentations OWNER TO agentmitra;

--
-- Name: revenue_forecasts; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.revenue_forecasts OWNER TO agentmitra;

--
-- Name: TABLE revenue_forecasts; Type: COMMENT; Schema: lic_schema; Owner: agentmitra
--

COMMENT ON TABLE lic_schema.revenue_forecasts IS 'Revenue and commission forecasting data';


--
-- Name: role_permissions; Type: TABLE; Schema: lic_schema; Owner: agentmitra
--

CREATE TABLE lic_schema.role_permissions (
    assignment_id uuid DEFAULT gen_random_uuid() NOT NULL,
    role_id uuid,
    permission_id uuid,
    granted_at timestamp without time zone DEFAULT now()
);


ALTER TABLE lic_schema.role_permissions OWNER TO agentmitra;

--
-- Name: roles; Type: TABLE; Schema: lic_schema; Owner: agentmitra
--

CREATE TABLE lic_schema.roles (
    role_id uuid DEFAULT gen_random_uuid() NOT NULL,
    role_name character varying(100) NOT NULL,
    role_description text,
    is_system_role boolean DEFAULT false,
    permissions jsonb,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE lic_schema.roles OWNER TO agentmitra;

--
-- Name: tenant_config; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.tenant_config OWNER TO agentmitra;

--
-- Name: tenants; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.tenants OWNER TO agentmitra;

--
-- Name: user_payment_methods; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.user_payment_methods OWNER TO agentmitra;

--
-- Name: user_roles; Type: TABLE; Schema: lic_schema; Owner: agentmitra
--

CREATE TABLE lic_schema.user_roles (
    assignment_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    role_id uuid,
    assigned_by uuid,
    assigned_at timestamp without time zone DEFAULT now(),
    expires_at timestamp without time zone
);


ALTER TABLE lic_schema.user_roles OWNER TO agentmitra;

--
-- Name: user_sessions; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.user_sessions OWNER TO agentmitra;

--
-- Name: COLUMN user_sessions.session_token; Type: COMMENT; Schema: lic_schema; Owner: agentmitra
--

COMMENT ON COLUMN lic_schema.user_sessions.session_token IS 'JWT access token (stored as TEXT to accommodate full token length)';


--
-- Name: COLUMN user_sessions.refresh_token; Type: COMMENT; Schema: lic_schema; Owner: agentmitra
--

COMMENT ON COLUMN lic_schema.user_sessions.refresh_token IS 'JWT refresh token (stored as TEXT to accommodate full token length)';


--
-- Name: video_content; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.video_content OWNER TO agentmitra;

--
-- Name: whatsapp_messages; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.whatsapp_messages OWNER TO agentmitra;

--
-- Name: whatsapp_templates; Type: TABLE; Schema: lic_schema; Owner: agentmitra
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


ALTER TABLE lic_schema.whatsapp_templates OWNER TO agentmitra;

--
-- Name: presentation_templates; Type: TABLE; Schema: public; Owner: agentmitra
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


ALTER TABLE public.presentation_templates OWNER TO agentmitra;

--
-- Name: presentations; Type: TABLE; Schema: public; Owner: agentmitra
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


ALTER TABLE public.presentations OWNER TO agentmitra;

--
-- Name: slides; Type: TABLE; Schema: public; Owner: agentmitra
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


ALTER TABLE public.slides OWNER TO agentmitra;

--
-- Name: user_sessions; Type: TABLE; Schema: public; Owner: agentmitra
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


ALTER TABLE public.user_sessions OWNER TO agentmitra;

--
-- Name: users; Type: TABLE; Schema: public; Owner: agentmitra
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


ALTER TABLE public.users OWNER TO agentmitra;

--
-- Name: countries; Type: TABLE; Schema: shared; Owner: agentmitra
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


ALTER TABLE shared.countries OWNER TO agentmitra;

--
-- Name: customer_data_mapping; Type: TABLE; Schema: shared; Owner: agentmitra
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


ALTER TABLE shared.customer_data_mapping OWNER TO agentmitra;

--
-- Name: data_imports; Type: TABLE; Schema: shared; Owner: agentmitra
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


ALTER TABLE shared.data_imports OWNER TO agentmitra;

--
-- Name: data_sync_status; Type: TABLE; Schema: shared; Owner: agentmitra
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


ALTER TABLE shared.data_sync_status OWNER TO agentmitra;

--
-- Name: flyway_schema_history; Type: TABLE; Schema: shared; Owner: agentmitra
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


ALTER TABLE shared.flyway_schema_history OWNER TO agentmitra;

--
-- Name: import_jobs; Type: TABLE; Schema: shared; Owner: agentmitra
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


ALTER TABLE shared.import_jobs OWNER TO agentmitra;

--
-- Name: insurance_categories; Type: TABLE; Schema: shared; Owner: agentmitra
--

CREATE TABLE shared.insurance_categories (
    category_id uuid DEFAULT gen_random_uuid() NOT NULL,
    category_code character varying(20) NOT NULL,
    category_name character varying(100) NOT NULL,
    category_type character varying(50),
    description text,
    status character varying(20) DEFAULT 'active'::character varying
);


ALTER TABLE shared.insurance_categories OWNER TO agentmitra;

--
-- Name: insurance_providers; Type: TABLE; Schema: shared; Owner: agentmitra
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


ALTER TABLE shared.insurance_providers OWNER TO agentmitra;

--
-- Name: languages; Type: TABLE; Schema: shared; Owner: agentmitra
--

CREATE TABLE shared.languages (
    language_id uuid DEFAULT gen_random_uuid() NOT NULL,
    language_code character varying(10) NOT NULL,
    language_name character varying(100) NOT NULL,
    native_name character varying(100),
    rtl boolean DEFAULT false,
    status character varying(20) DEFAULT 'active'::character varying
);


ALTER TABLE shared.languages OWNER TO agentmitra;

--
-- Name: tenant_config; Type: TABLE; Schema: shared; Owner: agentmitra
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


ALTER TABLE shared.tenant_config OWNER TO agentmitra;

--
-- Name: tenants; Type: TABLE; Schema: shared; Owner: agentmitra
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


ALTER TABLE shared.tenants OWNER TO agentmitra;

--
-- Name: whatsapp_templates; Type: TABLE; Schema: shared; Owner: agentmitra
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


ALTER TABLE shared.whatsapp_templates OWNER TO agentmitra;

--
-- Name: device_tokens id; Type: DEFAULT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.device_tokens ALTER COLUMN id SET DEFAULT nextval('lic_schema.device_tokens_id_seq'::regclass);


--
-- Name: notification_settings id; Type: DEFAULT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.notification_settings ALTER COLUMN id SET DEFAULT nextval('lic_schema.notification_settings_id_seq'::regclass);


--
-- Data for Name: agent_daily_metrics; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.agent_daily_metrics (metric_id, agent_id, metric_date, policies_sold, premium_collected, active_policyholders, new_customers, commission_earned, target_achievement, customer_satisfaction_score, conversion_rate, presentations_viewed, cta_clicks, whatsapp_messages_sent, created_at, updated_at) FROM stdin;
44b9d3cf-89dd-412e-ba74-793fdc9f71fa	1a4c8c40-d885-4c6d-b39a-8a42e3b4652d	2025-11-23	1	25000.00	1	0	0.00	0.00	\N	\N	0	0	0	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
12a235d3-f10d-4cbc-8c56-b7754ffe2ea3	f580839c-4af3-4ebb-9935-bdb8c7acf7b6	2025-11-23	1	30000.00	1	0	0.00	0.00	\N	\N	0	0	0	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
35eb4f24-0a8a-4d59-bf8b-d5133ef7fa2b	991e6172-dcd1-4ca7-9c82-85cbbd14f6b3	2025-11-23	1	35000.00	1	0	0.00	0.00	\N	\N	0	0	0	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
e50d2271-b472-4947-8c2a-107e33b1e209	e2038ed1-cedc-4be8-9055-ef3a66bb1907	2025-11-23	1	20000.00	1	0	0.00	0.00	\N	\N	0	0	0	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
abccf33c-b084-44ec-87bf-1f03d44a3dbf	ff5e562b-9a46-4a04-81d1-ce54e425acbd	2025-11-23	1	15000.00	1	1	0.00	0.00	\N	\N	0	0	0	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
4254f0d1-c027-4fae-8ee5-323ecd2702a3	bd40bf61-c2ad-4071-b868-ad54ab7cfa8d	2025-11-23	1	28000.00	1	0	0.00	0.00	\N	\N	0	0	0	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
ce08fb8c-cde3-4da0-a84c-03f2ccb6f947	e45c1148-56b7-4605-b183-68ea7aec4383	2025-11-23	1	40000.00	1	0	0.00	0.00	\N	\N	0	0	0	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
1beb351e-d8b0-43c4-b926-9d6bbfbce718	91ad72ed-42d2-46ad-8338-4d22d8f7c80f	2025-11-23	1	25000.00	1	0	0.00	0.00	\N	\N	0	0	0	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
1b7dbe89-eacb-4f49-9ecb-ebe1556a7059	da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec	2025-11-23	1	35000.00	1	0	0.00	0.00	\N	\N	0	0	0	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
c1c8b21c-227e-4b10-a4ef-6ea96219aaf2	c47a7151-d764-4ad0-85ed-a2dc7c4d5ef3	2025-11-23	1	45000.00	1	0	0.00	0.00	\N	\N	0	0	0	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
\.


--
-- Data for Name: agent_monthly_summary; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.agent_monthly_summary (summary_id, agent_id, summary_month, total_policies, total_premium, total_commission, active_customers, growth_rate, retention_rate, rank_by_premium, rank_by_policies, created_at) FROM stdin;
b49b4e4d-3a33-4741-9487-587372b2edfc	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-01	8	171466.81	29554.78	24	3.31	\N	6	8	2025-11-24 10:28:30.859344
6619b5d1-fd5d-4208-af63-50505ea7d218	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-10-01	14	165116.99	26806.96	12	-4.23	\N	5	6	2025-11-24 10:28:30.859344
7a7ebc23-46ed-4c72-8f1a-0508cc16b771	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-09-01	20	187364.00	5695.23	15	8.97	\N	10	10	2025-11-24 10:28:30.859344
744d0e1b-d81f-4193-b979-4d6bbc07e840	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-08-01	11	232622.29	11698.91	25	-7.74	\N	3	9	2025-11-24 10:28:30.859344
e2227460-9e54-44de-929d-4a480bffb614	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-07-01	16	183871.05	17463.01	24	-4.00	\N	4	8	2025-11-24 10:28:30.859344
d4c9698e-6e7a-4b23-ab87-e919b8627e0c	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-06-01	13	147500.70	23137.94	8	8.99	\N	2	4	2025-11-24 10:28:30.859344
e01de46a-6625-46a5-9723-7f0405b9f523	1a4c8c40-d885-4c6d-b39a-8a42e3b4652d	2025-11-01	17	102928.81	5114.38	27	9.04	\N	9	1	2025-11-24 10:28:30.859344
eb232273-d161-4a1f-ab42-0f79da9ec21d	1a4c8c40-d885-4c6d-b39a-8a42e3b4652d	2025-10-01	8	61000.10	7640.29	23	4.12	\N	6	6	2025-11-24 10:28:30.859344
2e10fc3d-d527-4d34-9cbf-789e04596bb8	1a4c8c40-d885-4c6d-b39a-8a42e3b4652d	2025-09-01	17	188705.30	6679.02	25	-5.49	\N	11	10	2025-11-24 10:28:30.859344
18382a50-640d-4b81-9821-5aa4e0a9cdfc	1a4c8c40-d885-4c6d-b39a-8a42e3b4652d	2025-08-01	6	177470.71	18991.61	12	8.66	\N	9	7	2025-11-24 10:28:30.859344
02db69c6-6bd0-4da0-8fd8-826a71c14eeb	1a4c8c40-d885-4c6d-b39a-8a42e3b4652d	2025-07-01	10	231987.65	20536.24	22	1.67	\N	10	4	2025-11-24 10:28:30.859344
eb168b3e-9a0d-4e6c-a01b-2b7b21962a21	1a4c8c40-d885-4c6d-b39a-8a42e3b4652d	2025-06-01	18	217544.30	11203.45	26	7.46	\N	10	9	2025-11-24 10:28:30.859344
23646407-4312-4e6f-a7c9-bbf90deceb06	f580839c-4af3-4ebb-9935-bdb8c7acf7b6	2025-11-01	17	131564.59	19052.42	23	-2.39	\N	6	3	2025-11-24 10:28:30.859344
d599ac97-bd32-4385-9d65-30f0bfe6b5c9	f580839c-4af3-4ebb-9935-bdb8c7acf7b6	2025-10-01	11	101525.47	28964.56	20	3.56	\N	1	2	2025-11-24 10:28:30.859344
626c49f0-5ebd-4b84-a531-cad1aa423c3b	f580839c-4af3-4ebb-9935-bdb8c7acf7b6	2025-09-01	12	60854.67	24176.89	15	-6.98	\N	4	11	2025-11-24 10:28:30.859344
7ac27e64-90c7-464f-8c2c-bad3a6de03dc	f580839c-4af3-4ebb-9935-bdb8c7acf7b6	2025-08-01	17	95625.66	18747.56	9	-9.17	\N	1	10	2025-11-24 10:28:30.859344
a749896d-52b4-4296-a728-956d11649ca3	f580839c-4af3-4ebb-9935-bdb8c7acf7b6	2025-07-01	7	237584.45	7136.12	14	-3.74	\N	4	7	2025-11-24 10:28:30.859344
ab3aaff0-89f2-4f08-80e2-e9faeba10a67	f580839c-4af3-4ebb-9935-bdb8c7acf7b6	2025-06-01	17	137253.69	11170.23	19	-6.63	\N	1	10	2025-11-24 10:28:30.859344
a829db4e-1c8e-4277-a666-b797c40e2455	991e6172-dcd1-4ca7-9c82-85cbbd14f6b3	2025-11-01	6	51322.24	22733.52	25	-2.15	\N	11	5	2025-11-24 10:28:30.859344
fc4ec13d-50ac-4333-8849-e4b7ee6b5fb6	991e6172-dcd1-4ca7-9c82-85cbbd14f6b3	2025-10-01	20	165486.85	24206.17	22	-8.30	\N	5	3	2025-11-24 10:28:30.859344
b67d05a7-8d55-455b-b44e-ff01dfaa5e7c	991e6172-dcd1-4ca7-9c82-85cbbd14f6b3	2025-09-01	12	131186.31	14678.04	15	7.70	\N	10	3	2025-11-24 10:28:30.859344
e58d0a59-b176-45f8-9774-5aee0e27f35a	991e6172-dcd1-4ca7-9c82-85cbbd14f6b3	2025-08-01	6	214662.72	15066.96	9	-4.84	\N	5	6	2025-11-24 10:28:30.859344
70a380d4-ccce-4357-9c37-59c6f2ea760d	991e6172-dcd1-4ca7-9c82-85cbbd14f6b3	2025-07-01	12	238633.09	7434.45	18	-9.55	\N	4	4	2025-11-24 10:28:30.859344
6138a7e3-398f-4430-a98d-961afedd385f	991e6172-dcd1-4ca7-9c82-85cbbd14f6b3	2025-06-01	9	170989.72	22819.96	27	-1.79	\N	3	7	2025-11-24 10:28:30.859344
fdc4ce67-3616-46da-9cb5-dc1cf0aaa4be	e2038ed1-cedc-4be8-9055-ef3a66bb1907	2025-11-01	13	218246.44	8627.90	11	-8.88	\N	2	3	2025-11-24 10:28:30.859344
9701bfa2-fd25-4994-b49d-139544e19b83	e2038ed1-cedc-4be8-9055-ef3a66bb1907	2025-10-01	11	181468.50	20575.64	9	9.20	\N	4	8	2025-11-24 10:28:30.859344
ca67d686-3580-492a-b7ce-43c82393005e	e2038ed1-cedc-4be8-9055-ef3a66bb1907	2025-09-01	10	86709.10	8065.80	24	-7.07	\N	6	7	2025-11-24 10:28:30.859344
ca39fae8-c897-4362-b1e8-b289b3e738d7	e2038ed1-cedc-4be8-9055-ef3a66bb1907	2025-08-01	12	118013.47	10788.75	12	1.35	\N	8	10	2025-11-24 10:28:30.859344
1c12cd85-f2c4-416b-8962-81fcda7e458d	e2038ed1-cedc-4be8-9055-ef3a66bb1907	2025-07-01	15	116755.97	12034.47	24	-6.95	\N	3	2	2025-11-24 10:28:30.859344
3bc2c074-131a-49c8-9450-584489889129	e2038ed1-cedc-4be8-9055-ef3a66bb1907	2025-06-01	19	94734.63	5987.60	16	-0.85	\N	4	11	2025-11-24 10:28:30.859344
\.


--
-- Data for Name: agent_presentation_preferences; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.agent_presentation_preferences (preference_id, agent_id, default_text_color, default_background_color, default_layout, default_duration, logo_url, brand_colors, auto_add_logo, auto_add_contact_cta, contact_cta_text, editor_theme, show_preview_by_default, auto_save_enabled, auto_save_interval_seconds, created_at, updated_at) FROM stdin;
30bda36d-cf02-4f3d-9866-cd013ab3421d	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	#FFFFFF	#1a365d	grid	5	\N	["#1a365d", "#2d3748", "#4a5568", "#718096", "#e2e8f0"]	t	t	Contact Me	light	t	t	71	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
12ffc600-d03a-4f41-aa83-023e7d2abb5a	1a4c8c40-d885-4c6d-b39a-8a42e3b4652d	#000000	#2d3748	left_aligned	6	\N	["#1a365d", "#2d3748", "#4a5568", "#718096", "#e2e8f0"]	t	t	Talk to Agent	light	t	t	87	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
3ad1ff45-f4ff-459e-bae0-e5f40359a851	f580839c-4af3-4ebb-9935-bdb8c7acf7b6	#333333	#000000	grid	7	https://cdn.agentmitra.com/logos/f580839c-4af3-4ebb-9935-bdb8c7acf7b6.png	["#1a365d", "#2d3748", "#4a5568", "#718096", "#e2e8f0"]	t	t	Talk to Agent	light	t	t	65	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
662c5a53-4a91-456e-8f82-2abe52bdf6a9	991e6172-dcd1-4ca7-9c82-85cbbd14f6b3	#333333	#2d3748	grid	6	https://cdn.agentmitra.com/logos/991e6172-dcd1-4ca7-9c82-85cbbd14f6b3.png	["#1a365d", "#2d3748", "#4a5568", "#718096", "#e2e8f0"]	t	t	Get Quote	light	t	t	72	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
4e6cfdbf-8195-4a8e-853f-b0e33e6ee0bc	e2038ed1-cedc-4be8-9055-ef3a66bb1907	#000000	#2d3748	grid	4	\N	["#1a365d", "#2d3748", "#4a5568", "#718096", "#e2e8f0"]	t	t	Get Quote	light	t	t	35	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
521c423f-7a14-452c-85b7-b86d2e503080	ff5e562b-9a46-4a04-81d1-ce54e425acbd	#333333	#2d3748	grid	6	https://cdn.agentmitra.com/logos/ff5e562b-9a46-4a04-81d1-ce54e425acbd.png	["#1a365d", "#2d3748", "#4a5568", "#718096", "#e2e8f0"]	t	t	Talk to Agent	dark	f	t	69	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
9c7d20a5-5dae-4a8c-9e86-9e85b3c49421	bd40bf61-c2ad-4071-b868-ad54ab7cfa8d	#000000	#2d3748	left_aligned	5	https://cdn.agentmitra.com/logos/bd40bf61-c2ad-4071-b868-ad54ab7cfa8d.png	["#1a365d", "#2d3748", "#4a5568", "#718096", "#e2e8f0"]	f	t	Get Quote	light	f	t	43	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
d30fcc55-9b87-49cc-9255-e0c7a01dc174	e45c1148-56b7-4605-b183-68ea7aec4383	#000000	#2d3748	grid	3	https://cdn.agentmitra.com/logos/e45c1148-56b7-4605-b183-68ea7aec4383.png	["#1a365d", "#2d3748", "#4a5568", "#718096", "#e2e8f0"]	f	t	Talk to Agent	light	f	t	30	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
7d25ba35-bd43-475b-a29d-466d7d9b2e06	91ad72ed-42d2-46ad-8338-4d22d8f7c80f	#FFFFFF	#2d3748	left_aligned	4	https://cdn.agentmitra.com/logos/91ad72ed-42d2-46ad-8338-4d22d8f7c80f.png	["#1a365d", "#2d3748", "#4a5568", "#718096", "#e2e8f0"]	t	t	Talk to Agent	dark	t	t	50	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
5a783667-d4be-409c-9abb-b926a17e76fd	da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec	#000000	#1a365d	left_aligned	3	https://cdn.agentmitra.com/logos/da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec.png	["#1a365d", "#2d3748", "#4a5568", "#718096", "#e2e8f0"]	t	t	Talk to Agent	light	t	t	46	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
\.


--
-- Data for Name: agents; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.agents (agent_id, user_id, provider_id, agent_code, license_number, license_expiry_date, license_issuing_authority, business_name, business_address, gst_number, pan_number, territory, operating_regions, experience_years, specializations, commission_rate, commission_structure, performance_bonus_structure, whatsapp_business_number, business_email, website, total_policies_sold, total_premium_collected, active_policyholders, customer_satisfaction_score, parent_agent_id, hierarchy_level, sub_agents_count, status, verification_status, approved_at, approved_by, created_at, updated_at) FROM stdin;
b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	AGENT001	LIC123456	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	43500.00	2	4.50	\N	1	0	active	pending	\N	\N	2025-11-23 22:34:55.683807	2025-11-23 22:34:55.683807
1a4c8c40-d885-4c6d-b39a-8a42e3b4652d	ddeee6e1-757f-4220-ad26-649bd9fd2987	f6613f86-3bb5-49fe-875a-036c21e73800	SEED_AG001	LIC_SEED_001	2026-11-23	\N	Seed Agency 1	\N	\N	\N	Mumbai	\N	\N	\N	5.00	\N	\N	\N	\N	\N	25	500000.00	0	\N	\N	1	0	active	pending	\N	\N	2025-09-24 23:19:48.514481	2025-11-23 23:19:48.514481
f580839c-4af3-4ebb-9935-bdb8c7acf7b6	5fbb7605-85a8-40b1-9e6e-ec405d8af18c	ddf40160-5705-422d-b887-4881972c16cf	SEED_AG002	HDFC_SEED_002	2026-11-23	\N	Seed Agency 2	\N	\N	\N	Delhi	\N	\N	\N	7.50	\N	\N	\N	\N	\N	45	900000.00	0	\N	\N	1	0	active	pending	\N	\N	2025-09-29 23:19:48.514481	2025-11-23 23:19:48.514481
991e6172-dcd1-4ca7-9c82-85cbbd14f6b3	045a6ed3-c48b-4d1c-ac86-8776bda0050f	cd28c1b2-e5b4-4162-b63e-4ee70a7414f3	SEED_AG003	ICICI_SEED_003	2026-11-23	\N	Seed Agency 3	\N	\N	\N	Bangalore	\N	\N	\N	10.00	\N	\N	\N	\N	\N	80	1600000.00	0	\N	\N	1	0	active	pending	\N	\N	2025-10-04 23:19:48.514481	2025-11-23 23:19:48.514481
e2038ed1-cedc-4be8-9055-ef3a66bb1907	0f2661d8-afb2-4f27-ad77-e0bfda097352	926e6011-18ab-41d3-9512-c47b4ef4deae	SEED_AG004	BAJAJ_SEED_004	2026-11-23	\N	Seed Agency 4	\N	\N	\N	Chennai	\N	\N	\N	4.50	\N	\N	\N	\N	\N	15	300000.00	0	\N	\N	1	0	active	pending	\N	\N	2025-10-09 23:19:48.514481	2025-11-23 23:19:48.514481
ff5e562b-9a46-4a04-81d1-ce54e425acbd	ddeee6e1-757f-4220-ad26-649bd9fd2987	a34a0c15-1337-4c21-8b1d-77f0c0409b91	SEED_AG005	SBI_SEED_005	2026-11-23	\N	Seed Agency 5	\N	\N	\N	Pune	\N	\N	\N	6.50	\N	\N	\N	\N	\N	35	700000.00	0	\N	\N	1	0	active	pending	\N	\N	2025-10-14 23:19:48.514481	2025-11-23 23:19:48.514481
bd40bf61-c2ad-4071-b868-ad54ab7cfa8d	5fbb7605-85a8-40b1-9e6e-ec405d8af18c	0e496781-cdc8-47ff-8c0e-adf1e48159df	SEED_AG006	TATA_SEED_006	2026-11-23	\N	Seed Agency 6	\N	\N	\N	Hyderabad	\N	\N	\N	5.50	\N	\N	\N	\N	\N	28	560000.00	0	\N	\N	1	0	active	pending	\N	\N	2025-10-19 23:19:48.514481	2025-11-23 23:19:48.514481
e45c1148-56b7-4605-b183-68ea7aec4383	045a6ed3-c48b-4d1c-ac86-8776bda0050f	bdf7b8b9-7467-4979-b72e-d3c6a92e70a4	SEED_AG007	MAX_SEED_007	2026-11-23	\N	Seed Agency 7	\N	\N	\N	Kolkata	\N	\N	\N	8.50	\N	\N	\N	\N	\N	65	1300000.00	0	\N	\N	1	0	active	pending	\N	\N	2025-10-24 23:19:48.514481	2025-11-23 23:19:48.514481
91ad72ed-42d2-46ad-8338-4d22d8f7c80f	0f2661d8-afb2-4f27-ad77-e0bfda097352	1c59a1d5-e9b4-4286-b2da-4eccbf101e80	SEED_AG008	PNB_SEED_008	2026-11-23	\N	Seed Agency 8	\N	\N	\N	Ahmedabad	\N	\N	\N	7.00	\N	\N	\N	\N	\N	42	840000.00	0	\N	\N	1	0	active	pending	\N	\N	2025-10-29 23:19:48.514481	2025-11-23 23:19:48.514481
da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec	ddeee6e1-757f-4220-ad26-649bd9fd2987	2ba6a4f1-cca1-49a0-bb66-94c68e1a4347	SEED_AG009	ADITYA_SEED_009	2026-11-23	\N	Seed Agency 9	\N	\N	\N	Jaipur	\N	\N	\N	5.00	\N	\N	\N	\N	\N	22	440000.00	0	\N	\N	1	0	active	pending	\N	\N	2025-11-03 23:19:48.514481	2025-11-23 23:19:48.514481
c47a7151-d764-4ad0-85ed-a2dc7c4d5ef3	5fbb7605-85a8-40b1-9e6e-ec405d8af18c	bca25ad9-b8b1-49bb-ab2a-7438b087e97d	SEED_AG010	KOTAK_SEED_010	2026-11-23	\N	Seed Agency 10	\N	\N	\N	Surat	\N	\N	\N	6.00	\N	\N	\N	\N	\N	38	760000.00	0	\N	\N	1	0	active	pending	\N	\N	2025-11-08 23:19:48.514481	2025-11-23 23:19:48.514481
d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	01fa8d3a-5509-4f73-abeb-617fd547f16d	AGENT002	LIC234567	\N	\N	Senior Insurance Solutions	{"city": "Mumbai", "state": "Maharashtra", "pincode": "400001"}	\N	\N	Mumbai Central	\N	8	{life_insurance,health_insurance}	5.50	\N	\N	\N	\N	\N	2	75000.00	2	4.70	\N	1	0	active	approved	\N	\N	2025-11-23 22:34:55.73505	2025-11-23 22:34:55.73505
d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	01fa8d3a-5509-4f73-abeb-617fd547f16d	AGENT003	LIC345678	\N	\N	Regional Insurance Hub	{"city": "Pune", "state": "Maharashtra", "pincode": "411001"}	\N	\N	Pune Region	\N	12	{term_life,ulip,retirement}	7.00	\N	\N	\N	\N	\N	1	50000.00	1	4.80	\N	1	0	active	approved	\N	\N	2025-11-23 22:34:55.73505	2025-11-23 22:34:55.73505
\.


--
-- Data for Name: analytics_query_log; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.analytics_query_log (log_id, user_id, query_type, query_parameters, execution_time_ms, records_returned, ip_address, user_agent, data_classification, access_reason, created_at) FROM stdin;
8fee74a2-a1f3-4eda-b241-b46db5b65bc3	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	export	{"filters": {"agent_id": "da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec", "date_range": "last_30_days", "policy_type": "term_life"}, "metrics": ["policies_sold", "premium_collected", "customer_satisfaction"]}	1875	496	192.168.1.17	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36	confidential	Business intelligence and performance monitoring	2025-11-24 10:28:30.859344
505f57fb-41ca-4e8a-a31f-d7990b6416b4	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	export	{"filters": {"agent_id": "f580839c-4af3-4ebb-9935-bdb8c7acf7b6", "date_range": "last_30_days", "policy_type": "term_life"}, "metrics": ["policies_sold", "premium_collected", "customer_satisfaction"]}	2170	424	192.168.1.24	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36	public	Business intelligence and performance monitoring	2025-11-24 10:28:30.859344
6db07c5f-5817-4a5c-bee4-0786f6b11d30	045a6ed3-c48b-4d1c-ac86-8776bda0050f	report	{"filters": {"agent_id": "e45c1148-56b7-4605-b183-68ea7aec4383", "date_range": "last_30_days", "policy_type": "term_life"}, "metrics": ["policies_sold", "premium_collected", "customer_satisfaction"]}	547	430	192.168.1.146	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36	internal	Business intelligence and performance monitoring	2025-11-24 10:28:30.859344
86bb20be-c429-45a2-955b-b515835c8e98	2da28562-c8be-4dd6-b0ee-5b1863ea66c4	export	{"filters": {"agent_id": "c47a7151-d764-4ad0-85ed-a2dc7c4d5ef3", "date_range": "last_30_days", "policy_type": "term_life"}, "metrics": ["policies_sold", "premium_collected", "customer_satisfaction"]}	2389	364	192.168.1.14	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36	confidential	Business intelligence and performance monitoring	2025-11-24 10:28:30.859344
daed89c7-a482-4382-8811-6682e92db8a0	5fbb7605-85a8-40b1-9e6e-ec405d8af18c	report	{"filters": {"agent_id": "991e6172-dcd1-4ca7-9c82-85cbbd14f6b3", "date_range": "last_30_days", "policy_type": "term_life"}, "metrics": ["policies_sold", "premium_collected", "customer_satisfaction"]}	1120	74	192.168.1.206	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36	confidential	Business intelligence and performance monitoring	2025-11-24 10:28:30.859344
994508c6-1781-4201-bec3-ecbb1681198f	ea5b10ca-f6dc-4922-901e-8beb02496510	export	{"filters": {"agent_id": "bd40bf61-c2ad-4071-b868-ad54ab7cfa8d", "date_range": "last_30_days", "policy_type": "term_life"}, "metrics": ["policies_sold", "premium_collected", "customer_satisfaction"]}	1366	193	192.168.1.39	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36	confidential	Business intelligence and performance monitoring	2025-11-24 10:28:30.859344
02ac1512-f87c-4da5-a1b0-1bbecbb36de9	2da28562-c8be-4dd6-b0ee-5b1863ea66c4	export	{"filters": {"agent_id": "991e6172-dcd1-4ca7-9c82-85cbbd14f6b3", "date_range": "last_30_days", "policy_type": "term_life"}, "metrics": ["policies_sold", "premium_collected", "customer_satisfaction"]}	1467	297	192.168.1.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36	confidential	Business intelligence and performance monitoring	2025-11-24 10:28:30.859344
7ddbff8d-50db-4f8e-88d6-b1e0b24d5f3d	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	export	{"filters": {"agent_id": "e45c1148-56b7-4605-b183-68ea7aec4383", "date_range": "last_30_days", "policy_type": "term_life"}, "metrics": ["policies_sold", "premium_collected", "customer_satisfaction"]}	1786	463	192.168.1.228	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36	confidential	Business intelligence and performance monitoring	2025-11-24 10:28:30.859344
72f8c2bf-92f4-4938-a161-a6920f19e47f	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	export	{"filters": {"agent_id": "d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20", "date_range": "last_30_days", "policy_type": "term_life"}, "metrics": ["policies_sold", "premium_collected", "customer_satisfaction"]}	2034	324	192.168.1.196	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36	confidential	Business intelligence and performance monitoring	2025-11-24 10:28:30.859344
ebcd8ac9-da51-4361-8f92-8f673126868e	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	export	{"filters": {"agent_id": "1a4c8c40-d885-4c6d-b39a-8a42e3b4652d", "date_range": "last_30_days", "policy_type": "term_life"}, "metrics": ["policies_sold", "premium_collected", "customer_satisfaction"]}	2310	399	192.168.1.145	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36	confidential	Business intelligence and performance monitoring	2025-11-24 10:28:30.859344
\.


--
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.chat_messages (message_id, session_id, user_id, message_type, content, is_from_user, intent_detected, confidence_score, entities_detected, response_generated, response_time_ms, suggested_actions, "timestamp") FROM stdin;
8f8f92cd-240d-4d3d-a6b7-ef6f5bd0cd53	5db21fc4-8923-428f-bbec-1bf0f6f9759f	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	text	I need to update my contact details	t	general_inquiry	0.89	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
541f8549-af6b-4238-bf61-154e21312313	5db21fc4-8923-428f-bbec-1bf0f6f9759f	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	text	For policy purchase, you will need: ID proof, address proof, income proof, and medical reports.	f	\N	\N	\N	Would you like me to connect you with an agent?	2219	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
5aaacd3c-82d6-4c17-935a-894566c0fc9e	5db21fc4-8923-428f-bbec-1bf0f6f9759f	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	text	What is the premium for term life insurance?	t	premium_inquiry	0.75	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
4638463a-6899-4dc3-ae8d-2f0e8b2ee9d3	5db21fc4-8923-428f-bbec-1bf0f6f9759f	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	text	For claims, please contact our claims department at 1800-XXX-XXXX or visit our claims portal.	f	\N	\N	\N	Would you like me to connect you with an agent?	2417	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
fd08881e-bca2-4266-9e06-909e98df09c2	5db21fc4-8923-428f-bbec-1bf0f6f9759f	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	text	How do I renew my policy?	t	general_inquiry	0.85	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
3bbe842a-bd56-43b9-b47f-1b30c567cf6e	5db21fc4-8923-428f-bbec-1bf0f6f9759f	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	text	You can renew your policy online through our portal. I can guide you through the process.	f	\N	\N	\N	I can help you with the next steps.	1229	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
f2b9ab66-020a-4abb-b88d-21e67d912a16	5db21fc4-8923-428f-bbec-1bf0f6f9759f	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	text	What documents do I need for policy purchase?	t	general_inquiry	0.75	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
026e91ee-3157-4054-a221-9b96b9f9ee13	5db21fc4-8923-428f-bbec-1bf0f6f9759f	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	text	For claims, please contact our claims department at 1800-XXX-XXXX or visit our claims portal.	f	\N	\N	\N	Would you like me to connect you with an agent?	1422	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
e2b23d10-6050-4a3e-8f30-b92f419ce476	0599455d-132c-418d-b4b6-eb1ee748a77e	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	text	How do I renew my policy?	t	general_inquiry	0.79	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
65dbd9e5-30dd-4e5e-b912-9c88ca6ce332	0599455d-132c-418d-b4b6-eb1ee748a77e	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	text	I can help you update your contact details. Please provide your policy number and the new information.	f	\N	\N	\N	Would you like me to connect you with an agent?	773	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
d37b9e0f-063a-460a-b3c2-39bc505c0c52	0599455d-132c-418d-b4b6-eb1ee748a77e	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	text	Can you help me with a claim?	t	premium_inquiry	0.79	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
1f59f0e3-133c-429f-b4f8-c79fc67a0b62	0599455d-132c-418d-b4b6-eb1ee748a77e	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	text	I can help you update your contact details. Please provide your policy number and the new information.	f	\N	\N	\N	I can help you with the next steps.	1406	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
cf76d117-47cb-454e-826c-ccc10854d6f4	0599455d-132c-418d-b4b6-eb1ee748a77e	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	text	I need to update my contact details	t	general_inquiry	0.95	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
42ddbbda-d37b-4fc2-bd01-89b55d62429c	0599455d-132c-418d-b4b6-eb1ee748a77e	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	text	For policy purchase, you will need: ID proof, address proof, income proof, and medical reports.	f	\N	\N	\N	Please provide more details about your requirements.	2399	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
17df9c82-d723-4849-8201-3ad86e2b6e14	0599455d-132c-418d-b4b6-eb1ee748a77e	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	text	What is the premium for term life insurance?	t	general_inquiry	0.88	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
83ee3aa3-e7cc-442c-bd9f-37e0380f2f0a	63080447-c751-47d1-b6e3-2c4c7ada48bb	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	text	What is the premium for term life insurance?	t	general_inquiry	0.82	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
0365c21e-14ec-41e1-a1f6-f6b0d25c670d	63080447-c751-47d1-b6e3-2c4c7ada48bb	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	text	I can help you update your contact details. Please provide your policy number and the new information.	f	\N	\N	\N	Please provide more details about your requirements.	1110	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
3bd753d0-c006-4881-b181-73385b0bc4a4	63080447-c751-47d1-b6e3-2c4c7ada48bb	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	text	How do I renew my policy?	t	contact_update	0.92	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
6d9e87fa-0454-4b86-a913-de0534ce4e93	8dba1123-bb2d-4a7d-8b30-8073b22c87a8	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	text	Can you help me with a claim?	t	general_inquiry	0.71	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
3c82b2c8-8582-4401-b73a-93a8cbaedfb8	8dba1123-bb2d-4a7d-8b30-8073b22c87a8	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	text	For policy purchase, you will need: ID proof, address proof, income proof, and medical reports.	f	\N	\N	\N	Would you like me to connect you with an agent?	1652	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
bad05b9a-69ec-4e5c-90fe-0968736861ca	8dba1123-bb2d-4a7d-8b30-8073b22c87a8	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	text	I need to update my contact details	t	general_inquiry	0.98	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
69d55f62-ba64-4d1d-9624-6cfbd4daa90a	8dba1123-bb2d-4a7d-8b30-8073b22c87a8	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	text	You can renew your policy online through our portal. I can guide you through the process.	f	\N	\N	\N	Would you like me to connect you with an agent?	1644	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
640bbef7-7139-4901-a9f8-443e61fcf9d3	8dba1123-bb2d-4a7d-8b30-8073b22c87a8	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	text	Can you help me with a claim?	t	premium_inquiry	1.00	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
b54062f5-4969-460f-8385-aca8c16e1bdc	01c7fde1-98a7-442e-addd-2ebbde46f27c	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	text	Can you help me with a claim?	t	contact_update	0.85	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
579415eb-a73a-42d1-b2da-959eb0754079	01c7fde1-98a7-442e-addd-2ebbde46f27c	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	text	You can renew your policy online through our portal. I can guide you through the process.	f	\N	\N	\N	Please provide more details about your requirements.	1665	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
75e28791-0d5d-4d62-a8e4-62e1fc915294	01c7fde1-98a7-442e-addd-2ebbde46f27c	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	text	How do I renew my policy?	t	policy_renewal	0.86	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
b1bb06b0-3289-4abd-ac9d-1f2c0a20c297	01c7fde1-98a7-442e-addd-2ebbde46f27c	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	text	For policy purchase, you will need: ID proof, address proof, income proof, and medical reports.	f	\N	\N	\N	Would you like me to connect you with an agent?	2055	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
ecb98ac8-b8aa-4e99-a25a-0c7da7f878c2	01c7fde1-98a7-442e-addd-2ebbde46f27c	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	text	What documents do I need for policy purchase?	t	policy_renewal	0.84	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
446ae049-1457-4dc8-8f83-efc211adf9fc	cbe25b4e-91bb-4223-9e7c-2e261649127f	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22	text	What documents do I need for policy purchase?	t	contact_update	0.97	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
8ac87ce5-7122-43cd-ade2-743ec8865a41	cbe25b4e-91bb-4223-9e7c-2e261649127f	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22	text	I can help you update your contact details. Please provide your policy number and the new information.	f	\N	\N	\N	I can help you with the next steps.	2179	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
3c805225-7244-43a3-94dd-df8aff6fdc87	59f84de2-dd14-40c0-a612-b4c0410ccd64	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	text	Can you help me with a claim?	t	premium_inquiry	0.96	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
69de7d86-8e0c-424f-91ac-fdfe8d8e611a	59f84de2-dd14-40c0-a612-b4c0410ccd64	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	text	For policy purchase, you will need: ID proof, address proof, income proof, and medical reports.	f	\N	\N	\N	I can help you with the next steps.	1536	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
1fee4c2a-201a-4fe6-8d37-4302632bed97	59f84de2-dd14-40c0-a612-b4c0410ccd64	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	text	Can you help me with a claim?	t	policy_renewal	0.80	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
a4265ac4-f298-4ed0-bcf1-0dfb53e723be	59f84de2-dd14-40c0-a612-b4c0410ccd64	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	text	For claims, please contact our claims department at 1800-XXX-XXXX or visit our claims portal.	f	\N	\N	\N	I can help you with the next steps.	1592	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
2115d3ec-7025-44d3-9a77-9bc203ddd2d6	59f84de2-dd14-40c0-a612-b4c0410ccd64	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	text	How do I renew my policy?	t	contact_update	0.82	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
14831cbc-2a5b-47d9-b053-d42eb76ae60a	59f84de2-dd14-40c0-a612-b4c0410ccd64	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	text	For claims, please contact our claims department at 1800-XXX-XXXX or visit our claims portal.	f	\N	\N	\N	Would you like me to connect you with an agent?	857	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
4712a443-bba8-4056-b24c-cb9aa8c9b305	53f4c858-ba71-40f1-a65b-84a97e97771e	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	text	How do I renew my policy?	t	general_inquiry	0.96	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
bc5d2edc-5f3d-4ad3-98b6-7fe6d67e3b76	53f4c858-ba71-40f1-a65b-84a97e97771e	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	text	For policy purchase, you will need: ID proof, address proof, income proof, and medical reports.	f	\N	\N	\N	I can help you with the next steps.	2466	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
77be7477-57d5-4312-8977-b5a1153defd9	53f4c858-ba71-40f1-a65b-84a97e97771e	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	text	I need to update my contact details	t	general_inquiry	0.84	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
51b5e13c-7ab0-4f7c-916e-74f5fb8cec64	53f4c858-ba71-40f1-a65b-84a97e97771e	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	text	For policy purchase, you will need: ID proof, address proof, income proof, and medical reports.	f	\N	\N	\N	I can help you with the next steps.	2182	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
78003a96-2d62-44e4-a266-45dfc4bff709	53f4c858-ba71-40f1-a65b-84a97e97771e	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	text	Can you help me with a claim?	t	general_inquiry	0.79	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
5932ad88-f504-477f-bb8f-194dbb555885	53f4c858-ba71-40f1-a65b-84a97e97771e	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	text	You can renew your policy online through our portal. I can guide you through the process.	f	\N	\N	\N	Would you like me to connect you with an agent?	1397	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
a7c1d80d-b7f6-4bbb-bda1-7eb738ec3cef	53f4c858-ba71-40f1-a65b-84a97e97771e	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	text	What documents do I need for policy purchase?	t	policy_renewal	0.85	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
7a3e6ed2-0ec7-4283-a622-3ea0077ac0bc	8ca2abc5-36ec-4592-af72-c6a6d94a61a7	ea2b3915-033a-4ee6-b798-673ce79beab8	text	How do I renew my policy?	t	premium_inquiry	0.98	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
2ed8a9f8-f163-4188-832d-002417967024	8ca2abc5-36ec-4592-af72-c6a6d94a61a7	ea2b3915-033a-4ee6-b798-673ce79beab8	text	You can renew your policy online through our portal. I can guide you through the process.	f	\N	\N	\N	I can help you with the next steps.	2397	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
d53e5bd5-d71e-4cef-a2e4-5048d9867849	8ca2abc5-36ec-4592-af72-c6a6d94a61a7	ea2b3915-033a-4ee6-b798-673ce79beab8	text	How do I renew my policy?	t	policy_renewal	0.87	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
f0ff9467-c1e6-4906-834d-475387535c8c	8ca2abc5-36ec-4592-af72-c6a6d94a61a7	ea2b3915-033a-4ee6-b798-673ce79beab8	text	For policy purchase, you will need: ID proof, address proof, income proof, and medical reports.	f	\N	\N	\N	I can help you with the next steps.	2045	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
84f8129e-8905-47b8-86e7-9315c3670401	8ca2abc5-36ec-4592-af72-c6a6d94a61a7	ea2b3915-033a-4ee6-b798-673ce79beab8	text	Can you help me with a claim?	t	contact_update	0.98	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
52473de1-bdbe-4f27-b3f7-a789e841cb67	8ca2abc5-36ec-4592-af72-c6a6d94a61a7	ea2b3915-033a-4ee6-b798-673ce79beab8	text	You can renew your policy online through our portal. I can guide you through the process.	f	\N	\N	\N	Would you like me to connect you with an agent?	2273	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
8b03f73a-fe01-4535-a893-7bede848795c	8ca2abc5-36ec-4592-af72-c6a6d94a61a7	ea2b3915-033a-4ee6-b798-673ce79beab8	text	What documents do I need for policy purchase?	t	premium_inquiry	0.76	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
46f474ce-decb-4cc0-af79-b2a25b089f32	8ca2abc5-36ec-4592-af72-c6a6d94a61a7	ea2b3915-033a-4ee6-b798-673ce79beab8	text	You can renew your policy online through our portal. I can guide you through the process.	f	\N	\N	\N	Would you like me to connect you with an agent?	1617	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
30891da2-0d08-41fe-876b-2362151ee1ae	f914cf97-987c-4730-ba5e-cffb1ed26aa1	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	text	How do I renew my policy?	t	contact_update	0.71	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
e6fc39df-256d-4121-a952-9f167a27f214	f914cf97-987c-4730-ba5e-cffb1ed26aa1	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	text	I can help you update your contact details. Please provide your policy number and the new information.	f	\N	\N	\N	I can help you with the next steps.	2107	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
2d5589e0-e5ab-451f-99f9-9e756895e461	f914cf97-987c-4730-ba5e-cffb1ed26aa1	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	text	I need to update my contact details	t	policy_renewal	0.95	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
0918f0e8-7363-43ed-bcff-74343bb97573	f914cf97-987c-4730-ba5e-cffb1ed26aa1	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	text	For claims, please contact our claims department at 1800-XXX-XXXX or visit our claims portal.	f	\N	\N	\N	I can help you with the next steps.	2353	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
9df0e924-39a3-41c8-98d1-a2c41d6f5bde	f914cf97-987c-4730-ba5e-cffb1ed26aa1	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	text	I need to update my contact details	t	general_inquiry	0.95	{"amount": "500000", "policy_type": "term_life"}	\N	\N	\N	2025-11-24 10:29:01.463858
256ba089-3e4d-435e-8812-6ea6f911716b	f914cf97-987c-4730-ba5e-cffb1ed26aa1	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	text	You can renew your policy online through our portal. I can guide you through the process.	f	\N	\N	\N	I can help you with the next steps.	1290	[{"label": "Get Quote", "action": "get_quote"}, {"label": "Contact Agent", "action": "contact_agent"}]	2025-11-24 10:29:01.463858
\.


--
-- Data for Name: chatbot_analytics_summary; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.chatbot_analytics_summary (analytics_id, summary_date, summary_period, total_sessions, completed_sessions, abandoned_sessions, total_messages, average_messages_per_session, average_response_time_ms, resolution_rate, escalation_rate, average_satisfaction, satisfaction_responses, top_intents, created_at) FROM stdin;
24ae6c3e-6fb0-4b7e-81e5-6c9dbb21920e	2025-11-23	daily	119	137	52	653	8.98	2980	85.78	13.35	4.02	21	{"general_help": 39, "renewal_info": 16, "claim_process": 12, "policy_inquiry": 39, "premium_payment": 28}	2025-11-24 10:41:38.515958
b3f66de8-4718-4140-9218-7b7a206e9c90	2025-11-22	daily	145	124	52	286	11.97	4377	94.52	23.84	4.06	37	{"general_help": 25, "renewal_info": 25, "claim_process": 22, "policy_inquiry": 30, "premium_payment": 18}	2025-11-24 10:41:38.515958
c81afcc7-f9dc-42f5-bf6c-6d146f80e16f	2025-11-21	daily	116	156	25	436	3.17	4712	79.00	12.18	4.46	56	{"general_help": 23, "renewal_info": 17, "claim_process": 20, "policy_inquiry": 35, "premium_payment": 25}	2025-11-24 10:41:38.515958
930e17ea-aefe-4341-a0b9-603eb8f477a1	2025-11-20	daily	221	143	19	177	3.37	2739	79.84	15.01	4.83	70	{"general_help": 35, "renewal_info": 9, "claim_process": 19, "policy_inquiry": 55, "premium_payment": 18}	2025-11-24 10:41:38.515958
3f3fba33-06ee-4d96-b709-c4931b1d20cb	2025-11-19	daily	189	70	20	470	7.11	3849	84.93	14.39	3.99	50	{"general_help": 17, "renewal_info": 24, "claim_process": 21, "policy_inquiry": 53, "premium_payment": 18}	2025-11-24 10:41:38.515958
5db8aa59-433a-48e0-bc2b-b8085a271971	2025-11-18	daily	145	87	25	399	8.20	4029	87.97	15.07	4.81	76	{"general_help": 36, "renewal_info": 16, "claim_process": 27, "policy_inquiry": 26, "premium_payment": 34}	2025-11-24 10:41:38.515958
16c3c4d0-fed2-40f1-bac8-2c75bfbedcff	2025-11-17	daily	114	138	28	173	3.08	1549	83.98	21.19	4.80	48	{"general_help": 15, "renewal_info": 18, "claim_process": 20, "policy_inquiry": 57, "premium_payment": 22}	2025-11-24 10:41:38.515958
38b0f5cc-8e84-4116-b5b3-f4ca1768e71f	2025-11-16	daily	175	122	39	307	6.85	1815	78.92	12.53	4.49	73	{"general_help": 38, "renewal_info": 17, "claim_process": 25, "policy_inquiry": 54, "premium_payment": 44}	2025-11-24 10:41:38.515958
b7582d94-4e61-4a93-a55d-5eac4c416ab2	2025-11-15	daily	152	176	25	451	6.05	2030	83.16	12.28	4.20	39	{"general_help": 12, "renewal_info": 16, "claim_process": 21, "policy_inquiry": 35, "premium_payment": 20}	2025-11-24 10:41:38.515958
4e5e425b-a801-4a36-bf28-a542ffc07114	2025-11-14	daily	104	109	35	526	5.01	3417	78.27	13.04	4.32	94	{"general_help": 21, "renewal_info": 19, "claim_process": 31, "policy_inquiry": 47, "premium_payment": 40}	2025-11-24 10:41:38.515958
\.


--
-- Data for Name: chatbot_intents; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.chatbot_intents (intent_id, intent_name, description, training_examples, response_templates, confidence_threshold, is_active, usage_count, success_rate, average_confidence, created_by, created_at, updated_at) FROM stdin;
b863576f-4f26-4b9f-9863-14ba52cf60f8	policy_inquiry	User is asking about policy details, status, or information	{"What is the status of my policy?","Can you tell me about my life insurance policy?","I need information about policy number POL123","When does my policy expire?"}	{"I can help you with information about your policy. Could you please provide your policy number?","To check your policy status, I need your policy number or some identifying information.","I'd be happy to help you with your policy inquiry. What specific information are you looking for?"}	0.70	t	0	\N	\N	\N	2025-11-23 22:34:55.759949	2025-11-23 22:34:55.759949
00d54d53-c3f2-4b07-b180-07ebfd163f34	premium_payment	User wants to know about or make premium payments	{"How do I pay my premium?","When is my next premium due?","I want to make a payment","What payment methods do you accept?"}	{"You can pay your premium through various methods including online banking, UPI, credit/debit cards, and cash at our branches.","Your next premium payment is due on [date]. You can pay online through our portal or mobile app.","We accept payments through net banking, UPI (Google Pay, PhonePe, Paytm), credit/debit cards, and cash payments."}	0.70	t	0	\N	\N	\N	2025-11-23 22:34:55.759949	2025-11-23 22:34:55.759949
fa53bf98-a566-45b9-b66c-abe2f0236615	premium_calculation	Calculate insurance premium based on coverage and age	{"calculate premium","how much premium","cost of insurance"}	{"I can help you calculate your premium. Please provide your age, coverage amount, and policy type."}	0.80	t	150	0.85	\N	\N	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
7667c52d-afaf-471c-836a-040190d0bed7	claim_process	Guide through insurance claim filing process	{"how to file claim","claim procedure","make a claim"}	{"To file a claim, you need: policy number, incident details, supporting documents. I can guide you through each step."}	0.85	t	200	0.90	\N	\N	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
d32e8c84-9849-4062-af95-6f1075797247	policy_comparison	Compare different insurance policies	{"compare policies","which policy is better","policy differences"}	{"I can help you compare policies based on coverage, premium, and benefits. Which policies would you like to compare?"}	0.75	t	120	0.80	\N	\N	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
6b9a9eee-be05-49a9-a667-47a57a39a939	renewal_reminder	Handle policy renewal inquiries	{"renew policy","renewal date","when to renew"}	{"Your policy renewal is due on {renewal_date}. You can renew online or contact your agent."}	0.90	t	180	0.88	\N	\N	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
e97a59ab-2564-45a4-b6a7-c42ac47bdf72	document_upload	Guide for uploading documents	{"upload documents","submit papers","required documents"}	{"Please upload the following documents: ID proof, address proof, and policy-related documents."}	0.80	t	90	0.82	\N	\N	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
fa0699a9-8fb6-4c0a-afdb-ca04827e5b54	payment_methods	Explain available payment options	{"payment options","how to pay","payment methods"}	{"You can pay through: UPI, net banking, credit/debit cards, or cash at agent office."}	0.85	t	160	0.87	\N	\N	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
777c68f2-b995-4ec1-bc33-bf413fff8725	coverage_details	Explain policy coverage details	{"what is covered","coverage details","policy benefits"}	{"Your policy covers: {coverage_details}. For complete details, please refer to your policy document."}	0.80	t	140	0.83	\N	\N	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
07224008-7e75-4808-9401-afdadd563654	agent_contact	Help contact insurance agent	{"contact agent","speak to agent","agent details"}	{"I can connect you with your agent. Please provide your policy number or customer ID."}	0.90	t	110	0.89	\N	\N	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
\.


--
-- Data for Name: chatbot_sessions; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.chatbot_sessions (session_id, user_id, conversation_id, started_at, ended_at, duration_seconds, message_count, resolution_status, average_response_time, user_satisfaction_score, escalation_reason, device_info, ip_address, user_agent) FROM stdin;
5db21fc4-8923-428f-bbec-1bf0f6f9759f	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	conv_a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11_1763960341.463858	2025-11-24 08:29:01.463858	2025-11-24 09:59:01.463858	2913	15	resolved	1.74	5	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.98	AgentMitra-Chat/1.0.0
0599455d-132c-418d-b4b6-eb1ee748a77e	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	conv_a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12_1763960341.463858	2025-11-24 08:29:01.463858	\N	4768	14	in_progress	3.19	3	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.22	AgentMitra-Chat/1.0.0
63080447-c751-47d1-b6e3-2c4c7ada48bb	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	conv_a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13_1763960341.463858	2025-11-24 08:29:01.463858	\N	3698	3	escalated	1.63	4	Technical issue beyond chatbot capability	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.91	AgentMitra-Chat/1.0.0
8dba1123-bb2d-4a7d-8b30-8073b22c87a8	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	conv_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20_1763960341.463858	2025-11-24 08:29:01.463858	\N	5259	4	escalated	1.61	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.105	AgentMitra-Chat/1.0.0
01c7fde1-98a7-442e-addd-2ebbde46f27c	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	conv_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21_1763960341.463858	2025-11-24 08:29:01.463858	\N	3857	4	abandoned	1.05	5	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.202	AgentMitra-Chat/1.0.0
cbe25b4e-91bb-4223-9e7c-2e261649127f	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22	conv_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22_1763960341.463858	2025-11-24 08:29:01.463858	2025-11-24 09:59:01.463858	4954	17	escalated	5.27	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.193	AgentMitra-Chat/1.0.0
59f84de2-dd14-40c0-a612-b4c0410ccd64	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	conv_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23_1763960341.463858	2025-11-24 08:29:01.463858	2025-11-24 09:59:01.463858	\N	9	in_progress	4.46	5	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.184	AgentMitra-Chat/1.0.0
53f4c858-ba71-40f1-a65b-84a97e97771e	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	conv_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24_1763960341.463858	2025-11-24 08:29:01.463858	2025-11-24 09:59:01.463858	5140	13	in_progress	1.36	5	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.55	AgentMitra-Chat/1.0.0
8ca2abc5-36ec-4592-af72-c6a6d94a61a7	ea2b3915-033a-4ee6-b798-673ce79beab8	conv_ea2b3915-033a-4ee6-b798-673ce79beab8_1763960341.463858	2025-11-24 08:29:01.463858	\N	3349	18	resolved	2.95	3	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.69	AgentMitra-Chat/1.0.0
f914cf97-987c-4730-ba5e-cffb1ed26aa1	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	conv_15f336f5-58a4-49a5-b1d5-26df0d6ed2a7_1763960341.463858	2025-11-24 08:29:01.463858	\N	\N	5	in_progress	3.95	4	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.171	AgentMitra-Chat/1.0.0
\.


--
-- Data for Name: countries; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.countries (country_id, country_code, country_name, currency_code, phone_code, timezone, status) FROM stdin;
22a696ac-a2ab-4ece-b9a3-798d61a1a580	IND	India	INR	+91	Asia/Kolkata	active
d8b51733-b932-4e93-8cc7-63653bc5de5f	USA	United States	USD	+1	America/New_York	active
21f86162-72b5-4e06-bcea-c39ecd820190	GBR	United Kingdom	GBP	+44	Europe/London	active
efdb77f8-e439-4b38-ac02-c4280bc2332d	IN	India	INR	+91	\N	active
f598cb47-c883-419b-a67e-6514e12534ac	US	United States	USD	+1	\N	active
1495c752-d2a5-4ba2-847e-b6374120a638	GB	United Kingdom	GBP	+44	\N	active
e1f26b27-73a3-42c8-9b62-4f361b482837	CA	Canada	CAD	+1	\N	active
fcfa4393-c288-4b7f-878e-a0ee0ebfd2f3	AU	Australia	AUD	+61	\N	active
cb5efd86-ccaf-447d-851f-01ac86829839	DE	Germany	EUR	+49	\N	active
15843834-0ab4-4332-ba06-1b45b2cd80f4	FR	France	EUR	+33	\N	active
bb6e6907-f81e-4a9e-928a-f622d60ee93c	JP	Japan	JPY	+81	\N	active
16f3807c-a9cb-4f8d-a0e1-03eb5a40db08	CN	China	CNY	+86	\N	active
82b9d8b3-32f2-4ab6-ad67-c42e43fe56b0	BR	Brazil	BRL	+55	\N	active
\.


--
-- Data for Name: customer_behavior_metrics; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.customer_behavior_metrics (metric_id, customer_id, metric_date, login_count, page_views, session_duration, policy_views, premium_payments, claims_submitted, email_opens, whatsapp_messages, support_tickets, churn_probability, upgrade_probability, created_at) FROM stdin;
c07b40f5-fb8a-45d9-8f33-b92724f55a3b	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-24	0	17	1781	7	0	0	2	0	0	6.59	4.79	2025-11-24 10:28:30.859344
eb8f3cd3-a3d5-4cc8-8905-b9ade2a913ca	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-23	5	14	841	4	0	0	0	0	0	9.65	0.42	2025-11-24 10:28:30.859344
79ffe797-d611-4fb1-8389-73af89d9e59a	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-22	3	16	1534	2	0	0	4	0	0	9.50	6.00	2025-11-24 10:28:30.859344
42aedeee-be39-4017-8a15-67e438ccd7be	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-21	5	13	1353	8	0	1	2	0	0	0.90	4.06	2025-11-24 10:28:30.859344
b3336425-428f-486b-b837-c92cb83c9b3d	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-20	4	17	520	3	0	0	0	0	0	2.64	7.15	2025-11-24 10:28:30.859344
95d477f3-7096-489f-b9c3-4e3ac1341a76	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-19	1	8	704	1	0	0	0	0	0	3.07	8.10	2025-11-24 10:28:30.859344
698e051b-2dac-4e46-8ccc-0c4d8b498c90	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-18	3	20	508	4	0	1	4	0	0	3.49	3.86	2025-11-24 10:28:30.859344
e52631bd-334b-459e-888b-130f5a58ea1b	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-17	0	16	1146	7	0	0	3	2	0	1.66	9.90	2025-11-24 10:28:30.859344
757f3f74-25b2-433b-9f69-7e0ce94b704d	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-16	2	10	1105	6	0	0	0	0	0	6.51	7.59	2025-11-24 10:28:30.859344
d70e1ff5-71d5-408c-a134-0ba62f425f3e	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-15	1	22	1634	4	0	0	0	0	0	4.25	1.54	2025-11-24 10:28:30.859344
377de6e9-01a5-40b8-9f23-e089f988490a	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-14	2	10	654	1	0	0	1	0	0	6.53	0.15	2025-11-24 10:28:30.859344
1f89b586-43fd-422d-bd94-c5f4d25f252b	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-13	2	12	1078	2	0	0	0	0	0	6.11	6.48	2025-11-24 10:28:30.859344
949c5c6f-34f9-4ba1-9823-01a46fbfd9e0	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-12	5	18	1690	10	0	0	0	0	0	3.20	3.47	2025-11-24 10:28:30.859344
a4ca196c-3278-4098-bee6-153c74fbaacb	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-11	3	9	616	0	0	0	0	0	0	0.01	2.36	2025-11-24 10:28:30.859344
6fb5a1bb-2a68-40aa-8c22-3a737ddd694a	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-10	1	24	317	1	0	0	0	0	0	5.64	9.23	2025-11-24 10:28:30.859344
2566d3b3-94e5-4b71-ad41-a3784ba2162f	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-09	4	11	2012	6	0	0	3	0	0	8.42	8.26	2025-11-24 10:28:30.859344
137f9a22-2a27-4da1-b444-8f3d4277598a	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-08	4	23	716	1	0	0	0	0	0	3.06	3.05	2025-11-24 10:28:30.859344
d8ca84df-99e8-487e-b4a6-d27990566666	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-07	5	10	1846	6	1	0	0	0	0	8.35	5.57	2025-11-24 10:28:30.859344
a976b194-e8b5-41b9-bb45-20366d7f7fdc	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-06	2	20	744	7	0	0	0	0	0	8.75	2.36	2025-11-24 10:28:30.859344
aa2258e9-379c-457e-94ad-186407303d8d	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-05	1	5	1721	0	0	0	0	0	1	4.51	9.88	2025-11-24 10:28:30.859344
2603572f-2e70-496a-b768-2e71dfd68386	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-04	3	25	952	6	0	0	3	0	0	0.92	5.90	2025-11-24 10:28:30.859344
5c5199d4-9105-4da1-a16c-55a2465f0fb2	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-03	2	10	1249	6	0	0	0	0	0	3.15	9.02	2025-11-24 10:28:30.859344
91638725-a906-44ec-b68d-11eb886c1dbf	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-02	4	9	1943	4	0	0	0	0	0	6.15	8.84	2025-11-24 10:28:30.859344
5d1a927b-931a-4d04-ae0c-238b6c87a296	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-11-01	1	17	1130	4	0	0	0	0	0	6.41	3.42	2025-11-24 10:28:30.859344
fa62bb11-97b0-4765-81b6-a5c470d4cec0	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-10-31	5	9	2010	1	0	0	4	0	0	1.03	7.26	2025-11-24 10:28:30.859344
34506b93-41e5-4ee9-b2bd-1dc6c8eded76	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-10-30	0	18	938	5	0	0	0	2	0	9.38	9.93	2025-11-24 10:28:30.859344
580e23b6-d63e-47af-af86-c7506be13be9	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-10-29	4	18	354	9	0	0	0	0	0	0.64	2.49	2025-11-24 10:28:30.859344
d0b54f67-93ab-40ad-bb10-675430e51a0f	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-10-28	5	9	1334	7	0	0	0	0	0	2.23	7.98	2025-11-24 10:28:30.859344
4f8223cb-acb5-486a-b7a3-dfeb11e08db2	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-10-27	0	23	1587	9	0	0	0	3	0	4.32	8.41	2025-11-24 10:28:30.859344
5144ef14-c3db-44cc-9d69-95304239582f	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	2025-10-26	1	9	1582	7	0	0	0	0	0	2.74	3.82	2025-11-24 10:28:30.859344
f1d9685f-0ffb-41ab-b273-550117f13e30	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-24	5	5	2012	2	0	0	4	0	0	0.46	2.54	2025-11-24 10:28:30.859344
de42f870-d437-45f4-a983-a64a24564514	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-23	3	22	2064	8	1	0	0	3	0	8.61	7.76	2025-11-24 10:28:30.859344
027ce853-0323-4fd7-a52c-d532df16bc41	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-22	3	19	707	1	0	0	0	0	0	3.42	0.58	2025-11-24 10:28:30.859344
f1b1f109-ee37-4e6c-826c-c893b506d5f2	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-21	2	23	532	4	0	0	3	0	0	3.13	4.87	2025-11-24 10:28:30.859344
2b8326fd-62af-48aa-84d5-73f16bd2c122	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-20	5	24	634	6	1	0	2	0	0	4.81	6.74	2025-11-24 10:28:30.859344
8fd313af-8d6f-49fa-bd8c-ebebf7f7e086	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-19	0	14	1737	5	1	0	0	0	0	2.91	2.35	2025-11-24 10:28:30.859344
1eaf8329-5ec3-4d27-b448-1743f3e489cb	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-18	4	9	572	1	0	0	0	0	0	7.84	9.20	2025-11-24 10:28:30.859344
6a2e9207-0598-40e3-8b3a-7e9015509120	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-17	2	22	1891	2	1	0	0	0	1	3.34	1.19	2025-11-24 10:28:30.859344
b7b617d9-75e7-4403-a002-d628d61ba9e9	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-16	3	9	632	4	0	0	0	0	0	9.69	9.85	2025-11-24 10:28:30.859344
3bc177a8-cf80-476f-9a85-c6dd930cf028	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-15	3	18	922	0	0	1	0	0	0	6.97	3.63	2025-11-24 10:28:30.859344
04d5beaf-2d2f-41c5-bd96-b610ddc32d7a	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-14	4	14	1328	9	0	0	2	0	0	5.75	6.77	2025-11-24 10:28:30.859344
dfa1320c-586b-4a1f-8fb8-b0069ad27c09	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-13	5	18	1251	0	0	0	0	0	0	0.21	5.84	2025-11-24 10:28:30.859344
13bd99a6-2780-4f60-887b-083b31346f3f	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-12	1	14	1248	3	0	0	0	0	0	8.20	8.61	2025-11-24 10:28:30.859344
cf31e88f-c7aa-4d71-b604-ab813ccf7a3f	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-11	4	19	752	2	0	0	2	0	1	7.97	8.38	2025-11-24 10:28:30.859344
989105c1-007c-4f16-bc5d-0d43027f2f93	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-10	4	17	733	2	0	0	0	0	0	1.29	1.25	2025-11-24 10:28:30.859344
3e58c963-917f-4985-97b6-1303dce29c72	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-09	2	15	1809	1	1	0	0	0	0	6.47	8.48	2025-11-24 10:28:30.859344
aa133788-4062-4a7c-9dab-a005b511abcb	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-08	2	13	717	7	0	0	1	3	0	5.28	7.16	2025-11-24 10:28:30.859344
9e096d4b-bf84-48bb-8db9-ab612c422d8a	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-07	4	22	668	3	0	0	0	0	0	1.55	2.93	2025-11-24 10:28:30.859344
d0f2dfd7-c094-4bbf-93ba-fdbd00eb88ce	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-06	1	14	569	7	0	0	3	0	0	3.64	1.31	2025-11-24 10:28:30.859344
173aa545-181a-405f-bf1d-341adde3fdcb	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-05	4	24	663	5	0	0	4	0	0	5.84	8.15	2025-11-24 10:28:30.859344
bec8720f-c6e2-4a58-86b5-ae26d04fae42	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-04	1	12	1154	8	0	0	3	0	0	9.81	1.94	2025-11-24 10:28:30.859344
93d0ff25-6240-48db-be9d-6d2b4a369810	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-03	4	23	1377	6	0	0	4	0	0	6.90	4.46	2025-11-24 10:28:30.859344
13b6b0aa-25f6-4004-b42d-59237af2e8bd	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-02	0	19	326	5	0	0	0	0	0	1.93	3.62	2025-11-24 10:28:30.859344
63c57735-9818-4bd2-a189-3ae3c936e2ce	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-01	2	7	483	2	0	0	0	0	0	1.58	3.80	2025-11-24 10:28:30.859344
8101956b-746c-46d6-80fb-e8051512a14c	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-10-31	5	12	746	9	0	0	2	0	0	6.41	9.56	2025-11-24 10:28:30.859344
965ceca9-9dec-4ce9-b195-a8af270fbbfb	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-10-30	0	19	489	9	0	0	0	0	0	6.19	6.67	2025-11-24 10:28:30.859344
87b1b680-a38f-4a68-9279-04507cb7eeaa	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-10-29	2	15	799	7	0	0	0	0	0	4.37	0.74	2025-11-24 10:28:30.859344
ab49ebf9-9160-4ea5-aaf9-b3405db73d21	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-10-28	2	20	783	5	0	0	2	0	0	3.22	6.24	2025-11-24 10:28:30.859344
62ca3316-d745-4e1f-af8e-7dd78298e178	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-10-27	4	15	1044	2	0	0	4	0	0	4.51	2.88	2025-11-24 10:28:30.859344
d9a3b2f8-fe23-4bc5-a48e-a57e8297de89	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-10-26	2	11	460	8	0	0	0	0	1	7.17	2.41	2025-11-24 10:28:30.859344
0d8c0ae3-9b18-40d9-a7eb-389062242216	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-24	3	6	1617	3	0	0	4	0	0	7.71	9.86	2025-11-24 10:28:30.859344
310b7b35-bc6b-4cb4-a025-beb511f8929f	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-23	2	9	326	3	0	0	0	0	0	3.55	9.93	2025-11-24 10:28:30.859344
8f9d2063-8b49-49b7-8f9b-7eafee9a0bd1	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-22	4	13	1586	2	0	0	2	0	0	1.81	2.29	2025-11-24 10:28:30.859344
cd7c93c2-e229-41dd-a17e-f9b739e7ca78	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-21	2	24	704	9	0	0	0	0	0	5.21	9.29	2025-11-24 10:28:30.859344
78d6f7f1-2d31-443a-98b4-99d734146847	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-20	3	19	435	2	0	0	1	3	0	1.28	1.30	2025-11-24 10:28:30.859344
a8a58a5b-8e72-49db-ad3a-94fa4b2c507d	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-19	2	25	1095	2	0	0	2	0	0	7.15	7.22	2025-11-24 10:28:30.859344
1e89037b-e63a-442d-8984-63878d28a6da	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-18	3	12	1913	6	0	0	0	0	0	4.50	9.04	2025-11-24 10:28:30.859344
a209dba4-a910-441b-b9a6-06edbd6ad919	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-17	1	6	454	9	0	0	0	0	0	7.48	8.76	2025-11-24 10:28:30.859344
38e7843b-5b55-4651-9795-323542a562c8	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-16	1	21	1747	9	1	0	0	0	1	4.85	6.83	2025-11-24 10:28:30.859344
5c19ad99-379c-4482-8789-5070fdd462dc	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-15	4	10	1202	3	0	0	0	1	0	0.42	6.13	2025-11-24 10:28:30.859344
11ca4fb9-9c6e-475b-bc4b-3aee99e90a81	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-14	3	9	573	7	0	0	0	2	0	9.11	8.49	2025-11-24 10:28:30.859344
ed9edf8a-d754-46d9-8a7a-acfec5bbe6ef	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-13	2	14	1878	8	0	0	0	0	0	3.83	8.75	2025-11-24 10:28:30.859344
7c1f0e5a-cbc4-4275-ac00-2d01455af662	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-12	3	13	2019	7	1	0	0	1	0	0.16	2.14	2025-11-24 10:28:30.859344
86902c8b-d880-45ca-8a1e-dd94926f5ce4	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-11	4	22	1000	5	0	0	0	0	0	9.56	4.18	2025-11-24 10:28:30.859344
29060d84-e869-4c94-a3a5-38ae141ac0a8	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-10	5	23	1633	3	1	0	0	0	0	9.39	6.23	2025-11-24 10:28:30.859344
bf15eacf-2da3-45fe-8757-4cbc0913cfad	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-09	1	17	335	6	1	0	3	0	0	7.25	1.39	2025-11-24 10:28:30.859344
94a4665e-6c0d-4ee4-9d29-83d856ce281c	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-08	1	16	1958	9	0	0	0	0	1	1.14	7.60	2025-11-24 10:28:30.859344
822bacc9-902a-4fb3-8c43-502ee05ebc6a	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-07	5	18	693	4	0	0	2	0	0	1.29	9.43	2025-11-24 10:28:30.859344
b6bc962c-3e45-4006-9a37-e214e0101b66	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-06	3	15	353	6	0	1	0	0	0	8.79	4.91	2025-11-24 10:28:30.859344
6550e3da-4a6e-488e-b908-8857f7c1d5d0	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-05	5	9	1863	2	0	0	0	2	0	9.24	5.13	2025-11-24 10:28:30.859344
3dd11103-b6dc-4adc-91e4-cad13662faab	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-04	5	13	1399	6	0	0	2	0	0	4.44	0.87	2025-11-24 10:28:30.859344
eaa712cb-2746-49e4-986e-c3ea626caa01	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-03	4	6	1818	4	0	0	0	0	0	6.89	9.25	2025-11-24 10:28:30.859344
f6096f49-3726-4d07-8396-77e5a9095aad	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-02	3	20	1387	7	0	0	3	0	0	2.49	3.55	2025-11-24 10:28:30.859344
b160901c-45c9-4ea0-8ea2-2b4c137b142e	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-01	2	9	1041	3	0	0	2	0	1	0.19	4.12	2025-11-24 10:28:30.859344
027970e4-b461-4cea-a857-52b518a3b993	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-10-31	5	15	689	9	0	0	0	0	0	3.62	0.51	2025-11-24 10:28:30.859344
f6d03b0c-c796-42ac-af56-a1e2c44ab2e3	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-10-30	1	9	2066	8	1	0	0	0	0	8.53	9.12	2025-11-24 10:28:30.859344
bd28fb9e-d839-4f21-99b1-1bbcafe1dca0	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-10-29	4	11	1060	1	0	0	0	0	0	3.29	8.96	2025-11-24 10:28:30.859344
0a704956-0ce7-4126-a91a-30f906f1fdc7	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-10-28	1	16	1249	2	0	0	0	2	0	5.76	9.35	2025-11-24 10:28:30.859344
f97ef2ae-3084-40d6-942e-8793ec316062	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-10-27	5	22	1998	8	0	0	0	0	0	7.75	1.41	2025-11-24 10:28:30.859344
8e437968-feea-4f01-8a70-184bd8476f6b	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-10-26	5	14	1502	9	0	0	3	0	0	9.08	8.84	2025-11-24 10:28:30.859344
b824139a-253d-45e2-80bd-2155acc368cb	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-24	5	21	715	9	0	0	0	0	0	3.28	9.36	2025-11-24 10:28:30.859344
6ae40e34-d90d-45ff-a186-6bb05282fd28	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-23	5	11	840	8	0	0	3	0	0	2.08	5.82	2025-11-24 10:28:30.859344
3eab8550-4bfe-43c4-8914-a88d06b13a20	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-22	1	18	1930	10	0	0	3	0	0	2.42	7.99	2025-11-24 10:28:30.859344
a39fc31a-4d4e-44a5-b141-61ea14143027	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-21	3	21	506	8	1	0	4	0	0	0.40	1.30	2025-11-24 10:28:30.859344
00cc084e-c4ef-4388-8717-7f02e37004c8	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-20	5	11	1999	8	0	0	3	0	0	2.49	3.48	2025-11-24 10:28:30.859344
28731b94-2f65-49de-b9af-992907d3c606	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-19	4	9	1329	4	0	0	0	0	0	3.18	7.17	2025-11-24 10:28:30.859344
7a105fc1-f3e9-4612-b339-16164b481d25	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-18	4	9	702	3	0	0	0	0	1	4.35	1.49	2025-11-24 10:28:30.859344
95a610d3-eca5-42c9-b3c1-c897c198f2c4	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-17	1	6	1093	7	0	0	0	0	0	6.19	9.72	2025-11-24 10:28:30.859344
dc99436b-c0f2-4f97-8def-893943ff4c46	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-16	1	11	1485	5	0	0	0	0	0	6.53	6.08	2025-11-24 10:28:30.859344
d328fddf-a9fe-4e50-8b27-a9a8d280a12c	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-15	4	13	511	6	1	0	3	3	0	4.37	7.94	2025-11-24 10:28:30.859344
2932e8cc-8835-446c-83a3-b1b8ac2e7242	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-14	4	20	1135	2	0	0	0	0	0	3.77	5.29	2025-11-24 10:28:30.859344
106a002a-97fd-41a4-90da-534480b80d9d	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-13	1	6	464	7	0	0	0	0	0	7.79	1.46	2025-11-24 10:28:30.859344
eeb329cd-515c-488f-830b-fc0a478fc830	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-12	4	11	1801	8	0	0	0	0	0	6.48	1.76	2025-11-24 10:28:30.859344
ff6cf15c-6b29-45d6-9d58-90b7c07e3073	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-11	3	19	653	2	0	0	0	0	0	2.29	8.32	2025-11-24 10:28:30.859344
3acb03e2-9a12-4fe0-b995-6dc531fb72e9	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-10	0	22	962	0	0	0	2	0	0	1.04	2.59	2025-11-24 10:28:30.859344
73879e25-dc2e-4c31-a5e7-909e159d2997	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-09	5	9	916	7	0	0	0	0	0	3.96	1.06	2025-11-24 10:28:30.859344
3254a7f8-95c0-4501-9920-3e6e726f8739	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-08	3	24	839	8	0	0	0	0	1	4.67	1.54	2025-11-24 10:28:30.859344
cb5443d6-71f1-428a-95ea-5f7063d64760	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-07	4	12	1542	3	0	0	0	0	0	4.08	4.61	2025-11-24 10:28:30.859344
41abdd49-42e4-4020-8a34-8f5e5ad8f4d9	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-06	3	17	1576	3	0	0	0	0	0	3.05	6.80	2025-11-24 10:28:30.859344
f67422b6-705b-4abc-afd1-c9950462ab63	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-05	1	16	1336	0	0	0	1	0	0	5.73	9.44	2025-11-24 10:28:30.859344
b46e6342-2155-4814-b72a-1b7d17d60d5e	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-04	4	8	451	10	0	0	0	0	0	0.31	5.64	2025-11-24 10:28:30.859344
5a1717f1-bdc1-45d6-a1cd-993b2514d19d	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-03	1	24	1132	3	0	0	0	0	0	1.28	9.76	2025-11-24 10:28:30.859344
47f5aa97-a064-4831-bde0-6e036c4283f6	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-02	0	14	427	10	0	0	0	0	0	4.25	2.44	2025-11-24 10:28:30.859344
695edda0-243c-45b9-8d9d-838c666794bc	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-11-01	5	10	641	8	1	0	0	0	0	7.88	0.83	2025-11-24 10:28:30.859344
7ec2e5d6-69e9-4f54-8f46-884761f8cae2	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-10-31	1	19	1996	3	0	0	4	0	0	7.79	4.16	2025-11-24 10:28:30.859344
f12c5fce-d914-4ce3-9263-129c17449ff1	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-10-30	1	22	1503	2	0	0	0	0	0	4.50	7.18	2025-11-24 10:28:30.859344
980b0fe9-8ef8-4a76-92f7-cfb935e367b0	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-10-29	0	23	1832	4	0	0	0	0	0	0.91	0.70	2025-11-24 10:28:30.859344
84f8592f-437b-4415-b560-e2cad968bc23	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-10-28	2	15	1239	6	0	0	0	0	0	7.93	7.23	2025-11-24 10:28:30.859344
8791bc8d-93a7-469c-a24e-e32e81da585d	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-10-27	5	24	1053	7	0	1	0	0	0	8.59	2.04	2025-11-24 10:28:30.859344
733415ab-73a7-4dce-8e4e-716156311ed9	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-10-26	2	8	813	10	0	0	0	0	0	4.05	9.49	2025-11-24 10:28:30.859344
668b9bb6-107c-4832-8563-d4545ccd17ca	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-24	1	11	698	10	0	0	0	1	0	7.74	8.49	2025-11-24 10:28:30.859344
5c33809a-d6c8-4c87-be35-b988074a93b6	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-23	1	24	1792	1	0	0	0	2	0	8.93	9.42	2025-11-24 10:28:30.859344
383e2a23-046d-4f47-8b57-66e734731c65	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-22	4	20	1736	4	0	0	2	0	0	0.29	4.55	2025-11-24 10:28:30.859344
1907a084-7c38-40e6-af03-670b4e2343d0	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-21	3	24	1809	1	0	0	2	0	0	2.32	2.65	2025-11-24 10:28:30.859344
aa0efb39-e8a0-4b19-bc05-1b2e7b9c936e	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-20	5	9	1426	2	0	0	3	0	0	3.23	1.54	2025-11-24 10:28:30.859344
5e937232-1848-4707-a422-c5cd8e4706f0	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-19	5	7	811	0	0	0	3	0	0	6.03	0.31	2025-11-24 10:28:30.859344
f02caa3f-3c4a-4dcb-85e9-7f2cf0503ff5	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-18	5	18	1397	1	0	0	0	0	0	6.83	2.07	2025-11-24 10:28:30.859344
c4d9fc58-0361-4f1f-abac-6145683e4ab0	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-17	5	21	1407	8	0	0	0	0	0	4.29	5.16	2025-11-24 10:28:30.859344
d67b6be1-fe63-4ab8-80b4-1600dced4c1a	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-16	0	9	634	6	0	0	3	0	0	2.34	5.20	2025-11-24 10:28:30.859344
9eb61f76-f5bb-45ef-a3b8-acdc1b25fc4e	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-15	1	22	1838	7	1	0	1	0	0	4.90	2.99	2025-11-24 10:28:30.859344
f5fc7b11-5ec2-4629-8685-e0b5ed99d7ab	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-14	4	11	2089	2	0	0	0	0	0	4.98	2.14	2025-11-24 10:28:30.859344
608eda96-30f9-4f2d-8159-5ba44c1f914f	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-13	1	24	645	3	0	0	0	0	0	2.80	9.84	2025-11-24 10:28:30.859344
bc9e4ad8-5905-4452-86cb-bda501430c0c	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-12	1	20	1650	9	0	0	0	0	0	4.93	9.02	2025-11-24 10:28:30.859344
7a8bbd22-c82f-4f09-88b5-7bd54e708c2c	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-11	5	9	878	2	1	0	0	0	0	4.99	9.70	2025-11-24 10:28:30.859344
48c4a4b9-dbd3-4ded-a9a6-e665b5a941b9	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-10	0	12	1227	8	0	0	2	2	0	1.07	0.96	2025-11-24 10:28:30.859344
12ffd7f6-078f-4258-bd55-a0e4d5753308	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-09	3	19	1460	4	0	0	0	3	0	5.85	1.34	2025-11-24 10:28:30.859344
1f170973-4341-4082-822f-ac6516c126ba	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-08	3	9	738	10	0	0	2	2	0	9.60	1.86	2025-11-24 10:28:30.859344
2caacce6-63f9-44d0-94fe-f92173df0d95	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-07	4	12	474	8	0	0	2	0	0	5.83	4.37	2025-11-24 10:28:30.859344
f5457e61-db76-491c-9ca2-071df0918821	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-06	1	16	1337	1	0	0	1	0	0	8.78	4.54	2025-11-24 10:28:30.859344
d368957e-7004-4e4d-9ca2-df04c063142e	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-05	4	9	1167	2	0	0	2	1	0	6.22	7.77	2025-11-24 10:28:30.859344
86f46236-18ef-4150-981b-672e9ac5ad86	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-04	4	10	2064	8	0	0	0	1	0	5.92	3.51	2025-11-24 10:28:30.859344
35c68941-30fe-41fe-99f1-7301bf419223	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-03	4	18	1034	6	0	0	0	0	0	4.39	0.16	2025-11-24 10:28:30.859344
a08749af-3f19-4061-9aa7-46325a31af77	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-02	4	17	924	5	0	0	2	0	0	4.11	6.32	2025-11-24 10:28:30.859344
01e455f3-6867-4cf0-b500-273daecf5616	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-11-01	1	17	345	1	0	0	3	0	0	9.47	5.47	2025-11-24 10:28:30.859344
ccc12523-2647-4824-ad0d-e347987b5e76	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-10-31	5	8	1964	0	0	0	0	0	0	1.29	5.09	2025-11-24 10:28:30.859344
bba31387-60b6-457c-88eb-b28872957ae6	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-10-30	0	24	1210	5	1	0	0	2	0	1.61	9.84	2025-11-24 10:28:30.859344
ed46ccd6-7020-4cdf-adb9-1e4552f36400	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-10-29	4	21	1643	8	0	0	0	0	0	4.89	4.41	2025-11-24 10:28:30.859344
cad77474-71e7-43f3-855a-c89c725cd748	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-10-28	1	21	1392	10	0	0	0	0	1	8.24	5.76	2025-11-24 10:28:30.859344
8991b0da-eaa2-48d9-9c81-123c87d2c382	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-10-27	0	19	616	10	0	0	0	0	0	7.36	0.59	2025-11-24 10:28:30.859344
670da855-57af-453d-9c48-7e1f9ce05e86	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	2025-10-26	0	14	2099	4	0	0	0	1	0	8.36	0.68	2025-11-24 10:28:30.859344
13993c24-ba18-4c68-b064-9913a4611536	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-24	0	6	1308	9	0	0	2	0	0	2.05	2.62	2025-11-24 10:28:30.859344
e007ce15-3756-4856-b35c-08ddd3c560d3	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-23	2	7	687	8	0	0	0	0	0	9.33	4.87	2025-11-24 10:28:30.859344
fb614817-a4c4-43e8-a33b-7acf89c1c02f	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-22	1	25	734	3	0	0	0	0	0	8.28	5.98	2025-11-24 10:28:30.859344
72fbcbbb-a5d6-46e0-afbe-595e18d48bde	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-21	2	24	1479	1	0	0	3	0	0	9.70	2.73	2025-11-24 10:28:30.859344
8dd11909-08c1-4d1d-b172-12a0daca7613	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-20	5	24	1660	1	0	0	1	0	0	4.63	7.01	2025-11-24 10:28:30.859344
933bfde2-8bc8-4a5e-9333-d7fa34aac1df	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-19	1	24	742	5	0	0	2	1	0	2.36	7.13	2025-11-24 10:28:30.859344
cd87e471-a1a9-4001-af8b-4a2465b03cda	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-18	3	7	884	9	0	0	3	0	0	2.97	1.27	2025-11-24 10:28:30.859344
dc948663-b82b-4eef-a405-1b03c9d0a17e	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-17	3	13	1543	10	0	0	0	0	0	5.06	9.36	2025-11-24 10:28:30.859344
f7b44d1e-2447-47e4-ba86-f8f1cd386908	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-16	2	10	1478	2	0	0	0	0	0	7.46	9.37	2025-11-24 10:28:30.859344
e008424f-929a-43d8-a756-85a6aff95107	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-15	2	18	1820	1	0	0	0	0	0	8.32	1.33	2025-11-24 10:28:30.859344
8608f294-a578-4faf-a4f5-42049b0dd078	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-14	0	20	822	3	0	0	3	2	0	7.24	8.62	2025-11-24 10:28:30.859344
5f4cee44-4834-4ea5-8fb0-1fe9ab4486ad	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-13	5	19	1488	3	0	0	0	0	0	8.65	6.64	2025-11-24 10:28:30.859344
628ac2f3-6fb1-4d6b-86fc-4b5afe4f558d	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-12	4	20	307	3	0	1	3	0	0	3.75	2.12	2025-11-24 10:28:30.859344
10202efa-d049-4465-b99a-e9581d8ea790	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-11	1	8	721	8	0	0	0	0	0	8.16	6.06	2025-11-24 10:28:30.859344
f443a76b-ce55-4a7b-9e27-a0025f9aaed1	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-10	1	15	1564	2	0	0	0	0	0	7.31	9.15	2025-11-24 10:28:30.859344
43ebef8e-1851-4255-ae56-dcb0602d0245	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-09	3	9	862	5	1	0	0	0	0	7.94	2.55	2025-11-24 10:28:30.859344
243c9c2e-df73-4227-a590-2dd88c80aab2	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-08	3	21	911	7	0	0	3	1	0	6.49	1.63	2025-11-24 10:28:30.859344
11a260e7-4bb0-40fd-8534-c147282cf10f	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-07	1	21	381	2	0	0	0	0	0	7.97	0.99	2025-11-24 10:28:30.859344
6db6c0e3-76d3-4dce-9740-e8644e87cbe4	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-06	5	23	1571	5	0	0	0	2	0	3.97	5.13	2025-11-24 10:28:30.859344
e08875af-07c2-4390-b716-12b08bdc01d5	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-05	0	24	1284	0	0	0	4	0	0	3.52	8.75	2025-11-24 10:28:30.859344
92bbd79a-29ef-4268-a00f-039d23b100dc	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-04	2	16	1729	0	1	0	0	0	0	7.14	4.51	2025-11-24 10:28:30.859344
2597b6af-5997-4495-84da-be41719e9d3d	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-03	2	22	968	8	0	0	0	0	0	0.75	6.03	2025-11-24 10:28:30.859344
01eaa39a-d3e0-4aaa-9ff8-d4b0c5de672f	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-02	0	23	2034	9	0	0	1	0	0	8.69	2.27	2025-11-24 10:28:30.859344
e038eff9-aa77-4bc3-aa72-3d73336a4b18	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-11-01	1	20	916	6	0	0	0	0	0	9.18	6.80	2025-11-24 10:28:30.859344
221d8821-2260-4b0f-a77a-d714935742e5	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-10-31	3	24	1343	3	0	0	0	0	0	2.23	1.73	2025-11-24 10:28:30.859344
1a4fb47c-3217-4bd5-aec2-069c4b547486	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-10-30	3	8	1675	1	0	0	0	0	0	2.98	8.92	2025-11-24 10:28:30.859344
ce727b75-e2d5-495a-a74c-e5e0fbc3558d	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-10-29	1	22	831	3	0	0	3	0	0	2.18	2.91	2025-11-24 10:28:30.859344
3e4c23c7-33ca-47df-b273-55a2bfddc3e0	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-10-28	1	20	755	6	0	0	0	0	0	1.12	5.22	2025-11-24 10:28:30.859344
f84a8943-9783-4788-87e9-943f30cdd2c2	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-10-27	2	19	1928	3	0	0	0	0	0	9.68	9.67	2025-11-24 10:28:30.859344
65d04ced-dd25-4e81-93a1-90445048457d	d3c63e20-1c1a-47f8-9999-c65dfd88859a	2025-10-26	1	16	1021	6	0	0	0	2	0	8.95	5.01	2025-11-24 10:28:30.859344
84711c82-910c-43f2-94d4-8b9b40df02f9	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-24	1	7	1525	5	0	0	0	0	0	1.91	3.31	2025-11-24 10:28:30.859344
8cd6b641-1e95-4fbe-ad17-dcf8a28a8dac	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-23	1	19	1696	7	0	0	0	0	0	1.17	3.41	2025-11-24 10:28:30.859344
86aa1aa1-1bb4-41f7-a452-a3ba486768d7	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-22	0	13	1769	5	0	0	0	0	0	8.22	2.63	2025-11-24 10:28:30.859344
2fd20f66-f4eb-4bf0-96b4-e540c7732be0	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-21	4	17	1217	3	0	0	2	2	0	7.84	8.33	2025-11-24 10:28:30.859344
4d78ef45-aef7-41bc-96d8-bcedf5a7a0b2	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-20	3	13	1478	9	0	0	0	2	0	6.13	2.93	2025-11-24 10:28:30.859344
1732a27a-36d1-402c-b6e1-a48e6659f37f	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-19	0	23	636	10	0	0	0	0	0	4.32	8.04	2025-11-24 10:28:30.859344
fb67337f-ff9d-4b72-819d-a1507d625b0d	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-18	3	22	1930	7	0	0	3	0	0	1.63	8.03	2025-11-24 10:28:30.859344
7ed7fe8d-cb84-4aa9-aceb-9c67e40bccc3	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-17	4	20	859	8	0	1	0	0	1	1.99	8.96	2025-11-24 10:28:30.859344
0714c15f-741c-4f92-af9c-bdb2a0874d62	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-16	3	10	949	8	0	0	2	0	0	2.12	5.62	2025-11-24 10:28:30.859344
1cba562b-2174-498f-a175-1c57bb497a9c	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-15	4	10	343	2	0	0	0	0	0	4.42	0.96	2025-11-24 10:28:30.859344
b085c656-4ff1-4eea-8fdd-7b5685d5b181	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-14	2	13	1864	3	0	0	1	0	0	4.90	6.84	2025-11-24 10:28:30.859344
11fca488-eee5-45c6-96eb-b654d8b8f86c	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-13	1	17	1518	10	0	0	3	2	0	1.55	9.81	2025-11-24 10:28:30.859344
dd2023c3-1e4b-4a97-a238-9d698ef8c2f6	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-12	1	19	1132	5	0	0	1	0	0	5.56	3.07	2025-11-24 10:28:30.859344
7fbfae55-e046-47a5-a755-63bc9d9019e9	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-11	1	22	1656	2	0	0	2	2	0	1.22	4.24	2025-11-24 10:28:30.859344
5eeeb4d9-227f-442b-b55e-172a70a0b7bb	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-10	4	23	1549	5	0	0	3	0	0	0.32	6.78	2025-11-24 10:28:30.859344
e985e823-364a-4478-88d4-20cdb5093594	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-09	3	17	1094	7	0	0	4	0	0	1.31	4.88	2025-11-24 10:28:30.859344
2d4d2114-b473-400d-99fb-3e8ba6a23252	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-08	4	19	371	5	0	0	3	0	0	1.86	3.99	2025-11-24 10:28:30.859344
019291a8-ee0b-463a-914b-40e1ed4ef41b	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-07	1	11	1063	1	0	0	1	0	0	4.11	3.88	2025-11-24 10:28:30.859344
1d7c9c1a-54fd-4d52-8ab8-44b399158525	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-06	2	12	731	8	0	0	0	0	0	4.95	3.77	2025-11-24 10:28:30.859344
96da282d-9062-42f9-9823-54243806b183	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-05	0	14	1198	8	0	0	0	0	0	7.66	7.93	2025-11-24 10:28:30.859344
c52b44d6-d62b-4e94-90b4-1fc70654e9d1	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-04	3	7	1890	9	0	0	0	0	0	4.92	0.53	2025-11-24 10:28:30.859344
c6446612-550b-45ed-8b79-58ad9b1eba4e	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-03	1	17	1368	5	0	0	0	0	0	4.38	4.16	2025-11-24 10:28:30.859344
9720e4ae-f103-4137-9f26-69543d81aa73	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-02	2	16	1380	1	0	0	2	2	0	8.47	3.87	2025-11-24 10:28:30.859344
fc37f8ae-1975-4599-b60b-7cd4d42f175b	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-11-01	4	12	1696	3	1	0	0	0	0	6.90	3.49	2025-11-24 10:28:30.859344
fd08c791-f6c0-4bfe-8f76-2e0897277de0	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-10-31	5	23	952	3	0	0	3	0	0	8.75	7.16	2025-11-24 10:28:30.859344
85de1043-bc89-4ac7-92ea-31fb4536783c	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-10-30	2	14	1682	3	0	0	1	0	0	1.85	0.56	2025-11-24 10:28:30.859344
eb9c444c-39aa-46a0-9a4c-1353bca49ad5	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-10-29	5	14	1031	3	0	0	0	0	0	1.57	1.65	2025-11-24 10:28:30.859344
6072ffee-29aa-4574-b4ed-974a526b0eb8	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-10-28	1	18	1696	6	0	0	0	3	0	6.90	3.11	2025-11-24 10:28:30.859344
1a2e5caf-a6e0-4c32-9b0d-d6a48ad5e74c	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-10-27	1	6	534	1	0	0	0	0	0	3.99	0.45	2025-11-24 10:28:30.859344
fcddce45-e6a9-4ee1-a108-44ea9b33f008	c5dbfbb5-8797-415c-9919-6f4992b51cc1	2025-10-26	3	11	760	8	0	0	4	3	0	2.85	1.61	2025-11-24 10:28:30.859344
14f1c861-f1c7-46dc-af09-b73576e75154	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-24	5	19	1074	8	0	0	3	0	0	5.61	5.20	2025-11-24 10:28:30.859344
65d653f4-d52d-4866-a48b-53ef12ff7859	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-23	4	13	988	6	0	0	2	0	0	0.59	0.13	2025-11-24 10:28:30.859344
b2de4fd4-dc1d-414d-98cd-c5e5ee2268eb	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-22	4	9	924	10	0	0	3	0	0	3.60	8.01	2025-11-24 10:28:30.859344
200f9ccf-6587-451b-9ef3-8aa7ebb24262	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-21	3	6	1765	2	0	0	0	0	0	5.32	7.03	2025-11-24 10:28:30.859344
483837dd-c43e-431c-9e29-59c19e283936	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-20	1	13	819	2	0	0	0	0	0	6.86	3.86	2025-11-24 10:28:30.859344
a92ed5d0-5fda-4284-a8cd-9308e2340c7a	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-19	1	7	1007	3	1	0	0	0	1	8.76	3.84	2025-11-24 10:28:30.859344
78aa7bc3-5f6f-4caa-9a59-7973c520be37	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-18	3	11	1124	4	0	0	0	0	0	7.64	3.63	2025-11-24 10:28:30.859344
aab373b8-62ec-4b6f-aea9-dca9f38c589c	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-17	3	22	699	3	0	0	2	0	0	3.66	8.07	2025-11-24 10:28:30.859344
d99aad1b-b08d-4418-a273-ab2584a0a921	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-16	0	18	898	9	0	0	0	0	0	3.90	9.72	2025-11-24 10:28:30.859344
e6c6ecb6-d1c0-473d-929f-598a56cf6235	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-15	1	24	316	6	0	0	0	0	0	9.17	5.50	2025-11-24 10:28:30.859344
035a671a-4f7e-494f-aa3f-2ec204f7fd00	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-14	5	16	1538	4	0	0	0	3	0	6.35	9.84	2025-11-24 10:28:30.859344
a6f5c507-f27b-432f-8cb9-755ad5fe0de6	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-13	3	24	344	10	0	0	0	3	0	8.28	6.50	2025-11-24 10:28:30.859344
712386b4-55aa-4106-9235-cd591b878d17	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-12	2	9	1538	9	0	0	3	0	0	1.75	8.94	2025-11-24 10:28:30.859344
ab14528a-3596-4371-ac97-968dfe3040a9	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-11	1	19	1806	8	0	0	0	2	0	8.63	6.15	2025-11-24 10:28:30.859344
6eafcca4-7e3f-4aec-90ca-a822304aed08	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-10	4	11	957	1	0	0	1	2	0	6.26	3.36	2025-11-24 10:28:30.859344
3e87a677-7dff-40c8-be35-f832bca2071e	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-09	2	16	1311	2	0	0	0	0	0	9.61	0.10	2025-11-24 10:28:30.859344
71a8d17f-200c-4841-bf6b-576127b9bde8	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-08	4	18	1228	6	0	0	3	0	0	2.10	3.32	2025-11-24 10:28:30.859344
096344c5-dde8-4a59-8149-b9b43a34a530	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-07	3	24	1591	10	0	0	0	2	0	4.10	4.34	2025-11-24 10:28:30.859344
f4df08a8-ddf1-4db9-9904-5048f8e27794	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-06	5	23	632	8	0	0	0	0	0	3.67	0.49	2025-11-24 10:28:30.859344
4b918750-a182-4e04-95ed-f26623460cf1	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-05	0	24	1836	8	0	0	3	0	0	8.24	5.20	2025-11-24 10:28:30.859344
efc9b039-df6a-48e6-b384-4f22f92b58b3	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-04	4	15	1599	7	0	0	0	0	0	0.21	0.36	2025-11-24 10:28:30.859344
195b6b50-856b-4bf4-b50a-c00814fadae8	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-03	5	22	1540	9	0	0	0	0	0	3.36	7.06	2025-11-24 10:28:30.859344
ed3bafc1-8f7d-43a3-9bb9-574f479a706a	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-02	3	9	969	7	0	0	2	3	0	8.71	4.74	2025-11-24 10:28:30.859344
aa9d68b1-6be8-4075-8191-3ccd30de2410	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-11-01	5	17	978	3	0	0	2	0	0	9.55	8.99	2025-11-24 10:28:30.859344
5b07b843-6d4a-4111-b0ab-d114e16e8cd3	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-10-31	5	25	797	6	0	0	0	0	0	7.62	4.01	2025-11-24 10:28:30.859344
44e238f8-317a-4c69-a22e-959995c8e317	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-10-30	3	11	658	10	0	0	0	0	0	6.69	7.72	2025-11-24 10:28:30.859344
0f67f6c3-cb31-403b-9c01-07bccbaf759c	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-10-29	1	9	1604	5	0	0	0	0	0	1.31	9.57	2025-11-24 10:28:30.859344
a6bc0611-8cb4-4267-8291-f1926b7eea4e	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-10-28	2	13	1206	4	0	0	0	0	0	8.16	5.93	2025-11-24 10:28:30.859344
a15c461a-635c-4467-a2b3-e208ca4d4385	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-10-27	2	10	470	6	0	0	0	0	0	4.38	6.66	2025-11-24 10:28:30.859344
96997d8a-d523-4720-9734-c780f7c13791	2b99fc80-2a41-4e25-a130-67ff675990a9	2025-10-26	3	14	452	8	0	0	0	0	0	1.44	3.60	2025-11-24 10:28:30.859344
1ec087bb-c8e3-4d9e-9fb9-e7079ab9f30c	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-24	5	18	1796	6	0	0	0	0	0	6.61	3.80	2025-11-24 10:28:30.859344
19f1aa66-3f5e-4ba0-a028-c3f46eb2fcb8	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-23	2	16	2004	10	0	0	0	0	0	1.08	6.01	2025-11-24 10:28:30.859344
dbbf79ef-173a-479b-b11b-e1c9d7463d48	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-22	4	15	931	5	0	0	0	3	0	0.61	4.26	2025-11-24 10:28:30.859344
f71a3a1a-f415-415a-a1f6-5d21268e2704	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-21	4	8	1883	3	0	0	2	2	0	8.30	4.97	2025-11-24 10:28:30.859344
0362aa71-177a-4bd4-ad42-9b38c5935275	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-20	0	5	1068	8	0	0	3	0	0	0.22	0.91	2025-11-24 10:28:30.859344
e993e51f-a21e-4b1f-b0a5-9d2f87c5ca92	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-19	0	5	2020	9	1	0	0	0	0	3.44	6.31	2025-11-24 10:28:30.859344
d56f815e-d1cd-4efa-bc2d-bcc01c912d96	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-18	1	6	848	2	0	0	4	0	0	2.97	6.88	2025-11-24 10:28:30.859344
6e9ff5c0-2888-4feb-a405-75bb1a42dda6	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-17	0	16	1995	9	0	0	0	3	0	8.69	6.76	2025-11-24 10:28:30.859344
151e0af0-12c6-4349-acf2-d51f3b85ff77	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-16	4	6	1643	8	0	0	0	0	0	4.22	8.63	2025-11-24 10:28:30.859344
47260267-1eaa-4f3d-aac8-2e2bfd296e93	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-15	5	17	407	3	1	0	0	0	0	6.59	7.39	2025-11-24 10:28:30.859344
cdd77f82-795f-44e4-b2d4-78e1b3324e7f	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-14	2	15	1176	7	0	0	0	0	0	0.08	6.98	2025-11-24 10:28:30.859344
aa3bda10-3a33-4d9a-b286-8828fa1a3779	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-13	4	22	1323	7	0	0	0	0	0	6.00	8.46	2025-11-24 10:28:30.859344
cfcc70cb-2d60-49bd-9ae2-d4c055425aec	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-12	2	19	338	10	0	1	3	0	0	7.42	2.74	2025-11-24 10:28:30.859344
c381e9d5-9ad2-4609-a162-6ef79499366b	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-11	5	14	1195	7	0	0	0	0	0	4.35	0.68	2025-11-24 10:28:30.859344
75f06138-29f8-4661-a7db-97127f848b64	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-10	3	17	1006	9	1	0	0	3	0	7.68	2.01	2025-11-24 10:28:30.859344
1b311db6-90f5-4d33-bcdc-588662ff3299	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-09	0	11	1046	8	0	1	0	0	0	3.26	9.59	2025-11-24 10:28:30.859344
006fb619-923f-491d-9949-82b197518aa1	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-08	5	20	745	10	0	0	0	1	0	6.07	3.64	2025-11-24 10:28:30.859344
14570b23-016a-4d46-8bc3-37a3c24a8f65	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-07	5	23	1071	8	0	0	0	0	0	5.91	4.88	2025-11-24 10:28:30.859344
ac3ce0d6-78c0-45ce-b071-778e47df6ad9	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-06	1	23	1303	9	0	0	0	0	0	2.10	1.29	2025-11-24 10:28:30.859344
5b65b2d8-d256-438f-93d8-77956d1d8326	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-05	1	8	888	9	1	0	3	0	0	8.31	5.46	2025-11-24 10:28:30.859344
d83a8d99-6223-4108-b217-3186a21758b9	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-04	2	13	2008	5	0	0	0	0	0	7.34	0.63	2025-11-24 10:28:30.859344
302c0633-ce51-4d34-8c5a-2f8c2b7e1a5b	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-03	2	17	357	6	0	0	3	2	1	2.99	3.08	2025-11-24 10:28:30.859344
18f53f10-65ee-4f6a-9c19-e00177259912	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-02	3	13	759	0	1	0	2	0	0	3.94	8.90	2025-11-24 10:28:30.859344
008b6e79-d548-4f7e-b0d2-a6279dd281ad	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-11-01	5	15	835	4	0	0	0	0	0	9.49	1.22	2025-11-24 10:28:30.859344
2afb4db4-7659-47d2-bfb6-6db10b1012bf	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-10-31	2	22	2038	9	0	0	2	0	0	8.36	1.96	2025-11-24 10:28:30.859344
a4fa31b6-d628-4124-b7fa-2a836e2cbc23	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-10-30	4	23	1467	7	0	0	0	0	1	5.05	9.26	2025-11-24 10:28:30.859344
01725f73-573e-4594-bbeb-f982d32d0c2b	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-10-29	3	17	2035	1	0	0	0	0	0	8.11	1.52	2025-11-24 10:28:30.859344
bfb4343c-4e0c-495a-9c3f-2d482060cfce	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-10-28	3	17	345	3	1	0	0	0	0	2.59	8.35	2025-11-24 10:28:30.859344
faf8a0ef-33ef-4e6d-b6b3-4672dec18bc7	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-10-27	5	24	565	8	0	0	0	0	0	8.14	1.75	2025-11-24 10:28:30.859344
8a60cb49-6dfd-40ee-954b-cfe5e9706af5	a93d7375-c27d-4da7-bfea-51d7e354827a	2025-10-26	2	7	1083	3	0	0	4	1	0	8.98	2.38	2025-11-24 10:28:30.859344
8624b180-f32e-4276-8a7f-a2489e976025	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-24	5	23	1006	0	0	0	0	2	0	8.40	6.41	2025-11-24 10:28:30.859344
a68abeeb-033c-4088-bbe7-f9404b2d11b7	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-23	0	7	1819	2	0	1	2	1	0	2.14	6.72	2025-11-24 10:28:30.859344
eb5dec18-c8a9-4ff4-bd74-f1532a0ace8e	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-22	1	21	905	7	0	1	0	0	1	8.34	7.27	2025-11-24 10:28:30.859344
c0f581e2-347c-4d55-ba2b-e7b79fb55afb	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-21	3	10	1281	0	1	0	0	0	0	2.11	7.65	2025-11-24 10:28:30.859344
18722421-6920-4853-8c1e-4e8837fdb5af	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-20	1	6	516	7	1	0	0	0	0	3.18	3.30	2025-11-24 10:28:30.859344
ae909268-40b0-4a5c-ab33-369d69b63816	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-19	3	19	387	3	0	0	3	0	0	7.45	9.50	2025-11-24 10:28:30.859344
d072d6b7-9200-4b56-93d8-d9191e5fe401	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-18	1	9	690	0	1	0	2	0	0	9.17	7.85	2025-11-24 10:28:30.859344
2f1204a4-2b65-4b65-b36e-37a6853f62b7	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-17	2	17	1328	10	0	0	0	0	0	9.65	0.38	2025-11-24 10:28:30.859344
96c18094-243f-49d1-be14-c66a6625270a	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-16	1	18	625	8	0	0	0	0	0	6.37	9.26	2025-11-24 10:28:30.859344
0a0426ae-d97e-472e-bde9-ee4860d8cf59	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-15	1	8	1590	1	0	0	2	2	0	1.76	7.11	2025-11-24 10:28:30.859344
ec3c3550-f06e-477c-816d-a37286b8004e	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-14	4	6	1080	6	0	0	0	0	0	1.87	5.47	2025-11-24 10:28:30.859344
aea358e8-69d9-40a3-a04e-4f7b4f730431	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-13	1	14	1813	4	0	0	1	0	0	0.15	1.35	2025-11-24 10:28:30.859344
a066b740-954e-475d-8a59-4d43bbebe4a0	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-12	4	23	335	1	0	0	0	0	0	0.86	0.91	2025-11-24 10:28:30.859344
c63798f7-4ad5-4df5-8e77-daeed7af527d	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-11	4	16	481	7	0	0	0	0	0	3.56	8.76	2025-11-24 10:28:30.859344
70a01e31-6a16-43a6-91a0-a404d7501756	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-10	1	5	1234	6	0	0	0	0	0	6.06	2.33	2025-11-24 10:28:30.859344
f9534402-a568-4e3b-a0a3-c3c809894f47	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-09	5	15	710	4	0	0	0	0	0	3.87	4.59	2025-11-24 10:28:30.859344
9c6f5409-a063-42ea-a4e3-de8376f9942c	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-08	2	22	568	5	0	0	0	0	0	7.36	1.13	2025-11-24 10:28:30.859344
c47b7929-ac12-4758-8626-19545b6a2c29	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-07	2	14	1673	10	0	0	0	0	0	4.74	9.77	2025-11-24 10:28:30.859344
91d63940-3945-4181-9ade-78001ab2dab6	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-06	5	17	1500	2	0	0	0	0	0	4.85	9.56	2025-11-24 10:28:30.859344
591eeb4b-cb83-4b13-8211-4f7db9ab66d3	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-05	4	16	1050	4	0	0	0	0	0	5.86	0.63	2025-11-24 10:28:30.859344
9a64507f-d2a8-4be5-9552-f5d9c63b7a27	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-04	4	7	421	8	0	0	0	0	0	8.07	2.21	2025-11-24 10:28:30.859344
758da6e1-84a5-4328-8b27-c2f9c57e2781	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-03	0	14	828	7	0	0	0	0	0	8.36	2.73	2025-11-24 10:28:30.859344
ea02e44d-cde4-4de7-8262-6974da17331c	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-02	1	18	1318	10	0	0	0	0	0	0.61	8.42	2025-11-24 10:28:30.859344
6a86d3b6-af34-49e6-b78e-af55667641a3	89d41274-d39f-4733-a13c-db44381ddda7	2025-11-01	2	21	1433	3	0	0	0	0	0	9.27	9.46	2025-11-24 10:28:30.859344
f5bec1f3-0c24-4797-9aad-8fad7c5c179a	89d41274-d39f-4733-a13c-db44381ddda7	2025-10-31	4	24	916	6	0	0	0	1	0	5.28	5.96	2025-11-24 10:28:30.859344
9b15a145-64f9-440e-8b0d-de175e4e178d	89d41274-d39f-4733-a13c-db44381ddda7	2025-10-30	2	22	1450	1	0	0	0	0	0	9.12	7.15	2025-11-24 10:28:30.859344
6f88085a-5150-48bf-bfb4-c421020d4956	89d41274-d39f-4733-a13c-db44381ddda7	2025-10-29	0	13	1635	7	0	0	0	0	0	3.86	2.88	2025-11-24 10:28:30.859344
c3ac0dc5-5434-4112-a726-a6e8298ac6f1	89d41274-d39f-4733-a13c-db44381ddda7	2025-10-28	5	13	670	0	0	0	0	0	0	2.54	1.12	2025-11-24 10:28:30.859344
b284893b-c1bb-48ed-a9b5-2b0220d9e320	89d41274-d39f-4733-a13c-db44381ddda7	2025-10-27	2	19	1782	10	0	0	0	0	0	2.50	2.49	2025-11-24 10:28:30.859344
9ce4adb9-16ce-4049-b1ba-563672a43d88	89d41274-d39f-4733-a13c-db44381ddda7	2025-10-26	1	20	1691	9	0	0	0	0	0	2.24	7.98	2025-11-24 10:28:30.859344
\.


--
-- Data for Name: customer_data_mapping; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.customer_data_mapping (mapping_id, import_id, excel_row_number, customer_name, phone_number, email, policy_number, date_of_birth, address, raw_excel_data, mapping_status, validation_errors, created_customer_id, created_at) FROM stdin;
72bd51b5-a2d8-4edc-abd3-ce8f20055b65	b659efb3-8b41-46bb-be3c-3f47fb71bfaf	628	Customer 998	+919583885209	customer710@example.com	POL7007	\N	\N	\N	error	\N	\N	2025-11-24 10:33:20.011083
31632e14-d1bc-4468-a4f7-11a62ada35ae	dbe63a64-9b23-4c74-a2ee-07c71d6e96d6	298	Customer 106	+919798920264	customer243@example.com	POL876	\N	\N	\N	error	\N	\N	2025-11-24 10:33:20.011083
126c6d80-9c94-4fea-9b33-01ee7fe30da0	9ab16351-a16f-4fd0-95d7-3d7896f7a0f5	352	Customer 65	+919248222759	customer673@example.com	POL6030	\N	\N	\N	mapped	\N	\N	2025-11-24 10:33:20.011083
8bade8f6-9bef-4337-87b1-5236a000f0b7	dbe63a64-9b23-4c74-a2ee-07c71d6e96d6	178	Customer 931	+919522389402	customer527@example.com	POL4516	\N	\N	\N	mapped	\N	\N	2025-11-24 10:33:20.011083
51a6aa62-3d0c-4c75-aa83-edd59df23d3d	9af73e33-dd8f-4b0d-b0e5-df36525d9e04	608	Customer 838	+919259972909	customer207@example.com	POL1995	\N	\N	\N	error	\N	\N	2025-11-24 10:33:20.011083
4f958dd2-f8fb-4496-99c7-ebf08662e774	12e786fc-7cbb-4ea5-9da3-d1a846ece5e1	870	Customer 578	+919117136689	customer690@example.com	POL7646	\N	\N	\N	mapped	\N	\N	2025-11-24 10:33:20.011083
973ea8af-744e-4afb-8cf9-b5396b65a5d9	b659efb3-8b41-46bb-be3c-3f47fb71bfaf	44	Customer 981	+919369684053	customer468@example.com	POL605	\N	\N	\N	mapped	\N	\N	2025-11-24 10:33:20.011083
c5b385e7-f30c-4e44-8390-5f2521f1f6c0	9ab16351-a16f-4fd0-95d7-3d7896f7a0f5	935	Customer 396	+919085203358	customer922@example.com	POL8261	\N	\N	\N	error	\N	\N	2025-11-24 10:33:20.011083
4d06b531-2fc8-4a64-b5b1-6ca8ea5c355d	e93df7d7-32d7-4dbe-abe7-3debd907c1b7	811	Customer 820	+919181432644	customer926@example.com	POL3566	\N	\N	\N	error	\N	\N	2025-11-24 10:33:20.011083
d0dbbb2e-57d7-4894-b3b9-482251a97943	9ab16351-a16f-4fd0-95d7-3d7896f7a0f5	477	Customer 623	+919761057268	customer215@example.com	POL2524	\N	\N	\N	mapped	\N	\N	2025-11-24 10:33:20.011083
\.


--
-- Data for Name: data_export_log; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.data_export_log (export_id, user_id, export_type, record_count, data_types, date_range, encryption_used, ip_address, purpose, retention_period_days, file_name, file_size_bytes, storage_location, created_at, expires_at) FROM stdin;
0f26cad3-58ff-4df3-ad26-1417dc098eef	2da28562-c8be-4dd6-b0ee-5b1863ea66c4	excel	649	{analytics,reports}	["2025-10-25 00:00:00","2025-11-24 00:00:00"]	t	192.168.1.212	Performance analysis	90	export_1763960310.859344_1.csv	3262663	\N	2025-11-24 10:28:30.859344	\N
032ba1b4-769b-45ca-ac95-40490343fff6	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	pdf	994	{analytics,reports}	["2025-10-25 00:00:00","2025-11-24 00:00:00"]	t	192.168.1.235	Monthly reporting	90	export_1763960310.859344_2.csv	1923121	\N	2025-11-24 10:28:30.859344	\N
15659f2a-4389-45d1-a684-fcecd2e0d1b0	ddeee6e1-757f-4220-ad26-649bd9fd2987	excel	839	{policies,customers}	["2025-10-25 00:00:00","2025-11-24 00:00:00"]	t	192.168.1.253	Monthly reporting	90	export_1763960310.859344_3.csv	2246682	\N	2025-11-24 10:28:30.859344	\N
f6cf7a96-50ff-451f-962b-8930341362ff	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	pdf	596	{policies,customers}	["2025-10-25 00:00:00","2025-11-24 00:00:00"]	t	192.168.1.62	Compliance audit	90	export_1763960310.859344_4.csv	4429603	\N	2025-11-24 10:28:30.859344	\N
5f075eca-e07f-4e75-adb8-c89266cb014d	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	csv	310	{analytics,reports}	["2025-10-25 00:00:00","2025-11-24 00:00:00"]	t	192.168.1.211	Monthly reporting	90	export_1763960310.859344_5.csv	1766454	\N	2025-11-24 10:28:30.859344	\N
48a70d60-707c-4152-8605-41f53561b037	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	excel	430	{payments,commissions}	["2025-10-25 00:00:00","2025-11-24 00:00:00"]	t	192.168.1.60	Performance analysis	90	export_1763960310.859344_6.csv	1990021	\N	2025-11-24 10:28:30.859344	\N
6da13a11-28c0-4b08-8569-cf95deca848c	5fbb7605-85a8-40b1-9e6e-ec405d8af18c	csv	398	{analytics,reports}	["2025-10-25 00:00:00","2025-11-24 00:00:00"]	t	192.168.1.71	Performance analysis	90	export_1763960310.859344_7.csv	6162083	\N	2025-11-24 10:28:30.859344	\N
0140734b-4fe4-4df4-aa9d-3acacee1fd87	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	pdf	604	{payments,commissions}	["2025-10-25 00:00:00","2025-11-24 00:00:00"]	t	192.168.1.163	Performance analysis	90	export_1763960310.859344_8.csv	5964794	\N	2025-11-24 10:28:30.859344	\N
108b64c0-1485-45ce-9c52-a0c2b1f03acc	ef9f8c57-26ea-4e55-a5fe-a08dbba3ee83	pdf	198	{policies,customers}	["2025-10-25 00:00:00","2025-11-24 00:00:00"]	t	192.168.1.238	Performance analysis	90	export_1763960310.859344_9.csv	4046513	\N	2025-11-24 10:28:30.859344	\N
c7a65193-3ce9-444d-a457-a66120414989	045a6ed3-c48b-4d1c-ac86-8776bda0050f	excel	150	{analytics,reports}	["2025-10-25 00:00:00","2025-11-24 00:00:00"]	t	192.168.1.55	Performance analysis	90	export_1763960310.859344_10.csv	4284711	\N	2025-11-24 10:28:30.859344	\N
\.


--
-- Data for Name: data_imports; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.data_imports (import_id, agent_id, file_name, file_path, file_size_bytes, import_type, status, total_records, processed_records, error_records, error_details, processing_started_at, processing_completed_at, created_at, updated_at) FROM stdin;
6341b508-ce48-45b1-b3b3-233c8b939abe	\N	import_1_1763960468.716097.csv	\N	\N	agents	processing	6222	4195	48	\N	2025-11-24 08:31:08.716097	\N	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
dbe63a64-9b23-4c74-a2ee-07c71d6e96d6	\N	import_2_1763960468.716097.csv	\N	\N	payments	completed	4250	4800	1	{"errors": ["5 invalid email formats", "3 missing phone numbers"]}	2025-11-24 08:31:08.716097	2025-11-24 10:01:08.716097	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
455a30e4-c729-45c7-a45b-34fa9f8ac8bb	\N	import_3_1763960468.716097.csv	\N	\N	payments	completed	4267	3038	97	{"errors": ["5 invalid email formats", "3 missing phone numbers"]}	2025-11-24 08:31:08.716097	\N	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
855cdb55-8428-43dd-a7c3-24b7d53bc4e9	\N	import_4_1763960468.716097.csv	\N	\N	payments	processing	4717	4625	52	\N	2025-11-24 08:31:08.716097	2025-11-24 10:01:08.716097	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
b659efb3-8b41-46bb-be3c-3f47fb71bfaf	\N	import_5_1763960468.716097.csv	\N	\N	agents	processing	9919	4186	67	{"errors": ["5 invalid email formats", "3 missing phone numbers"]}	2025-11-24 08:31:08.716097	2025-11-24 10:01:08.716097	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
12e786fc-7cbb-4ea5-9da3-d1a846ece5e1	\N	import_6_1763960468.716097.csv	\N	\N	agents	processing	3311	6620	46	{"errors": ["5 invalid email formats", "3 missing phone numbers"]}	2025-11-24 08:31:08.716097	2025-11-24 10:01:08.716097	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
e93df7d7-32d7-4dbe-abe7-3debd907c1b7	\N	import_7_1763960468.716097.csv	\N	\N	payments	failed	5937	4549	72	\N	2025-11-24 08:31:08.716097	\N	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
9ab16351-a16f-4fd0-95d7-3d7896f7a0f5	\N	import_8_1763960468.716097.csv	\N	\N	payments	failed	6751	4369	30	\N	2025-11-24 08:31:08.716097	2025-11-24 10:01:08.716097	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
9af73e33-dd8f-4b0d-b0e5-df36525d9e04	\N	import_9_1763960468.716097.csv	\N	\N	customers	processing	6106	1453	81	{"errors": ["5 invalid email formats", "3 missing phone numbers"]}	2025-11-24 08:31:08.716097	2025-11-24 10:01:08.716097	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
9f2e0e42-4725-4320-85a0-406612db6a01	\N	import_10_1763960468.716097.csv	\N	\N	agents	completed	1848	6970	54	\N	2025-11-24 08:31:08.716097	2025-11-24 10:01:08.716097	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
\.


--
-- Data for Name: data_sync_status; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.data_sync_status (sync_id, agent_id, customer_id, last_sync_at, sync_status, sync_type, error_message, retry_count, next_retry_at, created_at, updated_at) FROM stdin;
0450fe5f-8905-4e96-8372-34c9ab92afdc	\N	\N	2025-11-23 22:31:08.716097	failed	agents	\N	0	2025-11-24 14:31:08.716097	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
20e1c38c-1202-44e6-b61f-b55d604ce4b5	\N	\N	2025-11-24 00:31:08.716097	in_progress	customers	Connection timeout after 30 seconds	0	2025-11-24 12:31:08.716097	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
eaf12f40-0bd0-460b-9c9d-836b117e469b	\N	\N	2025-11-23 10:31:08.716097	pending	payments	\N	0	\N	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
fbc06265-72d9-45ea-8038-dd22540f59e0	\N	\N	2025-11-23 11:31:08.716097	completed	customers	\N	0	\N	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
63671ac5-a971-462a-99ac-e34f3f88867e	\N	\N	2025-11-24 06:31:08.716097	in_progress	policies	\N	0	\N	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
c400ac0d-d05f-4c6d-8515-9f2e9e38470e	\N	\N	2025-11-23 21:31:08.716097	failed	customers	\N	0	2025-11-24 13:31:08.716097	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
706efc99-fa3b-427b-8d9a-562d605827ac	\N	\N	2025-11-24 10:31:08.716097	completed	agents	\N	0	2025-11-24 11:31:08.716097	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
d2c8594e-0f8c-4df9-8712-d040d577cbc9	\N	\N	2025-11-23 20:31:08.716097	completed	customers	\N	0	2025-11-24 15:31:08.716097	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
94f24443-8d46-444e-af5c-1d1082fe0203	\N	\N	2025-11-24 07:31:08.716097	failed	policies	\N	0	2025-11-24 13:31:08.716097	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
ce4270d9-bfad-4e36-ad9f-cc6e88ab074d	\N	\N	2025-11-23 13:31:08.716097	pending	claims	Connection timeout after 30 seconds	0	2025-11-24 14:31:08.716097	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
\.


--
-- Data for Name: device_tokens; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.device_tokens (id, user_id, token, device_type, created_at, last_used_at) FROM stdin;
1	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	device_token_a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11_android_1763960301.255893	android	2025-11-17 10:28:21.255893+05:30	2025-11-24 08:28:21.255893+05:30
2	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	device_token_a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11_ios_1763960301.255893	ios	2025-11-19 10:28:21.255893+05:30	2025-11-23 10:28:21.255893+05:30
3	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	device_token_a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12_android_1763960301.255893	android	2025-11-17 10:28:21.255893+05:30	2025-11-24 08:28:21.255893+05:30
4	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	device_token_a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12_ios_1763960301.255893	ios	2025-11-19 10:28:21.255893+05:30	2025-11-23 10:28:21.255893+05:30
5	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	device_token_a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13_android_1763960301.255893	android	2025-11-17 10:28:21.255893+05:30	2025-11-24 08:28:21.255893+05:30
6	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	device_token_a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13_ios_1763960301.255893	ios	2025-11-19 10:28:21.255893+05:30	2025-11-23 10:28:21.255893+05:30
7	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	device_token_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20_android_1763960301.255893	android	2025-11-17 10:28:21.255893+05:30	2025-11-24 08:28:21.255893+05:30
8	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	device_token_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20_ios_1763960301.255893	ios	2025-11-19 10:28:21.255893+05:30	2025-11-23 10:28:21.255893+05:30
9	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	device_token_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21_android_1763960301.255893	android	2025-11-17 10:28:21.255893+05:30	2025-11-24 08:28:21.255893+05:30
10	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	device_token_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21_ios_1763960301.255893	ios	2025-11-19 10:28:21.255893+05:30	2025-11-23 10:28:21.255893+05:30
11	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22	device_token_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22_android_1763960301.255893	android	2025-11-17 10:28:21.255893+05:30	2025-11-24 08:28:21.255893+05:30
12	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22	device_token_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22_ios_1763960301.255893	ios	2025-11-19 10:28:21.255893+05:30	2025-11-23 10:28:21.255893+05:30
13	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	device_token_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23_android_1763960301.255893	android	2025-11-17 10:28:21.255893+05:30	2025-11-24 08:28:21.255893+05:30
14	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	device_token_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23_ios_1763960301.255893	ios	2025-11-19 10:28:21.255893+05:30	2025-11-23 10:28:21.255893+05:30
15	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	device_token_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24_android_1763960301.255893	android	2025-11-17 10:28:21.255893+05:30	2025-11-24 08:28:21.255893+05:30
16	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	device_token_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24_ios_1763960301.255893	ios	2025-11-19 10:28:21.255893+05:30	2025-11-23 10:28:21.255893+05:30
17	ea2b3915-033a-4ee6-b798-673ce79beab8	device_token_ea2b3915-033a-4ee6-b798-673ce79beab8_android_1763960301.255893	android	2025-11-17 10:28:21.255893+05:30	2025-11-24 08:28:21.255893+05:30
18	ea2b3915-033a-4ee6-b798-673ce79beab8	device_token_ea2b3915-033a-4ee6-b798-673ce79beab8_ios_1763960301.255893	ios	2025-11-19 10:28:21.255893+05:30	2025-11-23 10:28:21.255893+05:30
19	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	device_token_15f336f5-58a4-49a5-b1d5-26df0d6ed2a7_android_1763960301.255893	android	2025-11-17 10:28:21.255893+05:30	2025-11-24 08:28:21.255893+05:30
20	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	device_token_15f336f5-58a4-49a5-b1d5-26df0d6ed2a7_ios_1763960301.255893	ios	2025-11-19 10:28:21.255893+05:30	2025-11-23 10:28:21.255893+05:30
\.


--
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.flyway_schema_history (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) FROM stdin;
1	1	Create shared schema	SQL	V1__Create_shared_schema.sql	2050221321	agentmitra	2025-11-23 22:34:55.420343	9	t
2	2	Create tenant schemas	SQL	V2__Create_tenant_schemas.sql	-1912658828	agentmitra	2025-11-23 22:34:55.447615	54	t
3	3	Create lic schema tables	SQL	V3__Create_lic_schema_tables.sql	-578465177	agentmitra	2025-11-23 22:34:55.516151	80	t
4	4	Create presentation tables	SQL	V4__Create_presentation_tables.sql	-579676657	agentmitra	2025-11-23 22:34:55.61174	57	t
5	5	Seed test users and presentations	SQL	V5__Seed_test_users_and_presentations.sql	-1040637352	agentmitra	2025-11-23 22:34:55.680062	14	t
6	6	Alter user sessions token columns	SQL	V6__Alter_user_sessions_token_columns.sql	1571164045	agentmitra	2025-11-23 22:34:55.700319	4	t
7	7	Database performance indexes	SQL	V7__Database_performance_indexes.sql	-892795210	agentmitra	2025-11-23 22:34:55.708699	9	t
8	8	Fix password hashes	SQL	V8__Fix_password_hashes.sql	-937324813	agentmitra	2025-11-23 22:34:55.72275	3	t
9	9	Seed comprehensive test data	SQL	V9__Seed_comprehensive_test_data.sql	-47411727	agentmitra	2025-11-23 22:34:55.730114	17	t
10	10	Create advanced analytics tables	SQL	V10__Create_advanced_analytics_tables.sql	700586136	agentmitra	2025-11-23 22:34:55.75384	76	t
11	11	Create notification tables	SQL	V11__Create_notification_tables.sql	-1447061493	agentmitra	2025-11-23 22:34:55.840048	20	t
12	\N	Seed analytics chatbot data	SQL	R__Seed_analytics_chatbot_data.sql	-1138796245	agentmitra	2025-11-23 22:34:55.865056	2	t
13	\N	Seed initial data	SQL	R__Seed_initial_data.sql	1841294938	agentmitra	2025-11-23 22:34:55.872553	8	t
14	12	Migrate shared data to lic schema	SQL	V13__Migrate_shared_data_to_lic_schema.sql	-139071238	agentmitra	2025-11-23 22:35:15.664658	31	t
15	13	Fix schema foreign key constraints	SQL	V16__Ensure_minimum_seed_data.sql	-1673096031	agentmitra	2025-11-23 23:18:24.297012	24	t
16	14	Add comprehensive seed data	SQL	V17__Ensure_minimum_seed_data.sql	-714245728	agentmitra	2025-11-23 23:19:48.499138	40	t
17	15	Seed phase1 core auth data	SQL	V15__Seed_phase1_core_auth_data.sql	128485574	agentmitra	2025-11-24 10:28:21.241891	36	t
18	16	Seed phase2 analytics data	SQL	V16__Seed_phase2_analytics_data.sql	1513415597	agentmitra	2025-11-24 10:28:30.838711	55	t
19	17	Seed phase3 communication data	SQL	V17__Seed_phase3_communication_data.sql	-1168077545	agentmitra	2025-11-24 10:29:01.449893	36	t
20	18	Seed phase4 presentation data	SQL	V18__Seed_phase4_presentation_data.sql	1678977781	agentmitra	2025-11-24 10:29:01.504865	24	t
21	19	Seed phase5 data management	SQL	V19__Seed_phase5_data_management.sql	-1516476901	agentmitra	2025-11-24 10:31:08.703521	25	t
22	20	Seed enhance existing and final	SQL	V20__Seed_enhance_existing_and_final.sql	-1521739685	agentmitra	2025-11-24 10:33:19.994002	29	t
23	21	Seed final remaining tables	SQL	V21__Seed_final_remaining_tables.sql	1266143208	agentmitra	2025-11-24 10:41:38.504814	24	t
\.


--
-- Data for Name: import_jobs; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.import_jobs (job_id, import_id, job_type, priority, status, retry_count, max_retries, error_message, started_at, completed_at, created_at) FROM stdin;
c5b44b4f-8485-41d3-930b-8d28ed5895fc	9f2e0e42-4725-4320-85a0-406612db6a01	validate	5	processing	0	3	Validation failed for 5 records	2025-11-24 09:31:08.716097	\N	2025-11-24 10:31:08.716097
720d76a3-e596-45b1-a9f7-8237ea25e4df	9af73e33-dd8f-4b0d-b0e5-df36525d9e04	process	5	failed	0	3	\N	2025-11-24 09:31:08.716097	2025-11-24 10:01:08.716097	2025-11-24 10:31:08.716097
7d158316-e30e-4953-9318-230460642a26	9ab16351-a16f-4fd0-95d7-3d7896f7a0f5	process	1	processing	2	3	\N	2025-11-24 09:31:08.716097	2025-11-24 10:01:08.716097	2025-11-24 10:31:08.716097
0639c0e5-5809-47b8-b371-20d3b55c3807	6341b508-ce48-45b1-b3b3-233c8b939abe	cleanup	5	failed	0	3	\N	2025-11-24 09:31:08.716097	\N	2025-11-24 10:31:08.716097
938e5994-8c16-4c2b-b4a0-312aed18d7ab	6341b508-ce48-45b1-b3b3-233c8b939abe	process	5	completed	1	3	\N	2025-11-24 09:31:08.716097	\N	2025-11-24 10:31:08.716097
98579076-3836-459f-97f3-bfb3b1bc2660	455a30e4-c729-45c7-a45b-34fa9f8ac8bb	process	3	failed	0	3	\N	2025-11-24 09:31:08.716097	2025-11-24 10:01:08.716097	2025-11-24 10:31:08.716097
4452c5fe-f549-4a4f-81b3-3156a4a49dc3	9af73e33-dd8f-4b0d-b0e5-df36525d9e04	cleanup	1	completed	0	3	\N	2025-11-24 09:31:08.716097	\N	2025-11-24 10:31:08.716097
5843f686-b82a-49f1-b858-654b919dd3b7	855cdb55-8428-43dd-a7c3-24b7d53bc4e9	process	3	failed	0	3	Validation failed for 5 records	2025-11-24 09:31:08.716097	2025-11-24 10:01:08.716097	2025-11-24 10:31:08.716097
678f9403-af73-44ba-ad2a-eb4d983d6976	855cdb55-8428-43dd-a7c3-24b7d53bc4e9	cleanup	5	completed	0	3	\N	2025-11-24 09:31:08.716097	2025-11-24 10:01:08.716097	2025-11-24 10:31:08.716097
aeb64a75-b181-4c18-80f4-64e3c4be8ba8	b659efb3-8b41-46bb-be3c-3f47fb71bfaf	process	5	failed	2	3	Validation failed for 5 records	2025-11-24 09:31:08.716097	\N	2025-11-24 10:31:08.716097
\.


--
-- Data for Name: insurance_categories; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.insurance_categories (category_id, category_code, category_name, category_type, description, status) FROM stdin;
424e42b5-4a0d-40a3-aa7e-364618f4b64c	LIFE_TERM	Term Life Insurance	life	Pure life insurance coverage for a specific term period	active
37b8d14f-9d3d-4f1e-80cf-5b7c3fc77514	LIFE_WHOLE	Whole Life Insurance	life	Permanent life insurance with cash value accumulation	active
5a9f35f2-2456-41c1-863e-8828a01d1028	LIFE_ULIP	Unit Linked Insurance Plan	life	Combination of insurance and investment	active
78a317bf-9921-4e94-9168-bf8d13d3388c	HEALTH_INDIVIDUAL	Individual Health Insurance	health	Health coverage for individuals	active
786467aa-0724-43b1-adbb-aaf8afcc9cfb	HEALTH_FAMILY	Family Health Insurance	health	Health coverage for entire family	active
556aedb0-5c3c-457c-b7a5-329a1d4f26f2	HEALTH_SENIOR	Senior Citizen Health Insurance	health	Health coverage for senior citizens	active
e8c75371-4cef-4e00-9657-f44ebb4b8705	CHILD_PLAN	Child Plan	life	Savings and insurance plan for children	active
d29e06f9-61c6-4de3-8902-aa99658e847c	RETIREMENT	Retirement Plan	life	Pension and retirement savings plan	active
9376828e-cdc8-4e39-90a4-2ede3b8198c8	MOTOR	Motor Insurance	general	Vehicle insurance coverage	active
5eac643c-fe28-4d88-b55a-8bb2080a3edb	TRAVEL	Travel Insurance	general	Travel and medical coverage during trips	active
\.


--
-- Data for Name: insurance_policies; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.insurance_policies (policy_id, policy_number, provider_policy_id, policyholder_id, agent_id, provider_id, policy_type, plan_name, plan_code, category, sum_assured, premium_amount, premium_frequency, premium_mode, application_date, approval_date, start_date, maturity_date, renewal_date, status, sub_status, payment_status, coverage_details, exclusions, terms_and_conditions, policy_document_url, application_form_url, medical_reports, nominee_details, assignee_details, created_by, approved_by, last_payment_date, next_payment_date, total_payments, outstanding_amount, created_at, updated_at) FROM stdin;
f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	POL001001	\N	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	01fa8d3a-5509-4f73-abeb-617fd547f16d	term_life	LIC Term Plan	TERM2024	life	5000000.00	15000.00	annual	\N	2025-10-24	\N	2025-11-23	\N	\N	active	\N	pending	\N	\N	\N	\N	\N	\N	\N	\N	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	\N	\N	0	0.00	2025-11-23 22:34:55.73505	2025-11-23 22:34:55.73505
f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	POL001002	\N	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	01fa8d3a-5509-4f73-abeb-617fd547f16d	health_insurance	LIC Health Shield	HEALTH2024	health	300000.00	8500.00	annual	\N	2025-11-08	\N	2025-11-23	\N	\N	active	\N	pending	\N	\N	\N	\N	\N	\N	\N	\N	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	\N	\N	0	0.00	2025-11-23 22:34:55.73505	2025-11-23 22:34:55.73505
f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	POL002001	\N	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	01fa8d3a-5509-4f73-abeb-617fd547f16d	ulip	LIC ULIP Plan	ULIP2024	life	2000000.00	25000.00	annual	\N	2025-11-03	\N	2025-11-23	\N	\N	pending_approval	\N	pending	\N	\N	\N	\N	\N	\N	\N	\N	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	\N	\N	\N	0	0.00	2025-11-23 22:34:55.73505	2025-11-23 22:34:55.73505
f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	POL003001	\N	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	01fa8d3a-5509-4f73-abeb-617fd547f16d	retirement	LIC Retirement Plan	RETIRE2024	life	10000000.00	50000.00	annual	\N	2025-11-13	\N	2025-11-28	\N	\N	draft	\N	pending	\N	\N	\N	\N	\N	\N	\N	\N	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	\N	\N	\N	0	0.00	2025-11-23 22:34:55.73505	2025-11-23 22:34:55.73505
f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14	POL001003	\N	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	01fa8d3a-5509-4f73-abeb-617fd547f16d	child_plan	LIC Child Plan	CHILD2024	life	1000000.00	12000.00	annual	\N	2025-11-18	\N	2025-11-23	\N	\N	approved	\N	pending	\N	\N	\N	\N	\N	\N	\N	\N	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	\N	\N	0	0.00	2025-11-23 22:34:55.73505	2025-11-23 22:34:55.73505
99b51442-a86b-424f-adc3-24fc81ecfd1e	SEED_POL001	\N	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	1a4c8c40-d885-4c6d-b39a-8a42e3b4652d	048a9c69-46d3-47cd-88fd-83efe9bd2b0b	term_life	Seed Term Plan	\N	\N	5000000.00	25000.00	annual	\N	2025-10-24	\N	2025-11-03	\N	\N	active	\N	pending	{"term": 20, "riders": ["Critical Illness"]}	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0.00	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
97233aff-7079-431c-9ea0-7f283f47224e	SEED_POL002	\N	d3c63e20-1c1a-47f8-9999-c65dfd88859a	f580839c-4af3-4ebb-9935-bdb8c7acf7b6	01fa8d3a-5509-4f73-abeb-617fd547f16d	whole_life	Seed Whole Life	\N	\N	3000000.00	30000.00	annual	\N	2025-10-29	\N	2025-11-08	\N	\N	active	\N	pending	{"term": 30, "riders": ["Waiver of Premium"]}	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0.00	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
631e4685-f1c9-48a0-adca-509727d72508	SEED_POL003	\N	c5dbfbb5-8797-415c-9919-6f4992b51cc1	991e6172-dcd1-4ca7-9c82-85cbbd14f6b3	33225144-c3fd-412d-9e70-e67f25e5a47a	ulip	Seed ULIP	\N	\N	4000000.00	35000.00	annual	\N	2025-11-03	\N	2025-11-13	\N	\N	active	\N	pending	{"term": 15, "funds": ["Equity", "Debt"]}	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0.00	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
bf42e11a-3a94-457e-a77b-aede73f42967	SEED_POL004	\N	2b99fc80-2a41-4e25-a130-67ff675990a9	e2038ed1-cedc-4be8-9055-ef3a66bb1907	048a9c69-46d3-47cd-88fd-83efe9bd2b0b	endowment	Seed Endowment	\N	\N	2000000.00	20000.00	annual	\N	2025-11-08	\N	2025-11-18	\N	\N	active	\N	pending	{"term": 25, "riders": ["Accidental Death"]}	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0.00	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
4642386e-22d0-49bc-a415-23e7704eb53f	SEED_POL005	\N	a93d7375-c27d-4da7-bfea-51d7e354827a	ff5e562b-9a46-4a04-81d1-ce54e425acbd	01fa8d3a-5509-4f73-abeb-617fd547f16d	term_life	Seed Term Plus	\N	\N	2500000.00	15000.00	annual	\N	2025-11-13	\N	2025-11-23	\N	\N	active	\N	pending	{"term": 15, "riders": []}	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0.00	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
33f33eeb-9bfc-4172-90f1-cdf4d72260d7	SEED_POL006	\N	89d41274-d39f-4733-a13c-db44381ddda7	bd40bf61-c2ad-4071-b868-ad54ab7cfa8d	33225144-c3fd-412d-9e70-e67f25e5a47a	whole_life	Seed Whole Plus	\N	\N	3500000.00	28000.00	annual	\N	2025-10-19	\N	2025-10-29	\N	\N	active	\N	pending	{"term": 25, "riders": ["Critical Illness", "Waiver"]}	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0.00	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
70a8105e-e5d6-4d75-af24-bcd703a07d6f	SEED_POL007	\N	6074ed27-e32d-4166-8f38-d753b2597bd4	e45c1148-56b7-4605-b183-68ea7aec4383	048a9c69-46d3-47cd-88fd-83efe9bd2b0b	ulip	Seed ULIP Pro	\N	\N	4500000.00	40000.00	annual	\N	2025-10-14	\N	2025-10-24	\N	\N	active	\N	pending	{"term": 20, "funds": ["Equity", "Balanced"]}	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0.00	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
3373eb9a-9630-4bd6-93a4-0ee09407463c	SEED_POL008	\N	09647396-2e53-4146-8cd5-c8bbde0cc4a3	91ad72ed-42d2-46ad-8338-4d22d8f7c80f	01fa8d3a-5509-4f73-abeb-617fd547f16d	endowment	Seed Endowment Plus	\N	\N	3000000.00	25000.00	annual	\N	2025-10-09	\N	2025-10-19	\N	\N	active	\N	pending	{"term": 30, "riders": ["Critical Illness"]}	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0.00	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
4979eff5-4575-4ade-98bf-accb7777e845	SEED_POL009	\N	50b15302-0a4c-433c-b765-15d5079c8fcc	da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec	33225144-c3fd-412d-9e70-e67f25e5a47a	term_life	Seed Term Elite	\N	\N	6000000.00	35000.00	annual	\N	2025-10-04	\N	2025-10-14	\N	\N	active	\N	pending	{"term": 25, "riders": ["Critical Illness", "Waiver", "Accidental Death"]}	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0.00	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
1f8305fe-7cc4-42e6-8b90-5e504ae019a9	SEED_POL010	\N	f2541310-2def-4d20-99d5-40e14d567c2f	c47a7151-d764-4ad0-85ed-a2dc7c4d5ef3	048a9c69-46d3-47cd-88fd-83efe9bd2b0b	whole_life	Seed Whole Elite	\N	\N	5000000.00	45000.00	annual	\N	2025-09-29	\N	2025-10-09	\N	\N	active	\N	pending	{"term": 30, "riders": ["Waiver of Premium"]}	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0.00	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
\.


--
-- Data for Name: insurance_providers; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.insurance_providers (provider_id, provider_code, provider_name, provider_type, description, api_endpoint, api_credentials, webhook_url, webhook_secret, license_number, regulatory_authority, established_year, headquarters, supported_languages, business_hours, service_regions, commission_structure, status, integration_status, last_sync_at, created_at, updated_at) FROM stdin;
048a9c69-46d3-47cd-88fd-83efe9bd2b0b	LIC	Life Insurance Corporation of India	life_insurance	Largest life insurance company in India	\N	\N	\N	\N	LIC-001	IRDAI	1956	{"city": "Mumbai", "state": "Maharashtra", "country": "India"}	{en,hi,te,ta,kn,mr,gu,bn,ml,pa}	\N	\N	\N	active	pending	\N	2025-11-21 13:00:53.717908	2025-11-21 13:00:53.717908
01fa8d3a-5509-4f73-abeb-617fd547f16d	HDFC_LIFE	HDFC Life Insurance Company	life_insurance	Leading private life insurance provider	\N	\N	\N	\N	HDFC-001	IRDAI	2000	{"city": "Mumbai", "state": "Maharashtra", "country": "India"}	{en,hi}	\N	\N	\N	active	pending	\N	2025-11-21 13:00:53.717908	2025-11-21 13:00:53.717908
33225144-c3fd-412d-9e70-e67f25e5a47a	ICICI_PRUDENTIAL	ICICI Prudential Life Insurance	life_insurance	Joint venture between ICICI Bank and Prudential	\N	\N	\N	\N	ICICI-001	IRDAI	2000	{"city": "Mumbai", "state": "Maharashtra", "country": "India"}	{en,hi}	\N	\N	\N	active	pending	\N	2025-11-21 13:00:53.717908	2025-11-21 13:00:53.717908
f6613f86-3bb5-49fe-875a-036c21e73800	SEED_LIC	Seed LIC Provider	life_insurance	Seed insurance provider for testing	\N	\N	\N	\N	\N	\N	\N	\N	{en}	\N	\N	\N	active	pending	\N	2025-11-23 23:18:24.308084	2025-11-23 23:18:24.308084
ddf40160-5705-422d-b887-4881972c16cf	SEED_HDFC	Seed HDFC Provider	life_insurance	Seed insurance provider for testing	\N	\N	\N	\N	\N	\N	\N	\N	{en}	\N	\N	\N	active	pending	\N	2025-11-23 23:18:24.308084	2025-11-23 23:18:24.308084
cd28c1b2-e5b4-4162-b63e-4ee70a7414f3	SEED_ICICI	Seed ICICI Provider	life_insurance	Seed insurance provider for testing	\N	\N	\N	\N	\N	\N	\N	\N	{en}	\N	\N	\N	active	pending	\N	2025-11-23 23:18:24.308084	2025-11-23 23:18:24.308084
926e6011-18ab-41d3-9512-c47b4ef4deae	SEED_BAJAJ	Seed Bajaj Provider	life_insurance	Seed insurance provider for testing	\N	\N	\N	\N	\N	\N	\N	\N	{en}	\N	\N	\N	active	pending	\N	2025-11-23 23:18:24.308084	2025-11-23 23:18:24.308084
a34a0c15-1337-4c21-8b1d-77f0c0409b91	SEED_SBI	Seed SBI Provider	life_insurance	Seed insurance provider for testing	\N	\N	\N	\N	\N	\N	\N	\N	{en}	\N	\N	\N	active	pending	\N	2025-11-23 23:18:24.308084	2025-11-23 23:18:24.308084
0e496781-cdc8-47ff-8c0e-adf1e48159df	SEED_TATA	Seed Tata Provider	life_insurance	Seed insurance provider for testing	\N	\N	\N	\N	\N	\N	\N	\N	{en}	\N	\N	\N	active	pending	\N	2025-11-23 23:18:24.308084	2025-11-23 23:18:24.308084
bdf7b8b9-7467-4979-b72e-d3c6a92e70a4	SEED_MAX	Seed Max Provider	life_insurance	Seed insurance provider for testing	\N	\N	\N	\N	\N	\N	\N	\N	{en}	\N	\N	\N	active	pending	\N	2025-11-23 23:18:24.308084	2025-11-23 23:18:24.308084
1c59a1d5-e9b4-4286-b2da-4eccbf101e80	SEED_PNB	Seed PNB Provider	life_insurance	Seed insurance provider for testing	\N	\N	\N	\N	\N	\N	\N	\N	{en}	\N	\N	\N	active	pending	\N	2025-11-23 23:18:24.308084	2025-11-23 23:18:24.308084
2ba6a4f1-cca1-49a0-bb66-94c68e1a4347	SEED_ADITYA	Seed Aditya Provider	life_insurance	Seed insurance provider for testing	\N	\N	\N	\N	\N	\N	\N	\N	{en}	\N	\N	\N	active	pending	\N	2025-11-23 23:18:24.308084	2025-11-23 23:18:24.308084
bca25ad9-b8b1-49bb-ab2a-7438b087e97d	SEED_KOTAK	Seed Kotak Provider	life_insurance	Seed insurance provider for testing	\N	\N	\N	\N	\N	\N	\N	\N	{en}	\N	\N	\N	active	pending	\N	2025-11-23 23:18:24.308084	2025-11-23 23:18:24.308084
\.


--
-- Data for Name: knowledge_base_articles; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.knowledge_base_articles (article_id, title, content, summary, category, sub_category, tags, content_type, language, difficulty_level, embedding_vector, keywords_extracted, related_articles, view_count, helpful_votes, total_votes, average_rating, is_active, is_featured, moderation_status, created_by, moderated_by, created_at, updated_at, published_at) FROM stdin;
392ecd83-46ba-45d9-bfb1-c2c7922c4297	Life Insurance Basics: What You Need to Know	Life insurance is a contract between you and an insurance company. In exchange for premium payments, the insurance company provides a lump-sum payment, known as a death benefit, to beneficiaries when the insured passes away...	\N	life_insurance	\N	{basics,fundamentals,beginners}	guide	en	beginner	\N	\N	\N	0	0	0	\N	t	t	approved	\N	\N	2025-11-23 22:34:55.759949	2025-11-23 22:34:55.759949	\N
63150e1e-f9ca-4c1c-96c7-fc01d321d6e6	How to File an Insurance Claim	Filing an insurance claim can seem daunting, but following these steps will help you through the process smoothly...	\N	claims	\N	{claims,procedures,help}	guide	en	intermediate	\N	\N	\N	0	0	0	\N	t	t	approved	\N	\N	2025-11-23 22:34:55.759949	2025-11-23 22:34:55.759949	\N
65460e2b-4290-4fa6-9614-c542a50fa57f	Term Life Insurance Guide	Comprehensive guide explaining term life insurance, coverage options, premium calculation, and benefits...	\N	life_insurance	\N	{term_life,coverage,premium}	text	en	intermediate	\N	\N	\N	250	45	50	\N	t	f	approved	5fbb7605-85a8-40b1-9e6e-ec405d8af18c	\N	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083	\N
cdcc1492-8133-446c-9ec7-0a725a3eff64	Health Insurance Coverage Types	Detailed explanation of different health insurance coverage types including hospitalization, critical illness, and OPD...	\N	health_insurance	\N	{health,coverage,hospitalization}	text	en	intermediate	\N	\N	\N	180	38	42	\N	t	f	approved	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	\N	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083	\N
40f71893-d32a-4ac3-ab22-604aaf11f0d0	Investment Linked Insurance Plans	Guide to ULIP and other investment-linked insurance plans, fund options, and returns...	\N	investment	\N	{ulip,investment,funds}	text	en	intermediate	\N	\N	\N	320	67	72	\N	t	f	approved	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	\N	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083	\N
19341a53-0fe4-4577-a068-1f62fefbb032	Retirement Planning with Insurance	How to use insurance products for retirement planning and pension benefits...	\N	retirement	\N	{retirement,pension,planning}	text	en	intermediate	\N	\N	\N	150	28	32	\N	t	f	approved	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083	\N
72de27b7-03b4-41ae-90c7-4e9e0ea1c76b	Filing Insurance Claims	Step-by-step guide to filing different types of insurance claims...	\N	claims	\N	{claims,procedure,documents}	text	en	intermediate	\N	\N	\N	400	89	95	\N	t	f	approved	5fbb7605-85a8-40b1-9e6e-ec405d8af18c	\N	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083	\N
b1502e8b-816b-4b94-9b4f-347c0eed46c1	Tax Benefits on Insurance	Complete guide to tax deductions available under Section 80C, 80D, and other provisions...	\N	tax	\N	{tax,deductions,80c}	text	en	intermediate	\N	\N	\N	280	52	58	\N	t	f	approved	ddeee6e1-757f-4220-ad26-649bd9fd2987	\N	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083	\N
9a362a96-462b-43d3-ba0d-c6f987f66b61	Child Education Insurance Plans	Planning for child education using insurance policies and education funds...	\N	child_plans	\N	{children,education,future}	text	en	intermediate	\N	\N	\N	190	41	45	\N	t	f	approved	ea2b3915-033a-4ee6-b798-673ce79beab8	\N	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083	\N
245e0149-1783-42c2-834f-0df30bbd4b9e	Insurance Policy Renewal Process	Everything you need to know about renewing your insurance policies online and offline...	\N	renewal	\N	{renewal,process,online}	text	en	intermediate	\N	\N	\N	220	48	52	\N	t	f	approved	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	\N	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083	\N
\.


--
-- Data for Name: knowledge_search_log; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.knowledge_search_log (search_id, user_id, session_id, search_query, search_filters, results_count, clicked_article_id, search_time_ms, search_source, ip_address, created_at) FROM stdin;
7d7222e0-491e-4ac8-9421-9ab0fcae0551	4a944faf-5b11-4676-b887-f903da323b80	\N	policy renewal process	{"category": "general", "language": "hi"}	15	63150e1e-f9ca-4c1c-96c7-fc01d321d6e6	810	api	192.168.1.247	2025-11-24 10:31:08.716097
6ddf4ac3-a6b6-4593-a943-77bf644d807b	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	\N	policy renewal process	{"category": "life_insurance", "language": "en"}	9	\N	231	manual	192.168.1.117	2025-11-24 10:31:08.716097
664cae83-b4a8-4f95-a07a-b02c868767d2	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	8ca2abc5-36ec-4592-af72-c6a6d94a61a7	investment plans comparison	{"category": "general", "language": "hi"}	27	\N	420	chatbot	192.168.1.7	2025-11-24 10:31:08.716097
4f1cc405-3a47-47e5-8f20-dbabee996e4b	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	\N	agent commission structure	{"category": "health_insurance", "language": "en"}	18	392ecd83-46ba-45d9-bfb1-c2c7922c4297	198	manual	192.168.1.246	2025-11-24 10:31:08.716097
534faa59-a746-465a-a029-a6ccde6b38e0	ea2b3915-033a-4ee6-b798-673ce79beab8	\N	agent commission structure	{"category": "general", "language": "en"}	39	63150e1e-f9ca-4c1c-96c7-fc01d321d6e6	832	manual	192.168.1.127	2025-11-24 10:31:08.716097
31064abc-d553-4c8b-add8-ba442486a28d	5fbb7605-85a8-40b1-9e6e-ec405d8af18c	8dba1123-bb2d-4a7d-8b30-8073b22c87a8	premium payment methods	{"category": "health_insurance", "language": "hi"}	29	63150e1e-f9ca-4c1c-96c7-fc01d321d6e6	320	api	192.168.1.170	2025-11-24 10:31:08.716097
fe8a6190-e3c3-4c5e-bb7f-50a94373710a	ddeee6e1-757f-4220-ad26-649bd9fd2987	\N	tax benefits on insurance	{"category": "investment", "language": "en"}	2	392ecd83-46ba-45d9-bfb1-c2c7922c4297	717	chatbot	192.168.1.237	2025-11-24 10:31:08.716097
6b0ee863-930a-4193-baf4-d5ee794b4e3e	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	8dba1123-bb2d-4a7d-8b30-8073b22c87a8	term life insurance benefits	{"category": "investment", "language": "en"}	13	\N	836	api	192.168.1.134	2025-11-24 10:31:08.716097
1c46c692-2f5c-4172-98fc-2154ffa819b4	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	agent commission structure	{"category": "general", "language": "en"}	44	63150e1e-f9ca-4c1c-96c7-fc01d321d6e6	209	manual	192.168.1.242	2025-11-24 10:31:08.716097
45a314b1-2f9a-4ac7-974b-160b9a5ccf41	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	63080447-c751-47d1-b6e3-2c4c7ada48bb	health insurance coverage	{"category": "health_insurance", "language": "hi"}	2	\N	897	api	192.168.1.244	2025-11-24 10:31:08.716097
\.


--
-- Data for Name: languages; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.languages (language_id, language_code, language_name, native_name, rtl, status) FROM stdin;
19925dfe-1c3e-4842-a63e-878a23c7c3ab	en	English	English	f	active
3073e552-18ba-4e39-877b-78df5cfc0ab4	hi	Hindi	हिन्दी	f	active
4774c434-fea5-4aa5-aa0d-d91ef8ce004c	te	Telugu	తెలుగు	f	active
618b974c-0601-4481-b2f2-273ab063d494	ta	Tamil	தமிழ்	f	active
a9f8168b-a293-4c81-813a-644529c4d1ed	kn	Kannada	ಕನ್ನಡ	f	active
c82a6d0d-e7c0-43e0-9a38-32330e0c9f82	mr	Marathi	मराठी	f	active
22a2293e-1a13-4aad-81db-bc0c75309484	gu	Gujarati	ગુજરાતી	f	active
509f61d5-0512-46a7-ab2e-dbb35ff4a09b	bn	Bengali	বাংলা	f	active
d69fa08a-e3a9-406c-8741-d89b34393deb	ml	Malayalam	മലയാളം	f	active
53e801b2-13eb-4e11-bb5b-a296bcaf6f05	pa	Punjabi	ਪੰਜਾਬੀ	f	active
\.


--
-- Data for Name: notification_settings; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.notification_settings (id, user_id, enable_push_notifications, enable_policy_notifications, enable_payment_reminders, enable_claim_updates, enable_renewal_notices, enable_marketing_notifications, enable_sound, enable_vibration, show_badge, quiet_hours_enabled, quiet_hours_start, quiet_hours_end, enabled_topics, created_at, updated_at) FROM stdin;
1	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	t	t	t	t	t	f	t	t	t	f	\N	\N	["general", "policies", "payments", "claims", "renewals"]	2025-11-24 10:28:21.255893+05:30	2025-11-24 10:28:21.255893+05:30
2	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	t	t	t	t	t	f	t	t	t	f	\N	\N	["general", "policies", "payments", "claims", "renewals"]	2025-11-24 10:28:21.255893+05:30	2025-11-24 10:28:21.255893+05:30
3	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	t	t	t	t	t	f	t	t	t	f	\N	\N	["general", "policies", "payments", "claims", "renewals"]	2025-11-24 10:28:21.255893+05:30	2025-11-24 10:28:21.255893+05:30
4	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	t	t	t	t	t	f	t	t	t	f	\N	\N	["general", "policies", "payments", "claims", "renewals"]	2025-11-24 10:28:21.255893+05:30	2025-11-24 10:28:21.255893+05:30
5	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	t	t	t	t	t	f	t	t	t	f	\N	\N	["general", "policies", "payments", "claims", "renewals"]	2025-11-24 10:28:21.255893+05:30	2025-11-24 10:28:21.255893+05:30
6	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22	t	t	t	t	t	f	t	t	t	f	\N	\N	["general", "policies", "payments", "claims", "renewals"]	2025-11-24 10:28:21.255893+05:30	2025-11-24 10:28:21.255893+05:30
7	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	t	t	t	t	t	f	t	t	t	f	\N	\N	["general", "policies", "payments", "claims", "renewals"]	2025-11-24 10:28:21.255893+05:30	2025-11-24 10:28:21.255893+05:30
8	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	t	t	t	t	t	f	t	t	t	f	\N	\N	["general", "policies", "payments", "claims", "renewals"]	2025-11-24 10:28:21.255893+05:30	2025-11-24 10:28:21.255893+05:30
9	ea2b3915-033a-4ee6-b798-673ce79beab8	t	t	t	t	t	f	t	t	t	f	\N	\N	["general", "policies", "payments", "claims", "renewals"]	2025-11-24 10:28:21.255893+05:30	2025-11-24 10:28:21.255893+05:30
10	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	t	t	t	t	t	f	t	t	t	f	\N	\N	["general", "policies", "payments", "claims", "renewals"]	2025-11-24 10:28:21.255893+05:30	2025-11-24 10:28:21.255893+05:30
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.notifications (id, user_id, title, body, type, priority, is_read, read_at, action_url, action_route, action_text, image_url, data, created_at, scheduled_at) FROM stdin;
b2c64b08-6595-4856-b154-0448ca40a474	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Policy Renewal Reminder	Your LIC policy #12345 is due for renewal in 15 days. Renew now to avoid lapse.	renewal	medium	t	2025-11-24 08:29:01.463858+05:30	/policies/12345/renew	/policies	Renew Now	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-23 10:29:01.463858+05:30	\N
0f77a7b5-5c44-476e-8f44-acb38689a698	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Premium Payment Due	Premium payment of ₹2,500 is due tomorrow. Pay now to maintain coverage.	payment	high	t	\N	/payments/pay?policy=12345	/payments	Pay Premium	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-22 10:29:01.463858+05:30	\N
44d8216e-dbf2-447e-985d-97b66e58cd62	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	New Feature Available	Check out our new digital claim submission feature for faster processing.	feature	medium	t	2025-11-24 08:29:01.463858+05:30	/features/claims	/features	Learn More	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-21 10:29:01.463858+05:30	\N
72b847c3-3de7-4e64-9a4d-a6e1bca403bd	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	Policy Renewal Reminder	Your LIC policy #12345 is due for renewal in 15 days. Renew now to avoid lapse.	renewal	medium	t	2025-11-24 08:29:01.463858+05:30	/policies/12345/renew	/policies	Renew Now	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-23 10:29:01.463858+05:30	\N
641b92cf-cc37-4c01-962b-e5d37dfeee4f	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	Premium Payment Due	Premium payment of ₹2,500 is due tomorrow. Pay now to maintain coverage.	payment	high	t	2025-11-24 08:29:01.463858+05:30	/payments/pay?policy=12345	/payments	Pay Premium	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-22 10:29:01.463858+05:30	\N
cbf6eaea-45c4-4187-997a-6523317b6b40	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	New Feature Available	Check out our new digital claim submission feature for faster processing.	feature	medium	f	2025-11-24 08:29:01.463858+05:30	/features/claims	/features	Learn More	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-21 10:29:01.463858+05:30	\N
dba8b786-a251-4799-b984-cb5ee0410a48	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	Policy Renewal Reminder	Your LIC policy #12345 is due for renewal in 15 days. Renew now to avoid lapse.	renewal	medium	t	2025-11-24 08:29:01.463858+05:30	/policies/12345/renew	/policies	Renew Now	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-23 10:29:01.463858+05:30	\N
a29bf3d9-2925-410d-a2da-10786bac7ced	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	Premium Payment Due	Premium payment of ₹2,500 is due tomorrow. Pay now to maintain coverage.	payment	high	t	\N	/payments/pay?policy=12345	/payments	Pay Premium	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-22 10:29:01.463858+05:30	\N
359a957a-ac0f-4657-9d5d-5dae3f831bdd	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	New Feature Available	Check out our new digital claim submission feature for faster processing.	feature	medium	t	\N	/features/claims	/features	Learn More	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-21 10:29:01.463858+05:30	\N
449d0306-9f73-462f-b29d-647ba492295d	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	Policy Renewal Reminder	Your LIC policy #12345 is due for renewal in 15 days. Renew now to avoid lapse.	renewal	medium	t	\N	/policies/12345/renew	/policies	Renew Now	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-23 10:29:01.463858+05:30	\N
0d8d6eb6-7a6a-4459-9fdf-e04caedb473e	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	Premium Payment Due	Premium payment of ₹2,500 is due tomorrow. Pay now to maintain coverage.	payment	high	t	2025-11-24 08:29:01.463858+05:30	/payments/pay?policy=12345	/payments	Pay Premium	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-22 10:29:01.463858+05:30	\N
8f20e3de-c3c4-4b58-9f4c-bc76fa9daba9	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	New Feature Available	Check out our new digital claim submission feature for faster processing.	feature	medium	f	2025-11-24 08:29:01.463858+05:30	/features/claims	/features	Learn More	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-21 10:29:01.463858+05:30	\N
ef51686c-78fc-4201-910c-3c592d885eca	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	Policy Renewal Reminder	Your LIC policy #12345 is due for renewal in 15 days. Renew now to avoid lapse.	renewal	medium	t	2025-11-24 08:29:01.463858+05:30	/policies/12345/renew	/policies	Renew Now	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-23 10:29:01.463858+05:30	\N
6cdfd346-c2fc-4018-acf9-a403493a826f	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	Premium Payment Due	Premium payment of ₹2,500 is due tomorrow. Pay now to maintain coverage.	payment	high	t	\N	/payments/pay?policy=12345	/payments	Pay Premium	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-22 10:29:01.463858+05:30	\N
75fb7a61-a86a-43ac-a6e9-ac47ed74c4d2	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	New Feature Available	Check out our new digital claim submission feature for faster processing.	feature	medium	t	2025-11-24 08:29:01.463858+05:30	/features/claims	/features	Learn More	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-21 10:29:01.463858+05:30	\N
c4f75aa1-b583-43c9-9481-7bb2951fdd1b	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22	Policy Renewal Reminder	Your LIC policy #12345 is due for renewal in 15 days. Renew now to avoid lapse.	renewal	medium	t	2025-11-24 08:29:01.463858+05:30	/policies/12345/renew	/policies	Renew Now	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-23 10:29:01.463858+05:30	\N
f44d38ae-2907-4e27-8fee-31074def36b4	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22	Premium Payment Due	Premium payment of ₹2,500 is due tomorrow. Pay now to maintain coverage.	payment	high	t	\N	/payments/pay?policy=12345	/payments	Pay Premium	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-22 10:29:01.463858+05:30	\N
9004efe1-b410-4bbe-bbf0-2099d354782d	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22	New Feature Available	Check out our new digital claim submission feature for faster processing.	feature	medium	f	\N	/features/claims	/features	Learn More	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-21 10:29:01.463858+05:30	\N
59ac9387-9b9a-4088-829b-6b26ff4dbc68	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	Policy Renewal Reminder	Your LIC policy #12345 is due for renewal in 15 days. Renew now to avoid lapse.	renewal	medium	f	2025-11-24 08:29:01.463858+05:30	/policies/12345/renew	/policies	Renew Now	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-23 10:29:01.463858+05:30	\N
3be0cd03-d98e-4577-a36c-93449e5601e7	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	Premium Payment Due	Premium payment of ₹2,500 is due tomorrow. Pay now to maintain coverage.	payment	high	t	\N	/payments/pay?policy=12345	/payments	Pay Premium	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-22 10:29:01.463858+05:30	\N
830af036-5e1c-450e-ab16-87be1982b811	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	New Feature Available	Check out our new digital claim submission feature for faster processing.	feature	medium	t	2025-11-24 08:29:01.463858+05:30	/features/claims	/features	Learn More	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-21 10:29:01.463858+05:30	\N
1efc6363-9efd-4771-894b-adaacb5f12c3	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	Policy Renewal Reminder	Your LIC policy #12345 is due for renewal in 15 days. Renew now to avoid lapse.	renewal	medium	t	2025-11-24 08:29:01.463858+05:30	/policies/12345/renew	/policies	Renew Now	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-23 10:29:01.463858+05:30	\N
431b17ba-ad28-4247-953e-298c3b89707d	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	Premium Payment Due	Premium payment of ₹2,500 is due tomorrow. Pay now to maintain coverage.	payment	high	t	2025-11-24 08:29:01.463858+05:30	/payments/pay?policy=12345	/payments	Pay Premium	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-22 10:29:01.463858+05:30	\N
65479d56-8f5e-4924-8e2e-507b4033bc04	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	New Feature Available	Check out our new digital claim submission feature for faster processing.	feature	medium	f	2025-11-24 08:29:01.463858+05:30	/features/claims	/features	Learn More	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-21 10:29:01.463858+05:30	\N
0d8d91be-8d1b-4f02-912d-8d289294c1d8	ea2b3915-033a-4ee6-b798-673ce79beab8	Policy Renewal Reminder	Your LIC policy #12345 is due for renewal in 15 days. Renew now to avoid lapse.	renewal	medium	t	\N	/policies/12345/renew	/policies	Renew Now	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-23 10:29:01.463858+05:30	\N
8106fe62-c160-47a0-ad69-3750f4934b60	ea2b3915-033a-4ee6-b798-673ce79beab8	Premium Payment Due	Premium payment of ₹2,500 is due tomorrow. Pay now to maintain coverage.	payment	high	f	\N	/payments/pay?policy=12345	/payments	Pay Premium	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-22 10:29:01.463858+05:30	\N
ac5dc524-21e9-4e6d-8cdb-4555dbacbd25	ea2b3915-033a-4ee6-b798-673ce79beab8	New Feature Available	Check out our new digital claim submission feature for faster processing.	feature	medium	f	2025-11-24 08:29:01.463858+05:30	/features/claims	/features	Learn More	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-21 10:29:01.463858+05:30	\N
738fcf44-8698-410a-bb48-3fdab14b28cf	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	Policy Renewal Reminder	Your LIC policy #12345 is due for renewal in 15 days. Renew now to avoid lapse.	renewal	medium	t	2025-11-24 08:29:01.463858+05:30	/policies/12345/renew	/policies	Renew Now	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-23 10:29:01.463858+05:30	\N
a1f49b64-68f3-43fb-a528-94584647aa52	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	Premium Payment Due	Premium payment of ₹2,500 is due tomorrow. Pay now to maintain coverage.	payment	high	t	\N	/payments/pay?policy=12345	/payments	Pay Premium	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-22 10:29:01.463858+05:30	\N
bf59e158-af1a-4802-868b-8281eff08e32	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	New Feature Available	Check out our new digital claim submission feature for faster processing.	feature	medium	t	2025-11-24 08:29:01.463858+05:30	/features/claims	/features	Learn More	\N	{"amount": 2500, "due_date": "2025-11-25T00:00:00", "policy_id": "12345"}	2025-11-21 10:29:01.463858+05:30	\N
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.permissions (permission_id, permission_name, permission_description, resource_type, action, created_at) FROM stdin;
e554300e-ce26-4c6e-936d-26780b0fa117	users.create	Create users	user	create	2025-11-23 22:34:55.877872
7b3ccee0-2251-48e6-a8e4-fc8d0b8d2248	users.read	Read users	user	read	2025-11-23 22:34:55.877872
9c823a3d-91f8-4e30-994f-3a8c69a7f9e9	users.update	Update users	user	update	2025-11-23 22:34:55.877872
65f6b657-ddaf-4f4f-b15f-3216cf7d47cf	users.delete	Delete users	user	delete	2025-11-23 22:34:55.877872
4d21c5b8-9399-402e-a468-bae0f4b805fd	agents.create	Create agents	agent	create	2025-11-23 22:34:55.877872
db2d8775-4464-466a-afa5-09f57cb25c2b	agents.read	Read agents	agent	read	2025-11-23 22:34:55.877872
383fea3c-3b59-4c2c-8595-b89b106f1557	agents.update	Update agents	agent	update	2025-11-23 22:34:55.877872
c824ce9c-3988-4d1a-9dd1-549877ac31ca	policies.create	Create policies	policy	create	2025-11-23 22:34:55.877872
7c0cec13-546e-44ad-ac24-c5ef49998a83	policies.read	Read policies	policy	read	2025-11-23 22:34:55.877872
aca24e7f-8a6c-4c45-aae9-5752b7717508	policies.update	Update policies	policy	update	2025-11-23 22:34:55.877872
8809a3da-74cb-4ff9-a1fb-e3c497e67410	policies.delete	Delete policies	policy	delete	2025-11-23 22:34:55.877872
73876d58-f8fd-409f-b5dc-b5dc6590fe05	customers.create	Create customers	customer	create	2025-11-23 22:34:55.877872
951ae4aa-f460-49c1-9c63-d9e066b7b5e7	customers.read	Read customers	customer	read	2025-11-23 22:34:55.877872
3e074f2b-03f5-4bd4-8fd8-93d9a99b0c06	customers.update	Update customers	customer	update	2025-11-23 22:34:55.877872
71e669cb-3a13-4e15-b01f-36e435d60dfa	payments.create	Create payments	payment	create	2025-11-23 22:34:55.877872
896e5149-9f07-4b63-9507-b9184f31e528	payments.read	Read payments	payment	read	2025-11-23 22:34:55.877872
1efcd4c6-4666-4e44-9585-a46aead5e13f	reports.read	Read reports	report	read	2025-11-23 22:34:55.877872
40096ae6-9ac5-44f1-b29a-318c1ab205ef	presentations.create	Create presentations	presentation	create	2025-11-23 22:34:55.877872
c65ffb10-0a67-458c-9573-acac5804a0b9	presentations.read	Read presentations	presentation	read	2025-11-23 22:34:55.877872
815dba00-fe7a-4d5f-be11-ef58ead81a52	presentations.update	Update presentations	presentation	update	2025-11-23 22:34:55.877872
bcaba375-602f-4df1-9d0d-b81bc86aa1b1	presentations.publish	Publish presentations	presentation	publish	2025-11-23 22:34:55.877872
\.


--
-- Data for Name: policy_analytics_summary; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.policy_analytics_summary (summary_id, summary_date, summary_period, draft_policies, pending_policies, approved_policies, active_policies, lapsed_policies, cancelled_policies, life_policies, health_policies, general_policies, total_premium, average_premium, applications_received, applications_approved, conversion_rate, created_at) FROM stdin;
aed84e15-fa20-4ce0-a971-75021b62f733	2025-11-23	daily	10	15	135	120	5	3	80	45	25	2500000.00	16666.67	0	0	0.00	2025-11-23 22:34:55.866866
0d1681fe-60a9-4f79-9239-04ef26fa33c6	2025-11-23	weekly	11	26	130	106	9	2	94	36	23	2536695.15	18308.25	40	21	91.49	2025-11-24 10:33:20.011083
564e4689-2cb0-4b33-8045-dad685ffc9dd	2025-11-22	monthly	7	21	132	135	9	3	79	56	28	3799191.60	17857.56	38	27	84.60	2025-11-24 10:33:20.011083
35005b55-16fe-4f9e-bded-13b862bcf411	2025-11-21	daily	6	16	165	112	8	2	105	45	22	3129061.16	15291.35	35	21	87.11	2025-11-24 10:33:20.011083
60cfa240-632a-4919-9ebc-96618d68869b	2025-11-20	weekly	9	21	167	123	8	4	82	55	34	3749289.58	17074.10	30	29	88.31	2025-11-24 10:33:20.011083
e478cd58-328a-44ab-86ae-18fe157cb410	2025-11-19	monthly	9	20	149	111	5	3	102	38	33	2837180.45	19587.67	38	12	93.91	2025-11-24 10:33:20.011083
f4099dc2-9e24-455c-a8df-cea36e45279d	2025-11-18	daily	15	12	140	138	5	5	71	55	23	3613291.05	19553.40	40	27	79.47	2025-11-24 10:33:20.011083
4f8e3377-39b0-4359-8c13-281fe595877e	2025-11-17	weekly	9	14	162	155	5	3	100	53	22	2177315.81	16907.90	33	28	91.01	2025-11-24 10:33:20.011083
555c4464-6101-4c60-80f1-a88a0288f3c7	2025-11-16	monthly	16	16	169	135	4	4	91	38	23	3037917.33	15481.89	37	31	84.00	2025-11-24 10:33:20.011083
71b9d98c-b9cf-4077-a4b8-8bf0bf7a4919	2025-11-15	daily	9	24	159	140	5	1	72	43	24	3416827.87	17885.05	30	32	87.42	2025-11-24 10:33:20.011083
\.


--
-- Data for Name: policyholders; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.policyholders (policyholder_id, user_id, agent_id, customer_id, salutation, marital_status, occupation, annual_income, education_level, risk_profile, investment_horizon, communication_preferences, marketing_consent, family_members, nominee_details, bank_details, investment_portfolio, preferred_contact_time, preferred_language, digital_literacy_score, engagement_score, onboarding_status, churn_risk_score, last_interaction_at, total_interactions, created_at, updated_at) FROM stdin;
e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	CUST001	Mr.	married	Software Engineer	1200000.00	graduate	{"risk_tolerance": "moderate", "investment_horizon": "long_term"}	\N	\N	t	\N	\N	\N	\N	\N	en	\N	\N	completed	\N	\N	0	2025-11-23 22:34:55.73505	2025-11-23 22:34:55.73505
e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	CUST002	Ms.	single	Teacher	450000.00	post_graduate	{"risk_tolerance": "conservative", "investment_horizon": "medium_term"}	\N	\N	t	\N	\N	\N	\N	\N	hi	\N	\N	completed	\N	\N	0	2025-11-23 22:34:55.73505	2025-11-23 22:34:55.73505
e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	CUST003	Mr.	married	Doctor	2500000.00	post_graduate	{"risk_tolerance": "low", "investment_horizon": "short_term"}	\N	\N	t	\N	\N	\N	\N	\N	en	\N	\N	completed	\N	\N	0	2025-11-23 22:34:55.73505	2025-11-23 22:34:55.73505
e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	CUST004	Mrs.	married	Business Owner	800000.00	graduate	{"risk_tolerance": "high", "investment_horizon": "long_term"}	\N	\N	t	\N	\N	\N	\N	\N	hi	\N	\N	completed	\N	\N	0	2025-11-23 22:34:55.73505	2025-11-23 22:34:55.73505
cbf320e4-c5f6-43a2-9d1d-648b23c5c176	ea2b3915-033a-4ee6-b798-673ce79beab8	1a4c8c40-d885-4c6d-b39a-8a42e3b4652d	SEED_CUST001	Mr.	Married	Software Engineer	1200000.00	\N	\N	\N	{"sms": true, "calls": false, "email": true, "whatsapp": true}	t	[{"name": "Mrs. Seed User1", "relation": "Spouse"}]	\N	\N	\N	\N	en	\N	\N	completed	\N	\N	0	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
d3c63e20-1c1a-47f8-9999-c65dfd88859a	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	f580839c-4af3-4ebb-9935-bdb8c7acf7b6	SEED_CUST002	Mrs.	Single	Doctor	1800000.00	\N	\N	\N	{"sms": false, "calls": true, "email": true, "whatsapp": true}	t	[]	\N	\N	\N	\N	en	\N	\N	completed	\N	\N	0	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
c5dbfbb5-8797-415c-9919-6f4992b51cc1	ea5b10ca-f6dc-4922-901e-8beb02496510	991e6172-dcd1-4ca7-9c82-85cbbd14f6b3	SEED_CUST003	Mr.	Married	Business Owner	2500000.00	\N	\N	\N	{"sms": true, "calls": true, "email": true, "whatsapp": false}	t	[{"name": "Mrs. Seed User5", "relation": "Spouse"}, {"age": 12, "name": "Seed Child1", "relation": "Son"}]	\N	\N	\N	\N	en	\N	\N	completed	\N	\N	0	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
2b99fc80-2a41-4e25-a130-67ff675990a9	4a944faf-5b11-4676-b887-f903da323b80	e2038ed1-cedc-4be8-9055-ef3a66bb1907	SEED_CUST004	Mr.	Married	Teacher	800000.00	\N	\N	\N	{"sms": true, "calls": true, "email": false, "whatsapp": true}	t	[{"name": "Mrs. Seed User6", "relation": "Spouse"}]	\N	\N	\N	\N	en	\N	\N	completed	\N	\N	0	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
a93d7375-c27d-4da7-bfea-51d7e354827a	ef9f8c57-26ea-4e55-a5fe-a08dbba3ee83	ff5e562b-9a46-4a04-81d1-ce54e425acbd	SEED_CUST005	Mrs.	Widowed	Retired	400000.00	\N	\N	\N	{"sms": true, "calls": false, "email": false, "whatsapp": true}	t	[{"name": "Seed Son1", "relation": "Son"}]	\N	\N	\N	\N	en	\N	\N	completed	\N	\N	0	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
89d41274-d39f-4733-a13c-db44381ddda7	2da28562-c8be-4dd6-b0ee-5b1863ea66c4	bd40bf61-c2ad-4071-b868-ad54ab7cfa8d	SEED_CUST006	Mr.	Married	Accountant	1500000.00	\N	\N	\N	{"sms": true, "calls": true, "email": true, "whatsapp": true}	t	[{"name": "Mrs. Seed User10", "relation": "Spouse"}, {"age": 8, "name": "Seed Daughter1", "relation": "Daughter"}]	\N	\N	\N	\N	en	\N	\N	completed	\N	\N	0	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
6074ed27-e32d-4166-8f38-d753b2597bd4	ea2b3915-033a-4ee6-b798-673ce79beab8	e45c1148-56b7-4605-b183-68ea7aec4383	SEED_CUST007	Mr.	Single	Engineer	1000000.00	\N	\N	\N	{"sms": false, "calls": false, "email": true, "whatsapp": true}	t	[]	\N	\N	\N	\N	en	\N	\N	completed	\N	\N	0	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
09647396-2e53-4146-8cd5-c8bbde0cc4a3	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	91ad72ed-42d2-46ad-8338-4d22d8f7c80f	SEED_CUST008	Mrs.	Married	Lawyer	2000000.00	\N	\N	\N	{"sms": true, "calls": true, "email": true, "whatsapp": false}	t	[{"name": "Mr. Seed User2", "relation": "Spouse"}]	\N	\N	\N	\N	en	\N	\N	completed	\N	\N	0	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
50b15302-0a4c-433c-b765-15d5079c8fcc	ea5b10ca-f6dc-4922-901e-8beb02496510	da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec	SEED_CUST009	Mr.	Married	Manager	1600000.00	\N	\N	\N	{"sms": true, "calls": false, "email": true, "whatsapp": true}	t	[{"name": "Mrs. Seed User5", "relation": "Spouse"}]	\N	\N	\N	\N	en	\N	\N	completed	\N	\N	0	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
f2541310-2def-4d20-99d5-40e14d567c2f	4a944faf-5b11-4676-b887-f903da323b80	c47a7151-d764-4ad0-85ed-a2dc7c4d5ef3	SEED_CUST010	Mrs.	Single	Consultant	2200000.00	\N	\N	\N	{"sms": false, "calls": true, "email": true, "whatsapp": true}	t	[]	\N	\N	\N	\N	en	\N	\N	completed	\N	\N	0	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
\.


--
-- Data for Name: premium_payments; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.premium_payments (payment_id, policy_id, policyholder_id, amount, currency, payment_date, due_date, grace_period_days, payment_method, payment_gateway, gateway_transaction_id, gateway_response, status, failure_reason, retry_count, reconciled, reconciled_at, reconciled_by, ip_address, user_agent, device_info, created_at, updated_at) FROM stdin;
ab7fe6b9-e9e3-4f6d-9e36-92bfaa23ebd6	f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	15000.00	INR	2025-11-22 00:00:00	2025-11-23 00:00:00	30	online	\N	\N	\N	completed	\N	0	f	\N	\N	\N	\N	\N	2025-11-23 22:34:55.73505	2025-11-23 22:34:55.73505
1e90619a-cc4f-44f7-a83a-6bc78d6653cc	f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	8500.00	INR	2025-11-21 00:00:00	2025-11-23 00:00:00	30	bank_transfer	\N	\N	\N	completed	\N	0	f	\N	\N	\N	\N	\N	2025-11-23 22:34:55.73505	2025-11-23 22:34:55.73505
d0cee796-dedd-40ed-aa35-bf0b4fc06156	f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	25000.00	INR	2025-11-23 00:00:00	2025-12-23 00:00:00	30	online	\N	\N	\N	pending	\N	0	f	\N	\N	\N	\N	\N	2025-11-23 22:34:55.73505	2025-11-23 22:34:55.73505
7e4273e1-8ace-4f08-ade4-ccb6fee29925	99b51442-a86b-424f-adc3-24fc81ecfd1e	cbf320e4-c5f6-43a2-9d1d-648b23c5c176	25000.00	INR	2025-11-03 23:19:48.514481	2025-11-03 23:19:48.514481	30	upi	razorpay	\N	\N	completed	\N	0	f	\N	\N	\N	\N	\N	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
7b14c3f7-9e30-4ec2-bea4-2b71fd4e0c94	97233aff-7079-431c-9ea0-7f283f47224e	d3c63e20-1c1a-47f8-9999-c65dfd88859a	30000.00	INR	2025-11-08 23:19:48.514481	2025-11-08 23:19:48.514481	30	credit_card	phonepe	\N	\N	completed	\N	0	f	\N	\N	\N	\N	\N	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
bb010584-6f41-42a6-9ad0-0f67c6629d54	631e4685-f1c9-48a0-adca-509727d72508	c5dbfbb5-8797-415c-9919-6f4992b51cc1	35000.00	INR	2025-11-13 23:19:48.514481	2025-11-13 23:19:48.514481	30	debit_card	razorpay	\N	\N	completed	\N	0	f	\N	\N	\N	\N	\N	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
8575c114-f530-455b-91e0-15a275195d6b	bf42e11a-3a94-457e-a77b-aede73f42967	2b99fc80-2a41-4e25-a130-67ff675990a9	20000.00	INR	2025-11-18 23:19:48.514481	2025-11-18 23:19:48.514481	30	net_banking	phonepe	\N	\N	completed	\N	0	f	\N	\N	\N	\N	\N	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
cf5ddab6-b85f-47a7-bce0-d76ca1cc33c4	4642386e-22d0-49bc-a415-23e7704eb53f	a93d7375-c27d-4da7-bfea-51d7e354827a	15000.00	INR	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481	30	upi	razorpay	\N	\N	pending	\N	0	f	\N	\N	\N	\N	\N	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
721c4b07-f8f4-4cd5-be73-fa8804e0c2d7	33f33eeb-9bfc-4172-90f1-cdf4d72260d7	89d41274-d39f-4733-a13c-db44381ddda7	28000.00	INR	2025-10-29 23:19:48.514481	2025-10-29 23:19:48.514481	30	credit_card	phonepe	\N	\N	completed	\N	0	f	\N	\N	\N	\N	\N	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
766264f3-8a9f-4fe2-869d-b7fbcd3abf93	70a8105e-e5d6-4d75-af24-bcd703a07d6f	6074ed27-e32d-4166-8f38-d753b2597bd4	40000.00	INR	2025-10-24 23:19:48.514481	2025-10-24 23:19:48.514481	30	debit_card	razorpay	\N	\N	completed	\N	0	f	\N	\N	\N	\N	\N	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
cd544a2c-3d07-4dfb-9cc2-1287ffae5b10	3373eb9a-9630-4bd6-93a4-0ee09407463c	09647396-2e53-4146-8cd5-c8bbde0cc4a3	25000.00	INR	2025-10-19 23:19:48.514481	2025-10-19 23:19:48.514481	30	net_banking	phonepe	\N	\N	completed	\N	0	f	\N	\N	\N	\N	\N	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
d13647e6-bc36-4777-aa43-6e4d089dc9e4	4979eff5-4575-4ade-98bf-accb7777e845	50b15302-0a4c-433c-b765-15d5079c8fcc	35000.00	INR	2025-10-14 23:19:48.514481	2025-10-14 23:19:48.514481	30	upi	razorpay	\N	\N	completed	\N	0	f	\N	\N	\N	\N	\N	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
cff481b1-e31a-450c-b11d-5732ccb338b4	1f8305fe-7cc4-42e6-8b90-5e504ae019a9	f2541310-2def-4d20-99d5-40e14d567c2f	45000.00	INR	2025-10-09 23:19:48.514481	2025-10-09 23:19:48.514481	30	credit_card	phonepe	\N	\N	completed	\N	0	f	\N	\N	\N	\N	\N	2025-11-23 23:19:48.514481	2025-11-23 23:19:48.514481
\.


--
-- Data for Name: presentation_analytics; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.presentation_analytics (analytics_id, presentation_id, slide_id, agent_id, event_type, event_category, viewer_id, viewer_type, event_data, cta_action, share_method, device_info, ip_address, user_agent, location_info, event_timestamp) FROM stdin;
3d10fbda-c5e2-478f-b716-6878fd7f9f96	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	share	engagement	\N	customer	{"duration": 25, "slide_number": 6, "interaction_type": "click"}	contact_agent	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.96	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-10-29 10:29:01.512119
4c7d78c3-2eff-452f-9b4c-1c2c5342e8a5	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	interest	navigation	5fbb7605-85a8-40b1-9e6e-ec405d8af18c	prospect	{"duration": 31, "slide_number": 3, "interaction_type": "click"}	contact_agent	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.122	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-04 10:29:01.512119
f60c1ac6-ecb6-464f-be77-718ebd1e1672	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	completion	conversion	\N	prospect	{"duration": 13, "slide_number": 5, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.189	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-08 10:29:01.512119
f9f4e23a-9095-4bca-833e-0588326eb51b	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	share	conversion	\N	prospect	{"duration": 29, "slide_number": 4, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.53	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-12 10:29:01.512119
c11b7d2d-10bb-43a4-9fd1-a90c16050932	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	interest	conversion	\N	customer	{"duration": 30, "slide_number": 3, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.54	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-17 10:29:01.512119
785f8d86-3925-4a1b-9e0d-eaab3f82c1f8	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	slide_change	navigation	\N	prospect	{"duration": 24, "slide_number": 2, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.59	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-09 10:29:01.512119
f2c92469-2f4b-4026-8420-13f448c403f6	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	slide_change	engagement	\N	prospect	{"duration": 13, "slide_number": 1, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.236	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-18 10:29:01.512119
bf3761ad-4a5d-4332-9346-1a52c66d504f	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	cta_click	conversion	ddeee6e1-757f-4220-ad26-649bd9fd2987	prospect	{"duration": 26, "slide_number": 5, "interaction_type": "click"}	\N	email	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.7	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-01 10:29:01.512119
79bd7a51-b6bf-4ef1-bec2-a3fbcc428749	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	slide_change	conversion	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	prospect	{"duration": 25, "slide_number": 3, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.75	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-15 10:29:01.512119
8a70a670-f0e2-4003-a074-b894321d57ae	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	cta_click	conversion	\N	prospect	{"duration": 28, "slide_number": 1, "interaction_type": "click"}	\N	email	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.187	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-04 10:29:01.512119
577d15e3-f807-48d6-ba07-82aabc09ecb3	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	interest	navigation	\N	prospect	{"duration": 33, "slide_number": 2, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.20	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-10 10:29:01.512119
e086599c-c3b5-4c3d-a5ce-cc21167f7f5d	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	completion	navigation	\N	prospect	{"duration": 12, "slide_number": 2, "interaction_type": "click"}	\N	email	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.44	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-05 10:29:01.512119
031a8d26-7b77-4c5f-9a1c-c0dbb0e0b56a	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	view	engagement	ea5b10ca-f6dc-4922-901e-8beb02496510	prospect	{"duration": 28, "slide_number": 4, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.58	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-17 10:29:01.512119
5afda3f8-bc5d-454b-a737-83605c77fa06	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	interest	conversion	\N	customer	{"duration": 33, "slide_number": 6, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.245	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-04 10:29:01.512119
be3f4643-2513-4c7e-b799-15bf3ea079ff	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	completion	navigation	\N	customer	{"duration": 31, "slide_number": 2, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.4	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-03 10:29:01.512119
8c030d81-2973-4b88-ad48-3a33a1716ade	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	cta_click	navigation	\N	customer	{"duration": 34, "slide_number": 4, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.211	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-14 10:29:01.512119
7c4b3281-a7fd-4dfb-b62d-0b5cb6518e9c	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	completion	engagement	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	prospect	{"duration": 33, "slide_number": 4, "interaction_type": "click"}	contact_agent	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.135	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-19 10:29:01.512119
7cbde6c0-32b2-4a8b-ac30-99ca5a8686b7	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	interest	engagement	\N	customer	{"duration": 17, "slide_number": 3, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.78	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-18 10:29:01.512119
a2463873-792c-457f-aa5d-17b10bd2c34b	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	interest	navigation	\N	customer	{"duration": 20, "slide_number": 5, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.244	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-19 10:29:01.512119
b5504ca6-2b48-4909-8913-baa331462cd5	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	cta_click	navigation	\N	customer	{"duration": 8, "slide_number": 6, "interaction_type": "click"}	contact_agent	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.101	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-10-31 10:29:01.512119
fb17ca8e-ddd0-4af8-899b-1d5dcdb4b069	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	completion	conversion	\N	prospect	{"duration": 17, "slide_number": 5, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.35	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-18 10:29:01.512119
b2e3f517-393a-4e81-ba91-5353b3783b63	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	slide_change	navigation	\N	prospect	{"duration": 25, "slide_number": 3, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.59	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-12 10:29:01.512119
a15557fa-8eef-45f4-af07-4afc738286e7	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	completion	conversion	\N	customer	{"duration": 21, "slide_number": 6, "interaction_type": "click"}	\N	link	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.43	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-19 10:29:01.512119
c5653c44-6e89-4c31-88f9-17d61026049e	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	completion	navigation	\N	prospect	{"duration": 35, "slide_number": 5, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.37	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-12 10:29:01.512119
1e7f7e83-af6b-432c-89e9-8eefeb3551e2	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	share	navigation	ea2b3915-033a-4ee6-b798-673ce79beab8	prospect	{"duration": 16, "slide_number": 5, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.205	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-07 10:29:01.512119
2b86368b-d8ff-4543-8e9a-6b2f8dbfcb72	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	interest	navigation	\N	prospect	{"duration": 26, "slide_number": 6, "interaction_type": "click"}	contact_agent	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.88	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-09 10:29:01.512119
f67821fe-e05b-493e-bd74-05bf82cc7299	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	slide_change	engagement	0f2661d8-afb2-4f27-ad77-e0bfda097352	prospect	{"duration": 22, "slide_number": 6, "interaction_type": "click"}	contact_agent	whatsapp	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.186	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-10-27 10:29:01.512119
688f41df-670f-4072-9b29-fc1794ff46f5	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	view	navigation	\N	customer	{"duration": 32, "slide_number": 2, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.125	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-21 10:29:01.512119
40fe4694-2a5d-4ad0-bad1-00bdbe0f1a0e	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	slide_change	engagement	2da28562-c8be-4dd6-b0ee-5b1863ea66c4	customer	{"duration": 25, "slide_number": 3, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.224	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-10 10:29:01.512119
c7560df4-bc1c-4475-b41e-c7b743f593c5	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	share	navigation	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	prospect	{"duration": 27, "slide_number": 5, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.76	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-15 10:29:01.512119
bb322477-3c31-486c-b5cc-b23496f38623	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	share	conversion	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	prospect	{"duration": 14, "slide_number": 5, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.106	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-23 10:29:01.512119
43cfe0fb-a635-422c-810e-a6d1768f32f7	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	completion	engagement	\N	prospect	{"duration": 12, "slide_number": 3, "interaction_type": "click"}	\N	link	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.136	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-10-28 10:29:01.512119
c8fdbcf7-c399-4b0c-89aa-abe689817c08	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	completion	navigation	\N	customer	{"duration": 33, "slide_number": 1, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.21	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-08 10:29:01.512119
ecc9617c-0a64-4cc4-baaa-50784f8b75d0	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	completion	navigation	0f2661d8-afb2-4f27-ad77-e0bfda097352	prospect	{"duration": 32, "slide_number": 4, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.248	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-23 10:29:01.512119
754caf36-482f-417f-a25f-cb493f9cedc2	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	slide_change	conversion	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22	prospect	{"duration": 12, "slide_number": 6, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.83	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-10-27 10:29:01.512119
b142252d-2125-4285-be0d-499fb2108359	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	slide_change	conversion	\N	prospect	{"duration": 5, "slide_number": 4, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.50	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-22 10:29:01.512119
21428860-017a-4861-b8d6-87e4c84995c7	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	interest	navigation	0f2661d8-afb2-4f27-ad77-e0bfda097352	customer	{"duration": 14, "slide_number": 4, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.160	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-10-25 10:29:01.512119
c62dd8a6-97fc-44fe-93f5-817f5b437870	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	slide_change	conversion	\N	prospect	{"duration": 21, "slide_number": 5, "interaction_type": "click"}	\N	whatsapp	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.132	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-01 10:29:01.512119
c58b54b8-5ac1-493c-8a5b-12a7b874ee17	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	completion	conversion	\N	prospect	{"duration": 22, "slide_number": 4, "interaction_type": "click"}	contact_agent	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.1	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-21 10:29:01.512119
987fcd5b-d73b-44ab-bf56-1e89ff3c3040	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	\N	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	completion	navigation	\N	prospect	{"duration": 10, "slide_number": 2, "interaction_type": "click"}	\N	\N	{"os": "android", "browser": "Chrome", "device_type": "mobile"}	192.168.1.202	Mozilla/5.0 (Android) AgentMitra/1.0.0	\N	2025-11-19 10:29:01.512119
\.


--
-- Data for Name: presentation_media; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.presentation_media (media_id, agent_id, media_type, mime_type, file_name, file_size_bytes, storage_provider, storage_key, media_url, thumbnail_url, width, height, duration_seconds, file_hash, usage_count, last_used_at, status, is_optimized, uploaded_at, created_at, updated_at) FROM stdin;
68ec223b-33ca-49e2-b5f9-cf829ab4bb23	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	image	image/jpeg	media_b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11_1.jpg	3575531	s3	presentations/b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11/media_1	https://cdn.agentmitra.com/presentations/b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11/media_1	\N	1920	1080	\N	hash_b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11_1_1763960341.512119	7	\N	archived	f	2025-11-22 10:29:01.512119	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
36c8b253-5b9d-47e4-9b8e-93e8d8b2053e	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	video	video/mp4	media_b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11_2.mp4	27160858	s3	presentations/b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11/media_2	https://cdn.agentmitra.com/presentations/b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11/media_2	https://cdn.agentmitra.com/thumbnails/b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11/thumb_2.jpg	\N	\N	95	hash_b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11_2_1763960341.512119	0	\N	active	f	2025-10-27 10:29:01.512119	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
7460b255-6c36-4865-a121-65d61881660f	1a4c8c40-d885-4c6d-b39a-8a42e3b4652d	image	image/jpeg	media_1a4c8c40-d885-4c6d-b39a-8a42e3b4652d_1.jpg	2637737	s3	presentations/1a4c8c40-d885-4c6d-b39a-8a42e3b4652d/media_1	https://cdn.agentmitra.com/presentations/1a4c8c40-d885-4c6d-b39a-8a42e3b4652d/media_1	\N	1920	1080	\N	hash_1a4c8c40-d885-4c6d-b39a-8a42e3b4652d_1_1763960341.512119	6	\N	archived	f	2025-11-09 10:29:01.512119	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
af9429f9-dad4-46db-8aca-6dfb5db8664f	1a4c8c40-d885-4c6d-b39a-8a42e3b4652d	video	video/mp4	media_1a4c8c40-d885-4c6d-b39a-8a42e3b4652d_2.mp4	13805247	s3	presentations/1a4c8c40-d885-4c6d-b39a-8a42e3b4652d/media_2	https://cdn.agentmitra.com/presentations/1a4c8c40-d885-4c6d-b39a-8a42e3b4652d/media_2	https://cdn.agentmitra.com/thumbnails/1a4c8c40-d885-4c6d-b39a-8a42e3b4652d/thumb_2.jpg	\N	\N	239	hash_1a4c8c40-d885-4c6d-b39a-8a42e3b4652d_2_1763960341.512119	7	\N	processing	f	2025-11-21 10:29:01.512119	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
ccd20081-0c8f-4246-856a-07f7e2f39c99	f580839c-4af3-4ebb-9935-bdb8c7acf7b6	image	image/jpeg	media_f580839c-4af3-4ebb-9935-bdb8c7acf7b6_1.jpg	2401838	s3	presentations/f580839c-4af3-4ebb-9935-bdb8c7acf7b6/media_1	https://cdn.agentmitra.com/presentations/f580839c-4af3-4ebb-9935-bdb8c7acf7b6/media_1	\N	1920	1080	\N	hash_f580839c-4af3-4ebb-9935-bdb8c7acf7b6_1_1763960341.512119	3	\N	archived	f	2025-11-07 10:29:01.512119	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
4d4867e4-4c75-4e65-aaa9-41121bd26b5d	f580839c-4af3-4ebb-9935-bdb8c7acf7b6	video	video/mp4	media_f580839c-4af3-4ebb-9935-bdb8c7acf7b6_2.mp4	12823069	s3	presentations/f580839c-4af3-4ebb-9935-bdb8c7acf7b6/media_2	https://cdn.agentmitra.com/presentations/f580839c-4af3-4ebb-9935-bdb8c7acf7b6/media_2	https://cdn.agentmitra.com/thumbnails/f580839c-4af3-4ebb-9935-bdb8c7acf7b6/thumb_2.jpg	\N	\N	137	hash_f580839c-4af3-4ebb-9935-bdb8c7acf7b6_2_1763960341.512119	4	\N	archived	f	2025-11-19 10:29:01.512119	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
d4592c6a-7d10-4d51-af88-251947c96f43	991e6172-dcd1-4ca7-9c82-85cbbd14f6b3	image	image/jpeg	media_991e6172-dcd1-4ca7-9c82-85cbbd14f6b3_1.jpg	3964006	s3	presentations/991e6172-dcd1-4ca7-9c82-85cbbd14f6b3/media_1	https://cdn.agentmitra.com/presentations/991e6172-dcd1-4ca7-9c82-85cbbd14f6b3/media_1	\N	1920	1080	\N	hash_991e6172-dcd1-4ca7-9c82-85cbbd14f6b3_1_1763960341.512119	9	\N	active	f	2025-10-28 10:29:01.512119	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
82233cd5-6416-40fe-a0d9-c704f40bbdf8	991e6172-dcd1-4ca7-9c82-85cbbd14f6b3	video	video/mp4	media_991e6172-dcd1-4ca7-9c82-85cbbd14f6b3_2.mp4	28012900	s3	presentations/991e6172-dcd1-4ca7-9c82-85cbbd14f6b3/media_2	https://cdn.agentmitra.com/presentations/991e6172-dcd1-4ca7-9c82-85cbbd14f6b3/media_2	https://cdn.agentmitra.com/thumbnails/991e6172-dcd1-4ca7-9c82-85cbbd14f6b3/thumb_2.jpg	\N	\N	140	hash_991e6172-dcd1-4ca7-9c82-85cbbd14f6b3_2_1763960341.512119	3	\N	active	f	2025-10-29 10:29:01.512119	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
9d78d8f8-d3eb-42b8-ad1a-c931f549143b	e2038ed1-cedc-4be8-9055-ef3a66bb1907	image	image/jpeg	media_e2038ed1-cedc-4be8-9055-ef3a66bb1907_1.jpg	3172815	s3	presentations/e2038ed1-cedc-4be8-9055-ef3a66bb1907/media_1	https://cdn.agentmitra.com/presentations/e2038ed1-cedc-4be8-9055-ef3a66bb1907/media_1	\N	1920	1080	\N	hash_e2038ed1-cedc-4be8-9055-ef3a66bb1907_1_1763960341.512119	6	\N	active	f	2025-11-12 10:29:01.512119	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
9a06a25a-5065-42d6-b4e1-918afc083633	e2038ed1-cedc-4be8-9055-ef3a66bb1907	video	video/mp4	media_e2038ed1-cedc-4be8-9055-ef3a66bb1907_2.mp4	13535575	s3	presentations/e2038ed1-cedc-4be8-9055-ef3a66bb1907/media_2	https://cdn.agentmitra.com/presentations/e2038ed1-cedc-4be8-9055-ef3a66bb1907/media_2	https://cdn.agentmitra.com/thumbnails/e2038ed1-cedc-4be8-9055-ef3a66bb1907/thumb_2.jpg	\N	\N	265	hash_e2038ed1-cedc-4be8-9055-ef3a66bb1907_2_1763960341.512119	2	\N	archived	f	2025-11-16 10:29:01.512119	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
02e9075a-180b-43b2-8ada-3fd388baa3fb	ff5e562b-9a46-4a04-81d1-ce54e425acbd	image	image/jpeg	media_ff5e562b-9a46-4a04-81d1-ce54e425acbd_1.jpg	3366269	s3	presentations/ff5e562b-9a46-4a04-81d1-ce54e425acbd/media_1	https://cdn.agentmitra.com/presentations/ff5e562b-9a46-4a04-81d1-ce54e425acbd/media_1	\N	1920	1080	\N	hash_ff5e562b-9a46-4a04-81d1-ce54e425acbd_1_1763960341.512119	2	\N	active	f	2025-10-30 10:29:01.512119	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
16ca5c6f-778b-4d2a-ae1a-46e75853ac1a	ff5e562b-9a46-4a04-81d1-ce54e425acbd	video	video/mp4	media_ff5e562b-9a46-4a04-81d1-ce54e425acbd_2.mp4	28835826	s3	presentations/ff5e562b-9a46-4a04-81d1-ce54e425acbd/media_2	https://cdn.agentmitra.com/presentations/ff5e562b-9a46-4a04-81d1-ce54e425acbd/media_2	https://cdn.agentmitra.com/thumbnails/ff5e562b-9a46-4a04-81d1-ce54e425acbd/thumb_2.jpg	\N	\N	216	hash_ff5e562b-9a46-4a04-81d1-ce54e425acbd_2_1763960341.512119	9	\N	processing	f	2025-11-04 10:29:01.512119	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
2d53cd69-63f4-4c1b-a314-8cbd1850a28c	bd40bf61-c2ad-4071-b868-ad54ab7cfa8d	image	image/jpeg	media_bd40bf61-c2ad-4071-b868-ad54ab7cfa8d_1.jpg	2848394	s3	presentations/bd40bf61-c2ad-4071-b868-ad54ab7cfa8d/media_1	https://cdn.agentmitra.com/presentations/bd40bf61-c2ad-4071-b868-ad54ab7cfa8d/media_1	\N	1920	1080	\N	hash_bd40bf61-c2ad-4071-b868-ad54ab7cfa8d_1_1763960341.512119	7	\N	archived	f	2025-11-08 10:29:01.512119	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
a8507201-5fb4-414e-b57a-26fe3d490bf8	bd40bf61-c2ad-4071-b868-ad54ab7cfa8d	video	video/mp4	media_bd40bf61-c2ad-4071-b868-ad54ab7cfa8d_2.mp4	18859852	s3	presentations/bd40bf61-c2ad-4071-b868-ad54ab7cfa8d/media_2	https://cdn.agentmitra.com/presentations/bd40bf61-c2ad-4071-b868-ad54ab7cfa8d/media_2	https://cdn.agentmitra.com/thumbnails/bd40bf61-c2ad-4071-b868-ad54ab7cfa8d/thumb_2.jpg	\N	\N	151	hash_bd40bf61-c2ad-4071-b868-ad54ab7cfa8d_2_1763960341.512119	5	\N	active	f	2025-10-31 10:29:01.512119	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
e8c83e1c-1bf9-4837-9d02-65d76854da7c	e45c1148-56b7-4605-b183-68ea7aec4383	image	image/jpeg	media_e45c1148-56b7-4605-b183-68ea7aec4383_1.jpg	3377604	s3	presentations/e45c1148-56b7-4605-b183-68ea7aec4383/media_1	https://cdn.agentmitra.com/presentations/e45c1148-56b7-4605-b183-68ea7aec4383/media_1	\N	1920	1080	\N	hash_e45c1148-56b7-4605-b183-68ea7aec4383_1_1763960341.512119	7	\N	active	f	2025-11-08 10:29:01.512119	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
36e33675-3446-4832-9e76-bd7715d25cb4	e45c1148-56b7-4605-b183-68ea7aec4383	video	video/mp4	media_e45c1148-56b7-4605-b183-68ea7aec4383_2.mp4	13096242	s3	presentations/e45c1148-56b7-4605-b183-68ea7aec4383/media_2	https://cdn.agentmitra.com/presentations/e45c1148-56b7-4605-b183-68ea7aec4383/media_2	https://cdn.agentmitra.com/thumbnails/e45c1148-56b7-4605-b183-68ea7aec4383/thumb_2.jpg	\N	\N	307	hash_e45c1148-56b7-4605-b183-68ea7aec4383_2_1763960341.512119	8	\N	active	f	2025-10-31 10:29:01.512119	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
8891e304-c798-46bb-a1d3-f0e801e40711	91ad72ed-42d2-46ad-8338-4d22d8f7c80f	image	image/jpeg	media_91ad72ed-42d2-46ad-8338-4d22d8f7c80f_1.jpg	3705521	s3	presentations/91ad72ed-42d2-46ad-8338-4d22d8f7c80f/media_1	https://cdn.agentmitra.com/presentations/91ad72ed-42d2-46ad-8338-4d22d8f7c80f/media_1	\N	1920	1080	\N	hash_91ad72ed-42d2-46ad-8338-4d22d8f7c80f_1_1763960341.512119	7	\N	archived	f	2025-10-28 10:29:01.512119	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
c65391e2-d116-42e2-9733-876d9630c187	91ad72ed-42d2-46ad-8338-4d22d8f7c80f	video	video/mp4	media_91ad72ed-42d2-46ad-8338-4d22d8f7c80f_2.mp4	23529517	s3	presentations/91ad72ed-42d2-46ad-8338-4d22d8f7c80f/media_2	https://cdn.agentmitra.com/presentations/91ad72ed-42d2-46ad-8338-4d22d8f7c80f/media_2	https://cdn.agentmitra.com/thumbnails/91ad72ed-42d2-46ad-8338-4d22d8f7c80f/thumb_2.jpg	\N	\N	318	hash_91ad72ed-42d2-46ad-8338-4d22d8f7c80f_2_1763960341.512119	8	\N	archived	f	2025-10-28 10:29:01.512119	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
fe737aae-a5fc-4232-bbf2-f32b390eea4d	da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec	image	image/jpeg	media_da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec_1.jpg	3061505	s3	presentations/da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec/media_1	https://cdn.agentmitra.com/presentations/da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec/media_1	\N	1920	1080	\N	hash_da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec_1_1763960341.512119	5	\N	archived	f	2025-10-28 10:29:01.512119	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
06484f58-f0f0-472c-8296-721b9a686e7b	da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec	video	video/mp4	media_da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec_2.mp4	22059080	s3	presentations/da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec/media_2	https://cdn.agentmitra.com/presentations/da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec/media_2	https://cdn.agentmitra.com/thumbnails/da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec/thumb_2.jpg	\N	\N	82	hash_da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec_2_1763960341.512119	9	\N	archived	f	2025-11-17 10:29:01.512119	2025-11-24 10:29:01.512119	2025-11-24 10:29:01.512119
\.


--
-- Data for Name: presentation_slides; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.presentation_slides (slide_id, presentation_id, slide_order, slide_type, media_url, media_type, thumbnail_url, media_storage_key, title, subtitle, description, text_color, background_color, overlay_opacity, layout, duration, transition_effect, cta_button, agent_branding, created_at, updated_at) FROM stdin;
e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1	image	https://via.placeholder.com/800x600/FF0000/FFFFFF?text=Slide+1	\N	\N	\N	Welcome	To Agent Mitra	\N	#FFFFFF	#000000	0.50	centered	5	fade	\N	\N	2025-11-23 22:34:55.683807	2025-11-23 22:34:55.683807
e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2	text	\N	\N	\N	\N	Our Services	Insurance Solutions for Everyone	\N	#000000	#FFFFFF	0.50	centered	4	fade	{"text": "Learn More", "action": "/services"}	\N	2025-11-23 22:34:55.683807	2025-11-23 22:34:55.683807
e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	3	image	https://via.placeholder.com/800x600/0000FF/FFFFFF?text=Slide+3	\N	\N	\N	Contact Us	Get in touch today	\N	#FFFFFF	#0000FF	0.50	bottom	5	fade	\N	\N	2025-11-23 22:34:55.683807	2025-11-23 22:34:55.683807
a5c82963-b8ba-4052-b592-2c510048647f	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	4	text	\N	\N	\N	\N	Investment Benefits	Why Choose LIC Investments	\N	#FFFFFF	#1a365d	0.50	centered	5	fade	{"text": "Learn More", "action": "contact_agent", "textColor": "#FFFFFF", "backgroundColor": "#3182ce"}	\N	2025-11-20 10:41:38.515958	2025-11-20 10:41:38.515958
dc4336e0-2de2-4672-8c1e-51ce2f2a2195	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	5	video	\N	\N	\N	\N	Risk Coverage	Complete Protection Plans	\N	#FFFFFF	#2d3748	0.50	centered	5	fade	{"text": "Learn More", "action": "contact_agent", "textColor": "#FFFFFF", "backgroundColor": "#3182ce"}	\N	2025-11-19 10:41:38.515958	2025-11-19 10:41:38.515958
79872d6d-51bb-4e0a-a4be-7219829f1510	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	6	image	\N	\N	\N	\N	Claim Process	Easy Claim Settlement	\N	#FFFFFF	#1a365d	0.50	centered	5	fade	{"text": "Learn More", "action": "contact_agent", "textColor": "#FFFFFF", "backgroundColor": "#3182ce"}	\N	2025-11-18 10:41:38.515958	2025-11-18 10:41:38.515958
6fe2f90e-31f1-4aeb-b624-97a8f7dbf5bc	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	7	text	\N	\N	\N	\N	Contact Information	Get Your Quote Today	\N	#FFFFFF	#2d3748	0.50	centered	5	fade	{"text": "Learn More", "action": "contact_agent", "textColor": "#FFFFFF", "backgroundColor": "#3182ce"}	\N	2025-11-17 10:41:38.515958	2025-11-17 10:41:38.515958
5a79bd3f-9347-4815-80ff-3be53d2f5fb4	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	4	text	\N	\N	\N	\N	Investment Benefits	Why Choose LIC Investments	\N	#FFFFFF	#1a365d	0.50	centered	5	fade	{"text": "Learn More", "action": "contact_agent", "textColor": "#FFFFFF", "backgroundColor": "#3182ce"}	\N	2025-11-20 10:41:38.515958	2025-11-20 10:41:38.515958
0b6a311b-b14b-4af3-af5f-e742d1ff0a71	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	5	video	\N	\N	\N	\N	Risk Coverage	Complete Protection Plans	\N	#FFFFFF	#2d3748	0.50	centered	5	fade	{"text": "Learn More", "action": "contact_agent", "textColor": "#FFFFFF", "backgroundColor": "#3182ce"}	\N	2025-11-19 10:41:38.515958	2025-11-19 10:41:38.515958
6bbad4e9-42bc-49ed-86f9-0061609a5497	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	6	image	\N	\N	\N	\N	Claim Process	Easy Claim Settlement	\N	#FFFFFF	#1a365d	0.50	centered	5	fade	{"text": "Learn More", "action": "contact_agent", "textColor": "#FFFFFF", "backgroundColor": "#3182ce"}	\N	2025-11-18 10:41:38.515958	2025-11-18 10:41:38.515958
2d04fdaf-1885-46bb-a6dc-36c1c4f33392	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	7	text	\N	\N	\N	\N	Contact Information	Get Your Quote Today	\N	#FFFFFF	#2d3748	0.50	centered	5	fade	{"text": "Learn More", "action": "contact_agent", "textColor": "#FFFFFF", "backgroundColor": "#3182ce"}	\N	2025-11-17 10:41:38.515958	2025-11-17 10:41:38.515958
\.


--
-- Data for Name: presentation_templates; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.presentation_templates (template_id, name, description, category, slides, is_default, is_public, is_system_template, usage_count, average_rating, total_ratings, preview_image_url, preview_video_url, status, available_from, available_until, created_by, created_at, updated_at) FROM stdin;
c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Promotional Template	Template for promotional content	term_insurance	[{"type": "image", "layout": "centered"}]	f	t	f	0	\N	0	\N	\N	active	\N	\N	\N	2025-11-23 22:34:55.683807	2025-11-23 22:34:55.683807
c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	Educational Template	Template for educational content	health_insurance	[{"type": "text", "layout": "top"}]	f	t	f	0	\N	0	\N	\N	active	\N	\N	\N	2025-11-23 22:34:55.683807	2025-11-23 22:34:55.683807
\.


--
-- Data for Name: presentations; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.presentations (presentation_id, agent_id, name, description, status, is_active, template_id, template_category, version, parent_presentation_id, created_at, updated_at, published_at, archived_at, tags, target_audience, language, total_views, total_shares, total_cta_clicks, created_by, published_by) FROM stdin;
d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Daily Promotional	Daily promotional presentation	published	t	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	1	\N	2025-11-23 22:34:55.683807	2025-11-23 22:34:55.683807	\N	\N	{promotional,daily}	\N	en	1	2	4	\N	\N
d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Weekly Update	Weekly update presentation	draft	f	\N	\N	1	\N	2025-11-23 22:34:55.683807	2025-11-23 22:34:55.683807	\N	\N	{update}	\N	en	1	3	0	\N	\N
\.


--
-- Data for Name: revenue_forecasts; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.revenue_forecasts (forecast_id, agent_id, forecast_period, forecast_date, target_date, predicted_revenue, predicted_commission, confidence_level, actual_revenue, actual_commission, forecast_accuracy, forecast_method, created_by, created_at) FROM stdin;
73eef42d-6795-4cbb-8ed6-7cf6c0990d25	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	monthly	2025-11-24	2025-12-24	86754.83	5424.76	0.75	\N	\N	\N	machine_learning	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-24 10:33:20.011083
116ebebe-d252-46fc-b4fd-6cd24bb2b009	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	quarterly	2025-11-24	2026-02-24	345115.63	21569.25	0.78	\N	\N	\N	machine_learning	ea2b3915-033a-4ee6-b798-673ce79beab8	2025-11-24 10:33:20.011083
7954bcae-c071-487f-a770-a8ab5efdbadd	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	yearly	2025-11-24	2026-11-24	1499667.43	173142.34	0.85	\N	\N	\N	machine_learning	045a6ed3-c48b-4d1c-ac86-8776bda0050f	2025-11-24 10:33:20.011083
33f272ba-191e-4d10-9165-bb17eda0bf64	1a4c8c40-d885-4c6d-b39a-8a42e3b4652d	monthly	2025-11-24	2025-12-24	138961.96	14257.79	0.86	\N	\N	\N	time_series	ea2b3915-033a-4ee6-b798-673ce79beab8	2025-11-24 10:33:20.011083
9de5314b-151b-4d40-bafb-60720231f73d	1a4c8c40-d885-4c6d-b39a-8a42e3b4652d	quarterly	2025-11-24	2026-02-24	186761.02	16993.58	0.70	\N	\N	\N	machine_learning	0f2661d8-afb2-4f27-ad77-e0bfda097352	2025-11-24 10:33:20.011083
12eb8310-e425-45de-b20f-1fc35c6f2c85	1a4c8c40-d885-4c6d-b39a-8a42e3b4652d	yearly	2025-11-24	2026-11-24	1514007.98	84425.87	0.83	\N	\N	\N	linear_regression	ddeee6e1-757f-4220-ad26-649bd9fd2987	2025-11-24 10:33:20.011083
c7b85e81-a43e-4605-9210-a762e4dfcc6c	f580839c-4af3-4ebb-9935-bdb8c7acf7b6	monthly	2025-11-24	2025-12-24	74543.85	7380.69	0.79	\N	\N	\N	time_series	2da28562-c8be-4dd6-b0ee-5b1863ea66c4	2025-11-24 10:33:20.011083
cdef56b8-8bf7-4048-88fe-15ed7b37442c	f580839c-4af3-4ebb-9935-bdb8c7acf7b6	quarterly	2025-11-24	2026-02-24	199341.50	40962.99	0.94	\N	\N	\N	time_series	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-24 10:33:20.011083
d6423785-ceb2-4684-b6b0-e4cb727067e7	f580839c-4af3-4ebb-9935-bdb8c7acf7b6	yearly	2025-11-24	2026-11-24	949921.29	177304.21	0.89	\N	\N	\N	machine_learning	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22	2025-11-24 10:33:20.011083
b233807f-8e32-4658-96cc-7454cc4947f1	991e6172-dcd1-4ca7-9c82-85cbbd14f6b3	monthly	2025-11-24	2025-12-24	90641.78	5052.72	0.71	\N	\N	\N	machine_learning	ddeee6e1-757f-4220-ad26-649bd9fd2987	2025-11-24 10:33:20.011083
00d30e04-0580-422a-b4e4-bc5fa3a35afc	991e6172-dcd1-4ca7-9c82-85cbbd14f6b3	quarterly	2025-11-24	2026-02-24	323646.37	37238.67	0.71	\N	\N	\N	linear_regression	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-24 10:33:20.011083
4f35c613-b655-446c-a498-620ca1b3b2b0	991e6172-dcd1-4ca7-9c82-85cbbd14f6b3	yearly	2025-11-24	2026-11-24	1417708.79	169474.43	0.80	\N	\N	\N	machine_learning	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22	2025-11-24 10:33:20.011083
e619581c-eb44-4823-b992-ce939d1457fe	e2038ed1-cedc-4be8-9055-ef3a66bb1907	monthly	2025-11-24	2025-12-24	72540.31	14236.03	0.72	\N	\N	\N	machine_learning	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	2025-11-24 10:33:20.011083
de6263eb-363f-452d-a95c-4a1084f057e5	e2038ed1-cedc-4be8-9055-ef3a66bb1907	quarterly	2025-11-24	2026-02-24	282806.47	38943.68	0.90	\N	\N	\N	linear_regression	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	2025-11-24 10:33:20.011083
707573b5-4b51-4826-afd3-bcd1ad510b5b	e2038ed1-cedc-4be8-9055-ef3a66bb1907	yearly	2025-11-24	2026-11-24	772775.20	173181.94	0.83	\N	\N	\N	machine_learning	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	2025-11-24 10:33:20.011083
1a6c8890-4dba-4b08-b3c1-1de478e03a90	ff5e562b-9a46-4a04-81d1-ce54e425acbd	monthly	2025-11-24	2025-12-24	97214.14	13489.42	0.83	\N	\N	\N	time_series	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	2025-11-24 10:33:20.011083
fe1392e8-f97d-4aeb-afc3-94d32342d348	ff5e562b-9a46-4a04-81d1-ce54e425acbd	quarterly	2025-11-24	2026-02-24	197637.10	23233.73	0.76	\N	\N	\N	machine_learning	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-11-24 10:33:20.011083
18356d17-62e8-44a9-a05a-27cb5fdec834	ff5e562b-9a46-4a04-81d1-ce54e425acbd	yearly	2025-11-24	2026-11-24	1278666.89	78268.11	0.81	\N	\N	\N	machine_learning	4a944faf-5b11-4676-b887-f903da323b80	2025-11-24 10:33:20.011083
d67c0522-5e16-4245-8bc2-8ceaa66a84c6	bd40bf61-c2ad-4071-b868-ad54ab7cfa8d	monthly	2025-11-24	2025-12-24	143874.38	9734.42	0.85	\N	\N	\N	machine_learning	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	2025-11-24 10:33:20.011083
7e718938-3c95-4cb8-95cd-aeddecd8df0e	bd40bf61-c2ad-4071-b868-ad54ab7cfa8d	quarterly	2025-11-24	2026-02-24	192022.13	41932.57	0.91	\N	\N	\N	time_series	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-24 10:33:20.011083
72463b5f-ff35-4447-a3b1-e3be5cac3a4a	bd40bf61-c2ad-4071-b868-ad54ab7cfa8d	yearly	2025-11-24	2026-11-24	901307.05	140194.61	0.91	\N	\N	\N	machine_learning	ea2b3915-033a-4ee6-b798-673ce79beab8	2025-11-24 10:33:20.011083
506690e9-8db6-4574-8e92-62fd9c2c93b3	e45c1148-56b7-4605-b183-68ea7aec4383	monthly	2025-11-24	2025-12-24	99427.97	10483.84	0.94	\N	\N	\N	machine_learning	045a6ed3-c48b-4d1c-ac86-8776bda0050f	2025-11-24 10:33:20.011083
c217f986-44c7-40b8-82c2-07ca18459222	e45c1148-56b7-4605-b183-68ea7aec4383	quarterly	2025-11-24	2026-02-24	229790.00	37395.92	0.75	\N	\N	\N	machine_learning	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-11-24 10:33:20.011083
d9ca1e39-063e-4645-87a2-82cac3d6f750	e45c1148-56b7-4605-b183-68ea7aec4383	yearly	2025-11-24	2026-11-24	714597.47	136744.91	0.91	\N	\N	\N	linear_regression	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	2025-11-24 10:33:20.011083
828c5930-8201-4ba2-bd6a-de88813cac78	91ad72ed-42d2-46ad-8338-4d22d8f7c80f	monthly	2025-11-24	2025-12-24	63325.00	10103.62	0.77	\N	\N	\N	machine_learning	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	2025-11-24 10:33:20.011083
721b0258-26d9-439b-ab5a-3623c5d23e99	91ad72ed-42d2-46ad-8338-4d22d8f7c80f	quarterly	2025-11-24	2026-02-24	274906.40	42431.00	0.72	\N	\N	\N	linear_regression	ea5b10ca-f6dc-4922-901e-8beb02496510	2025-11-24 10:33:20.011083
f7efa371-a47c-4261-a06d-c7e3a5cb37ca	91ad72ed-42d2-46ad-8338-4d22d8f7c80f	yearly	2025-11-24	2026-11-24	1592938.81	69435.89	0.79	\N	\N	\N	linear_regression	045a6ed3-c48b-4d1c-ac86-8776bda0050f	2025-11-24 10:33:20.011083
0e822dfc-21eb-4d03-b454-4eaf2332a9f0	da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec	monthly	2025-11-24	2025-12-24	53569.56	5847.80	0.79	\N	\N	\N	machine_learning	045a6ed3-c48b-4d1c-ac86-8776bda0050f	2025-11-24 10:33:20.011083
4922c42c-43c3-45ad-ad92-133c2ed29e53	da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec	quarterly	2025-11-24	2026-02-24	286398.56	38703.21	0.71	\N	\N	\N	time_series	4a944faf-5b11-4676-b887-f903da323b80	2025-11-24 10:33:20.011083
8c3817af-1ea5-4335-aeaa-6557689620be	da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec	yearly	2025-11-24	2026-11-24	936430.84	99927.15	0.75	\N	\N	\N	time_series	ddeee6e1-757f-4220-ad26-649bd9fd2987	2025-11-24 10:33:20.011083
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.role_permissions (assignment_id, role_id, permission_id, granted_at) FROM stdin;
cf4b19df-876d-4c8b-abe8-16b4546f9226	7db127cb-2d62-4f07-8a77-3612b1472f88	1efcd4c6-4666-4e44-9585-a46aead5e13f	2025-10-25 10:28:21.255893
179a372a-f922-410f-8755-9df81504487a	7db127cb-2d62-4f07-8a77-3612b1472f88	71e669cb-3a13-4e15-b01f-36e435d60dfa	2025-10-25 10:28:21.255893
31260b82-080e-4d29-b59e-319fe6ae9ae9	7db127cb-2d62-4f07-8a77-3612b1472f88	73876d58-f8fd-409f-b5dc-b5dc6590fe05	2025-10-25 10:28:21.255893
15d158ef-e248-4a3a-acb9-9d5f9ee6a8ef	7db127cb-2d62-4f07-8a77-3612b1472f88	896e5149-9f07-4b63-9507-b9184f31e528	2025-10-25 10:28:21.255893
5ae9eecd-174a-4073-8e75-31a5423d5280	7db127cb-2d62-4f07-8a77-3612b1472f88	aca24e7f-8a6c-4c45-aae9-5752b7717508	2025-10-25 10:28:21.255893
0c519e12-c507-4ac0-a057-1eeb4b3d7beb	6f1550f5-6cc0-49b0-87e2-4d8e911b26e1	c824ce9c-3988-4d1a-9dd1-549877ac31ca	2025-10-25 10:28:21.255893
c8ecbbd6-3e15-4c28-b03e-b10f4af2cee9	6f1550f5-6cc0-49b0-87e2-4d8e911b26e1	815dba00-fe7a-4d5f-be11-ef58ead81a52	2025-10-25 10:28:21.255893
42a9deb5-ac2a-4005-baa9-c50c5dbd971d	6f1550f5-6cc0-49b0-87e2-4d8e911b26e1	7c0cec13-546e-44ad-ac24-c5ef49998a83	2025-10-25 10:28:21.255893
f3d6d3f2-e61c-42b4-82c6-668d318e0874	6f1550f5-6cc0-49b0-87e2-4d8e911b26e1	3e074f2b-03f5-4bd4-8fd8-93d9a99b0c06	2025-10-25 10:28:21.255893
cb49625d-6779-4dbf-b75c-427273c3670d	1c28a1fa-635f-40fe-87ad-5c737a9dc002	7b3ccee0-2251-48e6-a8e4-fc8d0b8d2248	2025-10-25 10:28:21.255893
3a59e87d-28be-4f89-815e-328b045ca576	1c28a1fa-635f-40fe-87ad-5c737a9dc002	7c0cec13-546e-44ad-ac24-c5ef49998a83	2025-10-25 10:28:21.255893
84b75107-7a17-49e2-bd9f-2015c08c71b9	1c28a1fa-635f-40fe-87ad-5c737a9dc002	c65ffb10-0a67-458c-9573-acac5804a0b9	2025-10-25 10:28:21.255893
2d9e4e4b-eb28-4800-99d7-2e3761d48fa6	1c28a1fa-635f-40fe-87ad-5c737a9dc002	951ae4aa-f460-49c1-9c63-d9e066b7b5e7	2025-10-25 10:28:21.255893
06a5f9b6-5e1e-4d65-9c00-a45fc90207cf	54fc8a7b-569e-434d-897f-770d002e933b	71e669cb-3a13-4e15-b01f-36e435d60dfa	2025-10-25 10:28:21.255893
65d8fa3a-59d5-4961-a9db-bf0a35f4cc2f	54fc8a7b-569e-434d-897f-770d002e933b	c824ce9c-3988-4d1a-9dd1-549877ac31ca	2025-10-25 10:28:21.255893
16b8d36c-8f43-42bb-93c2-56113ed4a1ae	54fc8a7b-569e-434d-897f-770d002e933b	e554300e-ce26-4c6e-936d-26780b0fa117	2025-10-25 10:28:21.255893
19a0c6a9-5ffd-4ff2-8e1f-8e890be17d26	54fc8a7b-569e-434d-897f-770d002e933b	73876d58-f8fd-409f-b5dc-b5dc6590fe05	2025-10-25 10:28:21.255893
f9eb9092-736c-4ba6-ab39-e1baa2dafdb1	54fc8a7b-569e-434d-897f-770d002e933b	4d21c5b8-9399-402e-a468-bae0f4b805fd	2025-10-25 10:28:21.255893
9c6e1da8-1074-4297-b549-82a84652095c	a6ad4340-5e1d-453e-aedd-db4543167f6d	951ae4aa-f460-49c1-9c63-d9e066b7b5e7	2025-10-25 10:28:21.255893
1f393fc6-3f59-4e27-9fc2-a2054c027b33	a6ad4340-5e1d-453e-aedd-db4543167f6d	896e5149-9f07-4b63-9507-b9184f31e528	2025-10-25 10:28:21.255893
1c6ff43c-649b-4100-8ce9-bbc8783b32f2	17fd5370-752f-4597-882c-00e30f15fd7f	db2d8775-4464-466a-afa5-09f57cb25c2b	2025-10-25 10:28:21.255893
45fa0c40-37b6-4b5b-9872-2a4fffc97109	17fd5370-752f-4597-882c-00e30f15fd7f	7c0cec13-546e-44ad-ac24-c5ef49998a83	2025-10-25 10:28:21.255893
968f0c31-1978-4fde-9ed7-d71c052a300d	17fd5370-752f-4597-882c-00e30f15fd7f	1efcd4c6-4666-4e44-9585-a46aead5e13f	2025-10-25 10:28:21.255893
a33149f1-cab8-4b11-b1ec-44581c959718	17fd5370-752f-4597-882c-00e30f15fd7f	7b3ccee0-2251-48e6-a8e4-fc8d0b8d2248	2025-10-25 10:28:21.255893
f36e8d19-27c5-4a0c-8394-3537dc744214	17fd5370-752f-4597-882c-00e30f15fd7f	951ae4aa-f460-49c1-9c63-d9e066b7b5e7	2025-10-25 10:28:21.255893
7679372f-e794-4260-b41c-8ef4de72b9af	c2b9b93c-5aaf-41a2-95e9-a41cba7b404e	951ae4aa-f460-49c1-9c63-d9e066b7b5e7	2025-10-25 10:28:21.255893
d2c0aee0-079d-49dd-b5cc-898446502bb5	c2b9b93c-5aaf-41a2-95e9-a41cba7b404e	7b3ccee0-2251-48e6-a8e4-fc8d0b8d2248	2025-10-25 10:28:21.255893
191ee6cd-afb6-41da-b4b9-06f7fd631eb0	c2b9b93c-5aaf-41a2-95e9-a41cba7b404e	1efcd4c6-4666-4e44-9585-a46aead5e13f	2025-10-25 10:28:21.255893
7a67068a-4a89-453b-8d42-8f40b381c6f2	f50be4d2-6e4b-4822-b637-daf9ce146a79	951ae4aa-f460-49c1-9c63-d9e066b7b5e7	2025-10-25 10:28:21.255893
4e1eac56-f713-43a1-bb66-04b1c71b97b2	f50be4d2-6e4b-4822-b637-daf9ce146a79	db2d8775-4464-466a-afa5-09f57cb25c2b	2025-10-25 10:28:21.255893
3cd3bd86-7db3-4361-a658-a22b3e9e430e	f50be4d2-6e4b-4822-b637-daf9ce146a79	1efcd4c6-4666-4e44-9585-a46aead5e13f	2025-10-25 10:28:21.255893
1b4c2277-7a5c-4711-87b9-20afbbcd893e	f50be4d2-6e4b-4822-b637-daf9ce146a79	c65ffb10-0a67-458c-9573-acac5804a0b9	2025-10-25 10:28:21.255893
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.roles (role_id, role_name, role_description, is_system_role, permissions, created_at) FROM stdin;
7db127cb-2d62-4f07-8a77-3612b1472f88	super_admin	Super Administrator with full system access	t	["*"]	2025-11-23 22:34:55.877872
6f1550f5-6cc0-49b0-87e2-4d8e911b26e1	insurance_provider_admin	Insurance Provider Administrator	t	["users.*", "agents.*", "policies.*", "reports.*"]	2025-11-23 22:34:55.877872
1c28a1fa-635f-40fe-87ad-5c737a9dc002	regional_manager	Regional Manager	t	["agents.read", "agents.update", "policies.read", "reports.read"]	2025-11-23 22:34:55.877872
54fc8a7b-569e-434d-897f-770d002e933b	senior_agent	Senior Insurance Agent	t	["policies.create", "policies.read", "policies.update", "customers.*"]	2025-11-23 22:34:55.877872
a6ad4340-5e1d-453e-aedd-db4543167f6d	junior_agent	Junior Insurance Agent	t	["policies.read", "customers.read"]	2025-11-23 22:34:55.877872
17fd5370-752f-4597-882c-00e30f15fd7f	policyholder	Policyholder/Customer	t	["policies.read", "payments.create", "payments.read"]	2025-11-23 22:34:55.877872
c2b9b93c-5aaf-41a2-95e9-a41cba7b404e	support_staff	Customer Support Staff	t	["customers.read", "policies.read", "tickets.*"]	2025-11-23 22:34:55.877872
f50be4d2-6e4b-4822-b637-daf9ce146a79	guest	Guest User	t	["policies.read"]	2025-11-23 22:34:55.877872
9de7c3a2-6a9e-4bd1-9c12-ffada76175c8	compliance_officer	Ensures regulatory compliance and audits	t	["compliance.read", "compliance.write", "audits.*", "reports.read"]	2025-11-24 10:33:20.011083
64584b83-2d85-44fc-a2c5-0f328e19f886	customer_support_lead	Leads customer support team	t	["support.*", "customers.*", "reports.read", "tickets.manage"]	2025-11-24 10:33:20.011083
\.


--
-- Data for Name: tenant_config; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.tenant_config (config_id, tenant_id, config_key, config_value, config_type, is_encrypted, created_at, updated_at) FROM stdin;
a5af8214-474f-4a77-9d53-98883654f058	bf0b6627-c595-4fd8-93c2-cb0e9cdc86bc	email.smtp.host	"smtp.gmail.com"	string	f	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
8fd37b77-6207-4ec1-8dae-7c8add99fe37	bf0b6627-c595-4fd8-93c2-cb0e9cdc86bc	email.templates.enabled	true	boolean	f	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
54f73226-4824-4fdb-96ab-776910ea2487	bf0b6627-c595-4fd8-93c2-cb0e9cdc86bc	whatsapp.business.number	"+919876543210"	string	f	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
07032f4f-3d39-4a01-9b56-64a262d909db	bf0b6627-c595-4fd8-93c2-cb0e9cdc86bc	payment.gateway.razorpay.key	"rzp_test_46d984d283afd277e920acee3dd37437"	string	t	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
3a4e1cd6-3b8c-4b13-b92e-ce87bbbcd22c	bf0b6627-c595-4fd8-93c2-cb0e9cdc86bc	features.chatbot.enabled	true	boolean	f	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
14fa211a-e601-41b0-8ee6-9fbfb040b95f	bf0b6627-c595-4fd8-93c2-cb0e9cdc86bc	analytics.retention.days	365	integer	f	2025-11-24 10:31:08.716097	2025-11-24 10:31:08.716097
\.


--
-- Data for Name: tenants; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.tenants (tenant_id, tenant_code, tenant_name, tenant_type, schema_name, parent_tenant_id, status, subscription_plan, trial_end_date, max_users, storage_limit_gb, api_rate_limit, created_at, updated_at) FROM stdin;
bf0b6627-c595-4fd8-93c2-cb0e9cdc86bc	LIC	Life Insurance Corporation of India	insurance_provider	lic_schema	\N	active	enterprise	\N	10000	1000	10000	2025-11-21 13:00:53.717908	2025-11-21 13:00:53.717908
\.


--
-- Data for Name: user_payment_methods; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.user_payment_methods (payment_method_id, user_id, method_type, method_name, is_default, card_number_encrypted, card_holder_name, expiry_month, expiry_year, cvv_encrypted, upi_id, bank_account_number_encrypted, bank_ifsc_code, bank_name, status, verification_status, last_used_at, created_at, updated_at) FROM stdin;
6355a8e4-1289-46a4-8e51-36784ba99095	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	upi	Paytm UPI	t	\N	\N	\N	\N	\N	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11@paytm	\N	\N	\N	active	verified	\N	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
6d78bd1a-ebdb-4ecb-b971-f624282c2268	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	net_banking	HDFC Net Banking	f	\N	\N	\N	\N	\N	\N	0cf93a2f4bcf5392c4ec5127a8927801	HDFC0001234	HDFC Bank	active	verified	2025-11-22 10:33:20.011083	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
ca274464-5de9-4e44-a4ed-f05af29b8ef3	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	upi	Paytm UPI	t	\N	\N	\N	\N	\N	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12@paytm	\N	\N	\N	active	verified	2025-10-28 10:33:20.011083	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
c86e80ff-99b4-4c4d-aa51-82ee5e836f40	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	upi	Paytm UPI	t	\N	\N	\N	\N	\N	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13@paytm	\N	\N	\N	active	verified	2025-11-08 10:33:20.011083	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
b8c9f104-c836-4193-acf1-b85a308ecb84	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	net_banking	HDFC Net Banking	f	\N	\N	\N	\N	\N	\N	c0d42c8b334d9a2c51d9dcc85b73e0ba	HDFC0001234	HDFC Bank	active	verified	2025-11-17 10:33:20.011083	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
5cb87e61-fb40-4f51-b0da-f07cd0e883ec	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	upi	Paytm UPI	t	\N	\N	\N	\N	\N	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20@paytm	\N	\N	\N	active	pending	2025-11-11 10:33:20.011083	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
3122c179-4ca7-45e9-8a6f-e3fcfcc6e0e1	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	net_banking	HDFC Net Banking	f	\N	\N	\N	\N	\N	\N	c7fbfa63b557cbda2254040fb0069640	HDFC0001234	HDFC Bank	active	verified	2025-10-30 10:33:20.011083	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
d8bc3883-259d-4a92-84f6-94cf9d7cdbe6	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	upi	Paytm UPI	t	\N	\N	\N	\N	\N	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21@paytm	\N	\N	\N	active	verified	2025-11-19 10:33:20.011083	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
0ee14b4e-63c3-412e-b186-0b8ecf05f56e	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	net_banking	HDFC Net Banking	f	\N	\N	\N	\N	\N	\N	89fefc9764431857f4cfb195910be91d	HDFC0001234	HDFC Bank	active	verified	2025-11-13 10:33:20.011083	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
52996eba-9164-4b6c-aa18-0bbb8d22eb97	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	credit_card	HDFC Credit Card	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	active	verified	2025-10-26 10:33:20.011083	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
e112583e-8123-4944-bc27-05680328653e	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22	upi	Paytm UPI	t	\N	\N	\N	\N	\N	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22@paytm	\N	\N	\N	active	verified	\N	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
2b261af2-a680-4c0c-aca4-b4c6b2d6a89e	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22	net_banking	HDFC Net Banking	f	\N	\N	\N	\N	\N	\N	abfc41631db7b1e966aa5188aeec95fd	HDFC0001234	HDFC Bank	active	verified	2025-11-19 10:33:20.011083	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
794f3d8b-ed75-49a9-9e55-9208e12e418d	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	upi	Paytm UPI	t	\N	\N	\N	\N	\N	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23@paytm	\N	\N	\N	active	verified	\N	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
24369e70-20ed-4ad3-bc8a-15c141cda527	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	net_banking	HDFC Net Banking	f	\N	\N	\N	\N	\N	\N	8c30ae54b6686e606b2dd7c3a03c0551	HDFC0001234	HDFC Bank	active	verified	2025-11-22 10:33:20.011083	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
6519829c-4072-407c-a4c2-29dbfefa3f7d	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	credit_card	HDFC Credit Card	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	active	verified	2025-11-02 10:33:20.011083	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
f2500911-f995-431e-ba2c-f94dfeea870e	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	upi	Paytm UPI	t	\N	\N	\N	\N	\N	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24@paytm	\N	\N	\N	active	verified	2025-11-02 10:33:20.011083	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
b814f911-f1f5-4566-b032-34c859e0d9b1	ea2b3915-033a-4ee6-b798-673ce79beab8	upi	Paytm UPI	t	\N	\N	\N	\N	\N	ea2b3915-033a-4ee6-b798-673ce79beab8@paytm	\N	\N	\N	active	verified	\N	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
a2bd2f61-182e-41dc-8cb8-34946b93c1b8	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	upi	Paytm UPI	t	\N	\N	\N	\N	\N	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7@paytm	\N	\N	\N	active	verified	2025-10-29 10:33:20.011083	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
8752dc0f-e4ae-4527-b4f3-686011da093a	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	net_banking	HDFC Net Banking	f	\N	\N	\N	\N	\N	\N	ac77be1752c9e4c45d45d68918b4cf09	HDFC0001234	HDFC Bank	active	verified	2025-11-06 10:33:20.011083	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
d9fa181e-6746-49c5-a2f8-ab61bcbe7d97	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	credit_card	HDFC Credit Card	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	active	pending	2025-10-26 10:33:20.011083	2025-11-24 10:33:20.011083	2025-11-24 10:33:20.011083
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.user_roles (assignment_id, user_id, role_id, assigned_by, assigned_at, expires_at) FROM stdin;
a59ebf65-9952-4240-9408-4d9d1eb2bb0e	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a6ad4340-5e1d-453e-aedd-db4543167f6d	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-10-25 10:28:21.255893	\N
6501ac0e-65f4-4147-911f-077023985063	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	17fd5370-752f-4597-882c-00e30f15fd7f	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	2025-10-25 10:28:21.255893	\N
a1b9c6a3-04d7-4495-baaf-55f6aec4acfc	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	17fd5370-752f-4597-882c-00e30f15fd7f	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	2025-10-25 10:28:21.255893	\N
3d405b6a-5022-4214-9afd-f6f5f64909a3	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	54fc8a7b-569e-434d-897f-770d002e933b	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	2025-10-25 10:28:21.255893	\N
b166eea7-4ce0-4700-8f99-2c0d0b464e1b	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	1c28a1fa-635f-40fe-87ad-5c737a9dc002	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	2025-10-25 10:28:21.255893	\N
35151c52-19a4-4407-ad0e-23400ec6bce7	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22	6f1550f5-6cc0-49b0-87e2-4d8e911b26e1	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22	2025-10-25 10:28:21.255893	\N
5cf85a10-3e25-4c2f-80b3-f086e9351932	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	17fd5370-752f-4597-882c-00e30f15fd7f	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	2025-10-25 10:28:21.255893	\N
1e560397-2391-404e-98d6-1c6814230dce	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	17fd5370-752f-4597-882c-00e30f15fd7f	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	2025-10-25 10:28:21.255893	\N
555bb368-8c4c-4101-9043-207c1fb6a43c	ea2b3915-033a-4ee6-b798-673ce79beab8	17fd5370-752f-4597-882c-00e30f15fd7f	ea2b3915-033a-4ee6-b798-673ce79beab8	2025-10-25 10:28:21.255893	\N
48819d4e-fed7-4ed5-ba26-496fcaa5da91	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	17fd5370-752f-4597-882c-00e30f15fd7f	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	2025-10-25 10:28:21.255893	\N
\.


--
-- Data for Name: user_sessions; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.user_sessions (session_id, user_id, session_token, refresh_token, device_info, ip_address, user_agent, location_info, expires_at, last_activity_at, created_at) FROM stdin;
8dbea8b3-f3e3-456b-b8fa-d62f9209982c	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	session_token_a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11_1763960301.255893	refresh_token_a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11_1763960301.255893	{"os": "android", "app_version": "1.0.0", "device_type": "mobile"}	192.168.1.48	AgentMitra/1.0.0 (Android 12; SM-G998B)	\N	2025-11-25 10:28:21.255893	2025-11-24 08:28:21.255893	2025-11-24 02:28:21.255893
e0590791-09d7-4fa9-b90e-6dba64df85d1	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	session_token_a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12_1763960301.255893	refresh_token_a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12_1763960301.255893	{"os": "android", "app_version": "1.0.0", "device_type": "mobile"}	192.168.1.172	AgentMitra/1.0.0 (Android 12; SM-G998B)	\N	2025-11-25 10:28:21.255893	2025-11-24 08:28:21.255893	2025-11-24 02:28:21.255893
28c4cdc0-aa17-4cb8-bdf7-5510235fdd19	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	session_token_a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13_1763960301.255893	refresh_token_a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13_1763960301.255893	{"os": "android", "app_version": "1.0.0", "device_type": "mobile"}	192.168.1.160	AgentMitra/1.0.0 (Android 12; SM-G998B)	\N	2025-11-25 10:28:21.255893	2025-11-24 08:28:21.255893	2025-11-24 02:28:21.255893
3f4c6b1a-5773-40cf-ad7d-f689d51e757a	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	session_token_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20_1763960301.255893	refresh_token_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20_1763960301.255893	{"os": "android", "app_version": "1.0.0", "device_type": "mobile"}	192.168.1.107	AgentMitra/1.0.0 (Android 12; SM-G998B)	\N	2025-11-25 10:28:21.255893	2025-11-24 08:28:21.255893	2025-11-24 02:28:21.255893
cae2801a-6772-4194-abbb-524edd8cbf61	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	session_token_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21_1763960301.255893	refresh_token_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21_1763960301.255893	{"os": "android", "app_version": "1.0.0", "device_type": "mobile"}	192.168.1.15	AgentMitra/1.0.0 (Android 12; SM-G998B)	\N	2025-11-25 10:28:21.255893	2025-11-24 08:28:21.255893	2025-11-24 02:28:21.255893
05be9664-c18e-447e-9f79-35b65b11ba8e	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22	session_token_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22_1763960301.255893	refresh_token_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22_1763960301.255893	{"os": "android", "app_version": "1.0.0", "device_type": "mobile"}	192.168.1.248	AgentMitra/1.0.0 (Android 12; SM-G998B)	\N	2025-11-25 10:28:21.255893	2025-11-24 08:28:21.255893	2025-11-24 02:28:21.255893
eb300a25-a9e8-478b-9aa6-2562bc2f69ec	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	session_token_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23_1763960301.255893	refresh_token_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23_1763960301.255893	{"os": "android", "app_version": "1.0.0", "device_type": "mobile"}	192.168.1.191	AgentMitra/1.0.0 (Android 12; SM-G998B)	\N	2025-11-25 10:28:21.255893	2025-11-24 08:28:21.255893	2025-11-24 02:28:21.255893
46f64186-a37e-4511-aba0-c567f4ecbf6b	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	session_token_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24_1763960301.255893	refresh_token_c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24_1763960301.255893	{"os": "android", "app_version": "1.0.0", "device_type": "mobile"}	192.168.1.71	AgentMitra/1.0.0 (Android 12; SM-G998B)	\N	2025-11-25 10:28:21.255893	2025-11-24 08:28:21.255893	2025-11-24 02:28:21.255893
9aa88855-08d5-484e-a819-f0fe14e928cd	ea2b3915-033a-4ee6-b798-673ce79beab8	session_token_ea2b3915-033a-4ee6-b798-673ce79beab8_1763960301.255893	refresh_token_ea2b3915-033a-4ee6-b798-673ce79beab8_1763960301.255893	{"os": "android", "app_version": "1.0.0", "device_type": "mobile"}	192.168.1.42	AgentMitra/1.0.0 (Android 12; SM-G998B)	\N	2025-11-25 10:28:21.255893	2025-11-24 08:28:21.255893	2025-11-24 02:28:21.255893
d1d5874d-2acc-47b9-ac61-5f2f58f19cfb	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	session_token_15f336f5-58a4-49a5-b1d5-26df0d6ed2a7_1763960301.255893	refresh_token_15f336f5-58a4-49a5-b1d5-26df0d6ed2a7_1763960301.255893	{"os": "android", "app_version": "1.0.0", "device_type": "mobile"}	192.168.1.80	AgentMitra/1.0.0 (Android 12; SM-G998B)	\N	2025-11-25 10:28:21.255893	2025-11-24 08:28:21.255893	2025-11-24 02:28:21.255893
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.users (user_id, tenant_id, email, phone_number, username, password_hash, password_salt, password_changed_at, first_name, last_name, display_name, avatar_url, date_of_birth, gender, address, emergency_contact, language_preference, timezone, theme_preference, notification_preferences, email_verified, phone_verified, email_verification_token, email_verification_expires, password_reset_token, password_reset_expires, mfa_enabled, mfa_secret, biometric_enabled, last_login_at, login_attempts, locked_until, role, status, trial_end_date, subscription_plan, subscription_status, created_by, created_at, updated_by, updated_at, deactivated_at, deactivated_reason) FROM stdin;
a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	00000000-0000-0000-0000-000000000000	agent1@test.com	+919876543210	\N	$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO	\N	\N	Test	Agent	Test Agent One	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	f	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	junior_agent	active	\N	\N	trial	\N	2025-11-23 22:34:55.683807	\N	2025-11-23 22:34:55.683807	\N	\N
a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	00000000-0000-0000-0000-000000000000	customer1@test.com	+919876543211	\N	$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO	\N	\N	Test	Customer	Test Customer One	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	f	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	policyholder	active	\N	\N	trial	\N	2025-11-23 22:34:55.683807	\N	2025-11-23 22:34:55.683807	\N	\N
a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	00000000-0000-0000-0000-000000000000	customer2@test.com	+919876543212	\N	$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO	\N	\N	Test	Customer2	Test Customer Two	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	f	f	\N	\N	\N	\N	f	\N	f	\N	0	\N	policyholder	active	\N	\N	trial	\N	2025-11-23 22:34:55.683807	\N	2025-11-23 22:34:55.683807	\N	\N
c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	00000000-0000-0000-0000-000000000000	senior_agent@test.com	+919876543220	\N	$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO	\N	\N	Senior	Agent	Senior Agent	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	f	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	senior_agent	active	\N	\N	trial	\N	2025-11-23 22:34:55.73505	\N	2025-11-23 22:34:55.73505	\N	\N
c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	00000000-0000-0000-0000-000000000000	regional_manager@test.com	+919876543221	\N	$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO	\N	\N	Regional	Manager	Regional Manager	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	f	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	regional_manager	active	\N	\N	trial	\N	2025-11-23 22:34:55.73505	\N	2025-11-23 22:34:55.73505	\N	\N
c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22	00000000-0000-0000-0000-000000000000	provider_admin@test.com	+919876543222	\N	$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO	\N	\N	Provider	Admin	Provider Admin	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	f	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	insurance_provider_admin	active	\N	\N	trial	\N	2025-11-23 22:34:55.73505	\N	2025-11-23 22:34:55.73505	\N	\N
c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	00000000-0000-0000-0000-000000000000	customer3@test.com	+919876543223	\N	$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO	\N	\N	Customer	Three	Customer Three	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	f	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	policyholder	active	\N	\N	trial	\N	2025-11-23 22:34:55.73505	\N	2025-11-23 22:34:55.73505	\N	\N
c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	00000000-0000-0000-0000-000000000000	customer4@test.com	+919876543224	\N	$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO	\N	\N	Customer	Four	Customer Four	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	f	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	policyholder	active	\N	\N	trial	\N	2025-11-23 22:34:55.73505	\N	2025-11-23 22:34:55.73505	\N	\N
ea2b3915-033a-4ee6-b798-673ce79beab8	00000000-0000-0000-0000-000000000000	seed_user_1@agentmitra.com	+919876543230	seed_user_1	$2b$10$example.hash	\N	\N	Seed	User1	Seed User 1	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	t	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	policyholder	active	\N	\N	trial	\N	2025-10-24 23:18:24.308084	\N	2025-11-23 23:18:24.308084	\N	\N
15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	00000000-0000-0000-0000-000000000000	seed_user_2@agentmitra.com	+919876543231	seed_user_2	$2b$10$example.hash	\N	\N	Seed	User2	Seed User 2	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	t	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	policyholder	active	\N	\N	trial	\N	2025-10-25 23:18:24.308084	\N	2025-11-23 23:18:24.308084	\N	\N
ddeee6e1-757f-4220-ad26-649bd9fd2987	00000000-0000-0000-0000-000000000000	seed_user_3@agentmitra.com	+919876543232	seed_user_3	$2b$10$example.hash	\N	\N	Seed	User3	Seed User 3	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	t	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	junior_agent	active	\N	\N	trial	\N	2025-10-26 23:18:24.308084	\N	2025-11-23 23:18:24.308084	\N	\N
5fbb7605-85a8-40b1-9e6e-ec405d8af18c	00000000-0000-0000-0000-000000000000	seed_user_4@agentmitra.com	+919876543233	seed_user_4	$2b$10$example.hash	\N	\N	Seed	User4	Seed User 4	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	t	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	senior_agent	active	\N	\N	trial	\N	2025-10-27 23:18:24.308084	\N	2025-11-23 23:18:24.308084	\N	\N
ea5b10ca-f6dc-4922-901e-8beb02496510	00000000-0000-0000-0000-000000000000	seed_user_5@agentmitra.com	+919876543234	seed_user_5	$2b$10$example.hash	\N	\N	Seed	User5	Seed User 5	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	t	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	policyholder	active	\N	\N	trial	\N	2025-10-28 23:18:24.308084	\N	2025-11-23 23:18:24.308084	\N	\N
4a944faf-5b11-4676-b887-f903da323b80	00000000-0000-0000-0000-000000000000	seed_user_6@agentmitra.com	+919876543235	seed_user_6	$2b$10$example.hash	\N	\N	Seed	User6	Seed User 6	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	t	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	policyholder	active	\N	\N	trial	\N	2025-10-29 23:18:24.308084	\N	2025-11-23 23:18:24.308084	\N	\N
045a6ed3-c48b-4d1c-ac86-8776bda0050f	00000000-0000-0000-0000-000000000000	seed_user_7@agentmitra.com	+919876543236	seed_user_7	$2b$10$example.hash	\N	\N	Seed	User7	Seed User 7	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	t	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	regional_manager	active	\N	\N	trial	\N	2025-10-30 23:18:24.308084	\N	2025-11-23 23:18:24.308084	\N	\N
0f2661d8-afb2-4f27-ad77-e0bfda097352	00000000-0000-0000-0000-000000000000	seed_user_8@agentmitra.com	+919876543237	seed_user_8	$2b$10$example.hash	\N	\N	Seed	User8	Seed User 8	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	t	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	junior_agent	active	\N	\N	trial	\N	2025-10-31 23:18:24.308084	\N	2025-11-23 23:18:24.308084	\N	\N
ef9f8c57-26ea-4e55-a5fe-a08dbba3ee83	00000000-0000-0000-0000-000000000000	seed_user_9@agentmitra.com	+919876543238	seed_user_9	$2b$10$example.hash	\N	\N	Seed	User9	Seed User 9	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	t	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	policyholder	active	\N	\N	trial	\N	2025-11-01 23:18:24.308084	\N	2025-11-23 23:18:24.308084	\N	\N
2da28562-c8be-4dd6-b0ee-5b1863ea66c4	00000000-0000-0000-0000-000000000000	seed_user_10@agentmitra.com	+919876543239	seed_user_10	$2b$10$example.hash	\N	\N	Seed	User10	Seed User 10	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	t	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	policyholder	active	\N	\N	trial	\N	2025-11-02 23:18:24.308084	\N	2025-11-23 23:18:24.308084	\N	\N
\.


--
-- Data for Name: video_content; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.video_content (video_id, agent_id, title, description, video_url, thumbnail_url, duration_seconds, category, tags, language, difficulty_level, target_audience, view_count, unique_viewers, avg_watch_time, completion_rate, engagement_rate, average_rating, total_ratings, featured, status, moderation_status, moderated_at, moderated_by, created_at, updated_at) FROM stdin;
534e1f9b-6941-48f1-9a61-226417e4ea84	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Health Insurance Made Simple	Plan your retirement with confidence using insurance	https://cdn.agentmitra.com/videos/b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11/video_1763960341.512119.mp4	https://cdn.agentmitra.com/thumbnails/b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11/thumb_1763960341.512119.jpg	565	health_insurance	{retirement,pension,planning}	en	intermediate	{young_professionals,investors}	3267	2285	212.21	45.73	14.66	3.58	98	t	processing	approved	\N	\N	2025-09-24 10:29:01.512119	2025-11-24 10:29:01.512119
a0c96fe0-a979-4bce-89b3-212504239374	1a4c8c40-d885-4c6d-b39a-8a42e3b4652d	Investment Plans for Your Future	Step-by-step guide to filing and processing insurance claims	https://cdn.agentmitra.com/videos/1a4c8c40-d885-4c6d-b39a-8a42e3b4652d/video_1763960341.512119.mp4	https://cdn.agentmitra.com/thumbnails/1a4c8c40-d885-4c6d-b39a-8a42e3b4652d/thumb_1763960341.512119.jpg	390	general	{retirement,pension,planning}	en	advanced	{young_professionals,investors}	1192	1821	208.57	28.36	27.05	3.76	25	t	rejected	approved	\N	\N	2025-10-28 10:29:01.512119	2025-11-24 10:29:01.512119
afa93c0b-69e1-4f84-97db-505fc5b01070	f580839c-4af3-4ebb-9935-bdb8c7acf7b6	Investment Plans for Your Future	Everything you need to know about health insurance	https://cdn.agentmitra.com/videos/f580839c-4af3-4ebb-9935-bdb8c7acf7b6/video_1763960341.512119.mp4	https://cdn.agentmitra.com/thumbnails/f580839c-4af3-4ebb-9935-bdb8c7acf7b6/thumb_1763960341.512119.jpg	194	health_insurance	{health,medical,hospital}	en	beginner	{policyholders,families}	4268	1191	250.35	48.76	36.00	4.92	22	f	published	approved	\N	\N	2025-09-18 10:29:01.512119	2025-11-24 10:29:01.512119
d6a4a86f-499b-4c7c-9afb-1becd4664353	991e6172-dcd1-4ca7-9c82-85cbbd14f6b3	Investment Plans for Your Future	Everything you need to know about health insurance	https://cdn.agentmitra.com/videos/991e6172-dcd1-4ca7-9c82-85cbbd14f6b3/video_1763960341.512119.mp4	https://cdn.agentmitra.com/thumbnails/991e6172-dcd1-4ca7-9c82-85cbbd14f6b3/thumb_1763960341.512119.jpg	416	general	{ulip,investment,savings}	en	advanced	{young_professionals,investors}	3830	1666	144.49	63.93	16.83	3.76	102	f	published	approved	\N	\N	2025-10-22 10:29:01.512119	2025-11-24 10:29:01.512119
8fad7bd9-299b-476a-b908-846b00498ea7	e2038ed1-cedc-4be8-9055-ef3a66bb1907	Investment Plans for Your Future	Everything you need to know about health insurance	https://cdn.agentmitra.com/videos/e2038ed1-cedc-4be8-9055-ef3a66bb1907/video_1763960341.512119.mp4	https://cdn.agentmitra.com/thumbnails/e2038ed1-cedc-4be8-9055-ef3a66bb1907/thumb_1763960341.512119.jpg	274	life_insurance	{health,medical,hospital}	en	advanced	{senior_citizens,retirees}	4239	1882	215.03	56.50	12.50	4.97	99	f	published	approved	\N	\N	2025-10-09 10:29:01.512119	2025-11-24 10:29:01.512119
128cd165-0446-406d-8e0c-e81245333da4	ff5e562b-9a46-4a04-81d1-ce54e425acbd	Retirement Planning Guide	Comprehensive guide to investment-linked insurance plans	https://cdn.agentmitra.com/videos/ff5e562b-9a46-4a04-81d1-ce54e425acbd/video_1763960341.512119.mp4	https://cdn.agentmitra.com/thumbnails/ff5e562b-9a46-4a04-81d1-ce54e425acbd/thumb_1763960341.512119.jpg	470	life_insurance	{health,medical,hospital}	hi	intermediate	{senior_citizens,retirees}	1045	2823	106.07	62.03	22.68	4.64	30	f	published	approved	\N	\N	2025-10-09 10:29:01.512119	2025-11-24 10:29:01.512119
2b2e795d-5b33-4910-80ab-59bd623702ee	bd40bf61-c2ad-4071-b868-ad54ab7cfa8d	Insurance Claims Process	Plan your retirement with confidence using insurance	https://cdn.agentmitra.com/videos/bd40bf61-c2ad-4071-b868-ad54ab7cfa8d/video_1763960341.512119.mp4	https://cdn.agentmitra.com/thumbnails/bd40bf61-c2ad-4071-b868-ad54ab7cfa8d/thumb_1763960341.512119.jpg	551	investment	{health,medical,hospital}	en	intermediate	{senior_citizens,retirees}	3520	2628	86.36	41.87	33.37	4.79	44	f	published	approved	\N	\N	2025-10-17 10:29:01.512119	2025-11-24 10:29:01.512119
8757d859-301e-473a-afe5-090c48ec7457	e45c1148-56b7-4605-b183-68ea7aec4383	Understanding Term Life Insurance	Comprehensive guide to investment-linked insurance plans	https://cdn.agentmitra.com/videos/e45c1148-56b7-4605-b183-68ea7aec4383/video_1763960341.512119.mp4	https://cdn.agentmitra.com/thumbnails/e45c1148-56b7-4605-b183-68ea7aec4383/thumb_1763960341.512119.jpg	195	health_insurance	{health,medical,hospital}	en	beginner	{young_professionals,investors}	3663	1970	236.80	58.96	37.52	3.65	71	f	processing	approved	\N	\N	2025-09-05 10:29:01.512119	2025-11-24 10:29:01.512119
82776fb1-f40a-48ad-afdf-11a137fdfcf8	91ad72ed-42d2-46ad-8338-4d22d8f7c80f	Investment Plans for Your Future	Step-by-step guide to filing and processing insurance claims	https://cdn.agentmitra.com/videos/91ad72ed-42d2-46ad-8338-4d22d8f7c80f/video_1763960341.512119.mp4	https://cdn.agentmitra.com/thumbnails/91ad72ed-42d2-46ad-8338-4d22d8f7c80f/thumb_1763960341.512119.jpg	350	life_insurance	{retirement,pension,planning}	en	advanced	{senior_citizens,retirees}	203	2616	156.76	33.42	36.78	4.83	59	f	rejected	approved	\N	\N	2025-11-02 10:29:01.512119	2025-11-24 10:29:01.512119
978e2460-5962-494f-86aa-49fe9c6abf26	da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec	Investment Plans for Your Future	Plan your retirement with confidence using insurance	https://cdn.agentmitra.com/videos/da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec/video_1763960341.512119.mp4	https://cdn.agentmitra.com/thumbnails/da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec/thumb_1763960341.512119.jpg	519	investment	{term_life,insurance,coverage}	en	advanced	{young_professionals,investors}	3413	486	110.17	44.70	21.99	3.65	18	t	rejected	approved	\N	\N	2025-11-15 10:29:01.512119	2025-11-24 10:29:01.512119
\.


--
-- Data for Name: whatsapp_messages; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.whatsapp_messages (message_id, whatsapp_message_id, sender_id, recipient_id, agent_id, message_type, content, media_url, media_type, whatsapp_template_id, whatsapp_template_name, whatsapp_status, conversation_id, message_sequence, is_from_customer, sent_at, delivered_at, read_at, created_at) FROM stdin;
11abff1f-dc1b-4199-8b11-6e5b300403b6	wa_1763960341.463858_1	045a6ed3-c48b-4d1c-ac86-8776bda0050f	045a6ed3-c48b-4d1c-ac86-8776bda0050f	e45c1148-56b7-4605-b183-68ea7aec4383	image	Please send me the premium payment link.	\N	\N	\N	\N	read	9f271bb2-d7fb-45d5-bfba-0791c1eca47c	1	f	2025-11-23 15:29:01.463858	2025-11-24 00:59:01.463858	2025-11-24 06:14:01.463858	2025-11-24 10:29:01.463858
80737690-e9a3-46aa-852b-5632af1098e0	wa_1763960341.463858_2	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	document	Hi, I need help with my policy renewal.	https://example.com/media/file_2.jpg	\N	\N	payment_reminder	read	404b68f1-ea35-4f00-8904-ac499e099fde	2	t	2025-11-23 17:29:01.463858	\N	2025-11-24 05:59:01.463858	2025-11-24 10:29:01.463858
897770c8-8f06-4da1-ba54-78e8abd2c01f	wa_1763960341.463858_3	5fbb7605-85a8-40b1-9e6e-ec405d8af18c	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	c47a7151-d764-4ad0-85ed-a2dc7c4d5ef3	image	Thank you for your assistance.	https://example.com/media/file_3.jpg	\N	\N	\N	delivered	b21769c5-3125-4702-aa46-3d7b0a0f5b7d	3	f	2025-11-23 14:29:01.463858	2025-11-24 07:29:01.463858	2025-11-24 07:59:01.463858	2025-11-24 10:29:01.463858
bec24134-dbd1-40e6-80af-fef791959507	wa_1763960341.463858_4	045a6ed3-c48b-4d1c-ac86-8776bda0050f	045a6ed3-c48b-4d1c-ac86-8776bda0050f	991e6172-dcd1-4ca7-9c82-85cbbd14f6b3	document	Please send me the premium payment link.	\N	\N	template_6	payment_reminder	sent	fc9261ef-74c2-4bce-a16e-7d83f86a6e55	4	t	2025-11-23 11:29:01.463858	2025-11-24 01:59:01.463858	2025-11-24 05:29:01.463858	2025-11-24 10:29:01.463858
41a4779d-2f9b-4f56-b97a-9843ada9779e	wa_1763960341.463858_5	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	document	Thank you for your assistance.	https://example.com/media/file_5.jpg	\N	\N	\N	delivered	92e73cd8-5d80-436f-9484-99ff10bffffd	5	t	2025-11-23 21:29:01.463858	2025-11-24 07:29:01.463858	\N	2025-11-24 10:29:01.463858
bd815a44-ee7d-49a7-886d-d96d82daae9e	wa_1763960341.463858_6	ea2b3915-033a-4ee6-b798-673ce79beab8	ea2b3915-033a-4ee6-b798-673ce79beab8	da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec	document	Thank you for your assistance.	https://example.com/media/file_6.jpg	\N	template_7	\N	delivered	ba4bdcaf-8436-46f2-a0f0-7cee4186fd82	6	t	2025-11-24 09:29:01.463858	2025-11-24 09:59:01.463858	2025-11-24 08:44:01.463858	2025-11-24 10:29:01.463858
18e74474-c589-429e-84db-e066454d8c4f	wa_1763960341.463858_7	ea5b10ca-f6dc-4922-901e-8beb02496510	0f2661d8-afb2-4f27-ad77-e0bfda097352	91ad72ed-42d2-46ad-8338-4d22d8f7c80f	document	Thank you for your assistance.	\N	\N	\N	\N	sent	b72366b4-ada1-4dd5-8af1-27e64f6e819b	7	t	2025-11-24 02:29:01.463858	\N	\N	2025-11-24 10:29:01.463858
f61a7d70-c31b-46a1-b942-28dd7f06a9ab	wa_1763960341.463858_8	15f336f5-58a4-49a5-b1d5-26df0d6ed2a7	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	document	Thank you for your assistance.	\N	\N	\N	\N	read	172fb3ca-9863-43d1-8e26-d58d5b39eafd	8	f	2025-11-23 16:29:01.463858	2025-11-24 07:29:01.463858	2025-11-24 09:29:01.463858	2025-11-24 10:29:01.463858
8d1e8216-95a6-4515-853e-e6914ab15bc0	wa_1763960341.463858_9	ddeee6e1-757f-4220-ad26-649bd9fd2987	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	1a4c8c40-d885-4c6d-b39a-8a42e3b4652d	document	Please send me the premium payment link.	\N	\N	template_5	payment_reminder	sent	d40d149a-e08c-4454-8688-d3bbc78c9924	9	t	2025-11-24 06:29:01.463858	\N	\N	2025-11-24 10:29:01.463858
4f7392c7-ff7c-446d-bbef-0e5c7bb0b85d	wa_1763960341.463858_10	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	da8561ea-93c9-47c5-8bcd-fcf0e8fa6bec	image	Please send me the premium payment link.	https://example.com/media/file_10.jpg	\N	\N	\N	read	c273cf21-27e4-43f3-8cc3-966c1b238583	10	f	2025-11-23 22:29:01.463858	2025-11-24 06:59:01.463858	2025-11-24 04:59:01.463858	2025-11-24 10:29:01.463858
\.


--
-- Data for Name: whatsapp_templates; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.whatsapp_templates (template_id, template_name, category, language, content, variables, approval_status, whatsapp_template_id, created_at) FROM stdin;
f9dfb57a-f016-40b4-9b8e-acd688517fec	policy_renewal_reminder	utility	en	Dear {{customer_name}}, Your policy {{policy_number}} is due for renewal on {{renewal_date}}. Please renew to continue coverage. Contact your agent {{agent_name}} at {{agent_phone}}.	["customer_name", "policy_number", "renewal_date", "agent_name", "agent_phone"]	pending	\N	2025-11-21 13:00:53.717908
f3902d7a-ed7d-4e7e-9fa0-0817ac8e9614	premium_payment_reminder	utility	en	Hello {{customer_name}}, Your premium payment of ₹{{amount}} for policy {{policy_number}} is due on {{due_date}}. Please pay to avoid policy lapse.	["customer_name", "amount", "policy_number", "due_date"]	pending	\N	2025-11-21 13:00:53.717908
ca86948f-0f21-4865-9054-f5b9c57f1865	policy_approval_notification	utility	en	Congratulations {{customer_name}}! Your policy {{policy_number}} has been approved. Policy document will be sent to your registered email.	["customer_name", "policy_number"]	pending	\N	2025-11-21 13:00:53.717908
60373194-5ebe-45ac-b664-2d1505f6854c	payment_reminder	utility	en	Hi {{customer_name}}, your premium payment of ₹{{amount}} for policy {{policy_number}} is due on {{due_date}}. Please pay on time to avoid policy lapse.	["customer_name", "amount", "policy_number", "due_date"]	approved	\N	2025-11-21 16:44:52.454925
c7902f18-f2fc-460b-820a-ed371fb520ed	policy_renewal_success	utility	en	Congratulations {{customer_name}}! Your policy {{policy_number}} has been successfully renewed. Coverage continues until {{end_date}}.	["customer_name", "policy_number", "end_date"]	approved	\N	2025-11-21 16:44:52.454925
e2eb8dfd-f07a-47c7-91db-b92ea705b0e5	agent_callback_request	utility	en	Hi {{customer_name}}, {{agent_name}} from {{agency_name}} would like to discuss insurance options with you. Please call back at {{phone_number}}.	["customer_name", "agent_name", "agency_name", "phone_number"]	approved	\N	2025-11-21 16:44:52.454925
\.


--
-- Data for Name: presentation_templates; Type: TABLE DATA; Schema: public; Owner: agentmitra
--

COPY public.presentation_templates (template_id, name, description, category, is_public, thumbnail_url, template_data, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: presentations; Type: TABLE DATA; Schema: public; Owner: agentmitra
--

COPY public.presentations (presentation_id, agent_id, name, description, status, is_active, template_id, tags, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: slides; Type: TABLE DATA; Schema: public; Owner: agentmitra
--

COPY public.slides (slide_id, presentation_id, slide_order, slide_type, media_url, thumbnail_url, title, subtitle, text_color, background_color, layout, duration, cta_button, agent_branding, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: user_sessions; Type: TABLE DATA; Schema: public; Owner: agentmitra
--

COPY public.user_sessions (session_id, user_id, access_token, refresh_token, expires_at, device_info, ip_address, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: agentmitra
--

COPY public.users (user_id, phone_number, email, full_name, agent_code, role, is_verified, password_hash, created_at, updated_at) FROM stdin;
d3fb5c5a-0580-4c2c-bb34-c6c4050bf4d3	+919876543212	\N	\N	\N	customer	f	\N	2025-11-21 13:31:58.50613	2025-11-21 13:31:58.50613
\.


--
-- Data for Name: countries; Type: TABLE DATA; Schema: shared; Owner: agentmitra
--

COPY shared.countries (country_id, country_code, country_name, currency_code, phone_code, timezone, status) FROM stdin;
22a696ac-a2ab-4ece-b9a3-798d61a1a580	IND	India	INR	+91	Asia/Kolkata	active
d8b51733-b932-4e93-8cc7-63653bc5de5f	USA	United States	USD	+1	America/New_York	active
21f86162-72b5-4e06-bcea-c39ecd820190	GBR	United Kingdom	GBP	+44	Europe/London	active
\.


--
-- Data for Name: customer_data_mapping; Type: TABLE DATA; Schema: shared; Owner: agentmitra
--

COPY shared.customer_data_mapping (mapping_id, import_id, excel_row_number, customer_name, phone_number, email, policy_number, date_of_birth, address, raw_excel_data, mapping_status, validation_errors, created_customer_id, created_at) FROM stdin;
\.


--
-- Data for Name: data_imports; Type: TABLE DATA; Schema: shared; Owner: agentmitra
--

COPY shared.data_imports (import_id, agent_id, file_name, file_path, file_size_bytes, import_type, status, total_records, processed_records, error_records, error_details, processing_started_at, processing_completed_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: data_sync_status; Type: TABLE DATA; Schema: shared; Owner: agentmitra
--

COPY shared.data_sync_status (sync_id, agent_id, customer_id, last_sync_at, sync_status, sync_type, error_message, retry_count, next_retry_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: shared; Owner: agentmitra
--

COPY shared.flyway_schema_history (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) FROM stdin;
0	\N	<< Flyway Schema Creation >>	SCHEMA	"shared","lic_schema","audit"	\N	agentmitra	2025-11-21 13:00:52.685654	0	t
1	1	Create shared schema	SQL	V1__Create_shared_schema.sql	2050221321	agentmitra	2025-11-21 13:00:52.729198	708	t
2	2	Create tenant schemas	SQL	V2__Create_tenant_schemas.sql	886127191	agentmitra	2025-11-21 13:00:53.450809	57	t
3	3	Create lic schema tables	SQL	V3__Create_lic_schema_tables.sql	294621631	agentmitra	2025-11-21 13:00:53.52252	85	t
4	4	Create presentation tables	SQL	V4__Create_presentation_tables.sql	-319447102	agentmitra	2025-11-21 13:00:53.620554	76	t
5	\N	Seed initial data	SQL	R__Seed_initial_data.sql	1841294938	agentmitra	2025-11-21 13:00:53.709229	17	t
6	5	Seed test users and presentations	SQL	V5__Seed_test_users_and_presentations.sql	-1040637352	agentmitra	2025-11-21 13:31:29.729201	64	t
7	6	Alter user sessions token columns	SQL	V6__Alter_user_sessions_token_columns.sql	1571164045	agentmitra	2025-11-21 13:36:06.344085	26	t
8	7	Database performance indexes	SQL	V7__Database_performance_indexes.sql	-892795210	agentmitra	2025-11-21 14:21:11.319867	31	t
9	8	Fix password hashes	SQL	V8__Fix_password_hashes.sql	-937324813	agentmitra	2025-11-21 16:22:09.15031	12	t
10	9	Seed comprehensive test data	SQL	V9__Seed_comprehensive_test_data.sql	-47411727	agentmitra	2025-11-21 16:44:52.437891	30	t
11	10	Create advanced analytics tables	SQL	V10__Create_advanced_analytics_tables.sql	700586136	agentmitra	2025-11-21 17:10:50.042416	111	t
12	\N	Seed analytics chatbot data	SQL	R__Seed_analytics_chatbot_data.sql	-1138796245	agentmitra	2025-11-21 17:14:38.414838	10	t
13	11	Create notification tables	SQL	V11__Create_notification_tables.sql	1048203998	manish	2025-11-22 17:06:52.520114	42	t
\.


--
-- Data for Name: import_jobs; Type: TABLE DATA; Schema: shared; Owner: agentmitra
--

COPY shared.import_jobs (job_id, import_id, job_type, priority, status, retry_count, max_retries, error_message, started_at, completed_at, created_at) FROM stdin;
\.


--
-- Data for Name: insurance_categories; Type: TABLE DATA; Schema: shared; Owner: agentmitra
--

COPY shared.insurance_categories (category_id, category_code, category_name, category_type, description, status) FROM stdin;
424e42b5-4a0d-40a3-aa7e-364618f4b64c	LIFE_TERM	Term Life Insurance	life	Pure life insurance coverage for a specific term period	active
37b8d14f-9d3d-4f1e-80cf-5b7c3fc77514	LIFE_WHOLE	Whole Life Insurance	life	Permanent life insurance with cash value accumulation	active
5a9f35f2-2456-41c1-863e-8828a01d1028	LIFE_ULIP	Unit Linked Insurance Plan	life	Combination of insurance and investment	active
78a317bf-9921-4e94-9168-bf8d13d3388c	HEALTH_INDIVIDUAL	Individual Health Insurance	health	Health coverage for individuals	active
786467aa-0724-43b1-adbb-aaf8afcc9cfb	HEALTH_FAMILY	Family Health Insurance	health	Health coverage for entire family	active
556aedb0-5c3c-457c-b7a5-329a1d4f26f2	HEALTH_SENIOR	Senior Citizen Health Insurance	health	Health coverage for senior citizens	active
e8c75371-4cef-4e00-9657-f44ebb4b8705	CHILD_PLAN	Child Plan	life	Savings and insurance plan for children	active
d29e06f9-61c6-4de3-8902-aa99658e847c	RETIREMENT	Retirement Plan	life	Pension and retirement savings plan	active
9376828e-cdc8-4e39-90a4-2ede3b8198c8	MOTOR	Motor Insurance	general	Vehicle insurance coverage	active
5eac643c-fe28-4d88-b55a-8bb2080a3edb	TRAVEL	Travel Insurance	general	Travel and medical coverage during trips	active
\.


--
-- Data for Name: insurance_providers; Type: TABLE DATA; Schema: shared; Owner: agentmitra
--

COPY shared.insurance_providers (provider_id, provider_code, provider_name, provider_type, description, api_endpoint, api_credentials, webhook_url, webhook_secret, license_number, regulatory_authority, established_year, headquarters, supported_languages, business_hours, service_regions, commission_structure, status, integration_status, last_sync_at, created_at, updated_at) FROM stdin;
048a9c69-46d3-47cd-88fd-83efe9bd2b0b	LIC	Life Insurance Corporation of India	life_insurance	Largest life insurance company in India	\N	\N	\N	\N	LIC-001	IRDAI	1956	{"city": "Mumbai", "state": "Maharashtra", "country": "India"}	{en,hi,te,ta,kn,mr,gu,bn,ml,pa}	\N	\N	\N	active	pending	\N	2025-11-21 13:00:53.717908	2025-11-21 13:00:53.717908
01fa8d3a-5509-4f73-abeb-617fd547f16d	HDFC_LIFE	HDFC Life Insurance Company	life_insurance	Leading private life insurance provider	\N	\N	\N	\N	HDFC-001	IRDAI	2000	{"city": "Mumbai", "state": "Maharashtra", "country": "India"}	{en,hi}	\N	\N	\N	active	pending	\N	2025-11-21 13:00:53.717908	2025-11-21 13:00:53.717908
33225144-c3fd-412d-9e70-e67f25e5a47a	ICICI_PRUDENTIAL	ICICI Prudential Life Insurance	life_insurance	Joint venture between ICICI Bank and Prudential	\N	\N	\N	\N	ICICI-001	IRDAI	2000	{"city": "Mumbai", "state": "Maharashtra", "country": "India"}	{en,hi}	\N	\N	\N	active	pending	\N	2025-11-21 13:00:53.717908	2025-11-21 13:00:53.717908
\.


--
-- Data for Name: languages; Type: TABLE DATA; Schema: shared; Owner: agentmitra
--

COPY shared.languages (language_id, language_code, language_name, native_name, rtl, status) FROM stdin;
19925dfe-1c3e-4842-a63e-878a23c7c3ab	en	English	English	f	active
3073e552-18ba-4e39-877b-78df5cfc0ab4	hi	Hindi	हिन्दी	f	active
4774c434-fea5-4aa5-aa0d-d91ef8ce004c	te	Telugu	తెలుగు	f	active
618b974c-0601-4481-b2f2-273ab063d494	ta	Tamil	தமிழ்	f	active
a9f8168b-a293-4c81-813a-644529c4d1ed	kn	Kannada	ಕನ್ನಡ	f	active
c82a6d0d-e7c0-43e0-9a38-32330e0c9f82	mr	Marathi	मराठी	f	active
22a2293e-1a13-4aad-81db-bc0c75309484	gu	Gujarati	ગુજરાતી	f	active
509f61d5-0512-46a7-ab2e-dbb35ff4a09b	bn	Bengali	বাংলা	f	active
d69fa08a-e3a9-406c-8741-d89b34393deb	ml	Malayalam	മലയാളം	f	active
53e801b2-13eb-4e11-bb5b-a296bcaf6f05	pa	Punjabi	ਪੰਜਾਬੀ	f	active
\.


--
-- Data for Name: tenant_config; Type: TABLE DATA; Schema: shared; Owner: agentmitra
--

COPY shared.tenant_config (config_id, tenant_id, config_key, config_value, config_type, is_encrypted, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: tenants; Type: TABLE DATA; Schema: shared; Owner: agentmitra
--

COPY shared.tenants (tenant_id, tenant_code, tenant_name, tenant_type, schema_name, parent_tenant_id, status, subscription_plan, trial_end_date, max_users, storage_limit_gb, api_rate_limit, created_at, updated_at) FROM stdin;
bf0b6627-c595-4fd8-93c2-cb0e9cdc86bc	LIC	Life Insurance Corporation of India	insurance_provider	lic_schema	\N	active	enterprise	\N	10000	1000	10000	2025-11-21 13:00:53.717908	2025-11-21 13:00:53.717908
\.


--
-- Data for Name: whatsapp_templates; Type: TABLE DATA; Schema: shared; Owner: agentmitra
--

COPY shared.whatsapp_templates (template_id, template_name, category, language, content, variables, approval_status, whatsapp_template_id, created_at) FROM stdin;
f9dfb57a-f016-40b4-9b8e-acd688517fec	policy_renewal_reminder	utility	en	Dear {{customer_name}}, Your policy {{policy_number}} is due for renewal on {{renewal_date}}. Please renew to continue coverage. Contact your agent {{agent_name}} at {{agent_phone}}.	["customer_name", "policy_number", "renewal_date", "agent_name", "agent_phone"]	pending	\N	2025-11-21 13:00:53.717908
f3902d7a-ed7d-4e7e-9fa0-0817ac8e9614	premium_payment_reminder	utility	en	Hello {{customer_name}}, Your premium payment of ₹{{amount}} for policy {{policy_number}} is due on {{due_date}}. Please pay to avoid policy lapse.	["customer_name", "amount", "policy_number", "due_date"]	pending	\N	2025-11-21 13:00:53.717908
ca86948f-0f21-4865-9054-f5b9c57f1865	policy_approval_notification	utility	en	Congratulations {{customer_name}}! Your policy {{policy_number}} has been approved. Policy document will be sent to your registered email.	["customer_name", "policy_number"]	pending	\N	2025-11-21 13:00:53.717908
60373194-5ebe-45ac-b664-2d1505f6854c	payment_reminder	utility	en	Hi {{customer_name}}, your premium payment of ₹{{amount}} for policy {{policy_number}} is due on {{due_date}}. Please pay on time to avoid policy lapse.	["customer_name", "amount", "policy_number", "due_date"]	approved	\N	2025-11-21 16:44:52.454925
c7902f18-f2fc-460b-820a-ed371fb520ed	policy_renewal_success	utility	en	Congratulations {{customer_name}}! Your policy {{policy_number}} has been successfully renewed. Coverage continues until {{end_date}}.	["customer_name", "policy_number", "end_date"]	approved	\N	2025-11-21 16:44:52.454925
e2eb8dfd-f07a-47c7-91db-b92ea705b0e5	agent_callback_request	utility	en	Hi {{customer_name}}, {{agent_name}} from {{agency_name}} would like to discuss insurance options with you. Please call back at {{phone_number}}.	["customer_name", "agent_name", "agency_name", "phone_number"]	approved	\N	2025-11-21 16:44:52.454925
bee63c28-2db2-4269-964b-3855f00bf2cb	claim_intimation	utility	en	Dear {{customer_name}}, your claim for policy {{policy_number}} amounting to ₹{{claim_amount}} has been processed and will be credited within 3 working days.	["customer_name", "policy_number", "claim_amount"]	approved	\N	2025-11-24 10:33:20.011083
a57a0954-22dd-4993-b2c7-fa96b76ffb82	policy_maturity	utility	en	Congratulations {{customer_name}}! Your policy {{policy_number}} has matured. The maturity amount of ₹{{maturity_amount}} will be credited to your account.	["customer_name", "policy_number", "maturity_amount"]	approved	\N	2025-11-24 10:33:20.011083
8bcaf27a-6c7e-4367-a23f-ddfc55a04cdb	document_verification	utility	en	Hi {{customer_name}}, we need additional documents for your policy {{policy_number}}. Please upload them through the app or visit your nearest branch.	["customer_name", "policy_number"]	approved	\N	2025-11-24 10:33:20.011083
35f2c954-b6b4-4802-b1d1-30e5717e46da	agent_assigned	utility	en	Welcome {{customer_name}}! {{agent_name}} has been assigned as your insurance agent. Contact: {{agent_phone}}	["customer_name", "agent_name", "agent_phone"]	pending	\N	2025-11-24 10:33:20.011083
ce793e22-cdde-4767-82f3-51bb151d1446	premium_discount	marketing	en	Special offer for {{customer_name}}! Get {{discount_percentage}}% discount on your next premium payment. Valid till {{valid_date}}.	["customer_name", "discount_percentage", "valid_date"]	pending	\N	2025-11-24 10:33:20.011083
6c832efc-89dd-4a12-9964-8883bec9fa10	policy_upgrade	marketing	en	Hi {{customer_name}}, upgrade your policy {{policy_number}} and get additional coverage at special rates. Contact us today!	["customer_name", "policy_number"]	pending	\N	2025-11-24 10:33:20.011083
1810a524-fd29-4cb2-b3ba-440e316916c2	payment_failed	utility	en	Alert: Payment of ₹{{amount}} for policy {{policy_number}} failed. Please retry or contact support.	["amount", "policy_number"]	approved	\N	2025-11-24 10:33:20.011083
\.


--
-- Name: device_tokens_id_seq; Type: SEQUENCE SET; Schema: lic_schema; Owner: agentmitra
--

SELECT pg_catalog.setval('lic_schema.device_tokens_id_seq', 20, true);


--
-- Name: notification_settings_id_seq; Type: SEQUENCE SET; Schema: lic_schema; Owner: agentmitra
--

SELECT pg_catalog.setval('lic_schema.notification_settings_id_seq', 10, true);


--
-- Name: agent_daily_metrics agent_daily_metrics_agent_id_metric_date_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.agent_daily_metrics
    ADD CONSTRAINT agent_daily_metrics_agent_id_metric_date_key UNIQUE (agent_id, metric_date);


--
-- Name: agent_daily_metrics agent_daily_metrics_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.agent_daily_metrics
    ADD CONSTRAINT agent_daily_metrics_pkey PRIMARY KEY (metric_id);


--
-- Name: agent_monthly_summary agent_monthly_summary_agent_id_summary_month_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.agent_monthly_summary
    ADD CONSTRAINT agent_monthly_summary_agent_id_summary_month_key UNIQUE (agent_id, summary_month);


--
-- Name: agent_monthly_summary agent_monthly_summary_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.agent_monthly_summary
    ADD CONSTRAINT agent_monthly_summary_pkey PRIMARY KEY (summary_id);


--
-- Name: agent_presentation_preferences agent_presentation_preferences_agent_id_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.agent_presentation_preferences
    ADD CONSTRAINT agent_presentation_preferences_agent_id_key UNIQUE (agent_id);


--
-- Name: agent_presentation_preferences agent_presentation_preferences_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.agent_presentation_preferences
    ADD CONSTRAINT agent_presentation_preferences_pkey PRIMARY KEY (preference_id);


--
-- Name: agents agents_agent_code_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.agents
    ADD CONSTRAINT agents_agent_code_key UNIQUE (agent_code);


--
-- Name: agents agents_license_number_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.agents
    ADD CONSTRAINT agents_license_number_key UNIQUE (license_number);


--
-- Name: agents agents_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.agents
    ADD CONSTRAINT agents_pkey PRIMARY KEY (agent_id);


--
-- Name: analytics_query_log analytics_query_log_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.analytics_query_log
    ADD CONSTRAINT analytics_query_log_pkey PRIMARY KEY (log_id);


--
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (message_id);


--
-- Name: chatbot_analytics_summary chatbot_analytics_summary_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.chatbot_analytics_summary
    ADD CONSTRAINT chatbot_analytics_summary_pkey PRIMARY KEY (analytics_id);


--
-- Name: chatbot_analytics_summary chatbot_analytics_summary_summary_date_summary_period_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.chatbot_analytics_summary
    ADD CONSTRAINT chatbot_analytics_summary_summary_date_summary_period_key UNIQUE (summary_date, summary_period);


--
-- Name: chatbot_intents chatbot_intents_intent_name_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.chatbot_intents
    ADD CONSTRAINT chatbot_intents_intent_name_key UNIQUE (intent_name);


--
-- Name: chatbot_intents chatbot_intents_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.chatbot_intents
    ADD CONSTRAINT chatbot_intents_pkey PRIMARY KEY (intent_id);


--
-- Name: chatbot_sessions chatbot_sessions_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.chatbot_sessions
    ADD CONSTRAINT chatbot_sessions_pkey PRIMARY KEY (session_id);


--
-- Name: countries countries_country_code_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.countries
    ADD CONSTRAINT countries_country_code_key UNIQUE (country_code);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (country_id);


--
-- Name: customer_behavior_metrics customer_behavior_metrics_customer_id_metric_date_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.customer_behavior_metrics
    ADD CONSTRAINT customer_behavior_metrics_customer_id_metric_date_key UNIQUE (customer_id, metric_date);


--
-- Name: customer_behavior_metrics customer_behavior_metrics_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.customer_behavior_metrics
    ADD CONSTRAINT customer_behavior_metrics_pkey PRIMARY KEY (metric_id);


--
-- Name: customer_data_mapping customer_data_mapping_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.customer_data_mapping
    ADD CONSTRAINT customer_data_mapping_pkey PRIMARY KEY (mapping_id);


--
-- Name: data_export_log data_export_log_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.data_export_log
    ADD CONSTRAINT data_export_log_pkey PRIMARY KEY (export_id);


--
-- Name: data_imports data_imports_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.data_imports
    ADD CONSTRAINT data_imports_pkey PRIMARY KEY (import_id);


--
-- Name: data_sync_status data_sync_status_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.data_sync_status
    ADD CONSTRAINT data_sync_status_pkey PRIMARY KEY (sync_id);


--
-- Name: device_tokens device_tokens_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.device_tokens
    ADD CONSTRAINT device_tokens_pkey PRIMARY KEY (id);


--
-- Name: device_tokens device_tokens_token_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.device_tokens
    ADD CONSTRAINT device_tokens_token_key UNIQUE (token);


--
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- Name: import_jobs import_jobs_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.import_jobs
    ADD CONSTRAINT import_jobs_pkey PRIMARY KEY (job_id);


--
-- Name: insurance_categories insurance_categories_category_code_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.insurance_categories
    ADD CONSTRAINT insurance_categories_category_code_key UNIQUE (category_code);


--
-- Name: insurance_categories insurance_categories_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.insurance_categories
    ADD CONSTRAINT insurance_categories_pkey PRIMARY KEY (category_id);


--
-- Name: insurance_policies insurance_policies_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.insurance_policies
    ADD CONSTRAINT insurance_policies_pkey PRIMARY KEY (policy_id);


--
-- Name: insurance_policies insurance_policies_policy_number_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.insurance_policies
    ADD CONSTRAINT insurance_policies_policy_number_key UNIQUE (policy_number);


--
-- Name: insurance_providers insurance_providers_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.insurance_providers
    ADD CONSTRAINT insurance_providers_pkey PRIMARY KEY (provider_id);


--
-- Name: insurance_providers insurance_providers_provider_code_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.insurance_providers
    ADD CONSTRAINT insurance_providers_provider_code_key UNIQUE (provider_code);


--
-- Name: knowledge_base_articles knowledge_base_articles_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.knowledge_base_articles
    ADD CONSTRAINT knowledge_base_articles_pkey PRIMARY KEY (article_id);


--
-- Name: knowledge_search_log knowledge_search_log_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.knowledge_search_log
    ADD CONSTRAINT knowledge_search_log_pkey PRIMARY KEY (search_id);


--
-- Name: languages languages_language_code_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.languages
    ADD CONSTRAINT languages_language_code_key UNIQUE (language_code);


--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (language_id);


--
-- Name: notification_settings notification_settings_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.notification_settings
    ADD CONSTRAINT notification_settings_pkey PRIMARY KEY (id);


--
-- Name: notification_settings notification_settings_user_id_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.notification_settings
    ADD CONSTRAINT notification_settings_user_id_key UNIQUE (user_id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_permission_name_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.permissions
    ADD CONSTRAINT permissions_permission_name_key UNIQUE (permission_name);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (permission_id);


--
-- Name: policy_analytics_summary policy_analytics_summary_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.policy_analytics_summary
    ADD CONSTRAINT policy_analytics_summary_pkey PRIMARY KEY (summary_id);


--
-- Name: policy_analytics_summary policy_analytics_summary_summary_date_summary_period_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.policy_analytics_summary
    ADD CONSTRAINT policy_analytics_summary_summary_date_summary_period_key UNIQUE (summary_date, summary_period);


--
-- Name: policyholders policyholders_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.policyholders
    ADD CONSTRAINT policyholders_pkey PRIMARY KEY (policyholder_id);


--
-- Name: premium_payments premium_payments_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.premium_payments
    ADD CONSTRAINT premium_payments_pkey PRIMARY KEY (payment_id);


--
-- Name: presentation_analytics presentation_analytics_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.presentation_analytics
    ADD CONSTRAINT presentation_analytics_pkey PRIMARY KEY (analytics_id);


--
-- Name: presentation_media presentation_media_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.presentation_media
    ADD CONSTRAINT presentation_media_pkey PRIMARY KEY (media_id);


--
-- Name: presentation_slides presentation_slides_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.presentation_slides
    ADD CONSTRAINT presentation_slides_pkey PRIMARY KEY (slide_id);


--
-- Name: presentation_slides presentation_slides_presentation_id_slide_order_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.presentation_slides
    ADD CONSTRAINT presentation_slides_presentation_id_slide_order_key UNIQUE (presentation_id, slide_order);


--
-- Name: presentation_templates presentation_templates_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.presentation_templates
    ADD CONSTRAINT presentation_templates_pkey PRIMARY KEY (template_id);


--
-- Name: presentations presentations_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.presentations
    ADD CONSTRAINT presentations_pkey PRIMARY KEY (presentation_id);


--
-- Name: revenue_forecasts revenue_forecasts_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.revenue_forecasts
    ADD CONSTRAINT revenue_forecasts_pkey PRIMARY KEY (forecast_id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (assignment_id);


--
-- Name: role_permissions role_permissions_role_id_permission_id_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.role_permissions
    ADD CONSTRAINT role_permissions_role_id_permission_id_key UNIQUE (role_id, permission_id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role_id);


--
-- Name: roles roles_role_name_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.roles
    ADD CONSTRAINT roles_role_name_key UNIQUE (role_name);


--
-- Name: tenant_config tenant_config_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.tenant_config
    ADD CONSTRAINT tenant_config_pkey PRIMARY KEY (config_id);


--
-- Name: tenant_config tenant_config_tenant_id_config_key_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.tenant_config
    ADD CONSTRAINT tenant_config_tenant_id_config_key_key UNIQUE (tenant_id, config_key);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (tenant_id);


--
-- Name: tenants tenants_schema_name_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.tenants
    ADD CONSTRAINT tenants_schema_name_key UNIQUE (schema_name);


--
-- Name: tenants tenants_tenant_code_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.tenants
    ADD CONSTRAINT tenants_tenant_code_key UNIQUE (tenant_code);


--
-- Name: user_payment_methods user_payment_methods_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.user_payment_methods
    ADD CONSTRAINT user_payment_methods_pkey PRIMARY KEY (payment_method_id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (assignment_id);


--
-- Name: user_roles user_roles_user_id_role_id_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.user_roles
    ADD CONSTRAINT user_roles_user_id_role_id_key UNIQUE (user_id, role_id);


--
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (session_id);


--
-- Name: user_sessions user_sessions_refresh_token_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.user_sessions
    ADD CONSTRAINT user_sessions_refresh_token_key UNIQUE (refresh_token);


--
-- Name: user_sessions user_sessions_session_token_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.user_sessions
    ADD CONSTRAINT user_sessions_session_token_key UNIQUE (session_token);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_number_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.users
    ADD CONSTRAINT users_phone_number_key UNIQUE (phone_number);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: video_content video_content_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.video_content
    ADD CONSTRAINT video_content_pkey PRIMARY KEY (video_id);


--
-- Name: whatsapp_messages whatsapp_messages_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.whatsapp_messages
    ADD CONSTRAINT whatsapp_messages_pkey PRIMARY KEY (message_id);


--
-- Name: whatsapp_messages whatsapp_messages_whatsapp_message_id_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.whatsapp_messages
    ADD CONSTRAINT whatsapp_messages_whatsapp_message_id_key UNIQUE (whatsapp_message_id);


--
-- Name: whatsapp_templates whatsapp_templates_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.whatsapp_templates
    ADD CONSTRAINT whatsapp_templates_pkey PRIMARY KEY (template_id);


--
-- Name: whatsapp_templates whatsapp_templates_template_name_key; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.whatsapp_templates
    ADD CONSTRAINT whatsapp_templates_template_name_key UNIQUE (template_name);


--
-- Name: presentation_templates presentation_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: agentmitra
--

ALTER TABLE ONLY public.presentation_templates
    ADD CONSTRAINT presentation_templates_pkey PRIMARY KEY (template_id);


--
-- Name: presentations presentations_pkey; Type: CONSTRAINT; Schema: public; Owner: agentmitra
--

ALTER TABLE ONLY public.presentations
    ADD CONSTRAINT presentations_pkey PRIMARY KEY (presentation_id);


--
-- Name: slides slides_pkey; Type: CONSTRAINT; Schema: public; Owner: agentmitra
--

ALTER TABLE ONLY public.slides
    ADD CONSTRAINT slides_pkey PRIMARY KEY (slide_id);


--
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: agentmitra
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (session_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: agentmitra
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: countries countries_country_code_key; Type: CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.countries
    ADD CONSTRAINT countries_country_code_key UNIQUE (country_code);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (country_id);


--
-- Name: customer_data_mapping customer_data_mapping_pkey; Type: CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.customer_data_mapping
    ADD CONSTRAINT customer_data_mapping_pkey PRIMARY KEY (mapping_id);


--
-- Name: data_imports data_imports_pkey; Type: CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.data_imports
    ADD CONSTRAINT data_imports_pkey PRIMARY KEY (import_id);


--
-- Name: data_sync_status data_sync_status_pkey; Type: CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.data_sync_status
    ADD CONSTRAINT data_sync_status_pkey PRIMARY KEY (sync_id);


--
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- Name: import_jobs import_jobs_pkey; Type: CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.import_jobs
    ADD CONSTRAINT import_jobs_pkey PRIMARY KEY (job_id);


--
-- Name: insurance_categories insurance_categories_category_code_key; Type: CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.insurance_categories
    ADD CONSTRAINT insurance_categories_category_code_key UNIQUE (category_code);


--
-- Name: insurance_categories insurance_categories_pkey; Type: CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.insurance_categories
    ADD CONSTRAINT insurance_categories_pkey PRIMARY KEY (category_id);


--
-- Name: insurance_providers insurance_providers_pkey; Type: CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.insurance_providers
    ADD CONSTRAINT insurance_providers_pkey PRIMARY KEY (provider_id);


--
-- Name: insurance_providers insurance_providers_provider_code_key; Type: CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.insurance_providers
    ADD CONSTRAINT insurance_providers_provider_code_key UNIQUE (provider_code);


--
-- Name: languages languages_language_code_key; Type: CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.languages
    ADD CONSTRAINT languages_language_code_key UNIQUE (language_code);


--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (language_id);


--
-- Name: tenant_config tenant_config_pkey; Type: CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.tenant_config
    ADD CONSTRAINT tenant_config_pkey PRIMARY KEY (config_id);


--
-- Name: tenant_config tenant_config_tenant_id_config_key_key; Type: CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.tenant_config
    ADD CONSTRAINT tenant_config_tenant_id_config_key_key UNIQUE (tenant_id, config_key);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (tenant_id);


--
-- Name: tenants tenants_schema_name_key; Type: CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.tenants
    ADD CONSTRAINT tenants_schema_name_key UNIQUE (schema_name);


--
-- Name: tenants tenants_tenant_code_key; Type: CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.tenants
    ADD CONSTRAINT tenants_tenant_code_key UNIQUE (tenant_code);


--
-- Name: whatsapp_templates whatsapp_templates_pkey; Type: CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.whatsapp_templates
    ADD CONSTRAINT whatsapp_templates_pkey PRIMARY KEY (template_id);


--
-- Name: whatsapp_templates whatsapp_templates_template_name_key; Type: CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.whatsapp_templates
    ADD CONSTRAINT whatsapp_templates_template_name_key UNIQUE (template_name);


--
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX flyway_schema_history_s_idx ON lic_schema.flyway_schema_history USING btree (success);


--
-- Name: idx_agent_leaderboard_rank; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_agent_leaderboard_rank ON lic_schema.agent_leaderboard USING btree (rank_by_premium);


--
-- Name: idx_agent_metrics_agent_date; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_agent_metrics_agent_date ON lic_schema.agent_daily_metrics USING btree (agent_id, metric_date DESC);


--
-- Name: idx_agent_metrics_date; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_agent_metrics_date ON lic_schema.agent_daily_metrics USING btree (metric_date DESC);


--
-- Name: idx_agent_summary_agent_month; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_agent_summary_agent_month ON lic_schema.agent_monthly_summary USING btree (agent_id, summary_month DESC);


--
-- Name: idx_agent_summary_month; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_agent_summary_month ON lic_schema.agent_monthly_summary USING btree (summary_month DESC);


--
-- Name: idx_agents_code_status; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_agents_code_status ON lic_schema.agents USING btree (agent_code, status) WHERE (status = 'active'::lic_schema.agent_status_enum);


--
-- Name: idx_agents_provider; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_agents_provider ON lic_schema.agents USING btree (provider_id);


--
-- Name: idx_agents_territory; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_agents_territory ON lic_schema.agents USING btree (territory);


--
-- Name: idx_agents_user_status; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_agents_user_status ON lic_schema.agents USING btree (user_id, status);


--
-- Name: idx_analytics_agent; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_analytics_agent ON lic_schema.presentation_analytics USING btree (agent_id, event_timestamp DESC);


--
-- Name: idx_analytics_event_data; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_analytics_event_data ON lic_schema.presentation_analytics USING gin (event_data);


--
-- Name: idx_analytics_event_type; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_analytics_event_type ON lic_schema.presentation_analytics USING btree (event_type, event_timestamp DESC);


--
-- Name: idx_analytics_presentation; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_analytics_presentation ON lic_schema.presentation_analytics USING btree (presentation_id, event_timestamp DESC);


--
-- Name: idx_analytics_query_type; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_analytics_query_type ON lic_schema.analytics_query_log USING btree (query_type, created_at DESC);


--
-- Name: idx_analytics_query_user; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_analytics_query_user ON lic_schema.analytics_query_log USING btree (user_id, created_at DESC);


--
-- Name: idx_analytics_slide; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_analytics_slide ON lic_schema.presentation_analytics USING btree (slide_id, event_type) WHERE (slide_id IS NOT NULL);


--
-- Name: idx_chatbot_analytics_date; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_chatbot_analytics_date ON lic_schema.chatbot_analytics_summary USING btree (summary_date DESC);


--
-- Name: idx_chatbot_intents_active; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_chatbot_intents_active ON lic_schema.chatbot_intents USING btree (intent_name) WHERE (is_active = true);


--
-- Name: idx_chatbot_sessions_user; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_chatbot_sessions_user ON lic_schema.chatbot_sessions USING btree (user_id);


--
-- Name: idx_countries_country_code; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_countries_country_code ON lic_schema.countries USING btree (country_code);


--
-- Name: idx_customer_behavior_customer; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_customer_behavior_customer ON lic_schema.customer_behavior_metrics USING btree (customer_id, metric_date DESC);


--
-- Name: idx_customer_behavior_date; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_customer_behavior_date ON lic_schema.customer_behavior_metrics USING btree (metric_date DESC);


--
-- Name: idx_customer_data_mapping_import; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_customer_data_mapping_import ON lic_schema.customer_data_mapping USING btree (import_id);


--
-- Name: idx_daily_kpis_date; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_daily_kpis_date ON lic_schema.daily_dashboard_kpis USING btree (report_date);


--
-- Name: idx_data_export_user; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_data_export_user ON lic_schema.data_export_log USING btree (user_id, created_at DESC);


--
-- Name: idx_data_imports_agent_status; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_data_imports_agent_status ON lic_schema.data_imports USING btree (agent_id, status);


--
-- Name: idx_data_sync_status_agent; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_data_sync_status_agent ON lic_schema.data_sync_status USING btree (agent_id);


--
-- Name: idx_device_tokens_token; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_device_tokens_token ON lic_schema.device_tokens USING btree (token);


--
-- Name: idx_device_tokens_user_id; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_device_tokens_user_id ON lic_schema.device_tokens USING btree (user_id);


--
-- Name: idx_import_jobs_status; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_import_jobs_status ON lic_schema.import_jobs USING btree (status);


--
-- Name: idx_insurance_categories_category_code; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_insurance_categories_category_code ON lic_schema.insurance_categories USING btree (category_code);


--
-- Name: idx_insurance_providers_provider_code; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_insurance_providers_provider_code ON lic_schema.insurance_providers USING btree (provider_code);


--
-- Name: idx_kb_articles_category; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_kb_articles_category ON lic_schema.knowledge_base_articles USING btree (category, is_active);


--
-- Name: idx_kb_articles_tags; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_kb_articles_tags ON lic_schema.knowledge_base_articles USING gin (tags);


--
-- Name: idx_kb_search_query; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_kb_search_query ON lic_schema.knowledge_search_log USING gin (to_tsvector('english'::regconfig, search_query));


--
-- Name: idx_kb_search_user; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_kb_search_user ON lic_schema.knowledge_search_log USING btree (user_id, created_at DESC);


--
-- Name: idx_languages_language_code; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_languages_language_code ON lic_schema.languages USING btree (language_code);


--
-- Name: idx_media_agent_status; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_media_agent_status ON lic_schema.presentation_media USING btree (agent_id, status);


--
-- Name: idx_media_hash; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_media_hash ON lic_schema.presentation_media USING btree (file_hash) WHERE (file_hash IS NOT NULL);


--
-- Name: idx_media_type; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_media_type ON lic_schema.presentation_media USING btree (media_type);


--
-- Name: idx_notification_settings_user_id; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_notification_settings_user_id ON lic_schema.notification_settings USING btree (user_id);


--
-- Name: idx_notifications_created_at; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_notifications_created_at ON lic_schema.notifications USING btree (created_at DESC);


--
-- Name: idx_notifications_is_read; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_notifications_is_read ON lic_schema.notifications USING btree (is_read);


--
-- Name: idx_notifications_type; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_notifications_type ON lic_schema.notifications USING btree (type);


--
-- Name: idx_notifications_user_id; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_notifications_user_id ON lic_schema.notifications USING btree (user_id);


--
-- Name: idx_notifications_user_read; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_notifications_user_read ON lic_schema.notifications USING btree (user_id, is_read);


--
-- Name: idx_payments_date_amount; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_payments_date_amount ON lic_schema.premium_payments USING btree (payment_date DESC, amount);


--
-- Name: idx_payments_policy_date; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_payments_policy_date ON lic_schema.premium_payments USING btree (policy_id, payment_date DESC);


--
-- Name: idx_payments_policy_status; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_payments_policy_status ON lic_schema.premium_payments USING btree (policy_id, status);


--
-- Name: idx_payments_status_date; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_payments_status_date ON lic_schema.premium_payments USING btree (status, payment_date DESC) WHERE (status = 'completed'::lic_schema.payment_status_enum);


--
-- Name: idx_policies_agent_provider; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_policies_agent_provider ON lic_schema.insurance_policies USING btree (agent_id, provider_id);


--
-- Name: idx_policies_dates_status; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_policies_dates_status ON lic_schema.insurance_policies USING btree (start_date, maturity_date, status) WHERE (status = ANY (ARRAY['active'::lic_schema.policy_status_enum, 'pending_approval'::lic_schema.policy_status_enum]));


--
-- Name: idx_policies_policyholder_status; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_policies_policyholder_status ON lic_schema.insurance_policies USING btree (policyholder_id, status);


--
-- Name: idx_policies_status_dates; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_policies_status_dates ON lic_schema.insurance_policies USING btree (status, start_date, maturity_date);


--
-- Name: idx_policy_analytics_date; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_policy_analytics_date ON lic_schema.policy_analytics_summary USING btree (summary_date DESC);


--
-- Name: idx_policy_analytics_period; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_policy_analytics_period ON lic_schema.policy_analytics_summary USING btree (summary_period, summary_date DESC);


--
-- Name: idx_presentations_active; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_presentations_active ON lic_schema.presentations USING btree (agent_id, is_active) WHERE (is_active = true);


--
-- Name: idx_presentations_agent_status; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_presentations_agent_status ON lic_schema.presentations USING btree (agent_id, status);


--
-- Name: idx_presentations_published; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_presentations_published ON lic_schema.presentations USING btree (published_at DESC) WHERE ((status)::text = 'published'::text);


--
-- Name: idx_presentations_template; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_presentations_template ON lic_schema.presentations USING btree (template_id) WHERE (template_id IS NOT NULL);


--
-- Name: idx_revenue_forecast_agent; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_revenue_forecast_agent ON lic_schema.revenue_forecasts USING btree (agent_id, forecast_date DESC);


--
-- Name: idx_revenue_forecast_date; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_revenue_forecast_date ON lic_schema.revenue_forecasts USING btree (forecast_date DESC);


--
-- Name: idx_slides_agent_branding; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_slides_agent_branding ON lic_schema.presentation_slides USING gin (agent_branding) WHERE (agent_branding IS NOT NULL);


--
-- Name: idx_slides_cta_button; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_slides_cta_button ON lic_schema.presentation_slides USING gin (cta_button) WHERE (cta_button IS NOT NULL);


--
-- Name: idx_slides_presentation_order; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_slides_presentation_order ON lic_schema.presentation_slides USING btree (presentation_id, slide_order);


--
-- Name: idx_slides_type; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_slides_type ON lic_schema.presentation_slides USING btree (slide_type);


--
-- Name: idx_templates_category_public; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_templates_category_public ON lic_schema.presentation_templates USING btree (category, is_public) WHERE (is_public = true);


--
-- Name: idx_templates_slides; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_templates_slides ON lic_schema.presentation_templates USING gin (slides);


--
-- Name: idx_templates_status; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_templates_status ON lic_schema.presentation_templates USING btree (status) WHERE ((status)::text = 'active'::text);


--
-- Name: idx_tenant_config_tenant_id; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_tenant_config_tenant_id ON lic_schema.tenant_config USING btree (tenant_id);


--
-- Name: idx_tenants_status; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_tenants_status ON lic_schema.tenants USING btree (status);


--
-- Name: idx_tenants_tenant_code; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_tenants_tenant_code ON lic_schema.tenants USING btree (tenant_code);


--
-- Name: idx_user_sessions_active; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_user_sessions_active ON lic_schema.user_sessions USING btree (user_id, expires_at DESC);


--
-- Name: idx_user_sessions_token; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_user_sessions_token ON lic_schema.user_sessions USING btree (session_token);


--
-- Name: idx_users_created_at; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_users_created_at ON lic_schema.users USING btree (created_at DESC);


--
-- Name: idx_users_email; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_users_email ON lic_schema.users USING btree (email) WHERE (email IS NOT NULL);


--
-- Name: idx_users_phone; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_users_phone ON lic_schema.users USING btree (phone_number) WHERE (phone_number IS NOT NULL);


--
-- Name: idx_users_phone_verified; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_users_phone_verified ON lic_schema.users USING btree (phone_number, phone_verified) WHERE (phone_verified = true);


--
-- Name: idx_users_role_status; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_users_role_status ON lic_schema.users USING btree (role, status) WHERE (status = 'active'::lic_schema.user_status_enum);


--
-- Name: idx_users_tenant_status; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_users_tenant_status ON lic_schema.users USING btree (tenant_id, status);


--
-- Name: idx_video_content_agent; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_video_content_agent ON lic_schema.video_content USING btree (agent_id);


--
-- Name: idx_whatsapp_messages_agent; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_whatsapp_messages_agent ON lic_schema.whatsapp_messages USING btree (agent_id);


--
-- Name: ix_presentations_agent_id; Type: INDEX; Schema: public; Owner: agentmitra
--

CREATE INDEX ix_presentations_agent_id ON public.presentations USING btree (agent_id);


--
-- Name: ix_presentations_is_active; Type: INDEX; Schema: public; Owner: agentmitra
--

CREATE INDEX ix_presentations_is_active ON public.presentations USING btree (is_active);


--
-- Name: ix_slides_presentation_id; Type: INDEX; Schema: public; Owner: agentmitra
--

CREATE INDEX ix_slides_presentation_id ON public.slides USING btree (presentation_id);


--
-- Name: ix_user_sessions_user_id; Type: INDEX; Schema: public; Owner: agentmitra
--

CREATE INDEX ix_user_sessions_user_id ON public.user_sessions USING btree (user_id);


--
-- Name: ix_users_agent_code; Type: INDEX; Schema: public; Owner: agentmitra
--

CREATE UNIQUE INDEX ix_users_agent_code ON public.users USING btree (agent_code);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: agentmitra
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_phone_number; Type: INDEX; Schema: public; Owner: agentmitra
--

CREATE UNIQUE INDEX ix_users_phone_number ON public.users USING btree (phone_number);


--
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: shared; Owner: agentmitra
--

CREATE INDEX flyway_schema_history_s_idx ON shared.flyway_schema_history USING btree (success);


--
-- Name: idx_countries_country_code; Type: INDEX; Schema: shared; Owner: agentmitra
--

CREATE INDEX idx_countries_country_code ON shared.countries USING btree (country_code);


--
-- Name: idx_customer_data_mapping_import; Type: INDEX; Schema: shared; Owner: agentmitra
--

CREATE INDEX idx_customer_data_mapping_import ON shared.customer_data_mapping USING btree (import_id);


--
-- Name: idx_data_imports_agent_status; Type: INDEX; Schema: shared; Owner: agentmitra
--

CREATE INDEX idx_data_imports_agent_status ON shared.data_imports USING btree (agent_id, status);


--
-- Name: idx_data_sync_status_agent; Type: INDEX; Schema: shared; Owner: agentmitra
--

CREATE INDEX idx_data_sync_status_agent ON shared.data_sync_status USING btree (agent_id);


--
-- Name: idx_import_jobs_status; Type: INDEX; Schema: shared; Owner: agentmitra
--

CREATE INDEX idx_import_jobs_status ON shared.import_jobs USING btree (status);


--
-- Name: idx_insurance_categories_category_code; Type: INDEX; Schema: shared; Owner: agentmitra
--

CREATE INDEX idx_insurance_categories_category_code ON shared.insurance_categories USING btree (category_code);


--
-- Name: idx_insurance_providers_provider_code; Type: INDEX; Schema: shared; Owner: agentmitra
--

CREATE INDEX idx_insurance_providers_provider_code ON shared.insurance_providers USING btree (provider_code);


--
-- Name: idx_languages_language_code; Type: INDEX; Schema: shared; Owner: agentmitra
--

CREATE INDEX idx_languages_language_code ON shared.languages USING btree (language_code);


--
-- Name: idx_tenant_config_tenant_id; Type: INDEX; Schema: shared; Owner: agentmitra
--

CREATE INDEX idx_tenant_config_tenant_id ON shared.tenant_config USING btree (tenant_id);


--
-- Name: idx_tenants_status; Type: INDEX; Schema: shared; Owner: agentmitra
--

CREATE INDEX idx_tenants_status ON shared.tenants USING btree (status);


--
-- Name: idx_tenants_tenant_code; Type: INDEX; Schema: shared; Owner: agentmitra
--

CREATE INDEX idx_tenants_tenant_code ON shared.tenants USING btree (tenant_code);


--
-- Name: presentation_analytics presentation_analytics_summary_trigger; Type: TRIGGER; Schema: lic_schema; Owner: agentmitra
--

CREATE TRIGGER presentation_analytics_summary_trigger AFTER INSERT ON lic_schema.presentation_analytics FOR EACH ROW EXECUTE FUNCTION lic_schema.update_presentation_analytics_summary();


--
-- Name: presentation_slides slide_media_usage_trigger; Type: TRIGGER; Schema: lic_schema; Owner: agentmitra
--

CREATE TRIGGER slide_media_usage_trigger AFTER INSERT OR UPDATE ON lic_schema.presentation_slides FOR EACH ROW EXECUTE FUNCTION lic_schema.increment_media_usage();


--
-- Name: device_tokens trigger_update_device_tokens_last_used_at; Type: TRIGGER; Schema: lic_schema; Owner: agentmitra
--

CREATE TRIGGER trigger_update_device_tokens_last_used_at BEFORE UPDATE ON lic_schema.device_tokens FOR EACH ROW EXECUTE FUNCTION lic_schema.update_device_tokens_last_used_at();


--
-- Name: notification_settings trigger_update_notification_settings_updated_at; Type: TRIGGER; Schema: lic_schema; Owner: agentmitra
--

CREATE TRIGGER trigger_update_notification_settings_updated_at BEFORE UPDATE ON lic_schema.notification_settings FOR EACH ROW EXECUTE FUNCTION lic_schema.update_notification_settings_updated_at();


--
-- Name: insurance_policies update_agent_metrics_trigger; Type: TRIGGER; Schema: lic_schema; Owner: agentmitra
--

CREATE TRIGGER update_agent_metrics_trigger AFTER INSERT OR DELETE OR UPDATE ON lic_schema.insurance_policies FOR EACH ROW EXECUTE FUNCTION lic_schema.update_agent_daily_metrics();


--
-- Name: agent_daily_metrics agent_daily_metrics_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.agent_daily_metrics
    ADD CONSTRAINT agent_daily_metrics_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: agent_monthly_summary agent_monthly_summary_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.agent_monthly_summary
    ADD CONSTRAINT agent_monthly_summary_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: agent_presentation_preferences agent_presentation_preferences_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.agent_presentation_preferences
    ADD CONSTRAINT agent_presentation_preferences_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: agents agents_approved_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.agents
    ADD CONSTRAINT agents_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES lic_schema.users(user_id);


--
-- Name: agents agents_parent_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.agents
    ADD CONSTRAINT agents_parent_agent_id_fkey FOREIGN KEY (parent_agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: agents agents_provider_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.agents
    ADD CONSTRAINT agents_provider_id_fkey FOREIGN KEY (provider_id) REFERENCES lic_schema.insurance_providers(provider_id);


--
-- Name: agents agents_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.agents
    ADD CONSTRAINT agents_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: analytics_query_log analytics_query_log_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.analytics_query_log
    ADD CONSTRAINT analytics_query_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id);


--
-- Name: chat_messages chat_messages_session_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.chat_messages
    ADD CONSTRAINT chat_messages_session_id_fkey FOREIGN KEY (session_id) REFERENCES lic_schema.chatbot_sessions(session_id);


--
-- Name: chat_messages chat_messages_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.chat_messages
    ADD CONSTRAINT chat_messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id);


--
-- Name: chatbot_intents chatbot_intents_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.chatbot_intents
    ADD CONSTRAINT chatbot_intents_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: chatbot_sessions chatbot_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.chatbot_sessions
    ADD CONSTRAINT chatbot_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id);


--
-- Name: customer_behavior_metrics customer_behavior_metrics_customer_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.customer_behavior_metrics
    ADD CONSTRAINT customer_behavior_metrics_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES lic_schema.policyholders(policyholder_id);


--
-- Name: customer_data_mapping customer_data_mapping_import_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.customer_data_mapping
    ADD CONSTRAINT customer_data_mapping_import_id_fkey FOREIGN KEY (import_id) REFERENCES lic_schema.data_imports(import_id);


--
-- Name: data_export_log data_export_log_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.data_export_log
    ADD CONSTRAINT data_export_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id);


--
-- Name: import_jobs import_jobs_import_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.import_jobs
    ADD CONSTRAINT import_jobs_import_id_fkey FOREIGN KEY (import_id) REFERENCES lic_schema.data_imports(import_id);


--
-- Name: insurance_policies insurance_policies_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.insurance_policies
    ADD CONSTRAINT insurance_policies_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: insurance_policies insurance_policies_approved_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.insurance_policies
    ADD CONSTRAINT insurance_policies_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES lic_schema.users(user_id);


--
-- Name: insurance_policies insurance_policies_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.insurance_policies
    ADD CONSTRAINT insurance_policies_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: insurance_policies insurance_policies_policyholder_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.insurance_policies
    ADD CONSTRAINT insurance_policies_policyholder_id_fkey FOREIGN KEY (policyholder_id) REFERENCES lic_schema.policyholders(policyholder_id);


--
-- Name: insurance_policies insurance_policies_provider_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.insurance_policies
    ADD CONSTRAINT insurance_policies_provider_id_fkey FOREIGN KEY (provider_id) REFERENCES shared.insurance_providers(provider_id);


--
-- Name: knowledge_base_articles knowledge_base_articles_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.knowledge_base_articles
    ADD CONSTRAINT knowledge_base_articles_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: knowledge_base_articles knowledge_base_articles_moderated_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.knowledge_base_articles
    ADD CONSTRAINT knowledge_base_articles_moderated_by_fkey FOREIGN KEY (moderated_by) REFERENCES lic_schema.users(user_id);


--
-- Name: knowledge_search_log knowledge_search_log_clicked_article_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.knowledge_search_log
    ADD CONSTRAINT knowledge_search_log_clicked_article_id_fkey FOREIGN KEY (clicked_article_id) REFERENCES lic_schema.knowledge_base_articles(article_id);


--
-- Name: knowledge_search_log knowledge_search_log_session_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.knowledge_search_log
    ADD CONSTRAINT knowledge_search_log_session_id_fkey FOREIGN KEY (session_id) REFERENCES lic_schema.chatbot_sessions(session_id);


--
-- Name: knowledge_search_log knowledge_search_log_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.knowledge_search_log
    ADD CONSTRAINT knowledge_search_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id);


--
-- Name: policyholders policyholders_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.policyholders
    ADD CONSTRAINT policyholders_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: policyholders policyholders_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.policyholders
    ADD CONSTRAINT policyholders_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: premium_payments premium_payments_policy_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.premium_payments
    ADD CONSTRAINT premium_payments_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES lic_schema.insurance_policies(policy_id);


--
-- Name: premium_payments premium_payments_policyholder_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.premium_payments
    ADD CONSTRAINT premium_payments_policyholder_id_fkey FOREIGN KEY (policyholder_id) REFERENCES lic_schema.policyholders(policyholder_id);


--
-- Name: premium_payments premium_payments_reconciled_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.premium_payments
    ADD CONSTRAINT premium_payments_reconciled_by_fkey FOREIGN KEY (reconciled_by) REFERENCES lic_schema.users(user_id);


--
-- Name: presentation_analytics presentation_analytics_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.presentation_analytics
    ADD CONSTRAINT presentation_analytics_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: presentation_analytics presentation_analytics_presentation_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.presentation_analytics
    ADD CONSTRAINT presentation_analytics_presentation_id_fkey FOREIGN KEY (presentation_id) REFERENCES lic_schema.presentations(presentation_id) ON DELETE CASCADE;


--
-- Name: presentation_analytics presentation_analytics_slide_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.presentation_analytics
    ADD CONSTRAINT presentation_analytics_slide_id_fkey FOREIGN KEY (slide_id) REFERENCES lic_schema.presentation_slides(slide_id) ON DELETE SET NULL;


--
-- Name: presentation_analytics presentation_analytics_viewer_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.presentation_analytics
    ADD CONSTRAINT presentation_analytics_viewer_id_fkey FOREIGN KEY (viewer_id) REFERENCES lic_schema.users(user_id);


--
-- Name: presentation_media presentation_media_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.presentation_media
    ADD CONSTRAINT presentation_media_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: presentation_slides presentation_slides_presentation_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.presentation_slides
    ADD CONSTRAINT presentation_slides_presentation_id_fkey FOREIGN KEY (presentation_id) REFERENCES lic_schema.presentations(presentation_id) ON DELETE CASCADE;


--
-- Name: presentation_templates presentation_templates_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.presentation_templates
    ADD CONSTRAINT presentation_templates_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: presentations presentations_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.presentations
    ADD CONSTRAINT presentations_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id) ON DELETE CASCADE;


--
-- Name: presentations presentations_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.presentations
    ADD CONSTRAINT presentations_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: presentations presentations_parent_presentation_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.presentations
    ADD CONSTRAINT presentations_parent_presentation_id_fkey FOREIGN KEY (parent_presentation_id) REFERENCES lic_schema.presentations(presentation_id);


--
-- Name: presentations presentations_published_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.presentations
    ADD CONSTRAINT presentations_published_by_fkey FOREIGN KEY (published_by) REFERENCES lic_schema.users(user_id);


--
-- Name: revenue_forecasts revenue_forecasts_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.revenue_forecasts
    ADD CONSTRAINT revenue_forecasts_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: revenue_forecasts revenue_forecasts_created_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.revenue_forecasts
    ADD CONSTRAINT revenue_forecasts_created_by_fkey FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id);


--
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES lic_schema.permissions(permission_id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES lic_schema.roles(role_id) ON DELETE CASCADE;


--
-- Name: tenant_config tenant_config_tenant_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.tenant_config
    ADD CONSTRAINT tenant_config_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES lic_schema.tenants(tenant_id);


--
-- Name: tenants tenants_parent_tenant_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.tenants
    ADD CONSTRAINT tenants_parent_tenant_id_fkey FOREIGN KEY (parent_tenant_id) REFERENCES lic_schema.tenants(tenant_id);


--
-- Name: user_payment_methods user_payment_methods_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.user_payment_methods
    ADD CONSTRAINT user_payment_methods_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_assigned_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.user_roles
    ADD CONSTRAINT user_roles_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES lic_schema.users(user_id);


--
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES lic_schema.roles(role_id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: user_sessions user_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.user_sessions
    ADD CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;


--
-- Name: video_content video_content_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.video_content
    ADD CONSTRAINT video_content_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: video_content video_content_moderated_by_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.video_content
    ADD CONSTRAINT video_content_moderated_by_fkey FOREIGN KEY (moderated_by) REFERENCES lic_schema.users(user_id);


--
-- Name: whatsapp_messages whatsapp_messages_agent_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.whatsapp_messages
    ADD CONSTRAINT whatsapp_messages_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id);


--
-- Name: whatsapp_messages whatsapp_messages_recipient_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.whatsapp_messages
    ADD CONSTRAINT whatsapp_messages_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES lic_schema.users(user_id);


--
-- Name: whatsapp_messages whatsapp_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.whatsapp_messages
    ADD CONSTRAINT whatsapp_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES lic_schema.users(user_id);


--
-- Name: presentations presentations_agent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: agentmitra
--

ALTER TABLE ONLY public.presentations
    ADD CONSTRAINT presentations_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES public.users(user_id);


--
-- Name: presentations presentations_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: agentmitra
--

ALTER TABLE ONLY public.presentations
    ADD CONSTRAINT presentations_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.presentation_templates(template_id);


--
-- Name: slides slides_presentation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: agentmitra
--

ALTER TABLE ONLY public.slides
    ADD CONSTRAINT slides_presentation_id_fkey FOREIGN KEY (presentation_id) REFERENCES public.presentations(presentation_id);


--
-- Name: user_sessions user_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: agentmitra
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: customer_data_mapping customer_data_mapping_import_id_fkey; Type: FK CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.customer_data_mapping
    ADD CONSTRAINT customer_data_mapping_import_id_fkey FOREIGN KEY (import_id) REFERENCES shared.data_imports(import_id);


--
-- Name: import_jobs import_jobs_import_id_fkey; Type: FK CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.import_jobs
    ADD CONSTRAINT import_jobs_import_id_fkey FOREIGN KEY (import_id) REFERENCES shared.data_imports(import_id);


--
-- Name: tenant_config tenant_config_tenant_id_fkey; Type: FK CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.tenant_config
    ADD CONSTRAINT tenant_config_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES shared.tenants(tenant_id);


--
-- Name: tenants tenants_parent_tenant_id_fkey; Type: FK CONSTRAINT; Schema: shared; Owner: agentmitra
--

ALTER TABLE ONLY shared.tenants
    ADD CONSTRAINT tenants_parent_tenant_id_fkey FOREIGN KEY (parent_tenant_id) REFERENCES shared.tenants(tenant_id);


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: audit; Owner: agentmitra
--

ALTER DEFAULT PRIVILEGES FOR ROLE agentmitra IN SCHEMA audit GRANT ALL ON TABLES TO agentmitra;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: lic_schema; Owner: agentmitra
--

ALTER DEFAULT PRIVILEGES FOR ROLE agentmitra IN SCHEMA lic_schema GRANT ALL ON TABLES TO agentmitra;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: shared; Owner: agentmitra
--

ALTER DEFAULT PRIVILEGES FOR ROLE agentmitra IN SCHEMA shared GRANT ALL ON TABLES TO agentmitra;


--
-- Name: agent_leaderboard; Type: MATERIALIZED VIEW DATA; Schema: lic_schema; Owner: agentmitra
--

REFRESH MATERIALIZED VIEW lic_schema.agent_leaderboard;


--
-- Name: daily_dashboard_kpis; Type: MATERIALIZED VIEW DATA; Schema: lic_schema; Owner: agentmitra
--

REFRESH MATERIALIZED VIEW lic_schema.daily_dashboard_kpis;


--
-- PostgreSQL database dump complete
--

\unrestrict 6unFOBg3CqVSDnvdu6VAjxTgWdHynQ3PsUvvMmFlfVULSGBfHwOjJkxc4NMRgqB

