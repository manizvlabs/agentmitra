# Agent Mitra - Comprehensive Database Design

> **Note:** This document adheres to the [Separation of Concerns](./glossary.md#separation-of-concerns) principle by maintaining clear data boundaries between the mobile app, configuration portal, and LIC systems.

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

-- Session analytics (NOT IMPLEMENTED)
-- This table is defined in the design but not created in the database
-- Session data is tracked through lic_schema.user_sessions table
-- Detailed analytics can be derived from user_sessions and other analytics tables
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

-- Video watch analytics (IMPLEMENTED - V22 Migration)
CREATE TABLE lic_schema.video_analytics (
    analytics_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    video_id UUID REFERENCES lic_schema.video_content(video_id) ON DELETE CASCADE,
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE SET NULL,

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
    playback_quality VARCHAR(20),
    
    -- Additional metadata (added in implementation)
    ip_address INET,
    user_agent TEXT,
    location_info JSONB,
    
    created_at TIMESTAMP DEFAULT NOW()
);
-- Note: Partitioning by RANGE (started_at) can be added later if needed for performance
```

#### Presentation Carousel Management
```sql
-- Presentation carousel (agent promotional content)
CREATE TABLE lic_schema.presentations (
    presentation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.agents(agent_id) ON DELETE CASCADE,
    
    -- Presentation details
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'draft', -- 'draft', 'published', 'archived'
    is_active BOOLEAN DEFAULT false,
    
    -- Template reference
    template_id UUID, -- References presentation_templates if created from template
    template_category VARCHAR(100), -- 'term_insurance', 'health_insurance', 'child_plans', 'retirement'
    
    -- Version control
    version INTEGER DEFAULT 1,
    parent_presentation_id UUID REFERENCES lic_schema.presentations(presentation_id),
    
    -- Lifecycle timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    published_at TIMESTAMP,
    archived_at TIMESTAMP,
    
    -- Metadata
    tags TEXT[],
    target_audience TEXT[], -- 'prospects', 'existing_customers', 'senior_citizens'
    language VARCHAR(10) DEFAULT 'en',
    
    -- Analytics summary (denormalized for performance)
    total_views INTEGER DEFAULT 0,
    total_shares INTEGER DEFAULT 0,
    total_cta_clicks INTEGER DEFAULT 0,
    
    -- Audit fields
    created_by UUID REFERENCES lic_schema.users(user_id),
    published_by UUID REFERENCES lic_schema.users(user_id)
);

-- Presentation slides (individual carousel slides)
CREATE TABLE lic_schema.presentation_slides (
    slide_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    presentation_id UUID REFERENCES lic_schema.presentations(presentation_id) ON DELETE CASCADE,
    
    -- Slide ordering
    slide_order INTEGER NOT NULL,
    
    -- Media content
    slide_type VARCHAR(50) NOT NULL, -- 'image', 'video', 'text'
    media_url VARCHAR(500),
    media_type VARCHAR(50), -- 'image/jpeg', 'image/png', 'video/mp4'
    thumbnail_url VARCHAR(500),
    media_storage_key VARCHAR(500), -- S3/CDN storage key
    
    -- Text content
    title TEXT,
    subtitle TEXT,
    description TEXT,
    
    -- Styling
    text_color VARCHAR(7) DEFAULT '#FFFFFF', -- Hex color
    background_color VARCHAR(7) DEFAULT '#000000', -- Hex color
    overlay_opacity DECIMAL(3,2) DEFAULT 0.5,
    layout VARCHAR(50) DEFAULT 'centered', -- 'centered', 'left_aligned', 'grid', 'right_aligned'
    
    -- Display settings
    duration INTEGER DEFAULT 4, -- Seconds to display slide
    transition_effect VARCHAR(50) DEFAULT 'fade', -- 'fade', 'slide', 'zoom'
    
    -- Call-to-action button
    cta_button JSONB, -- {enabled: bool, text: str, action: str, backgroundColor: str, textColor: str}
    
    -- Agent branding
    agent_branding JSONB, -- {showLogo: bool, logoUrl: str, showContact: bool, contactText: str}
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    -- Ensure unique ordering within presentation
    UNIQUE(presentation_id, slide_order)
);

-- Presentation templates (pre-built templates for agents)
CREATE TABLE lic_schema.presentation_templates (
    template_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Template details
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL, -- 'term_insurance', 'health_insurance', 'child_plans', 'retirement'
    
    -- Template content (JSONB array of slide definitions)
    slides JSONB NOT NULL, -- Array of slide objects with template variables
    
    -- Template metadata
    is_default BOOLEAN DEFAULT false,
    is_public BOOLEAN DEFAULT false, -- Public templates available to all agents
    is_system_template BOOLEAN DEFAULT false, -- System-created templates
    
    -- Usage tracking
    usage_count INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2),
    total_ratings INTEGER DEFAULT 0,
    
    -- Preview
    preview_image_url VARCHAR(500),
    preview_video_url VARCHAR(500),
    
    -- Availability
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'archived', 'deprecated'
    available_from TIMESTAMP,
    available_until TIMESTAMP,
    
    -- Audit fields
    created_by UUID REFERENCES lic_schema.users(user_id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Presentation analytics (tracking views, engagement, etc.)
CREATE TABLE lic_schema.presentation_analytics (
    analytics_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    presentation_id UUID REFERENCES lic_schema.presentations(presentation_id) ON DELETE CASCADE,
    slide_id UUID REFERENCES lic_schema.presentation_slides(slide_id) ON DELETE SET NULL,
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    
    -- Event details
    event_type VARCHAR(50) NOT NULL, -- 'view', 'cta_click', 'share', 'forward', 'interest'
    event_category VARCHAR(50), -- 'engagement', 'conversion', 'navigation'
    
    -- User context (if available)
    viewer_id UUID REFERENCES lic_schema.users(user_id), -- Nullable for anonymous views
    viewer_type VARCHAR(50), -- 'agent', 'customer', 'prospect', 'anonymous'
    
    -- Event metadata
    event_data JSONB, -- Additional event-specific data
    cta_action VARCHAR(100), -- If event_type is 'cta_click', what action was triggered
    share_method VARCHAR(50), -- 'whatsapp', 'email', 'sms', 'link' if event_type is 'share'
    
    -- Device and context
    device_info JSONB,
    ip_address INET,
    user_agent TEXT,
    location_info JSONB,
    
    -- Timestamps
    event_timestamp TIMESTAMP DEFAULT NOW()
) PARTITION BY RANGE (event_timestamp);

-- Presentation media storage (tracking uploaded media files)
CREATE TABLE lic_schema.presentation_media (
    media_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    
    -- Media details
    media_type VARCHAR(50) NOT NULL, -- 'image', 'video'
    mime_type VARCHAR(100), -- 'image/jpeg', 'video/mp4'
    file_name VARCHAR(255),
    file_size_bytes BIGINT,
    
    -- Storage locations
    storage_provider VARCHAR(50) DEFAULT 's3', -- 's3', 'firebase', 'cdn'
    storage_key VARCHAR(500) NOT NULL, -- S3 key or storage path
    media_url VARCHAR(500) NOT NULL, -- Public CDN URL
    thumbnail_url VARCHAR(500), -- Thumbnail URL for videos
    
    -- Media metadata
    width INTEGER, -- Image/video width in pixels
    height INTEGER, -- Image/video height in pixels
    duration_seconds INTEGER, -- Video duration
    file_hash VARCHAR(64), -- SHA-256 hash for deduplication
    
    -- Usage tracking
    usage_count INTEGER DEFAULT 0, -- How many slides use this media
    last_used_at TIMESTAMP,
    
    -- Status
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'archived', 'deleted'
    is_optimized BOOLEAN DEFAULT false,
    
    -- Timestamps
    uploaded_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Agent presentation preferences (customization settings)
CREATE TABLE lic_schema.agent_presentation_preferences (
    preference_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.agents(agent_id) UNIQUE,
    
    -- Branding preferences
    default_text_color VARCHAR(7) DEFAULT '#FFFFFF',
    default_background_color VARCHAR(7) DEFAULT '#000000',
    default_layout VARCHAR(50) DEFAULT 'centered',
    default_duration INTEGER DEFAULT 4,
    
    -- Branding assets
    logo_url VARCHAR(500),
    brand_colors JSONB, -- Array of brand color hex codes
    
    -- Auto-branding settings
    auto_add_logo BOOLEAN DEFAULT true,
    auto_add_contact_cta BOOLEAN DEFAULT true,
    contact_cta_text VARCHAR(100) DEFAULT 'Talk to me',
    
    -- Editor preferences
    editor_theme VARCHAR(20) DEFAULT 'light', -- 'light', 'dark'
    show_preview_by_default BOOLEAN DEFAULT true,
    auto_save_enabled BOOLEAN DEFAULT true,
    auto_save_interval_seconds INTEGER DEFAULT 60,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for presentation tables
CREATE INDEX CONCURRENTLY idx_presentations_agent_status ON lic_schema.presentations(agent_id, status);
CREATE INDEX CONCURRENTLY idx_presentations_active ON lic_schema.presentations(agent_id, is_active) WHERE is_active = true;
CREATE INDEX CONCURRENTLY idx_presentations_template ON lic_schema.presentations(template_id) WHERE template_id IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_presentations_published ON lic_schema.presentations(published_at DESC) WHERE status = 'published';

CREATE INDEX CONCURRENTLY idx_slides_presentation_order ON lic_schema.presentation_slides(presentation_id, slide_order);
CREATE INDEX CONCURRENTLY idx_slides_type ON lic_schema.presentation_slides(slide_type);

CREATE INDEX CONCURRENTLY idx_templates_category_public ON lic_schema.presentation_templates(category, is_public) WHERE is_public = true;
CREATE INDEX CONCURRENTLY idx_templates_status ON lic_schema.presentation_templates(status) WHERE status = 'active';

CREATE INDEX CONCURRENTLY idx_analytics_presentation ON lic_schema.presentation_analytics(presentation_id, event_timestamp DESC);
CREATE INDEX CONCURRENTLY idx_analytics_slide ON lic_schema.presentation_analytics(slide_id, event_type) WHERE slide_id IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_analytics_agent ON lic_schema.presentation_analytics(agent_id, event_timestamp DESC);
CREATE INDEX CONCURRENTLY idx_analytics_event_type ON lic_schema.presentation_analytics(event_type, event_timestamp DESC);

CREATE INDEX CONCURRENTLY idx_media_agent_status ON lic_schema.presentation_media(agent_id, status);
CREATE INDEX CONCURRENTLY idx_media_hash ON lic_schema.presentation_media(file_hash) WHERE file_hash IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_media_type ON lic_schema.presentation_media(media_type);

-- JSONB indexes for flexible queries
CREATE INDEX CONCURRENTLY idx_slides_cta_button ON lic_schema.presentation_slides USING GIN(cta_button) WHERE cta_button IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_slides_agent_branding ON lic_schema.presentation_slides USING GIN(agent_branding) WHERE agent_branding IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_analytics_event_data ON lic_schema.presentation_analytics USING GIN(event_data);
CREATE INDEX CONCURRENTLY idx_templates_slides ON lic_schema.presentation_templates USING GIN(slides);

-- Functions for presentation management
CREATE OR REPLACE FUNCTION update_presentation_analytics_summary()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

CREATE TRIGGER presentation_analytics_summary_trigger
    AFTER INSERT ON lic_schema.presentation_analytics
    FOR EACH ROW
    EXECUTE FUNCTION update_presentation_analytics_summary();

-- Function to archive old presentations
CREATE OR REPLACE FUNCTION archive_old_presentations()
RETURNS VOID AS $$
BEGIN
    UPDATE lic_schema.presentations
    SET status = 'archived',
        archived_at = NOW()
    WHERE status = 'published'
      AND published_at < NOW() - INTERVAL '90 days'
      AND is_active = false;
END;
$$ LANGUAGE plpgsql;

-- Function to increment media usage count
CREATE OR REPLACE FUNCTION increment_media_usage()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.media_url IS NOT NULL THEN
        UPDATE lic_schema.presentation_media
        SET usage_count = usage_count + 1,
            last_used_at = NOW()
        WHERE media_url = NEW.media_url;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER slide_media_usage_trigger
    AFTER INSERT OR UPDATE ON lic_schema.presentation_slides
    FOR EACH ROW
    EXECUTE FUNCTION increment_media_usage();
```

### 2.6 Analytics & Reporting Tables

#### User Behavior Analytics

> **Note:** The `user_events` table is **NOT implemented**. User behavior is tracked through the `customer_behavior_metrics` table (V10 migration) which provides aggregated metrics rather than raw event logs. If raw event tracking is needed, this table can be added in a future migration.

```sql
-- User behavior events (NOT IMPLEMENTED - Use customer_behavior_metrics instead)
-- This table is defined in the design but not created in the database
-- Alternative: lic_schema.customer_behavior_metrics provides aggregated behavior metrics
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

-- User journey tracking (IMPLEMENTED - V22 Migration)
CREATE TABLE lic_schema.user_journeys (
    journey_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,

    -- Journey metadata
    journey_type VARCHAR(100) NOT NULL, -- 'onboarding', 'policy_purchase', 'claim_process', 'profile_setup', etc.
    started_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP,
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'completed', 'abandoned', 'failed'

    -- Journey steps
    current_step INTEGER DEFAULT 1,
    total_steps INTEGER,
    step_history JSONB, -- Array of step objects with timestamps and metadata

    -- Conversion tracking
    converted BOOLEAN DEFAULT false,
    conversion_value DECIMAL(12,2),
    drop_off_step INTEGER,
    drop_off_reason TEXT,
    
    -- Additional metadata (added in implementation)
    journey_data JSONB, -- Flexible storage for journey-specific data
    session_id UUID REFERENCES lic_schema.user_sessions(session_id) ON DELETE SET NULL,
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

#### Business Intelligence Tables

> **Note:** The `agent_performance` table is **NOT implemented**. Agent performance is tracked through:
> - `agent_daily_metrics` (V10 migration) - Daily performance metrics
> - `agent_monthly_summary` (V10 migration) - Monthly aggregated summaries
> 
> These tables provide more granular and practical performance tracking than the single `agent_performance` table.

```sql
-- Agent performance metrics (NOT IMPLEMENTED - Use agent_daily_metrics and agent_monthly_summary instead)
-- This table is defined in the design but not created in the database
-- Alternatives: lic_schema.agent_daily_metrics and lic_schema.agent_monthly_summary
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

-- System health and performance (NOT IMPLEMENTED)
-- This table is defined in the design but not created in the database
-- System metrics are typically tracked through application monitoring tools (Prometheus, Grafana, etc.)
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
-- Query performance monitoring (NOT IMPLEMENTED - Use analytics_query_log instead)
-- This table is defined in the design but not created in the database
-- Alternative: lic_schema.analytics_query_log (V10 migration) provides similar functionality
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

## 6. Agent Configuration Portal Database Schemas

### 6.1 Portal Service Database Design

The Agent Configuration Portal requires dedicated database schemas to manage administrative functions, data import operations, and agent management. These schemas operate independently from the main application database while maintaining secure data synchronization.

#### Portal Database Architecture
```sql
-- portal_service database schemas
-- Separate database instance for portal operations

-- =================================================
-- AGENT CONFIGURATION PORTAL DATABASE SCHEMAS
-- =================================================

-- Portal users (agents and admins)
CREATE TABLE portal_users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL, -- Links to main app tenants
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role VARCHAR(50) NOT NULL, -- 'super_admin', 'insurance_provider_admin', 'regional_manager', 'senior_agent', 'junior_agent'
    agent_code VARCHAR(50) UNIQUE,
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Agent hierarchy and relationships
CREATE TABLE agent_hierarchy (
    hierarchy_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    agent_id UUID REFERENCES portal_users(user_id),
    manager_id UUID REFERENCES portal_users(user_id),
    hierarchy_level INTEGER NOT NULL, -- 1 = junior, 2 = senior, 3 = manager, etc.
    region VARCHAR(100),
    territory VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Data import operations
CREATE TABLE import_jobs (
    import_job_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    agent_id UUID REFERENCES portal_users(user_id),
    file_name VARCHAR(500) NOT NULL,
    file_path VARCHAR(1000),
    import_type VARCHAR(50) NOT NULL, -- 'excel', 'lic_api', 'bulk_update'
    total_records INTEGER DEFAULT 0,
    processed_records INTEGER DEFAULT 0,
    successful_records INTEGER DEFAULT 0,
    failed_records INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'failed'
    error_message TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    started_at TIMESTAMP,
    completed_at TIMESTAMP
);

-- Individual import records for tracking
CREATE TABLE import_records (
    import_record_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    import_job_id UUID REFERENCES import_jobs(import_job_id),
    row_number INTEGER NOT NULL,
    data JSONB NOT NULL, -- Raw imported data
    processed_data JSONB, -- Processed/cleaned data
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'success', 'failed', 'skipped'
    error_message TEXT,
    customer_id UUID, -- Link to created/updated customer
    policy_id UUID, -- Link to created/updated policy
    processed_at TIMESTAMP DEFAULT NOW()
);

-- Excel template configurations
CREATE TABLE excel_templates (
    template_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    template_name VARCHAR(200) NOT NULL,
    description TEXT,
    column_mapping JSONB NOT NULL, -- Maps Excel columns to database fields
    required_columns TEXT[] DEFAULT '{}', -- Array of required column names
    optional_columns TEXT[] DEFAULT '{}', -- Array of optional column names
    validation_rules JSONB DEFAULT '{}', -- Custom validation rules
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES portal_users(user_id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- LIC API synchronization jobs
CREATE TABLE lic_sync_jobs (
    sync_job_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    agent_id UUID REFERENCES portal_users(user_id),
    sync_type VARCHAR(100) NOT NULL, -- 'policies', 'customers', 'claims', 'full_sync'
    external_reference_id VARCHAR(200), -- LIC reference ID
    records_processed INTEGER DEFAULT 0,
    records_updated INTEGER DEFAULT 0,
    records_created INTEGER DEFAULT 0,
    records_failed INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'running', 'completed', 'failed'
    error_message TEXT,
    api_response JSONB, -- Store API response for debugging
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Portal activity audit log
CREATE TABLE portal_audit_log (
    audit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    user_id UUID REFERENCES portal_users(user_id),
    action VARCHAR(100) NOT NULL, -- 'login', 'import_data', 'update_customer', 'view_report', etc.
    resource_type VARCHAR(100), -- 'customer', 'policy', 'import_job', 'report', etc.
    resource_id UUID, -- ID of the affected resource
    old_values JSONB, -- Previous state (for updates)
    new_values JSONB, -- New state (for updates/creates)
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Customer data management (portal view)
CREATE TABLE portal_customers (
    customer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    external_customer_id UUID, -- Link to main app customer
    agent_id UUID REFERENCES portal_users(user_id),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(255),
    date_of_birth DATE,
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    pincode VARCHAR(10),
    aadhaar_number VARCHAR(12),
    pan_number VARCHAR(10),
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'inactive', 'suspended'
    risk_profile VARCHAR(50), -- 'low', 'medium', 'high'
    customer_value VARCHAR(20) DEFAULT 'bronze', -- 'bronze', 'silver', 'gold', 'platinum'
    tags TEXT[] DEFAULT '{}', -- Array of tags for segmentation
    last_contacted_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    created_by UUID REFERENCES portal_users(user_id),
    updated_by UUID REFERENCES portal_users(user_id)
);

-- Policy data management (portal view)
CREATE TABLE portal_policies (
    policy_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    customer_id UUID REFERENCES portal_customers(customer_id),
    external_policy_id UUID, -- Link to main app policy
    agent_id UUID REFERENCES portal_users(user_id),
    policy_number VARCHAR(100) UNIQUE NOT NULL,
    policy_type VARCHAR(100) NOT NULL, -- 'life', 'health', 'general', 'term', etc.
    product_name VARCHAR(200),
    sum_assured DECIMAL(15,2),
    premium_amount DECIMAL(10,2),
    premium_frequency VARCHAR(20) DEFAULT 'Monthly', -- 'Monthly', 'Quarterly', 'Half-Yearly', 'Yearly'
    issue_date DATE,
    maturity_date DATE,
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'lapsed', 'surrendered', 'matured', 'claimed'
    payment_status VARCHAR(50) DEFAULT 'regular', -- 'regular', 'overdue', 'lapsed'
    last_premium_date DATE,
    next_premium_date DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Reporting and analytics data
CREATE TABLE portal_reports (
    report_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    report_type VARCHAR(100) NOT NULL, -- 'customer_summary', 'policy_performance', 'agent_productivity', etc.
    report_name VARCHAR(200) NOT NULL,
    parameters JSONB DEFAULT '{}', -- Report parameters
    generated_by UUID REFERENCES portal_users(user_id),
    generated_at TIMESTAMP DEFAULT NOW(),
    file_path VARCHAR(1000), -- Path to generated report file
    file_size INTEGER, -- Size in bytes
    download_count INTEGER DEFAULT 0,
    expires_at TIMESTAMP -- Report expiration date
);

-- Dashboard preferences per user
CREATE TABLE dashboard_preferences (
    preference_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES portal_users(user_id) UNIQUE,
    layout_config JSONB DEFAULT '{}', -- Dashboard widget layout
    visible_widgets TEXT[] DEFAULT '{}', -- Array of visible widget IDs
    chart_preferences JSONB DEFAULT '{}', -- Chart display preferences
    refresh_interval INTEGER DEFAULT 300, -- Auto-refresh interval in seconds
    theme VARCHAR(20) DEFAULT 'light', -- 'light', 'dark', 'auto'
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_portal_users_tenant_role ON portal_users(tenant_id, role);
CREATE INDEX idx_portal_users_agent_code ON portal_users(agent_code);
CREATE INDEX idx_import_jobs_tenant_agent ON import_jobs(tenant_id, agent_id);
CREATE INDEX idx_import_jobs_status ON import_jobs(status);
CREATE INDEX idx_import_records_job_id ON import_records(import_job_id);
CREATE INDEX idx_lic_sync_jobs_tenant_agent ON lic_sync_jobs(tenant_id, agent_id);
CREATE INDEX idx_lic_sync_jobs_status ON lic_sync_jobs(status);
CREATE INDEX idx_portal_audit_log_tenant_user ON portal_audit_log(tenant_id, user_id);
CREATE INDEX idx_portal_audit_log_action ON portal_audit_log(action);
CREATE INDEX idx_portal_customers_tenant_agent ON portal_customers(tenant_id, agent_id);
CREATE INDEX idx_portal_customers_phone ON portal_customers(phone);
CREATE INDEX idx_portal_customers_email ON portal_customers(email);
CREATE INDEX idx_portal_policies_customer ON portal_policies(customer_id);
CREATE INDEX idx_portal_policies_agent ON portal_policies(agent_id);
CREATE INDEX idx_portal_policies_policy_number ON portal_policies(policy_number);
CREATE INDEX idx_portal_policies_status ON portal_policies(status);

-- Row Level Security (RLS) policies
ALTER TABLE portal_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE portal_customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE portal_policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE import_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE lic_sync_jobs ENABLE ROW LEVEL SECURITY;

-- RLS policy for portal_users (users can only see their own tenant)
CREATE POLICY portal_users_tenant_isolation ON portal_users
    FOR ALL USING (tenant_id = current_setting('app.current_tenant_id')::UUID);

-- RLS policy for portal_customers (users can only see customers in their tenant)
CREATE POLICY portal_customers_tenant_isolation ON portal_customers
    FOR ALL USING (tenant_id = current_setting('app.current_tenant_id')::UUID);

-- Additional RLS policies for agent-specific access
CREATE POLICY portal_customers_agent_access ON portal_customers
    FOR ALL USING (agent_id = current_setting('app.current_user_id')::UUID OR
                   current_setting('app.user_role') IN ('admin', 'manager'));

-- RLS policy for portal_policies
CREATE POLICY portal_policies_tenant_isolation ON portal_policies
    FOR ALL USING (tenant_id = current_setting('app.current_tenant_id')::UUID);

CREATE POLICY portal_policies_agent_access ON portal_policies
    FOR ALL USING (agent_id = current_setting('app.current_user_id')::UUID OR
                   current_setting('app.user_role') IN ('admin', 'manager'));
```

## 7. Callback Request Management Database Schemas

### 7.1 Callback Management Database Design

The callback management system requires dedicated tables to handle callback requests, priority management, SLA tracking, and agent assignments. These schemas integrate with the main application database.

#### Callback Management Tables
```sql
-- =================================================
-- CALLBACK REQUEST MANAGEMENT SCHEMAS
-- =================================================

-- Callback request priority levels
CREATE TYPE callback_priority AS ENUM ('high', 'medium', 'low');

-- Callback request status
CREATE TYPE callback_status AS ENUM ('pending', 'assigned', 'in_progress', 'completed', 'cancelled', 'overdue');

-- Main callback requests table
CREATE TABLE callback_requests (
    callback_request_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    customer_id UUID NOT NULL, -- References main app customers
    agent_id UUID REFERENCES portal_users(user_id), -- Assigned agent (nullable)
    request_type VARCHAR(100) NOT NULL, -- 'policy_issue', 'payment_problem', 'claim_assistance', etc.
    description TEXT NOT NULL,
    priority callback_priority DEFAULT 'low',
    priority_score DECIMAL(5,2) DEFAULT 0.00, -- Calculated priority score 0-100
    status callback_status DEFAULT 'pending',

    -- Customer contact information (cached for performance)
    customer_name VARCHAR(200) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    customer_email VARCHAR(255),

    -- SLA and time management
    sla_hours INTEGER DEFAULT 24, -- Service Level Agreement in hours
    created_at TIMESTAMP DEFAULT NOW(),
    assigned_at TIMESTAMP,
    scheduled_at TIMESTAMP, -- When callback is scheduled
    due_at TIMESTAMP, -- Calculated due date based on SLA
    started_at TIMESTAMP, -- When agent starts working on callback
    completed_at TIMESTAMP,

    -- Source tracking
    source VARCHAR(50) DEFAULT 'portal', -- 'portal', 'whatsapp', 'mobile', 'api'
    source_reference_id VARCHAR(200), -- Reference ID from source system

    -- Metadata and categorization
    tags TEXT[] DEFAULT '{}', -- Array of tags for categorization
    category VARCHAR(100), -- 'technical', 'billing', 'policy', 'general'
    urgency_level VARCHAR(20) DEFAULT 'medium', -- 'critical', 'high', 'medium', 'low'
    customer_value VARCHAR(20) DEFAULT 'bronze', -- 'bronze', 'silver', 'gold', 'platinum'

    -- Resolution details
    resolution TEXT, -- How the callback was resolved
    resolution_category VARCHAR(100), -- 'resolved', 'escalated', 'transferred', 'cancelled'
    satisfaction_rating INTEGER CHECK (satisfaction_rating >= 1 AND satisfaction_rating <= 5),

    -- Audit fields
    created_by UUID REFERENCES portal_users(user_id),
    assigned_by UUID REFERENCES portal_users(user_id),
    completed_by UUID REFERENCES portal_users(user_id),
    last_updated_by UUID REFERENCES portal_users(user_id),
    last_updated_at TIMESTAMP DEFAULT NOW()
);

-- Callback activity log (tracks all interactions)
CREATE TABLE callback_activities (
    callback_activity_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    callback_request_id UUID REFERENCES callback_requests(callback_request_id) ON DELETE CASCADE,
    agent_id UUID REFERENCES portal_users(user_id),
    activity_type VARCHAR(50) NOT NULL, -- 'created', 'assigned', 'called', 'completed', 'escalated', 'cancelled', etc.
    description TEXT NOT NULL,
    duration_minutes INTEGER, -- Duration of the activity in minutes
    contact_method VARCHAR(50), -- 'phone', 'whatsapp', 'email', 'sms', 'in_person'
    contact_outcome VARCHAR(100), -- 'successful', 'no_answer', 'wrong_number', 'voicemail', etc.
    notes TEXT, -- Additional notes from agent
    metadata JSONB DEFAULT '{}', -- Flexible metadata storage
    created_at TIMESTAMP DEFAULT NOW()
);

-- Callback queue management
CREATE TABLE callback_queues (
    callback_queue_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    queue_name VARCHAR(100) NOT NULL,
    queue_type VARCHAR(50) DEFAULT 'priority', -- 'priority', 'fifo', 'round_robin'
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    max_concurrent_callbacks INTEGER DEFAULT 5, -- Max callbacks an agent can handle simultaneously
    sla_target_hours INTEGER DEFAULT 24,
    auto_assignment_enabled BOOLEAN DEFAULT true,
    assignment_rules JSONB DEFAULT '{}', -- Rules for auto-assignment
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Agent callback assignments and capacity
CREATE TABLE agent_callback_capacity (
    capacity_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES portal_users(user_id) UNIQUE,
    max_daily_callbacks INTEGER DEFAULT 50,
    max_concurrent_callbacks INTEGER DEFAULT 3,
    current_active_callbacks INTEGER DEFAULT 0,
    specialties TEXT[] DEFAULT '{}', -- Types of callbacks this agent specializes in
    availability_schedule JSONB DEFAULT '{}', -- Agent's availability schedule
    is_available BOOLEAN DEFAULT true,
    last_updated_at TIMESTAMP DEFAULT NOW()
);

-- Callback escalation rules
CREATE TABLE callback_escalation_rules (
    escalation_rule_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    rule_name VARCHAR(200) NOT NULL,
    priority callback_priority,
    trigger_condition JSONB NOT NULL, -- When to trigger escalation
    escalation_action VARCHAR(100) NOT NULL, -- 'notify_manager', 'reassign', 'increase_priority', etc.
    escalation_target JSONB NOT NULL, -- Who/what to escalate to
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Callback templates for common responses
CREATE TABLE callback_templates (
    template_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    template_name VARCHAR(200) NOT NULL,
    category VARCHAR(100) NOT NULL,
    subject VARCHAR(500),
    template_text TEXT NOT NULL,
    variables TEXT[] DEFAULT '{}', -- Available variables for personalization
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES portal_users(user_id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Callback analytics and reporting tables
CREATE TABLE callback_metrics_daily (
    metric_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    date DATE NOT NULL,
    total_callbacks INTEGER DEFAULT 0,
    resolved_callbacks INTEGER DEFAULT 0,
    avg_resolution_time_minutes DECIMAL(8,2),
    avg_first_response_time_minutes DECIMAL(8,2),
    sla_compliance_percentage DECIMAL(5,2),
    customer_satisfaction_avg DECIMAL(3,2),
    callbacks_by_priority JSONB DEFAULT '{}',
    callbacks_by_type JSONB DEFAULT '{}',
    callbacks_by_source JSONB DEFAULT '{}',
    agent_performance JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT NOW(),

    UNIQUE(tenant_id, date)
);

-- Callback performance tracking per agent
CREATE TABLE agent_callback_performance (
    performance_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES portal_users(user_id),
    tenant_id UUID NOT NULL,
    date DATE NOT NULL,
    total_assigned INTEGER DEFAULT 0,
    total_resolved INTEGER DEFAULT 0,
    avg_resolution_time_minutes DECIMAL(8,2),
    sla_compliance_percentage DECIMAL(5,2),
    customer_satisfaction_avg DECIMAL(3,2),
    callbacks_by_priority JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT NOW(),

    UNIQUE(agent_id, date)
);

-- Callback SLA tracking
CREATE TABLE callback_sla_tracking (
    sla_tracking_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    callback_request_id UUID REFERENCES callback_requests(callback_request_id),
    sla_type VARCHAR(50) NOT NULL, -- 'first_response', 'resolution'
    target_time TIMESTAMP NOT NULL,
    actual_time TIMESTAMP,
    is_met BOOLEAN GENERATED ALWAYS AS (actual_time <= target_time) STORED,
    delay_minutes INTEGER GENERATED ALWAYS AS (
        EXTRACT(EPOCH FROM (actual_time - target_time))/60
    ) STORED,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_callback_requests_tenant_status ON callback_requests(tenant_id, status);
CREATE INDEX idx_callback_requests_tenant_priority ON callback_requests(tenant_id, priority);
CREATE INDEX idx_callback_requests_customer ON callback_requests(customer_id);
CREATE INDEX idx_callback_requests_agent ON callback_requests(agent_id);
CREATE INDEX idx_callback_requests_due_at ON callback_requests(due_at);
CREATE INDEX idx_callback_requests_created_at ON callback_requests(created_at);
CREATE INDEX idx_callback_activities_callback ON callback_activities(callback_request_id);
CREATE INDEX idx_callback_activities_agent ON callback_activities(agent_id);
CREATE INDEX idx_callback_activities_created_at ON callback_activities(created_at);
CREATE INDEX idx_callback_metrics_daily_tenant_date ON callback_metrics_daily(tenant_id, date);
CREATE INDEX idx_agent_callback_performance_agent_date ON agent_callback_performance(agent_id, date);
CREATE INDEX idx_callback_sla_tracking_callback ON callback_sla_tracking(callback_request_id);

-- Partial indexes for common queries
CREATE INDEX idx_callback_requests_pending ON callback_requests(callback_request_id) WHERE status = 'pending';
CREATE INDEX idx_callback_requests_overdue ON callback_requests(callback_request_id)
    WHERE status NOT IN ('completed', 'cancelled') AND due_at < NOW();
CREATE INDEX idx_callback_requests_high_priority ON callback_requests(callback_request_id)
    WHERE priority = 'high' AND status NOT IN ('completed', 'cancelled');

-- Row Level Security policies
ALTER TABLE callback_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE callback_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_callback_capacity ENABLE ROW LEVEL SECURITY;
ALTER TABLE callback_metrics_daily ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_callback_performance ENABLE ROW LEVEL SECURITY;

-- RLS policy for callback_requests (tenant isolation)
CREATE POLICY callback_requests_tenant_isolation ON callback_requests
    FOR ALL USING (tenant_id = current_setting('app.current_tenant_id')::UUID);

-- Additional access control policies
CREATE POLICY callback_requests_agent_access ON callback_requests
    FOR ALL USING (agent_id = current_setting('app.current_user_id')::UUID OR
                   current_setting('app.user_role') IN ('admin', 'manager'));

-- RLS policy for callback_activities
CREATE POLICY callback_activities_tenant_isolation ON callback_activities
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM callback_requests cr
            WHERE cr.callback_request_id = callback_activities.callback_request_id
            AND cr.tenant_id = current_setting('app.current_tenant_id')::UUID
        )
    );

-- RLS policy for agent_callback_capacity
CREATE POLICY agent_callback_capacity_tenant_isolation ON agent_callback_capacity
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM portal_users pu
            WHERE pu.user_id = agent_callback_capacity.agent_id
            AND pu.tenant_id = current_setting('app.current_tenant_id')::UUID
        )
    );

-- Functions for callback management
CREATE OR REPLACE FUNCTION calculate_callback_priority_score(
    customer_id UUID,
    request_type VARCHAR(100),
    urgency_level VARCHAR(20),
    customer_value VARCHAR(20),
    age_hours INTEGER DEFAULT 0
) RETURNS DECIMAL(5,2) AS $$
DECLARE
    base_score DECIMAL(5,2) := 0;
    request_weights JSONB := '{
        "policy_issue": 90,
        "payment_problem": 85,
        "claim_assistance": 80,
        "general_inquiry": 60,
        "feedback": 40,
        "suggestion": 30
    }';
    urgency_modifiers JSONB := '{
        "critical": 20,
        "high": 15,
        "medium": 10,
        "low": 0
    }';
    value_modifiers JSONB := '{
        "platinum": 15,
        "gold": 10,
        "silver": 5,
        "bronze": 0
    }';
BEGIN
    -- Get base score from request type
    base_score := COALESCE((request_weights->>request_type)::DECIMAL, 50.0);

    -- Add urgency modifier
    base_score := base_score + COALESCE((urgency_modifiers->>urgency_level)::DECIMAL, 0);

    -- Add customer value modifier
    base_score := base_score + COALESCE((value_modifiers->>customer_value)::DECIMAL, 0);

    -- Add age-based urgency
    base_score := base_score + LEAST(age_hours::DECIMAL / 4, 10);

    RETURN LEAST(100.0, GREATEST(1.0, base_score));
END;
$$ LANGUAGE plpgsql;

-- Function to assign priority category based on score
CREATE OR REPLACE FUNCTION get_callback_priority_category(score DECIMAL(5,2))
RETURNS callback_priority AS $$
BEGIN
    IF score >= 85 THEN
        RETURN 'high'::callback_priority;
    ELSIF score >= 70 THEN
        RETURN 'medium'::callback_priority;
    ELSE
        RETURN 'low'::callback_priority;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate SLA due date
CREATE OR REPLACE FUNCTION calculate_callback_due_date(
    created_at TIMESTAMP,
    priority callback_priority
) RETURNS TIMESTAMP AS $$
DECLARE
    sla_hours INTEGER;
BEGIN
    -- Get SLA hours based on priority
    CASE priority
        WHEN 'high' THEN sla_hours := 2;    -- 2 hours for high priority
        WHEN 'medium' THEN sla_hours := 8;  -- 8 hours for medium priority
        WHEN 'low' THEN sla_hours := 24;    -- 24 hours for low priority
        ELSE sla_hours := 24;
    END CASE;

    RETURN created_at + INTERVAL '1 hour' * sla_hours;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically set due date when callback is created
CREATE OR REPLACE FUNCTION set_callback_due_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.due_at IS NULL THEN
        NEW.due_at := calculate_callback_due_date(NEW.created_at, NEW.priority);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER callback_due_date_trigger
    BEFORE INSERT ON callback_requests
    FOR EACH ROW
    EXECUTE FUNCTION set_callback_due_date();

-- Function to update callback status timestamps
CREATE OR REPLACE FUNCTION update_callback_timestamps()
RETURNS TRIGGER AS $$
BEGIN
    -- Set assigned_at when status changes to assigned
    IF NEW.status = 'assigned' AND OLD.status != 'assigned' THEN
        NEW.assigned_at := NOW();
    END IF;

    -- Set started_at when status changes to in_progress
    IF NEW.status = 'in_progress' AND OLD.status != 'in_progress' THEN
        NEW.started_at := NOW();
    END IF;

    -- Set completed_at when status changes to completed
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        NEW.completed_at := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER callback_timestamps_trigger
    BEFORE UPDATE ON callback_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_callback_timestamps();
```

This comprehensive database design provides a solid foundation for the Agent Mitra platform, ensuring scalability, security, performance, and compliance with industry standards. The schema supports multi-tenancy, advanced analytics, and complex business workflows while maintaining data integrity and regulatory compliance.
