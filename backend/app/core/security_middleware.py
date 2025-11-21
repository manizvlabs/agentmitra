"""
Security Middleware for FastAPI
Implements rate limiting, security headers, and request validation
"""

from fastapi import Request, HTTPException, status
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import Response
import time
import hashlib
import hmac
import secrets
from typing import Dict, List, Optional, Tuple
import re
from collections import defaultdict
import asyncio
from datetime import datetime, timedelta

from app.core.logging_config import get_logger
from app.core.config import settings

logger = get_logger(__name__)

class SecurityMiddleware(BaseHTTPMiddleware):
    """Comprehensive security middleware"""

    def __init__(self, app, exclude_paths: List[str] = None):
        super().__init__(app)
        self.exclude_paths = exclude_paths or ["/health", "/docs", "/openapi.json"]
        self._setup_security()

    def _setup_security(self):
        """Initialize security configurations"""
        self.rate_limiter = RateLimiter()
        self.request_validator = RequestValidator()
        self.threat_detector = ThreatDetector()

    async def dispatch(self, request: Request, call_next):
        start_time = time.time()

        try:
            # Skip security checks for excluded paths
            if any(request.url.path.startswith(path) for path in self.exclude_paths):
                return await call_next(request)

            # Rate limiting check
            if not await self.rate_limiter.check_rate_limit(request):
                logger.warning(f"Rate limit exceeded for {request.client.host}")
                return JSONResponse(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    content={"error": "Too many requests", "retry_after": 60}
                )

            # Request validation
            validation_error = await self.request_validator.validate_request(request)
            if validation_error:
                logger.warning(f"Request validation failed: {validation_error}")
                return JSONResponse(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    content={"error": validation_error}
                )

            # Threat detection
            if await self.threat_detector.is_suspicious(request):
                logger.warning(f"Suspicious request detected from {request.client.host}")
                return JSONResponse(
                    status_code=status.HTTP_403_FORBIDDEN,
                    content={"error": "Request blocked for security reasons"}
                )

            # Process request
            response = await call_next(request)

            # Add security headers
            response = self._add_security_headers(response)

            # Log security events
            processing_time = time.time() - start_time
            if processing_time > 1.0:  # Log slow requests
                logger.info(f"Slow request: {request.method} {request.url.path} ({processing_time:.2f}s)")

            return response

        except Exception as e:
            logger.error(f"Security middleware error: {e}")
            return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content={"error": "Internal server error"}
            )

    def _add_security_headers(self, response: Response) -> Response:
        """Add security headers to response"""
        security_headers = {
            # Prevent clickjacking
            "X-Frame-Options": "SAMEORIGIN",

            # Prevent MIME type sniffing
            "X-Content-Type-Options": "nosniff",

            # XSS protection
            "X-XSS-Protection": "1; mode=block",

            # Referrer policy
            "Referrer-Policy": "strict-origin-when-cross-origin",

            # Content Security Policy
            "Content-Security-Policy": "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'",

            # HSTS (HTTP Strict Transport Security)
            "Strict-Transport-Security": "max-age=31536000; includeSubDomains",

            # Prevent caching of sensitive content
            "Cache-Control": "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0",
            "Pragma": "no-cache",
            "Expires": "0",
        }

        for header, value in security_headers.items():
            response.headers[header] = value

        return response


