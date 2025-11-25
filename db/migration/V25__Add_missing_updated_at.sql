ALTER TABLE lic_schema.callback_requests ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();
