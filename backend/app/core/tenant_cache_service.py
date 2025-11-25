"""
Tenant-Aware Caching Service
Implements multi-tenant caching with Redis for performance optimization
"""
from typing import Any, Optional, Dict, List
import redis
import json
from datetime import datetime, timedelta
import logging
from app.core.tenant_service import TenantService

logger = logging.getLogger(__name__)


class MultiTenantCacheService:
    """Multi-tenant caching service with tenant isolation"""

    def __init__(self, redis_url: str, default_ttl: int = 3600):
        self.redis_client = redis.from_url(redis_url)
        self.default_ttl = default_ttl
        self.tenant_service = None  # Will be injected

    def set_tenant_service(self, tenant_service: TenantService):
        """Set tenant service for validation"""
        self.tenant_service = tenant_service

    def get_tenant_cache(self, tenant_id: str, key: str) -> Optional[Any]:
        """Get cached value for a tenant"""
        cache_key = f"tenant:{tenant_id}:{key}"
        try:
            cached_value = self.redis_client.get(cache_key)
            if cached_value:
                return json.loads(cached_value)
        except Exception as e:
            logger.error(f"Error retrieving cache for tenant {tenant_id}, key {key}: {e}")
        return None

    def set_tenant_cache(self, tenant_id: str, key: str, value: Any, ttl: Optional[int] = None) -> None:
        """Set cached value for a tenant"""
        cache_key = f"tenant:{tenant_id}:{key}"
        try:
            serialized_value = json.dumps(value, default=str)
            cache_ttl = ttl or self.default_ttl
            self.redis_client.setex(cache_key, cache_ttl, serialized_value)
        except Exception as e:
            logger.error(f"Error setting cache for tenant {tenant_id}, key {key}: {e}")

    def delete_tenant_cache(self, tenant_id: str, key: str) -> None:
        """Delete cached value for a tenant"""
        cache_key = f"tenant:{tenant_id}:{key}"
        try:
            self.redis_client.delete(cache_key)
        except Exception as e:
            logger.error(f"Error deleting cache for tenant {tenant_id}, key {key}: {e}")

    def clear_tenant_cache(self, tenant_id: str) -> None:
        """Clear all cached values for a tenant"""
        pattern = f"tenant:{tenant_id}:*"
        try:
            keys = self.redis_client.keys(pattern)
            if keys:
                self.redis_client.delete(*keys)
                logger.info(f"Cleared {len(keys)} cache entries for tenant {tenant_id}")
        except Exception as e:
            logger.error(f"Error clearing cache for tenant {tenant_id}: {e}")

    def get_tenant_cache_info(self, tenant_id: str) -> Dict[str, Any]:
        """Get cache usage information for a tenant"""
        pattern = f"tenant:{tenant_id}:*"
        try:
            keys = self.redis_client.keys(pattern)
            cache_info = {
                'total_keys': len(keys),
                'keys': [],
            }

            # Limit to first 10 keys for performance
            for key in keys[:10]:
                try:
                    ttl = self.redis_client.ttl(key)
                    cache_info['keys'].append({
                        'key': key.decode('utf-8'),
                        'ttl': ttl,
                    })
                except:
                    continue

            return cache_info
        except Exception as e:
            logger.error(f"Error getting cache info for tenant {tenant_id}: {e}")
            return {'total_keys': 0, 'keys': []}

    def warm_tenant_cache(self, tenant_id: str) -> None:
        """Warm up frequently accessed data for a tenant"""
        try:
            # This would pre-load commonly accessed data
            # Implementation depends on specific tenant data patterns
            logger.info(f"Warming cache for tenant {tenant_id}")
            # TODO: Implement cache warming logic based on tenant usage patterns
        except Exception as e:
            logger.error(f"Error warming cache for tenant {tenant_id}: {e}")

    def invalidate_tenant_data(self, tenant_id: str, data_type: str, data_id: str = None) -> None:
        """Invalidate specific data type for a tenant"""
        try:
            if data_type == 'agent' and data_id:
                # Clear agent-specific cache
                self.delete_tenant_cache(tenant_id, f"agent:{data_id}")
                self.delete_tenant_cache(tenant_id, f"agent_dashboard:{data_id}")
                self.delete_tenant_cache(tenant_id, f"agent_metrics:{data_id}")

            elif data_type == 'customer' and data_id:
                # Clear customer-specific cache
                self.delete_tenant_cache(tenant_id, f"customer:{data_id}")
                # Clear any agent customer lists that might contain this customer
                self._clear_pattern(tenant_id, f"customer_list:*")

            elif data_type == 'policy' and data_id:
                # Clear policy-specific cache
                self.delete_tenant_cache(tenant_id, f"policy:{data_id}")

            elif data_type == 'campaign' and data_id:
                # Clear campaign-specific cache
                self.delete_tenant_cache(tenant_id, f"campaign:{data_id}")
                self.delete_tenant_cache(tenant_id, f"campaign_analytics:{data_id}")

            elif data_type == 'all_agents':
                self._clear_pattern(tenant_id, "agent:*")

            elif data_type == 'all_customers':
                self._clear_pattern(tenant_id, "customer:*")

            elif data_type == 'all_policies':
                self._clear_pattern(tenant_id, "policy:*")

            logger.info(f"Invalidated {data_type} cache for tenant {tenant_id}")

        except Exception as e:
            logger.error(f"Error invalidating cache for tenant {tenant_id}, type {data_type}: {e}")

    def _clear_pattern(self, tenant_id: str, pattern: str) -> None:
        """Clear all keys matching a pattern for a tenant"""
        try:
            full_pattern = f"tenant:{tenant_id}:{pattern}"
            keys = self.redis_client.keys(full_pattern)
            if keys:
                self.redis_client.delete(*keys)
        except Exception as e:
            logger.error(f"Error clearing pattern {pattern} for tenant {tenant_id}: {e}")

    def get_cache_performance_metrics(self) -> Dict[str, Any]:
        """Get cache performance metrics"""
        try:
            info = self.redis_client.info()
            return {
                'connected_clients': info.get('connected_clients', 0),
                'used_memory': info.get('used_memory_human', '0'),
                'total_keys': self.redis_client.dbsize(),
                'hit_rate': self._calculate_hit_rate(info),
                'uptime_days': info.get('uptime_in_days', 0),
                'evicted_keys': info.get('evicted_keys_total', 0),
            }
        except Exception as e:
            logger.error(f"Error getting cache performance metrics: {e}")
            return {}

    def _calculate_hit_rate(self, info: Dict) -> float:
        """Calculate cache hit rate"""
        hits = info.get('keyspace_hits', 0)
        misses = info.get('keyspace_misses', 0)
        total = hits + misses
        return (hits / total * 100) if total > 0 else 0.0

    def set_tenant_cache_with_expiry(self, tenant_id: str, key: str, value: Any,
                                   expiry_minutes: int = 30) -> None:
        """Set cached value with specific expiry time in minutes"""
        ttl_seconds = expiry_minutes * 60
        self.set_tenant_cache(tenant_id, key, value, ttl_seconds)

    def get_or_set_tenant_cache(self, tenant_id: str, key: str, getter_func, ttl: Optional[int] = None):
        """Get from cache or set if not exists using getter function"""
        cached_value = self.get_tenant_cache(tenant_id, key)
        if cached_value is not None:
            return cached_value

        # Get fresh data
        fresh_value = getter_func()
        self.set_tenant_cache(tenant_id, key, fresh_value, ttl)
        return fresh_value


