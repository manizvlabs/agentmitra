"""
Monitoring utilities for response time tracking and performance metrics
"""
import time
import logging
import psutil
from functools import wraps
from typing import Callable, Any
from fastapi import Request, Response

logger = logging.getLogger(__name__)


def response_time_monitor(endpoint_name: str = None):
    """
    Decorator to monitor response times for endpoints

    Args:
        endpoint_name: Name of the endpoint for logging
    """
    def decorator(func: Callable) -> Callable:
        @wraps(func)
        async def wrapper(*args, **kwargs):
            start_time = time.time()

            try:
                # Get endpoint name from function if not provided
                name = endpoint_name or func.__name__

                # Execute the function
                result = await func(*args, **kwargs)

                # Calculate response time
                end_time = time.time()
                response_time_ms = (end_time - start_time) * 1000

                # Log response time
                logger.info(f"Endpoint '{name}' completed in {response_time_ms:.2f}ms")

                # Add response time header if result is a Response object
                if hasattr(result, 'headers'):
                    result.headers['X-Response-Time'] = f"{response_time_ms:.2f}ms"

                return result

            except Exception as e:
                # Calculate response time even for errors
                end_time = time.time()
                response_time_ms = (end_time - start_time) * 1000

                name = endpoint_name or func.__name__
                logger.error(f"Endpoint '{name}' failed after {response_time_ms:.2f}ms: {str(e)}")

                raise

        return wrapper
    return decorator


def analytics_monitor(endpoint_name: str = None):
    """
    Specialized decorator for analytics endpoints with performance logging
    """
    def decorator(func: Callable) -> Callable:
        @wraps(func)
        async def wrapper(*args, **kwargs):
            start_time = time.time()

            try:
                # Get endpoint name
                name = endpoint_name or f"analytics.{func.__name__}"

                logger.info(f"Analytics request started: {name}")

                # Execute the function
                result = await func(*args, **kwargs)

                # Calculate and log performance
                end_time = time.time()
                response_time_ms = (end_time - start_time) * 1000

                # Log performance metrics
                if response_time_ms > 1000:  # Log slow queries (> 1 second)
                    logger.warning(f"SLOW ANALYTICS: '{name}' took {response_time_ms:.2f}ms")
                elif response_time_ms > 500:  # Log moderately slow queries (> 500ms)
                    logger.info(f"MODERATE ANALYTICS: '{name}' took {response_time_ms:.2f}ms")
                else:
                    logger.debug(f"FAST ANALYTICS: '{name}' took {response_time_ms:.2f}ms")

                # Add performance headers
                if hasattr(result, 'headers'):
                    result.headers['X-Response-Time'] = f"{response_time_ms:.2f}ms"
                    result.headers['X-Endpoint-Name'] = name

                return result

            except Exception as e:
                # Log error with timing
                end_time = time.time()
                response_time_ms = (end_time - start_time) * 1000

                name = endpoint_name or f"analytics.{func.__name__}"
                logger.error(f"Analytics error in '{name}' after {response_time_ms:.2f}ms: {str(e)}")

                raise

        return wrapper
    return decorator


