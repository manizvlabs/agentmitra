"""
Tenant-Aware Base Service
Implements the base service class for tenant-aware operations from the multitenant architecture design
"""
from typing import Dict, Any, Optional, List
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy import create_engine, text
from abc import ABC, abstractmethod
import logging
from contextvars import ContextVar
from app.core.tenant_service import TenantService
from app.core.database import SessionLocal

logger = logging.getLogger(__name__)

# Context variable to store current tenant ID
current_tenant_id: ContextVar[Optional[str]] = ContextVar('current_tenant_id', default=None)


class TenantAwareService(ABC):
    """Base class for tenant-aware services with automatic tenant context switching"""

    def __init__(self, tenant_service: TenantService):
        self.tenant_service = tenant_service
        self._session_factory = None

    def execute_in_tenant_context(self, tenant_id: str, operation: callable, *args, **kwargs):
        """Execute operation within tenant context with automatic error handling"""
        try:
            # Validate tenant access and get context
            tenant_context = self.tenant_service.get_tenant_context(tenant_id)

            if tenant_context['status'] != 'active':
                raise ValueError(f"Tenant {tenant_id} is not active")

            # Set tenant context in context variable
            token = current_tenant_id.set(tenant_id)

            try:
                # Create tenant-specific session
                session = self._create_tenant_session(tenant_id)

                # Set tenant context in database session
                session.execute(text(f"SELECT lic_schema.set_tenant_context('{tenant_id}')"))

                # Execute operation
                result = operation(session, *args, **kwargs)

                session.commit()
                return result

            finally:
                # Reset context variable
                current_tenant_id.reset(token)

        except Exception as e:
            logger.error(f"Error in tenant {tenant_id} context: {e}")
            raise

    def validate_operation_permissions(self, tenant_id: str, user_id: str,
                                     operation: str, resource: str) -> bool:
        """Validate user permissions for operation within tenant context"""
        try:
            # Get user permissions for tenant
            user_tenants = self.tenant_service.get_user_tenants(user_id)
            user_tenant = next(
                (t for t in user_tenants if t['tenant_id'] == tenant_id),
                None
            )

            if not user_tenant:
                return False

            permissions = user_tenant.get('permissions', [])
            if not permissions:
                # Check role-based permissions
                role = user_tenant.get('role', '')
                permissions = self._get_role_permissions(role)

            # Check if operation is allowed
            required_permission = f"{operation}:{resource}"
            return required_permission in permissions

        except Exception as e:
            logger.error(f"Error validating permissions for user {user_id} in tenant {tenant_id}: {e}")
            return False

    def _get_role_permissions(self, role: str) -> List[str]:
        """Get default permissions for a role"""
        role_permissions = {
            'super_admin': ['*'],  # All permissions
            'insurance_provider_admin': [
                'users:read', 'users:create', 'users:update',
                'agents:read', 'agents:create', 'agents:update', 'agents:approve',
                'policies:read', 'policies:create', 'policies:update', 'policies:approve',
                'campaigns:read', 'campaigns:create', 'campaigns:update',
                'analytics:read', 'reports:generate'
            ],
            'regional_manager': [
                'agents:read', 'agents:update',
                'policies:read', 'policies:update', 'policies:approve',
                'campaigns:read', 'campaigns:create',
                'analytics:read', 'reports:generate'
            ],
            'senior_agent': [
                'agents:read', 'agents:update',
                'policies:read', 'policies:create', 'policies:update',
                'customers:read', 'customers:create', 'customers:update',
                'campaigns:read', 'campaigns:create',
                'analytics:read'
            ],
            'junior_agent': [
                'policies:read', 'policies:create',
                'customers:read', 'customers:create', 'customers:update',
                'campaigns:read'
            ],
            'support_staff': [
                'customers:read', 'customers:update',
                'policies:read',
                'campaigns:read'
            ]
        }

        return role_permissions.get(role, [])

    def _create_tenant_session(self, tenant_id: str) -> Session:
        """Create database session for specific tenant with isolation"""
        if not self._session_factory:
            # Create engine with tenant-specific connection pooling
            from app.core.database import get_db_config
            engine_config = get_db_config()

            # Add tenant-specific connection settings
            engine_config['connect_args']['options'] = f"-c search_path=lic_schema,public -c app.current_tenant_id={tenant_id}"

            engine = create_engine(
                self.tenant_service.database_url,
                **engine_config
            )
            self._session_factory = sessionmaker(bind=engine)

        return self._session_factory()

    def check_tenant_limits(self, tenant_id: str, operation: str) -> bool:
        """Check if operation is within tenant limits"""
        return self.tenant_service.check_tenant_limits(tenant_id, operation)

    def audit_log(self, tenant_id: str, user_id: str, action: str,
                  resource_type: str, resource_id: str, details: Dict[str, Any],
                  ip_address: str = None, user_agent: str = None) -> None:
        """Log audit entry for tenant operation"""
        try:
            # This would integrate with the audit service
            # For now, we'll implement basic logging
            audit_entry = {
                'tenant_id': tenant_id,
                'user_id': user_id,
                'action': action,
                'resource_type': resource_type,
                'resource_id': resource_id,
                'details': details,
                'ip_address': ip_address,
                'user_agent': user_agent,
                'timestamp': datetime.utcnow().isoformat(),
            }

            logger.info(f"AUDIT: {audit_entry}")

            # TODO: Implement actual audit logging to database
            # self._store_audit_entry(tenant_id, audit_entry)

        except Exception as e:
            logger.error(f"Failed to log audit entry: {e}")

    def get_current_tenant_id(self) -> Optional[str]:
        """Get current tenant ID from context"""
        return current_tenant_id.get()

    def validate_tenant_resource_access(self, tenant_id: str, resource_type: str, resource_id: str, user_id: str) -> bool:
        """Validate that user has access to specific tenant resource"""
        # This is a basic implementation - in production, you'd check ownership/assignment
        return self.validate_operation_permissions(tenant_id, user_id, 'read', resource_type)


