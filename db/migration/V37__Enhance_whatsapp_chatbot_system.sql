-- ========================================
-- Enhanced WhatsApp & Chatbot System Migration
-- ========================================
-- Enhances WhatsApp integration and chatbot capabilities with
-- actionable reports, conversation context, and advanced analytics

-- ========================================
-- Enhanced WhatsApp Message Table
-- ========================================
-- Add missing columns to existing whatsapp_messages table
ALTER TABLE whatsapp_messages ADD COLUMN IF NOT EXISTS id UUID DEFAULT gen_random_uuid();
ALTER TABLE whatsapp_messages ADD COLUMN IF NOT EXISTS whatsapp_message_id VARCHAR(255);
ALTER TABLE whatsapp_messages ADD COLUMN IF NOT EXISTS from_number VARCHAR(20);
ALTER TABLE whatsapp_messages ADD COLUMN IF NOT EXISTS to_number VARCHAR(20);
ALTER TABLE whatsapp_messages ADD COLUMN IF NOT EXISTS message_type VARCHAR(50) DEFAULT 'text';
ALTER TABLE whatsapp_messages ADD COLUMN IF NOT EXISTS media_caption TEXT;
ALTER TABLE whatsapp_messages ADD COLUMN IF NOT EXISTS media_mime_type VARCHAR(100);
ALTER TABLE whatsapp_messages ADD COLUMN IF NOT EXISTS media_file_size INTEGER;
ALTER TABLE whatsapp_messages ADD COLUMN IF NOT EXISTS timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE whatsapp_messages ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'received';
ALTER TABLE whatsapp_messages ADD COLUMN IF NOT EXISTS direction VARCHAR(10) DEFAULT 'inbound';
ALTER TABLE whatsapp_messages ADD COLUMN IF NOT EXISTS conversation_id VARCHAR(255);
ALTER TABLE whatsapp_messages ADD COLUMN IF NOT EXISTS session_id VARCHAR(255);
ALTER TABLE whatsapp_messages ADD COLUMN IF NOT EXISTS customer_id UUID;
ALTER TABLE whatsapp_messages ADD COLUMN IF NOT EXISTS context_data JSONB;
ALTER TABLE whatsapp_messages ADD COLUMN IF NOT EXISTS metadata JSONB;
ALTER TABLE whatsapp_messages ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- Update existing records to populate new columns where possible
UPDATE whatsapp_messages SET
    from_number = 'unknown',
    to_number = 'unknown',
    timestamp = created_at,
    direction = CASE WHEN sender_id IS NOT NULL THEN 'outbound' ELSE 'inbound' END
WHERE from_number IS NULL;

-- Make required columns NOT NULL after populating data
ALTER TABLE whatsapp_messages ALTER COLUMN from_number SET NOT NULL;
ALTER TABLE whatsapp_messages ALTER COLUMN to_number SET NOT NULL;
ALTER TABLE whatsapp_messages ALTER COLUMN message_type SET NOT NULL;
ALTER TABLE whatsapp_messages ALTER COLUMN timestamp SET NOT NULL;
ALTER TABLE whatsapp_messages ALTER COLUMN direction SET NOT NULL;

-- Add primary key constraint if it doesn't exist (use message_id as primary key for existing table)
-- Note: Existing table uses message_id as primary key, so we'll work with that

-- ========================================
-- WhatsApp Conversation Sessions Table
-- ========================================
CREATE TABLE IF NOT EXISTS whatsapp_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id VARCHAR(255) UNIQUE NOT NULL,
    customer_number VARCHAR(20) NOT NULL,
    agent_id UUID,
    status VARCHAR(50) DEFAULT 'active', -- active, closed, escalated
    start_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_message_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    message_count INTEGER DEFAULT 0,
    escalation_reason TEXT,
    escalation_timestamp TIMESTAMP WITH TIME ZONE,
    resolution_status VARCHAR(50), -- resolved, pending, unresolved
    resolution_notes TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- Actionable Reports Table
