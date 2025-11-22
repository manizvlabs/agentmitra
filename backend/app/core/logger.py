"""
Logger module for the application
"""
import logging
from .logging_config import get_logger

# Create the main application logger
logger = get_logger(__name__)