class PerformanceTracker:
    """Utility class for tracking performance metrics"""

    def __init__(self):
        self.requests = []

    def start_request(self, request_id: str, endpoint: str):
        """Start tracking a request"""
        self.requests.append({
            'id': request_id,
            'endpoint': endpoint,
            'start_time': time.time(),
            'status': 'in_progress'
        })

    def end_request(self, request_id: str, status: str = 'completed'):
        """End tracking a request"""
        for req in self.requests:
            if req['id'] == request_id:
                req['end_time'] = time.time()
                req['duration_ms'] = (req['end_time'] - req['start_time']) * 1000
                req['status'] = status

                # Log performance
                duration = req['duration_ms']
                endpoint = req['endpoint']

                if duration > 2000:
                    logger.warning(f"Very slow request: {endpoint} took {duration:.2f}ms")
                elif duration > 1000:
                    logger.info(f"Slow request: {endpoint} took {duration:.2f}ms")

                break

    def get_stats(self):
        """Get performance statistics"""
        completed_requests = [r for r in self.requests if r.get('status') != 'in_progress']

        if not completed_requests:
            return {'total_requests': 0, 'avg_response_time': 0, 'slow_requests': 0}

        total_time = sum(r['duration_ms'] for r in completed_requests)
        avg_time = total_time / len(completed_requests)
        slow_requests = len([r for r in completed_requests if r['duration_ms'] > 1000])

        return {
            'total_requests': len(completed_requests),
            'avg_response_time': avg_time,
            'slow_requests': slow_requests,
            'recent_requests': completed_requests[-10:]  # Last 10 requests
        }

    async def get_metrics(self) -> str:
        """
        Get Prometheus format metrics
        Returns metrics in Prometheus text format for monitoring
        """
        try:
            metrics_lines = []
            
            # System metrics
            try:
                # CPU metrics
                cpu_percent = psutil.cpu_percent(interval=0.1)
                cpu_count = psutil.cpu_count()
                metrics_lines.append(f"# HELP system_cpu_usage CPU usage percentage")
                metrics_lines.append(f"# TYPE system_cpu_usage gauge")
                metrics_lines.append(f"system_cpu_usage {cpu_percent}")
                metrics_lines.append(f"# HELP system_cpu_cores Number of CPU cores")
                metrics_lines.append(f"# TYPE system_cpu_cores gauge")
                metrics_lines.append(f"system_cpu_cores {cpu_count}")
                
                # Memory metrics
                memory = psutil.virtual_memory()
                metrics_lines.append(f"# HELP system_memory_usage Memory usage percentage")
                metrics_lines.append(f"# TYPE system_memory_usage gauge")
                metrics_lines.append(f"system_memory_usage {memory.percent}")
                metrics_lines.append(f"# HELP system_memory_total_bytes Total memory in bytes")
                metrics_lines.append(f"# TYPE system_memory_total_bytes gauge")
                metrics_lines.append(f"system_memory_total_bytes {memory.total}")
                metrics_lines.append(f"# HELP system_memory_available_bytes Available memory in bytes")
                metrics_lines.append(f"# TYPE system_memory_available_bytes gauge")
                metrics_lines.append(f"system_memory_available_bytes {memory.available}")
                metrics_lines.append(f"# HELP system_memory_used_bytes Used memory in bytes")
                metrics_lines.append(f"# TYPE system_memory_used_bytes gauge")
                metrics_lines.append(f"system_memory_used_bytes {memory.used}")
                
                # Disk metrics
                disk = psutil.disk_usage('/')
                metrics_lines.append(f"# HELP system_disk_usage Disk usage percentage")
                metrics_lines.append(f"# TYPE system_disk_usage gauge")
                metrics_lines.append(f"system_disk_usage {disk.percent}")
                metrics_lines.append(f"# HELP system_disk_total_bytes Total disk space in bytes")
                metrics_lines.append(f"# TYPE system_disk_total_bytes gauge")
                metrics_lines.append(f"system_disk_total_bytes {disk.total}")
                metrics_lines.append(f"# HELP system_disk_free_bytes Free disk space in bytes")
                metrics_lines.append(f"# TYPE system_disk_free_bytes gauge")
                metrics_lines.append(f"system_disk_free_bytes {disk.free}")
                metrics_lines.append(f"# HELP system_disk_used_bytes Used disk space in bytes")
                metrics_lines.append(f"# TYPE system_disk_used_bytes gauge")
                metrics_lines.append(f"system_disk_used_bytes {disk.used}")
            except Exception as e:
                logger.warning(f"Failed to collect system metrics: {e}")
            
            # Application metrics
            stats = self.get_stats()
            metrics_lines.append(f"# HELP api_requests_total Total API requests processed")
            metrics_lines.append(f"# TYPE api_requests_total counter")
            metrics_lines.append(f"api_requests_total {stats['total_requests']}")
            metrics_lines.append(f"# HELP api_response_time_ms Average response time in milliseconds")
            metrics_lines.append(f"# TYPE api_response_time_ms gauge")
            metrics_lines.append(f"api_response_time_ms {stats['avg_response_time']:.2f}")
            metrics_lines.append(f"# HELP api_slow_requests_total Total slow requests (>1000ms)")
            metrics_lines.append(f"# TYPE api_slow_requests_total counter")
            metrics_lines.append(f"api_slow_requests_total {stats['slow_requests']}")
            
            return "\n".join(metrics_lines)
        except Exception as e:
            logger.error(f"Error generating Prometheus metrics: {e}")
            return f"# Error generating metrics: {str(e)}"


# Global performance tracker
performance_tracker = PerformanceTracker()

# Export for backward compatibility
monitoring = performance_tracker