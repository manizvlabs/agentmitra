-- Agent Mitra - Migration V12: Consolidate All Tables into lic_schema
-- This migration consolidates all tables from shared and public schemas into lic_schema
-- to create a single comprehensive schema for the agentmitra_dev database.
-- Tables are only created if they don't already exist to avoid duplication.

-- =====================================================
-- SHARED SCHEMA TABLES MIGRATION TO LIC_SCHEMA
-- =====================================================

-- Create shared.tenants table in lic_schema (if not exists)
CREATE TABLE IF NOT EXISTS lic_schema.tenants (
    tenant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_code VARCHAR(20) UNIQUE NOT NULL,
    tenant_name VARCHAR(255) NOT NULL,
    tenant_type VARCHAR(50) NOT NULL, -- 'insurance_provider', 'independent_agent', 'agent_network'
    schema_name VARCHAR(100) UNIQUE,
    parent_tenant_id UUID REFERENCES lic_schema.tenants(tenant_id),
    status VARCHAR(20) DEFAULT 'active',
    subscription_plan VARCHAR(50),
    trial_end_date TIMESTAMP,
    max_users INTEGER DEFAULT 1000,
    storage_limit_gb INTEGER DEFAULT 10,
    api_rate_limit INTEGER DEFAULT 1000,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create shared.tenant_config table in lic_schema (if not exists)
CREATE TABLE IF NOT EXISTS lic_schema.tenant_config (
    config_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES lic_schema.tenants(tenant_id),
    config_key VARCHAR(100) NOT NULL,
    config_value JSONB,
    config_type VARCHAR(50) DEFAULT 'string', -- 'string', 'number', 'boolean', 'json'
    is_encrypted BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(tenant_id, config_key)
);

-- Create shared.countries table in lic_schema (if not exists)
CREATE TABLE IF NOT EXISTS lic_schema.countries (
    country_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_code VARCHAR(3) UNIQUE NOT NULL, -- ISO 3166-1 alpha-3
    country_name VARCHAR(100) NOT NULL,
    currency_code VARCHAR(3), -- ISO 4217
    phone_code VARCHAR(5),
    timezone VARCHAR(50),
    status VARCHAR(20) DEFAULT 'active'
);

-- Create shared.languages table in lic_schema (if not exists)
CREATE TABLE IF NOT EXISTS lic_schema.languages (
    language_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    language_code VARCHAR(10) UNIQUE NOT NULL, -- ISO 639-1
    language_name VARCHAR(100) NOT NULL,
    native_name VARCHAR(100),
    rtl BOOLEAN DEFAULT false, -- Right-to-left
    status VARCHAR(20) DEFAULT 'active'
);

-- Create shared.insurance_categories table in lic_schema (if not exists)
CREATE TABLE IF NOT EXISTS lic_schema.insurance_categories (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_code VARCHAR(20) UNIQUE NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    category_type VARCHAR(50), -- 'life', 'health', 'general', 'motor'
    description TEXT,
    status VARCHAR(20) DEFAULT 'active'
);

-- Create shared.insurance_providers table in lic_schema (if not exists)
CREATE TABLE IF NOT EXISTS lic_schema.insurance_providers (
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

-- Create shared.data_imports table in lic_schema (if not exists)
CREATE TABLE IF NOT EXISTS lic_schema.data_imports (
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

-- Create shared.import_jobs table in lic_schema (if not exists)
CREATE TABLE IF NOT EXISTS lic_schema.import_jobs (
    job_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    import_id UUID REFERENCES lic_schema.data_imports(import_id),
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

-- Create shared.customer_data_mapping table in lic_schema (if not exists)
CREATE TABLE IF NOT EXISTS lic_schema.customer_data_mapping (
    mapping_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    import_id UUID REFERENCES lic_schema.data_imports(import_id),
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

-- Create shared.data_sync_status table in lic_schema (if not exists)
CREATE TABLE IF NOT EXISTS lic_schema.data_sync_status (
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

-- Create shared.whatsapp_templates table in lic_schema (if not exists)
CREATE TABLE IF NOT EXISTS lic_schema.whatsapp_templates (
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

-- =====================================================
-- DATA MIGRATION FROM SHARED TO LIC_SCHEMA
-- =====================================================

-- Migrate data from shared.tenants to lic_schema.tenants (only if shared.tenants exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'shared' AND table_name = 'tenants') THEN
        INSERT INTO lic_schema.tenants (
            tenant_id, tenant_code, tenant_name, tenant_type, schema_name,
            parent_tenant_id, status, subscription_plan, trial_end_date,
            max_users, storage_limit_gb, api_rate_limit, created_at, updated_at
        )
        SELECT
            tenant_id, tenant_code, tenant_name, tenant_type, schema_name,
            parent_tenant_id, status, subscription_plan, trial_end_date,
            max_users, storage_limit_gb, api_rate_limit, created_at, updated_at
        FROM shared.tenants
        ON CONFLICT (tenant_id) DO NOTHING;
    END IF;
END $$;

-- Migrate data from shared.tenant_config to lic_schema.tenant_config
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'shared' AND table_name = 'tenant_config') THEN
        INSERT INTO lic_schema.tenant_config (
            config_id, tenant_id, config_key, config_value, config_type,
            is_encrypted, created_at, updated_at
        )
        SELECT
            config_id, tenant_id, config_key, config_value, config_type,
            is_encrypted, created_at, updated_at
        FROM shared.tenant_config
        ON CONFLICT (config_id) DO NOTHING;
    END IF;
END $$;

-- Migrate data from shared.countries to lic_schema.countries
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'shared' AND table_name = 'countries') THEN
        INSERT INTO lic_schema.countries (
            country_id, country_code, country_name, currency_code,
            phone_code, timezone, status
        )
        SELECT
            country_id, country_code, country_name, currency_code,
            phone_code, timezone, status
        FROM shared.countries
        ON CONFLICT (country_id) DO NOTHING;
    END IF;
END $$;

-- Migrate data from shared.languages to lic_schema.languages
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'shared' AND table_name = 'languages') THEN
        INSERT INTO lic_schema.languages (
            language_id, language_code, language_name, native_name, rtl, status
        )
        SELECT
            language_id, language_code, language_name, native_name, rtl, status
        FROM shared.languages
        ON CONFLICT (language_id) DO NOTHING;
    END IF;
END $$;

-- Migrate data from shared.insurance_categories to lic_schema.insurance_categories
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'shared' AND table_name = 'insurance_categories') THEN
        INSERT INTO lic_schema.insurance_categories (
            category_id, category_code, category_name, category_type, description, status
        )
        SELECT
            category_id, category_code, category_name, category_type, description, status
        FROM shared.insurance_categories
        ON CONFLICT (category_id) DO NOTHING;
    END IF;
END $$;

-- Migrate data from shared.insurance_providers to lic_schema.insurance_providers
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'shared' AND table_name = 'insurance_providers') THEN
        INSERT INTO lic_schema.insurance_providers (
            provider_id, provider_code, provider_name, provider_type, description,
            api_endpoint, api_credentials, webhook_url, webhook_secret,
            license_number, regulatory_authority, established_year, headquarters,
            supported_languages, business_hours, service_regions, commission_structure,
            status, integration_status, last_sync_at, created_at, updated_at
        )
        SELECT
            provider_id, provider_code, provider_name, provider_type, description,
            api_endpoint, api_credentials, webhook_url, webhook_secret,
            license_number, regulatory_authority, established_year, headquarters,
            supported_languages, business_hours, service_regions, commission_structure,
            status, integration_status, last_sync_at, created_at, updated_at
        FROM shared.insurance_providers
        ON CONFLICT (provider_id) DO NOTHING;
    END IF;
END $$;

-- Migrate data from shared.data_imports to lic_schema.data_imports
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'shared' AND table_name = 'data_imports') THEN
        INSERT INTO lic_schema.data_imports (
            import_id, agent_id, file_name, file_path, file_size_bytes, import_type,
            status, total_records, processed_records, error_records, error_details,
            processing_started_at, processing_completed_at, created_at, updated_at
        )
        SELECT
            import_id, agent_id, file_name, file_path, file_size_bytes, import_type,
            status, total_records, processed_records, error_records, error_details,
            processing_started_at, processing_completed_at, created_at, updated_at
        FROM shared.data_imports
        ON CONFLICT (import_id) DO NOTHING;
    END IF;
END $$;

-- Migrate data from shared.import_jobs to lic_schema.import_jobs
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'shared' AND table_name = 'import_jobs') THEN
        INSERT INTO lic_schema.import_jobs (
            job_id, import_id, job_type, priority, status, retry_count,
            max_retries, error_message, started_at, completed_at, created_at
        )
        SELECT
            job_id, import_id, job_type, priority, status, retry_count,
            max_retries, error_message, started_at, completed_at, created_at
        FROM shared.import_jobs
        ON CONFLICT (job_id) DO NOTHING;
    END IF;
