-- Create content table for generic content management
-- This table stores all types of content (videos, documents, images, etc.)

CREATE TABLE IF NOT EXISTS lic_schema.content (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_id VARCHAR(255) UNIQUE NOT NULL,
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    storage_key VARCHAR(500) NOT NULL,
    media_url VARCHAR(1000) NOT NULL,
    file_hash VARCHAR(64) NOT NULL,
    file_size BIGINT NOT NULL,
    mime_type VARCHAR(100) NOT NULL,

    -- Content classification
    content_type VARCHAR(50) NOT NULL, -- video, document, image, other
    category VARCHAR(100) NOT NULL, -- presentations, training, marketing, etc.
    sub_category VARCHAR(100),

    -- Metadata
    tags JSON,
    content_metadata JSON,
    description TEXT,

    -- Processing information
    processing_status VARCHAR(50) NOT NULL DEFAULT 'pending', -- pending, processing, completed, failed
    processing_started_at TIMESTAMP WITH TIME ZONE,
    processing_completed_at TIMESTAMP WITH TIME ZONE,
    processing_error TEXT,

    -- Video-specific metadata
    video_duration FLOAT,
    video_resolution VARCHAR(20),
    video_bitrate INTEGER,
    video_codec VARCHAR(50),

    -- Document-specific metadata
    page_count INTEGER,
    word_count INTEGER,
    text_content TEXT,
    document_language VARCHAR(10),

    -- Image-specific metadata
    image_width INTEGER,
    image_height INTEGER,
    image_color_depth INTEGER,
    image_format VARCHAR(20),

    -- Access control
    uploader_id UUID NOT NULL REFERENCES lic_schema.users(user_id),
    owner_id UUID NOT NULL REFERENCES lic_schema.users(user_id),
    tenant_id UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
    is_public BOOLEAN DEFAULT FALSE,
    allowed_users JSON,
    share_token VARCHAR(255),

    -- Usage statistics
    view_count INTEGER NOT NULL DEFAULT 0,
    download_count INTEGER NOT NULL DEFAULT 0,
    last_accessed_at TIMESTAMP WITH TIME ZONE,

    -- Status and lifecycle
    status VARCHAR(50) DEFAULT 'active',

    -- Audit fields
    created_by UUID REFERENCES lic_schema.users(user_id),
    updated_by UUID REFERENCES lic_schema.users(user_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_content_content_id ON lic_schema.content(content_id);
CREATE INDEX IF NOT EXISTS idx_content_uploader_id ON lic_schema.content(uploader_id);
CREATE INDEX IF NOT EXISTS idx_content_tenant_id ON lic_schema.content(tenant_id);
CREATE INDEX IF NOT EXISTS idx_content_content_type ON lic_schema.content(content_type);
CREATE INDEX IF NOT EXISTS idx_content_category ON lic_schema.content(category);
CREATE INDEX IF NOT EXISTS idx_content_status ON lic_schema.content(status);
CREATE INDEX IF NOT EXISTS idx_content_file_hash ON lic_schema.content(file_hash);
CREATE INDEX IF NOT EXISTS idx_content_created_at ON lic_schema.content(created_at);

-- Add comments
COMMENT ON TABLE lic_schema.content IS 'Generic content storage table for all media types';
COMMENT ON COLUMN lic_schema.content.content_id IS 'Unique identifier for content (can be used in URLs)';
COMMENT ON COLUMN lic_schema.content.storage_key IS 'Key/path in storage system (MinIO, S3, etc.)';
COMMENT ON COLUMN lic_schema.content.media_url IS 'Public URL for accessing the content';
COMMENT ON COLUMN lic_schema.content.file_hash IS 'SHA-256 hash of the file for integrity checking';
COMMENT ON COLUMN lic_schema.content.metadata IS 'Flexible JSON metadata for content-specific data';
