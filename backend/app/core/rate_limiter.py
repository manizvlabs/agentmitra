"""
Rate Limiting Middleware and Utilities
Implements rate limiting for API endpoints using Redis or in-memory storage
"""
from typing import Optional, Dict
from datetime import datetime, timedelta
from fastapi import HTTPException, status, Request
from fastapi.responses import JSONResponse
import redis
from app.core.config.settings import settings
from app.core.logging_config import get_logger

logger = get_logger(__name__)

# Initialize Redis client for rate limiting
try:
    redis_client = redis.from_url(settings.redis_url, decode_responses=True)
except Exception:
    redis_client = None
    logger.warning("Redis not available, using in-memory rate limiting (not shared across instances)")
    # Fallback to in-memory storage
    _rate_limit_storage: Dict[str, Dict] = {}


class RateLimiter:
    """Rate limiter for API endpoints"""
    
    def __init__(self, limit: int, window: str):
        """
        Initialize rate limiter
        
        Args:
            limit: Maximum number of requests
            window: Time window (e.g., "60/minute", "5/hour", "100/day")
        """
        self.limit = limit
        self.window_str = window
        
        # Parse window
        if "/" in window:
            duration_str, unit = window.split("/")
            duration = int(duration_str)
            
            if unit == "minute" or unit == "min":
                self.window_seconds = duration * 60
            elif unit == "hour" or unit == "hr":
                self.window_seconds = duration * 3600
            elif unit == "day":
                self.window_seconds = duration * 86400
            else:
                self.window_seconds = duration  # Assume seconds
        else:
            self.window_seconds = 60  # Default to 1 minute
    
    def _get_key(self, identifier: str) -> str:
        """Get Redis key for rate limiting"""
        return f"rate_limit:{identifier}:{self.window_str}"
    
    def is_allowed(self, identifier: str) -> tuple[bool, Optional[int]]:
        """
        Check if request is allowed
        
        Args:
            identifier: Unique identifier (e.g., IP address, user_id, phone_number)
        
        Returns:
            Tuple of (is_allowed, remaining_requests)
        """
        key = self._get_key(identifier)
        now = datetime.utcnow()
        
        if redis_client:
            # Use Redis with sliding window
            pipe = redis_client.pipeline()
            pipe.incr(key)
            pipe.expire(key, self.window_seconds)
            results = pipe.execute()
            
            current_count = results[0]
            
            if current_count > self.limit:
                # Reset if exceeded
                redis_client.delete(key)
                return False, 0
            
            remaining = max(0, self.limit - current_count)
            return current_count <= self.limit, remaining
        else:
            # Fallback to in-memory storage
            if identifier not in _rate_limit_storage:
                _rate_limit_storage[identifier] = {
                    "count": 0,
                    "window_start": now
                }
            
            data = _rate_limit_storage[identifier]
            
            # Reset if window expired
            if (now - data["window_start"]).total_seconds() > self.window_seconds:
                data["count"] = 0
                data["window_start"] = now
            
            # Increment count
            data["count"] += 1
            
            if data["count"] > self.limit:
                remaining = 0
                return False, remaining
            
            remaining = max(0, self.limit - data["count"])
            return True, remaining
    
    def get_remaining(self, identifier: str) -> int:
        """Get remaining requests for identifier"""
        _, remaining = self.is_allowed(identifier)
        return remaining or 0
    
    def reset(self, identifier: str) -> None:
        """Reset rate limit for identifier (useful for testing)"""
        key = self._get_key(identifier)
        if redis_client:
            redis_client.delete(key)
        else:
            if identifier in _rate_limit_storage:
                del _rate_limit_storage[identifier]
    
    def reset_all(self) -> None:
        """Reset all rate limits (useful for testing)"""
        if redis_client:
            # Delete all rate limit keys
            keys = redis_client.keys("rate_limit:*")
            if keys:
                redis_client.delete(*keys)
        else:
            _rate_limit_storage.clear()


# Pre-configured rate limiters
auth_rate_limiter = RateLimiter(
    limit=int(settings.rate_limit_auth.split("/")[0]),
    window=settings.rate_limit_auth
)

otp_rate_limiter = RateLimiter(
    limit=int(settings.rate_limit_otp.split("/")[0]),
    window=settings.rate_limit_otp
)

default_rate_limiter = RateLimiter(
    limit=int(settings.rate_limit_default.split("/")[0]),
    window=settings.rate_limit_default
)


async def rate_limit_middleware(request: Request, call_next):
    """Rate limiting middleware"""
    if not settings.rate_limiting_enabled:
        return await call_next(request)
    
    # Get identifier (IP address or user ID)
    identifier = request.client.host if request.client else "unknown"
    
    # Get user ID if authenticated
    user_id = getattr(request.state, 'user_id', None)
    if user_id:
        identifier = f"user:{user_id}"
    
    # Determine rate limiter based on endpoint
    path = request.url.path
    
    if path.startswith("/api/v1/auth"):
        if "otp" in path.lower():
            limiter = otp_rate_limiter
        else:
            limiter = auth_rate_limiter
    else:
        limiter = default_rate_limiter
    
    # Check rate limit
    is_allowed, remaining = limiter.is_allowed(identifier)
    
    if not is_allowed:
        logger.warning(f"Rate limit exceeded for {identifier} on {path}")
        return JSONResponse(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            content={
                "detail": "Rate limit exceeded. Please try again later.",
                "retry_after": limiter.window_seconds
            },
            headers={
                "X-RateLimit-Limit": str(limiter.limit),
                "X-RateLimit-Remaining": "0",
                "Retry-After": str(limiter.window_seconds)
            }
        )
    
    # Add rate limit headers
    response = await call_next(request)
    response.headers["X-RateLimit-Limit"] = str(limiter.limit)
    response.headers["X-RateLimit-Remaining"] = str(remaining)
    
    return response


def rate_limit(limit: int, window: str):
    """
    Decorator for rate limiting specific endpoints
    
    Usage:
        @router.post("/endpoint")
        @rate_limit(limit=10, window="60/minute")
        async def my_endpoint():
            ...
    """
    limiter = RateLimiter(limit=limit, window=window)
    
    def decorator(func):
        async def wrapper(*args, **kwargs):
            # Extract identifier from request
            request = kwargs.get('request') or args[0] if args else None
            if not request:
                return await func(*args, **kwargs)
            
            identifier = request.client.host if request.client else "unknown"
            user_id = getattr(request.state, 'user_id', None)
            if user_id:
                identifier = f"user:{user_id}"
            
            is_allowed, remaining = limiter.is_allowed(identifier)
            
            if not is_allowed:
                raise HTTPException(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    detail="Rate limit exceeded. Please try again later.",
                    headers={
                        "X-RateLimit-Limit": str(limiter.limit),
                        "X-RateLimit-Remaining": "0",
                        "Retry-After": str(limiter.window_seconds)
                    }
                )
            
            return await func(*args, **kwargs)
        
        return wrapper
    return decorator

