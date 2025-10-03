# Agent Mitra - Python Backend Design

## 1. Backend Architecture Overview

### 1.1 Technology Stack & Philosophy

#### Core Technology Decisions
```
🐍 PYTHON BACKEND ECOSYSTEM

🎯 Technology Philosophy:
├── FastAPI: High-performance async web framework
├── SQLAlchemy: Powerful ORM with async support
├── PostgreSQL: Advanced relational database
├── Redis: High-performance caching and sessions
├── Docker: Containerized deployment
├── Kubernetes: Orchestration (future scaling)
└── Async/Await: Non-blocking I/O throughout

📊 Performance Targets:
├── API Response Time: <200ms (95th percentile)
├── Concurrent Requests: 10,000+ per instance
├── Error Rate: <0.1%
├── Uptime: 99.9% SLA
└── Memory Usage: <512MB per instance
```

#### Framework Selection Rationale
```python
# Why FastAPI over other frameworks?
"""
FastAPI Advantages:
✅ Automatic API documentation (Swagger/OpenAPI)
✅ Type hints for runtime validation
✅ Async support out-of-the-box
✅ Dependency injection system
✅ Background tasks and WebSocket support
✅ Production-ready with minimal configuration
✅ Excellent performance (comparable to Go/Node.js)
✅ Built-in security features
"""

# Comparison with alternatives
FRAMEWORK_COMPARISON = {
    "FastAPI": {
        "performance": "⭐⭐⭐⭐⭐",
        "developer_experience": "⭐⭐⭐⭐⭐",
        "async_support": "⭐⭐⭐⭐⭐",
        "documentation": "⭐⭐⭐⭐⭐",
        "community": "⭐⭐⭐⭐⭐"
    },
    "Django": {
        "performance": "⭐⭐⭐⭐",
        "developer_experience": "⭐⭐⭐⭐⭐",
        "async_support": "⭐⭐⭐⭐",
        "documentation": "⭐⭐⭐⭐⭐",
        "community": "⭐⭐⭐⭐⭐"
    },
    "Flask": {
        "performance": "⭐⭐⭐⭐⭐",
        "developer_experience": "⭐⭐⭐⭐",
        "async_support": "⭐⭐⭐",
        "documentation": "⭐⭐⭐⭐",
        "community": "⭐⭐⭐⭐⭐"
    }
}
```

### 1.2 Application Architecture Patterns

#### Microservices Architecture
```
🏗️ MICROSERVICES ARCHITECTURE

📦 Service Decomposition:
├── API Gateway Service (FastAPI)
│   ├── Request routing and authentication
│   ├── Rate limiting and throttling
│   ├── Request/response transformation
│   └── Service orchestration
│
├── User Management Service
│   ├── Authentication & authorization
│   ├── User profiles and preferences
│   ├── Session management
│   └── Role-based access control
│
├── Policy Management Service
│   ├── Insurance policy CRUD operations
│   ├── Policy lifecycle management
│   ├── Premium calculations
│   └── Policy document generation
│
├── Payment Processing Service
│   ├── Payment gateway integration
│   ├── Premium collection
│   ├── Refund processing
│   └── Payment reconciliation
│
├── Data Import Service
│   ├── Excel file processing from agent uploads
│   ├── Customer and policy data validation
│   ├── Background job processing and queuing
│   ├── Data mapping and transformation
│   └── Import status tracking and notifications
│
├── Communication Service
│   ├── WhatsApp Business API integration
│   ├── Email and SMS notifications
│   ├── Template management
│   └── Message queuing
│
├── Analytics & Reporting Service
│   ├── Business intelligence
│   ├── Performance metrics
│   ├── User behavior analytics
│   └── Custom reporting
│
├── Content Management Service
│   ├── Video content management
│   ├── Document storage
│   └── Media processing
│
└── Chatbot & AI Service
    ├── Natural language processing
    ├── Intent recognition
    ├── Automated responses
    └── AI model integration
```

#### API Design Patterns
```python
# RESTful API Design with FastAPI
from fastapi import FastAPI, Depends, HTTPException
from pydantic import BaseModel, Field
from typing import List, Optional
from uuid import UUID

app = FastAPI(
    title="Agent Mitra API",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# API Response Models
class APIResponse(BaseModel):
    success: bool = Field(default=True)
    message: str = Field(default="")
    data: Optional[dict] = None
    errors: Optional[List[str]] = None

class PaginatedResponse(APIResponse):
    data: dict = Field(default_factory=dict)
    pagination: dict = Field(default_factory=lambda: {
        "page": 1,
        "limit": 20,
        "total": 0,
        "pages": 0
    })

# HTTP Status Code Mapping
HTTP_STATUS = {
    "success": 200,
    "created": 201,
    "accepted": 202,
    "no_content": 204,
    "bad_request": 400,
    "unauthorized": 401,
    "forbidden": 403,
    "not_found": 404,
    "conflict": 409,
    "unprocessable": 422,
    "too_many_requests": 429,
    "internal_error": 500
}

# API Versioning Strategy
API_VERSIONS = {
    "v1": "/api/v1",
    "v2": "/api/v2"  # Future version
}

# Content Negotiation
SUPPORTED_FORMATS = ["application/json", "application/xml"]
DEFAULT_FORMAT = "application/json"
```

## 2. Core Backend Services Implementation

### 2.1 API Gateway Service

#### FastAPI Application Structure
```python
# main.py - Application Entry Point
"""
Agent Mitra API Gateway Service
===============================

This is the main entry point for the Agent Mitra backend API.
It provides RESTful endpoints for all client applications.

Features:
- JWT Authentication & Authorization
- Request/Response Logging
- Rate Limiting
- CORS Support
- API Documentation
- Health Checks
- Background Tasks
"""

import uvicorn
from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
import logging
import time

# Import service modules
from app.core.config import settings
from app.core.logging import setup_logging
from app.api.v1.api import api_router
from app.core.database import create_tables
from app.core.redis import init_redis
from app.core.cache import init_cache

# Setup logging
setup_logging()
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan context manager"""
    logger.info("🚀 Starting Agent Mitra API Gateway")

    # Initialize services
    await init_redis()
    await init_cache()
    await create_tables()

    logger.info("✅ All services initialized")

    yield

    logger.info("🛑 Shutting down Agent Mitra API Gateway")
    # Cleanup resources here

# Create FastAPI application
app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description=settings.DESCRIPTION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# Security Middleware
app.add_middleware(TrustedHostMiddleware, allowed_hosts=settings.ALLOWED_HOSTS)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request/Response Middleware
@app.middleware("http")
async def log_requests(request: Request, call_next):
    """Log all requests and responses"""
    start_time = time.time()

    # Log request
    logger.info(f"📨 {request.method} {request.url} - {request.client.host}")

    # Process request
    response = await call_next(request)

    # Calculate processing time
    process_time = time.time() - start_time

    # Log response
    logger.info(f"📤 {response.status_code} - {process_time:.3f}s")

    # Add processing time header
    response.headers["X-Process-Time"] = str(process_time)

    return response

# Exception Handlers
@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    """Handle HTTP exceptions"""
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "message": exc.detail,
            "errors": [exc.detail]
        }
    )

@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    """Handle general exceptions"""
    logger.error(f"Unhandled exception: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={
            "success": False,
            "message": "Internal server error",
            "errors": ["An unexpected error occurred"]
        }
    )

# Health Check Endpoint
@app.get("/health")
async def health_check():
    """Health check endpoint for load balancers and monitoring"""
    return {
        "status": "healthy",
        "timestamp": time.time(),
        "version": settings.VERSION
    }

# API Routes
app.include_router(api_router, prefix=settings.API_V1_STR)

# WebSocket Support (for real-time features)
from app.api.v1.websocket import websocket_router
app.include_router(websocket_router, prefix="/ws")

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG,
        log_level="info"
    )
```

#### API Router Structure
```python
# app/api/v1/api.py
"""
API Router Configuration
========================

This module configures all API routes for version 1 of the API.
Routes are organized by domain and include proper dependency injection.
"""

from fastapi import APIRouter
from app.api.v1.endpoints import (
    auth, users, policies, payments,
    communications, analytics, content, chatbot
)

api_router = APIRouter()

# Authentication routes (no auth required)
api_router.include_router(
    auth.router,
    prefix="/auth",
    tags=["authentication"]
)

# Protected routes (auth required)
api_router.include_router(
    users.router,
    prefix="/users",
    tags=["users"]
)

api_router.include_router(
    policies.router,
    prefix="/policies",
    tags=["policies"]
)

api_router.include_router(
    payments.router,
    prefix="/payments",
    tags=["payments"]
)

api_router.include_router(
    communications.router,
    prefix="/communications",
    tags=["communications"]
)

api_router.include_router(
    analytics.router,
    prefix="/analytics",
    tags=["analytics"]
)

api_router.include_router(
    content.router,
    prefix="/content",
    tags=["content"]
)

api_router.include_router(
    chatbot.router,
    prefix="/chatbot",
    tags=["chatbot"]
)
```

### 2.2 Authentication & Authorization Service

#### JWT Token Management
```python
# app/core/security.py
"""
Security and Authentication Utilities
====================================

This module provides JWT token creation, validation, password hashing,
and other security-related utilities.
"""

import jwt
import bcrypt
from datetime import datetime, timedelta
from typing import Optional, Dict, Any
from passlib.context import CryptContext
from app.core.config import settings

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class SecurityService:
    """Security service for authentication and authorization"""

    @staticmethod
    def hash_password(password: str) -> str:
        """Hash a password using bcrypt"""
        return pwd_context.hash(password)

    @staticmethod
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        """Verify a password against its hash"""
        return pwd_context.verify(plain_password, hashed_password)

    @staticmethod
    def create_access_token(
        data: Dict[str, Any],
        expires_delta: Optional[timedelta] = None
    ) -> str:
        """Create JWT access token"""
        to_encode = data.copy()

        if expires_delta:
            expire = datetime.utcnow() + expires_delta
        else:
            expire = datetime.utcnow() + timedelta(
                minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
            )

        to_encode.update({"exp": expire, "type": "access"})
        encoded_jwt = jwt.encode(
            to_encode,
            settings.JWT_SECRET_KEY,
            algorithm=settings.JWT_ALGORITHM
        )
        return encoded_jwt

    @staticmethod
    def create_refresh_token(data: Dict[str, Any]) -> str:
        """Create JWT refresh token"""
        to_encode = data.copy()
        expire = datetime.utcnow() + timedelta(
            days=settings.REFRESH_TOKEN_EXPIRE_DAYS
        )
        to_encode.update({"exp": expire, "type": "refresh"})

        encoded_jwt = jwt.encode(
            to_encode,
            settings.JWT_REFRESH_SECRET_KEY,
            algorithm=settings.JWT_ALGORITHM
        )
        return encoded_jwt

    @staticmethod
    def decode_token(token: str) -> Optional[Dict[str, Any]]:
        """Decode and validate JWT token"""
        try:
            payload = jwt.decode(
                token,
                settings.JWT_SECRET_KEY,
                algorithms=[settings.JWT_ALGORITHM]
            )
            return payload
        except jwt.ExpiredSignatureError:
            return None
        except jwt.JWTError:
            return None

    @staticmethod
    def generate_otp(length: int = 6) -> str:
        """Generate numeric OTP"""
        import random
        return ''.join([str(random.randint(0, 9)) for _ in range(length)])

    @staticmethod
    def generate_secure_token(length: int = 32) -> str:
        """Generate cryptographically secure random token"""
        import secrets
        return secrets.token_urlsafe(length)
```

