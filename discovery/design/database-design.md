# Agent Mitra - Comprehensive Database Design

## 1. Database Architecture Overview

### 1.1 Database Philosophy & Principles

#### Multi-Tenant Architecture Strategy
```
🏢 MULTI-TENANT DATABASE DESIGN PHILOSOPHY

🎯 Core Principles:
├── Strong Isolation: Complete data separation between insurance providers
├── Cost Efficiency: Single database instance with smart partitioning
├── Performance: Optimized queries with proper indexing and caching
├── Scalability: Horizontal scaling ready with read replicas
├── Compliance: IRDAI and DPDP compliant with audit trails
└── Maintainability: Clean schema design with proper relationships

📊 Design Decisions:
├── Schema-based tenancy (chosen approach)
├── Row-level security (RLS) for granular access control
├── JSONB fields for flexible data storage
├── Time-based partitioning for analytics data
└── Comprehensive indexing strategy
```

#### Database Technology Stack
```
💾 DATABASE ECOSYSTEM

🗄️ Primary Database:
├── PostgreSQL 15+ (Relational data storage)
├── Aurora PostgreSQL (AWS managed, auto-scaling)
├── PostGIS (Geospatial data support)
└── pgvector (AI/ML vector embeddings)

⚡ Caching & Performance:
├── Redis Cluster (Session storage, API caching)
├── Redis ElastiCache (AWS managed, multi-region)
├── Application-level caching (SQLAlchemy)
└── CDN caching (Static assets)

🔍 Search & Analytics:
├── Elasticsearch (Advanced search capabilities)
├── TimescaleDB (Time-series analytics)
├── ClickHouse (Real-time analytics - future)
└── Custom materialized views (Performance optimization)
```

### 1.2 Database Design Patterns

#### Schema Design Patterns
```sql
-- 1. Multi-tenant schema pattern
CREATE SCHEMA lic_schema AUTHORIZATION agent_mitra;
CREATE SCHEMA hdfc_schema AUTHORIZATION agent_mitra;
CREATE SCHEMA icici_schema AUTHORIZATION agent_mitra;

-- 2. Shared reference schema
CREATE SCHEMA shared AUTHORIZATION agent_mitra;

-- 3. Audit schema for compliance
CREATE SCHEMA audit AUTHORIZATION agent_mitra;
```

#### Data Modeling Patterns
```
📋 DATA MODELING PATTERNS

🔗 Relationship Patterns:
├── One-to-One: User ↔ Profile (Single table preferred)
├── One-to-Many: Agent → Policyholders (Foreign keys)
├── Many-to-Many: Users ↔ Roles (Junction tables)
└── Hierarchical: Agent → Sub-agents (Self-referencing)

📦 Storage Patterns:
├── Normalized: Core business data (3NF)
├── Denormalized: Reporting tables (Performance)
├── JSONB: Flexible attributes (Policy metadata)
└── Arrays: Simple lists (Tags, categories)

🔒 Security Patterns:
├── Row Level Security (RLS)
├── Column encryption (Sensitive data)
├── Audit triggers (Change tracking)
└── Access control (RBAC integration)
```

## 2. Core Database Schema Design

### 2.1 Multi-Tenant Infrastructure Tables

#### Tenant Management
```sql
-- Master tenant registry
CREATE TABLE shared.tenants (
    tenant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_code VARCHAR(20) UNIQUE NOT NULL,
    tenant_name VARCHAR(255) NOT NULL,
    tenant_type VARCHAR(50) NOT NULL, -- 'insurance_provider', 'independent_agent', 'agent_network'
    schema_name VARCHAR(100) UNIQUE,
    parent_tenant_id UUID REFERENCES shared.tenants(tenant_id),
    status VARCHAR(20) DEFAULT 'active',
    subscription_plan VARCHAR(50),
    trial_end_date TIMESTAMP,
    max_users INTEGER DEFAULT 1000,
    storage_limit_gb INTEGER DEFAULT 10,
    api_rate_limit INTEGER DEFAULT 1000,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tenant configuration
CREATE TABLE shared.tenant_config (
    config_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES shared.tenants(tenant_id),
    config_key VARCHAR(100) NOT NULL,
    config_value JSONB,
    config_type VARCHAR(50) DEFAULT 'string', -- 'string', 'number', 'boolean', 'json'
    is_encrypted BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(tenant_id, config_key)
);
```

