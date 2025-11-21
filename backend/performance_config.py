"""
Backend Performance Optimization Configuration
"""

from typing import Dict, Any
import os

# Performance settings
PERFORMANCE_CONFIG = {
    # Database connection pool settings
    "database": {
        "pool_size": int(os.getenv("DB_POOL_SIZE", "10")),
        "max_overflow": int(os.getenv("DB_MAX_OVERFLOW", "20")),
        "pool_timeout": int(os.getenv("DB_POOL_TIMEOUT", "30")),
        "pool_recycle": int(os.getenv("DB_POOL_RECYCLE", "3600")),
        "echo": os.getenv("DB_ECHO", "false").lower() == "true",
    },

    # Redis cache settings
    "redis": {
        "host": os.getenv("REDIS_HOST", "localhost"),
        "port": int(os.getenv("REDIS_PORT", "6379")),
        "db": int(os.getenv("REDIS_DB", "0")),
        "password": os.getenv("REDIS_PASSWORD"),
        "socket_timeout": int(os.getenv("REDIS_SOCKET_TIMEOUT", "5")),
        "socket_connect_timeout": int(os.getenv("REDIS_SOCKET_CONNECT_TIMEOUT", "5")),
        "socket_keepalive": True,
        "socket_keepalive_options": {
            "TCP_KEEPIDLE": 60,
            "TCP_KEEPINTVL": 30,
            "TCP_KEEPCNT": 3,
        },
        "health_check_interval": 30,
    },

    # API rate limiting
    "rate_limiting": {
        "enabled": os.getenv("RATE_LIMITING_ENABLED", "true").lower() == "true",
        "default_limit": os.getenv("RATE_LIMIT_DEFAULT", "100/minute"),
        "auth_limit": os.getenv("RATE_LIMIT_AUTH", "10/minute"),
        "import_limit": os.getenv("RATE_LIMIT_IMPORT", "5/minute"),
        "analytics_limit": os.getenv("RATE_LIMIT_ANALYTICS", "50/minute"),
    },

    # Caching configuration
    "caching": {
        "enabled": os.getenv("CACHE_ENABLED", "true").lower() == "true",
        "ttl": {
            "user_data": int(os.getenv("CACHE_USER_TTL", "300")),  # 5 minutes
            "analytics": int(os.getenv("CACHE_ANALYTICS_TTL", "600")),  # 10 minutes
            "presentations": int(os.getenv("CACHE_PRESENTATIONS_TTL", "1800")),  # 30 minutes
            "static_data": int(os.getenv("CACHE_STATIC_TTL", "3600")),  # 1 hour
        },
        "max_memory": os.getenv("CACHE_MAX_MEMORY", "512mb"),
        "max_memory_policy": os.getenv("CACHE_MAX_MEMORY_POLICY", "allkeys-lru"),
    },

    # API performance monitoring
    "monitoring": {
        "enabled": os.getenv("API_MONITORING_ENABLED", "true").lower() == "true",
        "slow_query_threshold": float(os.getenv("SLOW_QUERY_THRESHOLD", "1.0")),  # seconds
        "request_timeout": int(os.getenv("REQUEST_TIMEOUT", "30")),  # seconds
        "metrics_interval": int(os.getenv("METRICS_INTERVAL", "60")),  # seconds
    },

    # Background task configuration
    "background_tasks": {
        "enabled": os.getenv("BACKGROUND_TASKS_ENABLED", "true").lower() == "true",
        "max_workers": int(os.getenv("MAX_WORKERS", "4")),
        "task_timeout": int(os.getenv("TASK_TIMEOUT", "300")),  # 5 minutes
        "queue_size": int(os.getenv("QUEUE_SIZE", "1000")),
    },

    # Security performance settings
    "security": {
        "jwt_expiration": int(os.getenv("JWT_EXPIRATION", "3600")),  # 1 hour
        "session_timeout": int(os.getenv("SESSION_TIMEOUT", "7200")),  # 2 hours
        "max_login_attempts": int(os.getenv("MAX_LOGIN_ATTEMPTS", "5")),
        "lockout_duration": int(os.getenv("LOCKOUT_DURATION", "900")),  # 15 minutes
    },

    # File upload settings
    "uploads": {
        "max_file_size": int(os.getenv("MAX_FILE_SIZE", "10485760")),  # 10MB
        "allowed_extensions": [".csv", ".xlsx", ".xls", ".json"],
        "upload_timeout": int(os.getenv("UPLOAD_TIMEOUT", "120")),  # 2 minutes
        "chunk_size": int(os.getenv("UPLOAD_CHUNK_SIZE", "8192")),  # 8KB
    },

    # Logging performance
    "logging": {
        "level": os.getenv("LOG_LEVEL", "INFO"),
        "max_file_size": os.getenv("LOG_MAX_SIZE", "10MB"),
        "backup_count": int(os.getenv("LOG_BACKUP_COUNT", "5")),
        "async_logging": os.getenv("ASYNC_LOGGING", "true").lower() == "true",
    },
}

