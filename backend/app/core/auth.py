"""
Authentication and Authorization middleware
"""
from fastapi import Depends, HTTPException, status, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from typing import Optional, List, Dict, Any
from app.core.database import get_db
from app.core.security import validate_jwt_token, extract_token_from_header
from app.repositories.user_repository import UserRepository
from app.models.user import User
from app.models.rbac import Role, Permission, UserRole
from app.models.feature_flags import FeatureFlag, FeatureFlagOverride

# Fallback constants for when RBAC models are disabled
PERMISSIONS = {}
ROLE_HIERARCHY = {}
from datetime import datetime
import time
import json
from typing import Set, Dict, Any
from sqlalchemy import text

# Lazy logger initialization to avoid import issues
_logger = None

def get_auth_logger():
    """Get logger for auth module, initialized lazily"""
    global _logger
    if _logger is None:
        try:
            from app.core.logging_config import get_logger
            _logger = get_logger(__name__)
        except Exception:
            # Fallback logger if get_logger fails during import
            import logging
            _logger = logging.getLogger(__name__)
            _logger.setLevel(logging.INFO)
    return _logger

# For backward compatibility
logger = None  # Will be set by get_auth_logger()

# Security scheme
security = HTTPBearer(auto_error=False)


# Role hierarchy for permission inheritance
ROLE_HIERARCHY = {
    "super_admin": 100,
    "compliance_officer": 95,
    "customer_support_lead": 90,
    "insurance_provider_admin": 80,
    "regional_manager": 60,
    "senior_agent": 40,
    "junior_agent": 20,
    "support_staff": 15,
    "policyholder": 10,
    "guest": 0,
}

# Role inheritance mapping (higher roles inherit permissions from lower roles)
ROLE_INHERITANCE = {
    "super_admin": ["compliance_officer", "customer_support_lead", "insurance_provider_admin", "regional_manager", "senior_agent", "junior_agent", "support_staff", "policyholder", "guest"],
    "insurance_provider_admin": ["regional_manager", "senior_agent", "junior_agent", "support_staff", "policyholder"],
    "regional_manager": ["senior_agent", "junior_agent", "support_staff"],
    "senior_agent": ["junior_agent"],
    "customer_support_lead": ["support_staff"],
    # Other roles don't inherit from lower roles
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
    "tenants.read": ["super_admin"],
    "tenants.create": ["super_admin"],
    "tenants.update": ["super_admin"],
    "tenants.delete": ["super_admin"],
}


# Import feature flag models
# from app.models.feature_flags import FeatureFlag, FeatureFlagOverride