#### System Reference Data
```sql
-- Countries and regions
CREATE TABLE shared.countries (
    country_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_code VARCHAR(3) UNIQUE NOT NULL, -- ISO 3166-1 alpha-3
    country_name VARCHAR(100) NOT NULL,
    currency_code VARCHAR(3), -- ISO 4217
    phone_code VARCHAR(5),
    timezone VARCHAR(50),
    status VARCHAR(20) DEFAULT 'active'
);

-- Languages supported
CREATE TABLE shared.languages (
    language_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    language_code VARCHAR(10) UNIQUE NOT NULL, -- ISO 639-1
    language_name VARCHAR(100) NOT NULL,
    native_name VARCHAR(100),
    rtl BOOLEAN DEFAULT false, -- Right-to-left
    status VARCHAR(20) DEFAULT 'active'
);

-- Insurance product categories
CREATE TABLE shared.insurance_categories (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_code VARCHAR(20) UNIQUE NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    category_type VARCHAR(50), -- 'life', 'health', 'general', 'motor'
    description TEXT,
    status VARCHAR(20) DEFAULT 'active'
);

-- Data import/export tracking for agent configuration portal
CREATE TABLE shared.data_imports (
    import_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500),
    file_size_bytes BIGINT,
    import_type VARCHAR(50) DEFAULT 'customer_data', -- 'customer_data', 'policy_data', 'bulk_update'
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'failed'
    total_records INTEGER DEFAULT 0,
    processed_records INTEGER DEFAULT 0,
    error_records INTEGER DEFAULT 0,
    error_details JSONB,
    processing_started_at TIMESTAMP,
    processing_completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Import job queue for background processing
CREATE TABLE shared.import_jobs (
    job_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    import_id UUID REFERENCES shared.data_imports(import_id),
    job_type VARCHAR(50) NOT NULL, -- 'validate', 'process', 'cleanup'
    priority INTEGER DEFAULT 1, -- 1=low, 5=high
    status VARCHAR(50) DEFAULT 'queued', -- 'queued', 'processing', 'completed', 'failed'
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    error_message TEXT,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Customer data mapping for Excel imports
CREATE TABLE shared.customer_data_mapping (
    mapping_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    import_id UUID REFERENCES shared.data_imports(import_id),
    excel_row_number INTEGER NOT NULL,
    customer_name VARCHAR(255),
    phone_number VARCHAR(15),
    email VARCHAR(255),
    policy_number VARCHAR(100),
    date_of_birth DATE,
    address JSONB,
    raw_excel_data JSONB, -- Complete row data for reference
    mapping_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'mapped', 'error'
    validation_errors JSONB,
    created_customer_id UUID, -- References created customer record
    created_at TIMESTAMP DEFAULT NOW()
);

-- Data sync status tracking
CREATE TABLE shared.data_sync_status (
    sync_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    customer_id UUID REFERENCES lic_schema.policyholders(policyholder_id),
    last_sync_at TIMESTAMP DEFAULT NOW(),
    sync_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'in_progress', 'completed', 'failed'
    sync_type VARCHAR(50) DEFAULT 'initial', -- 'initial', 'update', 'manual'
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    next_retry_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

### 2.2 User Management & Authentication

#### User Accounts (Multi-tenant)
```sql
-- Multi-tenant users table (schema-based)
CREATE TABLE lic_schema.users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL DEFAULT 'lic-tenant-id', -- Fixed for schema isolation
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
    role user_role_enum NOT NULL,
    status user_status_enum DEFAULT 'active',
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

