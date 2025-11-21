-- Agent Mitra - Migration V3: Create LIC Schema Tables
-- This migration creates all core business tables in lic_schema

-- =====================================================
-- ENUMS
-- =====================================================

-- User roles enumeration
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

-- User status enumeration
CREATE TYPE lic_schema.user_status_enum AS ENUM (
    'active',
    'inactive',
    'suspended',
    'pending_verification',
    'deactivated'
);

-- Agent status enumeration
CREATE TYPE lic_schema.agent_status_enum AS ENUM (
    'active',
    'inactive',
    'suspended',
    'pending_approval',
    'rejected'
);

-- Policy status enumeration
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

-- Payment status enumeration
CREATE TYPE lic_schema.payment_status_enum AS ENUM (
    'pending',
    'processing',
    'completed',
    'failed',
    'refunded',
    'cancelled'
);

-- =====================================================
-- USER MANAGEMENT & AUTHENTICATION
-- =====================================================

-- Multi-tenant users table (schema-based)
CREATE TABLE lic_schema.users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000', -- Fixed for schema isolation
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(15) UNIQUE,
    username VARCHAR(100) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    password_salt VARCHAR(255),
    password_changed_at TIMESTAMP,

    -- Profile information
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    display_name VARCHAR(255),
    avatar_url VARCHAR(500),
    date_of_birth DATE,
    gender VARCHAR(20),

    -- Contact details
    address JSONB, -- Structured address data
    emergency_contact JSONB,

    -- Account settings
    language_preference VARCHAR(10) DEFAULT 'en',
    timezone VARCHAR(50) DEFAULT 'Asia/Kolkata',
    theme_preference VARCHAR(20) DEFAULT 'light',
    notification_preferences JSONB,

    -- Authentication
    email_verified BOOLEAN DEFAULT false,
    phone_verified BOOLEAN DEFAULT false,
    email_verification_token VARCHAR(255),
    email_verification_expires TIMESTAMP,
    password_reset_token VARCHAR(255),
    password_reset_expires TIMESTAMP,

    -- Security
    mfa_enabled BOOLEAN DEFAULT false,
    mfa_secret VARCHAR(255),
    biometric_enabled BOOLEAN DEFAULT false,
    last_login_at TIMESTAMP,
    login_attempts INTEGER DEFAULT 0,
    locked_until TIMESTAMP,

    -- Account status
    role lic_schema.user_role_enum NOT NULL,
    status lic_schema.user_status_enum DEFAULT 'active',
    trial_end_date TIMESTAMP,
    subscription_plan VARCHAR(50),
    subscription_status VARCHAR(20) DEFAULT 'trial',

    -- Audit fields
    created_by UUID,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_by UUID,
    updated_at TIMESTAMP DEFAULT NOW(),
    deactivated_at TIMESTAMP,
    deactivated_reason TEXT
);

