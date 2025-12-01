-- Agent Mitra - Migration V57: Fix Audit Trigger Function
-- This migration fixes the audit_tenant_data_changes() function to be generic
-- and work with all tables, not just those with specific field names

-- =====================================================
-- FIX AUDIT FUNCTION TO BE GENERIC
-- =====================================================

-- Drop existing triggers first to avoid conflicts
DROP TRIGGER IF EXISTS audit_tenant_data_changes_trigger ON lic_schema.insurance_policies;
DROP TRIGGER IF EXISTS audit_tenant_data_changes_trigger ON lic_schema.agents;
DROP TRIGGER IF EXISTS audit_tenant_data_changes_trigger ON lic_schema.users;

-- Recreate audit function to be generic and handle any table structure
CREATE OR REPLACE FUNCTION lic_schema.audit_tenant_data_changes()
RETURNS TRIGGER AS $$
DECLARE
    current_tenant UUID;
    current_user_id UUID;
    record_id_field TEXT;
    record_id_value UUID;
    table_primary_key TEXT;
BEGIN
    -- Get current tenant and user from context
    current_tenant := lic_schema.current_tenant_id();
    current_user_id := NULLIF(current_setting('app.current_user_id', TRUE), '')::UUID;

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
        NULLIF(current_setting('app.client_ip', TRUE), '')::inet,
        NULLIF(current_setting('app.user_agent', TRUE), '')
    );

    RETURN CASE
        WHEN TG_OP = 'DELETE' THEN OLD
        ELSE NEW
    END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- RECREATE TRIGGERS WITH NEW FUNCTION
-- =====================================================

-- Insurance Policies trigger
CREATE TRIGGER audit_tenant_data_changes_trigger
    AFTER INSERT OR UPDATE OR DELETE ON lic_schema.insurance_policies
    FOR EACH ROW EXECUTE FUNCTION lic_schema.audit_tenant_data_changes();

-- Agents trigger
CREATE TRIGGER audit_tenant_data_changes_trigger
    AFTER INSERT OR UPDATE OR DELETE ON lic_schema.agents
    FOR EACH ROW EXECUTE FUNCTION lic_schema.audit_tenant_data_changes();

-- Users trigger
CREATE TRIGGER audit_tenant_data_changes_trigger
    AFTER INSERT OR UPDATE OR DELETE ON lic_schema.users
    FOR EACH ROW EXECUTE FUNCTION lic_schema.audit_tenant_data_changes();

-- Policyholders trigger
CREATE TRIGGER audit_tenant_data_changes_trigger
    AFTER INSERT OR UPDATE OR DELETE ON lic_schema.policyholders
    FOR EACH ROW EXECUTE FUNCTION lic_schema.audit_tenant_data_changes();

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================