class AgentService(TenantAwareService):
    """Agent management service with tenant isolation"""

    def get_agent_profile(self, tenant_id: str, agent_id: str, user_id: str = None) -> Dict:
        """Get agent profile for specific tenant"""
        if user_id and not self.validate_tenant_resource_access(tenant_id, 'agent', agent_id, user_id):
            raise PermissionError("Access denied to agent profile")

        def operation(session: Session):
            from app.models.agent import Agent

            agent = session.query(Agent).filter(
                Agent.agent_id == agent_id
            ).first()

            if not agent:
                raise ValueError(f"Agent {agent_id} not found")

            return {
                'agent_id': str(agent.agent_id),
                'tenant_id': str(agent.tenant_id),
                'user_id': str(agent.user_id),
                'agent_code': agent.agent_code,
                'business_name': agent.business_name,
                'total_policies_sold': agent.total_policies_sold,
                'total_premium_collected': float(agent.total_premium_collected or 0),
                'active_policyholders': agent.active_policyholders,
                'status': agent.status,
                'verification_status': agent.verification_status,
            }

        return self.execute_in_tenant_context(tenant_id, operation)

    def update_agent_metrics(self, tenant_id: str, agent_id: str) -> None:
        """Update agent performance metrics"""
        def operation(session: Session):
            from app.models.agent import Agent
            from app.models.policy import InsurancePolicy, PremiumPayment
            from sqlalchemy import func
            from datetime import datetime, timedelta

            # Recalculate metrics from policies and payments
            agent_metrics = self._calculate_agent_metrics(session, agent_id)

            # Update agent profile
            session.query(Agent).filter(
                Agent.agent_id == agent_id
            ).update(agent_metrics)

        self.execute_in_tenant_context(tenant_id, operation)

    def _calculate_agent_metrics(self, session: Session, agent_id: str) -> Dict:
        """Calculate agent performance metrics"""
        from app.models.policy import InsurancePolicy, PremiumPayment
        from sqlalchemy import func
        from datetime import datetime, timedelta

        # Active customers count
        active_customers = session.query(func.count(func.distinct(InsurancePolicy.policyholder_id))).filter(
            InsurancePolicy.agent_id == agent_id,
            InsurancePolicy.status.in_(['active', 'approved'])
        ).scalar() or 0

        # Monthly revenue (last 30 days)
        thirty_days_ago = datetime.now() - timedelta(days=30)
        monthly_revenue = session.query(func.sum(PremiumPayment.amount)).join(
            InsurancePolicy, PremiumPayment.policy_id == InsurancePolicy.policy_id
        ).filter(
            InsurancePolicy.agent_id == agent_id,
            PremiumPayment.payment_date >= thirty_days_ago,
            PremiumPayment.status == 'completed'
        ).scalar() or 0

        # Total policies sold
        total_policies = session.query(func.count(InsurancePolicy.policy_id)).filter(
            InsurancePolicy.agent_id == agent_id,
            InsurancePolicy.status.in_(['active', 'approved'])
        ).scalar() or 0

        return {
            'total_policies_sold': total_policies,
            'total_premium_collected': monthly_revenue,
            'active_policyholders': active_customers,
            'updated_at': datetime.now(),
        }
