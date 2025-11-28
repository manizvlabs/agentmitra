-- Dedicated emergency contact management
CREATE TABLE IF NOT EXISTS lic_schema.emergency_contacts (
    contact_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    email VARCHAR(255),
    relationship VARCHAR(50) NOT NULL, -- 'spouse', 'parent', 'sibling', 'child', 'friend'
    address JSONB,
    is_primary BOOLEAN DEFAULT false,
    verification_status VARCHAR(50) DEFAULT 'unverified', -- 'unverified', 'verified', 'failed'
    verified_at TIMESTAMP,
    priority INTEGER DEFAULT 1, -- 1=primary, 2=secondary, etc.
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Add indexes for emergency contacts
CREATE INDEX IF NOT EXISTS idx_emergency_contacts_user_id ON lic_schema.emergency_contacts(user_id);
CREATE INDEX IF NOT EXISTS idx_emergency_contacts_primary ON lic_schema.emergency_contacts(user_id, is_primary);
CREATE INDEX IF NOT EXISTS idx_emergency_contacts_verification_status ON lic_schema.emergency_contacts(verification_status);

-- Emergency contact verification attempts
CREATE TABLE IF NOT EXISTS lic_schema.emergency_contact_verifications (
    verification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID REFERENCES lic_schema.emergency_contacts(contact_id) ON DELETE CASCADE,
    verification_method VARCHAR(50), -- 'sms', 'call', 'email'
    verification_code VARCHAR(10),
    attempts INTEGER DEFAULT 0,
    verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Add indexes for verification attempts
CREATE INDEX IF NOT EXISTS idx_emergency_verifications_contact_id ON lic_schema.emergency_contact_verifications(contact_id);
CREATE INDEX IF NOT EXISTS idx_emergency_verifications_verified ON lic_schema.emergency_contact_verifications(verified);

-- Add updated_at trigger for emergency_contacts
CREATE OR REPLACE FUNCTION update_emergency_contacts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_emergency_contacts_updated_at
    BEFORE UPDATE ON lic_schema.emergency_contacts
    FOR EACH ROW
    EXECUTE FUNCTION update_emergency_contacts_updated_at();

-- Constraint to ensure only one primary contact per user
ALTER TABLE lic_schema.emergency_contacts
ADD CONSTRAINT unique_primary_contact_per_user
EXCLUDE (user_id WITH =)
WHERE (is_primary = true);
