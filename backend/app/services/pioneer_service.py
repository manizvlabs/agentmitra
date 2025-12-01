"""
Pioneer Service
Simple service for checking Pioneer feature flags
"""

import logging
import os
from pathlib import Path
from typing import Any, Optional
from sqlalchemy.orm import Session
from dotenv import load_dotenv

from app.core.logging_config import get_logger

logger = get_logger(__name__)

# Load environment variables from project root .env file
PROJECT_ROOT = Path(__file__).parent.parent.parent.parent
env_file = PROJECT_ROOT / ".env"
if env_file.exists():
    load_dotenv(env_file, override=True)


class PioneerService:
    """Simple Pioneer service for feature flag checking"""

    def __init__(self):
        pass

    async def get_flag_value(self, flag_name: str, default: Any = False) -> Any:
        """
        Get feature flag value from Pioneer or environment variables
        For now, check environment variables. In production, this should connect to Pioneer Compass API.
        """
        try:
            import os

            # Check environment variables first (for local development)
            env_var = f"PIONEER_FLAG_{flag_name.upper()}"
            env_value = os.getenv(env_var)

            logger.info(f"Checking flag {flag_name}, env_var {env_var}, env_value: {env_value}")

            if env_value is not None:
                # Convert string to boolean
                if env_value.lower() in ('true', '1', 'yes', 'on'):
                    logger.info(f"Flag {flag_name} set to True from env var")
                    return True
                elif env_value.lower() in ('false', '0', 'no', 'off'):
                    logger.info(f"Flag {flag_name} set to False from env var")
                    return False
                else:
                    logger.info(f"Flag {flag_name} returning string value: {env_value}")
                    return env_value  # Return as string if not boolean

            logger.info(f"No env var found for {flag_name}, using default: {default}")

            # Hardcoded defaults for specific flags (only if no env var found)
            if flag_name == "mock_otp_enabled":
                return False  # Disable mock OTP by default (only enable via env var)

            # Return default value for other flags
            return default

        except Exception as e:
            logger.error(f"Error getting flag {flag_name}: {e}")
            return default
