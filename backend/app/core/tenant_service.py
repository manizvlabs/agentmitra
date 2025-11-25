"""
Tenant Service - Multi-tenant context management and validation
Implements the tenant service layer from the multitenant architecture design
"""
from typing import Dict, Optional, List
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, and_, text
from sqlalchemy.pool import Pool
import redis
import json
import logging
from datetime import datetime, timedelta
from app.core.database import SessionLocal
from app.models.shared import Tenant, TenantConfig, TenantUser
from app.models.user import User

logger = logging.getLogger(__name__)


class TenantService:
    """Service for managing tenant context and data isolation"""

    def __init__(self, database_url: str, redis_url: str):
        self.database_url = database_url
        self.redis_client = redis.from_url(redis_url)
        self._tenant_cache = {}
        self._cache_ttl = 300  # 5 minutes

    def get_tenant_context(self, tenant_id: str) -> Dict:
        """Get tenant configuration and context"""
        # Check cache first
        if tenant_id in self._tenant_cache:
            cached_data, timestamp = self._tenant_cache[tenant_id]
            if datetime.now().timestamp() - timestamp < self._cache_ttl:
                return cached_data

        # Load from database
        with SessionLocal() as session:
            tenant = session.query(Tenant).filter(
                Tenant.tenant_id == tenant_id
            ).first()

            if not tenant:
                raise ValueError(f"Tenant {tenant_id} not found")

            # Get tenant configurations
            configs = session.query(TenantConfig).filter(
                TenantConfig.tenant_id == tenant_id
            ).all()

            config_dict = {config.config_key: config.config_value for config in configs}

            context = {
                'tenant_id': str(tenant.tenant_id),
                'tenant_name': tenant.tenant_name,
                'tenant_type': tenant.tenant_type,
                'tenant_code': tenant.tenant_code,
                'status': tenant.status,
                'subscription_plan': tenant.subscription_plan,
                'trial_end_date': tenant.trial_end_date.isoformat() if tenant.trial_end_date else None,
                'max_users': tenant.max_users,
                'storage_limit_gb': tenant.storage_limit_gb,
                'api_rate_limit': tenant.api_rate_limit,
                'contact_email': tenant.contact_email,
                'contact_phone': tenant.contact_phone,
                'business_address': tenant.business_address,
                'branding_settings': tenant.branding_settings,
                'theme_settings': tenant.theme_settings,
                'compliance_status': tenant.compliance_status,
                'regulatory_approvals': tenant.regulatory_approvals,
                'metadata': tenant.metadata,
                'config': config_dict,
                'limits': {
                    'users': tenant.max_users,
                    'storage_gb': tenant.storage_limit_gb,
                    'api_calls_per_hour': tenant.api_rate_limit,
                },
                'features': self._get_tenant_features(tenant, config_dict),
            }

            # Cache for 5 minutes
            self._tenant_cache[tenant_id] = (context, datetime.now().timestamp())
            self.redis_client.setex(
                f"tenant:{tenant_id}",
                self._cache_ttl,
                json.dumps(context)
            )

            return context

    def validate_tenant_access(self, user_id: str, tenant_id: str) -> bool:
        """Validate if user has access to the tenant"""
        with SessionLocal() as session:
            # Check if user is assigned to tenant
            user_tenant = session.query(TenantUser).filter(
                and_(
                    TenantUser.user_id == user_id,
                    TenantUser.tenant_id == tenant_id,
                    TenantUser.status == 'active'
                )
            ).first()

            return user_tenant is not None

    def get_user_tenants(self, user_id: str) -> List[Dict]:
        """Get all tenants accessible by a user"""
        with SessionLocal() as session:
            user_tenants = session.query(TenantUser).filter(
                and_(
                    TenantUser.user_id == user_id,
                    TenantUser.status == 'active'
                )
            ).all()

            tenants = []
            for ut in user_tenants:
                tenant_context = self.get_tenant_context(str(ut.tenant_id))
                tenants.append({
                    'tenant_id': str(ut.tenant_id),
                    'tenant_name': tenant_context['tenant_name'],
                    'tenant_code': tenant_context['tenant_code'],
                    'role': ut.role,
                    'permissions': ut.permissions,
                    'is_primary': ut.is_primary,
                    'joined_at': ut.joined_at.isoformat(),
                })

            return tenants

    def switch_tenant_context(self, tenant_id: str) -> None:
        """Switch database context to specific tenant"""
        # Set tenant context in database session
        with SessionLocal() as session:
            session.execute(text(f"SELECT lic_schema.set_tenant_context('{tenant_id}')"))
            session.commit()

    def check_tenant_limits(self, tenant_id: str, resource: str, amount: int = 1) -> bool:
        """Check if tenant operation is within limits"""
        try:
            tenant_context = self.get_tenant_context(tenant_id)
            limits = tenant_context.get('limits', {})

            if resource not in limits:
                return True  # No limit set

            current_usage = self._get_current_usage(tenant_id, resource)
            limit = limits[resource]

            return (current_usage + amount) <= limit
        except Exception as e:
            logger.error(f"Error checking tenant limits for {tenant_id}: {e}")
            return False  # Fail safe - deny if can't check

    def _get_current_usage(self, tenant_id: str, resource: str) -> int:
        """Get current usage for a resource (cached)"""
        cache_key = f"usage:{tenant_id}:{resource}"
        usage = self.redis_client.get(cache_key)

        if usage:
            return int(usage)

        # Calculate from database (expensive, so cached)
        usage = self._calculate_usage_from_db(tenant_id, resource)
        self.redis_client.setex(cache_key, 3600, usage)  # Cache for 1 hour

        return usage

    def _calculate_usage_from_db(self, tenant_id: str, resource: str) -> int:
        """Calculate resource usage from database"""
        with SessionLocal() as session:
            if resource == 'users':
                return session.query(TenantUser).filter(
                    and_(
                        TenantUser.tenant_id == tenant_id,
                        TenantUser.status == 'active'
                    )
                ).count()
            elif resource == 'agents':
                from app.models.agent import Agent
                return session.query(Agent).filter(
                    Agent.tenant_id == tenant_id
                ).count()
            elif resource == 'policies':
                from app.models.policy import InsurancePolicy
                return session.query(InsurancePolicy).filter(
                    InsurancePolicy.tenant_id == tenant_id
                ).count()
            elif resource == 'customers':
                from app.models.policy import Policyholder
                return session.query(Policyholder).filter(
                    Policyholder.tenant_id == tenant_id
                ).count()

        return 0

    def _get_tenant_features(self, tenant: Tenant, config: Dict) -> Dict:
        """Get tenant feature flags and capabilities"""
        # Base features based on subscription plan
        base_features = {
            'basic': ['user_management', 'policy_management', 'basic_reporting'],
            'professional': ['user_management', 'policy_management', 'advanced_reporting', 'campaigns', 'api_access'],
            'enterprise': ['user_management', 'policy_management', 'advanced_reporting', 'campaigns', 'api_access', 'white_label', 'custom_integrations']
        }

        plan = tenant.subscription_plan or 'basic'
        features = base_features.get(plan, base_features['basic'])

        # Add custom features from config
        custom_features = config.get('enabled_features', [])
        if isinstance(custom_features, list):
            features.extend(custom_features)

        return {
            'enabled_features': list(set(features)),  # Remove duplicates
            'subscription_plan': plan,
            'custom_features': custom_features
        }

    def invalidate_tenant_cache(self, tenant_id: str) -> None:
        """Invalidate cached data for a tenant"""
        # Clear local cache
        self._tenant_cache.pop(tenant_id, None)

        # Clear Redis cache
        pattern = f"tenant:{tenant_id}*"
        keys = self.redis_client.keys(pattern)
        if keys:
            self.redis_client.delete(*keys)

    def get_tenant_stats(self, tenant_id: str) -> Dict:
        """Get comprehensive tenant statistics"""
        with SessionLocal() as session:
            from app.models.agent import Agent
            from app.models.policy import InsurancePolicy, Policyholder, PremiumPayment

            stats = {
                'users': session.query(TenantUser).filter(TenantUser.tenant_id == tenant_id).count(),
                'agents': session.query(Agent).filter(Agent.tenant_id == tenant_id).count(),
                'customers': session.query(Policyholder).filter(Policyholder.tenant_id == tenant_id).count(),
                'policies': session.query(InsurancePolicy).filter(InsurancePolicy.tenant_id == tenant_id).count(),
                'payments': session.query(PremiumPayment).filter(PremiumPayment.tenant_id == tenant_id).count(),
            }

            # Calculate totals
            total_premium = session.query(PremiumPayment).filter(
                and_(
                    PremiumPayment.tenant_id == tenant_id,
                    PremiumPayment.status == 'completed'
                )
            ).with_entities(PremiumPayment.amount).all()

            stats['total_premium_collected'] = sum(p.amount for p in total_premium if p.amount)

            return stats

    def create_tenant_user(self, tenant_id: str, user_id: str, role: str, permissions: Dict = None) -> TenantUser:
        """Create a tenant-user relationship"""
        with SessionLocal() as session:
            tenant_user = TenantUser(
                tenant_id=tenant_id,
                user_id=user_id,
                role=role,
                permissions=permissions or {}
            )
            session.add(tenant_user)
            session.commit()
            session.refresh(tenant_user)

            # Invalidate cache
            self.invalidate_tenant_cache(tenant_id)

            return tenant_user

    def update_tenant_config(self, tenant_id: str, config_key: str, config_value: any, config_type: str = 'string') -> None:
        """Update tenant configuration"""
        with SessionLocal() as session:
            config = session.query(TenantConfig).filter(
                and_(
                    TenantConfig.tenant_id == tenant_id,
                    TenantConfig.config_key == config_key
                )
            ).first()

            if config:
                config.config_value = config_value
                config.config_type = config_type
                config.updated_at = datetime.utcnow()
            else:
                config = TenantConfig(
                    tenant_id=tenant_id,
                    config_key=config_key,
                    config_value=config_value,
                    config_type=config_type
                )
                session.add(config)

            session.commit()

            # Invalidate cache
            self.invalidate_tenant_cache(tenant_id)