-- ========================================
CREATE TABLE IF NOT EXISTS actionable_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_id VARCHAR(50) UNIQUE NOT NULL,
    customer_id UUID NOT NULL,
    agent_id UUID,
    subject VARCHAR(500) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,
    source VARCHAR(50) NOT NULL, -- chatbot, whatsapp, manual
    priority VARCHAR(20) NOT NULL DEFAULT 'medium', -- low, medium, high, urgent
    status VARCHAR(50) DEFAULT 'pending', -- pending, in_progress, completed, cancelled
    sla_target_minutes INTEGER,
    escalation_level INTEGER DEFAULT 1,
    conversation_context JSONB,
    current_query TEXT,
    intent_analysis JSONB,
    complexity_score DECIMAL(3,2),
    key_issues JSONB,
    suggested_actions JSONB,
    priority_factors JSONB,
    conversation_timeline JSONB,
    resolution_details JSONB,
    resolution_time_minutes INTEGER,
    user_satisfaction_rating INTEGER CHECK (user_satisfaction_rating >= 1 AND user_satisfaction_rating <= 5),
    agent_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    due_by TIMESTAMP WITH TIME ZONE
);

-- ========================================
-- Enhanced Chatbot Analytics Table
-- ========================================
CREATE TABLE IF NOT EXISTS chatbot_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id VARCHAR(255) NOT NULL,
    user_id UUID,
    conversation_id VARCHAR(255),
    message_count INTEGER DEFAULT 0,
    total_messages INTEGER DEFAULT 0,
    average_response_time_ms DECIMAL(10,2),
    intent_distribution JSONB,
    sentiment_trend VARCHAR(20), -- improving, worsening, stable
    user_satisfaction_estimate VARCHAR(20), -- satisfied, dissatisfied, neutral
    resolution_indicators JSONB,
    conversation_quality_score DECIMAL(3,2),
    escalation_occurred BOOLEAN DEFAULT false,
    escalation_reason TEXT,
    video_recommendations_count INTEGER DEFAULT 0,
    video_recommendations_clicked INTEGER DEFAULT 0,
    language_used VARCHAR(10) DEFAULT 'en',
    device_info JSONB,
    start_time TIMESTAMP WITH TIME ZONE,
    end_time TIMESTAMP WITH TIME ZONE,
    duration_seconds INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- Knowledge Base Articles Table Enhancement
-- ========================================
-- Add missing columns to existing knowledge_base_articles table
ALTER TABLE knowledge_base_articles ADD COLUMN IF NOT EXISTS target_audience JSONB;
ALTER TABLE knowledge_base_articles ADD COLUMN IF NOT EXISTS is_published BOOLEAN DEFAULT true;
ALTER TABLE knowledge_base_articles ADD COLUMN IF NOT EXISTS helpful_votes INTEGER DEFAULT 0;
ALTER TABLE knowledge_base_articles ADD COLUMN IF NOT EXISTS not_helpful_votes INTEGER DEFAULT 0;
ALTER TABLE knowledge_base_articles ADD COLUMN IF NOT EXISTS last_reviewed_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE knowledge_base_articles ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP WITH TIME ZONE;

-- ========================================
-- Chatbot Intent Patterns Table Enhancement
-- ========================================
-- Add missing columns to existing chatbot_intents table
ALTER TABLE chatbot_intents ADD COLUMN IF NOT EXISTS training_examples JSONB;
ALTER TABLE chatbot_intents ADD COLUMN IF NOT EXISTS response_templates JSONB;
ALTER TABLE chatbot_intents ADD COLUMN IF NOT EXISTS keywords JSONB;
ALTER TABLE chatbot_intents ADD COLUMN IF NOT EXISTS confidence_threshold DECIMAL(3,2) DEFAULT 0.7;
ALTER TABLE chatbot_intents ADD COLUMN IF NOT EXISTS escalation_trigger BOOLEAN DEFAULT false;
ALTER TABLE chatbot_intents ADD COLUMN IF NOT EXISTS priority_boost INTEGER DEFAULT 0;
ALTER TABLE chatbot_intents ADD COLUMN IF NOT EXISTS usage_count INTEGER DEFAULT 0;
ALTER TABLE chatbot_intents ADD COLUMN IF NOT EXISTS success_rate DECIMAL(5,2) DEFAULT 0.00;
ALTER TABLE chatbot_intents ADD COLUMN IF NOT EXISTS created_by UUID;
ALTER TABLE chatbot_intents ADD COLUMN IF NOT EXISTS updated_by UUID;