class RateLimiter:
    """Advanced rate limiter with multiple strategies"""

    def __init__(self):
        self.requests = defaultdict(list)
        self.blocked_ips = set()
        self._cleanup_task = None

        # Rate limit configurations
        self.limits = {
            "default": (100, 60),  # 100 requests per minute
            "auth": (10, 60),      # 10 auth requests per minute
            "api": (500, 60),      # 500 API requests per minute
            "import": (5, 60),     # 5 import requests per minute
        }

    async def check_rate_limit(self, request: Request) -> bool:
        """Check if request is within rate limits"""
        client_ip = self._get_client_ip(request)
        endpoint_type = self._get_endpoint_type(request.url.path)

        # Check if IP is blocked
        if client_ip in self.blocked_ips:
            return False

        # Get rate limit for endpoint type
        limit, window = self.limits.get(endpoint_type, self.limits["default"])

        # Clean old requests
        await self._cleanup_old_requests(client_ip)

        # Check current request count
        current_requests = len(self.requests[client_ip])
        if current_requests >= limit:
            # Block IP for 15 minutes
            self.blocked_ips.add(client_ip)
            asyncio.create_task(self._unblock_ip(client_ip, 900))
            return False

        # Add current request
        self.requests[client_ip].append(time.time())
        return True

    def _get_client_ip(self, request: Request) -> str:
        """Get real client IP address"""
        # Check X-Forwarded-For header first
        x_forwarded_for = request.headers.get("X-Forwarded-For")
        if x_forwarded_for:
            # Take the first IP in case of multiple proxies
            return x_forwarded_for.split(",")[0].strip()

        # Fall back to direct client host
        return request.client.host if request.client else "unknown"

    def _get_endpoint_type(self, path: str) -> str:
        """Determine endpoint type based on path"""
        if path.startswith("/api/v1/auth"):
            return "auth"
        elif path.startswith("/api/v1/import"):
            return "import"
        elif path.startswith("/api/v1/"):
            return "api"
        return "default"

    async def _cleanup_old_requests(self, client_ip: str):
        """Clean up old requests for rate limiting"""
        if client_ip not in self.requests:
            return

        current_time = time.time()
        window = 60  # 1 minute window

        # Keep only recent requests
        self.requests[client_ip] = [
            req_time for req_time in self.requests[client_ip]
            if current_time - req_time < window
        ]

    async def _unblock_ip(self, ip: str, duration: int):
        """Unblock IP after specified duration"""
        await asyncio.sleep(duration)
        self.blocked_ips.discard(ip)


class RequestValidator:
    """Request validation and sanitization"""

    def __init__(self):
        # SQL injection patterns
        self.sql_patterns = [
            r';\s*--',  # Semicolon followed by comment
            r';\s*/\*',  # Semicolon followed by block comment
            r'union\s+select',  # UNION SELECT
            r'/\*.*\*/',  # Block comments
            r'--.*$',  # Line comments
        ]

        # XSS patterns
        self.xss_patterns = [
            r'<script[^>]*>.*?</script>',
            r'javascript:',
            r'on\w+\s*=',
            r'<iframe[^>]*>.*?</iframe>',
            r'<object[^>]*>.*?</object>',
        ]

        # Path traversal patterns
        self.path_traversal_patterns = [
            r'\.\./',
            r'\.\.\\',
            r'%2e%2e%2f',
            r'%2e%2e%5c',
        ]

    async def validate_request(self, request: Request) -> Optional[str]:
        """Validate incoming request"""
        try:
            # Validate URL path
            if not self._is_valid_path(request.url.path):
                return "Invalid URL path"

            # Validate query parameters
            for key, value in request.query_params.items():
                if not self._is_safe_string(str(value)):
                    return f"Invalid query parameter: {key}"

            # Validate headers
            for header_name, header_value in request.headers.items():
                if not self._is_safe_header(header_name, header_value):
                    return f"Invalid header: {header_name}"

            # For POST/PUT requests, validate body would go here
            # (This would require reading the body, which might not be desirable for all requests)

            return None

        except Exception as e:
            logger.error(f"Request validation error: {e}")
            return "Request validation failed"

    def _is_valid_path(self, path: str) -> bool:
        """Validate URL path for security"""
        # Check path traversal
        for pattern in self.path_traversal_patterns:
            if re.search(pattern, path, re.IGNORECASE):
                return False

        # Check for null bytes
        if '\x00' in path:
            return False

        # Check for extremely long paths
        if len(path) > 2048:
            return False

        return True

    def _is_safe_string(self, value: str) -> bool:
        """Check if string contains potentially dangerous content"""
        # Check SQL injection patterns
        for pattern in self.sql_patterns:
            if re.search(pattern, value, re.IGNORECASE):
                return False

        # Check XSS patterns
        for pattern in self.xss_patterns:
            if re.search(pattern, value, re.IGNORECASE):
                return False

        # Check for null bytes
        if '\x00' in value:
            return False

        return True

    def _is_safe_header(self, name: str, value: str) -> bool:
        """Validate header name and value"""
        # Check header name
        if not re.match(r'^[a-zA-Z0-9-]+$', name):
            return False

        # Check for dangerous header values
        dangerous_headers = ['host', 'authorization']
        if name.lower() in dangerous_headers:
            # Additional validation for sensitive headers
            if not self._is_safe_string(value):
                return False

        return True