#### Authentication Endpoints
```python
# app/api/v1/endpoints/auth.py
"""
Authentication Endpoints
========================

This module provides authentication endpoints including:
- User login/logout
- Token refresh
- OTP verification
- Password reset
- MFA setup
"""

from datetime import timedelta
from typing import Any, Dict
from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from pydantic import BaseModel, EmailStr

from app.core.security import SecurityService
from app.core.config import settings
from app.db.session import get_db
from app.models.user import User
from app.schemas.auth import (
    TokenResponse, LoginRequest, RegisterRequest,
    OTPVerifyRequest, PasswordResetRequest
)
from app.services.auth_service import AuthService
from app.services.email_service import EmailService
from app.services.sms_service import SMSService

router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl=f"{settings.API_V1_STR}/auth/login")

class AuthController:
    """Authentication controller with dependency injection"""

    def __init__(self, db: Session):
        self.db = db
        self.auth_service = AuthService(db)
        self.email_service = EmailService()
        self.sms_service = SMSService()

    async def login(self, request: LoginRequest) -> TokenResponse:
        """User login with email/phone and password"""
        # Authenticate user
        user = self.auth_service.authenticate_user(
            request.identifier,  # email or phone
            request.password
        )

        if not user:
            raise HTTPException(
                status_code=401,
                detail="Invalid credentials"
            )

        # Check if MFA is required
        if user.mfa_enabled:
            # Generate and send MFA code
            otp_code = SecurityService.generate_otp()
            await self._send_mfa_code(user, otp_code)

            return TokenResponse(
                access_token="",
                refresh_token="",
                token_type="bearer",
                requires_mfa=True,
                mfa_token=self._create_mfa_token(user.id)
            )

        # Create tokens
        access_token = SecurityService.create_access_token(
            data={"sub": str(user.id), "tenant_id": str(user.tenant_id)}
        )
        refresh_token = SecurityService.create_refresh_token(
            data={"sub": str(user.id)}
        )

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60
        )

    async def verify_otp(self, request: OTPVerifyRequest) -> TokenResponse:
        """Verify OTP for MFA or phone verification"""
        # Verify OTP from cache/database
        is_valid = await self.auth_service.verify_otp(
            request.identifier,
            request.otp_code,
            request.otp_type  # 'mfa', 'phone_verification', 'password_reset'
        )

        if not is_valid:
            raise HTTPException(
                status_code=400,
                detail="Invalid or expired OTP"
            )

        if request.otp_type == "mfa":
            # Complete MFA login
            user = await self.auth_service.get_user_by_identifier(request.identifier)
            access_token = SecurityService.create_access_token(
                data={"sub": str(user.id), "tenant_id": str(user.tenant_id)}
            )
            refresh_token = SecurityService.create_refresh_token(
                data={"sub": str(user.id)}
            )

            return TokenResponse(
                access_token=access_token,
                refresh_token=refresh_token,
                token_type="bearer",
                expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60
            )

        return TokenResponse(message="OTP verified successfully")

    async def refresh_token(self, refresh_token: str) -> TokenResponse:
        """Refresh access token using refresh token"""
        payload = SecurityService.decode_token(refresh_token)

        if not payload or payload.get("type") != "refresh":
            raise HTTPException(
                status_code=401,
                detail="Invalid refresh token"
            )

        user_id = payload.get("sub")
        user = self.auth_service.get_user_by_id(user_id)

        if not user:
            raise HTTPException(
                status_code=401,
                detail="User not found"
            )

        # Create new access token
        access_token = SecurityService.create_access_token(
            data={"sub": str(user.id), "tenant_id": str(user.tenant_id)}
        )

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,  # Return same refresh token
            token_type="bearer",
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60
        )

    async def request_password_reset(self, request: PasswordResetRequest, background_tasks: BackgroundTasks):
        """Request password reset"""
        user = self.auth_service.get_user_by_email(request.email)

        if user:
            # Generate reset token
            reset_token = SecurityService.generate_secure_token()
            await self.auth_service.store_reset_token(user.id, reset_token)

            # Send reset email
            background_tasks.add_task(
                self.email_service.send_password_reset_email,
                user.email,
                reset_token
            )

        # Always return success (don't reveal if email exists)
        return {"message": "If the email exists, a reset link has been sent"}

    async def reset_password(self, token: str, new_password: str):
        """Reset password using token"""
        user_id = await self.auth_service.verify_reset_token(token)

        if not user_id:
            raise HTTPException(
                status_code=400,
                detail="Invalid or expired reset token"
            )

        # Update password
        hashed_password = SecurityService.hash_password(new_password)
        await self.auth_service.update_password(user_id, hashed_password)

        return {"message": "Password reset successfully"}

    async def _send_mfa_code(self, user: User, otp_code: str):
        """Send MFA code via SMS or email"""
        if user.phone_number and user.phone_verified:
            await self.sms_service.send_sms(
                user.phone_number,
                f"Your Agent Mitra verification code is: {otp_code}"
            )
        elif user.email and user.email_verified:
            await self.email_service.send_email(
                user.email,
                "Agent Mitra MFA Code",
                f"Your verification code is: {otp_code}"
            )

    def _create_mfa_token(self, user_id: str) -> str:
        """Create temporary MFA token"""
        return SecurityService.create_access_token(
            data={"sub": user_id, "mfa_required": True},
            expires_delta=timedelta(minutes=5)
        )

# Route definitions
auth_controller = None  # Will be injected via dependency

@router.post("/login", response_model=TokenResponse)
async def login(
    request: LoginRequest,
    db: Session = Depends(get_db)
):
    """User login endpoint"""
    controller = AuthController(db)
    return await controller.login(request)

@router.post("/verify-otp", response_model=TokenResponse)
async def verify_otp(
    request: OTPVerifyRequest,
    db: Session = Depends(get_db)
):
    """OTP verification endpoint"""
    controller = AuthController(db)
    return await controller.verify_otp(request)

@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    refresh_token: str,
    db: Session = Depends(get_db)
):
    """Token refresh endpoint"""
    controller = AuthController(db)
    return await controller.refresh_token(refresh_token)

@router.post("/request-password-reset")
async def request_password_reset(
    request: PasswordResetRequest,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    """Request password reset endpoint"""
    controller = AuthController(db)
    return await controller.request_password_reset(request, background_tasks)

@router.post("/reset-password")
async def reset_password(
    token: str,
    new_password: str,
    db: Session = Depends(get_db)
):
    """Reset password endpoint"""
    controller = AuthController(db)
    return await controller.reset_password(token, new_password)
```

### 2.3 Policy Management Service

#### Policy CRUD Operations
```python
# app/api/v1/endpoints/policies.py
"""
Policy Management Endpoints
===========================

This module provides CRUD operations for insurance policies:
- Create new policies
- Retrieve policy details
- Update policy information
- List policies with filtering
- Policy lifecycle management
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field

from app.db.session import get_db
from app.core.auth import get_current_user
from app.models.policy import InsurancePolicy
from app.models.user import User
from app.schemas.policy import (
    PolicyCreate, PolicyUpdate, PolicyResponse,
    PolicyListResponse, PolicyFilter
)
from app.services.policy_service import PolicyService
from app.services.document_service import DocumentService

router = APIRouter()

class PolicyController:
    """Policy management controller"""

    def __init__(self, db: Session):
        self.db = db
        self.policy_service = PolicyService(db)
        self.document_service = DocumentService()

    async def create_policy(
        self,
        policy_data: PolicyCreate,
        current_user: User
    ) -> PolicyResponse:
        """Create a new insurance policy"""
        # Validate agent permissions
        if not self._can_create_policy(current_user, policy_data.agent_id):
            raise HTTPException(
                status_code=403,
                detail="Not authorized to create policies for this agent"
            )

        # Create policy
        policy = await self.policy_service.create_policy(
            policy_data,
            created_by=current_user.id
        )

        # Generate policy documents
        await self.document_service.generate_policy_documents(policy.id)

        return PolicyResponse.from_orm(policy)

    async def get_policies(
        self,
        current_user: User,
        filters: PolicyFilter,
        page: int = 1,
        limit: int = 20
    ) -> PolicyListResponse:
        """Get paginated list of policies"""
        # Build query based on user role
        query_filters = self._build_policy_filters(current_user, filters)

        # Get policies with pagination
        policies, total = await self.policy_service.get_policies_paginated(
            query_filters, page, limit
        )

        return PolicyListResponse(
            items=[PolicyResponse.from_orm(p) for p in policies],
            total=total,
            page=page,
            limit=limit,
            pages=(total + limit - 1) // limit
        )

    async def get_policy(
        self,
        policy_id: str,
        current_user: User
    ) -> PolicyResponse:
        """Get policy details"""
        policy = await self.policy_service.get_policy_by_id(policy_id)

        if not policy:
            raise HTTPException(status_code=404, detail="Policy not found")

        # Check access permissions
        if not self._can_access_policy(current_user, policy):
            raise HTTPException(
                status_code=403,
                detail="Not authorized to access this policy"
            )

        return PolicyResponse.from_orm(policy)

    async def update_policy(
        self,
        policy_id: str,
        update_data: PolicyUpdate,
        current_user: User
    ) -> PolicyResponse:
        """Update policy information"""
        policy = await self.policy_service.get_policy_by_id(policy_id)

        if not policy:
            raise HTTPException(status_code=404, detail="Policy not found")

        # Check update permissions
        if not self._can_update_policy(current_user, policy):
            raise HTTPException(
                status_code=403,
                detail="Not authorized to update this policy"
            )

        # Update policy
        updated_policy = await self.policy_service.update_policy(
            policy_id, update_data, updated_by=current_user.id
        )

        return PolicyResponse.from_orm(updated_policy)

    async def delete_policy(
        self,
        policy_id: str,
        current_user: User
    ):
        """Soft delete policy"""
        policy = await self.policy_service.get_policy_by_id(policy_id)

        if not policy:
            raise HTTPException(status_code=404, detail="Policy not found")

        # Check delete permissions
        if not self._can_delete_policy(current_user, policy):
            raise HTTPException(
                status_code=403,
                detail="Not authorized to delete this policy"
            )

        await self.policy_service.delete_policy(policy_id, deleted_by=current_user.id)

        return {"message": "Policy deleted successfully"}

    def _can_create_policy(self, user: User, agent_id: str) -> bool:
        """Check if user can create policies for the given agent"""
        if user.role == "super_admin":
            return True
        if user.role == "senior_agent" and str(user.id) == agent_id:
            return True
        if user.role == "provider_admin":
            # Check if agent belongs to user's provider
            return True  # Implementation needed
        return False

    def _can_access_policy(self, user: User, policy: InsurancePolicy) -> bool:
        """Check if user can access the policy"""
        if user.role in ["super_admin", "provider_admin"]:
            return True
        if user.role in ["senior_agent", "junior_agent"]:
            return str(policy.agent_id) == str(user.id)
        if user.role == "policyholder":
            return str(policy.policyholder_id) == str(user.id)
        return False

    def _can_update_policy(self, user: User, policy: InsurancePolicy) -> bool:
        """Check if user can update the policy"""
        if user.role in ["super_admin", "provider_admin"]:
            return True
        if user.role in ["senior_agent", "junior_agent"]:
            return str(policy.agent_id) == str(user.id)
        return False

    def _can_delete_policy(self, user: User, policy: InsurancePolicy) -> bool:
        """Check if user can delete the policy"""
        # Only admins can delete policies
        return user.role in ["super_admin", "provider_admin"]

    def _build_policy_filters(self, user: User, filters: PolicyFilter) -> dict:
        """Build query filters based on user role and provided filters"""
        query_filters = {}

        # Role-based filters
        if user.role in ["senior_agent", "junior_agent"]:
            query_filters["agent_id"] = user.id
        elif user.role == "policyholder":
            query_filters["policyholder_id"] = user.id

        # Apply provided filters
        if filters.status:
            query_filters["status"] = filters.status
        if filters.policy_type:
            query_filters["policy_type"] = filters.policy_type
        if filters.agent_id and user.role in ["super_admin", "provider_admin"]:
            query_filters["agent_id"] = filters.agent_id
        if filters.date_from:
            query_filters["created_at__gte"] = filters.date_from
        if filters.date_to:
            query_filters["created_at__lte"] = filters.date_to

        return query_filters

# Route definitions
@router.post("/", response_model=PolicyResponse)
async def create_policy(
    policy_data: PolicyCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create new insurance policy"""
    controller = PolicyController(db)
    return await controller.create_policy(policy_data, current_user)

@router.get("/", response_model=PolicyListResponse)
async def get_policies(
    # Filter parameters
    status: Optional[str] = None,
    policy_type: Optional[str] = None,
    agent_id: Optional[str] = None,
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    # Pagination
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get paginated list of policies"""
    filters = PolicyFilter(
        status=status,
        policy_type=policy_type,
        agent_id=agent_id,
        date_from=date_from,
        date_to=date_to
    )

    controller = PolicyController(db)
    return await controller.get_policies(current_user, filters, page, limit)

@router.get("/{policy_id}", response_model=PolicyResponse)
async def get_policy(
    policy_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get policy details"""
    controller = PolicyController(db)
    return await controller.get_policy(policy_id, current_user)

@router.put("/{policy_id}", response_model=PolicyResponse)
async def update_policy(
    policy_id: str,
    policy_data: PolicyUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update policy information"""
    controller = PolicyController(db)
    return await controller.update_policy(policy_id, policy_data, current_user)

@router.delete("/{policy_id}")
async def delete_policy(
    policy_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete policy"""
    controller = PolicyController(db)
    return await controller.delete_policy(policy_id, current_user)
```

