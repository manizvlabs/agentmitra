"""
Database connection and session management
Production-grade database configuration with connection pooling, health checks, and monitoring
"""
import time
from typing import Optional, Dict, Any
from contextlib import contextmanager
from sqlalchemy import create_engine, event, text
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import QueuePool, NullPool
from sqlalchemy.exc import SQLAlchemyError
from app.core.config.settings import settings
from app.core.logging_config import get_logger
from app.models.base import Base

logger = get_logger(__name__)

# Environment-specific database configuration
def get_db_config() -> Dict[str, Any]:
    """Get database configuration based on environment"""
    base_config = {
        "pool_pre_ping": True,  # Test connections before use
        "pool_recycle": 3600,   # Recycle connections after 1 hour
        "connect_args": {},
    }

    if settings.environment == "production":
        # Production configuration
        base_config.update({
            "poolclass": QueuePool,
            "pool_size": 20,          # Connection pool size
            "max_overflow": 30,       # Max additional connections
            "pool_timeout": 30,       # Connection timeout
            "pool_recycle": 1800,     # Recycle after 30 minutes in prod
            "echo": False,            # Never echo SQL in production
        })
        # SSL configuration for production
        if "sslmode" not in settings.database_url:
            base_config["connect_args"]["sslmode"] = "require"

    elif settings.environment == "staging":
        # Staging configuration
        base_config.update({
            "poolclass": QueuePool,
            "pool_size": 10,
            "max_overflow": 10,
            "pool_timeout": 20,
            "echo": False,
        })

    else:  # development
        # Development configuration
        base_config.update({
            "poolclass": NullPool,    # No pooling in dev for easier debugging
            "echo": settings.debug,   # Log SQL queries in debug mode
            "pool_recycle": 300,      # Recycle connections after 5 minutes
        })
    
    # Set schema search path for PostgreSQL
    # This ensures SQLAlchemy can find tables in the lic_schema
    if "postgresql" in settings.database_url:
        base_config["connect_args"]["options"] = "-c search_path=lic_schema,public"
        # Add connection timeout for reliability (host should come from DATABASE_URL)
        base_config["connect_args"]["connect_timeout"] = 10

    return base_config

# Create database engine with optimized configuration
engine_config = get_db_config()
logger.info(f"Creating database engine with URL: {settings.database_url}")
engine = create_engine(settings.database_url, **engine_config)

# Set schema search path after engine creation
@event.listens_for(engine, "connect", insert=True)
def set_search_path(dbapi_conn, connection_record):
    """Set PostgreSQL search path to include lic_schema"""
    with dbapi_conn.cursor() as cursor:
        cursor.execute("SET search_path TO lic_schema, public")
        dbapi_conn.commit()

# Create session factory with optimized settings
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
    expire_on_commit=False,  # Prevent unnecessary SELECT queries
)


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
    Verify database connection on startup.

    NOTE: Database schema is managed strictly through Flyway migrations.
    Do NOT use SQLAlchemy's create_all() - all tables must be created via Flyway.
    Run migrations with: flyway -configFiles=flyway.conf migrate
    """
    # Only verify connection, do not create tables
    try:
        logger.info("Attempting database connection...")
        with engine.connect() as conn:
            logger.info("Executing test query...")
            conn.execute(text("SELECT 1"))
            logger.info("Test query completed")
        logger.info("Database connection verified successfully")
    except Exception as e:
        logger.warning(f"Database connection verification failed: {e}")
        logger.warning("Continuing startup without database connection...")
        # Don't raise exception to allow startup to continue
        return False
    return True


def drop_db():
    """
    Drop all tables - use with caution!
    
    NOTE: This function is disabled. Database schema is managed strictly through Flyway migrations.
    To drop tables, use Flyway: flyway -configFiles=flyway.conf clean
    """
    raise NotImplementedError(
        "drop_db() is disabled. Database schema is managed through Flyway migrations. "
        "Use 'flyway -configFiles=flyway.conf clean' to drop tables."
    )


# Health check and monitoring functions
def check_db_connection() -> Dict[str, Any]:
    """
    Check database connection health
    Returns connection status and metrics
    """
    start_time = time.time()
    try:
        with engine.connect() as conn:
            # Execute a simple query to test connection
            result = conn.execute(text("SELECT 1 as test")).fetchone()
            response_time = time.time() - start_time

            return {
                "status": "healthy" if result[0] == 1 else "unhealthy",
                "response_time_ms": round(response_time * 1000, 2),
                "pool_size": 0,  # Pool size info not available in all environments
                "checked_at": time.time(),
            }
    except Exception as e:
        logger.error(f"Database connection check failed: {e}")
        return {
            "status": "unhealthy",
            "error": str(e),
            "checked_at": time.time(),
        }


def get_db_stats() -> Dict[str, Any]:
    """
    Get database connection pool statistics
    """
    pool = engine.pool
    stats = {
        "pool_class": pool.__class__.__name__,
        "checked_at": time.time(),
    }

    # Add pool-specific stats
    if hasattr(pool, 'size'):
        stats["pool_size"] = pool.size() if callable(pool.size) else pool.size
    if hasattr(pool, 'checkedin'):
        stats["connections_checked_in"] = pool.checkedin()
    if hasattr(pool, 'checkedout'):
        stats["connections_checked_out"] = pool.checkedout()
    if hasattr(pool, 'overflow'):
        stats["overflow_connections"] = pool.overflow()
    if hasattr(pool, 'invalid'):
        stats["invalid_connections"] = pool.invalid()

    return stats


@contextmanager
def get_db_session():
    """
    Context manager for database sessions with automatic error handling
    """
    session = SessionLocal()
    try:
        yield session
        session.commit()
    except SQLAlchemyError as e:
        logger.error(f"Database session error: {e}")
        session.rollback()
        raise
    finally:
        session.close()


def execute_with_retry(query: str, max_retries: int = 3, retry_delay: float = 0.5) -> Any:
    """
    Execute a query with retry logic for transient failures
    """
    last_error = None

    for attempt in range(max_retries):
        try:
            with engine.connect() as conn:
                result = conn.execute(text(query))
                return result.fetchall() if result.returns_rows else None
        except Exception as e:
            last_error = e
            if attempt < max_retries - 1:
                logger.warning(f"Query attempt {attempt + 1} failed, retrying: {e}")
                time.sleep(retry_delay * (2 ** attempt))  # Exponential backoff
            else:
                logger.error(f"Query failed after {max_retries} attempts: {e}")

    raise last_error


# SQLAlchemy event listeners for monitoring (only in development)
if settings.environment == "development":
    @event.listens_for(engine, "connect")
    def connect_event(connection, connection_record):
        """Log database connections"""
        logger.debug("Database connection established")

@event.listens_for(engine, "checkout")
def checkout_event(dbapi_connection, connection_record, connection_proxy):
    """Log connection checkouts"""
    logger.debug("Database connection checked out")

@event.listens_for(engine, "checkin")
def checkin_event(dbapi_connection, connection_record):
    """Log connection checkins"""
    logger.debug("Database connection checked in")

    @event.listens_for(engine, "close")
    def close_event(connection, connection_record):
        """Log connection closures"""
        logger.debug("Database connection closed")

