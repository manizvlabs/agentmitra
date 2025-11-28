"""
Logging Configuration
Structured logging setup for the application with correlation IDs
"""
import logging
import sys
from logging.handlers import RotatingFileHandler
from pathlib import Path
import json
import uuid
from datetime import datetime
from typing import Any, Dict, Optional

from app.core.config.settings import settings


class StructuredJSONFormatter(logging.Formatter):
    """Enhanced JSON formatter for structured logging with correlation IDs"""

    def __init__(self, service_name: str = "agent-mitra"):
        super().__init__()
        self.service_name = service_name

    def format(self, record: logging.LogRecord) -> str:
        log_data: Dict[str, Any] = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "service": self.service_name,
            "version": getattr(settings, 'app_version', '1.0.0'),
            "environment": getattr(settings, 'environment', 'development'),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno,
        }

        # Add exception info if present
        if record.exc_info:
            log_data["exception"] = self.formatException(record.exc_info)

        # Add correlation and context fields
        if hasattr(record, "request_id"):
            log_data["request_id"] = record.request_id
        if hasattr(record, "correlation_id"):
            log_data["correlation_id"] = record.correlation_id
        if hasattr(record, "user_id"):
            log_data["user_id"] = record.user_id
        if hasattr(record, "tenant_id"):
            log_data["tenant_id"] = record.tenant_id
        if hasattr(record, "session_id"):
            log_data["session_id"] = record.session_id
        if hasattr(record, "duration_ms"):
            log_data["duration_ms"] = record.duration_ms
        if hasattr(record, "status_code"):
            log_data["status_code"] = record.status_code
        if hasattr(record, "user_agent"):
            log_data["user_agent"] = record.user_agent
        if hasattr(record, "ip_address"):
            log_data["ip_address"] = record.ip_address
        if hasattr(record, "endpoint"):
            log_data["endpoint"] = record.endpoint
        if hasattr(record, "method"):
            log_data["method"] = record.method

        # Add business context
        if hasattr(record, "policy_id"):
            log_data["policy_id"] = record.policy_id
        if hasattr(record, "agent_id"):
            log_data["agent_id"] = record.agent_id
        if hasattr(record, "customer_id"):
            log_data["customer_id"] = record.customer_id
        if hasattr(record, "payment_id"):
            log_data["payment_id"] = record.payment_id

        return json.dumps(log_data, default=str)


class RequestLogger:
    """Request logging middleware with correlation IDs"""

    def __init__(self, logger: logging.Logger):
        self.logger = logger

    async def log_request(self, request, response=None, error=None, **context):
        """Log HTTP request/response with correlation ID"""

        # Generate correlation ID if not present
        correlation_id = context.get('correlation_id', str(uuid.uuid4()))

        log_data = {
            "correlation_id": correlation_id,
            "method": request.method,
            "url": str(request.url),
            "client_ip": getattr(request.client, 'host', None) if request.client else None,
            "user_agent": request.headers.get('user-agent'),
            "request_id": request.headers.get('x-request-id'),
        }

        # Add context data
        log_data.update(context)

        if response:
            log_data.update({
                "status_code": response.status_code,
                "response_time": getattr(response, 'process_time', None),
                "content_length": response.headers.get('content-length')
            })

            if response.status_code >= 400:
                self.logger.warning("HTTP Request failed", extra=log_data)
            else:
                self.logger.info("HTTP Request completed", extra=log_data)

        elif error:
            log_data.update({
                "error": str(error),
                "error_type": type(error).__name__
            })
            self.logger.error("HTTP Request error", extra=log_data)
        else:
            self.logger.info("HTTP Request started", extra=log_data)


class ColoredFormatter(logging.Formatter):
    """Colored formatter for console output"""
    
    COLORS = {
        'DEBUG': '\033[36m',      # Cyan
        'INFO': '\033[32m',       # Green
        'WARNING': '\033[33m',    # Yellow
        'ERROR': '\033[31m',      # Red
        'CRITICAL': '\033[35m',   # Magenta
    }
    RESET = '\033[0m'
    
    def format(self, record: logging.LogRecord) -> str:
        log_color = self.COLORS.get(record.levelname, self.RESET)
        record.levelname = f"{log_color}{record.levelname}{self.RESET}"
        return super().format(record)


def setup_logging(
    log_level: str = "INFO",
    log_file: Optional[str] = None,
    json_format: bool = False,
    environment: str = "development",
    service_name: str = "agent-mitra"
):
    """
    Setup application logging
    
    Args:
        log_level: Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
        log_file: Path to log file (optional)
        json_format: Use JSON format for logs
        environment: Environment name (development, staging, production)
    """
    # Create logs directory if it doesn't exist
    if log_file:
        log_path = Path(log_file)
        log_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Get root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(getattr(logging, log_level.upper()))
    
    # Remove existing handlers
    root_logger.handlers.clear()
    
    # Console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(getattr(logging, log_level.upper()))
    
    if json_format or environment == "production":
        console_formatter = StructuredJSONFormatter(service_name)
    else:
        console_formatter = ColoredFormatter(
            fmt='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )

    console_handler.setFormatter(console_formatter)
    root_logger.addHandler(console_handler)

    # File handler (if log_file specified)
    if log_file:
        file_handler = RotatingFileHandler(
            log_file,
            maxBytes=10 * 1024 * 1024,  # 10MB
            backupCount=5
        )
        file_handler.setLevel(logging.DEBUG)  # Always log everything to file
        file_formatter = StructuredJSONFormatter(service_name)
        file_handler.setFormatter(file_formatter)
        root_logger.addHandler(file_handler)

    # Set levels for third-party loggers
    logging.getLogger("uvicorn").setLevel(logging.INFO)
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
    logging.getLogger("sqlalchemy.engine").setLevel(logging.WARNING)
    logging.getLogger("httpx").setLevel(logging.WARNING)
    logging.getLogger("celery").setLevel(logging.INFO)
    logging.getLogger("redis").setLevel(logging.WARNING)


def get_logger(name: str) -> logging.Logger:
    """
    Get a logger instance
    
    Args:
        name: Logger name (usually __name__)
        
    Returns:
        Logger instance
    """
    return logging.getLogger(name)

