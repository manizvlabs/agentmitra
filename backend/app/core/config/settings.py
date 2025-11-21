"""
Application Configuration Settings
Loads from environment variables
"""
import os
from pydantic_settings import BaseSettings
from dotenv import load_dotenv

# Load .env.local file
load_dotenv("../.env.local")


class Settings(BaseSettings):
    """Application settings"""
    
    # Application
    app_name: str = "Agent Mitra API"
    app_version: str = "0.1.0"
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
    
    # Redis
    redis_url: str = os.getenv("REDIS_URL", "redis://localhost:6379")
    
    # Security
    jwt_secret_key: str = os.getenv("JWT_SECRET_KEY", "dev-secret-key-change-in-production")
    jwt_algorithm: str = os.getenv("JWT_ALGORITHM", "HS256")
    jwt_access_token_expire_minutes: int = int(os.getenv("JWT_ACCESS_TOKEN_EXPIRE_MINUTES", "30"))
    jwt_refresh_token_expire_days: int = int(os.getenv("JWT_REFRESH_TOKEN_EXPIRE_DAYS", "7"))
    
    # Feature Flags
    enable_mock_data: bool = os.getenv("ENABLE_MOCK_DATA", "false").lower() == "true"
    enable_analytics: bool = os.getenv("ENABLE_ANALYTICS", "false").lower() == "true"
    enable_payment_processing: bool = os.getenv("ENABLE_PAYMENT_PROCESSING", "false").lower() == "true"
    
    class Config:
        env_file = "../.env.local"
        case_sensitive = False


# Create settings instance
settings = Settings()