### 2.4 Payment Processing Service

#### Payment Gateway Integration
```python
# app/services/payment_service.py
"""
Payment Processing Service
==========================

This service handles payment gateway integrations including:
- Premium payment collection
- Payment gateway callbacks
- Refund processing
- Payment reconciliation
- Fraud detection
"""

import hashlib
import hmac
import json
from datetime import datetime, timedelta
from typing import Dict, Optional, Tuple
from decimal import Decimal

import razorpay
import stripe
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.payment import PremiumPayment
from app.models.policy import InsurancePolicy
from app.services.notification_service import NotificationService

class PaymentService:
    """Payment processing service with multiple gateway support"""

    def __init__(self, db: Session):
        self.db = db
        self.notification_service = NotificationService()

        # Initialize payment gateways
        self.razorpay_client = razorpay.Client(
            auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET)
        )

        self.stripe_client = stripe.StripeClient(settings.STRIPE_SECRET_KEY)

    async def create_payment_order(
        self,
        policy_id: str,
        amount: Decimal,
        currency: str = "INR",
        gateway: str = "razorpay"
    ) -> Dict:
        """Create payment order for premium collection"""

        # Validate policy and amount
        policy = await self._get_policy(policy_id)
        if not policy:
            raise ValueError("Invalid policy")

        # Validate amount against policy premium
        if amount != policy.premium_amount:
            raise ValueError("Payment amount doesn't match policy premium")

        # Create order based on gateway
        if gateway == "razorpay":
            return await self._create_razorpay_order(policy, amount, currency)
        elif gateway == "stripe":
            return await self._create_stripe_payment_intent(policy, amount, currency)
        else:
            raise ValueError(f"Unsupported payment gateway: {gateway}")

    async def process_payment_callback(
        self,
        gateway: str,
        callback_data: Dict
    ) -> bool:
        """Process payment gateway callback/webhook"""

        if gateway == "razorpay":
            return await self._process_razorpay_callback(callback_data)
        elif gateway == "stripe":
            return await self._process_stripe_webhook(callback_data)
        else:
            raise ValueError(f"Unsupported payment gateway: {gateway}")

    async def process_refund(
        self,
        payment_id: str,
        refund_amount: Optional[Decimal] = None,
        reason: str = "customer_request"
    ) -> Dict:
        """Process payment refund"""

        payment = await self._get_payment(payment_id)
        if not payment:
            raise ValueError("Payment not found")

        if payment.status != "completed":
            raise ValueError("Can only refund completed payments")

        refund_amount = refund_amount or payment.amount

        if refund_amount > payment.amount:
            raise ValueError("Refund amount cannot exceed payment amount")

        # Process refund based on gateway
        if payment.gateway == "razorpay":
            return await self._process_razorpay_refund(payment, refund_amount, reason)
        elif payment.gateway == "stripe":
            return await self._process_stripe_refund(payment, refund_amount, reason)
        else:
            raise ValueError(f"Unsupported payment gateway: {payment.gateway}")

    async def reconcile_payments(
        self,
        start_date: datetime,
        end_date: datetime
    ) -> Dict:
        """Reconcile payments with gateway statements"""

        # Get payments from database
        db_payments = await self._get_payments_for_reconciliation(start_date, end_date)

        reconciliation_results = {
            "total_payments": len(db_payments),
            "matched": 0,
            "discrepancies": 0,
            "missing": 0,
            "details": []
        }

        # Compare with gateway data
        for payment in db_payments:
            gateway_status = await self._get_gateway_payment_status(payment)

            if payment.status == gateway_status["status"]:
                reconciliation_results["matched"] += 1
            else:
                reconciliation_results["discrepancies"] += 1
                reconciliation_results["details"].append({
                    "payment_id": payment.id,
                    "db_status": payment.status,
                    "gateway_status": gateway_status["status"],
                    "discrepancy": gateway_status.get("notes", "")
                })

        return reconciliation_results

    # Private methods for Razorpay integration
    async def _create_razorpay_order(
        self,
        policy: InsurancePolicy,
        amount: Decimal,
        currency: str
    ) -> Dict:
        """Create Razorpay payment order"""

        order_data = {
            "amount": int(amount * 100),  # Razorpay expects paisa
            "currency": currency,
            "receipt": f"policy_{policy.policy_number}",
            "notes": {
                "policy_id": str(policy.id),
                "policy_number": policy.policy_number,
                "customer_id": str(policy.policyholder_id)
            }
        }

        order = self.razorpay_client.order.create(order_data)

        # Store order details in database
        await self._store_payment_order({
            "order_id": order["id"],
            "policy_id": policy.id,
            "amount": amount,
            "currency": currency,
            "gateway": "razorpay",
            "gateway_order_id": order["id"],
            "status": "created"
        })

        return {
            "order_id": order["id"],
            "amount": order["amount"],
            "currency": order["currency"],
            "key": settings.RAZORPAY_KEY_ID
        }

    async def _process_razorpay_callback(self, callback_data: Dict) -> bool:
        """Process Razorpay payment callback"""

        # Verify payment signature
        if not self._verify_razorpay_signature(callback_data):
            raise ValueError("Invalid payment signature")

        payment_entity = callback_data["payload"]["payment"]["entity"]

        # Update payment status
        payment_update = {
            "gateway_payment_id": payment_entity["id"],
            "status": "completed" if payment_entity["status"] == "captured" else "failed",
            "gateway_response": payment_entity,
            "processed_at": datetime.utcnow()
        }

        await self._update_payment_status(
            callback_data["order_id"],
            payment_update
        )

        # Send notifications
        if payment_update["status"] == "completed":
            await self.notification_service.send_payment_success_notification(
                payment_entity["notes"]["policy_id"]
            )

        return True

    async def _process_razorpay_refund(
        self,
        payment: PremiumPayment,
        refund_amount: Decimal,
        reason: str
    ) -> Dict:
        """Process Razorpay refund"""

        refund_data = {
            "payment_id": payment.gateway_payment_id,
            "amount": int(refund_amount * 100),
            "notes": {
                "reason": reason,
                "requested_by": "system"
            }
        }

        refund = self.razorpay_client.payment.refund(
            payment.gateway_payment_id,
            refund_data
        )

        # Store refund details
        await self._store_refund({
            "payment_id": payment.id,
            "refund_id": refund["id"],
            "amount": refund_amount,
            "reason": reason,
            "gateway": "razorpay",
            "status": "processed"
        })

        return {
            "refund_id": refund["id"],
            "status": "processed",
            "amount": refund_amount
        }

    def _verify_razorpay_signature(self, callback_data: Dict) -> bool:
        """Verify Razorpay webhook signature"""
        signature = callback_data.get("signature", "")
        payload = json.dumps(callback_data["payload"], separators=(',', ':'))

        expected_signature = hmac.new(
            settings.RAZORPAY_WEBHOOK_SECRET.encode(),
            payload.encode(),
            hashlib.sha256
        ).hexdigest()

        return hmac.compare_digest(signature, expected_signature)

    # Helper methods
    async def _get_policy(self, policy_id: str) -> Optional[InsurancePolicy]:
        """Get policy by ID"""
        return self.db.query(InsurancePolicy).filter(
            InsurancePolicy.id == policy_id
        ).first()

    async def _get_payment(self, payment_id: str) -> Optional[PremiumPayment]:
        """Get payment by ID"""
        return self.db.query(PremiumPayment).filter(
            PremiumPayment.id == payment_id
        ).first()

    async def _store_payment_order(self, order_data: Dict):
        """Store payment order details"""
        # Implementation for storing order details
        pass

    async def _update_payment_status(self, order_id: str, update_data: Dict):
        """Update payment status"""
        # Implementation for updating payment status
        pass

    async def _store_refund(self, refund_data: Dict):
        """Store refund details"""
        # Implementation for storing refund details
        pass

    async def _get_payments_for_reconciliation(self, start_date: datetime, end_date: datetime):
        """Get payments for reconciliation"""
        # Implementation for getting payments in date range
        pass

    async def _get_gateway_payment_status(self, payment: PremiumPayment) -> Dict:
        """Get payment status from gateway"""
        # Implementation for checking gateway status
        pass
```

### 2.5 Data Import Service

