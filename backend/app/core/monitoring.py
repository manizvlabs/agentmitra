"""
Application Monitoring & Metrics
================================

This module provides comprehensive monitoring including:
- Application performance metrics
- Health checks and alerts
- Custom business metrics
- Integration with monitoring services
"""

import time
import logging
from typing import Dict, Any, Optional
from dataclasses import dataclass
from contextlib import asynccontextmanager

import psutil
from prometheus_client import Counter, Histogram, Gauge, generate_latest

from app.core.config.settings import settings

logger = logging.getLogger(__name__)

# Prometheus metrics
REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status_code']
)

REQUEST_LATENCY = Histogram(
    'http_request_duration_seconds',
    'HTTP request latency',
    ['method', 'endpoint']
)

ACTIVE_CONNECTIONS = Gauge(
    'active_connections',
    'Number of active connections'
)

DB_CONNECTIONS = Gauge(
    'db_connections_active',
    'Number of active database connections'
)

MEMORY_USAGE = Gauge(
    'memory_usage_bytes',
    'Memory usage in bytes'
)

CPU_USAGE = Gauge(
    'cpu_usage_percent',
    'CPU usage percentage'
)

# Business metrics
POLICY_CREATED_COUNT = Counter(
    'policies_created_total',
    'Total number of policies created',
    ['agent_type', 'policy_type']
)

PAYMENT_PROCESSED_COUNT = Counter(
    'payments_processed_total',
    'Total number of payments processed',
    ['gateway', 'status']
)

WHATSAPP_MESSAGES_SENT = Counter(
    'whatsapp_messages_sent_total',
    'Total WhatsApp messages sent',
    ['message_type', 'status']
)

IMPORT_JOBS_COMPLETED = Counter(
    'import_jobs_completed_total',
    'Total import jobs completed',
    ['import_type', 'status']
)

USER_LOGIN_COUNT = Counter(
    'user_logins_total',
    'Total user logins',
    ['user_type', 'login_method']
)

API_ERRORS = Counter(
    'api_errors_total',
    'Total API errors',
    ['endpoint', 'error_type']
)


@dataclass
class HealthStatus:
    """Health check status"""
    status: str  # 'healthy', 'degraded', 'unhealthy'
    timestamp: float
    checks: Dict[str, Dict[str, Any]]