# Database-driven Authorization Service
class AuthorizationService:
    """Comprehensive database-driven authorization service with RBAC"""

    def __init__(self, redis_client=None):
        # Use Redis for caching if available, otherwise fallback to in-memory
        self._redis_client = redis_client
        self._memory_cache: Dict[str, tuple] = {}
        self._cache_ttl = 300  # 5 minutes
        self._use_redis = redis_client is not None

    # ==================== PERMISSION CHECKING ====================

    def has_permission(self, user_id: str, permission: str, db: Session, tenant_id: str = None) -> bool:
        """Check if user has a specific permission with tenant context"""
        try:
            # Get user's roles and their permissions
            user_permissions = self._get_user_permissions(user_id, db)

            # Check tenant access if tenant_id is provided
            if tenant_id and not self._has_tenant_access(user_id, tenant_id, db):
                return False

            # Check if user has the permission or a wildcard permission
            return (
                permission in user_permissions or
                "*" in user_permissions or
                self._matches_wildcard(permission, user_permissions)
            )
        except Exception as e:
            get_auth_logger().error(f"Error checking permission {permission} for user {user_id}: {e}")
            return False

    def _has_tenant_access(self, user_id: str, tenant_id: str, db: Session) -> bool:
        """Check if user has access to the specified tenant"""
        try:
            from app.models.user import TenantUser

            # Check if user is assigned to tenant
            tenant_user = db.query(TenantUser).filter(
                TenantUser.user_id == user_id,
                TenantUser.tenant_id == tenant_id,
                TenantUser.status == 'active'
            ).first()

            # If user is assigned to tenant, allow access
            if tenant_user:
                return True

            # Check if user has super_admin role (can access all tenants)
            user_roles = self._get_user_roles(user_id, db)
            if "super_admin" in user_roles:
                return True

            return False

        except Exception as e:
            get_auth_logger().error(f"Error checking tenant access for user {user_id}, tenant {tenant_id}: {e}")
            return False

    def has_any_permission(self, user_id: str, permissions: List[str], db: Session, tenant_id: str = None) -> bool:
        """Check if user has any of the specified permissions"""
        for permission in permissions:
            if self.has_permission(user_id, permission, db, tenant_id):
                return True
        return False

    def has_all_permissions(self, user_id: str, permissions: List[str], db: Session, tenant_id: str = None) -> bool:
        """Check if user has all of the specified permissions"""
        for permission in permissions:
            if not self.has_permission(user_id, permission, db, tenant_id):
                return False
        return True

    # ==================== ROLE CHECKING ====================

    def has_role(self, user_id: str, role_name: str, db: Session) -> bool:
        """Check if user has a specific role"""
        try:
            user_roles = self._get_user_roles(user_id, db)
            return role_name in user_roles
        except Exception as e:
            get_auth_logger().error(f"Error checking role {role_name} for user {user_id}: {e}")
            return False

    def has_any_role(self, user_id: str, role_names: List[str], db: Session) -> bool:
        """Check if user has any of the specified roles"""
        for role_name in role_names:
            if self.has_role(user_id, role_name, db):
                return True
        return False

    def has_role_level(self, user_id: str, min_role_level: int, db: Session) -> bool:
        """Check if user has role at or above specified level"""
        try:
            user_roles = self._get_user_roles(user_id, db)
            for role_name in user_roles:
                if ROLE_HIERARCHY.get(role_name, 0) >= min_role_level:
                    return True
            return False
        except Exception as e:
            get_auth_logger().error(f"Error checking role level for user {user_id}: {e}")
            return False

    # ==================== FEATURE FLAG CHECKING ====================

    def is_feature_enabled(self, flag_name: str, user_id: str = None, tenant_id: str = None, db: Session = None) -> bool:
        """Check if a feature flag is enabled for user/tenant"""
        try:
            # Check user-specific override first
            if user_id and db:
                user_override = db.query(FeatureFlagOverride).\
                    join(FeatureFlag).\
                    filter(
                        FeatureFlag.flag_name == flag_name,
                        FeatureFlagOverride.user_id == user_id
                    ).first()

                if user_override:
                    return user_override.override_value.lower() == 'true'

            # Check role-based override
            if user_id and db:
                user_roles = self._get_user_roles(user_id, db)
                for role_name in user_roles:
                    role = db.query(Role).filter(Role.role_name == role_name).first()
                    if role:
                        role_override = db.query(FeatureFlagOverride).\
                            join(FeatureFlag).\
                            filter(
                                FeatureFlag.flag_name == flag_name,
                                FeatureFlagOverride.role_id == role.role_id,
                                FeatureFlagOverride.tenant_id == tenant_id
                            ).first()

                        if role_override:
                            return role_override.override_value.lower() == 'true'

            # Check tenant-specific flag
            if tenant_id and db:
                tenant_flag = db.query(FeatureFlag).\
                    filter(
                        FeatureFlag.flag_name == flag_name,
                        FeatureFlag.tenant_id == tenant_id
                    ).first()

                if tenant_flag:
                    return tenant_flag.is_enabled

            # Check global flag
            if db:
                global_flag = db.query(FeatureFlag).\
                    filter(
                        FeatureFlag.flag_name == flag_name,
                        FeatureFlag.tenant_id.is_(None)
                    ).first()

                if global_flag:
                    return global_flag.is_enabled

            # Default to enabled if flag doesn't exist
            return True

        except Exception as e:
            get_auth_logger().error(f"Error checking feature flag {flag_name}: {e}")
            return True  # Default to enabled on error

    # ==================== DATA RETRIEVAL ====================

    def get_user_permissions(self, user_id: str, db: Session) -> List[str]:
        """Get all permissions for a user"""
        return self._get_user_permissions(user_id, db)

    def get_user_roles(self, user_id: str, db: Session) -> List[str]:
        """Get all roles for a user"""
        return self._get_user_roles(user_id, db)

    def get_all_roles(self, db: Session) -> List[Dict[str, Any]]:
        """Get all available roles"""
        try:
            roles = db.query(Role).all()
            return [{
                'role_id': str(r.role_id),
                'role_name': r.role_name,
                'description': r.role_description,
                'is_system_role': r.is_system_role
            } for r in roles]
        except Exception as e:
            get_auth_logger().error(f"Error getting all roles: {e}")
            return []

    def get_role_permissions(self, role_name: str, db: Session) -> List[str]:
        """Get all permissions for a specific role"""
        try:
            permissions = db.query(Permission).\
                join(RolePermission).\
                join(Role).\
                filter(Role.role_name == role_name).\
                all()

            return [p.permission_name for p in permissions]
        except Exception as e:
            get_auth_logger().error(f"Error getting permissions for role {role_name}: {e}")
            return []

    # ==================== ROLE MANAGEMENT ====================

    def assign_role_to_user(self, user_id: str, role_name: str, assigned_by: str, db: Session, tenant_id: str = None) -> bool:
        """Assign a role to a user"""
        try:
            # Get role
            role = db.query(Role).filter(Role.role_name == role_name).first()
            if not role:
                get_auth_logger().error(f"Role {role_name} not found")
                return False

            # Check if assignment already exists
            existing = db.query(UserRole).filter(
                UserRole.user_id == user_id,
                UserRole.role_id == role.role_id
            ).first()

            if existing:
                get_auth_logger().warning(f"User {user_id} already has role {role_name}")
                return True

            # Create assignment
            user_role = UserRole(
                user_id=user_id,
                role_id=role.role_id,
                assigned_by=assigned_by
            )
            db.add(user_role)
            db.commit()

            # Invalidate cache
            self.invalidate_user_cache(user_id)

            # Audit log
            self._audit_log(db, {
                'tenant_id': tenant_id,
                'user_id': assigned_by,
                'action': 'role_assigned',
                'target_user_id': user_id,
                'target_role_id': str(role.role_id),
                'details': {'assigned_role': role_name}
            })

            get_auth_logger().info(f"Assigned role {role_name} to user {user_id}")
            return True

        except Exception as e:
            get_auth_logger().error(f"Error assigning role {role_name} to user {user_id}: {e}")
            db.rollback()
            return False

    def remove_role_from_user(self, user_id: str, role_name: str, removed_by: str, db: Session, tenant_id: str = None) -> bool:
        """Remove a role from a user"""
        try:
            # Delete assignment
            role = db.query(Role).filter(Role.role_name == role_name).first()
            if not role:
                return False

            deleted = db.query(UserRole).filter(
                UserRole.user_id == user_id,
                UserRole.role_id == role.role_id
            ).delete()

            if deleted > 0:
                db.commit()
                self.invalidate_user_cache(user_id)

                # Audit log
                self._audit_log(db, {
                    'tenant_id': tenant_id,
                    'user_id': removed_by,
                    'action': 'role_removed',
                    'target_user_id': user_id,
                    'target_role_id': str(role.role_id),
                    'details': {'removed_role': role_name}
                })

                get_auth_logger().info(f"Removed role {role_name} from user {user_id}")
                return True
            else:
                get_auth_logger().warning(f"Role {role_name} not found for user {user_id}")
                return False

        except Exception as e:
            get_auth_logger().error(f"Error removing role {role_name} from user {user_id}: {e}")
            db.rollback()
            return False

    # ==================== FEATURE FLAG MANAGEMENT ====================

    def set_feature_flag(self, flag_name: str, enabled: bool, updated_by: str, tenant_id: str = None, db: Session = None) -> bool:
        """Enable/disable a feature flag"""
        try:
            # Find or create flag
            flag = db.query(FeatureFlag).filter(
                FeatureFlag.flag_name == flag_name,
                FeatureFlag.tenant_id == tenant_id
            ).first()

            if flag:
                flag.is_enabled = enabled
                flag.updated_by = updated_by
                flag.updated_at = datetime.utcnow()
            else:
                flag = FeatureFlag(
                    flag_name=flag_name,
                    is_enabled=enabled,
                    tenant_id=tenant_id,
                    created_by=updated_by,
                    updated_by=updated_by
                )
                db.add(flag)

            db.commit()

            # Audit log
            self._audit_log(db, {
                'tenant_id': tenant_id,
                'user_id': updated_by,
                'action': 'feature_flag_changed',
                'target_flag_id': str(flag.flag_id),
                'details': {'flag_name': flag_name, 'enabled': enabled}
            })

            return True

        except Exception as e:
            get_auth_logger().error(f"Error setting feature flag {flag_name}: {e}")
            db.rollback()
            return False

    # ==================== PRIVATE METHODS ====================

    def _get_user_permissions(self, user_id: str, db: Session) -> List[str]:
        """Get all permissions for a user from database with hierarchical inheritance"""
        cache_key = f"user_permissions:{user_id}"

        # Check cache first
        cached_permissions = self._get_cache(cache_key)
        if cached_permissions is not None:
            return cached_permissions

        try:
            # Get user's direct roles
            user_roles = self._get_user_roles(user_id, db)

            # Expand roles with inheritance
            all_roles = self._expand_roles_with_inheritance(user_roles)

            # Query permissions from the JSONB field in roles table
            if all_roles:
                from app.models.rbac import Role
                roles_data = db.query(Role).filter(Role.role_name.in_(all_roles)).all()

                permission_list = []
                for role in roles_data:
                    if role.permissions:
                        # permissions is a JSONB field containing a list of permission strings
                        if isinstance(role.permissions, list):
                            permission_list.extend(role.permissions)
                        elif isinstance(role.permissions, str):
                            # Handle comma-separated string if needed
                            permission_list.extend([p.strip() for p in role.permissions.split(',')])
            else:
                permission_list = []

            # Remove duplicates
            permission_list = list(set(permission_list))

            # Cache the result
            self._set_cache(cache_key, permission_list)

            return permission_list

        except Exception as e:
            get_auth_logger().error(f"Error getting permissions for user {user_id}: {e}")
            return []

    def _expand_roles_with_inheritance(self, user_roles: List[str]) -> List[str]:
        """Expand user roles with inherited roles"""
        all_roles = set(user_roles)

        # Add inherited roles for each user role
        for role in user_roles:
            if role in ROLE_INHERITANCE:
                inherited_roles = ROLE_INHERITANCE[role]
                all_roles.update(inherited_roles)

        return list(all_roles)

    def _get_user_roles(self, user_id: str, db: Session) -> List[str]:
        """Get all roles for a user from database"""
        cache_key = f"user_roles:{user_id}"

        # Check cache first
        cached_roles = self._get_cache(cache_key)
        if cached_roles is not None:
            return cached_roles

        try:
            # Query user roles from database
            roles = db.query(Role).\
                join(UserRole).\
                filter(UserRole.user_id == user_id).\
                all()

            role_list = [r.role_name for r in roles]

            # Cache the result
            self._set_cache(cache_key, role_list)

            return role_list

        except Exception as e:
            get_auth_logger().error(f"Error getting roles for user {user_id}: {e}")
            return []

    def _matches_wildcard(self, permission: str, user_permissions: List[str]) -> bool:
        """Check if permission matches any wildcard patterns"""
        for user_perm in user_permissions:
            if user_perm == "*":
                return True
            if user_perm.endswith(".*"):
                prefix = user_perm[:-2]  # Remove .*
                if permission.startswith(prefix + "."):
                    return True
        return False

    def _audit_log(self, db: Session, audit_data: Dict[str, Any]):
        """Log authorization actions"""
        try:
            # This would integrate with the audit service
            # For now, we'll log to the RBAC audit table
            audit_entry = {
                'tenant_id': audit_data.get('tenant_id'),
                'user_id': audit_data.get('user_id'),
                'action': audit_data.get('action'),
                'target_user_id': audit_data.get('target_user_id'),
                'target_role_id': audit_data.get('target_role_id'),
                'target_permission_id': audit_data.get('target_permission_id'),
                'target_flag_id': audit_data.get('target_flag_id'),
                'details': audit_data.get('details', {}),
                'success': True
            }

            # Insert into rbac_audit_log table
            db.execute(text("""
                INSERT INTO lic_schema.rbac_audit_log
                (tenant_id, user_id, action, target_user_id, target_role_id,
                 target_permission_id, target_flag_id, details, success)
                VALUES (:tenant_id, :user_id, :action, :target_user_id, :target_role_id,
                       :target_permission_id, :target_flag_id, :details, :success)
            """), audit_entry)

        except Exception as e:
            get_auth_logger().error(f"Error creating audit log: {e}")

    def _get_cache(self, key: str) -> Any:
        """Get value from cache (Redis or memory)"""
        try:
            if self._use_redis and self._redis_client:
                cached_data = self._redis_client.get(key)
                if cached_data:
                    return json.loads(cached_data)
            else:
                # Use in-memory cache
                if key in self._memory_cache:
                    data, timestamp = self._memory_cache[key]
                    if time.time() - timestamp < self._cache_ttl:
                        return data
        except Exception as e:
            get_auth_logger().warning(f"Cache read error for key {key}: {e}")

        return None

    def _set_cache(self, key: str, value: Any):
        """Set value in cache (Redis or memory)"""
        try:
            if self._use_redis and self._redis_client:
                self._redis_client.setex(key, self._cache_ttl, json.dumps(value))
            else:
                # Use in-memory cache
                self._memory_cache[key] = (value, time.time())
        except Exception as e:
            get_auth_logger().warning(f"Cache write error for key {key}: {e}")

    def _delete_cache(self, key: str):
        """Delete value from cache"""
        try:
            if self._use_redis and self._redis_client:
                self._redis_client.delete(key)
            else:
                self._memory_cache.pop(key, None)
        except Exception as e:
            get_auth_logger().warning(f"Cache delete error for key {key}: {e}")

    def invalidate_user_cache(self, user_id: str):
        """Invalidate cached permissions and roles for a user"""
        self._delete_cache(f"user_permissions:{user_id}")
        self._delete_cache(f"user_roles:{user_id}")

    def clear_all_cache(self):
        """Clear all cached authorization data"""
        try:
            if self._use_redis and self._redis_client:
                # Clear Redis cache with pattern (if supported)
                # For now, we'll just clear memory cache since Redis pattern delete is complex
                pass
            self._memory_cache.clear()
        except Exception as e:
            get_auth_logger().error(f"Error clearing all cache: {e}")