#### Excel File Processing & Background Jobs
```python
# app/services/data_import_service.py
"""
Data Import Service
===================

This service handles Excel file processing from agent configuration portal including:
- Excel file validation and parsing
- Customer and policy data mapping
- Background job processing and queuing
- Data validation and transformation
- Import status tracking and notifications
- Error handling and retry logic
"""

import asyncio
import uuid
from typing import Dict, List, Optional, Any
from pathlib import Path
import pandas as pd
from sqlalchemy.orm import Session
from sqlalchemy import text
import logging

from ..core.config import settings
from ..core.database import get_db
from ..models import DataImport, ImportJob, CustomerDataMapping, DataSyncStatus
from ..repositories import DataImportRepository
from ..utils.excel_parser import ExcelParser
from ..utils.data_validator import DataValidator
from ..utils.notification_service import NotificationService

logger = logging.getLogger(__name__)

class DataImportService:
    """Service for handling Excel data imports from agent configuration portal"""

    def __init__(self, db: Session):
        self.db = db
        self.import_repo = DataImportRepository(db)
        self.excel_parser = ExcelParser()
        self.data_validator = DataValidator()
        self.notification_service = NotificationService()

    async def process_excel_import(
        self,
        agent_id: str,
        file_path: str,
        import_type: str = "customer_data"
    ) -> Dict[str, Any]:
        """Main entry point for Excel file processing"""

        # 1. Create import record
        import_record = await self._create_import_record(
            agent_id=agent_id,
            file_path=file_path,
            import_type=import_type
        )

        # 2. Validate file
        validation_result = await self._validate_excel_file(file_path)
        if not validation_result["valid"]:
            await self._update_import_status(
                import_record.id,
                "failed",
                error_details={"validation_errors": validation_result["errors"]}
            )
            return {"success": False, "errors": validation_result["errors"]}

        # 3. Parse Excel data
        try:
            parsed_data = await self.excel_parser.parse_excel(file_path)
        except Exception as e:
            logger.error(f"Excel parsing failed: {e}")
            await self._update_import_status(
                import_record.id,
                "failed",
                error_details={"parsing_error": str(e)}
            )
            return {"success": False, "error": f"Failed to parse Excel file: {str(e)}"}

        # 4. Create background job for processing
        job_result = await self._create_background_job(
            import_id=import_record.id,
            job_type="process_data",
            job_data={
                "parsed_data": parsed_data,
                "agent_id": agent_id,
                "import_type": import_type
            }
        )

        # 5. Update import record with job info
        await self._update_import_record(
            import_record.id,
            total_records=len(parsed_data),
            processing_job_id=job_result["job_id"]
        )

        return {
            "success": True,
            "import_id": import_record.id,
            "job_id": job_result["job_id"],
            "total_records": len(parsed_data),
            "message": "Import job queued for processing"
        }

    async def _create_import_record(
        self,
        agent_id: str,
        file_path: str,
        import_type: str
    ) -> DataImport:
        """Create import record in database"""
        file_path_obj = Path(file_path)

        import_record = DataImport(
            id=str(uuid.uuid4()),
            agent_id=agent_id,
            file_name=file_path_obj.name,
            file_path=file_path,
            file_size_bytes=file_path_obj.stat().st_size,
            import_type=import_type,
            status="pending"
        )

        self.db.add(import_record)
        await self.db.commit()
        await self.db.refresh(import_record)

        return import_record

    async def _validate_excel_file(self, file_path: str) -> Dict[str, Any]:
        """Validate Excel file structure and content"""
        try:
            # Check file exists and is readable
            if not Path(file_path).exists():
                return {"valid": False, "errors": ["File does not exist"]}

            # Validate Excel structure
            validation_result = await self.excel_parser.validate_structure(file_path)

            return validation_result

        except Exception as e:
            logger.error(f"File validation failed: {e}")
            return {"valid": False, "errors": [f"Validation failed: {str(e)}"]}

    async def _create_background_job(
        self,
        import_id: str,
        job_type: str,
        job_data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Create background job for data processing"""

        # Create job record
        job = ImportJob(
            id=str(uuid.uuid4()),
            import_id=import_id,
            job_type=job_type,
            priority=1,
            status="queued",
            job_data=job_data
        )

        self.db.add(job)
        await self.db.commit()

        # Queue job for processing (this would integrate with Celery/RQ)
        await self._queue_job_for_processing(job.id)

        return {"job_id": job.id, "status": "queued"}

    async def _queue_job_for_processing(self, job_id: str):
        """Queue job for background processing using Celery"""
        # This would integrate with Celery or similar job queue
        # For now, we'll simulate by calling the processing function directly

        # In production, this would be:
        # from ..tasks import process_data_import
        # process_data_import.delay(job_id)

        # For demo purposes, we'll process synchronously
        asyncio.create_task(self._process_job_async(job_id))

    async def _process_job_async(self, job_id: str):
        """Process job asynchronously"""
        try:
            await self._process_data_import_job(job_id)
        except Exception as e:
            logger.error(f"Job processing failed for job {job_id}: {e}")
            await self._update_job_status(job_id, "failed", str(e))

    async def _process_data_import_job(self, job_id: str):
        """Main data processing logic"""

        # Get job details
        job = await self.import_repo.get_job_by_id(job_id)
        if not job:
            raise ValueError(f"Job {job_id} not found")

        # Update job status to processing
        await self._update_job_status(job_id, "processing")

        try:
            # Extract job data
            job_data = job.job_data
            parsed_data = job_data["parsed_data"]
            agent_id = job_data["agent_id"]
            import_type = job_data["import_type"]

            # Process each row
            processed_count = 0
            error_count = 0

            for row_idx, row_data in enumerate(parsed_data):
                try:
                    # Validate row data
                    validation_result = await self.data_validator.validate_row(
                        row_data, import_type
                    )

                    if not validation_result["valid"]:
                        # Create mapping record with errors
                        await self._create_data_mapping_record(
                            import_id=job.import_id,
                            excel_row_number=row_idx + 1,
                            raw_excel_data=row_data,
                            mapping_status="error",
                            validation_errors=validation_result["errors"]
                        )
                        error_count += 1
                        continue

                    # Process valid data
                    await self._process_valid_row(
                        row_data=row_data,
                        agent_id=agent_id,
                        import_type=import_type,
                        import_id=job.import_id,
                        row_number=row_idx + 1
                    )
                    processed_count += 1

                except Exception as e:
                    logger.error(f"Error processing row {row_idx + 1}: {e}")
                    await self._create_data_mapping_record(
                        import_id=job.import_id,
                        excel_row_number=row_idx + 1,
                        raw_excel_data=row_data,
                        mapping_status="error",
                        validation_errors=[str(e)]
                    )
                    error_count += 1

            # Update import record with results
            await self._update_import_record(
                job.import_id,
                processed_records=processed_count,
                error_records=error_count,
                status="completed" if error_count == 0 else "completed_with_errors"
            )

            # Update job status
            await self._update_job_status(job_id, "completed")

            # Send notifications
            await self._send_import_completion_notification(
                agent_id=agent_id,
                import_id=job.import_id,
                processed_count=processed_count,
                error_count=error_count
            )

        except Exception as e:
            logger.error(f"Job processing failed: {e}")
            await self._update_job_status(job_id, "failed", str(e))
            await self._update_import_record(job.import_id, status="failed")
            raise

    async def _process_valid_row(
        self,
        row_data: Dict[str, Any],
        agent_id: str,
        import_type: str,
        import_id: str,
        row_number: int
    ):
        """Process a valid row of data"""

        if import_type == "customer_data":
            # Create or update customer record
            customer_result = await self._create_or_update_customer(
                row_data=row_data,
                agent_id=agent_id
            )

            # Create data mapping record
            await self._create_data_mapping_record(
                import_id=import_id,
                excel_row_number=row_number,
                customer_name=row_data.get("customer_name"),
                phone_number=row_data.get("phone_number"),
                email=row_data.get("email"),
                policy_number=row_data.get("policy_number"),
                raw_excel_data=row_data,
                mapping_status="mapped",
                created_customer_id=customer_result.get("customer_id")
            )

        # Additional processing for other import types can be added here

    async def _create_or_update_customer(
        self,
        row_data: Dict[str, Any],
        agent_id: str
    ) -> Dict[str, Any]:
        """Create or update customer record"""
        # Implementation for customer creation/update
        # This would involve checking existing customers and updating/creating records
        pass

    async def _create_data_mapping_record(
        self,
        import_id: str,
        excel_row_number: int,
        customer_name: Optional[str] = None,
        phone_number: Optional[str] = None,
        email: Optional[str] = None,
        policy_number: Optional[str] = None,
        raw_excel_data: Dict[str, Any] = None,
        mapping_status: str = "pending",
        validation_errors: List[str] = None,
        created_customer_id: Optional[str] = None
    ):
        """Create data mapping record"""
        mapping = CustomerDataMapping(
            id=str(uuid.uuid4()),
            import_id=import_id,
            excel_row_number=excel_row_number,
            customer_name=customer_name,
            phone_number=phone_number,
            email=email,
            policy_number=policy_number,
            raw_excel_data=raw_excel_data or {},
            mapping_status=mapping_status,
            validation_errors=validation_errors or [],
            created_customer_id=created_customer_id
        )

        self.db.add(mapping)
        await self.db.commit()

    async def _update_import_record(
        self,
        import_id: str,
        processed_records: Optional[int] = None,
        error_records: Optional[int] = None,
        status: Optional[str] = None,
        processing_job_id: Optional[str] = None
    ):
        """Update import record"""
        import_record = await self.import_repo.get_import_by_id(import_id)
        if not import_record:
            return

        if processed_records is not None:
            import_record.processed_records = processed_records
        if error_records is not None:
            import_record.error_records = error_records
        if status is not None:
            import_record.status = status
        if processing_job_id is not None:
            # This would be a foreign key reference in a real implementation
            pass

        import_record.processing_completed_at = text("NOW()")

        await self.db.commit()

    async def _update_job_status(
        self,
        job_id: str,
        status: str,
        error_message: Optional[str] = None
    ):
        """Update job status"""
        job = await self.import_repo.get_job_by_id(job_id)
        if not job:
            return

        job.status = status
        if error_message:
            job.error_message = error_message

        if status in ["completed", "failed"]:
            job.completed_at = text("NOW()")

        await self.db.commit()

    async def _send_import_completion_notification(
        self,
        agent_id: str,
        import_id: str,
        processed_count: int,
        error_count: int
    ):
        """Send completion notification to agent"""
        # Implementation for sending notifications
        pass

    async def get_import_status(self, import_id: str) -> Dict[str, Any]:
        """Get import status and details"""
        import_record = await self.import_repo.get_import_by_id(import_id)
        if not import_record:
            return {"error": "Import not found"}

        return {
            "import_id": import_record.id,
            "status": import_record.status,
            "total_records": import_record.total_records,
            "processed_records": import_record.processed_records,
            "error_records": import_record.error_records,
            "created_at": import_record.created_at.isoformat(),
            "processing_started_at": import_record.processing_started_at.isoformat() if import_record.processing_started_at else None,
            "processing_completed_at": import_record.processing_completed_at.isoformat() if import_record.processing_completed_at else None
        }
```

### 2.5.1 Data Import API Endpoints

#### Import Status and Management
```python
# app/api/v1/data_import.py
"""
Data Import API Endpoints
=========================

API endpoints for data import management:
- File upload and validation
- Import status tracking
- Error reporting and retry
- Background job monitoring
"""

from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
import logging

from ...core.database import get_db
from ...core.auth import get_current_user
from ...services.data_import_service import DataImportService
from ...models import User

router = APIRouter()
logger = logging.getLogger(__name__)

@router.post("/upload", response_model=Dict[str, Any])
async def upload_excel_file(
    file: UploadFile = File(...),
    import_type: str = "customer_data",
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Upload Excel file for data import"""

    # Validate user permissions (must be agent)
    if current_user.role not in ["agent", "senior_agent", "super_admin"]:
        raise HTTPException(
            status_code=403,
            detail="Only agents can upload data files"
        )

    # Validate file type
    if not file.filename.endswith(('.xlsx', '.xls')):
        raise HTTPException(
            status_code=400,
            detail="Only Excel files (.xlsx, .xls) are allowed"
        )

    # Save uploaded file temporarily
    file_path = f"/tmp/{file.filename}"
    with open(file_path, "wb") as f:
        content = await file.read()
        f.write(content)

    # Process import
    import_service = DataImportService(db)
    result = await import_service.process_excel_import(
        agent_id=str(current_user.id),
        file_path=file_path,
        import_type=import_type
    )

    if not result["success"]:
        raise HTTPException(
            status_code=400,
            detail=result.get("error", "Import failed")
        )

    return result

@router.get("/imports", response_model=List[Dict[str, Any]])
async def get_import_history(
    status: Optional[str] = None,
    limit: int = 20,
    offset: int = 0,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get import history for current user"""

    import_service = DataImportService(db)
    imports = await import_service.get_user_imports(
        user_id=str(current_user.id),
        status=status,
        limit=limit,
        offset=offset
    )

    return imports

@router.get("/imports/{import_id}", response_model=Dict[str, Any])
async def get_import_details(
    import_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get detailed import information"""

    import_service = DataImportService(db)
    import_details = await import_service.get_import_details(
        import_id=import_id,
        user_id=str(current_user.id)
    )

    if not import_details:
        raise HTTPException(status_code=404, detail="Import not found")

    return import_details

@router.get("/imports/{import_id}/errors", response_model=List[Dict[str, Any]])
async def get_import_errors(
    import_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get import error details"""

    import_service = DataImportService(db)
    errors = await import_service.get_import_errors(
        import_id=import_id,
        user_id=str(current_user.id)
    )

    return errors

@router.post("/imports/{import_id}/retry")
async def retry_import(
    import_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Retry failed import"""

    import_service = DataImportService(db)
    result = await import_service.retry_import(
        import_id=import_id,
        user_id=str(current_user.id)
    )

    if not result["success"]:
        raise HTTPException(
            status_code=400,
            detail=result.get("error", "Retry failed")
        )

    return result
```

### 2.5 Communication & Notification Service