END $$;

-- Migrate data from shared.customer_data_mapping to lic_schema.customer_data_mapping
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'shared' AND table_name = 'customer_data_mapping') THEN
        INSERT INTO lic_schema.customer_data_mapping (
            mapping_id, import_id, excel_row_number, customer_name, phone_number,
            email, policy_number, date_of_birth, address, raw_excel_data,
            mapping_status, validation_errors, created_customer_id, created_at
        )
        SELECT
            mapping_id, import_id, excel_row_number, customer_name, phone_number,
            email, policy_number, date_of_birth, address, raw_excel_data,
            mapping_status, validation_errors, created_customer_id, created_at
        FROM shared.customer_data_mapping
        ON CONFLICT (mapping_id) DO NOTHING;
    END IF;
END $$;

-- Migrate data from shared.data_sync_status to lic_schema.data_sync_status
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'shared' AND table_name = 'data_sync_status') THEN
        INSERT INTO lic_schema.data_sync_status (
            sync_id, agent_id, customer_id, last_sync_at, sync_status, sync_type,
            error_message, retry_count, next_retry_at, created_at, updated_at
        )
        SELECT
            sync_id, agent_id, customer_id, last_sync_at, sync_status, sync_type,
            error_message, retry_count, next_retry_at, created_at, updated_at
        FROM shared.data_sync_status
        ON CONFLICT (sync_id) DO NOTHING;
    END IF;