class MonitoringService:
    """Application monitoring service"""

    def __init__(self):
        self.start_time = time.time()

    async def health_check(self) -> HealthStatus:
        """Comprehensive health check"""

        checks = {}

        # Database health
        db_status = await self._check_database()
        checks['database'] = db_status

        # Redis health
        redis_status = await self._check_redis()
        checks['redis'] = redis_status

        # External services
        external_status = await self._check_external_services()
        checks['external_services'] = external_status

        # Application metrics
        app_status = await self._check_application_metrics()
        checks['application'] = app_status

        # Determine overall status
        failed_checks = [k for k, v in checks.items() if not v.get('healthy', False)]
        if failed_checks:
            if len(failed_checks) > 2:
                status = 'unhealthy'
            else:
                status = 'degraded'
        else:
            status = 'healthy'

        return HealthStatus(
            status=status,
            timestamp=time.time(),
            checks=checks
        )

    async def get_metrics(self) -> str:
        """Get Prometheus metrics"""
        # Update gauges
        MEMORY_USAGE.set(psutil.virtual_memory().used)
        CPU_USAGE.set(psutil.cpu_percent(interval=1))

        # Generate latest metrics
        return generate_latest()

    async def record_request_metrics(
        self,
        method: str,
        endpoint: str,
        status_code: int,
        duration: float
    ):
        """Record HTTP request metrics"""
        REQUEST_COUNT.labels(
            method=method,
            endpoint=endpoint,
            status_code=status_code
        ).inc()

        REQUEST_LATENCY.labels(
            method=method,
            endpoint=endpoint
        ).observe(duration)

        # Record API errors
        if status_code >= 400:
            API_ERRORS.labels(
                endpoint=endpoint,
                error_type=self._get_error_type(status_code)
            ).inc()

    @asynccontextmanager
    async def measure_request_time(self, method: str, endpoint: str):
        """Context manager to measure request time"""
        start_time = time.time()
        try:
            yield
        finally:
            duration = time.time() - start_time
            await self.record_request_metrics(method, endpoint, 200, duration)

    def record_business_metrics(
        self,
        metric_type: str,
        labels: Dict[str, str] = None,
        value: float = 1.0
    ):
        """Record business metrics"""
        labels = labels or {}

        if metric_type == "policy_created":
            POLICY_CREATED_COUNT.labels(**labels).inc(value)
        elif metric_type == "payment_processed":
            PAYMENT_PROCESSED_COUNT.labels(**labels).inc(value)
        elif metric_type == "whatsapp_message_sent":
            WHATSAPP_MESSAGES_SENT.labels(**labels).inc(value)
        elif metric_type == "import_job_completed":
            IMPORT_JOBS_COMPLETED.labels(**labels).inc(value)
        elif metric_type == "user_login":
            USER_LOGIN_COUNT.labels(**labels).inc(value)

    async def _check_database(self) -> Dict[str, Any]:
        """Check database connectivity"""
        try:
            from app.core.database import check_database_health
            result = await check_database_health()
            return {
                'healthy': result['status'] == 'healthy',
                'response_time': result.get('response_time'),
                'active_connections': result.get('active_connections')
            }
        except Exception as e:
            return {
                'healthy': False,
                'error': str(e)
            }

    async def _check_redis(self) -> Dict[str, Any]:
        """Check Redis connectivity"""
        try:
            import redis
            r = redis.from_url(settings.redis_url)
            r.ping()
            return {'healthy': True}
        except Exception as e:
            return {
                'healthy': False,
                'error': str(e)
            }

    async def _check_external_services(self) -> Dict[str, Any]:
        """Check external service connectivity"""
        services_status = {}

        # Check OpenAI
        try:
            import openai
            # Simple connectivity check (API key validation)
            if settings.openai_api_key:
                services_status['openai'] = {'healthy': True}
            else:
                services_status['openai'] = {'healthy': False, 'error': 'API key not configured'}
        except:
            services_status['openai'] = {'healthy': False}

        # Check WhatsApp
        try:
            if settings.whatsapp_access_token and settings.whatsapp_api_url:
                services_status['whatsapp'] = {'healthy': True}
            else:
                services_status['whatsapp'] = {'healthy': False, 'error': 'Not configured'}
        except:
            services_status['whatsapp'] = {'healthy': False}

        # Check payment gateways
        try:
            if settings.razorpay_key_id or settings.stripe_secret_key:
                services_status['payment_gateways'] = {'healthy': True}
            else:
                services_status['payment_gateways'] = {'healthy': False, 'error': 'No gateway configured'}
        except:
            services_status['payment_gateways'] = {'healthy': False}

        return services_status

    async def _check_application_metrics(self) -> Dict[str, Any]:
        """Check application-specific metrics"""
        return {
            'healthy': True,
            'uptime_seconds': time.time() - self.start_time,
            'memory_usage': psutil.virtual_memory().percent,
            'cpu_usage': psutil.cpu_percent(interval=1)
        }

    def _get_error_type(self, status_code: int) -> str:
        """Get error type from HTTP status code"""
        if status_code == 400:
            return 'bad_request'
        elif status_code == 401:
            return 'unauthorized'
        elif status_code == 403:
            return 'forbidden'
        elif status_code == 404:
            return 'not_found'
        elif status_code == 422:
            return 'validation_error'
        elif status_code >= 500:
            return 'server_error'
        else:
            return 'other'


# Global monitoring instance
monitoring = MonitoringService()
