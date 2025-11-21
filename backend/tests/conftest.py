"""
Test configuration and fixtures
"""
import pytest
import pytest_asyncio
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import NullPool
from app.core.config.settings import Settings
from app.core.database import Base
from app.models import *

# Test database URL
TEST_DATABASE_URL = "postgresql://agentmitra:agentmitra_dev@localhost:5432/agentmitra_test"

# Create test engine
test_engine = create_engine(
    TEST_DATABASE_URL,
    poolclass=NullPool,
    echo=False,
)

# Create test session factory
TestSessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=test_engine,
    expire_on_commit=False,
)


@pytest.fixture(scope="session")
def test_db():
    """
    Create test database schema
    """
    # Create all tables
    Base.metadata.create_all(bind=test_engine)

    yield test_engine

    # Drop all tables after tests
    Base.metadata.drop_all(bind=test_engine)


@pytest.fixture
def db_session(test_db):
    """
    Provide database session for tests
    """
    session = TestSessionLocal()
    try:
        yield session
    finally:
        session.rollback()
        session.close()


@pytest.fixture
def test_settings():
    """Provide test settings"""
    return Settings(
        database_url=TEST_DATABASE_URL,
        environment="testing",
        debug=False,
    )


@pytest.fixture
def sample_user_data():
    """Sample user data for tests"""
    return {
        "user_id": "550e8400-e29b-41d4-a716-446655440000",
        "phone_number": "+919876543210",
        "email": "test@example.com",
        "first_name": "Test",
        "last_name": "User",
        "role": "junior_agent",
        "phone_verified": True,
        "password_hash": "hashed_password",
    }


@pytest.fixture
def sample_agent_data():
    """Sample agent data for tests"""
    return {
        "agent_id": "660e8400-e29b-41d4-a716-446655440001",
        "user_id": "550e8400-e29b-41d4-a716-446655440000",
        "agent_code": "TEST001",
        "license_number": "LIC123456",
        "status": "active",
    }


@pytest.fixture
def sample_presentation_data():
    """Sample presentation data for tests"""
    return {
        "presentation_id": "770e8400-e29b-41d4-a716-446655440002",
        "agent_id": "660e8400-e29b-41d4-a716-446655440001",
        "name": "Test Presentation",
        "description": "Test presentation description",
        "status": "published",
        "is_active": True,
    }


@pytest.fixture
def sample_slide_data():
    """Sample slide data for tests"""
    return {
        "slide_id": "880e8400-e29b-41d4-a716-446655440003",
        "presentation_id": "770e8400-e29b-41d4-a716-446655440002",
        "slide_order": 1,
        "slide_type": "image",
        "media_url": "https://example.com/image.jpg",
        "title": "Test Slide",
        "subtitle": "Test subtitle",
        "text_color": "#FFFFFF",
        "background_color": "#000000",
        "layout": "centered",
        "duration": 5,
    }
