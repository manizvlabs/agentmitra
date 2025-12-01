"""
Redis Cache Service for Agent Mitra
Provides caching functionality for analytics and other frequently accessed data
"""
import json
import logging
from typing import Any, Optional, Union
from datetime import timedelta
import redis
from functools import wraps

from app.core.config import settings

logger = logging.getLogger(__name__)


class RedisCache:
    """Redis cache service with TTL support"""

    def __init__(self):
        self.redis_client = None
        self._connect()

    def _connect(self):
        """Establish Redis connection"""
        try:
            self.redis_client = redis.Redis(
                host=settings.REDIS_HOST,
                port=settings.REDIS_PORT,
                db=settings.REDIS_DB,
                password=settings.REDIS_PASSWORD,
                decode_responses=True,
                socket_connect_timeout=5,
                socket_timeout=5,
                retry_on_timeout=True,
                max_connections=20
            )
            # Test connection
            self.redis_client.ping()
            logger.info(f"Connected to Redis at {settings.REDIS_HOST}:{settings.REDIS_PORT}")
        except redis.ConnectionError as e:
            logger.warning(f"Failed to connect to Redis: {e}")
            self.redis_client = None
        except Exception as e:
            logger.error(f"Redis connection error: {e}")
            self.redis_client = None

    def is_connected(self) -> bool:
        """Check if Redis is connected"""
        return self.redis_client is not None

    def get(self, key: str) -> Optional[Any]:
        """Get value from cache"""
        if not self.is_connected():
            return None

        try:
            value = self.redis_client.get(key)
            if value:
                return json.loads(value)
            return None
        except Exception as e:
            logger.error(f"Redis get error for key {key}: {e}")
            return None

    def set(self, key: str, value: Any, ttl_seconds: int = 300) -> bool:
        """Set value in cache with TTL"""
        if not self.is_connected():
            return False

        try:
            serialized_value = json.dumps(value)
            return bool(self.redis_client.setex(key, ttl_seconds, serialized_value))
        except Exception as e:
            logger.error(f"Redis set error for key {key}: {e}")
            return False

    def delete(self, key: str) -> bool:
        """Delete key from cache"""
        if not self.is_connected():
            return False

        try:
            return bool(self.redis_client.delete(key))
        except Exception as e:
            logger.error(f"Redis delete error for key {key}: {e}")
            return False

    def delete_pattern(self, pattern: str) -> int:
        """Delete keys matching pattern"""
        if not self.is_connected():
            return 0

        try:
            keys = self.redis_client.keys(pattern)
            if keys:
                return self.redis_client.delete(*keys)
            return 0
        except Exception as e:
            logger.error(f"Redis delete pattern error for {pattern}: {e}")
            return 0

    def clear_analytics_cache(self) -> int:
        """Clear all analytics-related cache"""
        return self.delete_pattern("analytics:*")

    def get_cache_key(self, prefix: str, *args) -> str:
        """Generate cache key from prefix and arguments"""
        key_parts = [prefix] + [str(arg) for arg in args]
        return ":".join(key_parts)


# Global cache instance
cache = RedisCache()


def cached(ttl_seconds: int = 300, key_prefix: str = "cache"):
    """
    Decorator to cache function results

    Args:
        ttl_seconds: Time to live in seconds
        key_prefix: Prefix for cache key
    """
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # Generate cache key
            key_parts = [key_prefix, func.__name__]
            key_parts.extend([str(arg) for arg in args[1:]])  # Skip 'self' for methods
            for k, v in sorted(kwargs.items()):
                key_parts.extend([k, str(v)])
            cache_key = ":".join(key_parts)

            # Try to get from cache first
            cached_result = cache.get(cache_key)
            if cached_result is not None:
                logger.debug(f"Cache hit for {cache_key}")
                return cached_result

            # Execute function
            result = await func(*args, **kwargs)

            # Cache the result
            if cache.set(cache_key, result, ttl_seconds):
                logger.debug(f"Cached result for {cache_key}")
            else:
                logger.warning(f"Failed to cache result for {cache_key}")

            return result

        return wrapper
    return decorator


def analytics_cache(ttl_seconds: int = 600):
    """Decorator specifically for analytics caching"""
    return cached(ttl_seconds=ttl_seconds, key_prefix="analytics")


# Cache key constants
class CacheKeys:
    """Cache key constants for different data types"""

    @staticmethod
    def dashboard_kpis(agent_id: Optional[str] = None):
        if agent_id:
            return f"analytics:dashboard:kpis:agent:{agent_id}"
        return "analytics:dashboard:kpis:global"

    @staticmethod
    def top_agents(limit: int, date_range: Optional[tuple] = None):
        key = f"analytics:dashboard:top_agents:limit:{limit}"
        if date_range:
            start, end = date_range
            key += f":daterange:{start}:{end}"
        return key

    @staticmethod
    def revenue_trends(date_range: Optional[tuple] = None):
        key = "analytics:dashboard:revenue_trends"
        if date_range:
            start, end = date_range
            key += f":daterange:{start}:{end}"
        return key

    @staticmethod
    def policy_trends(date_range: Optional[tuple] = None):
        key = "analytics:dashboard:policy_trends"
        if date_range:
            start, end = date_range
            key += f":daterange:{start}:{end}"
        return key

    @staticmethod
    def agent_performance(agent_id: str, date_range: Optional[tuple] = None):
        key = f"analytics:agent:performance:{agent_id}"
        if date_range:
            start, end = date_range
            key += f":daterange:{start}:{end}"
        return key

    @staticmethod
    def leads_data(agent_id: str, priority_filter: str = "all"):
        return f"analytics:leads:agent:{agent_id}:priority:{priority_filter}"

    @staticmethod
    def retention_data(agent_id: str):
        return f"analytics:retention:agent:{agent_id}"

    @staticmethod
    def roi_data(agent_id: str, date_range: Optional[tuple] = None):
        key = f"analytics:roi:agent:{agent_id}"
        if date_range:
            start, end = date_range
            key += f":daterange:{start}:{end}"
        return key