-- User roles enumeration
CREATE TYPE user_role_enum AS ENUM (
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
CREATE TYPE user_status_enum AS ENUM (
    'active',
    'inactive',
    'suspended',
    'pending_verification',
    'deactivated'
);
```

#### Session Management
```sql
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

-- Session analytics
CREATE TABLE lic_schema.session_analytics (
    analytics_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES lic_schema.user_sessions(session_id),
    user_id UUID REFERENCES lic_schema.users(user_id),
    event_type VARCHAR(50) NOT NULL, -- 'login', 'logout', 'activity', 'error'
    event_data JSONB,
    timestamp TIMESTAMP DEFAULT NOW()
) PARTITION BY RANGE (timestamp);
```

#### Role-Based Access Control (RBAC)
```sql
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
```

### 2.3 Insurance Domain Tables

#### Insurance Providers
```sql
-- Insurance providers (shared across tenants)
CREATE TABLE shared.insurance_providers (
    provider_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_code VARCHAR(20) UNIQUE NOT NULL, -- LIC, HDFC_LIFE, ICICI_PRUDENTIAL
    provider_name VARCHAR(255) NOT NULL,
    provider_type VARCHAR(50), -- 'life_insurance', 'health_insurance', 'general_insurance'
    description TEXT,

    -- API Integration
    api_endpoint VARCHAR(500),
    api_credentials JSONB, -- Encrypted sensitive data
    webhook_url VARCHAR(500),
    webhook_secret VARCHAR(255),

    -- Business details
    license_number VARCHAR(100),
    regulatory_authority VARCHAR(100), -- IRDAI, etc.
    established_year INTEGER,
    headquarters JSONB,

    -- Operational settings
    supported_languages TEXT[] DEFAULT ARRAY['en'],
    business_hours JSONB,
    service_regions TEXT[],
    commission_structure JSONB,

    -- Status and metadata
    status provider_status_enum DEFAULT 'active',
    integration_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'testing', 'active'
    last_sync_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TYPE provider_status_enum AS ENUM ('active', 'inactive', 'suspended', 'under_maintenance');
```

#### Agents & Agency Management
```sql
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
    status agent_status_enum DEFAULT 'active',
    verification_status VARCHAR(50) DEFAULT 'pending',
    approved_at TIMESTAMP,
    approved_by UUID REFERENCES lic_schema.users(user_id),

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TYPE agent_status_enum AS ENUM ('active', 'inactive', 'suspended', 'pending_approval', 'rejected');
```

#### Policyholders (Customers)
```sql
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
```

#### Insurance Policies
```sql
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
    status policy_status_enum DEFAULT 'pending_approval',
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

CREATE TYPE policy_status_enum AS ENUM (
    'draft', 'pending_approval', 'under_review', 'approved', 'active',
    'lapsed', 'surrendered', 'matured', 'claimed', 'cancelled'
);
```

### 2.4 Payment & Transaction Management

#### Premium Payments
```sql
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
    status payment_status_enum DEFAULT 'pending',
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

CREATE TYPE payment_status_enum AS ENUM ('pending', 'processing', 'completed', 'failed', 'refunded', 'cancelled');
```

#### Payment Methods & Wallets
```sql
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
```

### 2.5 Communication & Content Management

#### WhatsApp Integration
```sql
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

-- WhatsApp templates
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
```

#### Chatbot & AI Interactions
```sql
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
```

#### Video Content Management
```sql
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

-- Video watch analytics
CREATE TABLE lic_schema.video_analytics (
    analytics_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    video_id UUID REFERENCES lic_schema.video_content(video_id),
    user_id UUID REFERENCES lic_schema.users(user_id),

    -- Watch session
    watch_session_id UUID,
    started_at TIMESTAMP DEFAULT NOW(),
    ended_at TIMESTAMP,
    watch_duration_seconds INTEGER,

    -- Engagement metrics
    completed BOOLEAN DEFAULT false,
    paused_count INTEGER DEFAULT 0,
    seek_count INTEGER DEFAULT 0,
    quality_changes INTEGER DEFAULT 0,

    -- Device and context
    device_info JSONB,
    network_type VARCHAR(50),
    playback_quality VARCHAR(20)
) PARTITION BY RANGE (started_at);
```

### 2.6 Analytics & Reporting Tables

#### User Behavior Analytics
```sql
-- User behavior events
CREATE TABLE lic_schema.user_events (
    event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id),
    session_id UUID REFERENCES lic_schema.user_sessions(session_id),

    -- Event details
    event_type VARCHAR(100) NOT NULL,
    event_category VARCHAR(50), -- 'navigation', 'interaction', 'conversion', 'error'
    event_action VARCHAR(100),
    event_label VARCHAR(255),

    -- Event data
    event_properties JSONB,
    event_value DECIMAL(10,2),

    -- Context
    page_url VARCHAR(500),
    referrer_url VARCHAR(500),
    device_info JSONB,
    location_info JSONB,

    timestamp TIMESTAMP DEFAULT NOW()
) PARTITION BY RANGE (timestamp);

-- User journey tracking
CREATE TABLE lic_schema.user_journeys (
    journey_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id),

    -- Journey metadata
    journey_type VARCHAR(100), -- 'onboarding', 'policy_purchase', 'claim_process'
    started_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP,
    status VARCHAR(50) DEFAULT 'active',

    -- Journey steps
    current_step INTEGER DEFAULT 1,
    total_steps INTEGER,
    step_history JSONB,

    -- Conversion tracking
    converted BOOLEAN DEFAULT false,
    conversion_value DECIMAL(12,2),
    drop_off_step INTEGER,
    drop_off_reason TEXT
);
```

#### Business Intelligence Tables
```sql
-- Agent performance metrics
CREATE TABLE lic_schema.agent_performance (
    performance_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.agents(agent_id),

    -- Time period
    metric_date DATE NOT NULL,
    metric_period VARCHAR(20) DEFAULT 'daily', -- 'daily', 'weekly', 'monthly'

    -- Core metrics
    policies_sold INTEGER DEFAULT 0,
    premium_collected DECIMAL(15,2) DEFAULT 0,
    new_policyholders INTEGER DEFAULT 0,
    active_policyholders INTEGER DEFAULT 0,

    -- Engagement metrics
    customer_interactions INTEGER DEFAULT 0,
    whatsapp_messages INTEGER DEFAULT 0,
    video_content_views INTEGER DEFAULT 0,
    chatbot_conversations INTEGER DEFAULT 0,

    -- Quality metrics
    customer_satisfaction DECIMAL(3,2),
    response_time_hours DECIMAL(6,2),
    conversion_rate DECIMAL(5,2),

    -- Financial metrics
    commission_earned DECIMAL(12,2) DEFAULT 0,
    expenses DECIMAL(12,2) DEFAULT 0,
    net_profit DECIMAL(12,2) DEFAULT 0,

    created_at TIMESTAMP DEFAULT NOW()
);

