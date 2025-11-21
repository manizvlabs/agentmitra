-- Migration V6: Alter user_sessions token columns to TEXT for JWT tokens
-- JWT tokens are longer than VARCHAR(255), so we need TEXT type

ALTER TABLE lic_schema.user_sessions 
    ALTER COLUMN session_token TYPE TEXT,
    ALTER COLUMN refresh_token TYPE TEXT;

-- Add comment
COMMENT ON COLUMN lic_schema.user_sessions.session_token IS 'JWT access token (stored as TEXT to accommodate full token length)';
COMMENT ON COLUMN lic_schema.user_sessions.refresh_token IS 'JWT refresh token (stored as TEXT to accommodate full token length)';

