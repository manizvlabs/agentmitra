"""
Portal Service Configuration Settings
=====================================

Configuration settings for the Agent Configuration Portal service.
This service handles agent onboarding, profile management, and administrative functions.
"""

import os
from pathlib import Path
from pydantic_settings import BaseSettings
from dotenv import load_dotenv
from typing import Optional

# Get the portal service directory
PORTAL_DIR = Path(__file__).parent.parent.parent.parent

# Load environment variables
env_local = PORTAL_DIR / ".env.local"
env_file = PORTAL_DIR / ".env"

if env_local.exists():
    load_dotenv(env_local, override=True)
elif env_file.exists():
    load_dotenv(env_file, override=False)


class PortalSettings(BaseSettings):
    """Portal service settings"""

    # Application
    app_name: str = os.getenv("PORTAL_APP_NAME", "Agent Configuration Portal")
    app_version: str = os.getenv("PORTAL_APP_VERSION", "1.0.0")
    debug: bool = os.getenv("PORTAL_DEBUG", "true").lower() == "true"
    environment: str = os.getenv("PORTAL_ENVIRONMENT", "development")

    # Server
    host: str = os.getenv("PORTAL_HOST", "0.0.0.0")
    port: int = int(os.getenv("PORTAL_PORT", "3013"))

    # Database (shared with main API)
    database_url: str = os.getenv("DATABASE_URL", "postgresql://agentmitra:agentmitra_dev@localhost:5432/agentmitra_dev")

    # Redis (shared with main API)
    redis_url: str = os.getenv("REDIS_URL", "redis://localhost:6379")

    # Main API Communication
    main_api_url: str = os.getenv("MAIN_API_URL", "http://localhost:8012")
    main_api_token: Optional[str] = os.getenv("MAIN_API_TOKEN")

    # Security
    jwt_secret_key: str = os.getenv("PORTAL_JWT_SECRET_KEY", "portal-secret-key-change-in-production")
    jwt_algorithm: str = os.getenv("PORTAL_JWT_ALGORITHM", "HS256")
    jwt_access_token_expire_minutes: int = int(os.getenv("PORTAL_JWT_ACCESS_TOKEN_EXPIRE_MINUTES", "60"))

    # File Upload
    upload_dir: str = os.getenv("PORTAL_UPLOAD_DIR", "./portal_uploads")
    max_upload_size_mb: int = int(os.getenv("PORTAL_MAX_UPLOAD_SIZE_MB", "50"))

    # CORS
    cors_origins: str = os.getenv("PORTAL_CORS_ORIGINS", "http://localhost:3000,http://localhost:3013")
    cors_allow_credentials: bool = os.getenv("PORTAL_CORS_ALLOW_CREDENTIALS", "true").lower() == "true"

    # Email (for notifications)
    smtp_server: str = os.getenv("PORTAL_SMTP_SERVER", "smtp.gmail.com")
    smtp_port: int = int(os.getenv("PORTAL_SMTP_PORT", "587"))
    smtp_username: Optional[str] = os.getenv("PORTAL_SMTP_USERNAME")
    smtp_password: Optional[str] = os.getenv("PORTAL_SMTP_PASSWORD")

    # Portal-specific features
    enable_agent_onboarding: bool = os.getenv("ENABLE_AGENT_ONBOARDING", "true").lower() == "true"
    enable_bulk_import: bool = os.getenv("ENABLE_BULK_IMPORT", "true").lower() == "true"
    enable_callback_management: bool = os.getenv("ENABLE_CALLBACK_MANAGEMENT", "true").lower() == "true"
    enable_content_management: bool = os.getenv("ENABLE_CONTENT_MANAGEMENT", "true").lower() == "true"

    # Data import settings
    import_batch_size: int = int(os.getenv("IMPORT_BATCH_SIZE", "100"))
    import_timeout_seconds: int = int(os.getenv("IMPORT_TIMEOUT_SECONDS", "300"))

    # Logging
    log_level: str = os.getenv("PORTAL_LOG_LEVEL", "INFO")
    log_file: Optional[str] = os.getenv("PORTAL_LOG_FILE")

    class Config:
        env_file = str(env_local if env_local.exists() else env_file)
        case_sensitive = False


# Create settings instance
settings = PortalSettings()