-- ========================================
-- Conversation Context Storage Table
-- ========================================
CREATE TABLE IF NOT EXISTS conversation_contexts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    context_id VARCHAR(255) UNIQUE NOT NULL,
    session_id VARCHAR(255) NOT NULL,
    user_id UUID,
    channel VARCHAR(50) NOT NULL, -- app, whatsapp, web
    context_type VARCHAR(50) NOT NULL, -- chatbot, whatsapp, support
    context_data JSONB NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE,
    last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- Multi-language Support Tables
-- ========================================
CREATE TABLE IF NOT EXISTS language_translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    translation_key VARCHAR(255) NOT NULL,
    language_code VARCHAR(10) NOT NULL,
    translated_text TEXT NOT NULL,
    context VARCHAR(100), -- ui, chatbot, video, etc.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(translation_key, language_code, context)
);

-- ========================================
-- Indexes for Performance
-- ========================================
-- WhatsApp Messages Indexes
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_message_id ON whatsapp_messages(message_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_from_number ON whatsapp_messages(from_number);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_timestamp ON whatsapp_messages(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_conversation ON whatsapp_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_session ON whatsapp_messages(session_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_status ON whatsapp_messages(status);

-- WhatsApp Conversations Indexes
CREATE INDEX IF NOT EXISTS idx_whatsapp_conversations_customer ON whatsapp_conversations(customer_number);
CREATE INDEX IF NOT EXISTS idx_whatsapp_conversations_agent ON whatsapp_conversations(agent_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_conversations_status ON whatsapp_conversations(status);
CREATE INDEX IF NOT EXISTS idx_whatsapp_conversations_last_message ON whatsapp_conversations(last_message_time DESC);

-- Actionable Reports Indexes
CREATE INDEX IF NOT EXISTS idx_actionable_reports_report_id ON actionable_reports(report_id);
CREATE INDEX IF NOT EXISTS idx_actionable_reports_customer ON actionable_reports(customer_id);
CREATE INDEX IF NOT EXISTS idx_actionable_reports_agent ON actionable_reports(agent_id);
CREATE INDEX IF NOT EXISTS idx_actionable_reports_priority ON actionable_reports(priority);
CREATE INDEX IF NOT EXISTS idx_actionable_reports_status ON actionable_reports(status);
CREATE INDEX IF NOT EXISTS idx_actionable_reports_created ON actionable_reports(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_actionable_reports_due_by ON actionable_reports(due_by);
CREATE INDEX IF NOT EXISTS idx_actionable_reports_category ON actionable_reports(category);

-- Chatbot Analytics Indexes
CREATE INDEX IF NOT EXISTS idx_chatbot_analytics_session ON chatbot_analytics(session_id);
CREATE INDEX IF NOT EXISTS idx_chatbot_analytics_user ON chatbot_analytics(user_id);
CREATE INDEX IF NOT EXISTS idx_chatbot_analytics_conversation ON chatbot_analytics(conversation_id);
CREATE INDEX IF NOT EXISTS idx_chatbot_analytics_quality ON chatbot_analytics(conversation_quality_score DESC);

-- Knowledge Base Indexes
CREATE INDEX IF NOT EXISTS idx_knowledge_base_article_id ON knowledge_base_articles(article_id);
CREATE INDEX IF NOT EXISTS idx_knowledge_base_category ON knowledge_base_articles(category);
CREATE INDEX IF NOT EXISTS idx_knowledge_base_language ON knowledge_base_articles(language);
CREATE INDEX IF NOT EXISTS idx_knowledge_base_published ON knowledge_base_articles(is_published) WHERE is_published = true;
CREATE INDEX IF NOT EXISTS idx_knowledge_base_search_title ON knowledge_base_articles USING gin(to_tsvector('english', title));
CREATE INDEX IF NOT EXISTS idx_knowledge_base_search_content ON knowledge_base_articles USING gin(to_tsvector('english', content));
CREATE INDEX IF NOT EXISTS idx_knowledge_base_author ON knowledge_base_articles(author_id);
CREATE INDEX IF NOT EXISTS idx_knowledge_base_difficulty ON knowledge_base_articles(difficulty_level);

-- Intent Patterns Indexes
CREATE INDEX IF NOT EXISTS idx_chatbot_intents_name ON chatbot_intents(intent_name);
CREATE INDEX IF NOT EXISTS idx_chatbot_intents_category ON chatbot_intents(category);
CREATE INDEX IF NOT EXISTS idx_chatbot_intents_active ON chatbot_intents(is_active) WHERE is_active = true;

-- Conversation Context Indexes
CREATE INDEX IF NOT EXISTS idx_conversation_contexts_context_id ON conversation_contexts(context_id);
CREATE INDEX IF NOT EXISTS idx_conversation_contexts_session ON conversation_contexts(session_id);
CREATE INDEX IF NOT EXISTS idx_conversation_contexts_user ON conversation_contexts(user_id);
CREATE INDEX IF NOT EXISTS idx_conversation_contexts_expires ON conversation_contexts(expires_at);
CREATE INDEX IF NOT EXISTS idx_conversation_contexts_accessed ON conversation_contexts(last_accessed_at DESC);

-- Language Translations Indexes
CREATE INDEX IF NOT EXISTS idx_language_translations_key ON language_translations(translation_key);
CREATE INDEX IF NOT EXISTS idx_language_translations_lang ON language_translations(language_code);
CREATE INDEX IF NOT EXISTS idx_language_translations_context ON language_translations(context);

-- ========================================
-- Full Text Search Indexes
-- ========================================
-- Actionable Reports Full Text Search
CREATE INDEX IF NOT EXISTS idx_actionable_reports_search_subject ON actionable_reports USING gin(to_tsvector('english', subject));
CREATE INDEX IF NOT EXISTS idx_actionable_reports_search_description ON actionable_reports USING gin(to_tsvector('english', description));

-- WhatsApp Messages Full Text Search
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_search_content ON whatsapp_messages USING gin(to_tsvector('english', COALESCE(content, '')));

-- ========================================
-- Foreign Key Constraints
-- ========================================
-- WhatsApp Messages
ALTER TABLE whatsapp_messages DROP CONSTRAINT IF EXISTS fk_whatsapp_messages_agent;
ALTER TABLE whatsapp_messages ADD CONSTRAINT fk_whatsapp_messages_agent
    FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id) ON DELETE SET NULL;

-- WhatsApp Conversations
ALTER TABLE whatsapp_conversations DROP CONSTRAINT IF EXISTS fk_whatsapp_conversations_agent;
ALTER TABLE whatsapp_conversations ADD CONSTRAINT fk_whatsapp_conversations_agent
    FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id) ON DELETE SET NULL;

-- Actionable Reports
ALTER TABLE actionable_reports DROP CONSTRAINT IF EXISTS fk_actionable_reports_customer;
ALTER TABLE actionable_reports ADD CONSTRAINT fk_actionable_reports_customer
    FOREIGN KEY (customer_id) REFERENCES lic_schema.users(user_id) ON DELETE CASCADE;

ALTER TABLE actionable_reports DROP CONSTRAINT IF EXISTS fk_actionable_reports_agent;
ALTER TABLE actionable_reports ADD CONSTRAINT fk_actionable_reports_agent
    FOREIGN KEY (agent_id) REFERENCES lic_schema.agents(agent_id) ON DELETE SET NULL;

-- Knowledge Base Articles
ALTER TABLE knowledge_base_articles DROP CONSTRAINT IF EXISTS fk_knowledge_base_author;
ALTER TABLE knowledge_base_articles ADD CONSTRAINT fk_knowledge_base_author
    FOREIGN KEY (author_id) REFERENCES lic_schema.users(user_id) ON DELETE SET NULL;

-- Chatbot Intents
ALTER TABLE chatbot_intents DROP CONSTRAINT IF EXISTS fk_chatbot_intents_created_by;
ALTER TABLE chatbot_intents ADD CONSTRAINT fk_chatbot_intents_created_by
    FOREIGN KEY (created_by) REFERENCES lic_schema.users(user_id) ON DELETE SET NULL;

ALTER TABLE chatbot_intents DROP CONSTRAINT IF EXISTS fk_chatbot_intents_updated_by;
ALTER TABLE chatbot_intents ADD CONSTRAINT fk_chatbot_intents_updated_by
    FOREIGN KEY (updated_by) REFERENCES lic_schema.users(user_id) ON DELETE SET NULL;

-- ========================================
-- Triggers for Updated At
-- ========================================
-- Add triggers for updated_at columns
DROP TRIGGER IF EXISTS update_whatsapp_messages_updated_at ON whatsapp_messages;
CREATE TRIGGER update_whatsapp_messages_updated_at
    BEFORE UPDATE ON whatsapp_messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_whatsapp_conversations_updated_at ON whatsapp_conversations;
CREATE TRIGGER update_whatsapp_conversations_updated_at
    BEFORE UPDATE ON whatsapp_conversations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_actionable_reports_updated_at ON actionable_reports;
CREATE TRIGGER update_actionable_reports_updated_at
    BEFORE UPDATE ON actionable_reports
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_chatbot_analytics_updated_at ON chatbot_analytics;
CREATE TRIGGER update_chatbot_analytics_updated_at
    BEFORE UPDATE ON chatbot_analytics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_knowledge_base_updated_at ON knowledge_base_articles;
CREATE TRIGGER update_knowledge_base_updated_at
    BEFORE UPDATE ON knowledge_base_articles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_chatbot_intents_updated_at ON chatbot_intents;
CREATE TRIGGER update_chatbot_intents_updated_at
    BEFORE UPDATE ON chatbot_intents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_conversation_contexts_updated_at ON conversation_contexts;
CREATE TRIGGER update_conversation_contexts_updated_at
    BEFORE UPDATE ON conversation_contexts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_language_translations_updated_at ON language_translations;
CREATE TRIGGER update_language_translations_updated_at
    BEFORE UPDATE ON language_translations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- Seed Initial Chatbot Intents
-- ========================================
INSERT INTO chatbot_intents (intent_name, display_name, description, category, training_examples, response_templates, keywords, confidence_threshold, escalation_trigger) VALUES
('policy_inquiry', 'Policy Inquiry', 'Questions about existing policies', 'policy', 
 '["How do I check my policy status?", "What is my policy coverage?", "Show me my policy details", "Policy information"]'::jsonb,
 '["I can help you with your policy information. Let me check your policy details.", "Here is the information about your policy."]'::jsonb,
 '["policy", "coverage", "status", "details", "information"]'::jsonb,
 0.8, false),

('premium_payment', 'Premium Payment', 'Questions about premium payments', 'payment',
 '["How do I pay my premium?", "Payment methods", "Premium due date", "Online payment"]'::jsonb,
 '["I can guide you through the premium payment process.", "Here are the available payment methods for your premium."]'::jsonb,
 '["premium", "payment", "pay", "due", "online"]'::jsonb,
 0.8, false),

('claim_help', 'Claim Assistance', 'Help with filing or checking claims', 'claims',
 '["How do I file a claim?", "Claim status", "Claim process", "Submit claim"]'::jsonb,
 '["I can help you with the claims process.", "Let me guide you through filing your claim."]'::jsonb,
 '["claim", "file", "status", "process", "submit"]'::jsonb,
 0.8, false),

('complaint', 'Customer Complaint', 'Customer dissatisfaction or complaints', 'support',
 '["This is not working", "I am unhappy", "Bad service", "Complaint", "Dissatisfied"]'::jsonb,
 '["I apologize for the inconvenience. Let me help resolve this issue.", "I understand your concern. Let me connect you with a representative."]'::jsonb,
 '["complaint", "unhappy", "bad", "dissatisfied", "problem"]'::jsonb,
 0.6, true),

('escalation_request', 'Escalation Request', 'Request to speak with human agent', 'support',
 '["Speak to human", "Talk to agent", "Customer service", "Supervisor", "Representative"]'::jsonb,
 '["I understand you would like to speak with a human representative. Let me arrange that for you."]'::jsonb,
 '["human", "agent", "representative", "supervisor", "speak"]'::jsonb,
 0.9, true)
ON CONFLICT (intent_name) DO NOTHING;

-- ========================================
-- Seed Initial Knowledge Base Articles
-- ========================================
INSERT INTO knowledge_base_articles (article_id, title, content, category, tags, language, difficulty_level) VALUES
('kb_policy_status', 'How to Check Your Policy Status', 
 'To check your policy status:\n1. Open the Agent Mitra app\n2. Go to Policies section\n3. Select your policy\n4. View the status at the top of the policy details\n\nIf you have any questions about your policy status, contact your agent.',
 'policy', '["policy", "status", "check", "view"]'::jsonb, 'en', 'beginner'),

('kb_premium_payment', 'Premium Payment Methods',
 'You can pay your insurance premium through:\n\n1. **Online Payment**\n   - UPI apps (Google Pay, PhonePe, Paytm)\n   - Net Banking\n   - Credit/Debit Cards\n\n2. **Agent Payment**\n   - Contact your insurance agent\n   - Cash or cheque payment\n\n3. **Auto-debit**\n   - Set up standing instruction\n   - ECS mandate\n\nPremium due dates are mentioned in your policy documents.',
 'payment', '["premium", "payment", "online", "methods", "pay"]'::jsonb, 'en', 'beginner'),

('kb_claim_process', 'How to File an Insurance Claim',
 'To file an insurance claim:\n\n1. **Gather Documents**\n   - Policy copy\n   - Incident report\n   - Medical bills (for health claims)\n   - FIR copy (if applicable)\n\n2. **Submit Claim**\n   - Through app or website\n   - Contact your agent\n   - Visit branch office\n\n3. **Track Status**\n   - Check claim status in app\n   - Receive updates via SMS/email\n\nProcessing time varies by claim type.',
 'claims', '["claim", "file", "process", "submit", "documents"]'::jsonb, 'en', 'intermediate')
ON CONFLICT (article_id) DO NOTHING;

-- ========================================
-- Seed Language Translations
-- ========================================
INSERT INTO language_translations (translation_key, language_code, translated_text, context) VALUES
-- Common UI elements
('welcome_message', 'hi', 'स्वागत है', 'ui'),
('welcome_message', 'te', 'స్వాగతం', 'ui'),
('help_button', 'hi', 'मदद', 'ui'),
('help_button', 'te', 'సహాయం', 'ui'),

-- Chatbot responses
('policy_inquiry_response', 'hi', 'मैं आपकी पॉलिसी जानकारी में मदद कर सकता हूं।', 'chatbot'),
('policy_inquiry_response', 'te', 'మీ పాలసీ సమాచారంలో నేను సహాయపడగలను.', 'chatbot'),
('payment_help_response', 'hi', 'मैं प्रीमियम भुगतान प्रक्रिया में आपकी मदद कर सकता हूं।', 'chatbot'),
('payment_help_response', 'te', 'ప్రీమియం చెల్లింపు ప్రక్రియలో నేను మీకు సహాయపడగలను.', 'chatbot')
ON CONFLICT (translation_key, language_code, context) DO NOTHING;
