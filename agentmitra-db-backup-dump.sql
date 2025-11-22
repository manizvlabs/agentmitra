--
-- PostgreSQL database dump
--

\restrict ZddoH5SNZeecvmjfyH39Ik5UilB5ZQzDkv67dF43XPUOhC5l2fpCU6R5YLXkyRS

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
-- Data for Name: agent_daily_metrics; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.agent_daily_metrics (metric_id, agent_id, metric_date, policies_sold, premium_collected, active_policyholders, new_customers, commission_earned, target_achievement, customer_satisfaction_score, conversion_rate, presentations_viewed, cta_clicks, whatsapp_messages_sent, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: agent_monthly_summary; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.agent_monthly_summary (summary_id, agent_id, summary_month, total_policies, total_premium, total_commission, active_customers, growth_rate, retention_rate, rank_by_premium, rank_by_policies, created_at) FROM stdin;
\.


--
-- Data for Name: agent_presentation_preferences; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.agent_presentation_preferences (preference_id, agent_id, default_text_color, default_background_color, default_layout, default_duration, logo_url, brand_colors, auto_add_logo, auto_add_contact_cta, contact_cta_text, editor_theme, show_preview_by_default, auto_save_enabled, auto_save_interval_seconds, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: agents; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.agents (agent_id, user_id, provider_id, agent_code, license_number, license_expiry_date, license_issuing_authority, business_name, business_address, gst_number, pan_number, territory, operating_regions, experience_years, specializations, commission_rate, commission_structure, performance_bonus_structure, whatsapp_business_number, business_email, website, total_policies_sold, total_premium_collected, active_policyholders, customer_satisfaction_score, parent_agent_id, hierarchy_level, sub_agents_count, status, verification_status, approved_at, approved_by, created_at, updated_at) FROM stdin;
b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	AGENT001	LIC123456	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	43500.00	2	4.50	\N	1	0	active	pending	\N	\N	2025-11-21 13:31:29.74132	2025-11-21 13:31:29.74132
d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	01fa8d3a-5509-4f73-abeb-617fd547f16d	AGENT002	LIC234567	\N	\N	Senior Insurance Solutions	{"city": "Mumbai", "state": "Maharashtra", "pincode": "400001"}	\N	\N	Mumbai Central	\N	8	{life_insurance,health_insurance}	5.50	\N	\N	\N	\N	\N	2	75000.00	2	4.70	\N	1	0	active	approved	\N	\N	2025-11-21 16:44:52.454925	2025-11-21 16:44:52.454925
d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	01fa8d3a-5509-4f73-abeb-617fd547f16d	AGENT003	LIC345678	\N	\N	Regional Insurance Hub	{"city": "Pune", "state": "Maharashtra", "pincode": "411001"}	\N	\N	Pune Region	\N	12	{term_life,ulip,retirement}	7.00	\N	\N	\N	\N	\N	1	50000.00	1	4.80	\N	1	0	active	approved	\N	\N	2025-11-21 16:44:52.454925	2025-11-21 16:44:52.454925
\.


--
-- Data for Name: analytics_query_log; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.analytics_query_log (log_id, user_id, query_type, query_parameters, execution_time_ms, records_returned, ip_address, user_agent, data_classification, access_reason, created_at) FROM stdin;
\.


--
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.chat_messages (message_id, session_id, user_id, message_type, content, is_from_user, intent_detected, confidence_score, entities_detected, response_generated, response_time_ms, suggested_actions, "timestamp") FROM stdin;
\.


--
-- Data for Name: chatbot_analytics_summary; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.chatbot_analytics_summary (analytics_id, summary_date, summary_period, total_sessions, completed_sessions, abandoned_sessions, total_messages, average_messages_per_session, average_response_time_ms, resolution_rate, escalation_rate, average_satisfaction, satisfaction_responses, top_intents, created_at) FROM stdin;
\.


--
-- Data for Name: chatbot_intents; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.chatbot_intents (intent_id, intent_name, description, training_examples, response_templates, confidence_threshold, is_active, usage_count, success_rate, average_confidence, created_by, created_at, updated_at) FROM stdin;
e5b66a8f-0602-42f9-8f50-99ae095fae72	policy_inquiry	User is asking about policy details, status, or information	{"What is the status of my policy?","Can you tell me about my life insurance policy?","I need information about policy number POL123","When does my policy expire?"}	{"I can help you with information about your policy. Could you please provide your policy number?","To check your policy status, I need your policy number or some identifying information.","I'd be happy to help you with your policy inquiry. What specific information are you looking for?"}	0.70	t	0	\N	\N	\N	2025-11-21 17:10:50.078901	2025-11-21 17:10:50.078901
67a24a2c-34cd-4dd6-a14c-3818ff328898	premium_payment	User wants to know about or make premium payments	{"How do I pay my premium?","When is my next premium due?","I want to make a payment","What payment methods do you accept?"}	{"You can pay your premium through various methods including online banking, UPI, credit/debit cards, and cash at our branches.","Your next premium payment is due on [date]. You can pay online through our portal or mobile app.","We accept payments through net banking, UPI (Google Pay, PhonePe, Paytm), credit/debit cards, and cash payments."}	0.70	t	0	\N	\N	\N	2025-11-21 17:10:50.078901	2025-11-21 17:10:50.078901
\.


--
-- Data for Name: chatbot_sessions; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.chatbot_sessions (session_id, user_id, conversation_id, started_at, ended_at, duration_seconds, message_count, resolution_status, average_response_time, user_satisfaction_score, escalation_reason, device_info, ip_address, user_agent) FROM stdin;
\.


--
-- Data for Name: customer_behavior_metrics; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.customer_behavior_metrics (metric_id, customer_id, metric_date, login_count, page_views, session_duration, policy_views, premium_payments, claims_submitted, email_opens, whatsapp_messages, support_tickets, churn_probability, upgrade_probability, created_at) FROM stdin;
\.


--
-- Data for Name: data_export_log; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.data_export_log (export_id, user_id, export_type, record_count, data_types, date_range, encryption_used, ip_address, purpose, retention_period_days, file_name, file_size_bytes, storage_location, created_at, expires_at) FROM stdin;
\.


--
-- Data for Name: insurance_policies; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.insurance_policies (policy_id, policy_number, provider_policy_id, policyholder_id, agent_id, provider_id, policy_type, plan_name, plan_code, category, sum_assured, premium_amount, premium_frequency, premium_mode, application_date, approval_date, start_date, maturity_date, renewal_date, status, sub_status, payment_status, coverage_details, exclusions, terms_and_conditions, policy_document_url, application_form_url, medical_reports, nominee_details, assignee_details, created_by, approved_by, last_payment_date, next_payment_date, total_payments, outstanding_amount, created_at, updated_at) FROM stdin;
f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	POL001001	\N	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	01fa8d3a-5509-4f73-abeb-617fd547f16d	term_life	LIC Term Plan	TERM2024	life	5000000.00	15000.00	annual	\N	2025-10-22	\N	2025-11-21	\N	\N	active	\N	pending	\N	\N	\N	\N	\N	\N	\N	\N	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	\N	\N	0	0.00	2025-11-21 16:44:52.454925	2025-11-21 16:44:52.454925
f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	POL001002	\N	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	01fa8d3a-5509-4f73-abeb-617fd547f16d	health_insurance	LIC Health Shield	HEALTH2024	health	300000.00	8500.00	annual	\N	2025-11-06	\N	2025-11-21	\N	\N	active	\N	pending	\N	\N	\N	\N	\N	\N	\N	\N	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	\N	\N	0	0.00	2025-11-21 16:44:52.454925	2025-11-21 16:44:52.454925
f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	POL002001	\N	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	01fa8d3a-5509-4f73-abeb-617fd547f16d	ulip	LIC ULIP Plan	ULIP2024	life	2000000.00	25000.00	annual	\N	2025-11-01	\N	2025-11-21	\N	\N	pending_approval	\N	pending	\N	\N	\N	\N	\N	\N	\N	\N	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	\N	\N	\N	0	0.00	2025-11-21 16:44:52.454925	2025-11-21 16:44:52.454925
f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	POL003001	\N	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	01fa8d3a-5509-4f73-abeb-617fd547f16d	retirement	LIC Retirement Plan	RETIRE2024	life	10000000.00	50000.00	annual	\N	2025-11-11	\N	2025-11-26	\N	\N	draft	\N	pending	\N	\N	\N	\N	\N	\N	\N	\N	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	\N	\N	\N	0	0.00	2025-11-21 16:44:52.454925	2025-11-21 16:44:52.454925
f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14	POL001003	\N	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	01fa8d3a-5509-4f73-abeb-617fd547f16d	child_plan	LIC Child Plan	CHILD2024	life	1000000.00	12000.00	annual	\N	2025-11-16	\N	2025-11-21	\N	\N	approved	\N	pending	\N	\N	\N	\N	\N	\N	\N	\N	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	\N	\N	0	0.00	2025-11-21 16:44:52.454925	2025-11-21 16:44:52.454925
\.


--
-- Data for Name: knowledge_base_articles; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.knowledge_base_articles (article_id, title, content, summary, category, sub_category, tags, content_type, language, difficulty_level, embedding_vector, keywords_extracted, related_articles, view_count, helpful_votes, total_votes, average_rating, is_active, is_featured, moderation_status, created_by, moderated_by, created_at, updated_at, published_at) FROM stdin;
d82c4e31-54a1-440b-b934-89f3fcba8b91	Life Insurance Basics: What You Need to Know	Life insurance is a contract between you and an insurance company. In exchange for premium payments, the insurance company provides a lump-sum payment, known as a death benefit, to beneficiaries when the insured passes away...	\N	life_insurance	\N	{basics,fundamentals,beginners}	guide	en	beginner	\N	\N	\N	0	0	0	\N	t	t	approved	\N	\N	2025-11-21 17:10:50.078901	2025-11-21 17:10:50.078901	\N
f221cd0d-1a34-41d3-8e21-b4af6223a075	How to File an Insurance Claim	Filing an insurance claim can seem daunting, but following these steps will help you through the process smoothly...	\N	claims	\N	{claims,procedures,help}	guide	en	intermediate	\N	\N	\N	0	0	0	\N	t	t	approved	\N	\N	2025-11-21 17:10:50.078901	2025-11-21 17:10:50.078901	\N
\.


--
-- Data for Name: knowledge_search_log; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.knowledge_search_log (search_id, user_id, session_id, search_query, search_filters, results_count, clicked_article_id, search_time_ms, search_source, ip_address, created_at) FROM stdin;
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.permissions (permission_id, permission_name, permission_description, resource_type, action, created_at) FROM stdin;
71581566-95db-4c7d-9e2f-e30307989190	users.create	Create users	user	create	2025-11-21 13:00:53.717908
3ba5c47e-36f6-4e93-99e1-bb4e2f7a327c	users.read	Read users	user	read	2025-11-21 13:00:53.717908
ff9076e7-4d5a-4886-bb36-079e1fa4b96c	users.update	Update users	user	update	2025-11-21 13:00:53.717908
3e5bef5f-eced-4cda-ab86-bb2ee57e60d3	users.delete	Delete users	user	delete	2025-11-21 13:00:53.717908
a3cf04c9-e87c-4f7f-9631-6ed30d0b4c99	agents.create	Create agents	agent	create	2025-11-21 13:00:53.717908
52ffd5a7-182f-424a-a939-019235cfa336	agents.read	Read agents	agent	read	2025-11-21 13:00:53.717908
cb12be6b-e5b0-449d-974d-49303a65ec3f	agents.update	Update agents	agent	update	2025-11-21 13:00:53.717908
d2cd9fc6-fd80-4ce5-925c-223bae689037	policies.create	Create policies	policy	create	2025-11-21 13:00:53.717908
8bf20220-9f43-41e1-bdfa-e788fa05e9b9	policies.read	Read policies	policy	read	2025-11-21 13:00:53.717908
779bcb3c-8285-4320-b82d-4653b151023a	policies.update	Update policies	policy	update	2025-11-21 13:00:53.717908
51e11f1a-cc18-4a27-8596-17716bc612a0	policies.delete	Delete policies	policy	delete	2025-11-21 13:00:53.717908
44d5f789-0491-4e23-a7c3-dd84049a9272	customers.create	Create customers	customer	create	2025-11-21 13:00:53.717908
fd3e18b3-7d96-49f6-9dac-884e03229a0c	customers.read	Read customers	customer	read	2025-11-21 13:00:53.717908
a0d0614c-2dfd-403d-aace-0dc32606258d	customers.update	Update customers	customer	update	2025-11-21 13:00:53.717908
c93ab5d2-b860-4259-ab55-33090c70a7d5	payments.create	Create payments	payment	create	2025-11-21 13:00:53.717908
6f228cdc-e5da-42c3-8316-78c3aa6420a1	payments.read	Read payments	payment	read	2025-11-21 13:00:53.717908
5c51fc9b-5a3c-4409-8881-2cc6bff17cb5	reports.read	Read reports	report	read	2025-11-21 13:00:53.717908
4a55b72e-e05d-4842-b5f7-1e8c9d7aa096	presentations.create	Create presentations	presentation	create	2025-11-21 13:00:53.717908
424f839b-8d97-4676-b0cb-15b472853748	presentations.read	Read presentations	presentation	read	2025-11-21 13:00:53.717908
280e0965-4b00-4add-8c61-1725583bf275	presentations.update	Update presentations	presentation	update	2025-11-21 13:00:53.717908
13fd03ae-01a7-4dc2-a0bd-bb57b5589860	presentations.publish	Publish presentations	presentation	publish	2025-11-21 13:00:53.717908
\.


--
-- Data for Name: policy_analytics_summary; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.policy_analytics_summary (summary_id, summary_date, summary_period, draft_policies, pending_policies, approved_policies, active_policies, lapsed_policies, cancelled_policies, life_policies, health_policies, general_policies, total_premium, average_premium, applications_received, applications_approved, conversion_rate, created_at) FROM stdin;
bc9e6ff2-dc49-4fe8-b213-c8482633a8d6	2025-11-21	daily	10	15	135	120	5	3	80	45	25	2500000.00	16666.67	0	0	0.00	2025-11-21 17:14:38.426928
\.


--
-- Data for Name: policyholders; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.policyholders (policyholder_id, user_id, agent_id, customer_id, salutation, marital_status, occupation, annual_income, education_level, risk_profile, investment_horizon, communication_preferences, marketing_consent, family_members, nominee_details, bank_details, investment_portfolio, preferred_contact_time, preferred_language, digital_literacy_score, engagement_score, onboarding_status, churn_risk_score, last_interaction_at, total_interactions, created_at, updated_at) FROM stdin;
e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	CUST001	Mr.	married	Software Engineer	1200000.00	graduate	{"risk_tolerance": "moderate", "investment_horizon": "long_term"}	\N	\N	t	\N	\N	\N	\N	\N	en	\N	\N	completed	\N	\N	0	2025-11-21 16:44:52.454925	2025-11-21 16:44:52.454925
e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	CUST002	Ms.	single	Teacher	450000.00	post_graduate	{"risk_tolerance": "conservative", "investment_horizon": "medium_term"}	\N	\N	t	\N	\N	\N	\N	\N	hi	\N	\N	completed	\N	\N	0	2025-11-21 16:44:52.454925	2025-11-21 16:44:52.454925
e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	CUST003	Mr.	married	Doctor	2500000.00	post_graduate	{"risk_tolerance": "low", "investment_horizon": "short_term"}	\N	\N	t	\N	\N	\N	\N	\N	en	\N	\N	completed	\N	\N	0	2025-11-21 16:44:52.454925	2025-11-21 16:44:52.454925
e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	CUST004	Mrs.	married	Business Owner	800000.00	graduate	{"risk_tolerance": "high", "investment_horizon": "long_term"}	\N	\N	t	\N	\N	\N	\N	\N	hi	\N	\N	completed	\N	\N	0	2025-11-21 16:44:52.454925	2025-11-21 16:44:52.454925
\.


--
-- Data for Name: premium_payments; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.premium_payments (payment_id, policy_id, policyholder_id, amount, currency, payment_date, due_date, grace_period_days, payment_method, payment_gateway, gateway_transaction_id, gateway_response, status, failure_reason, retry_count, reconciled, reconciled_at, reconciled_by, ip_address, user_agent, device_info, created_at, updated_at) FROM stdin;
eb248793-6ee3-472b-ba95-a9e2809176e7	f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10	15000.00	INR	2025-11-20 00:00:00	2025-11-21 00:00:00	30	online	\N	\N	\N	completed	\N	0	f	\N	\N	\N	\N	\N	2025-11-21 16:44:52.454925	2025-11-21 16:44:52.454925
dca087cf-8355-40f2-8730-c3beba97439b	f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	8500.00	INR	2025-11-19 00:00:00	2025-11-21 00:00:00	30	bank_transfer	\N	\N	\N	completed	\N	0	f	\N	\N	\N	\N	\N	2025-11-21 16:44:52.454925	2025-11-21 16:44:52.454925
5732dcfa-7f16-49a1-abd9-a87691c94f60	f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	25000.00	INR	2025-11-21 00:00:00	2025-12-21 00:00:00	30	online	\N	\N	\N	pending	\N	0	f	\N	\N	\N	\N	\N	2025-11-21 16:44:52.454925	2025-11-21 16:44:52.454925
\.


--
-- Data for Name: presentation_analytics; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.presentation_analytics (analytics_id, presentation_id, slide_id, agent_id, event_type, event_category, viewer_id, viewer_type, event_data, cta_action, share_method, device_info, ip_address, user_agent, location_info, event_timestamp) FROM stdin;
\.


--
-- Data for Name: presentation_media; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.presentation_media (media_id, agent_id, media_type, mime_type, file_name, file_size_bytes, storage_provider, storage_key, media_url, thumbnail_url, width, height, duration_seconds, file_hash, usage_count, last_used_at, status, is_optimized, uploaded_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: presentation_slides; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.presentation_slides (slide_id, presentation_id, slide_order, slide_type, media_url, media_type, thumbnail_url, media_storage_key, title, subtitle, description, text_color, background_color, overlay_opacity, layout, duration, transition_effect, cta_button, agent_branding, created_at, updated_at) FROM stdin;
e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1	image	https://via.placeholder.com/800x600/FF0000/FFFFFF?text=Slide+1	\N	\N	\N	Welcome	To Agent Mitra	\N	#FFFFFF	#000000	0.50	centered	5	fade	\N	\N	2025-11-21 13:31:29.74132	2025-11-21 13:31:29.74132
e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2	text	\N	\N	\N	\N	Our Services	Insurance Solutions for Everyone	\N	#000000	#FFFFFF	0.50	centered	4	fade	{"text": "Learn More", "action": "/services"}	\N	2025-11-21 13:31:29.74132	2025-11-21 13:31:29.74132
e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	3	image	https://via.placeholder.com/800x600/0000FF/FFFFFF?text=Slide+3	\N	\N	\N	Contact Us	Get in touch today	\N	#FFFFFF	#0000FF	0.50	bottom	5	fade	\N	\N	2025-11-21 13:31:29.74132	2025-11-21 13:31:29.74132
\.


--
-- Data for Name: presentation_templates; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.presentation_templates (template_id, name, description, category, slides, is_default, is_public, is_system_template, usage_count, average_rating, total_ratings, preview_image_url, preview_video_url, status, available_from, available_until, created_by, created_at, updated_at) FROM stdin;
c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Promotional Template	Template for promotional content	term_insurance	[{"type": "image", "layout": "centered"}]	f	t	f	0	\N	0	\N	\N	active	\N	\N	\N	2025-11-21 13:31:29.74132	2025-11-21 13:31:29.74132
c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	Educational Template	Template for educational content	health_insurance	[{"type": "text", "layout": "top"}]	f	t	f	0	\N	0	\N	\N	active	\N	\N	\N	2025-11-21 13:31:29.74132	2025-11-21 13:31:29.74132
\.


--
-- Data for Name: presentations; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.presentations (presentation_id, agent_id, name, description, status, is_active, template_id, template_category, version, parent_presentation_id, created_at, updated_at, published_at, archived_at, tags, target_audience, language, total_views, total_shares, total_cta_clicks, created_by, published_by) FROM stdin;
d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Daily Promotional	Daily promotional presentation	published	t	c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	1	\N	2025-11-21 13:31:29.74132	2025-11-21 13:31:29.74132	\N	\N	{promotional,daily}	\N	en	0	0	0	\N	\N
d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Weekly Update	Weekly update presentation	draft	f	\N	\N	1	\N	2025-11-21 13:31:29.74132	2025-11-21 13:31:29.74132	\N	\N	{update}	\N	en	0	0	0	\N	\N
\.


--
-- Data for Name: revenue_forecasts; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.revenue_forecasts (forecast_id, agent_id, forecast_period, forecast_date, target_date, predicted_revenue, predicted_commission, confidence_level, actual_revenue, actual_commission, forecast_accuracy, forecast_method, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.role_permissions (assignment_id, role_id, permission_id, granted_at) FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.roles (role_id, role_name, role_description, is_system_role, permissions, created_at) FROM stdin;
f4ceceeb-f89a-4e3e-af37-c25a38c6e3e1	super_admin	Super Administrator with full system access	t	["*"]	2025-11-21 13:00:53.717908
910a5ded-0162-44d1-aad3-87031623c419	insurance_provider_admin	Insurance Provider Administrator	t	["users.*", "agents.*", "policies.*", "reports.*"]	2025-11-21 13:00:53.717908
3fcf10c1-87f8-4c87-a8a4-f73a8bb671d9	regional_manager	Regional Manager	t	["agents.read", "agents.update", "policies.read", "reports.read"]	2025-11-21 13:00:53.717908
b58aff91-79e5-46d0-9d7e-47fc89cf8b05	senior_agent	Senior Insurance Agent	t	["policies.create", "policies.read", "policies.update", "customers.*"]	2025-11-21 13:00:53.717908
f6326f04-3cc8-4a3d-bb53-e40a9e07a877	junior_agent	Junior Insurance Agent	t	["policies.read", "customers.read"]	2025-11-21 13:00:53.717908
5f67605d-d5f6-4f34-a2f9-7dfbdbe31484	policyholder	Policyholder/Customer	t	["policies.read", "payments.create", "payments.read"]	2025-11-21 13:00:53.717908
f3374dd4-24f9-42e0-be32-3d2a65b6cf27	support_staff	Customer Support Staff	t	["customers.read", "policies.read", "tickets.*"]	2025-11-21 13:00:53.717908
0227351b-f104-4603-8f3f-f45caf5be97c	guest	Guest User	t	["policies.read"]	2025-11-21 13:00:53.717908
\.


--
-- Data for Name: user_payment_methods; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.user_payment_methods (payment_method_id, user_id, method_type, method_name, is_default, card_number_encrypted, card_holder_name, expiry_month, expiry_year, cvv_encrypted, upi_id, bank_account_number_encrypted, bank_ifsc_code, bank_name, status, verification_status, last_used_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.user_roles (assignment_id, user_id, role_id, assigned_by, assigned_at, expires_at) FROM stdin;
\.


--
-- Data for Name: user_sessions; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.user_sessions (session_id, user_id, session_token, refresh_token, device_info, ip_address, user_agent, location_info, expires_at, last_activity_at, created_at) FROM stdin;
48059e30-e71f-4958-998d-5e0c65a7fab5	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImV4cCI6MTc2MzcxNDE3OSwidHlwZSI6ImFjY2VzcyJ9.VfzaR-Azz0d4xr3egYAwPEQFY48wyXTfgTinIFyxxvQ	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImV4cCI6MTc2NDMxNzE3OSwidHlwZSI6InJlZnJlc2gifQ.1WDtx2UkYEMEfUMk49H7A_jSFsBZNmnfEkCOqEw6tH8	null	\N	\N	\N	2025-11-21 08:21:31.862146	2025-11-21 13:36:19.769364	2025-11-21 13:36:19.769364
bba13389-cf7c-4df5-8895-ff181df21d31	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImV4cCI6MTc2MzcxNTA0OCwidHlwZSI6ImFjY2VzcyJ9.GmfU7h4mMUNeh1HZD3T-PRRN_pT8HTxOhDjhzyRvr2U	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImV4cCI6MTc2NDMxODA0OCwidHlwZSI6InJlZnJlc2gifQ.4UoXiqrJBQTKwg7bUi9h0oRXSFJdCDwBZkwsPCghb_E	null	\N	\N	\N	2025-11-21 08:21:31.862149	2025-11-21 13:50:48.184711	2025-11-21 13:50:48.184711
c5205273-ee60-468f-a85a-57ce6e8c79ff	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImV4cCI6MTc2MzcxNDE3MCwidHlwZSI6ImFjY2VzcyJ9.6wrTJPSYljlYFZ758nWqmRTLeTmZSwHfZQnaNvku9pc	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImV4cCI6MTc2NDMxNzE3MCwidHlwZSI6InJlZnJlc2gifQ.aRdmLA5xJ1ZK1RYDNM0-74y3zZCudeD8wVvtHrjhaic	null	\N	\N	\N	2025-11-21 08:21:31.862132	2025-11-21 13:36:10.200456	2025-11-21 13:36:10.200456
c910e950-0630-4cbf-8d63-afea57dc32a0	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImV4cCI6MTc2MzcxNTA1NiwidHlwZSI6ImFjY2VzcyJ9.yuQ5vf1060ii3FbygsCL1KmJ35yNfiAfv3r2PeyewKY	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImV4cCI6MTc2NDMxODA1NiwidHlwZSI6InJlZnJlc2gifQ.I3JzUdopxgsbSF_kQ8G2cb474xU8RoJOKlJkTMRA90k	null	\N	\N	\N	2025-11-21 08:21:31.862151	2025-11-21 13:50:56.210019	2025-11-21 13:50:56.210019
d897cce4-cf01-4f8c-9e49-7fb2deb8be45	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImV4cCI6MTc2MzcxNTA1NSwidHlwZSI6ImFjY2VzcyJ9.Tjjy1QVZrScb6bFhT-HTSOGZ3sthIi8_77DeHs2krSI	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImV4cCI6MTc2NDMxODA1NSwidHlwZSI6InJlZnJlc2gifQ.BNhJHkgGoyhDZq8bn7VGZzAaWt0LfSleMR384XAxJv4	null	\N	\N	\N	2025-11-21 08:21:31.86215	2025-11-21 13:50:55.097345	2025-11-21 13:50:55.097345
f62951f4-567c-4dc3-8ed5-ee9e15907a02	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImV4cCI6MTc2MzcxNTA5MiwidHlwZSI6ImFjY2VzcyJ9.Kz6RICCQz1LSov3DcHMQp3M7jwL4pPJ6GTbJmX1zmKA	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImV4cCI6MTc2NDMxODA5MiwidHlwZSI6InJlZnJlc2gifQ.ftzSwHsxrI25fEeiyRc68J3SqBry3w_HzXtgDrZZBVk	null	\N	\N	\N	2025-11-21 08:21:31.862153	2025-11-21 13:51:32.526582	2025-11-21 13:51:32.526582
4672c162-11b1-4823-ac87-3a75456b3c26	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImV4cCI6MTc2MzcxNTEyNCwidHlwZSI6ImFjY2VzcyJ9.3ghYX3-a99SVe5teTIwEQUgi6v83jpvMBx7Pjm35syo	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImV4cCI6MTc2NDMxODEyNCwidHlwZSI6InJlZnJlc2gifQ.bFwuCff6wJu4lsC8RplLP08KuVI3lFEe3wjXqoMmRkU	null	\N	\N	\N	2025-11-21 08:22:03.823107	2025-11-21 13:52:04.478042	2025-11-21 13:52:04.478042
cff3b0f5-c998-43f6-af80-92f6dfbd72de	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzE3OTQzLCJ0eXBlIjoiYWNjZXNzIn0.QyERyDyZoKoBAoSmL84oWxDF21xoVb-YeYQcXqHHcW4	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzIwOTQzLCJ0eXBlIjoicmVmcmVzaCJ9.8Xhcj7hjQBNIyzbsLsD2eBAYKOpd1HD1ZAPJ3vEqwRo	null	\N	\N	\N	2025-11-21 09:39:03.415959	2025-11-21 14:39:03.396079	2025-11-21 14:39:03.396079
caa9d990-40f4-4dca-bd32-bb2b5ababab2	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzIzODg2LCJ0eXBlIjoiYWNjZXNzIn0.KjkKtRAEAPS6xgAw4daWYiM8VEXvpeRAvzFp9QRjCfA	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI2ODg2LCJ0eXBlIjoicmVmcmVzaCJ9.4kT9AByr4EcfmtDZ7Lhhxr9fUh12BQ3i5yqZNFbPTfE	null	\N	\N	\N	2025-11-21 11:18:06.353424	2025-11-21 16:18:06.340676	2025-11-21 16:18:06.340676
584d65a0-1680-4995-8818-a2bd3815124c	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI0MTQzLCJ0eXBlIjoiYWNjZXNzIn0.2F0F6RJp-dNB9nq_WOjbprYOGrO6EZnPlL2ZntmjpXw	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI3MTQzLCJ0eXBlIjoicmVmcmVzaCJ9.2_iwl8ULAdO3HWt39Q2qTuB2tBcHqdEFDRwtBgxYDaQ	null	\N	\N	\N	2025-11-21 11:22:23.156669	2025-11-21 16:22:22.852157	2025-11-21 16:22:22.852157
f706da0f-37c3-4a3e-bf4a-5af69ead38be	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTIiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjExIiwicm9sZSI6InBvbGljeWhvbGRlciIsImVtYWlsIjoiY3VzdG9tZXIxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI0MTQ5LCJ0eXBlIjoiYWNjZXNzIn0.8s7zC5KPICB7Ipr1w-Z4YRi1mW3em6ZxnLznQAqyR14	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTIiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjExIiwicm9sZSI6InBvbGljeWhvbGRlciIsImVtYWlsIjoiY3VzdG9tZXIxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI3MTQ5LCJ0eXBlIjoicmVmcmVzaCJ9.T5de0Bqvr9ToLjuR4DNyo_yTTmOvyWevWkCMt7Ps_rI	null	\N	\N	\N	2025-11-21 11:22:29.583396	2025-11-21 16:22:29.294631	2025-11-21 16:22:29.294631
8a00ff76-520e-4862-925e-d83e317192cc	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI0MzgxLCJ0eXBlIjoiYWNjZXNzIn0.u6YyezwcPxnMk2EW4PFXsBEaU9_phBkkPwKMqxWydXY	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI3MzgxLCJ0eXBlIjoicmVmcmVzaCJ9.NNsutx-0c11t2MDWG-Xnap9qiBBc39FwrzJJ3XmGCtI	null	\N	\N	\N	2025-11-21 11:26:21.111638	2025-11-21 16:26:20.816202	2025-11-21 16:26:20.816202
2ade3e25-d9fe-4e30-a69c-029d81936d7b	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI0MzkzLCJ0eXBlIjoiYWNjZXNzIn0.QDtVL3kdOzhqf3PVauSJd8MFqHBNt0fIFyolrNPEI_Y	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI3MzkzLCJ0eXBlIjoicmVmcmVzaCJ9.qhDbbVdeu18PmrBkN8DnodP1ok3pVLXXIij0N6PCQZo	null	\N	\N	\N	2025-11-21 11:26:33.790395	2025-11-21 16:26:33.49981	2025-11-21 16:26:33.49981
68485bfa-a9e1-437b-b5e9-6c11ec281514	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI0NDAzLCJ0eXBlIjoiYWNjZXNzIn0.eChCDl6MN_K-F92lld3eN_mc0eu4POUalj7NicjtI8s	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI3NDAzLCJ0eXBlIjoicmVmcmVzaCJ9.FdZ2W5JCxiUwtPsNhNm4X3mPUNUMLsMjCj-mpCSpgZI	null	\N	\N	\N	2025-11-21 11:26:43.989295	2025-11-21 16:26:43.697711	2025-11-21 16:26:43.697711
bf507ce4-7e9d-41e3-919a-673d358cfe44	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI0NDE3LCJ0eXBlIjoiYWNjZXNzIn0.zLyXI3fU1TPe4G5YO32eehIoy3Zy4h1NB11UAHmN6nk	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI3NDE3LCJ0eXBlIjoicmVmcmVzaCJ9.Zs5_p7ztz6F0CR6ZWn9kSAY8Q_aDQ6_SAipB5T4qLe8	null	\N	\N	\N	2025-11-21 11:26:57.742757	2025-11-21 16:26:57.449004	2025-11-21 16:26:57.449004
b60b5d67-d11f-4b00-8ac0-869b94306165	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI0NDI1LCJ0eXBlIjoiYWNjZXNzIn0.io-MLTFeyaq_XzmHX4z5ios_Pleqzx_-O4Fl1XB8_Gw	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI3NDI1LCJ0eXBlIjoicmVmcmVzaCJ9.C8LvvxApvkxaI7xiTbuhUeD3jcAwcx7pgpX9g4Kjs3A	null	\N	\N	\N	2025-11-21 11:27:05.942484	2025-11-21 16:27:05.652536	2025-11-21 16:27:05.652536
c33821f1-de1e-4ef4-9c31-b5b893ea366b	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI0NDQzLCJ0eXBlIjoiYWNjZXNzIn0.nBogdpSpZd3s7ql3-duCzRR32vrqzu4TeC6RgtqBBTo	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI3NDQzLCJ0eXBlIjoicmVmcmVzaCJ9.Lwbi9IvgewuyqCL_slJvZzom7bQnF0qP8OSjiGHCGSA	null	\N	\N	\N	2025-11-21 11:27:23.483351	2025-11-21 16:27:23.18867	2025-11-21 16:27:23.18867
a17b35f8-d5db-4a89-965b-0474e5ae933b	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI0NDcwLCJ0eXBlIjoiYWNjZXNzIn0.gVEadmkahAlBN5ex96GhBhokWtnYbqeJ_O-PBZnGta0	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI3NDcwLCJ0eXBlIjoicmVmcmVzaCJ9.Uoz-qrzwKm50IbtwMjU27rXDy9d1LRqumQnoa-L1qfA	null	\N	\N	\N	2025-11-21 11:27:50.889919	2025-11-21 16:27:50.598776	2025-11-21 16:27:50.598776
49258b02-5554-4b86-a77e-0d4578a593f0	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI0NTAxLCJ0eXBlIjoiYWNjZXNzIn0.bGTMK8asytZnjzVeHKTBSffCz1QfM6YDTPIwQd4oG50	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI3NTAxLCJ0eXBlIjoicmVmcmVzaCJ9.h7CIyph2pK5JnfO5dOZUvYgBaZNMbou8EkDKYZLEsjU	null	\N	\N	\N	2025-11-21 11:28:21.518079	2025-11-21 16:28:21.228435	2025-11-21 16:28:21.228435
dd977d92-f453-4d45-a694-7efca09c4426	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI0NTE3LCJ0eXBlIjoiYWNjZXNzIn0.y8Z66lBP4uDUMJCPmTW4EbfI87ieN1qM79_bmElw2bw	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI3NTE3LCJ0eXBlIjoicmVmcmVzaCJ9.aFN5btj-Y5nttgy6V-ofp9hPSWEpMG25WEViliFwGAA	null	\N	\N	\N	2025-11-21 11:28:37.724937	2025-11-21 16:28:37.434398	2025-11-21 16:28:37.434398
902ad7a4-b9d8-4984-806a-3c4247125edd	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI0ODIyLCJ0eXBlIjoiYWNjZXNzIn0._DBSu9Ukcb33Sg_7ymYKuGtOKQHR-KbFW3sT1HXOQMM	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI3ODIyLCJ0eXBlIjoicmVmcmVzaCJ9.Tme7Xy1YZKB1ymnyivapxcy3lRoMxVohifqbPCGWG_E	null	\N	\N	\N	2025-11-21 11:33:42.550286	2025-11-21 16:33:42.251284	2025-11-21 16:33:42.251284
a94fdd7d-d9ba-4946-a913-8c5bd2119de2	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI0ODg1LCJ0eXBlIjoiYWNjZXNzIn0.AIMgfV2V_bPzmcPT4FDQHvp27zfoywKclYxno_pX2Fw	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI3ODg1LCJ0eXBlIjoicmVmcmVzaCJ9.g_yMP9SgPGgMt50a29MohQzNhdaNCI1sCu9QzNbCFjw	null	\N	\N	\N	2025-11-21 11:34:45.134105	2025-11-21 16:34:44.832496	2025-11-21 16:34:44.832496
444b8429-3bf5-4886-a176-ea75d7ecc3ef	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI1MDI1LCJ0eXBlIjoiYWNjZXNzIn0.MYZzmEJoCLi-ra_Jo-_UWFYMFqrojYUMqe-gi22k58w	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI4MDI1LCJ0eXBlIjoicmVmcmVzaCJ9.azdpHbIhwH8SxHPou2YvOUVCj2rtJROLn_m0jMgroVk	null	\N	\N	\N	2025-11-21 11:37:05.346842	2025-11-21 16:37:05.053512	2025-11-21 16:37:05.053512
bca0b579-93a6-44c1-88d8-3f2b5a5b5dc1	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI1NTM3LCJ0eXBlIjoiYWNjZXNzIn0.tseF5za3PS_Lpp0sagDXggW7UhMWrmNjNX2TxXyrIZE	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI4NTM3LCJ0eXBlIjoicmVmcmVzaCJ9.TB61MUH5hzm7ThR1TeOBeAoMNjPSuAd-VU8GOGOBHxQ	null	\N	\N	\N	2025-11-21 11:45:37.646946	2025-11-21 16:45:37.634096	2025-11-21 16:45:37.634096
0f027df9-600b-499e-b20b-713c1be80ce5	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI1NTQzLCJ0eXBlIjoiYWNjZXNzIn0.Dnmjt1zJWVt7aW83vSlTU06rJluI_ADAYBWM3_CinXA	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI4NTQzLCJ0eXBlIjoicmVmcmVzaCJ9.sDrYmsY0s1X2XdSjq2pI1F6aOya_SGkmB_gUyjzvFVA	null	\N	\N	\N	2025-11-21 11:45:43.373463	2025-11-21 16:45:43.082527	2025-11-21 16:45:43.082527
7e38ffbd-f190-4062-b77b-1a3176848004	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI1NTc0LCJ0eXBlIjoiYWNjZXNzIn0.2UX-Xbi7yJR43M3rpjjGo3cTrPwB1cVINWCK4LQxHv8	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI4NTc0LCJ0eXBlIjoicmVmcmVzaCJ9.1wXIQRSRdJpeAiAtxLW0ZhYlk7za33ZdTC53tH2i3K0	null	\N	\N	\N	2025-11-21 11:46:14.279267	2025-11-21 16:46:14.274093	2025-11-21 16:46:14.274093
4f2f7845-fad5-4a39-80cf-5ec35778aeb1	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI1NjA5LCJ0eXBlIjoiYWNjZXNzIn0.7M3Uzw-ozUY-JjC8P6dfkjmBJt6sI_S-GLVajMPh1Oc	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI4NjA5LCJ0eXBlIjoicmVmcmVzaCJ9.KCqLKOYTL_4B5nAVjrw1T0fIK25SeYqJeYkNvseLZMM	null	\N	\N	\N	2025-11-21 11:46:49.0137	2025-11-21 16:46:49.008033	2025-11-21 16:46:49.008033
df0254c0-4fb8-4de6-bf68-a6eb87020e1b	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI1NjE4LCJ0eXBlIjoiYWNjZXNzIn0.uw0KVr9z4U6We6F8XM9mUm57MD2vVEIb9a6kDuEZR7s	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI4NjE4LCJ0eXBlIjoicmVmcmVzaCJ9.ZpscR5uoRz6k9Yhx8bygO3FH9I1DejQ1H7Qjw95Rukc	null	\N	\N	\N	2025-11-21 11:46:58.612426	2025-11-21 16:46:58.606892	2025-11-21 16:46:58.606892
d00cc86a-68ee-4daf-bdb7-18502bedb6d6	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI1NjI4LCJ0eXBlIjoiYWNjZXNzIn0.uEwvnXnDfGDa3pWmd4Z2mk4SVWET_c322EnKAa1p3MY	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzI4NjI4LCJ0eXBlIjoicmVmcmVzaCJ9.e6ef1J2BF-8-CAdMo8-L0ukLXVTm9-SXvS_Atzpp-QE	null	\N	\N	\N	2025-11-21 11:47:08.570003	2025-11-21 16:47:08.564156	2025-11-21 16:47:08.564156
601c65ab-710d-4db4-9349-ffe857dabcde	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzYzNzI3MzE2LCJ0eXBlIjoiYWNjZXNzIn0.xu3n6sNTyd8Yo_Acw_zbIF57k0oSnBt3-BAR-0KTpnQ	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMGVlYmM5OS05YzBiLTRlZjgtYmI2ZC02YmI5YmQzODBhMTEiLCJwaG9uZV9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwicm9sZSI6Imp1bmlvcl9hZ2VudCIsImVtYWlsIjoiYWdlbnQxQHRlc3QuY29tIiwiZXhwIjoxNzY0MzMwMzE2LCJ0eXBlIjoicmVmcmVzaCJ9.Z1nHUhYILOMmS8Jw-PavUv62LMlyLA6Havrf25DCzEA	null	\N	\N	\N	2025-11-21 12:15:16.481139	2025-11-21 17:15:16.451075	2025-11-21 17:15:16.451075
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.users (user_id, tenant_id, email, phone_number, username, password_hash, password_salt, password_changed_at, first_name, last_name, display_name, avatar_url, date_of_birth, gender, address, emergency_contact, language_preference, timezone, theme_preference, notification_preferences, email_verified, phone_verified, email_verification_token, email_verification_expires, password_reset_token, password_reset_expires, mfa_enabled, mfa_secret, biometric_enabled, last_login_at, login_attempts, locked_until, role, status, trial_end_date, subscription_plan, subscription_status, created_by, created_at, updated_by, updated_at, deactivated_at, deactivated_reason) FROM stdin;
a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	00000000-0000-0000-0000-000000000000	customer2@test.com	+919876543212	\N	$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO	\N	\N	Test	Customer2	Test Customer Two	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	f	f	\N	\N	\N	\N	f	\N	f	\N	0	\N	policyholder	active	\N	\N	trial	\N	2025-11-21 13:31:29.74132	\N	2025-11-21 13:31:29.74132	\N	\N
a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	00000000-0000-0000-0000-000000000000	customer1@test.com	+919876543211	\N	$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO	\N	\N	Test	Customer	Test Customer One	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	f	t	\N	\N	\N	\N	f	\N	f	2025-11-21 10:52:29.60217	0	\N	policyholder	active	\N	\N	trial	\N	2025-11-21 13:31:29.74132	\N	2025-11-21 16:22:29.598699	\N	\N
c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a20	00000000-0000-0000-0000-000000000000	senior_agent@test.com	+919876543220	\N	$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO	\N	\N	Senior	Agent	Senior Agent	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	f	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	senior_agent	active	\N	\N	trial	\N	2025-11-21 16:44:52.454925	\N	2025-11-21 16:44:52.454925	\N	\N
c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21	00000000-0000-0000-0000-000000000000	regional_manager@test.com	+919876543221	\N	$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO	\N	\N	Regional	Manager	Regional Manager	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	f	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	regional_manager	active	\N	\N	trial	\N	2025-11-21 16:44:52.454925	\N	2025-11-21 16:44:52.454925	\N	\N
c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22	00000000-0000-0000-0000-000000000000	provider_admin@test.com	+919876543222	\N	$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO	\N	\N	Provider	Admin	Provider Admin	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	f	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	insurance_provider_admin	active	\N	\N	trial	\N	2025-11-21 16:44:52.454925	\N	2025-11-21 16:44:52.454925	\N	\N
c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23	00000000-0000-0000-0000-000000000000	customer3@test.com	+919876543223	\N	$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO	\N	\N	Customer	Three	Customer Three	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	f	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	policyholder	active	\N	\N	trial	\N	2025-11-21 16:44:52.454925	\N	2025-11-21 16:44:52.454925	\N	\N
c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a24	00000000-0000-0000-0000-000000000000	customer4@test.com	+919876543224	\N	$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO	\N	\N	Customer	Four	Customer Four	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	f	t	\N	\N	\N	\N	f	\N	f	\N	0	\N	policyholder	active	\N	\N	trial	\N	2025-11-21 16:44:52.454925	\N	2025-11-21 16:44:52.454925	\N	\N
a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	00000000-0000-0000-0000-000000000000	agent1@test.com	+919876543210	\N	$2b$12$XDz4mpAyOaN9Q1YcgjTOmOAltObOtHpvVOzm9XuiDCg.wPyT4TGHO	\N	\N	Updated	Agent	Test Agent One	\N	\N	\N	\N	\N	hi	Asia/Kolkata	light	\N	f	t	\N	\N	\N	\N	f	\N	f	2025-11-21 11:45:16.497729	0	\N	junior_agent	active	\N	\N	trial	\N	2025-11-21 13:31:29.74132	\N	2025-11-21 17:15:16.495571	\N	\N
28fd9d71-b452-45a0-8812-491c1a7464cc	00000000-0000-0000-0000-000000000000	\N	+919876543299	\N		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	en	Asia/Kolkata	light	\N	f	f	\N	\N	\N	\N	f	\N	f	\N	0	\N	policyholder	active	\N	\N	trial	\N	2025-11-21 16:46:14.969894	\N	2025-11-21 16:46:14.969894	\N	\N
\.


--
-- Data for Name: video_content; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.video_content (video_id, agent_id, title, description, video_url, thumbnail_url, duration_seconds, category, tags, language, difficulty_level, target_audience, view_count, unique_viewers, avg_watch_time, completion_rate, engagement_rate, average_rating, total_ratings, featured, status, moderation_status, moderated_at, moderated_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: whatsapp_messages; Type: TABLE DATA; Schema: lic_schema; Owner: agentmitra
--

COPY lic_schema.whatsapp_messages (message_id, whatsapp_message_id, sender_id, recipient_id, agent_id, message_type, content, media_url, media_type, whatsapp_template_id, whatsapp_template_name, whatsapp_status, conversation_id, message_sequence, is_from_customer, sent_at, delivered_at, read_at, created_at) FROM stdin;
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
\.


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
-- Name: data_export_log data_export_log_pkey; Type: CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.data_export_log
    ADD CONSTRAINT data_export_log_pkey PRIMARY KEY (export_id);


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
-- Name: idx_customer_behavior_customer; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_customer_behavior_customer ON lic_schema.customer_behavior_metrics USING btree (customer_id, metric_date DESC);


--
-- Name: idx_customer_behavior_date; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_customer_behavior_date ON lic_schema.customer_behavior_metrics USING btree (metric_date DESC);


--
-- Name: idx_daily_kpis_date; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_daily_kpis_date ON lic_schema.daily_dashboard_kpis USING btree (report_date);


--
-- Name: idx_data_export_user; Type: INDEX; Schema: lic_schema; Owner: agentmitra
--

CREATE INDEX idx_data_export_user ON lic_schema.data_export_log USING btree (user_id, created_at DESC);


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
    ADD CONSTRAINT agents_provider_id_fkey FOREIGN KEY (provider_id) REFERENCES shared.insurance_providers(provider_id);


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
-- Name: data_export_log data_export_log_user_id_fkey; Type: FK CONSTRAINT; Schema: lic_schema; Owner: agentmitra
--

ALTER TABLE ONLY lic_schema.data_export_log
    ADD CONSTRAINT data_export_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id);


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

\unrestrict ZddoH5SNZeecvmjfyH39Ik5UilB5ZQzDkv67dF43XPUOhC5l2fpCU6R5YLXkyRS