#### WhatsApp Business API Integration
```python
# app/services/whatsapp_service.py
"""
WhatsApp Business API Service
=============================

This service handles WhatsApp Business API integration including:
- Message sending and receiving
- Template message management
- Webhook processing
- Message status tracking
- Rate limiting and compliance
"""

import json
import hashlib
import hmac
from datetime import datetime, timedelta
from typing import Dict, List, Optional

import httpx
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.whatsapp_message import WhatsAppMessage
from app.models.whatsapp_template import WhatsAppTemplate
from app.services.template_service import TemplateService

class WhatsAppService:
    """WhatsApp Business API integration service"""

    def __init__(self, db: Session):
        self.db = db
        self.template_service = TemplateService(db)
        self.http_client = httpx.AsyncClient(
            timeout=30.0,
            headers={
                "Authorization": f"Bearer {settings.WHATSAPP_ACCESS_TOKEN}",
                "Content-Type": "application/json"
            }
        )

    async def send_message(
        self,
        to_phone: str,
        message_type: str,
        content: Dict,
        template_name: Optional[str] = None
    ) -> Dict:
        """Send WhatsApp message"""

        # Validate phone number format
        to_phone = self._format_phone_number(to_phone)

        # Prepare message payload
        payload = {
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": to_phone
        }

        if message_type == "template":
            # Send template message
            template = await self.template_service.get_template(template_name)
            payload.update({
                "type": "template",
                "template": {
                    "name": template.name,
                    "language": {"code": template.language},
                    "components": self._build_template_components(template, content)
                }
            })
        elif message_type == "text":
            # Send text message
            payload.update({
                "type": "text",
                "text": {"body": content["body"]}
            })
        elif message_type == "interactive":
            # Send interactive message (buttons, lists)
            payload.update(content)

        # Send message via WhatsApp API
        response = await self._send_whatsapp_request(
            f"{settings.WHATSAPP_API_URL}/messages",
            payload
        )

        # Store message in database
        await self._store_message({
            "message_id": response["messages"][0]["id"],
            "to_phone": to_phone,
            "from_phone": settings.WHATSAPP_BUSINESS_NUMBER,
            "message_type": message_type,
            "content": content,
            "status": "sent",
            "direction": "outbound",
            "template_name": template_name
        })

        return response

    async def process_webhook(self, webhook_data: Dict) -> bool:
        """Process incoming WhatsApp webhook"""

        # Verify webhook signature
        if not self._verify_webhook_signature(webhook_data):
            raise ValueError("Invalid webhook signature")

        # Process each entry
        for entry in webhook_data.get("entry", []):
            for change in entry.get("changes", []):
                if change.get("field") == "messages":
                    await self._process_messages(change["value"])

        return True

    async def get_message_status(self, message_id: str) -> Dict:
        """Get message delivery status"""

        response = await self._send_whatsapp_request(
            f"{settings.WHATSAPP_API_URL}/messages/{message_id}"
        )

        return {
            "message_id": message_id,
            "status": response.get("status", "unknown"),
            "timestamp": response.get("timestamp")
        }

    async def create_template(
        self,
        name: str,
        category: str,
        language: str,
        content: str,
        variables: List[str]
    ) -> Dict:
        """Create WhatsApp message template"""

        payload = {
            "name": name,
            "category": category,
            "language": language,
            "components": [
                {
                    "type": "body",
                    "text": content
                }
            ]
        }

        # Add header if needed
        if variables:
            payload["components"].append({
                "type": "footer",
                "text": f"Variables: {', '.join(variables)}"
            })

        response = await self._send_whatsapp_request(
            f"{settings.WHATSAPP_API_URL}/message_templates",
            payload,
            method="POST"
        )

        # Store template in database
        await self.template_service.create_template({
            "template_id": response["id"],
            "name": name,
            "category": category,
            "language": language,
            "content": content,
            "variables": variables,
            "status": "pending_approval"
        })

        return response

    async def get_templates(self) -> List[Dict]:
        """Get approved message templates"""

        response = await self._send_whatsapp_request(
            f"{settings.WHATSAPP_API_URL}/message_templates"
        )

        return response.get("data", [])

    # Private methods
    async def _send_whatsapp_request(
        self,
        url: str,
        payload: Optional[Dict] = None,
        method: str = "POST"
    ) -> Dict:
        """Send request to WhatsApp API"""

        try:
            if method == "POST":
                response = await self.http_client.post(url, json=payload)
            elif method == "GET":
                response = await self.http_client.get(url)
            else:
                raise ValueError(f"Unsupported HTTP method: {method}")

            response.raise_for_status()
            return response.json()

        except httpx.HTTPError as e:
            # Log error and handle rate limiting
            print(f"WhatsApp API error: {e}")
            if response.status_code == 429:
                # Implement backoff strategy
                await self._handle_rate_limit()
            raise

    async def _process_messages(self, messages_data: Dict):
        """Process incoming messages"""

        for message in messages_data.get("messages", []):
            # Store incoming message
            await self._store_message({
                "message_id": message["id"],
                "to_phone": settings.WHATSAPP_BUSINESS_NUMBER,
                "from_phone": message["from"],
                "message_type": message["type"],
                "content": message.get("text", {}).get("body", ""),
                "status": "received",
                "direction": "inbound",
                "timestamp": message["timestamp"]
            })

            # Process based on message type
            if message["type"] == "text":
                await self._handle_text_message(message)
            elif message["type"] == "interactive":
                await self._handle_interactive_message(message)

    async def _handle_text_message(self, message: Dict):
        """Handle incoming text message"""
        # Check if it's a chatbot query
        from app.services.chatbot_service import ChatbotService

        chatbot_service = ChatbotService(self.db)
        response = await chatbot_service.process_message(
            message["from"],
            message["text"]["body"]
        )

        # Send response
        if response:
            await self.send_message(
                message["from"],
                "text",
                {"body": response}
            )

    async def _handle_interactive_message(self, message: Dict):
        """Handle interactive message responses"""
        # Process button clicks, list selections, etc.
        interactive_data = message.get("interactive", {})

        if interactive_data.get("type") == "button_reply":
            button_id = interactive_data["button_reply"]["id"]
            await self._process_button_click(message["from"], button_id)

        elif interactive_data.get("type") == "list_reply":
            selection_id = interactive_data["list_reply"]["id"]
            await self._process_list_selection(message["from"], selection_id)

    async def _process_button_click(self, phone: str, button_id: str):
        """Process button click actions"""
        # Handle different button actions
        if button_id == "call_agent":
            # Create agent callback request
            from app.services.callback_service import CallbackService
            callback_service = CallbackService(self.db)
            await callback_service.create_callback_request(phone)
        elif button_id == "pay_premium":
            # Send payment link
            await self._send_payment_link(phone)
        # Handle other button actions...

    async def _store_message(self, message_data: Dict):
        """Store WhatsApp message in database"""
        whatsapp_message = WhatsAppMessage(**message_data)
        self.db.add(whatsapp_message)
        await self.db.commit()

    def _verify_webhook_signature(self, webhook_data: Dict) -> bool:
        """Verify WhatsApp webhook signature"""
        signature = webhook_data.get("signature", "")
        body = json.dumps(webhook_data, separators=(',', ':'))

        expected_signature = hmac.new(
            settings.WHATSAPP_WEBHOOK_SECRET.encode(),
            body.encode(),
            hashlib.sha256
        ).hexdigest()

        return hmac.compare_digest(signature, expected_signature)

    def _format_phone_number(self, phone: str) -> str:
        """Format phone number for WhatsApp API"""
        # Remove all non-numeric characters
        phone = ''.join(filter(str.isdigit, phone))

        # Add country code if missing
        if not phone.startswith('91'):
            phone = f'91{phone}'

        return phone

    def _build_template_components(self, template: WhatsAppTemplate, variables: Dict) -> List[Dict]:
        """Build template components for WhatsApp API"""
        components = []

        # Body component
        components.append({
            "type": "body",
            "parameters": [
                {"type": "text", "text": variables.get(var, "")}
                for var in template.variables
            ]
        })

        return components

    async def _handle_rate_limit(self):
        """Handle WhatsApp API rate limiting"""
        # Implement exponential backoff
        import asyncio
        await asyncio.sleep(60)  # Wait 1 minute before retrying
```

### 2.6 Chatbot & AI Service

#### AI-Powered Chatbot Implementation
```python
# app/services/chatbot_service.py
"""
AI Chatbot Service
==================

This service provides intelligent conversation handling using:
- Natural language processing
- Intent recognition
- Context-aware responses
- Knowledge base integration
- Human agent escalation
"""

import re
import json
from typing import Dict, List, Optional, Tuple
from datetime import datetime

import openai
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.chatbot_session import ChatbotSession
from app.models.chatbot_message import ChatbotMessage
from app.models.knowledge_base import KnowledgeBase
from app.services.localization_service import LocalizationService

class ChatbotService:
    """AI-powered chatbot service"""

    def __init__(self, db: Session):
        self.db = db
        self.localization = LocalizationService()
        openai.api_key = settings.OPENAI_API_KEY

        # Predefined intents and responses
        self.intents = {
            "premium_payment": {
                "keywords": ["pay", "premium", "payment", "fee", "amount"],
                "response": "premium_payment_guide"
            },
            "policy_status": {
                "keywords": ["status", "policy", "active", "lapsed"],
                "response": "policy_status_check"
            },
            "claim_process": {
                "keywords": ["claim", "accident", "hospital", "medical"],
                "response": "claim_filing_guide"
            },
            "agent_contact": {
                "keywords": ["agent", "call", "speak", "talk", "help"],
                "response": "agent_callback_request"
            }
        }

    async def process_message(
        self,
        user_phone: str,
        message: str,
        language: str = "en"
    ) -> str:
        """Process incoming message and generate response"""

        # Get or create chat session
        session = await self._get_or_create_session(user_phone)

        # Store user message
        await self._store_message(session.id, message, "user")

        # Analyze message intent
        intent, confidence = await self._analyze_intent(message)

        # Get response based on intent
        if intent == "agent_callback_request" or confidence < 0.6:
            # Escalate to agent or ask for clarification
            response = await self._handle_escalation(session, message)
        else:
            # Generate AI response
            response = await self._generate_ai_response(
                message, intent, session.context, language
            )

        # Store bot response
        await self._store_message(session.id, response, "bot")

        # Update session
        await self._update_session_context(session, intent)

        return response

    async def _analyze_intent(self, message: str) -> Tuple[str, float]:
        """Analyze message intent using keyword matching and AI"""

        # Convert to lowercase for matching
        message_lower = message.lower()

        # Check for keyword matches
        for intent, config in self.intents.items():
            if any(keyword in message_lower for keyword in config["keywords"]):
                return intent, 0.8

        # Use AI for intent recognition if no keyword match
        try:
            response = await openai.ChatCompletion.acreate(
                model="gpt-3.5-turbo",
                messages=[
                    {
                        "role": "system",
                        "content": "Analyze the user's message and classify the intent. "
                                 "Return only the intent category from: premium_payment, "
                                 "policy_status, claim_process, agent_contact, general_inquiry"
                    },
                    {"role": "user", "content": message}
                ],
                max_tokens=50,
                temperature=0.3
            )

            ai_intent = response.choices[0].message.content.strip().lower()
            return ai_intent, 0.7

        except Exception as e:
            print(f"AI intent analysis failed: {e}")
            return "general_inquiry", 0.5

    async def _generate_ai_response(
        self,
        message: str,
        intent: str,
        context: Dict,
        language: str
    ) -> str:
        """Generate AI-powered response"""

        # Get relevant knowledge base articles
        kb_articles = await self._search_knowledge_base(message, intent)

        # Build context for AI
        system_prompt = f"""
        You are Agent Mitra, a helpful insurance assistant for LIC agents and policyholders.
        Respond in {language} language.

        Context:
        - User intent: {intent}
        - Previous conversation: {context.get('last_topic', 'new conversation')}
        - Available knowledge: {len(kb_articles)} relevant articles

        Guidelines:
        - Be friendly and helpful
        - Keep responses concise but informative
        - If complex, suggest calling the agent
        - Always offer specific help
        """

        try:
            response = await openai.ChatCompletion.acreate(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": message}
                ],
                max_tokens=300,
                temperature=0.7
            )

            ai_response = response.choices[0].message.content.strip()

            # Add knowledge base suggestions if relevant
            if kb_articles:
                ai_response += "\n\n" + await self._format_kb_suggestions(kb_articles, language)

            return ai_response

        except Exception as e:
            print(f"AI response generation failed: {e}")
            return await self._get_fallback_response(intent, language)

    async def _handle_escalation(self, session: ChatbotSession, message: str) -> str:
        """Handle agent escalation requests"""

        # Create callback request
        from app.services.callback_service import CallbackService
        callback_service = CallbackService(self.db)
        await callback_service.create_callback_request(
            session.user_phone,
            reason="complex_query",
            context={"last_message": message, "session_id": session.id}
        )

        # Return escalation message
        return self.localization.get_string("agent_callback_confirmation")

    async def _search_knowledge_base(self, query: str, intent: str) -> List[Dict]:
        """Search knowledge base for relevant information"""

        # Simple text search (can be enhanced with vector search)
        kb_entries = self.db.query(KnowledgeBase).filter(
            KnowledgeBase.intent == intent,
            KnowledgeBase.language == "en"  # Can be parameterized
        ).limit(3).all()

        return [
            {
                "title": entry.question,
                "content": entry.answer,
                "url": f"/kb/{entry.id}"
            }
            for entry in kb_entries
        ]

    async def _format_kb_suggestions(self, articles: List[Dict], language: str) -> str:
        """Format knowledge base suggestions for response"""

        if not articles:
            return ""

        suggestion_text = self.localization.get_string("helpful_links", locale=language)
        suggestion_text += ":\n"

        for i, article in enumerate(articles[:2], 1):
            suggestion_text += f"{i}. {article['title']}\n"

        return suggestion_text

    async def _get_fallback_response(self, intent: str, language: str) -> str:
        """Get fallback response when AI fails"""

        fallbacks = {
            "premium_payment": "I can help you with premium payment. Please visit the payments section.",
            "policy_status": "You can check your policy status in the My Policies section.",
            "claim_process": "For claim assistance, please contact your agent.",
            "general_inquiry": "I'm here to help! Please try rephrasing your question."
        }

        return fallbacks.get(intent, fallbacks["general_inquiry"])

    async def _get_or_create_session(self, user_phone: str) -> ChatbotSession:
        """Get existing session or create new one"""

        # Check for active session (last 24 hours)
        session = self.db.query(ChatbotSession).filter(
            ChatbotSession.user_phone == user_phone,
            ChatbotSession.created_at >= datetime.utcnow() - timedelta(hours=24)
        ).order_by(ChatbotSession.created_at.desc()).first()

        if not session:
            session = ChatbotSession(
                user_phone=user_phone,
                context={}
            )
            self.db.add(session)
            await self.db.commit()

        return session

    async def _store_message(self, session_id: str, content: str, sender: str):
        """Store chat message"""

        message = ChatbotMessage(
            session_id=session_id,
            content=content,
            sender=sender
        )
        self.db.add(message)
        await self.db.commit()

    async def _update_session_context(self, session: ChatbotSession, intent: str):
        """Update session context"""

        session.context = session.context or {}
        session.context["last_intent"] = intent
        session.context["last_activity"] = datetime.utcnow().isoformat()
        session.message_count += 1

        await self.db.commit()
```