END $$;

-- Migrate data from shared.whatsapp_templates to lic_schema.whatsapp_templates
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'shared' AND table_name = 'whatsapp_templates') THEN
        INSERT INTO lic_schema.whatsapp_templates (
            template_id, template_name, category, language, content, variables,
            approval_status, whatsapp_template_id, created_at
        )
        SELECT
            template_id, template_name, category, language, content, variables,
            approval_status, whatsapp_template_id, created_at
        FROM shared.whatsapp_templates
        ON CONFLICT (template_id) DO NOTHING;
    END IF;
END $$;

-- =====================================================
-- CREATE INDEXES FOR MIGRATED TABLES
-- =====================================================

-- Indexes for migrated shared tables in lic_schema
CREATE INDEX IF NOT EXISTS idx_tenants_tenant_code ON lic_schema.tenants(tenant_code);
CREATE INDEX IF NOT EXISTS idx_tenants_status ON lic_schema.tenants(status);
CREATE INDEX IF NOT EXISTS idx_tenant_config_tenant_id ON lic_schema.tenant_config(tenant_id);

CREATE INDEX IF NOT EXISTS idx_countries_country_code ON lic_schema.countries(country_code);
CREATE INDEX IF NOT EXISTS idx_languages_language_code ON lic_schema.languages(language_code);
CREATE INDEX IF NOT EXISTS idx_insurance_categories_category_code ON lic_schema.insurance_categories(category_code);
CREATE INDEX IF NOT EXISTS idx_insurance_providers_provider_code ON lic_schema.insurance_providers(provider_code);