-- System health and performance
CREATE TABLE lic_schema.system_metrics (
    metric_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Metric identification
    metric_name VARCHAR(100) NOT NULL,
    metric_category VARCHAR(50), -- 'performance', 'security', 'business'
    metric_type VARCHAR(50), -- 'counter', 'gauge', 'histogram'

    -- Metric data
    metric_value DECIMAL(15,4),
    metric_unit VARCHAR(20),
    metric_tags JSONB,

    -- Time and context
    collection_timestamp TIMESTAMP DEFAULT NOW(),
    collection_interval_seconds INTEGER,

    -- Thresholds
    warning_threshold DECIMAL(15,4),
    critical_threshold DECIMAL(15,4),

    created_at TIMESTAMP DEFAULT NOW()
);
```

## 3. Database Performance & Optimization

### 3.1 Indexing Strategy

#### Primary Indexes
```sql
-- User table indexes
CREATE INDEX CONCURRENTLY idx_users_tenant_status ON lic_schema.users(tenant_id, status);
CREATE INDEX CONCURRENTLY idx_users_email ON lic_schema.users(email) WHERE email IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_users_phone ON lic_schema.users(phone_number) WHERE phone_number IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_users_created_at ON lic_schema.users(created_at DESC);

-- Policy table indexes
CREATE INDEX CONCURRENTLY idx_policies_policyholder_status ON lic_schema.insurance_policies(policyholder_id, status);
CREATE INDEX CONCURRENTLY idx_policies_agent_provider ON lic_schema.insurance_policies(agent_id, provider_id);
CREATE INDEX CONCURRENTLY idx_policies_status_dates ON lic_schema.insurance_policies(status, start_date, maturity_date);
CREATE INDEX CONCURRENTLY idx_policies_premium ON lic_schema.insurance_policies(premium_amount) WHERE status = 'active';

-- Agent table indexes
CREATE INDEX CONCURRENTLY idx_agents_user_status ON lic_schema.agents(user_id, status);
CREATE INDEX CONCURRENTLY idx_agents_provider ON lic_schema.agents(provider_id);
CREATE INDEX CONCURRENTLY idx_agents_territory ON lic_schema.agents(territory);

-- Payment table indexes
CREATE INDEX CONCURRENTLY idx_payments_policy_status ON lic_schema.premium_payments(policy_id, status);
CREATE INDEX CONCURRENTLY idx_payments_date_amount ON lic_schema.premium_payments(payment_date DESC, amount);
CREATE INDEX CONCURRENTLY idx_payments_gateway ON lic_schema.premium_payments(payment_gateway, status);
```

#### Advanced Indexes
```sql
-- Composite indexes for complex queries
CREATE INDEX CONCURRENTLY idx_policies_comprehensive ON lic_schema.insurance_policies(
    provider_id, agent_id, status, premium_amount, maturity_date
) WHERE status IN ('active', 'pending_approval');

