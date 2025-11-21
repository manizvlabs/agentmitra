"""
Database connection and session management
"""
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import NullPool
from app.core.config.settings import settings
from app.models.base import Base

# Create database engine
engine = create_engine(
    settings.database_url,
    poolclass=NullPool,  # Use NullPool for development, switch to QueuePool for production
    echo=settings.debug,  # Log SQL queries in debug mode
)

# Create session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db():
    """
    Dependency function to get database session
    Use this in FastAPI route dependencies
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db():
    """
    Initialize database - create all tables
    Call this on application startup
    """
    Base.metadata.create_all(bind=engine)


def drop_db():
    """
    Drop all tables - use with caution!
    """
    Base.metadata.drop_all(bind=engine)