# Global authorization service instance - lazy loaded
_auth_service = None

def get_auth_service() -> AuthorizationService:
    """Get or create the authorization service instance"""
    global _auth_service
    if _auth_service is None:
        # Try to initialize with Redis if available
        try:
            import redis
            from app.core.config.settings import settings
            redis_client = redis.from_url(settings.redis_url)
            # Test connection
            redis_client.ping()
            _auth_service = AuthorizationService(redis_client)
            get_auth_logger().info("AuthorizationService initialized with Redis caching")
        except Exception as e:
            get_auth_logger().warning(f"Redis not available for authorization caching, using in-memory cache: {e}")
            _auth_service = AuthorizationService()
    return _auth_service

# For backward compatibility
auth_service = None  # Will be set by get_auth_service()


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
                get_auth_logger().warning(f"Error looking up agent_id for user {self.user_id}: {e}")
                self._agent_id = None
                return None
        
        self._agent_id = None
        return None

    def _get_permissions(self) -> List[str]:
        """Get user permissions from database"""
        if self._db:
            try:
                auth_svc = get_auth_service()
                return auth_svc.get_user_permissions(self.user_id, self._db)
            except Exception as e:
                get_auth_logger().error(f"Failed to get permissions from database: {e}")
                return []
        else:
            # Fallback to hardcoded permissions if no database connection
            get_auth_logger().warning(f"No database connection for user {self.user_id}, using fallback permissions")
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
        # First check JWT permissions (faster)
        if permission in self.permissions:
            return True

        # If JWT doesn't have it, check database if available
        if self._db:
            try:
                auth_svc = get_auth_service()
                return auth_svc.has_permission(self.user_id, permission, self._db)
            except Exception as e:
                get_auth_logger().error(f"Database permission check failed: {e}")
                return False

        return False  # No permission found

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
    get_auth_logger().info(
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
    get_auth_logger().info(
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
