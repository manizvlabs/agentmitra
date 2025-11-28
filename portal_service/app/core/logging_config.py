"""
Portal Logging Configuration
============================

Logging configuration for the Agent Configuration Portal.
"""

import logging
import logging.config
from typing import Optional
from pathlib import Path


def setup_logging(
    log_level: str = "INFO",
    log_file: Optional[str] = None,
    json_format: bool = False,
    environment: str = "development",
    service_name: str = "agent-portal"
) -> logging.Logger:
    """Setup logging configuration"""

    # Create logs directory if it doesn't exist
    if log_file:
        log_path = Path(log_file).parent
        log_path.mkdir(parents=True, exist_ok=True)

    # Logging configuration
    config = {
        "version": 1,
        "disable_existing_loggers": False,
        "formatters": {
            "default": {
                "format": f"[{service_name}] %(asctime)s - %(name)s - %(levelname)s - %(message)s"
            },
            "json": {
                "format": f'{{"timestamp": "%(asctime)s", "service": "{service_name}", "level": "%(levelname)s", "logger": "%(name)s", "message": "%(message)s"}}'
            }
        },
        "handlers": {
            "console": {
                "class": "logging.StreamHandler",
                "formatter": "default" if not json_format else "json",
                "level": log_level
            }
        },
        "root": {
            "handlers": ["console"],
            "level": log_level
        },
        "loggers": {
            "uvicorn": {"level": "INFO"},
            "uvicorn.error": {"level": "INFO"},
            "uvicorn.access": {"level": "INFO"},
        }
    }

    # Add file handler if log_file is specified
    if log_file:
        config["handlers"]["file"] = {
            "class": "logging.FileHandler",
            "filename": log_file,
            "formatter": "default" if not json_format else "json",
            "level": log_level
        }
        config["root"]["handlers"].append("file")

    logging.config.dictConfig(config)

    # Create and return logger
    logger = logging.getLogger(service_name)
    logger.info(f"Logging configured for {service_name} in {environment} environment")

    return logger


def get_logger(name: str) -> logging.Logger:
    """Get logger instance"""
    return logging.getLogger(name)
