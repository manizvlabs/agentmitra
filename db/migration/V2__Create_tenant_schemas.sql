-- Agent Mitra - Migration V2: Create Tenant Management and System Reference Tables
-- This migration creates tenant management tables and system reference data tables in shared schema

-- =====================================================
-- TENANT MANAGEMENT TABLES
-- =====================================================

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

-- =====================================================
-- SYSTEM REFERENCE DATA TABLES
-- =====================================================

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
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'inactive', 'suspended', 'under_maintenance'
    integration_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'testing', 'active'
    last_sync_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- DATA IMPORT/EXPORT TABLES (Agent Configuration Portal)
-- =====================================================

-- Data import/export tracking for agent configuration portal
CREATE TABLE shared.data_imports (
    import_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID, -- Will reference lic_schema.agents(agent_id) after that table is created
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
    agent_id UUID, -- Will reference lic_schema.agents(agent_id) after that table is created
    customer_id UUID, -- Will reference lic_schema.policyholders(policyholder_id) after that table is created
    last_sync_at TIMESTAMP DEFAULT NOW(),
    sync_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'in_progress', 'completed', 'failed'
    sync_type VARCHAR(50) DEFAULT 'initial', -- 'initial', 'update', 'manual'
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    next_retry_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- INDEXES
-- =====================================================

CREATE INDEX idx_tenants_tenant_code ON shared.tenants(tenant_code);
CREATE INDEX idx_tenants_status ON shared.tenants(status);
CREATE INDEX idx_tenant_config_tenant_id ON shared.tenant_config(tenant_id);

CREATE INDEX idx_countries_country_code ON shared.countries(country_code);
CREATE INDEX idx_languages_language_code ON shared.languages(language_code);
CREATE INDEX idx_insurance_categories_category_code ON shared.insurance_categories(category_code);
CREATE INDEX idx_insurance_providers_provider_code ON shared.insurance_providers(provider_code);

CREATE INDEX idx_data_imports_agent_status ON shared.data_imports(agent_id, status);
CREATE INDEX idx_import_jobs_status ON shared.import_jobs(status);
CREATE INDEX idx_customer_data_mapping_import ON shared.customer_data_mapping(import_id);
CREATE INDEX idx_data_sync_status_agent ON shared.data_sync_status(agent_id);