CREATE INDEX IF NOT EXISTS idx_data_imports_agent_status ON lic_schema.data_imports(agent_id, status);
CREATE INDEX IF NOT EXISTS idx_import_jobs_status ON lic_schema.import_jobs(status);
CREATE INDEX IF NOT EXISTS idx_customer_data_mapping_import ON lic_schema.customer_data_mapping(import_id);
CREATE INDEX IF NOT EXISTS idx_data_sync_status_agent ON lic_schema.data_sync_status(agent_id);

CREATE INDEX IF NOT EXISTS idx_whatsapp_templates_category ON lic_schema.whatsapp_templates(category);
CREATE INDEX IF NOT EXISTS idx_whatsapp_templates_status ON lic_schema.whatsapp_templates(approval_status);

-- =====================================================
-- UPDATE FOREIGN KEY REFERENCES
-- =====================================================

-- Update foreign key references in existing lic_schema tables to point to migrated tables
-- (These will be handled automatically by PostgreSQL since we're using the same table names)

-- =====================================================
-- CLEANUP SHARED SCHEMA (Optional - commented out for safety)
-- =====================================================

-- Note: The following DROP operations are commented out for safety.
-- They should only be executed after verifying that all data has been successfully migrated
-- and that the application is working correctly with the consolidated schema.

/*
-- Drop shared schema tables after successful migration
DROP TABLE IF EXISTS shared.whatsapp_templates CASCADE;
DROP TABLE IF EXISTS shared.data_sync_status CASCADE;
DROP TABLE IF EXISTS shared.customer_data_mapping CASCADE;
DROP TABLE IF EXISTS shared.import_jobs CASCADE;
DROP TABLE IF EXISTS shared.data_imports CASCADE;
DROP TABLE IF EXISTS shared.insurance_providers CASCADE;
DROP TABLE IF EXISTS shared.insurance_categories CASCADE;
DROP TABLE IF EXISTS shared.languages CASCADE;
DROP TABLE IF EXISTS shared.countries CASCADE;
DROP TABLE IF EXISTS shared.tenant_config CASCADE;
DROP TABLE IF EXISTS shared.tenants CASCADE;

-- Drop shared schema if empty
DROP SCHEMA IF EXISTS shared CASCADE;
*/

-- =====================================================
-- COMMENTS AND DOCUMENTATION
-- =====================================================

COMMENT ON TABLE lic_schema.tenants IS 'Master tenant registry (migrated from shared.tenants)';
COMMENT ON TABLE lic_schema.tenant_config IS 'Tenant configuration settings (migrated from shared.tenant_config)';
COMMENT ON TABLE lic_schema.countries IS 'Countries and regions reference data (migrated from shared.countries)';
COMMENT ON TABLE lic_schema.languages IS 'Supported languages reference data (migrated from shared.languages)';
COMMENT ON TABLE lic_schema.insurance_categories IS 'Insurance product categories (migrated from shared.insurance_categories)';
COMMENT ON TABLE lic_schema.insurance_providers IS 'Insurance providers master data (migrated from shared.insurance_providers)';
COMMENT ON TABLE lic_schema.data_imports IS 'Data import/export tracking (migrated from shared.data_imports)';
COMMENT ON TABLE lic_schema.import_jobs IS 'Background import job processing (migrated from shared.import_jobs)';
COMMENT ON TABLE lic_schema.customer_data_mapping IS 'Excel import data mapping (migrated from shared.customer_data_mapping)';
COMMENT ON TABLE lic_schema.data_sync_status IS 'Customer data synchronization status (migrated from shared.data_sync_status)';
COMMENT ON TABLE lic_schema.whatsapp_templates IS 'WhatsApp message templates (migrated from shared.whatsapp_templates)';

-- =====================================================
-- MIGRATION COMPLETION LOG
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Schema consolidation migration V12 completed successfully.';
    RAISE NOTICE 'All shared schema tables have been migrated to lic_schema.';
    RAISE NOTICE 'Please verify data integrity and update application configurations.';
    RAISE NOTICE 'Consider updating flyway.conf to use only lic_schema.';
END $$;