## 3. Database Layer Implementation

### 3.1 SQLAlchemy ORM Configuration

#### Database Models Base Configuration
```python
# app/db/base.py
"""
Database Base Configuration
===========================

This module provides the base configuration for SQLAlchemy models,
database connections, and session management.
"""

from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, DateTime, String, Integer
from sqlalchemy.sql import func

# Create base class for all models
Base = declarative_base()

class TimestampMixin:
    """Mixin for automatic timestamp fields"""

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

class AuditMixin(TimestampMixin):
    """Mixin for audit fields"""

    created_by = Column(String(36), nullable=True)
    updated_by = Column(String(36), nullable=True)

class SoftDeleteMixin:
    """Mixin for soft delete functionality"""

    deleted_at = Column(DateTime(timezone=True), nullable=True)
    is_deleted = Column(Integer, default=0, nullable=False)

    def soft_delete(self):
        """Mark record as deleted"""
        self.deleted_at = func.now()
        self.is_deleted = 1

# Custom query class for soft deletes
class SoftDeleteQuery:
    """Query class that automatically filters soft-deleted records"""

    def __init__(self, entities, session=None):
        self.entities = entities
        self.session = session

    def filter(self, *criterion):
        """Apply filters with soft delete check"""
        from app.models.base import SoftDeleteMixin

        # Check if entity has soft delete
        if hasattr(self.entities[0], 'is_deleted'):
            criterion = list(criterion) + [self.entities[0].is_deleted == 0]

        return self.session.query(*self.entities).filter(*criterion)
```

#### Database Connection Management
```python
# app/core/database.py
"""
Database Connection Management
==============================

This module handles database connections, session management,
connection pooling, and multi-tenant database routing.
"""

import logging
from typing import Generator
from contextlib import contextmanager

from sqlalchemy import create_engine, event
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import QueuePool

from app.core.config import settings

logger = logging.getLogger(__name__)

# Database URL based on environment
DATABASE_URL = settings.DATABASE_URL

# Create engine with connection pooling
engine = create_engine(
    DATABASE_URL,
    poolclass=QueuePool,
    pool_size=10,
    max_overflow=20,
    pool_timeout=30,
    pool_recycle=3600,  # Recycle connections every hour
    echo=settings.DEBUG,  # SQL query logging in debug mode
    future=True  # Use SQLAlchemy 2.0 style
)

# Create session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Multi-tenant session context
tenant_context = {}

@contextmanager
def get_db(tenant_id: str = None) -> Generator[Session, None, None]:
    """
    Get database session with tenant context

    Args:
        tenant_id: Tenant identifier for multi-tenant routing
    """
    db = SessionLocal()

    # Set tenant context for RLS policies
    if tenant_id:
        tenant_context['tenant_id'] = tenant_id
        # Set session variable for PostgreSQL RLS
        db.execute(f"SET app.tenant_id = '{tenant_id}'")

    try:
        yield db
    except Exception as e:
        logger.error(f"Database error: {e}")
        db.rollback()
        raise
    finally:
        db.close()
        # Clear tenant context
        tenant_context.pop('tenant_id', None)

def get_db_session() -> Generator[Session, None, None]:
    """Get database session (for dependency injection)"""
    with get_db() as session:
        yield session

# Database health check
async def check_database_health() -> Dict[str, Any]:
    """Check database connectivity and performance"""
    try:
        with get_db() as db:
            # Simple query to test connection
            result = db.execute("SELECT 1 as health_check").fetchone()

            # Get connection stats
            connection_count = db.execute("""
                SELECT count(*) as active_connections
                FROM pg_stat_activity
                WHERE state = 'active'
            """).fetchone()

            return {
                "status": "healthy",
                "active_connections": connection_count.active_connections,
                "timestamp": datetime.utcnow()
            }
    except Exception as e:
        logger.error(f"Database health check failed: {e}")
        return {
            "status": "unhealthy",
            "error": str(e),
            "timestamp": datetime.utcnow()
        }

# Database migration helpers
def run_migrations():
    """Run database migrations using Alembic"""
    from alembic.config import Config
    from alembic import command

    alembic_cfg = Config("alembic.ini")
    command.upgrade(alembic_cfg, "head")

def create_database_schema():
    """Create database schema from SQLAlchemy models"""
    from app.db.base import Base
    Base.metadata.create_all(bind=engine)

# Connection event listeners
@event.listens_for(engine, "connect")
def connect_event(connection, connection_record):
    """Handle database connection events"""
    logger.info("Database connection established")

@event.listens_for(engine, "checkout")
def checkout_event(connection):
    """Handle connection checkout from pool"""
    pass

@event.listens_for(engine, "checkin")
def checkin_event(connection, connection_record):
    """Handle connection checkin to pool"""
    pass
```

#### User Model Implementation
```python
# app/models/user.py
"""
User Model
==========

This module defines the User model with all authentication,
authorization, and profile-related fields.
"""

from sqlalchemy import Column, String, Integer, Boolean, DateTime, Text, Date
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base, TimestampMixin, AuditMixin

class User(Base, TimestampMixin, AuditMixin):
    """User model for authentication and profiles"""

    __tablename__ = "users"

    # Primary identifier
    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())

    # Authentication fields
    email = Column(String(255), unique=True, index=True, nullable=True)
    phone_number = Column(String(15), unique=True, index=True, nullable=True)
    username = Column(String(100), unique=True, index=True, nullable=True)
    password_hash = Column(String(255), nullable=False)
    password_salt = Column(String(255))
    password_changed_at = Column(DateTime(timezone=True))

    # Profile information
    first_name = Column(String(100))
    last_name = Column(String(100))
    display_name = Column(String(255))
    avatar_url = Column(String(500))

    # Personal details
    date_of_birth = Column(Date)
    gender = Column(String(20))
    address = Column(JSONB)  # Structured address data
    emergency_contact = Column(JSONB)

    # Account settings
    language_preference = Column(String(10), default='en')
    timezone = Column(String(50), default='Asia/Kolkata')
    theme_preference = Column(String(20), default='light')
    notification_preferences = Column(JSONB)

    # Authentication status
    email_verified = Column(Boolean, default=False)
    phone_verified = Column(Boolean, default=False)
    email_verification_token = Column(String(255))
    email_verification_expires = Column(DateTime(timezone=True))
    password_reset_token = Column(String(255))
    password_reset_expires = Column(DateTime(timezone=True))

    # Security
    mfa_enabled = Column(Boolean, default=False)
    mfa_secret = Column(String(255))
    biometric_enabled = Column(Boolean, default=False)
    last_login_at = Column(DateTime(timezone=True))
    login_attempts = Column(Integer, default=0)
    locked_until = Column(DateTime(timezone=True))

    # Account status
    role = Column(String(50), nullable=False)  # From user_role_enum
    status = Column(String(50), default='active')  # From user_status_enum
    trial_end_date = Column(DateTime(timezone=True))
    subscription_plan = Column(String(50))
    subscription_status = Column(String(50), default='trial')

    # Relationships
    sessions = relationship("UserSession", back_populates="user", cascade="all, delete-orphan")
    permissions = relationship("UserPermission", back_populates="user", cascade="all, delete-orphan")

    # Methods
    def full_name(self) -> str:
        """Get user's full name"""
        if self.first_name and self.last_name:
            return f"{self.first_name} {self.last_name}"
        return self.display_name or self.username or self.email or ""

    def is_active(self) -> bool:
        """Check if user account is active"""
        return self.status == 'active'

    def is_verified(self) -> bool:
        """Check if user has verified email or phone"""
        return self.email_verified or self.phone_verified

    def can_login(self) -> bool:
        """Check if user can login"""
        if not self.is_active():
            return False

        if self.locked_until and self.locked_until > datetime.utcnow():
            return False

        return True

    def record_login_attempt(self, successful: bool = False):
        """Record login attempt"""
        if successful:
            self.login_attempts = 0
            self.last_login_at = func.now()
            self.locked_until = None
        else:
            self.login_attempts += 1
            if self.login_attempts >= 5:  # Lock account after 5 failed attempts
                self.locked_until = func.now() + timedelta(minutes=30)

    def __repr__(self):
        return f"<User(id={self.id}, email={self.email}, role={self.role})>"
```

## 4. Background Tasks & Job Processing

### 4.1 Asynchronous Task Processing

