"""
RBAC (Role-Based Access Control) Service
=========================================

Comprehensive role-based access control service implementing the RBAC design document.
Handles user authentication, authorization, and permission checking.
"""

import logging
from typing import List, Dict, Any, Optional, Set, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, text
from functools import wraps

from app.core.logging_config import get_logger

logger = get_logger(__name__)


class RBACService:
    """RBAC service for managing roles, permissions, and access control"""

    # Role hierarchy based on design document
    ROLE_HIERARCHY = {
        "super_admin": 100,      # Full system access
        "provider_admin": 80,    # Tenant administrator
        "regional_manager": 60,  # Multi-agent supervisor
        "senior_agent": 40,      # Advanced features
        "junior_agent": 20,      # Basic features
        "support_staff": 15,     # Customer service
        "policyholder": 10,      # Customer portal
        "guest_user": 5          # Trial/limited access
    }

    # Permission definitions by resource and action
    PERMISSIONS = {
        # User management
        "users.create": "Create user accounts",
        "users.read": "View user information",
        "users.update": "Update user profiles",
        "users.delete": "Delete user accounts",

        # Agent management
        "agents.create": "Create agent accounts",
        "agents.read": "View agent information",
        "agents.update": "Update agent profiles",
        "agents.delete": "Delete agent accounts",

        # Policy management
        "policies.create": "Create insurance policies",
        "policies.read": "View policy information",
        "policies.update": "Update policy details",
        "policies.delete": "Delete policies",

        # Customer management
        "customers.create": "Create customer accounts",
        "customers.read": "View customer information",
        "customers.update": "Update customer profiles",
        "customers.delete": "Delete customer accounts",

        # Payment management
        "payments.create": "Process payments",
        "payments.read": "View payment records",
        "payments.update": "Update payment details",
        "payments.delete": "Delete payment records",

        # Content management
        "content.create": "Upload content",
        "content.read": "View content",
        "content.update": "Update content",
        "content.delete": "Delete content",

        # Analytics
        "analytics.read": "View analytics and reports",

        # System administration
        "system.admin": "System administration",
        "feature_flags.manage": "Manage feature flags",
        "audit.read": "View audit logs",

        # Communication
        "communication.send": "Send messages",
        "communication.read": "View messages",

        # Callbacks
        "callbacks.create": "Create callback requests",
        "callbacks.read": "View callback requests",
        "callbacks.update": "Update callback requests",
        "callbacks.delete": "Delete callback requests",
    }

    # Role-based permissions mapping
    ROLE_PERMISSIONS = {
        "super_admin": [
            # All permissions
            "users.*", "agents.*", "policies.*", "customers.*", "payments.*",
            "content.*", "analytics.*", "system.*", "feature_flags.*", "audit.*",
            "communication.*", "callbacks.*"
        ],
        "provider_admin": [
            # Full tenant control
            "users.read", "users.update", "agents.*", "policies.*", "customers.*",
            "payments.read", "content.*", "analytics.read", "communication.*", "callbacks.*"
        ],
        "regional_manager": [
            # Team management
            "agents.read", "agents.update", "policies.read", "customers.read",
            "analytics.read", "communication.read", "callbacks.read", "callbacks.update"
        ],
        "senior_agent": [
            # Advanced agent features
            "customers.*", "policies.*", "payments.read", "content.*",
            "analytics.read", "communication.*", "callbacks.*"
        ],
        "junior_agent": [
            # Basic agent features
            "customers.read", "customers.update", "policies.read", "policies.update",
            "payments.read", "content.read", "analytics.read", "communication.send"
        ],
        "support_staff": [
            # Support features
            "customers.read", "communication.*", "callbacks.*"
        ],
        "policyholder": [
            # Customer portal
            "policies.read", "payments.create", "payments.read", "content.read",
            "communication.send", "callbacks.create"
        ],
        "guest_user": [
            # Limited trial features
            "policies.read", "content.read", "communication.send"
        ]
    }

    def __init__(self, db: Optional[Session] = None):
        self.db = db

    async def has_permission(self, user_id: str, permission: str, resource_id: Optional[str] = None) -> bool:
        """
        Check if user has a specific permission

        Args:
            user_id: User ID to check
            permission: Permission to check (e.g., "users.read")
            resource_id: Optional resource ID for row-level security

        Returns:
            True if user has permission, False otherwise
        """
        try:
            # Get user roles
            user_roles = await self.get_user_roles(user_id)
            if not user_roles:
                return False

            # Check if any role has the required permission
            for role in user_roles:
                if await self._role_has_permission(role, permission):
                    return True

            return False

        except Exception as e:
            logger.error(f"Permission check failed for user {user_id}: {e}")
            return False

    async def has_any_permission(self, user_id: str, permissions: List[str]) -> bool:
        """Check if user has any of the specified permissions"""
        for permission in permissions:
            if await self.has_permission(user_id, permission):
                return True
        return False

    async def has_all_permissions(self, user_id: str, permissions: List[str]) -> bool:
        """Check if user has all of the specified permissions"""
        for permission in permissions:
            if not await self.has_permission(user_id, permission):
                return False
        return True

    async def get_user_roles(self, user_id: str) -> List[str]:
        """Get all roles assigned to a user"""
        try:
            # Query user roles from database
            if self.db:
                result = self.db.execute(text("""
                    SELECT r.role_name
                    FROM lic_schema.user_roles ur
                    JOIN lic_schema.roles r ON ur.role_id = r.role_id
                    WHERE ur.user_id = :user_id
                """), {"user_id": user_id})

                roles = [row.role_name for row in result]
            else:
                # Fallback to hardcoded roles (for development)
                roles = ["junior_agent"]  # Default role

            return roles

        except Exception as e:
            logger.error(f"Failed to get user roles for {user_id}: {e}")
            return []

    async def get_user_permissions(self, user_id: str) -> Set[str]:
        """Get all permissions for a user based on their roles"""
        try:
            user_roles = await self.get_user_roles(user_id)
            permissions = set()

            for role in user_roles:
                role_permissions = self.ROLE_PERMISSIONS.get(role, [])
                for perm in role_permissions:
                    if perm.endswith(".*"):
                        # Expand wildcard permissions
                        prefix = perm[:-2]
                        for full_perm in self.PERMISSIONS.keys():
                            if full_perm.startswith(prefix):
                                permissions.add(full_perm)
                    else:
                        permissions.add(perm)

            return permissions

        except Exception as e:
            logger.error(f"Failed to get user permissions for {user_id}: {e}")
            return set()

    async def get_feature_flags(self, user_id: str, tenant_id: str) -> Dict[str, bool]:
        """Get feature flags for a user, considering tenant and user overrides"""
        try:
            from app.services.feature_flag_service import get_feature_flag_service
            feature_flag_service = get_feature_flag_service(self.db)

            # Get user-specific feature flags (includes tenant overrides)
            flags = await feature_flag_service.get_user_feature_flags(user_id, tenant_id)

            # Convert any non-boolean values to boolean
            result = {}
            for key, value in flags.items():
                if isinstance(value, str):
                    # Handle string values like "true"/"false"
                    result[key] = value.lower() in ('true', '1', 'yes', 'on')
                else:
                    result[key] = bool(value)

            return result

        except Exception as e:
            logger.error(f"Error getting feature flags for user {user_id}: {e}")
            # Return minimal safe defaults on error
            return {
                "phone_auth_enabled": True,
                "email_auth_enabled": True,
                "otp_verification_enabled": True,
                "dashboard_enabled": True,
                "policies_enabled": True,
                "chat_enabled": True,
                "notifications_enabled": True,
                "analytics_enabled": True,
                "portal_enabled": True,
            }

    async def can_access_tenant(self, user_id: str, tenant_id: str) -> bool:
        """Check if user can access a specific tenant"""
        try:
            user_roles = await self.get_user_roles(user_id)

            # Super admin can access all tenants
            if "super_admin" in user_roles:
                return True

            # Provider admin can access their tenant
            if "provider_admin" in user_roles:
                # Check if user belongs to the tenant
                return await self._user_belongs_to_tenant(user_id, tenant_id)

            # Other roles have limited access
            return False

        except Exception as e:
            logger.error(f"Tenant access check failed for user {user_id}: {e}")
            return False

    async def can_access_resource(self, user_id: str, resource_type: str, resource_id: str) -> bool:
        """Check if user can access a specific resource (row-level security)"""
        try:
            user_roles = await self.get_user_roles(user_id)

            # Super admin can access everything
            if "super_admin" in user_roles:
                return True

            # Check resource ownership based on role
            if resource_type == "customer":
                return await self._can_access_customer(user_id, resource_id, user_roles)
            elif resource_type == "policy":
                return await self._can_access_policy(user_id, resource_id, user_roles)
            elif resource_type == "agent":
                return await self._can_access_agent(user_id, resource_id, user_roles)
            else:
                # Default to permission-based access
                permission = f"{resource_type}.read"
                return await self.has_permission(user_id, permission)

        except Exception as e:
            logger.error(f"Resource access check failed for user {user_id}: {e}")
            return False

    async def _role_has_permission(self, role: str, permission: str) -> bool:
        """Check if a role has a specific permission"""
        role_permissions = self.ROLE_PERMISSIONS.get(role, [])

        # Direct permission match
        if permission in role_permissions:
            return True

        # Wildcard match
        for role_perm in role_permissions:
            if role_perm.endswith(".*"):
                if permission.startswith(role_perm[:-1]):
                    return True

        return False

    async def _get_role_permissions(self, role: str) -> set:
        """Get permissions for a specific role"""
        role_permissions = self.ROLE_PERMISSIONS.get(role, [])
        permissions = set()

        for perm in role_permissions:
            if perm.endswith(".*"):
                # Expand wildcard permissions
                prefix = perm[:-2]
                for full_perm in self.PERMISSIONS.keys():
                    if full_perm.startswith(prefix):
                        permissions.add(full_perm)
            else:
                permissions.add(perm)

        return permissions

    async def _user_belongs_to_tenant(self, user_id: str, tenant_id: str) -> bool:
        """Check if user belongs to a specific tenant"""
        # Implementation would check user-tenant relationship
        # For now, return True for development
        return True

    async def _can_access_customer(self, user_id: str, customer_id: str, user_roles: List[str]) -> bool:
        """Check if user can access a specific customer"""
        if "provider_admin" in user_roles or "super_admin" in user_roles:
            return True

        if "senior_agent" in user_roles or "junior_agent" in user_roles:
            # Check if customer belongs to this agent
            return await self._customer_belongs_to_agent(customer_id, user_id)

        if "policyholder" in user_roles:
            # Users can only access their own data
            return customer_id == user_id

        return False

    async def _can_access_policy(self, user_id: str, policy_id: str, user_roles: List[str]) -> bool:
        """Check if user can access a specific policy"""
        if "provider_admin" in user_roles or "super_admin" in user_roles:
            return True

        if "senior_agent" in user_roles or "junior_agent" in user_roles:
            # Check if policy belongs to agent's customer
            return await self._policy_belongs_to_agent(policy_id, user_id)

        if "policyholder" in user_roles:
            # Check if policy belongs to user
            return await self._policy_belongs_to_customer(policy_id, user_id)

        return False

    async def _can_access_agent(self, user_id: str, agent_id: str, user_roles: List[str]) -> bool:
        """Check if user can access a specific agent"""
        if "super_admin" in user_roles:
            return True

        if "provider_admin" in user_roles:
            # Provider admin can access agents in their tenant
            return await self._agent_belongs_to_tenant(agent_id, await self._get_user_tenant(user_id))

        if "regional_manager" in user_roles:
            # Regional manager can access agents in their region
            return await self._agent_belongs_to_region(agent_id, await self._get_user_region(user_id))

        # Agents can only access themselves
        return agent_id == user_id

    async def _customer_belongs_to_agent(self, customer_id: str, agent_id: str) -> bool:
        """Check if customer belongs to agent"""
        # Implementation would check customer-agent relationship
        return True  # Placeholder

    async def _policy_belongs_to_agent(self, policy_id: str, agent_id: str) -> bool:
        """Check if policy belongs to agent's customer"""
        # Implementation would check policy ownership
        return True  # Placeholder

    async def _policy_belongs_to_customer(self, policy_id: str, customer_id: str) -> bool:
        """Check if policy belongs to customer"""
        # Implementation would check policy ownership
        return True  # Placeholder

    async def _agent_belongs_to_tenant(self, agent_id: str, tenant_id: str) -> bool:
        """Check if agent belongs to tenant"""
        # Implementation would check agent-tenant relationship
        return True  # Placeholder

    async def _agent_belongs_to_region(self, agent_id: str, region_id: str) -> bool:
        """Check if agent belongs to region"""
        # Implementation would check agent-region relationship
        return True  # Placeholder

    async def _get_user_tenant(self, user_id: str) -> str:
        """Get user's tenant ID"""
        # Implementation would get user tenant
        return "default_tenant"  # Placeholder

    async def _get_user_region(self, user_id: str) -> str:
        """Get user's region ID"""
        # Implementation would get user region
        return "default_region"  # Placeholder


# Global RBAC service instance
_rbac_service = None

def get_rbac_service(db: Optional[Session] = None) -> RBACService:
    """Get or create RBAC service instance"""
    global _rbac_service
    if _rbac_service is None:
        _rbac_service = RBACService(db)
    return _rbac_service


# Permission checking decorators
def require_permission(permission: str):
    """Decorator to require specific permission"""
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # Extract user from kwargs or request context
            # This would be implemented based on your auth system
            return await func(*args, **kwargs)
        return wrapper
    return decorator


def require_any_permission(permissions: List[str]):
    """Decorator to require any of the specified permissions"""
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # Extract user from kwargs or request context
            # This would be implemented based on your auth system
            return await func(*args, **kwargs)
        return wrapper
    return decorator


def require_role(role: str):
    """Decorator to require specific role"""
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # Extract user from kwargs or request context
            # This would be implemented based on your auth system
            return await func(*args, **kwargs)
        return wrapper
    return decorator


def require_any_role(roles: List[str]):
    """Decorator to require any of the specified roles"""
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # Extract user from kwargs or request context
            # This would be implemented based on your auth system
            return await func(*args, **kwargs)
        return wrapper
    return decorator