-- JSONB indexes for flexible queries
CREATE INDEX CONCURRENTLY idx_users_address_city ON lic_schema.users USING GIN((address->'city'));
CREATE INDEX CONCURRENTLY idx_policies_coverage_riders ON lic_schema.insurance_policies USING GIN(coverage_details);
CREATE INDEX CONCURRENTLY idx_user_events_properties ON lic_schema.user_events USING GIN(event_properties);

-- Partial indexes for specific use cases
CREATE INDEX CONCURRENTLY idx_active_policies ON lic_schema.insurance_policies(policy_number)
WHERE status = 'active';

CREATE INDEX CONCURRENTLY idx_pending_payments ON lic_schema.premium_payments(policy_id, due_date)
WHERE status = 'pending' AND due_date <= NOW() + INTERVAL '30 days';

-- Text search indexes
CREATE INDEX CONCURRENTLY idx_video_content_search ON lic_schema.video_content
USING GIN(to_tsvector('english', title || ' ' || description || ' ' || array_to_string(tags, ' ')));

CREATE INDEX CONCURRENTLY idx_chatbot_kb_search ON lic_schema.chatbot_knowledge_base
USING GIN(to_tsvector('english', question || ' ' || answer));
```

### 3.2 Partitioning Strategy

#### Time-Based Partitioning
```sql
-- Analytics data partitioning (monthly)
CREATE TABLE lic_schema.user_events_partitioned (
    LIKE lic_schema.user_events INCLUDING ALL,
    PRIMARY KEY (event_id, timestamp)
) PARTITION BY RANGE (timestamp);

-- Create monthly partitions
CREATE TABLE lic_schema.user_events_2024_01 PARTITION OF lic_schema.user_events_partitioned
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE lic_schema.user_events_2024_02 PARTITION OF lic_schema.user_events_partitioned
FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Automated partition management
CREATE OR REPLACE FUNCTION create_monthly_partition(target_date DATE)
RETURNS VOID AS $$
DECLARE
    partition_name TEXT;
    start_date DATE;
    end_date DATE;
BEGIN
    start_date := date_trunc('month', target_date);
    end_date := start_date + INTERVAL '1 month';
    partition_name := 'user_events_' || to_char(start_date, 'YYYY_MM');

    EXECUTE format('CREATE TABLE IF NOT EXISTS %I PARTITION OF user_events_partitioned
                   FOR VALUES FROM (%L) TO (%L)',
                   partition_name, start_date, end_date);
END;
$$ LANGUAGE plpgsql;
```

#### Business Logic Partitioning
```sql
-- Provider-based partitioning for multi-tenant isolation
CREATE TABLE lic_schema.insurance_policies_partitioned (
    LIKE lic_schema.insurance_policies INCLUDING ALL
) PARTITION BY LIST (provider_id);

-- Create provider-specific partitions
CREATE TABLE lic_schema.policies_lic PARTITION OF lic_schema.insurance_policies_partitioned
FOR VALUES IN ('lic-provider-id');

CREATE TABLE lic_schema.policies_hdfc PARTITION OF lic_schema.insurance_policies_partitioned
FOR VALUES IN ('hdfc-provider-id');

-- Status-based partitioning for performance
CREATE TABLE lic_schema.policies_active PARTITION OF lic_schema.insurance_policies_partitioned
FOR VALUES IN ('active');

CREATE TABLE lic_schema.policies_inactive PARTITION OF lic_schema.insurance_policies_partitioned
FOR VALUES IN ('lapsed', 'surrendered', 'cancelled');
```

### 3.3 Query Optimization & Caching

#### Materialized Views
```sql
-- Agent dashboard performance view
CREATE MATERIALIZED VIEW lic_schema.agent_dashboard_metrics AS
SELECT
    a.agent_id,
    a.agent_code,
    u.display_name as agent_name,
    COUNT(DISTINCT p.policyholder_id) as total_policyholders,
    COUNT(DISTINCT ip.policy_id) as total_policies,
    SUM(ip.premium_amount) as total_premium,
    AVG(pp.amount) as avg_payment_amount,
    COUNT(pp.*) as total_payments,
    MAX(pp.payment_date) as last_payment_date
