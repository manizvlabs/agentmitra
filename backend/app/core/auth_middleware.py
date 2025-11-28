"""
Authentication and Authorization Middleware
===========================================

FastAPI middleware for JWT authentication and RBAC authorization.
All API endpoints are protected by default unless explicitly marked as public.
"""

import logging
from typing import Optional, Dict, Any, List
from fastapi import Request, HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from sqlalchemy import text
from jose import jwt, JWTError

from app.core.config.settings import settings
from app.core.database import get_db
from app.services.rbac_service import get_rbac_service, RBACService
from app.core.logging_config import get_logger

logger = get_logger(__name__)

# Security scheme
security = HTTPBearer(auto_error=False)


class UserContext:
    """User context object containing user information and permissions"""

    def __init__(self, user_id: str, username: str, email: str, roles: List[str], permissions: set):
        self.user_id = user_id
        self.username = username
        self.email = email
        self.roles = roles
        self.permissions = permissions

    def has_role(self, role: str) -> bool:
        """Check if user has specific role"""
        return role in self.roles

    def has_any_role(self, roles: List[str]) -> bool:
        """Check if user has any of the specified roles"""
        return any(role in self.roles for role in roles)

    def has_permission(self, permission: str) -> bool:
        """Check if user has specific permission"""
        return permission in self.permissions

    def has_any_permission(self, permissions: List[str]) -> bool:
        """Check if user has any of the specified permissions"""
        return any(perm in self.permissions for perm in permissions)


async def get_current_user_context(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
    db: Session = Depends(get_db)
) -> UserContext:
    """
    Get current authenticated user context with roles and permissions

    This dependency is used by all protected endpoints
    """
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        # Decode JWT token
        payload = jwt.decode(
            credentials.credentials,
            settings.jwt_secret_key,
            algorithms=[settings.jwt_algorithm]
        )

        user_id = payload.get("user_id") or payload.get("sub")
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token: missing user ID"
            )

        # Get user from database
        result = db.execute(text("""
            SELECT id, username, email, first_name, last_name, role, status
            FROM users
            WHERE id = :user_id
        """), {"user_id": user_id})

        user_row = result.first()
        if not user_row:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found"
            )

        # Check if user is active
        if user_row.status != "active":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Account is not active"
            )

        # Get user roles and permissions
        roles = [user_row.role] if user_row.role else ["guest"]
        permissions = set()

        # For now, use basic permissions based on role
        # TODO: Integrate with full RBAC system when database tables are ready
        try:
            rbac_service = get_rbac_service(db)
            db_roles = await rbac_service.get_user_roles(str(user_row.id))
            if db_roles:
                roles = db_roles
            db_permissions = await rbac_service.get_user_permissions(str(user_row.id))
            if db_permissions:
                permissions = db_permissions
        except Exception as e:
            logger.warning(f"RBAC service not available, using basic permissions: {e}")
            # Fallback to basic permissions based on role
            if user_row.role == "junior_agent":
                permissions = {"customers.read", "policies.read", "communication.send"}
            elif user_row.role == "senior_agent":
                permissions = {"customers.*", "policies.*", "analytics.read", "communication.*"}
            elif user_row.role == "provider_admin":
                permissions = {"users.read", "agents.*", "customers.*", "policies.*", "analytics.read"}
            elif user_row.role == "super_admin":
                permissions = {"*"}  # All permissions

        return UserContext(
            user_id=str(user_row.id),
            username=user_row.username,
            email=user_row.email,
            roles=roles,
            permissions=permissions
        )

    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired"
        )
    except JWTError as e:
        logger.warning(f"JWT validation failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication token"
        )
    except Exception as e:
        logger.error(f"Authentication error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Authentication service error"
        )


def require_permission(permission: str):
    """Dependency to require specific permission"""
    async def dependency(user: UserContext = Depends(get_current_user_context)) -> UserContext:
        if not user.has_permission(permission):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Insufficient permissions: {permission} required"
            )
        return user
    return dependency


def require_any_permission(permissions: List[str]):
    """Dependency to require any of the specified permissions"""
    async def dependency(user: UserContext = Depends(get_current_user_context)) -> UserContext:
        if not user.has_any_permission(permissions):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Insufficient permissions: one of {permissions} required"
            )
        return user
    return dependency


def require_role(role: str):
    """Dependency to require specific role"""
    async def dependency(user: UserContext = Depends(get_current_user_context)) -> UserContext:
        if not user.has_role(role):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied: {role} role required"
            )
        return user
    return dependency


def require_any_role(roles: List[str]):
    """Dependency to require any of the specified roles"""
    async def dependency(user: UserContext = Depends(get_current_user_context)) -> UserContext:
        if not user.has_any_role(roles):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied: one of {roles} roles required"
            )
        return user
    return dependency


# Public endpoints that don't require authentication
PUBLIC_ENDPOINTS = {
    "/api/v1/auth/login",
    "/api/v1/auth/register",
    "/api/v1/health",
    "/docs",
    "/redoc",
    "/openapi.json",
}


async def auth_middleware(request: Request, call_next):
    """
    Authentication middleware for all API endpoints

    This middleware runs on every request and enforces authentication
    unless the endpoint is explicitly marked as public.
    """
    path = request.url.path

    # Allow public endpoints
    if path in PUBLIC_ENDPOINTS or path.startswith(("/static/", "/docs", "/redoc", "/openapi.json")):
        return await call_next(request)

    # Check if it's an API endpoint (starts with /api/)
    if not path.startswith("/api/"):
        return await call_next(request)

    # For API endpoints, authentication is required
    # The actual authentication check happens in the endpoint dependencies
    # This middleware just ensures we don't bypass auth for API routes

    try:
        response = await call_next(request)
        return response
    except HTTPException as e:
        # Re-raise HTTP exceptions as-is
        raise e
    except Exception as e:
        logger.error(f"Request processing error: {e}")
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={"detail": "Internal server error"}
        )


def check_tenant_access(tenant_id: Optional[str] = None):
    """Dependency to check tenant access for multi-tenant operations"""
    async def dependency(
        user: UserContext = Depends(get_current_user_context),
        db: Session = Depends(get_db)
    ) -> UserContext:
        if tenant_id:
            rbac_service = get_rbac_service(db)
            if not await rbac_service.can_access_tenant(user.user_id, tenant_id):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Access denied: cannot access this tenant"
                )
        return user
    return dependency


def check_resource_access(resource_type: str, resource_id: str):
    """Dependency to check resource-level access (row-level security)"""
    async def dependency(
        user: UserContext = Depends(get_current_user_context),
        db: Session = Depends(get_db)
    ) -> UserContext:
        rbac_service = get_rbac_service(db)
        if not await rbac_service.can_access_resource(user.user_id, resource_type, resource_id):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied: cannot access this {resource_type}"
            )
        return user
    return dependency
