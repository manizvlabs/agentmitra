-- Add tenant_id column to presentation_media table for multi-tenancy support
DO $$
BEGIN
    -- Add tenant_id column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'lic_schema'
        AND table_name = 'presentation_media'
        AND column_name = 'tenant_id'
    ) THEN
        ALTER TABLE lic_schema.presentation_media
        ADD COLUMN tenant_id UUID REFERENCES lic_schema.tenants(tenant_id);

        -- Set default tenant_id for existing records based on agent's tenant
        UPDATE lic_schema.presentation_media pm
        SET tenant_id = a.tenant_id
        FROM lic_schema.agents a
        WHERE pm.agent_id = a.agent_id AND pm.tenant_id IS NULL;

        -- For any remaining records without tenant, set a default
        UPDATE lic_schema.presentation_media
        SET tenant_id = '00000000-0000-0000-0000-000000000000'
        WHERE tenant_id IS NULL;

        -- Make tenant_id NOT NULL
        ALTER TABLE lic_schema.presentation_media
        ALTER COLUMN tenant_id SET NOT NULL;

        RAISE NOTICE 'Added tenant_id column to presentation_media table';
    ELSE
        RAISE NOTICE 'tenant_id column already exists in presentation_media table';
    END IF;

    -- Add index if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE schemaname = 'lic_schema'
        AND tablename = 'presentation_media'
        AND indexname = 'idx_presentation_media_tenant_id'
    ) THEN
        CREATE INDEX idx_presentation_media_tenant_id ON lic_schema.presentation_media(tenant_id);
        RAISE NOTICE 'Created index idx_presentation_media_tenant_id';
    ELSE
        RAISE NOTICE 'Index idx_presentation_media_tenant_id already exists';
    END IF;
END $$;