class CacheManager:
    """Manages caching across the multi-tenant application"""

    def __init__(self, cache_service: MultiTenantCacheService):
        self.cache = cache_service

    def get_agent_dashboard_data(self, tenant_id: str, agent_id: str) -> Optional[Dict]:
        """Get cached agent dashboard data"""
        cache_key = f"agent_dashboard:{agent_id}"
        return self.cache.get_tenant_cache(tenant_id, cache_key)

    def set_agent_dashboard_data(self, tenant_id: str, agent_id: str, data: Dict, ttl_minutes: int = 30) -> None:
        """Cache agent dashboard data"""
        cache_key = f"agent_dashboard:{agent_id}"
        self.cache.set_tenant_cache_with_expiry(tenant_id, cache_key, data, ttl_minutes)

    def get_customer_list(self, tenant_id: str, agent_id: str, page: int = 1, limit: int = 50) -> Optional[List]:
        """Get cached customer list"""
        cache_key = f"customer_list:{agent_id}:page_{page}:limit_{limit}"
        return self.cache.get_tenant_cache(tenant_id, cache_key)

    def set_customer_list(self, tenant_id: str, agent_id: str, customers: List, page: int = 1, limit: int = 50) -> None:
        """Cache customer list"""
        cache_key = f"customer_list:{agent_id}:page_{page}:limit_{limit}"
        self.cache.set_tenant_cache_with_expiry(tenant_id, cache_key, customers, 15)  # 15 minutes

    def get_policy_details(self, tenant_id: str, policy_id: str) -> Optional[Dict]:
        """Get cached policy details"""
        cache_key = f"policy:{policy_id}"
        return self.cache.get_tenant_cache(tenant_id, cache_key)

    def set_policy_details(self, tenant_id: str, policy_id: str, policy_data: Dict) -> None:
        """Cache policy details"""
        cache_key = f"policy:{policy_id}"
        self.cache.set_tenant_cache_with_expiry(tenant_id, cache_key, policy_data, 60)  # 1 hour

    def get_tenant_analytics(self, tenant_id: str, analytics_type: str, period: str) -> Optional[Dict]:
        """Get cached tenant analytics"""
        cache_key = f"analytics:{analytics_type}:{period}"
        return self.cache.get_tenant_cache(tenant_id, cache_key)

    def set_tenant_analytics(self, tenant_id: str, analytics_type: str, period: str, data: Dict) -> None:
        """Cache tenant analytics"""
        cache_key = f"analytics:{analytics_type}:{period}"
        self.cache.set_tenant_cache_with_expiry(tenant_id, cache_key, data, 120)  # 2 hours

    def invalidate_agent_data(self, tenant_id: str, agent_id: str) -> None:
        """Invalidate all cached data for an agent"""
        self.cache.invalidate_tenant_data(tenant_id, 'agent', agent_id)

    def invalidate_customer_data(self, tenant_id: str, customer_id: str) -> None:
        """Invalidate cached data for a customer"""
        self.cache.invalidate_tenant_data(tenant_id, 'customer', customer_id)

    def invalidate_policy_data(self, tenant_id: str, policy_id: str) -> None:
        """Invalidate cached data for a policy"""
        self.cache.invalidate_tenant_data(tenant_id, 'policy', policy_id)

    def invalidate_tenant_analytics(self, tenant_id: str) -> None:
        """Invalidate all analytics cache for a tenant"""
        self.cache._clear_pattern(tenant_id, "analytics:*")

    def warmup_tenant_cache(self, tenant_id: str) -> None:
        """Warm up cache with frequently accessed data"""
        self.cache.warm_tenant_cache(tenant_id)

    def get_tenant_cache_stats(self, tenant_id: str) -> Dict:
        """Get cache statistics for a tenant"""
        return self.cache.get_tenant_cache_info(tenant_id)

    def clear_tenant_cache(self, tenant_id: str) -> None:
        """Clear all cache for a tenant"""
        self.cache.clear_tenant_cache(tenant_id)

    def health_check(self) -> Dict:
        """Cache service health check"""
        try:
            # Simple ping test
            self.cache.redis_client.ping()
            metrics = self.cache.get_cache_performance_metrics()
            return {
                'status': 'healthy',
                'metrics': metrics
            }
        except Exception as e:
            return {
                'status': 'unhealthy',
                'error': str(e)
            }
