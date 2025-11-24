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
# 3. Environment variables (highest priority if set)
env_local = BACKEND_DIR / ".env.local"
env_file = BACKEND_DIR / ".env"

if env_local.exists():
    load_dotenv(env_local, override=True)
elif env_file.exists():
    load_dotenv(env_file, override=False)


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
    # Development: Allow 1000 logins per hour (effectively unlimited for testing)
    # Production: 10/minute (600/hour)
    _env = os.getenv("ENVIRONMENT", "development")
    rate_limit_auth: str = os.getenv("RATE_LIMIT_AUTH", "1000/hour" if _env == "development" else "10/minute")
    rate_limit_otp: str = os.getenv("RATE_LIMIT_OTP", "5/hour")
    rate_limit_import: str = os.getenv("RATE_LIMIT_IMPORT", "5/minute")
    rate_limit_analytics: str = os.getenv("RATE_LIMIT_ANALYTICS", "50/minute")
    
    # External APIs
    openai_api_key: str = os.getenv("OPENAI_API_KEY", "")
    
    # SMS Provider
    sms_provider: str = os.getenv("SMS_PROVIDER", "twilio")
    sms_api_key: Optional[str] = os.getenv("SMS_API_KEY")
    sms_api_secret: Optional[str] = os.getenv("SMS_API_SECRET")
    sms_from_number: Optional[str] = os.getenv("SMS_FROM_NUMBER")
    
    # Email Provider
    email_provider: str = os.getenv("EMAIL_PROVIDER", "smtp")
    email_host: str = os.getenv("EMAIL_HOST", "smtp.gmail.com")
    email_port: int = int(os.getenv("EMAIL_PORT", "587"))
    email_user: Optional[str] = os.getenv("EMAIL_USER")
    email_password: Optional[str] = os.getenv("EMAIL_PASSWORD")  # Gmail App Password
    email_from: Optional[str] = os.getenv("EMAIL_FROM", os.getenv("EMAIL_USER"))
    
    # FeatureHub Configuration
    featurehub_url: str = os.getenv("FEATUREHUB_URL", "http://localhost:8071")
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
    cors_origins: str = os.getenv("CORS_ORIGINS", "http://localhost:3000,http://localhost:8080")
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
    
    class Config:
        env_file = str(env_local if env_local.exists() else env_file)
        case_sensitive = False


# Create settings instance
settings = Settings()

