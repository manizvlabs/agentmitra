"""
Agent Mitra - FastAPI Backend Application
Main entry point for the backend API server
"""

"""
Agent Mitra - FastAPI Backend Application
Main entry point for the backend API server
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1 import api_router
from app.core.database import init_db
from app.core.logging_config import setup_logging, get_logger
from app.core.config.settings import settings
import uvicorn
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv(".env")

# Setup logging
setup_logging(
    log_level=os.getenv("LOG_LEVEL", "INFO"),
    log_file=os.getenv("LOG_FILE", "logs/app.log") if settings.environment == "production" else None,
    json_format=settings.environment == "production",
    environment=settings.environment
)

logger = get_logger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Agent Mitra API",
    description="Agent Mitra Backend API - Insurance Agent Management Platform",
    version="1.0.0",
    docs_url="/docs" if settings.environment == "development" else None,  # Disable docs in production
    redoc_url="/redoc" if settings.environment == "development" else None,  # Disable redoc in production
)

# Security middleware
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import Response
from starlette.middleware.trustedhost import TrustedHostMiddleware
from starlette.middleware.httpsredirect import HTTPSRedirectMiddleware
import time

class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """Add security headers to all responses"""

    async def dispatch(self, request, call_next):
        start_time = time.time()

        response = await call_next(request)

        # Add security headers
        response.headers['X-Content-Type-Options'] = 'nosniff'
        response.headers['X-Frame-Options'] = 'DENY'
        response.headers['X-XSS-Protection'] = '1; mode=block'
        response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
        response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
        response.headers['Permissions-Policy'] = 'geolocation=(), microphone=(), camera=()'
        response.headers['Content-Security-Policy'] = "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'"

        # Add response time header for monitoring
        process_time = time.time() - start_time
        response.headers['X-Process-Time'] = str(process_time)

        return response

# Add trusted host middleware (configure for production)
if settings.environment == "production":
    app.add_middleware(
        TrustedHostMiddleware,
        allowed_hosts=["your-domain.com", "*.your-domain.com"]  # Configure for your domain
    )

# Add HTTPS redirect in production
if settings.environment == "production":
    app.add_middleware(HTTPSRedirectMiddleware)

# Add security middleware
app.add_middleware(SecurityHeadersMiddleware)

# Add rate limiting middleware
from app.core.rate_limiter import rate_limit_middleware
app.middleware("http")(rate_limit_middleware)

# CORS middleware (restrict in production)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure properly for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API routers
app.include_router(api_router)


@app.on_event("startup")
async def startup_event():
    """Initialize database on startup"""
    logger.info("Starting Agent Mitra API")
    init_db()
    logger.info("Database initialized")


# Lifespan event handler (modern approach)
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Handle application startup and shutdown events"""
    # Startup
    logger.info("Starting Agent Mitra API with lifespan events")
    init_db()
    logger.info("Database initialized")

    yield

    # Shutdown
    logger.info("Shutting down Agent Mitra API")


# Update app to use lifespan (uncomment when ready to replace on_event)
# app = FastAPI(
#     title="Agent Mitra API",
#     description="Agent Mitra Backend API - Insurance Agent Management Platform",
#     version="0.1.0",
#     docs_url="/docs",
#     redoc_url="/redoc",
#     lifespan=lifespan,
# )


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Agent Mitra API",
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs",
        "api": "/api/v1"
    }


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "agent-mitra-backend",
        "version": "0.1.0"
    }


@app.get("/api/v1/health")
async def api_health():
    """API health check endpoint"""
    return {
        "status": "healthy",
        "api_version": "v1",
        "service": "agent-mitra-backend"
    }


if __name__ == "__main__":
    # Get port from environment or default to 8012
    port = int(os.getenv("API_PORT", "8012"))
    reload_mode = os.getenv("ENVIRONMENT", "development") == "development"
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=port,
        reload=reload_mode
    )