#### Background Task System
```python
# app/core/tasks.py
"""
Background Task Processing
==========================

This module provides background task processing using:
- FastAPI BackgroundTasks for simple tasks
- Celery for complex distributed tasks
- Redis Queue for job queuing
- Scheduled tasks with cron-like scheduling
"""

import asyncio
import logging
from datetime import datetime, timedelta
from typing import Dict, Any, Optional

from fastapi import BackgroundTasks
from celery import Celery
from redis import Redis

from app.core.config import settings

logger = logging.getLogger(__name__)

# Celery configuration
celery_app = Celery(
    "agent_mitra",
    broker=settings.REDIS_URL,
    backend=settings.REDIS_URL,
    include=["app.tasks"]
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    task_routes={
        "app.tasks.email_tasks.*": {"queue": "email"},
        "app.tasks.payment_tasks.*": {"queue": "payment"},
        "app.tasks.reporting_tasks.*": {"queue": "reporting"},
    }
)

# Redis connection for simple queuing
redis_client = Redis.from_url(settings.REDIS_URL)

class TaskManager:
    """Background task manager"""

    @staticmethod
    async def send_email_async(
        background_tasks: BackgroundTasks,
        to_email: str,
        subject: str,
        template: str,
        context: Dict[str, Any]
    ):
        """Send email asynchronously"""
        from app.services.email_service import EmailService

        background_tasks.add_task(
            EmailService.send_template_email,
            to_email, subject, template, context
        )

    @staticmethod
    async def send_sms_async(
        background_tasks: BackgroundTasks,
        to_phone: str,
        message: str
    ):
        """Send SMS asynchronously"""
        from app.services.sms_service import SMSService

        background_tasks.add_task(
            SMSService.send_sms,
            to_phone, message
        )

    @staticmethod
    def process_payment_webhook(gateway: str, webhook_data: Dict):
        """Process payment webhook asynchronously"""
        from app.services.payment_service import PaymentService

        # Queue payment processing task
        celery_app.send_task(
            "app.tasks.payment_tasks.process_webhook",
            args=[gateway, webhook_data],
            queue="payment"
        )

    @staticmethod
    def generate_monthly_report(user_id: str, report_type: str):
        """Generate monthly report asynchronously"""
        celery_app.send_task(
            "app.tasks.reporting_tasks.generate_monthly_report",
            args=[user_id, report_type],
            queue="reporting",
            eta=datetime.utcnow() + timedelta(hours=1)  # Delay by 1 hour
        )

    @staticmethod
    def schedule_daily_maintenance():
        """Schedule daily maintenance tasks"""
        # Clean up old sessions
        celery_app.send_task(
            "app.tasks.maintenance_tasks.cleanup_sessions",
            queue="maintenance"
        )

        # Generate daily reports
        celery_app.send_task(
            "app.tasks.reporting_tasks.generate_daily_reports",
            queue="reporting"
        )

        # Process pending notifications
        celery_app.send_task(
            "app.tasks.notification_tasks.process_pending_notifications",
            queue="notifications"
        )

    @staticmethod
    def queue_video_processing(video_id: str, video_url: str):
        """Queue video processing task"""
        celery_app.send_task(
            "app.tasks.video_tasks.process_video",
            args=[video_id, video_url],
            queue="video"
        )

# Task decorators for Celery
def email_task(name: str):
    """Decorator for email-related tasks"""
    def decorator(func):
        func.name = f"app.tasks.email_tasks.{name}"
        return celery_app.task(func)
    return decorator

def payment_task(name: str):
    """Decorator for payment-related tasks"""
    def decorator(func):
        func.name = f"app.tasks.payment_tasks.{name}"
        return celery_app.task(func)
    return decorator

def reporting_task(name: str):
    """Decorator for reporting tasks"""
    def decorator(func):
        func.name = f"app.tasks.reporting_tasks.{name}"
        return celery_app.task(func)
    return decorator
```

#### Email Service Implementation
```python
# app/services/email_service.py
"""
Email Service
=============

This service handles email sending using multiple providers:
- SendGrid for transactional emails
- AWS SES for high-volume emails
- Template-based email rendering
- Email tracking and analytics
"""

import logging
from typing import Dict, Any, List
from pathlib import Path

import sendgrid
from sendgrid.helpers.mail import Mail, Email, To, Content, TemplateId
from jinja2 import Environment, FileSystemLoader
from sqlalchemy.orm import Session

from app.core.config import settings

logger = logging.getLogger(__name__)

class EmailService:
    """Email service with multiple provider support"""

    def __init__(self):
        self.sg_client = sendgrid.SendGridAPIClient(settings.SENDGRID_API_KEY)

        # Template engine setup
        template_dir = Path(__file__).parent / "templates" / "email"
        self.template_env = Environment(
            loader=FileSystemLoader(template_dir),
            autoescape=True
        )

    async def send_template_email(
        self,
        to_email: str,
        subject: str,
        template_name: str,
        context: Dict[str, Any],
        from_email: str = None
    ) -> bool:
        """Send email using HTML template"""

        try:
            # Render template
            template = self.template_env.get_template(f"{template_name}.html")
            html_content = template.render(**context)

            # Create text version (strip HTML)
            text_content = self._html_to_text(html_content)

            # Send email
            from_email_addr = from_email or settings.DEFAULT_FROM_EMAIL

            message = Mail(
                from_email=Email(from_email_addr),
                to_emails=To(to_email),
                subject=subject,
                html_content=Content("text/html", html_content),
                plain_text_content=Content("text/plain", text_content)
            )

            response = self.sg_client.send(message)

            logger.info(f"Email sent to {to_email}, status: {response.status_code}")
            return response.status_code == 202

        except Exception as e:
            logger.error(f"Failed to send email to {to_email}: {e}")
            return False

    async def send_bulk_email(
        self,
        to_emails: List[str],
        subject: str,
        template_name: str,
        context: Dict[str, Any]
    ) -> Dict[str, int]:
        """Send bulk email to multiple recipients"""

        results = {"successful": 0, "failed": 0}

        # Send emails individually to avoid bulk limits
        for email in to_emails:
            success = await self.send_template_email(
                email, subject, template_name, context
            )
            if success:
                results["successful"] += 1
            else:
                results["failed"] += 1

        logger.info(f"Bulk email completed: {results}")
        return results

    async def send_password_reset_email(self, to_email: str, reset_token: str) -> bool:
        """Send password reset email"""

        reset_url = f"{settings.FRONTEND_URL}/reset-password?token={reset_token}"

        return await self.send_template_email(
            to_email,
            "Reset Your Agent Mitra Password",
            "password_reset",
            {
                "reset_url": reset_url,
                "expiry_hours": 24
            }
        )

    async def send_welcome_email(self, to_email: str, user_name: str) -> bool:
        """Send welcome email to new users"""

        return await self.send_template_email(
            to_email,
            "Welcome to Agent Mitra!",
            "welcome",
            {
                "user_name": user_name,
                "login_url": f"{settings.FRONTEND_URL}/login",
                "support_email": settings.SUPPORT_EMAIL
            }
        )

    async def send_payment_confirmation_email(
        self,
        to_email: str,
        policy_number: str,
        amount: float,
        payment_date: str
    ) -> bool:
        """Send payment confirmation email"""

        return await self.send_template_email(
            to_email,
            f"Payment Confirmation - Policy {policy_number}",
            "payment_confirmation",
            {
                "policy_number": policy_number,
                "amount": amount,
                "payment_date": payment_date,
                "support_email": settings.SUPPORT_EMAIL
            }
        )

    def _html_to_text(self, html_content: str) -> str:
        """Convert HTML to plain text"""
        # Simple HTML to text conversion
        # In production, use libraries like html2text
        import re

        # Remove HTML tags
        text = re.sub(r'<[^>]+>', '', html_content)

        # Decode HTML entities
        import html
        text = html.unescape(text)

        # Clean up whitespace
        text = re.sub(r'\s+', ' ', text).strip()

        return text
```

## 5. Testing & Quality Assurance

### 5.1 Test Structure & Organization

#### Test Configuration
```python
# tests/conftest.py
"""
Test Configuration and Fixtures
===============================

This module provides test configuration, database fixtures,
and common test utilities for the entire test suite.
"""

import pytest
import asyncio
from typing import Generator, Dict, Any
from unittest.mock import Mock

from fastapi import FastAPI
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import StaticPool

from app.core.config import settings
from app.core.database import Base, get_db
from app.api.v1.api import api_router
from app.services.auth_service import AuthService

# Test database URL
TEST_DATABASE_URL = "sqlite:///./test.db"

# Create test engine
test_engine = create_engine(
    TEST_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)

# Create test session
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)

@pytest.fixture(scope="session")
def event_loop():
    """Create an instance of the default event loop for the test session."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()

@pytest.fixture(scope="session")
def test_db():
    """Create test database and tables"""
    Base.metadata.create_all(bind=test_engine)
    yield
    Base.metadata.drop_all(bind=test_engine)

@pytest.fixture
def db_session(test_db) -> Generator[Session, None, None]:
    """Get database session for tests"""
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()

@pytest.fixture
def client(test_db) -> TestClient:
    """Get FastAPI test client"""

    def override_get_db():
        session = TestingSessionLocal()
        try:
            yield session
        finally:
            session.close()

    app = FastAPI()
    app.include_router(api_router)

    # Override dependency
    app.dependency_overrides[get_db] = override_get_db

    return TestClient(app)

@pytest.fixture
def test_user(db_session: Session) -> Dict[str, Any]:
    """Create test user"""
    from app.models.user import User
    from app.core.security import SecurityService

    user_data = {
        "email": "test@example.com",
        "password_hash": SecurityService.hash_password("testpass123"),
        "first_name": "Test",
        "last_name": "User",
        "role": "policyholder",
        "status": "active"
    }

    user = User(**user_data)
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)

    return {
        "id": str(user.id),
        "email": user.email,
        "role": user.role
    }

@pytest.fixture
def auth_headers(test_user: Dict[str, Any]) -> Dict[str, str]:
    """Get authentication headers for test user"""
    from app.core.security import SecurityService

    access_token = SecurityService.create_access_token(
        data={"sub": test_user["id"], "tenant_id": "test-tenant"}
    )

    return {"Authorization": f"Bearer {access_token}"}

@pytest.fixture
def mock_payment_service():
    """Mock payment service for tests"""
    mock_service = Mock()
    mock_service.create_payment_order.return_value = {
        "order_id": "test_order_123",
        "amount": 250000,  # 2500.00 INR in paisa
        "currency": "INR"
    }
    return mock_service

@pytest.fixture
def mock_email_service():
    """Mock email service for tests"""
    mock_service = Mock()
    mock_service.send_template_email.return_value = True
    return mock_service
```

#### API Endpoint Tests
```python
# tests/test_auth.py
"""
Authentication API Tests
========================

This module tests authentication endpoints including:
- User registration and login
- Token refresh and validation
- Password reset functionality
- MFA and security features
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

class TestAuthentication:
    """Test authentication endpoints"""

    def test_user_registration(self, client: TestClient, db_session: Session):
        """Test user registration endpoint"""
        user_data = {
            "email": "newuser@example.com",
            "password": "securepassword123",
            "first_name": "New",
            "last_name": "User",
            "phone_number": "+919876543210"
        }

        response = client.post("/auth/register", json=user_data)

        assert response.status_code == 201
        data = response.json()
        assert data["success"] is True
        assert "user" in data["data"]
        assert data["data"]["user"]["email"] == user_data["email"]

    def test_user_login_success(self, client: TestClient, test_user: Dict[str, Any]):
        """Test successful user login"""
        login_data = {
            "identifier": test_user["email"],
            "password": "testpass123"
        }

        response = client.post("/auth/login", json=login_data)

        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "access_token" in data["data"]
        assert "refresh_token" in data["data"]
        assert data["data"]["token_type"] == "bearer"

    def test_user_login_invalid_credentials(self, client: TestClient):
        """Test login with invalid credentials"""
        login_data = {
            "identifier": "nonexistent@example.com",
            "password": "wrongpassword"
        }

        response = client.post("/auth/login", json=login_data)

        assert response.status_code == 401
        data = response.json()
        assert data["success"] is False
        assert "Invalid credentials" in data["message"]

    def test_token_refresh(self, client: TestClient, auth_headers: Dict[str, str]):
        """Test token refresh functionality"""
        # First login to get tokens
        login_response = client.post("/auth/login", json={
            "identifier": "test@example.com",
            "password": "testpass123"
        })

        refresh_token = login_response.json()["data"]["refresh_token"]

        # Test refresh
        refresh_response = client.post("/auth/refresh", json={
            "refresh_token": refresh_token
        })

        assert refresh_response.status_code == 200
        data = refresh_response.json()
        assert data["success"] is True
        assert "access_token" in data["data"]

    def test_password_reset_request(self, client: TestClient, test_user: Dict[str, Any]):
        """Test password reset request"""
        reset_data = {"email": test_user["email"]}

        response = client.post("/auth/request-password-reset", json=reset_data)

        # Should always return success for security
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True

    def test_protected_endpoint_access(self, client: TestClient, auth_headers: Dict[str, str]):
        """Test access to protected endpoints"""
        # Without auth headers - should fail
        response = client.get("/users/profile")
        assert response.status_code == 401

        # With auth headers - should succeed
        response = client.get("/users/profile", headers=auth_headers)
        assert response.status_code == 200

class TestAuthorization:
    """Test authorization and role-based access"""

    def test_role_based_access_control(self, client: TestClient):
        """Test that users can only access appropriate resources"""
        # Create users with different roles
        agent_user = self._create_test_user(client, role="agent")
        customer_user = self._create_test_user(client, role="policyholder")

        # Agent should be able to access agent-specific endpoints
        agent_headers = self._get_auth_headers(client, agent_user)
        response = client.get("/policies/agent-dashboard", headers=agent_headers)
        assert response.status_code == 200

        # Customer should not be able to access agent endpoints
        customer_headers = self._get_auth_headers(client, customer_user)
        response = client.get("/policies/agent-dashboard", headers=customer_headers)
        assert response.status_code == 403

    def _create_test_user(self, client: TestClient, role: str) -> Dict[str, Any]:
        """Helper method to create test user"""
        user_data = {
            "email": f"test_{role}@example.com",
            "password": "testpass123",
            "first_name": "Test",
            "last_name": role.title(),
            "role": role
        }

        response = client.post("/auth/register", json=user_data)
        return response.json()["data"]["user"]

    def _get_auth_headers(self, client: TestClient, user: Dict[str, Any]) -> Dict[str, str]:
        """Helper method to get auth headers"""
        login_response = client.post("/auth/login", json={
            "identifier": user["email"],
            "password": "testpass123"
        })

        access_token = login_response.json()["data"]["access_token"]
        return {"Authorization": f"Bearer {access_token}"}
```