FROM lic_schema.agents a
JOIN lic_schema.users u ON a.user_id = u.user_id
LEFT JOIN lic_schema.policyholders p ON a.agent_id = p.agent_id
LEFT JOIN lic_schema.insurance_policies ip ON a.agent_id = ip.agent_id AND ip.status = 'active'
LEFT JOIN lic_schema.premium_payments pp ON ip.policy_id = pp.policy_id AND pp.status = 'completed'
GROUP BY a.agent_id, a.agent_code, u.display_name;

-- Refresh materialized view
CREATE UNIQUE INDEX idx_agent_dashboard_agent_id ON lic_schema.agent_dashboard_metrics(agent_id);
REFRESH MATERIALIZED VIEW CONCURRENTLY lic_schema.agent_dashboard_metrics;

-- Automated refresh schedule
CREATE OR REPLACE FUNCTION refresh_agent_metrics()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY lic_schema.agent_dashboard_metrics;
END;
$$ LANGUAGE plpgsql;

-- Schedule daily refresh
SELECT cron.schedule('refresh-agent-metrics', '0 2 * * *', 'SELECT refresh_agent_metrics();');
```

#### Query Optimization Techniques
```sql
-- Optimized policy search query
CREATE OR REPLACE FUNCTION search_policies_optimized(
    search_term TEXT,
    agent_id UUID DEFAULT NULL,
    status_filter TEXT[] DEFAULT NULL,
    limit_count INTEGER DEFAULT 50
)
RETURNS TABLE (
    policy_id UUID,
    policy_number TEXT,
    policyholder_name TEXT,
    agent_name TEXT,
    status TEXT,
    premium_amount DECIMAL,
    relevance_score FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.policy_id,
        p.policy_number,
        CONCAT(ph.first_name, ' ', ph.last_name) as policyholder_name,
        CONCAT(a.first_name, ' ', a.last_name) as agent_name,
        p.status,
        p.premium_amount,
        ts_rank_cd(
            to_tsvector('english', p.policy_number || ' ' || ph.first_name || ' ' || ph.last_name),
            plainto_tsquery('english', search_term)
        ) as relevance_score
    FROM lic_schema.insurance_policies p
    JOIN lic_schema.policyholders ph ON p.policyholder_id = ph.policyholder_id
    JOIN lic_schema.agents a ON p.agent_id = a.agent_id
    WHERE (agent_id IS NULL OR p.agent_id = search_policies_optimized.agent_id)
      AND (status_filter IS NULL OR p.status = ANY(status_filter))
      AND to_tsvector('english', p.policy_number || ' ' || ph.first_name || ' ' || ph.last_name) @@ plainto_tsquery('english', search_term)
    ORDER BY relevance_score DESC, p.created_at DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Add indexes for the optimized query
CREATE INDEX CONCURRENTLY idx_policies_search ON lic_schema.insurance_policies
USING GIN(to_tsvector('english', policy_number));

CREATE INDEX CONCURRENTLY idx_policyholders_search ON lic_schema.policyholders
USING GIN(to_tsvector('english', first_name || ' ' || last_name));
```

## 4. Data Security & Compliance

### 4.1 Encryption Strategy

#### Data at Rest Encryption
```sql
-- Enable encryption for sensitive columns
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Encrypted user data
ALTER TABLE lic_schema.users
ADD COLUMN encrypted_ssn TEXT,
ADD COLUMN encrypted_bank_details TEXT;

-- Encryption functions
CREATE OR REPLACE FUNCTION encrypt_sensitive_data(plain_text TEXT, encryption_key TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN encode(
        encrypt(plain_text::bytea, encryption_key::bytea, 'aes'),
        'hex'
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION decrypt_sensitive_data(encrypted_text TEXT, encryption_key TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN convert_from(
        decrypt(decode(encrypted_text, 'hex'), encryption_key::bytea, 'aes'),
        'UTF8'
    );
END;
$$ LANGUAGE plpgsql;
```

#### Row-Level Security (RLS)
```sql
-- Enable RLS on all tenant tables
ALTER TABLE lic_schema.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE lic_schema.agents ENABLE ROW LEVEL SECURITY;
ALTER TABLE lic_schema.policyholders ENABLE ROW LEVEL SECURITY;
ALTER TABLE lic_schema.insurance_policies ENABLE ROW LEVEL SECURITY;

-- RLS policies for multi-tenant access
CREATE POLICY tenant_isolation_policy ON lic_schema.users
FOR ALL USING (tenant_id = current_setting('app.tenant_id')::UUID);

CREATE POLICY agent_access_policy ON lic_schema.policyholders
FOR ALL USING (
    agent_id IN (
        SELECT agent_id FROM lic_schema.agents
        WHERE user_id = current_setting('app.user_id')::UUID
    )
);

-- Super admin bypass policy
CREATE POLICY super_admin_policy ON lic_schema.users
FOR ALL USING (
    EXISTS (
        SELECT 1 FROM lic_schema.user_roles ur
        JOIN lic_schema.roles r ON ur.role_id = r.role_id
        WHERE ur.user_id = current_setting('app.user_id')::UUID
        AND r.role_name = 'super_admin'
    )
);
```

### 4.2 Audit & Compliance

#### Comprehensive Audit Logging
```sql
-- Audit log table
CREATE TABLE audit.lic_audit_log (
    audit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    operation VARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
    old_values JSONB,
    new_values JSONB,

    -- Context
    user_id UUID,
    session_id UUID,
    ip_address INET,
    user_agent TEXT,
    timestamp TIMESTAMP DEFAULT NOW(),

    -- Compliance
    compliance_category VARCHAR(50), -- GDPR, IRDAI, etc.
    retention_period_days INTEGER DEFAULT 2555 -- 7 years
);

-- Audit trigger function
CREATE OR REPLACE FUNCTION audit.audit_trigger_function()
RETURNS TRIGGER AS $$
DECLARE
    audit_data JSONB;
    old_data JSONB;
    new_data JSONB;
BEGIN
    -- Prepare audit data
    old_data := CASE WHEN TG_OP != 'INSERT' THEN row_to_json(OLD)::JSONB ELSE NULL END;
    new_data := CASE WHEN TG_OP != 'DELETE' THEN row_to_json(NEW)::JSONB ELSE NULL END;

    -- Insert audit record
    INSERT INTO audit.lic_audit_log (
        table_name, record_id, operation, old_values, new_values,
        user_id, session_id, ip_address, user_agent
    ) VALUES (
        TG_TABLE_NAME, COALESCE(NEW.id, OLD.id),
        TG_OP, old_data, new_data,
        current_setting('app.user_id', true)::UUID,
        current_setting('app.session_id', true)::UUID,
        inet_client_addr(),
        current_setting('app.user_agent', true)
    );

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Apply audit triggers to critical tables
CREATE TRIGGER audit_users_trigger
    AFTER INSERT OR UPDATE OR DELETE ON lic_schema.users
    FOR EACH ROW EXECUTE FUNCTION audit.audit_trigger_function();

CREATE TRIGGER audit_policies_trigger
    AFTER INSERT OR UPDATE OR DELETE ON lic_schema.insurance_policies
    FOR EACH ROW EXECUTE FUNCTION audit.audit_trigger_function();
```

#### Data Retention & Archival
```sql
-- Automated data archival function
CREATE OR REPLACE FUNCTION archive_old_data()
RETURNS VOID AS $$
DECLARE
    archive_cutoff DATE := CURRENT_DATE - INTERVAL '7 years';
BEGIN
    -- Archive old audit logs
    INSERT INTO audit.archived_audit_logs
    SELECT * FROM audit.lic_audit_log
    WHERE timestamp < archive_cutoff;

    DELETE FROM audit.lic_audit_log
    WHERE timestamp < archive_cutoff;

    -- Archive old user events
    INSERT INTO lic_schema.archived_user_events
    SELECT * FROM lic_schema.user_events
    WHERE timestamp < (CURRENT_DATE - INTERVAL '2 years');

    DELETE FROM lic_schema.user_events
    WHERE timestamp < (CURRENT_DATE - INTERVAL '2 years');
END;
$$ LANGUAGE plpgsql;

-- Schedule monthly archival
SELECT cron.schedule('monthly-data-archival', '0 3 1 * *', 'SELECT archive_old_data();');
```

## 5. Database Maintenance & Monitoring

### 5.1 Health Monitoring

#### Database Health Checks
```sql
-- Database health monitoring function
CREATE OR REPLACE FUNCTION monitor_database_health()
RETURNS TABLE (
    metric_name TEXT,
    metric_value TEXT,
    status TEXT,
    recommendation TEXT
) AS $$
BEGIN
    RETURN QUERY
    -- Connection count
    SELECT
        'active_connections'::TEXT,
        count(*)::TEXT,
        CASE WHEN count(*) > 50 THEN 'warning' ELSE 'healthy' END,
        'Monitor connection pool usage'::TEXT
    FROM pg_stat_activity
    WHERE state = 'active'

    UNION ALL

    -- Database size
    SELECT
        'database_size'::TEXT,
        pg_size_pretty(pg_database_size(current_database()))::TEXT,
        CASE WHEN pg_database_size(current_database()) > 10000000000 THEN 'warning' ELSE 'healthy' END,
        'Consider archiving old data'::TEXT

    UNION ALL

    -- Long-running queries
    SELECT
        'long_running_queries'::TEXT,
        count(*)::TEXT,
        CASE WHEN count(*) > 5 THEN 'critical' ELSE 'healthy' END,
        'Investigate slow queries'::TEXT
    FROM pg_stat_activity
    WHERE state = 'active'
      AND now() - query_start > interval '5 minutes';
END;
$$ LANGUAGE plpgsql;
```

#### Performance Monitoring
```sql
-- Query performance monitoring
CREATE TABLE lic_schema.query_performance_log (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    query_id VARCHAR(255),
    query_text TEXT,
    execution_time_ms INTEGER,
    rows_affected INTEGER,
    user_id UUID,
    timestamp TIMESTAMP DEFAULT NOW()
);

-- Log slow queries
CREATE OR REPLACE FUNCTION log_slow_queries()
RETURNS event_trigger AS $$
DECLARE
    query_record RECORD;
BEGIN
    FOR query_record IN
        SELECT * FROM pg_stat_statements
        WHERE mean_time > 1000 -- Queries taking more than 1 second
        ORDER BY mean_time DESC
        LIMIT 10
    LOOP
        INSERT INTO lic_schema.query_performance_log (
            query_id, query_text, execution_time_ms
        ) VALUES (
            query_record.queryid::TEXT,
            query_record.query,
            query_record.mean_time::INTEGER
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Create event trigger
CREATE EVENT TRIGGER slow_query_logger
    ON ddl_command_end
    EXECUTE FUNCTION log_slow_queries();
```

### 5.2 Backup & Recovery

#### Automated Backup Strategy
```sql
-- Backup configuration
CREATE TABLE shared.backup_config (
    config_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES shared.tenants(tenant_id),
    backup_type VARCHAR(50), -- 'full', 'incremental', 'differential'
    schedule VARCHAR(100), -- cron expression
    retention_days INTEGER DEFAULT 30,
    storage_location VARCHAR(500),
    encryption_enabled BOOLEAN DEFAULT true,
    last_backup_at TIMESTAMP,
    next_backup_at TIMESTAMP,
    status VARCHAR(50) DEFAULT 'active'
);

-- Backup execution tracking
CREATE TABLE shared.backup_history (
    backup_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES shared.tenants(tenant_id),
    config_id UUID REFERENCES shared.backup_config(config_id),
    backup_type VARCHAR(50),
    started_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP,
    size_bytes BIGINT,
    status VARCHAR(50), -- 'running', 'completed', 'failed'
    error_message TEXT,
    verification_status VARCHAR(50) -- 'pending', 'verified', 'failed'
);

-- Automated backup function
CREATE OR REPLACE FUNCTION execute_tenant_backup(target_tenant_id UUID)
RETURNS UUID AS $$
DECLARE
    backup_record_id UUID;
    backup_file_path TEXT;
BEGIN
    -- Create backup record
    INSERT INTO shared.backup_history (tenant_id, backup_type, status)
    VALUES (target_tenant_id, 'full', 'running')
    RETURNING backup_id INTO backup_record_id;

    -- Execute pg_dump for tenant schema
    SELECT format('/backups/%s_%s_%s.sql',
                  target_tenant_id,
                  'full',
                  to_char(NOW(), 'YYYY_MM_DD_HH24_MI_SS'))
    INTO backup_file_path;

    -- Update backup record
    UPDATE shared.backup_history
    SET completed_at = NOW(),
        status = 'completed',
        verification_status = 'pending'
    WHERE backup_id = backup_record_id;

    RETURN backup_record_id;
END;
$$ LANGUAGE plpgsql;
```

This comprehensive database design provides a solid foundation for the Agent Mitra platform, ensuring scalability, security, performance, and compliance with industry standards. The schema supports multi-tenancy, advanced analytics, and complex business workflows while maintaining data integrity and regulatory compliance.
