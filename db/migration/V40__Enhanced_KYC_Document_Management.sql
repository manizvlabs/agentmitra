-- Enhanced KYC document management with OCR tracking
CREATE TABLE IF NOT EXISTS lic_schema.kyc_documents (
    document_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL, -- 'aadhaar', 'voter_id', 'passport', 'selfie'
    file_path VARCHAR(500) NOT NULL,
    ocr_extracted_data JSONB,
    verification_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'verified', 'rejected', 'manual_review'
    rejection_reason TEXT,
    verified_at TIMESTAMP,
    verified_by UUID REFERENCES lic_schema.users(user_id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_kyc_documents_user_id ON lic_schema.kyc_documents(user_id);
CREATE INDEX IF NOT EXISTS idx_kyc_documents_status ON lic_schema.kyc_documents(verification_status);
CREATE INDEX IF NOT EXISTS idx_kyc_documents_type ON lic_schema.kyc_documents(document_type);

-- OCR processing results
CREATE TABLE IF NOT EXISTS lic_schema.document_ocr_results (
    ocr_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID REFERENCES lic_schema.kyc_documents(document_id) ON DELETE CASCADE,
    ocr_provider VARCHAR(50), -- 'google_vision', 'aws_textract', 'azure_form'
    confidence_score DECIMAL(5,2),
    extracted_fields JSONB, -- name, dob, address, document_number, etc.
    processing_status VARCHAR(50) DEFAULT 'processing',
    processed_at TIMESTAMP,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Add indexes for OCR results
CREATE INDEX IF NOT EXISTS idx_ocr_results_document_id ON lic_schema.document_ocr_results(document_id);
CREATE INDEX IF NOT EXISTS idx_ocr_results_status ON lic_schema.document_ocr_results(processing_status);

-- Manual review queue
CREATE TABLE IF NOT EXISTS lic_schema.kyc_manual_reviews (
    review_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID REFERENCES lic_schema.kyc_documents(document_id) ON DELETE CASCADE,
    reviewer_id UUID REFERENCES lic_schema.users(user_id),
    review_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
    review_notes TEXT,
    reviewed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Add indexes for manual reviews
CREATE INDEX IF NOT EXISTS idx_manual_reviews_document_id ON lic_schema.kyc_manual_reviews(document_id);
CREATE INDEX IF NOT EXISTS idx_manual_reviews_reviewer_id ON lic_schema.kyc_manual_reviews(reviewer_id);
CREATE INDEX IF NOT EXISTS idx_manual_reviews_status ON lic_schema.kyc_manual_reviews(review_status);

-- Add updated_at trigger for kyc_documents
CREATE OR REPLACE FUNCTION update_kyc_documents_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_kyc_documents_updated_at
    BEFORE UPDATE ON lic_schema.kyc_documents
    FOR EACH ROW
    EXECUTE FUNCTION update_kyc_documents_updated_at();