class ThreatDetector:
    """Advanced threat detection"""

    def __init__(self):
        self.suspicious_patterns = [
            # Common attack patterns
            r'\.\./',  # Directory traversal
            r'%2e%2e%2f',  # URL encoded directory traversal
            r'<script',  # XSS attempts
            r'union.*select',  # SQL injection
            r';\s*shutdown',  # System commands
            r'rm\s+-rf',  # Dangerous commands
        ]

        self.suspicious_ips = set()
        self.request_counts = defaultdict(int)
        self.last_request_time = defaultdict(float)

    async def is_suspicious(self, request: Request) -> bool:
        """Check if request appears suspicious"""
        try:
            client_ip = request.client.host if request.client else "unknown"

            # Check IP reputation (basic implementation)
            if client_ip in self.suspicious_ips:
                return True

            # Check request frequency (basic DoS protection)
            current_time = time.time()
            time_diff = current_time - self.last_request_time[client_ip]

            if time_diff < 0.1:  # More than 10 requests per second
                self.request_counts[client_ip] += 1
                if self.request_counts[client_ip] > 50:
                    self.suspicious_ips.add(client_ip)
                    logger.warning(f"IP {client_ip} marked as suspicious (high frequency)")
                    return True
            else:
                self.request_counts[client_ip] = 1

            self.last_request_time[client_ip] = current_time

            # Check request content
            full_url = str(request.url)
            user_agent = request.headers.get("user-agent", "")

            # Check for suspicious patterns
            for pattern in self.suspicious_patterns:
                if re.search(pattern, full_url, re.IGNORECASE):
                    logger.warning(f"Suspicious pattern detected in URL: {pattern}")
                    return True

                if re.search(pattern, user_agent, re.IGNORECASE):
                    logger.warning(f"Suspicious pattern detected in User-Agent: {pattern}")
                    return True

            # Check request size (basic DoS protection)
            content_length = request.headers.get("content-length")
            if content_length:
                try:
                    size = int(content_length)
                    if size > 10 * 1024 * 1024:  # 10MB limit
                        logger.warning(f"Request too large from {client_ip}: {size} bytes")
                        return True
                except ValueError:
                    pass

            return False

        except Exception as e:
            logger.error(f"Threat detection error: {e}")
            # On error, allow the request to proceed
            return False


# Security utility functions
def generate_secure_token(length: int = 32) -> str:
    """Generate a cryptographically secure random token"""
    return secrets.token_urlsafe(length)

def hash_password(password: str, salt: str = None) -> Tuple[str, str]:
    """Hash password with salt using PBKDF2"""
    if not salt:
        salt = secrets.token_hex(16)

    # Use PBKDF2 with SHA-256
    key = hashlib.pbkdf2_hmac(
        'sha256',
        password.encode('utf-8'),
        salt.encode('utf-8'),
        100000  # 100,000 iterations
    )

    return key.hex(), salt

def verify_password(password: str, hashed: str, salt: str) -> bool:
    """Verify password against hash"""
    key, _ = hash_password(password, salt)
    return hmac.compare_digest(key, hashed)

def sanitize_input(input_string: str) -> str:
    """Sanitize user input to prevent injection attacks"""
    if not input_string:
        return ""

    # Remove potentially dangerous characters
    sanitized = re.sub(r'[;\'\"\\]', '', input_string)

    # Trim whitespace
    sanitized = sanitized.strip()

    # Limit length
    if len(sanitized) > 1000:
        sanitized = sanitized[:1000]

    return sanitized
