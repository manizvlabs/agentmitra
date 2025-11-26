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

# Initialize logger with fallback
try:
    logger = get_logger(__name__)
except Exception:
    # Fallback logger if get_logger fails during import
    import logging
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.INFO)

# Create FastAPI app
app = FastAPI(
    title="Agent Mitra API",
    description="Agent Mitra Backend API - Insurance Agent Management Platform",
    version="1.0.0",
    docs_url="/docs" if settings.environment == "development" else None,  # Disable docs in production
    redoc_url="/redoc" if settings.environment == "development" else None,  # Disable redoc in production
)

# CORS middleware MUST be added FIRST, before other middleware
# Parse CORS origins from settings (comma-separated string)
cors_origins = settings.cors_origins.split(",") if settings.cors_origins else ["*"]
# In development, allow all origins for easier testing
if settings.environment == "development":
    cors_origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=settings.cors_allow_credentials,
    allow_methods=settings.cors_allow_methods.split(",") if isinstance(settings.cors_allow_methods, str) else ["*"],
    allow_headers=settings.cors_allow_headers.split(",") if isinstance(settings.cors_allow_headers, str) else ["*"],
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

        # Add security headers (but don't override CORS headers)
        response.headers['X-Content-Type-Options'] = 'nosniff'
        response.headers['X-Frame-Options'] = 'DENY'
        response.headers['X-XSS-Protection'] = '1; mode=block'
        # Only add HSTS in production
        if settings.environment == "production":
            response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
        response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
        response.headers['Permissions-Policy'] = 'geolocation=(), microphone=(), camera=()'
        # Relax CSP in development to allow React dev server
        if settings.environment == "development":
            response.headers['Content-Security-Policy'] = "default-src 'self' 'unsafe-inline' 'unsafe-eval'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; connect-src 'self' http://localhost:* ws://localhost:*"
        else:
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

# Add HTTPS redirect in production (disabled for local testing)
# if settings.environment == "production":
#     app.add_middleware(HTTPSRedirectMiddleware)

# Add security middleware
app.add_middleware(SecurityHeadersMiddleware)

# Initialize tenant and audit services
from app.core.tenant_service import TenantService
from app.core.audit_service import AuditService
from app.core.tenant_middleware import TenantMiddleware

tenant_service = TenantService(
    database_url=settings.database_url,
    redis_url=settings.redis_url
)
audit_service = AuditService(tenant_service=tenant_service)

# Add tenant middleware
app.add_middleware(TenantMiddleware, tenant_service=tenant_service, audit_service=audit_service)

# Add rate limiting middleware
from app.core.rate_limiter import rate_limit_middleware
app.middleware("http")(rate_limit_middleware)

# Global exception handler for better error reporting
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException

@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """Global exception handler to catch all unhandled exceptions"""
    import traceback
    logger.error(f"Unhandled exception: {str(exc)}", exc_info=True)
    logger.error(f"Traceback: {traceback.format_exc()}")

    # Return JSON error response
    return JSONResponse(
        status_code=500,
        content={
            "detail": f"Internal server error: {str(exc)}",
            "error_type": type(exc).__name__
        }
    )

@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request, exc):
    """Handle HTTP exceptions"""
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail}
    )

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request, exc):
    """Handle validation errors"""
    return JSONResponse(
        status_code=422,
        content={"detail": exc.errors(), "body": exc.body}
    )

# Include API routers
app.include_router(api_router)


@app.on_event("startup")
async def startup_event():
    """Verify database connection on startup"""
    logger.info("Starting Agent Mitra API")
    
    # Configure SQLAlchemy mappers after all models are imported
    # This ensures all relationships can be resolved
    try:
        from app.models import configure_all_mappers
        configure_all_mappers()
        logger.info("SQLAlchemy mappers configured successfully")
    except Exception as e:
        logger.warning(f"Mapper configuration warning (non-critical): {e}")
    
    # Verify database connection (schema managed by Flyway migrations)
    init_db()
    logger.info("Database connection verified (schema managed by Flyway)")


# Lifespan event handler (modern approach)
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Handle application startup and shutdown events"""
    # Startup
    logger.info("Starting Agent Mitra API with lifespan events")
    # Verify database connection (schema managed by Flyway migrations)
    init_db()
    logger.info("Database connection verified (schema managed by Flyway)")

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

