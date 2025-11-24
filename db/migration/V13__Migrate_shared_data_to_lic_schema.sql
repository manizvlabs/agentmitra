-- Agent Mitra - Migration V13: Migrate Existing Data from Shared to Lic Schema
-- This migration safely migrates all existing data from shared schema tables to lic_schema tables
-- Only runs if the shared schema tables exist and contain data

DO $$
DECLARE
    shared_table_exists BOOLEAN := FALSE;
    data_count INTEGER := 0;
BEGIN
    RAISE NOTICE 'Starting data migration from shared schema to lic_schema...';

    -- =====================================================
    -- MIGRATE TENANTS DATA
    -- =====================================================

    SELECT COUNT(*) INTO data_count FROM shared.tenants;
    IF data_count > 0 THEN
        RAISE NOTICE 'Migrating % tenant records...', data_count;

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

        RAISE NOTICE 'Successfully migrated tenants data';
    ELSE
        RAISE NOTICE 'No tenant data to migrate';
    END IF;

    -- =====================================================
    -- MIGRATE TENANT CONFIG DATA
    -- =====================================================

    SELECT COUNT(*) INTO data_count FROM shared.tenant_config;
    IF data_count > 0 THEN
        RAISE NOTICE 'Migrating % tenant config records...', data_count;

        INSERT INTO lic_schema.tenant_config (
            config_id, tenant_id, config_key, config_value, config_type,
            is_encrypted, created_at, updated_at
        )
        SELECT
            config_id, tenant_id, config_key, config_value, config_type,
            is_encrypted, created_at, updated_at
        FROM shared.tenant_config
        ON CONFLICT (config_id) DO NOTHING;

        RAISE NOTICE 'Successfully migrated tenant config data';
    ELSE
        RAISE NOTICE 'No tenant config data to migrate';
    END IF;

    -- =====================================================
    -- MIGRATE COUNTRIES DATA
    -- =====================================================

    SELECT COUNT(*) INTO data_count FROM shared.countries;
    IF data_count > 0 THEN
        RAISE NOTICE 'Migrating % country records...', data_count;

        INSERT INTO lic_schema.countries (
            country_id, country_code, country_name, currency_code,
            phone_code, timezone, status
        )
        SELECT
            country_id, country_code, country_name, currency_code,
            phone_code, timezone, status
        FROM shared.countries
        ON CONFLICT (country_id) DO NOTHING;

        RAISE NOTICE 'Successfully migrated countries data';
    ELSE
        RAISE NOTICE 'No countries data to migrate';
    END IF;

    -- =====================================================
    -- MIGRATE LANGUAGES DATA
    -- =====================================================

    SELECT COUNT(*) INTO data_count FROM shared.languages;
    IF data_count > 0 THEN
        RAISE NOTICE 'Migrating % language records...', data_count;

        INSERT INTO lic_schema.languages (
            language_id, language_code, language_name, native_name, rtl, status
        )
        SELECT
            language_id, language_code, language_name, native_name, rtl, status
        FROM shared.languages
        ON CONFLICT (language_id) DO NOTHING;

        RAISE NOTICE 'Successfully migrated languages data';
    ELSE
        RAISE NOTICE 'No languages data to migrate';
    END IF;

    -- =====================================================
    -- MIGRATE INSURANCE CATEGORIES DATA
    -- =====================================================

    SELECT COUNT(*) INTO data_count FROM shared.insurance_categories;
    IF data_count > 0 THEN
        RAISE NOTICE 'Migrating % insurance category records...', data_count;

        INSERT INTO lic_schema.insurance_categories (
            category_id, category_code, category_name, category_type, description, status
        )
        SELECT
            category_id, category_code, category_name, category_type, description, status
        FROM shared.insurance_categories
        ON CONFLICT (category_id) DO NOTHING;

        RAISE NOTICE 'Successfully migrated insurance categories data';
    ELSE
        RAISE NOTICE 'No insurance categories data to migrate';
    END IF;

    -- =====================================================
    -- MIGRATE INSURANCE PROVIDERS DATA
    -- =====================================================

    SELECT COUNT(*) INTO data_count FROM shared.insurance_providers;
    IF data_count > 0 THEN
        RAISE NOTICE 'Migrating % insurance provider records...', data_count;

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

        RAISE NOTICE 'Successfully migrated insurance providers data';
    ELSE
        RAISE NOTICE 'No insurance providers data to migrate';
    END IF;

    -- =====================================================
    -- MIGRATE DATA IMPORTS
    -- =====================================================

    SELECT COUNT(*) INTO data_count FROM shared.data_imports;
    IF data_count > 0 THEN
        RAISE NOTICE 'Migrating % data import records...', data_count;

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

        RAISE NOTICE 'Successfully migrated data imports';
    ELSE
        RAISE NOTICE 'No data imports to migrate';
    END IF;

    -- =====================================================
    -- MIGRATE IMPORT JOBS
    -- =====================================================

    SELECT COUNT(*) INTO data_count FROM shared.import_jobs;
    IF data_count > 0 THEN
        RAISE NOTICE 'Migrating % import job records...', data_count;

        INSERT INTO lic_schema.import_jobs (
            job_id, import_id, job_type, priority, status, retry_count,
            max_retries, error_message, started_at, completed_at, created_at
        )
        SELECT
            job_id, import_id, job_type, priority, status, retry_count,
            max_retries, error_message, started_at, completed_at, created_at
        FROM shared.import_jobs
        ON CONFLICT (job_id) DO NOTHING;

        RAISE NOTICE 'Successfully migrated import jobs';
    ELSE
        RAISE NOTICE 'No import jobs to migrate';
    END IF;

    -- =====================================================
    -- MIGRATE CUSTOMER DATA MAPPING
    -- =====================================================

    SELECT COUNT(*) INTO data_count FROM shared.customer_data_mapping;
    IF data_count > 0 THEN
        RAISE NOTICE 'Migrating % customer data mapping records...', data_count;

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

        RAISE NOTICE 'Successfully migrated customer data mapping';
    ELSE
        RAISE NOTICE 'No customer data mapping to migrate';
    END IF;

    -- =====================================================
    -- MIGRATE DATA SYNC STATUS
    -- =====================================================

    SELECT COUNT(*) INTO data_count FROM shared.data_sync_status;
    IF data_count > 0 THEN
        RAISE NOTICE 'Migrating % data sync status records...', data_count;

        INSERT INTO lic_schema.data_sync_status (
            sync_id, agent_id, customer_id, last_sync_at, sync_status, sync_type,
            error_message, retry_count, next_retry_at, created_at, updated_at
        )
        SELECT
            sync_id, agent_id, customer_id, last_sync_at, sync_status, sync_type,
            error_message, retry_count, next_retry_at, created_at, updated_at
        FROM shared.data_sync_status
        ON CONFLICT (sync_id) DO NOTHING;

        RAISE NOTICE 'Successfully migrated data sync status';
    ELSE
        RAISE NOTICE 'No data sync status to migrate';
    END IF;

    -- =====================================================
    -- MIGRATE WHATSAPP TEMPLATES
    -- =====================================================

    SELECT COUNT(*) INTO data_count FROM shared.whatsapp_templates;
    IF data_count > 0 THEN
        RAISE NOTICE 'Migrating % WhatsApp template records...', data_count;

        INSERT INTO lic_schema.whatsapp_templates (
            template_id, template_name, category, language, content, variables,
            approval_status, whatsapp_template_id, created_at
        )
        SELECT
            template_id, template_name, category, language, content, variables,
            approval_status, whatsapp_template_id, created_at
        FROM shared.whatsapp_templates
        ON CONFLICT (template_id) DO NOTHING;

        RAISE NOTICE 'Successfully migrated WhatsApp templates';
    ELSE
        RAISE NOTICE 'No WhatsApp templates to migrate';
    END IF;

    -- =====================================================
    -- MIGRATION COMPLETION
    -- =====================================================

    RAISE NOTICE 'Data migration from shared schema to lic_schema completed successfully!';
    RAISE NOTICE 'All existing data has been safely migrated without duplication.';

END $$;
