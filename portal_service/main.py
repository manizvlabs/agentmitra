"""
Agent Configuration Portal Service
===================================

Dedicated service for agent configuration, onboarding, and administrative functions.
Provides web interface and APIs for agent management, data import workflows,
and administrative operations.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse
from contextlib import asynccontextmanager
import uvicorn
import os
from dotenv import load_dotenv

from app.api.v1.api import api_router
from app.core.config.settings import settings
from app.core.database import init_db
from app.core.logging_config import setup_logging, get_logger

# Load environment variables
load_dotenv()

# Setup logging
setup_logging(
    log_level=os.getenv("LOG_LEVEL", "INFO"),
    log_file=os.getenv("LOG_FILE", "logs/portal.log") if settings.environment == "production" else None,
    json_format=settings.environment == "production",
    environment=settings.environment,
    service_name="agent-portal"
)

logger = get_logger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan context manager"""
    logger.info("🚀 Starting Agent Configuration Portal")

    # Initialize database
    init_db()
    logger.info("✅ Database connection established")

    yield

    logger.info("🛑 Shutting down Agent Configuration Portal")


# Create FastAPI application
app = FastAPI(
    title="Agent Configuration Portal",
    description="Agent Configuration Portal - Administrative interface for insurance agents",
    version="1.0.0",
    docs_url="/docs" if settings.environment == "development" else None,
    redoc_url="/redoc" if settings.environment == "development" else None,
    lifespan=lifespan
)

# CORS middleware
cors_origins = settings.cors_origins.split(",") if settings.cors_origins else ["*"]
if settings.environment == "development":
    cors_origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Security middleware
app.add_middleware(TrustedHostMiddleware, allowed_hosts=["*"])  # Configure for production

# Mount static files (for frontend assets)
app.mount("/static", StaticFiles(directory="static", html=True), name="static")

# Include API routers
app.include_router(api_router, prefix="/api/v1")


@app.get("/", response_class=HTMLResponse)
async def root():
    """Serve the main portal interface"""
    return """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Agent Configuration Portal</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            .container { max-width: 800px; margin: 0 auto; }
            .header { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
            .nav { display: flex; gap: 20px; margin-bottom: 20px; }
            .nav a { padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 5px; }
            .nav a:hover { background: #0056b3; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🏢 Agent Configuration Portal</h1>
                <p>Administrative interface for insurance agent management and configuration</p>
            </div>

            <div class="nav">
                <a href="/docs">📚 API Documentation</a>
                <a href="/api/v1/health">🏥 Health Check</a>
                <a href="/api/v1/dashboard">📊 Dashboard</a>
            </div>

            <div>
                <h2>Available Features</h2>
                <ul>
                    <li><strong>Agent Onboarding:</strong> Register and configure new insurance agents</li>
                    <li><strong>Data Import:</strong> Bulk upload customer and policy data</li>
                    <li><strong>Profile Management:</strong> Update agent profiles and credentials</li>
                    <li><strong>Analytics Dashboard:</strong> Monitor agent performance and system metrics</li>
                    <li><strong>Callback Management:</strong> Handle customer inquiries and escalations</li>
                    <li><strong>Content Management:</strong> Upload and manage training materials</li>
                </ul>
            </div>
        </div>
    </body>
    </html>
    """


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "agent-portal",
        "version": "1.0.0"
    }


@app.get("/api/v1/health")
async def api_health():
    """API health check endpoint"""
    return {
        "status": "healthy",
        "service": "agent-portal-api",
        "version": "1.0.0"
    }


if __name__ == "__main__":
    port = int(os.getenv("PORTAL_PORT", "3013"))
    reload_mode = os.getenv("ENVIRONMENT", "development") == "development"

    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=port,
        reload=reload_mode,
        log_level="info"
    )
