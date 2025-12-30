-- Repeatable migration to baseline Flyway
-- This ensures the flyway_schema_history table is properly set up

-- Drop existing empty table if it exists
DROP TABLE IF EXISTS lic_schema.flyway_schema_history;

-- Create the history table with proper structure
CREATE TABLE IF NOT EXISTS lic_schema.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);

-- Add constraints and indexes
ALTER TABLE ONLY lic_schema.flyway_schema_history
    DROP CONSTRAINT IF EXISTS flyway_schema_history_pk;
ALTER TABLE ONLY lic_schema.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);

DROP INDEX IF EXISTS lic_schema.flyway_schema_history_s_idx;
CREATE INDEX flyway_schema_history_s_idx ON lic_schema.flyway_schema_history USING btree (success);

-- Insert baseline record if table is empty
INSERT INTO lic_schema.flyway_schema_history (
    installed_rank, version, description, type, script, checksum, 
    installed_by, installed_on, execution_time, success
) 
SELECT 0, '71', 'Database restored from dump, baseline at V71', 'BASELINE', '<< Flyway Baseline >>', 
       NULL, 'manish', NOW(), 0, true
WHERE NOT EXISTS (SELECT 1 FROM lic_schema.flyway_schema_history WHERE installed_rank = 0);
