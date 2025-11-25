"""
Authentication and Authorization middleware
"""
from fastapi import Depends, HTTPException, status, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from typing import Optional, List, Dict, Any
from app.core.database import get_db
from app.core.security import validate_jwt_token, extract_token_from_header
from app.core.logging_config import get_logger
from app.repositories.user_repository import UserRepository
from app.models.user import User

logger = get_logger(__name__)

# Security scheme
security = HTTPBearer(auto_error=False)


# Role hierarchy and permissions
ROLE_HIERARCHY = {
    "super_admin": 100,
    "provider_admin": 80,
    "regional_manager": 60,
    "senior_agent": 40,
    "junior_agent": 20,
    "policyholder": 10,
    "guest": 0,
}

PERMISSIONS = {
    # Authentication & Profile
    "auth.login": ["*"],
    "auth.logout": ["*"],
    "profile.read": ["*"],
    "profile.update": ["*"],

    # User Management (Admin only)
    "users.read": ["super_admin", "provider_admin"],
    "users.create": ["super_admin"],
    "users.update": ["super_admin", "provider_admin"],
    "users.delete": ["super_admin"],
    "users.search": ["super_admin", "provider_admin", "regional_manager"],

    # Provider Management
    "providers.read": ["*"],
    "providers.create": ["super_admin"],
    "providers.update": ["super_admin", "provider_admin"],
    "providers.delete": ["super_admin"],

    # Agent Management
    "agents.read": ["super_admin", "provider_admin", "regional_manager"],
    "agents.create": ["super_admin", "provider_admin"],
    "agents.update": ["super_admin", "provider_admin", "regional_manager", "senior_agent"],
    "agents.approve": ["super_admin", "provider_admin", "regional_manager"],

    # Policy Management
    "policies.read": ["*"],  # Users can read their own policies
    "policies.create": ["junior_agent", "senior_agent"],
    "policies.update": ["junior_agent", "senior_agent", "regional_manager"],
    "policies.approve": ["regional_manager", "provider_admin"],
    "policies.delete": ["super_admin", "provider_admin"],

    # Session Management
    "sessions.read": ["*"],
    "sessions.delete": ["*"],

    # Analytics & Reporting
    "analytics.read": ["super_admin", "provider_admin", "regional_manager", "senior_agent"],
    "reports.generate": ["super_admin", "provider_admin", "regional_manager"],
}


class UserContext:
    """User context for authenticated requests"""

    def __init__(self, user: User, token_data: Dict[str, Any], db: Optional[Session] = None):
        self.user = user
        self.user_id = str(user.user_id)
        self.phone_number = user.phone_number
        self.role = user.role
        self.email = user.email
        self.token_data = token_data
        self._db = db
        self._agent_id = None
        self.permissions = self._get_permissions()
    
    @property
    def agent_id(self) -> Optional[str]:
        """Get agent_id for the user if they are an agent"""
        if self._agent_id is not None:
            return self._agent_id
        
        # Only lookup if user is an agent role
        if self.role not in ['junior_agent', 'senior_agent', 'regional_manager']:
            self._agent_id = None
            return None
        
        # Lookup agent_id from database
        if self._db:
            try:
                from app.models.agent import Agent
                agent = self._db.query(Agent).filter(Agent.user_id == self.user.user_id).first()
                if agent:
                    self._agent_id = str(agent.agent_id)
                    return self._agent_id
            except Exception as e:
                logger.warning(f"Error looking up agent_id for user {self.user_id}: {e}")
                self._agent_id = None
                return None
        
        self._agent_id = None
        return None

    def _get_permissions(self) -> List[str]:
        """Get user permissions based on role"""
        user_role = self.role
        permissions = []

        # Add all permissions for user's role and lower roles
        user_level = ROLE_HIERARCHY.get(user_role, 0)

        for permission, allowed_roles in PERMISSIONS.items():
            if "*" in allowed_roles or user_role in allowed_roles:
                permissions.append(permission)
            else:
                # Check role hierarchy
                for role in allowed_roles:
                    if ROLE_HIERARCHY.get(role, 0) <= user_level:
                        permissions.append(permission)
                        break

        return permissions

    def has_permission(self, permission: str) -> bool:
        """Check if user has specific permission"""
        return permission in self.permissions

    def has_any_permission(self, permissions: List[str]) -> bool:
        """Check if user has any of the specified permissions"""
        return any(perm in self.permissions for perm in permissions)

    def has_role(self, role: str) -> bool:
        """Check if user has specific role"""
        return self.role == role

    def has_role_level(self, min_role: str) -> bool:
        """Check if user has role at or above specified level"""
        user_level = ROLE_HIERARCHY.get(self.role, 0)
        min_level = ROLE_HIERARCHY.get(min_role, 100)
        return user_level >= min_level


def get_current_user_context(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
) -> UserContext:
    """
    Dependency to get current authenticated user context
    """
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication credentials not provided",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = credentials.credentials

    # Validate token
    token_data = validate_jwt_token(token, "access")
    if not token_data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Get user from database
    user_repo = UserRepository(db)
    user_id = token_data.get("sub")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token data",
        )

    user = user_repo.get_by_id(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
        )

    # Check if user is active
    if hasattr(user, 'status') and user.status != 'active':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is not active",
        )

    return UserContext(user, token_data, db)


def get_current_user_optional(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
) -> Optional[UserContext]:
    """
    Optional authentication - returns None if not authenticated
    """
    try:
        return get_current_user_context(credentials, db)
    except HTTPException:
        return None


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
) -> User:
    """
    Dependency to get current authenticated user
    """
    user_context = get_current_user_context(credentials, db)
    return user_context.user


def require_permission(permission: str):
    """
    Dependency factory for permission-based access control
    """
    def dependency(current_user: UserContext = Depends(get_current_user_context)):
        if not current_user.has_permission(permission):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Insufficient permissions: {permission} required",
            )
        return current_user
    return dependency


def require_any_permission(permissions: List[str]):
    """
    Dependency factory for multiple permission options
    """
    def dependency(current_user: UserContext = Depends(get_current_user_context)):
        if not current_user.has_any_permission(permissions):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Insufficient permissions: one of {permissions} required",
            )
        return current_user
    return dependency


def require_role(role: str):
    """
    Dependency factory for role-based access control
    """
    def dependency(current_user: UserContext = Depends(get_current_user_context)):
        if not current_user.has_role(role):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Role {role} required",
            )
        return current_user
    return dependency


def require_role_level(min_role: str):
    """
    Dependency factory for minimum role level
    """
    def dependency(current_user: UserContext = Depends(get_current_user_context)):
        if not current_user.has_role_level(min_role):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Minimum role level {min_role} required",
            )
        return current_user
    return dependency


# Request logging middleware
async def log_request_middleware(request: Request, call_next):
    """
    Middleware to log API requests with user context
    """
    import time

    start_time = time.time()

    # Get user context if available
    user_context = getattr(request.state, 'user', None)
    user_id = user_context.user_id if user_context else None

    # Log request
    logger.info(
        "API Request",
        extra={
            "method": request.method,
            "url": str(request.url),
            "user_id": user_id,
            "user_agent": request.headers.get("user-agent"),
            "ip": request.client.host if request.client else None,
        }
    )

    # Process request
    response = await call_next(request)

    # Log response
    process_time = time.time() - start_time
    logger.info(
        "API Response",
        extra={
            "method": request.method,
            "url": str(request.url),
            "status_code": response.status_code,
            "process_time": round(process_time * 1000, 2),  # ms
            "user_id": user_id,
        }
    )

    return response