def get_performance_config(section: str = None) -> Dict[str, Any]:
    """Get performance configuration for a specific section or all sections"""
    if section:
        return PERFORMANCE_CONFIG.get(section, {})
    return PERFORMANCE_CONFIG

def is_feature_enabled(feature: str) -> bool:
    """Check if a performance feature is enabled"""
    config = PERFORMANCE_CONFIG.get(feature, {})
    return config.get("enabled", False)

def get_cache_ttl(cache_type: str) -> int:
    """Get cache TTL for a specific cache type"""
    cache_config = PERFORMANCE_CONFIG.get("caching", {}).get("ttl", {})
    return cache_config.get(cache_type, 300)  # Default 5 minutes

def get_rate_limit(endpoint_type: str) -> str:
    """Get rate limit for a specific endpoint type"""
    rate_limits = PERFORMANCE_CONFIG.get("rate_limiting", {})
    return rate_limits.get(f"{endpoint_type}_limit", rate_limits.get("default_limit", "100/minute"))

# Performance monitoring decorators
def performance_monitor(func):
    """Decorator to monitor function performance"""
    import time
    import functools
    from app.core.logging_config import get_logger

    logger = get_logger(__name__)

    @functools.wraps(func)
    async def wrapper(*args, **kwargs):
        start_time = time.time()
        try:
            result = await func(*args, **kwargs)
            execution_time = time.time() - start_time

            # Log slow queries
            threshold = PERFORMANCE_CONFIG["monitoring"]["slow_query_threshold"]
            if execution_time > threshold:
                logger.warning(
                    f"Slow operation detected: {func.__name__}",
                    extra={
                        "execution_time": execution_time,
                        "threshold": threshold,
                        "function": func.__name__,
                    }
                )

            return result
        except Exception as e:
            execution_time = time.time() - start_time
            logger.error(
                f"Operation failed: {func.__name__}",
                extra={
                    "execution_time": execution_time,
                    "error": str(e),
                    "function": func.__name__,
                }
            )
            raise

    return wrapper

# Database query optimization helpers
def optimize_query(query, use_cache: bool = True):
    """Optimize database query with caching and performance hints"""
    if use_cache and is_feature_enabled("caching"):
        # Add caching logic here
        pass

    # Add query optimization hints
    optimized_query = query.options(
        # Add specific optimization options based on query type
    )

    return optimized_query

# Memory usage monitoring
def get_memory_usage():
    """Get current memory usage statistics"""
    import psutil
    import os

    process = psutil.Process(os.getpid())
    memory_info = process.memory_info()

    return {
        "rss": memory_info.rss,  # Resident Set Size
        "vms": memory_info.vms,  # Virtual Memory Size
        "percent": process.memory_percent(),
        "rss_mb": memory_info.rss / 1024 / 1024,
        "vms_mb": memory_info.vms / 1024 / 1024,
    }

def log_performance_metrics():
    """Log current performance metrics"""
    from app.core.logging_config import get_logger

    logger = get_logger(__name__)

    try:
        memory_usage = get_memory_usage()

        logger.info(
            "Performance metrics",
            extra={
                "memory_rss_mb": round(memory_usage["rss_mb"], 2),
                "memory_vms_mb": round(memory_usage["vms_mb"], 2),
                "memory_percent": round(memory_usage["percent"], 2),
            }
        )
    except Exception as e:
        logger.error(f"Failed to collect performance metrics: {e}")
