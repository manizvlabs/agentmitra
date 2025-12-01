-- Agent Mitra - Migration V58: Fix Audit Context Settings
-- This migration fixes the audit function to handle missing context settings gracefully

-- =====================================================
-- UPDATE AUDIT FUNCTION TO HANDLE MISSING CONTEXT
-- =====================================================

CREATE OR REPLACE FUNCTION lic_schema.audit_tenant_data_changes()
RETURNS TRIGGER AS $$
DECLARE
    current_tenant UUID;
    current_user_id UUID;
    record_id_field TEXT;
    record_id_value UUID;
    table_primary_key TEXT;
    client_ip_value INET;
    user_agent_value TEXT;
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
        CASE
            WHEN TG_OP = 'DELETE' THEN
                CASE
                    WHEN TG_TABLE_NAME = 'users' THEN (OLD.user_id)
                    WHEN TG_TABLE_NAME = 'agents' THEN (OLD.user_id)
                    WHEN TG_TABLE_NAME = 'policyholders' THEN (OLD.user_id)
                    ELSE NULL
                END
            ELSE
                CASE
                    WHEN TG_TABLE_NAME = 'users' THEN (NEW.user_id)
                    WHEN TG_TABLE_NAME = 'agents' THEN (NEW.user_id)
                    WHEN TG_TABLE_NAME = 'policyholders' THEN (NEW.user_id)
                    ELSE NULL
                END
        END,
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================
