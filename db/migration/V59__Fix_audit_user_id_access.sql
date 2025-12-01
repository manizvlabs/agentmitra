-- Agent Mitra - Migration V59: Fix Audit User ID Access
-- This migration fixes the audit function to properly handle user_id access for different tables

-- =====================================================
-- UPDATE AUDIT FUNCTION TO HANDLE USER_ID PROPERLY
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
    target_user_value UUID;
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

    -- Get target user ID safely
    target_user_value := NULL;
    IF TG_OP = 'DELETE' THEN
        -- For DELETE operations, try to get user_id from OLD record
        BEGIN
            CASE TG_TABLE_NAME
                WHEN 'users' THEN
                    EXECUTE 'SELECT ($1).user_id' INTO target_user_value USING OLD;
                WHEN 'agents' THEN
                    EXECUTE 'SELECT ($1).user_id' INTO target_user_value USING OLD;
                WHEN 'policyholders' THEN
                    EXECUTE 'SELECT ($1).user_id' INTO target_user_value USING OLD;
                -- For other tables, leave as NULL
                ELSE
                    target_user_value := NULL;
            END CASE;
        EXCEPTION WHEN OTHERS THEN
            target_user_value := NULL;
        END;
    ELSE
        -- For INSERT/UPDATE operations, try to get user_id from NEW record
        BEGIN
            CASE TG_TABLE_NAME
                WHEN 'users' THEN
                    EXECUTE 'SELECT ($1).user_id' INTO target_user_value USING NEW;
                WHEN 'agents' THEN
                    EXECUTE 'SELECT ($1).user_id' INTO target_user_value USING NEW;
                WHEN 'policyholders' THEN
                    EXECUTE 'SELECT ($1).user_id' INTO target_user_value USING NEW;
                -- For other tables, leave as NULL
                ELSE
                    target_user_value := NULL;
            END CASE;
        EXCEPTION WHEN OTHERS THEN
            target_user_value := NULL;
        END;
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
        target_user_value,
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
