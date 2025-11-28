"""
Correlation ID Middleware
========================

Middleware for adding correlation IDs to requests for distributed tracing and logging.
"""

import uuid
from typing import Callable
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

from app.core.logging_config import RequestLogger
from app.core.monitoring import monitoring
import logging

logger = logging.getLogger(__name__)


class CorrelationIdMiddleware(BaseHTTPMiddleware):
    """Middleware to add correlation IDs to requests"""

    def __init__(self, app: Callable):
        super().__init__(app)
        self.request_logger = RequestLogger(logger)

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        # Generate or get correlation ID
        correlation_id = request.headers.get('x-correlation-id', str(uuid.uuid4()))

        # Add correlation ID to request state
        request.state.correlation_id = correlation_id

        # Add correlation ID to response headers
        response = await call_next(request)
        response.headers['x-correlation-id'] = correlation_id

        return response


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """Middleware for comprehensive request logging with correlation IDs"""

    def __init__(self, app: Callable):
        super().__init__(app)
        self.request_logger = RequestLogger(logger)

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        import time

        # Get correlation ID
        correlation_id = getattr(request.state, 'correlation_id', str(uuid.uuid4()))

        # Extract context information
        context = {
            'correlation_id': correlation_id,
            'endpoint': request.url.path,
            'method': request.method,
            'ip_address': request.client.host if request.client else None,
            'user_agent': request.headers.get('user-agent'),
        }

        # Log request start
        await self.request_logger.log_request(request, **context)

        start_time = time.time()

        try:
            # Process request
            response = await call_next(request)

            # Calculate processing time
            process_time = time.time() - start_time

            # Add processing time to context
            context['duration_ms'] = round(process_time * 1000, 2)

            # Log successful response
            await self.request_logger.log_request(request, response, **context)

            # Record metrics
            await monitoring.record_request_metrics(
                method=request.method,
                endpoint=request.url.path,
                status_code=response.status_code,
                duration=process_time
            )

            # Add processing time header
            response.headers['x-process-time'] = str(process_time)

            return response

        except Exception as e:
            # Calculate processing time for error
            process_time = time.time() - start_time
            context['duration_ms'] = round(process_time * 1000, 2)

            # Log error
            await self.request_logger.log_request(request, error=e, **context)

            # Record error metrics
            await monitoring.record_request_metrics(
                method=request.method,
                endpoint=request.url.path,
                status_code=500,
                duration=process_time
            )

            # Re-raise exception
            raise
