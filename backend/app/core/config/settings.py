"""
Application Configuration Settings
Loads from environment variables with proper .env file support
"""
import os
from pathlib import Path
from pydantic_settings import BaseSettings
from dotenv import load_dotenv
from typing import Optional

# Get the backend directory (parent of this file)
BACKEND_DIR = Path(__file__).parent.parent.parent

# Load .env files in order of precedence:
# 1. .env.local (highest priority, should be gitignored)
# 2. .env (default, can be committed)
# 3. env.development (development defaults)
# 4. env.example (template)
# 5. Environment variables (highest priority if set)
env_local = BACKEND_DIR / ".env.local"
env_file = BACKEND_DIR / ".env"
env_development = BACKEND_DIR / "env.development"
env_example = BACKEND_DIR / "env.example"

if env_local.exists():
    load_dotenv(env_local, override=True)
elif env_file.exists():
    load_dotenv(env_file, override=True)
elif env_development.exists():
    load_dotenv(env_development, override=False)
elif env_example.exists():
    load_dotenv(env_example, override=False)


class Settings(BaseSettings):
    """Application settings - all values externalized to .env"""
    
    # Application
    app_name: str = os.getenv("APP_NAME", "Agent Mitra API")
    app_version: str = os.getenv("APP_VERSION", "0.1.0")
    debug: bool = os.getenv("DEBUG", "true").lower() == "true"
    environment: str = os.getenv("ENVIRONMENT", "development")
    
    # Server
    api_host: str = os.getenv("API_HOST", "0.0.0.0")
    api_port: int = int(os.getenv("API_PORT", "8012"))
    
    # Database
    database_url: str = os.getenv(
        "DATABASE_URL",
        "postgresql://agentmitra:agentmitra_dev@localhost:5432/agentmitra_dev"
    )
    db_schema: str = os.getenv("DB_SCHEMA", "lic_schema")
    db_pool_size: int = int(os.getenv("DB_POOL_SIZE", "10"))
    db_max_overflow: int = int(os.getenv("DB_MAX_OVERFLOW", "20"))
    db_pool_timeout: int = int(os.getenv("DB_POOL_TIMEOUT", "30"))
    db_pool_recycle: int = int(os.getenv("DB_POOL_RECYCLE", "3600"))
    db_echo: bool = os.getenv("DB_ECHO", "false").lower() == "true"
    
    # Redis
    redis_url: str = os.getenv("REDIS_URL", "redis://localhost:6379")
    redis_host: str = os.getenv("REDIS_HOST", "localhost")
    redis_port: int = int(os.getenv("REDIS_PORT", "6379"))
    redis_db: int = int(os.getenv("REDIS_DB", "0"))
    redis_password: Optional[str] = os.getenv("REDIS_PASSWORD")
    redis_socket_timeout: int = int(os.getenv("REDIS_SOCKET_TIMEOUT", "5"))
    redis_socket_connect_timeout: int = int(os.getenv("REDIS_SOCKET_CONNECT_TIMEOUT", "5"))
    
    # Security & Authentication
    jwt_secret_key: str = os.getenv("JWT_SECRET_KEY", "dev-secret-key-change-in-production")
    jwt_algorithm: str = os.getenv("JWT_ALGORITHM", "HS256")
    jwt_access_token_expire_minutes: int = int(os.getenv("JWT_ACCESS_TOKEN_EXPIRE_MINUTES", "15"))
    jwt_refresh_token_expire_days: int = int(os.getenv("JWT_REFRESH_TOKEN_EXPIRE_DAYS", "7"))
    
    # OTP Configuration
    otp_expiry_minutes: int = int(os.getenv("OTP_EXPIRY_MINUTES", "5"))
    otp_max_attempts: int = int(os.getenv("OTP_MAX_ATTEMPTS", "3"))
    otp_rate_limit_per_hour: int = int(os.getenv("OTP_RATE_LIMIT_PER_HOUR", "5"))
    
    # Rate Limiting
    rate_limiting_enabled: bool = os.getenv("RATE_LIMITING_ENABLED", "true").lower() == "true"
    rate_limit_default: str = os.getenv("RATE_LIMIT_DEFAULT", "100/minute")
    # Development: Allow 10000 logins per hour (for extensive testing)
    # Production: 10/minute (600/hour)
    _env = os.getenv("ENVIRONMENT", "development")
    rate_limit_auth: str = os.getenv("RATE_LIMIT_AUTH", "10000/hour" if _env == "development" else "10/minute")
    rate_limit_otp: str = os.getenv("RATE_LIMIT_OTP", "50/hour")
    rate_limit_import: str = os.getenv("RATE_LIMIT_IMPORT", "50/minute")
    rate_limit_analytics: str = os.getenv("RATE_LIMIT_ANALYTICS", "500/minute")
    
    # External APIs
    openai_api_key: str = os.getenv("OPENAI_API_KEY", "")
    openai_model: str = os.getenv("OPENAI_MODEL", "gpt-3.5-turbo")
    openai_max_tokens: int = int(os.getenv("OPENAI_MAX_TOKENS", "300"))
    openai_temperature: float = float(os.getenv("OPENAI_TEMPERATURE", "0.7"))
    openai_organization: Optional[str] = os.getenv("OPENAI_ORGANIZATION")
    
    # SMS Provider
    sms_provider: str = os.getenv("SMS_PROVIDER", "twilio")
    sms_api_key: Optional[str] = os.getenv("SMS_API_KEY")
    sms_api_secret: Optional[str] = os.getenv("SMS_API_SECRET")
    sms_from_number: Optional[str] = os.getenv("SMS_FROM_NUMBER")
    sms_sender_id: Optional[str] = os.getenv("SMS_SENDER_ID", "AGMITR")

    # Twilio Configuration
    twilio_account_sid: Optional[str] = os.getenv("TWILIO_ACCOUNT_SID")
    twilio_auth_token: Optional[str] = os.getenv("TWILIO_AUTH_TOKEN")
    twilio_phone_number: Optional[str] = os.getenv("TWILIO_PHONE_NUMBER")
    twilio_messaging_service_sid: Optional[str] = os.getenv("TWILIO_MESSAGING_SERVICE_SID")

    # AWS Configuration (for SNS)
    aws_access_key_id: Optional[str] = os.getenv("AWS_ACCESS_KEY_ID")
    aws_secret_access_key: Optional[str] = os.getenv("AWS_SECRET_ACCESS_KEY")
    aws_region: str = os.getenv("AWS_REGION", "us-east-1")
    
    # Email Provider
    email_provider: str = os.getenv("EMAIL_PROVIDER", "smtp")
    email_host: str = os.getenv("EMAIL_HOST", "smtp.gmail.com")
    email_port: int = int(os.getenv("EMAIL_PORT", "587"))
    email_user: Optional[str] = os.getenv("EMAIL_USER")
    email_password: Optional[str] = os.getenv("EMAIL_PASSWORD")  # Gmail App Password
    email_from: Optional[str] = os.getenv("EMAIL_FROM", os.getenv("EMAIL_USER"))
    
    # Feature Flag Configuration (Pioneer)
    pioneer_url: str = os.getenv("PIONEER_URL", "http://localhost:8080")
    pioneer_api_key: str = os.getenv("PIONEER_API_KEY", "")

    # FeatureHub Configuration (legacy - deprecated)
    featurehub_url: str = os.getenv("FEATUREHUB_URL", "http://localhost:8071")
    
    # MinIO Storage Configuration
    minio_endpoint: str = os.getenv("MINIO_ENDPOINT", "localhost:9000")
    minio_access_key: str = os.getenv("MINIO_ACCESS_KEY", "minioadmin")
    minio_secret_key: str = os.getenv("MINIO_SECRET_KEY", "minioadmin")
    minio_bucket_name: str = os.getenv("MINIO_BUCKET_NAME", "agentmitra-media")
    minio_use_ssl: bool = os.getenv("MINIO_USE_SSL", "false").lower() == "true"
    minio_cdn_base_url: str = os.getenv("MINIO_CDN_BASE_URL", f"http://{os.getenv('MINIO_ENDPOINT', 'localhost:9000')}/{os.getenv('MINIO_BUCKET_NAME', 'agentmitra-media')}")

    # WhatsApp Business API Configuration
    whatsapp_api_url: str = os.getenv("WHATSAPP_API_URL", "https://graph.facebook.com/v18.0")
    whatsapp_access_token: str = os.getenv("WHATSAPP_ACCESS_TOKEN", "")
    whatsapp_business_account_id: Optional[str] = os.getenv("WHATSAPP_BUSINESS_ACCOUNT_ID")
    whatsapp_business_number: str = os.getenv("WHATSAPP_BUSINESS_NUMBER", "")
    whatsapp_webhook_secret: str = os.getenv("WHATSAPP_WEBHOOK_SECRET", "")
    whatsapp_verify_token: str = os.getenv("WHATSAPP_VERIFY_TOKEN", "")

    # Payment Gateway Configuration
    razorpay_key_id: str = os.getenv("RAZORPAY_KEY_ID", "")
    razorpay_key_secret: str = os.getenv("RAZORPAY_KEY_SECRET", "")
    razorpay_webhook_secret: str = os.getenv("RAZORPAY_WEBHOOK_SECRET", "")
    stripe_secret_key: str = os.getenv("STRIPE_SECRET_KEY", "")
    stripe_publishable_key: str = os.getenv("STRIPE_PUBLISHABLE_KEY", "")
    stripe_webhook_secret: str = os.getenv("STRIPE_WEBHOOK_SECRET", "")

    featurehub_api_key: Optional[str] = os.getenv("FEATUREHUB_API_KEY")
    featurehub_environment: str = os.getenv("FEATUREHUB_ENVIRONMENT", "development")
    featurehub_sdk_key: Optional[str] = os.getenv("FEATUREHUB_SDK_KEY")
    featurehub_poll_interval: int = int(os.getenv("FEATUREHUB_POLL_INTERVAL", "30"))
    featurehub_streaming: bool = os.getenv("FEATUREHUB_STREAMING", "true").lower() == "true"
    featurehub_admin_token: Optional[str] = os.getenv("FEATUREHUB_ADMIN_TOKEN")
    featurehub_admin_sdk_url: Optional[str] = os.getenv("FEATUREHUB_ADMIN_SDK_URL")
    
    # Feature Flags (Legacy - will be replaced by FeatureHub)
    enable_mock_data: bool = os.getenv("ENABLE_MOCK_DATA", "false").lower() == "true"
    enable_analytics: bool = os.getenv("ENABLE_ANALYTICS", "true").lower() == "true"
    enable_payment_processing: bool = os.getenv("ENABLE_PAYMENT_PROCESSING", "false").lower() == "true"
    enable_chatbot: bool = os.getenv("ENABLE_CHATBOT", "true").lower() == "true"
    
    # Logging
    log_level: str = os.getenv("LOG_LEVEL", "INFO")
    log_file: Optional[str] = os.getenv("LOG_FILE")
    log_json_format: bool = os.getenv("LOG_JSON_FORMAT", "false").lower() == "true"
    
    # Monitoring
    enable_metrics: bool = os.getenv("ENABLE_METRICS", "true").lower() == "true"
    metrics_port: int = int(os.getenv("METRICS_PORT", "9090"))
    prometheus_enabled: bool = os.getenv("PROMETHEUS_ENABLED", "true").lower() == "true"
    
    # CORS
    cors_origins: str = os.getenv("CORS_ORIGINS", "http://localhost:3000,http://localhost:8080,http://localhost:8012,http://localhost:3013")
    cors_allow_credentials: bool = os.getenv("CORS_ALLOW_CREDENTIALS", "true").lower() == "true"
    cors_allow_methods: str = os.getenv("CORS_ALLOW_METHODS", "GET,POST,PUT,DELETE,OPTIONS")
    cors_allow_headers: str = os.getenv("CORS_ALLOW_HEADERS", "*")
    
    # File Upload
    max_upload_size_mb: int = int(os.getenv("MAX_UPLOAD_SIZE_MB", "10"))
    upload_dir: str = os.getenv("UPLOAD_DIR", "./uploads")
    allowed_file_types: str = os.getenv("ALLOWED_FILE_TYPES", "image/jpeg,image/png,image/gif,application/pdf")
    
    # Compliance
    irdai_compliance_enabled: bool = os.getenv("IRDAI_COMPLIANCE_ENABLED", "true").lower() == "true"
    dpdp_compliance_enabled: bool = os.getenv("DPDP_COMPLIANCE_ENABLED", "true").lower() == "true"
    audit_logging_enabled: bool = os.getenv("AUDIT_LOGGING_ENABLED", "true").lower() == "true"
    data_encryption_enabled: bool = os.getenv("DATA_ENCRYPTION_ENABLED", "true").lower() == "true"

    # Content Management
    content_max_file_size_mb: int = int(os.getenv("CONTENT_MAX_FILE_SIZE_MB", "100"))
    content_allowed_video_types: str = os.getenv("CONTENT_ALLOWED_VIDEO_TYPES", "video/mp4,video/avi,video/mov,video/mkv,video/webm")
    content_allowed_doc_types: str = os.getenv("CONTENT_ALLOWED_DOC_TYPES", "application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document")
    content_cdn_enabled: bool = os.getenv("CONTENT_CDN_ENABLED", "true").lower() == "true"
    content_compression_enabled: bool = os.getenv("CONTENT_COMPRESSION_ENABLED", "true").lower() == "true"

    # Analytics Configuration
    analytics_retention_days: int = int(os.getenv("ANALYTICS_RETENTION_DAYS", "90"))
    analytics_cache_ttl: int = int(os.getenv("ANALYTICS_CACHE_TTL", "3600"))
    analytics_reporting_enabled: bool = os.getenv("ANALYTICS_REPORTING_ENABLED", "true").lower() == "true"

    # Chatbot Configuration
    chatbot_enabled: bool = os.getenv("CHATBOT_ENABLED", "true").lower() == "true"
    chatbot_model: str = os.getenv("CHATBOT_MODEL", "gpt-3.5-turbo")
    chatbot_temperature: float = float(os.getenv("CHATBOT_TEMPERATURE", "0.7"))
    chatbot_max_tokens: int = int(os.getenv("CHATBOT_MAX_TOKENS", "300"))
    chatbot_language: str = os.getenv("CHATBOT_LANGUAGE", "en")
    chatbot_auto_escalation_enabled: bool = os.getenv("CHATBOT_AUTO_ESCALATION_ENABLED", "true").lower() == "true"
    chatbot_proactive_suggestions_enabled: bool = os.getenv("CHATBOT_PROACTIVE_SUGGESTIONS_ENABLED", "true").lower() == "true"
    
    class Config:
        env_file = str(env_local if env_local.exists() else env_file)
        case_sensitive = False


# Create settings instance
settings = Settings()

