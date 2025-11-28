"""
Portal Service Database Connection
===================================

Database connection and session management for the portal service.
Shares the same database as the main API service.
"""

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import QueuePool

from app.core.config.settings import settings


# Create engine with connection pooling
engine = create_engine(
    settings.database_url,
    poolclass=QueuePool,
    pool_size=5,  # Smaller pool for portal service
    max_overflow=10,
    pool_timeout=30,
    pool_recycle=3600,
    echo=settings.debug,
    future=True
)

# Create session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db() -> Session:
    """Get database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db():
    """Initialize database connection"""
    try:
        # Test connection
        with engine.connect() as conn:
            conn.execute("SELECT 1")
        print("✅ Portal database connection established")
    except Exception as e:
        print(f"❌ Portal database connection failed: {e}")
        raise


def check_db_connection():
    """Check database connectivity"""
    try:
        with engine.connect() as conn:
            result = conn.execute("SELECT 1 as test")
            return {"status": "healthy", "message": "Database connection successful"}
    except Exception as e:
        return {"status": "unhealthy", "error": str(e)}