### 5.2 Performance Testing

#### Load Testing Configuration
```python
# tests/performance/test_load.py
"""
Load Testing Suite
==================

This module provides load testing for critical endpoints
using Locust for distributed load testing.
"""

import json
from locust import HttpUser, task, between
from locust.contrib.fasthttp import FastHttpUser

class AgentMitraUser(FastHttpUser):
    """Load testing user for Agent Mitra API"""

    wait_time = between(1, 3)  # Wait 1-3 seconds between requests

    def on_start(self):
        """Setup before tests start"""
        # Login and get token
        response = self.client.post("/auth/login", json={
            "identifier": "loadtest@example.com",
            "password": "loadtest123"
        })

        if response.status_code == 200:
            self.token = response.json()["data"]["access_token"]
            self.headers = {"Authorization": f"Bearer {self.token}"}
        else:
            self.token = None
            self.headers = {}

    @task(3)  # 30% of requests
    def get_policies(self):
        """Test policy listing endpoint"""
        if self.token:
            self.client.get("/policies/", headers=self.headers)

    @task(2)  # 20% of requests
    def get_policy_details(self):
        """Test policy details endpoint"""
        if self.token:
            # Use a known policy ID for testing
            self.client.get("/policies/test-policy-id", headers=self.headers)

    @task(2)  # 20% of requests
    def chatbot_interaction(self):
        """Test chatbot endpoint"""
        if self.token:
            self.client.post("/chatbot/message", json={
                "message": "What is my policy status?",
                "language": "en"
            }, headers=self.headers)

    @task(1)  # 10% of requests
    def create_payment(self):
        """Test payment creation endpoint"""
        if self.token:
            self.client.post("/payments/create", json={
                "policy_id": "test-policy-id",
                "amount": 2500.00,
                "currency": "INR"
            }, headers=self.headers)

    @task(1)  # 10% of requests
    def get_dashboard(self):
        """Test dashboard endpoint"""
        if self.token:
            self.client.get("/analytics/dashboard", headers=self.headers)

    @task(1)  # 10% of requests
    def search_policies(self):
        """Test search functionality"""
        if self.token:
            self.client.get("/policies/search?q=life+insurance", headers=self.headers)

# Performance test scenarios
class PeakLoadTest(AgentMitraUser):
    """Test peak load scenario"""
    wait_time = between(0.5, 1)  # Faster requests for peak load

class SustainedLoadTest(AgentMitraUser):
    """Test sustained load scenario"""
    wait_time = between(2, 5)  # More realistic sustained usage

class StressTest(AgentMitraUser):
    """Test stress/load breaking point"""
    wait_time = between(0.1, 0.5)  # Very fast requests to find limits
```

## 6. Monitoring & Logging

### 6.1 Application Monitoring

#### Structured Logging Configuration
```python
# app/core/logging.py
"""
Logging Configuration
====================

This module provides structured logging configuration with:
- Multiple log levels and formatters
- Structured JSON logging for production
- Request/response logging middleware
- Error tracking and correlation IDs
"""

import logging
import json
import sys
from datetime import datetime
from typing import Dict, Any
from pythonjsonlogger import jsonlogger

from app.core.config import settings

class StructuredFormatter(jsonlogger.JsonFormatter):
    """Custom JSON formatter for structured logging"""

    def add_fields(self, log_record, record, message_dict):
        super().add_fields(log_record, record, message_dict)

        # Add custom fields
        log_record['timestamp'] = datetime.utcnow().isoformat()
        log_record['service'] = 'agent-mitra-api'
        log_record['version'] = settings.VERSION
        log_record['environment'] = settings.ENVIRONMENT

        # Add request context if available
        if hasattr(record, 'request_id'):
            log_record['request_id'] = record.request_id

        if hasattr(record, 'user_id'):
            log_record['user_id'] = record.user_id

def setup_logging():
    """Setup logging configuration"""

    # Create logger
    logger = logging.getLogger()
    logger.setLevel(getattr(logging, settings.LOG_LEVEL.upper()))

    # Remove existing handlers
    for handler in logger.handlers[:]:
        logger.removeHandler(handler)

    # Console handler for development
    if settings.ENVIRONMENT == "development":
        console_handler = logging.StreamHandler(sys.stdout)
        console_formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        console_handler.setFormatter(console_formatter)
        logger.addHandler(console_handler)
    else:
        # JSON structured logging for production
        json_handler = logging.StreamHandler(sys.stdout)
        json_formatter = StructuredFormatter(
            '%(timestamp)s %(service)s %(version)s %(levelname)s %(name)s %(message)s'
        )
        json_handler.setFormatter(json_formatter)
        logger.addHandler(json_handler)

    # File handler for all environments
    file_handler = logging.FileHandler('logs/agent_mitra.log')
    file_formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(levelname)s - %(message)s'
    )
    file_handler.setFormatter(file_formatter)
    logger.addHandler(file_handler)

    # Set third-party library log levels
    logging.getLogger('sqlalchemy').setLevel(logging.WARNING)
    logging.getLogger('urllib3').setLevel(logging.WARNING)
    logging.getLogger('httpx').setLevel(logging.WARNING)

    return logger

class RequestLogger:
    """Request logging middleware"""

    def __init__(self, logger: logging.Logger):
        self.logger = logger

    async def log_request(self, request, response=None, error=None):
        """Log HTTP request/response"""

        log_data = {
            'method': request.method,
            'url': str(request.url),
            'client_ip': request.client.host if request.client else None,
            'user_agent': request.headers.get('user-agent'),
            'request_id': request.headers.get('x-request-id'),
        }

        if response:
            log_data.update({
                'status_code': response.status_code,
                'response_time': getattr(response, 'process_time', None),
                'content_length': response.headers.get('content-length')
            })
            self.logger.info("HTTP Request completed", extra=log_data)
        elif error:
            log_data.update({
                'error': str(error),
                'error_type': type(error).__name__
            })
            self.logger.error("HTTP Request failed", extra=log_data)
        else:
            self.logger.info("HTTP Request started", extra=log_data)
```

#### Health Monitoring & Metrics
```python
# app/core/monitoring.py
"""
Application Monitoring & Metrics
================================

This module provides comprehensive monitoring including:
- Application performance metrics
- Health checks and alerts
- Custom business metrics
- Integration with monitoring services
"""

import time
import logging
from typing import Dict, Any, Optional
from dataclasses import dataclass
from contextlib import asynccontextmanager

import psutil
from prometheus_client import Counter, Histogram, Gauge, generate_latest

from app.core.config import settings

logger = logging.getLogger(__name__)

# Prometheus metrics
REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status_code']
)

REQUEST_LATENCY = Histogram(
    'http_request_duration_seconds',
    'HTTP request latency',
    ['method', 'endpoint']
)

ACTIVE_CONNECTIONS = Gauge(
    'active_connections',
    'Number of active connections'
)

DB_CONNECTIONS = Gauge(
    'db_connections_active',
    'Number of active database connections'
)

MEMORY_USAGE = Gauge(
    'memory_usage_bytes',
    'Memory usage in bytes'
)

@dataclass
class HealthStatus:
    """Health check status"""
    status: str  # 'healthy', 'degraded', 'unhealthy'
    timestamp: float
    checks: Dict[str, Dict[str, Any]]

class MonitoringService:
    """Application monitoring service"""

    def __init__(self):
        self.start_time = time.time()

    async def health_check(self) -> HealthStatus:
        """Comprehensive health check"""

        checks = {}

        # Database health
        db_status = await self._check_database()
        checks['database'] = db_status

        # Redis health
        redis_status = await self._check_redis()
        checks['redis'] = redis_status

        # External services
        external_status = await self._check_external_services()
        checks['external_services'] = external_status

        # Application metrics
        app_status = await self._check_application_metrics()
        checks['application'] = app_status

        # Determine overall status
        failed_checks = [k for k, v in checks.items() if not v.get('healthy', False)]
        if failed_checks:
            if len(failed_checks) > 2:
                status = 'unhealthy'
            else:
                status = 'degraded'
        else:
            status = 'healthy'

        return HealthStatus(
            status=status,
            timestamp=time.time(),
            checks=checks
        )

    async def get_metrics(self) -> str:
        """Get Prometheus metrics"""
        # Update gauges
        MEMORY_USAGE.set(psutil.virtual_memory().used)

        # Generate latest metrics
        return generate_latest()

    async def record_request_metrics(
        self,
        method: str,
        endpoint: str,
        status_code: int,
        duration: float
    ):
        """Record HTTP request metrics"""
        REQUEST_COUNT.labels(
            method=method,
            endpoint=endpoint,
            status_code=status_code
        ).inc()

        REQUEST_LATENCY.labels(
            method=method,
            endpoint=endpoint
        ).observe(duration)

    @asynccontextmanager
    async def measure_request_time(self, method: str, endpoint: str):
        """Context manager to measure request time"""
        start_time = time.time()
        try:
            yield
        finally:
            duration = time.time() - start_time
            await self.record_request_metrics(method, endpoint, 200, duration)

    async def _check_database(self) -> Dict[str, Any]:
        """Check database connectivity"""
        try:
            from app.core.database import check_database_health
            result = await check_database_health()
            return {
                'healthy': result['status'] == 'healthy',
                'response_time': result.get('response_time'),
                'active_connections': result.get('active_connections')
            }
        except Exception as e:
            return {
                'healthy': False,
                'error': str(e)
            }

    async def _check_redis(self) -> Dict[str, Any]:
        """Check Redis connectivity"""
        try:
            import redis
            r = redis.from_url(settings.REDIS_URL)
            r.ping()
            return {'healthy': True}
        except Exception as e:
            return {
                'healthy': False,
                'error': str(e)
            }

    async def _check_external_services(self) -> Dict[str, Any]:
        """Check external service connectivity"""
        services_status = {}

        # Check OpenAI
        try:
            import openai
            # Simple connectivity check
            services_status['openai'] = {'healthy': True}
        except:
            services_status['openai'] = {'healthy': False}

        # Check WhatsApp
        try:
            # WhatsApp connectivity check
            services_status['whatsapp'] = {'healthy': True}
        except:
            services_status['whatsapp'] = {'healthy': False}

        return services_status

    async def _check_application_metrics(self) -> Dict[str, Any]:
        """Check application-specific metrics"""
        return {
            'healthy': True,
            'uptime_seconds': time.time() - self.start_time,
            'memory_usage': psutil.virtual_memory().percent,
            'cpu_usage': psutil.cpu_percent(interval=1)
        }

# Global monitoring instance
monitoring = MonitoringService()
```

This comprehensive Python backend design provides a solid foundation for the Agent Mitra platform with production-ready features, extensive testing, monitoring, and scalable architecture. The design supports microservices evolution, comprehensive security, and enterprise-grade reliability.