-- User sessions with Redis backup
CREATE TABLE lic_schema.user_sessions (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    refresh_token VARCHAR(255) UNIQUE,
    device_info JSONB,
    ip_address INET,
    user_agent TEXT,
    location_info JSONB,
    expires_at TIMESTAMP NOT NULL,
    last_activity_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Roles definition
CREATE TABLE lic_schema.roles (
    role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_name VARCHAR(100) UNIQUE NOT NULL,
    role_description TEXT,
    is_system_role BOOLEAN DEFAULT false,
    permissions JSONB, -- Array of permission strings
    created_at TIMESTAMP DEFAULT NOW()
);

-- User role assignments
CREATE TABLE lic_schema.user_roles (
    assignment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    role_id UUID REFERENCES lic_schema.roles(role_id) ON DELETE CASCADE,
    assigned_by UUID REFERENCES lic_schema.users(user_id),
    assigned_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP,
    UNIQUE(user_id, role_id)
);

-- Permissions granular control
CREATE TABLE lic_schema.permissions (
    permission_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    permission_name VARCHAR(100) UNIQUE NOT NULL,
    permission_description TEXT,
    resource_type VARCHAR(50), -- 'user', 'policy', 'campaign', etc.
    action VARCHAR(50), -- 'create', 'read', 'update', 'delete', 'admin'
    created_at TIMESTAMP DEFAULT NOW()
);

-- Role permission assignments
CREATE TABLE lic_schema.role_permissions (
    assignment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id UUID REFERENCES lic_schema.roles(role_id) ON DELETE CASCADE,
    permission_id UUID REFERENCES lic_schema.permissions(permission_id) ON DELETE CASCADE,
    granted_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(role_id, permission_id)
);

-- =====================================================
-- INSURANCE DOMAIN TABLES
-- =====================================================

-- Insurance agents
CREATE TABLE lic_schema.agents (
    agent_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    provider_id UUID REFERENCES shared.insurance_providers(provider_id),

    -- Agent identification
    agent_code VARCHAR(50) UNIQUE NOT NULL,
    license_number VARCHAR(100) UNIQUE,
    license_expiry_date DATE,
    license_issuing_authority VARCHAR(100),

    -- Business information
    business_name VARCHAR(255),
    business_address JSONB,
    gst_number VARCHAR(15),
    pan_number VARCHAR(10),

    -- Operational details
    territory VARCHAR(255),
    operating_regions TEXT[],
    experience_years INTEGER,
    specializations TEXT[],

    -- Commission structure
    commission_rate DECIMAL(5,2), -- Base commission percentage
    commission_structure JSONB, -- Complex commission rules
    performance_bonus_structure JSONB,

    -- Communication
    whatsapp_business_number VARCHAR(15),
    business_email VARCHAR(255),
    website VARCHAR(500),

    -- Performance metrics
    total_policies_sold INTEGER DEFAULT 0,
    total_premium_collected DECIMAL(15,2) DEFAULT 0,
    active_policyholders INTEGER DEFAULT 0,
    customer_satisfaction_score DECIMAL(3,2),

    -- Hierarchy (for agent networks)
    parent_agent_id UUID REFERENCES lic_schema.agents(agent_id),
    hierarchy_level INTEGER DEFAULT 1,
    sub_agents_count INTEGER DEFAULT 0,

    -- Status
    status lic_schema.agent_status_enum DEFAULT 'active',
    verification_status VARCHAR(50) DEFAULT 'pending',
    approved_at TIMESTAMP,
    approved_by UUID REFERENCES lic_schema.users(user_id),

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Policyholder profiles
CREATE TABLE lic_schema.policyholders (
    policyholder_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    agent_id UUID REFERENCES lic_schema.agents(agent_id),

    -- Personal information
    customer_id VARCHAR(100), -- Provider-specific customer ID
    salutation VARCHAR(10),
    marital_status VARCHAR(20),
    occupation VARCHAR(100),
    annual_income DECIMAL(12,2),
    education_level VARCHAR(50),

    -- Risk profile and preferences
    risk_profile JSONB, -- Risk tolerance, investment preferences
    investment_horizon VARCHAR(20),
    communication_preferences JSONB, -- Email, SMS, WhatsApp preferences
    marketing_consent BOOLEAN DEFAULT true,

    -- Family information
    family_members JSONB, -- Spouse, children, dependents
    nominee_details JSONB,

    -- Financial information
    bank_details JSONB, -- Encrypted sensitive data
    investment_portfolio JSONB,

    -- Behavioral data
    preferred_contact_time VARCHAR(20), -- 'morning', 'afternoon', 'evening'
    preferred_language VARCHAR(10) DEFAULT 'en',
    digital_literacy_score INTEGER, -- 1-10 scale
    engagement_score DECIMAL(3,2), -- Calculated engagement metric

    -- Status and lifecycle
    onboarding_status VARCHAR(50) DEFAULT 'completed',
    churn_risk_score DECIMAL(3,2),
    last_interaction_at TIMESTAMP,
    total_interactions INTEGER DEFAULT 0,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Insurance policies (core business entity)
CREATE TABLE lic_schema.insurance_policies (
    policy_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_number VARCHAR(100) UNIQUE NOT NULL,
    provider_policy_id VARCHAR(100), -- Provider's internal ID

    -- Relationships
    policyholder_id UUID REFERENCES lic_schema.policyholders(policyholder_id),
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    provider_id UUID REFERENCES shared.insurance_providers(provider_id),

    -- Policy details
    policy_type VARCHAR(100) NOT NULL, -- 'term_life', 'whole_life', 'ulip', etc.
    plan_name VARCHAR(255) NOT NULL,
    plan_code VARCHAR(50),
    category VARCHAR(50), -- 'life', 'health', 'general'

    -- Financial details
    sum_assured DECIMAL(15,2) NOT NULL,
    premium_amount DECIMAL(12,2) NOT NULL,
    premium_frequency VARCHAR(20) NOT NULL, -- 'monthly', 'quarterly', 'half_yearly', 'annual'
    premium_mode VARCHAR(20), -- 'regular', 'single', 'limited_pay'

    -- Dates
    application_date DATE NOT NULL,
    approval_date DATE,
    start_date DATE NOT NULL,
    maturity_date DATE,
    renewal_date DATE,

    -- Status and lifecycle
    status lic_schema.policy_status_enum DEFAULT 'pending_approval',
    sub_status VARCHAR(50), -- 'under_review', 'medical_check', 'approved', etc.
    payment_status VARCHAR(50) DEFAULT 'pending',

    -- Coverage details
    coverage_details JSONB, -- Riders, additional benefits
    exclusions JSONB,
    terms_and_conditions JSONB,

    -- Documents
    policy_document_url VARCHAR(500),
    application_form_url VARCHAR(500),
    medical_reports JSONB,

    -- Beneficiaries
    nominee_details JSONB,
    assignee_details JSONB,

    -- Audit and tracking
    created_by UUID REFERENCES lic_schema.users(user_id),
    approved_by UUID REFERENCES lic_schema.users(user_id),
    last_payment_date TIMESTAMP,
    next_payment_date TIMESTAMP,
    total_payments INTEGER DEFAULT 0,
    outstanding_amount DECIMAL(12,2) DEFAULT 0,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- PAYMENT & TRANSACTION MANAGEMENT
-- =====================================================

-- Premium payment transactions
CREATE TABLE lic_schema.premium_payments (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_id UUID REFERENCES lic_schema.insurance_policies(policy_id),
    policyholder_id UUID REFERENCES lic_schema.policyholders(policyholder_id),

    -- Payment details
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    payment_date TIMESTAMP DEFAULT NOW(),
    due_date TIMESTAMP,
    grace_period_days INTEGER DEFAULT 30,

    -- Payment method
    payment_method VARCHAR(50), -- 'upi', 'net_banking', 'credit_card', etc.
    payment_gateway VARCHAR(50), -- 'razorpay', 'paytm', 'phonepe'
    gateway_transaction_id VARCHAR(255),
    gateway_response JSONB,

    -- Status tracking
    status lic_schema.payment_status_enum DEFAULT 'pending',
    failure_reason TEXT,
    retry_count INTEGER DEFAULT 0,

    -- Reconciliation
    reconciled BOOLEAN DEFAULT false,
    reconciled_at TIMESTAMP,
    reconciled_by UUID REFERENCES lic_schema.users(user_id),

    -- Additional metadata
    ip_address INET,
    user_agent TEXT,
    device_info JSONB,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- User payment methods
CREATE TABLE lic_schema.user_payment_methods (
    payment_method_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,

    -- Method details
    method_type VARCHAR(50) NOT NULL, -- 'credit_card', 'debit_card', 'upi', 'net_banking'
    method_name VARCHAR(100), -- 'HDFC Credit Card', 'Paytm UPI'
    is_default BOOLEAN DEFAULT false,

    -- Card details (encrypted)
    card_number_encrypted TEXT,
    card_holder_name VARCHAR(255),
    expiry_month INTEGER,
    expiry_year INTEGER,
    cvv_encrypted TEXT,

    -- UPI/Net Banking details
    upi_id VARCHAR(255),
    bank_account_number_encrypted TEXT,
    bank_ifsc_code VARCHAR(11),
    bank_name VARCHAR(100),

    -- Status and security
    status VARCHAR(20) DEFAULT 'active',
    verification_status VARCHAR(50) DEFAULT 'pending',
    last_used_at TIMESTAMP,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- COMMUNICATION & CONTENT MANAGEMENT
-- =====================================================

-- WhatsApp message logs
CREATE TABLE lic_schema.whatsapp_messages (
    message_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    whatsapp_message_id VARCHAR(255) UNIQUE,

    -- Participants
    sender_id UUID REFERENCES lic_schema.users(user_id),
    recipient_id UUID REFERENCES lic_schema.users(user_id),
    agent_id UUID REFERENCES lic_schema.agents(agent_id),

    -- Message content
    message_type VARCHAR(50), -- 'text', 'image', 'document', 'location'
    content TEXT,
    media_url VARCHAR(500),
    media_type VARCHAR(50),

    -- WhatsApp specific
    whatsapp_template_id VARCHAR(255),
    whatsapp_template_name VARCHAR(100),
    whatsapp_status VARCHAR(50), -- 'sent', 'delivered', 'read', 'failed'

    -- Conversation context
    conversation_id UUID,
    message_sequence INTEGER,
    is_from_customer BOOLEAN DEFAULT true,

    -- Timestamps
    sent_at TIMESTAMP,
    delivered_at TIMESTAMP,
    read_at TIMESTAMP,

    created_at TIMESTAMP DEFAULT NOW()
);

-- WhatsApp templates (in shared schema)
CREATE TABLE shared.whatsapp_templates (
    template_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_name VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(50), -- 'marketing', 'utility', 'authentication'
    language VARCHAR(10) DEFAULT 'en',
    content TEXT NOT NULL,
    variables JSONB,
    approval_status VARCHAR(50) DEFAULT 'pending',
    whatsapp_template_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Chatbot conversation sessions
CREATE TABLE lic_schema.chatbot_sessions (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id),
    conversation_id VARCHAR(255),

    -- Session metadata
    started_at TIMESTAMP DEFAULT NOW(),
    ended_at TIMESTAMP,
    duration_seconds INTEGER,
    message_count INTEGER DEFAULT 0,
    resolution_status VARCHAR(50), -- 'resolved', 'escalated', 'abandoned'

    -- AI metrics
    average_response_time DECIMAL(6,2),
    user_satisfaction_score INTEGER, -- 1-5 scale
    escalation_reason TEXT,

    -- Device and context
    device_info JSONB,
    ip_address INET,
    user_agent TEXT
);

-- Individual chat messages
CREATE TABLE lic_schema.chat_messages (
    message_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES lic_schema.chatbot_sessions(session_id),
    user_id UUID REFERENCES lic_schema.users(user_id),

    -- Message content
    message_type VARCHAR(50) DEFAULT 'text', -- 'text', 'button_click', 'file_upload'
    content TEXT,
    is_from_user BOOLEAN DEFAULT true,

    -- AI processing
    intent_detected VARCHAR(100),
    confidence_score DECIMAL(3,2),
    entities_detected JSONB,

    -- Response details
    response_generated TEXT,
    response_time_ms INTEGER,
    suggested_actions JSONB,

    timestamp TIMESTAMP DEFAULT NOW()
);

-- Agent-uploaded video content
CREATE TABLE lic_schema.video_content (
    video_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.agents(agent_id),

    -- Content details
    title VARCHAR(255) NOT NULL,
    description TEXT,
    video_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    duration_seconds INTEGER,

    -- Categorization
    category VARCHAR(100),
    tags TEXT[],
    language VARCHAR(10) DEFAULT 'en',
    difficulty_level VARCHAR(20), -- 'beginner', 'intermediate', 'advanced'
    target_audience TEXT[], -- 'policyholders', 'agents', 'senior_citizens'

    -- Analytics
    view_count INTEGER DEFAULT 0,
    unique_viewers INTEGER DEFAULT 0,
    avg_watch_time DECIMAL(6,2),
    completion_rate DECIMAL(5,2),
    engagement_rate DECIMAL(5,2),

    -- Ratings and feedback
    average_rating DECIMAL(3,2),
    total_ratings INTEGER DEFAULT 0,
    featured BOOLEAN DEFAULT false,

    -- Status and moderation
    status VARCHAR(50) DEFAULT 'processing', -- 'processing', 'published', 'rejected'
    moderation_status VARCHAR(50) DEFAULT 'pending',
    moderated_at TIMESTAMP,
    moderated_by UUID REFERENCES lic_schema.users(user_id),

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- INDEXES
-- =====================================================

-- User indexes
CREATE INDEX idx_users_tenant_status ON lic_schema.users(tenant_id, status);
CREATE INDEX idx_users_email ON lic_schema.users(email) WHERE email IS NOT NULL;
CREATE INDEX idx_users_phone ON lic_schema.users(phone_number) WHERE phone_number IS NOT NULL;
CREATE INDEX idx_users_created_at ON lic_schema.users(created_at DESC);

-- Agent indexes
CREATE INDEX idx_agents_user_status ON lic_schema.agents(user_id, status);
CREATE INDEX idx_agents_provider ON lic_schema.agents(provider_id);
CREATE INDEX idx_agents_territory ON lic_schema.agents(territory);

-- Policy indexes
CREATE INDEX idx_policies_policyholder_status ON lic_schema.insurance_policies(policyholder_id, status);
CREATE INDEX idx_policies_agent_provider ON lic_schema.insurance_policies(agent_id, provider_id);
CREATE INDEX idx_policies_status_dates ON lic_schema.insurance_policies(status, start_date, maturity_date);

-- Payment indexes
CREATE INDEX idx_payments_policy_status ON lic_schema.premium_payments(policy_id, status);
CREATE INDEX idx_payments_date_amount ON lic_schema.premium_payments(payment_date DESC, amount);

-- Communication indexes
CREATE INDEX idx_whatsapp_messages_agent ON lic_schema.whatsapp_messages(agent_id);
CREATE INDEX idx_chatbot_sessions_user ON lic_schema.chatbot_sessions(user_id);
CREATE INDEX idx_video_content_agent ON lic_schema.video_content(agent_id);

