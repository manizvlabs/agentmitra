"""
Celery Worker Configuration
===========================

This module configures and runs the Celery worker for background task processing.
"""

import os
from app.core.tasks import celery_app

if __name__ == '__main__':
    # Set environment for worker
    os.environ.setdefault('ENVIRONMENT', 'production')

    # Start the Celery worker
    celery_app.start()
