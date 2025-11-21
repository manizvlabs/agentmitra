"""
Repository layer tests
"""
import pytest
import uuid
from app.repositories.user_repository import UserRepository
from app.repositories.agent_repository import AgentRepository
from app.repositories.presentation_repository import PresentationRepository


class TestUserRepository:
    """Test UserRepository functionality"""

    def test_create_user(self, db_session, sample_user_data):
        """Test user creation"""
        repo = UserRepository(db_session)

        user = repo.create(sample_user_data)

        assert user.user_id is not None
        assert user.phone_number == sample_user_data["phone_number"]
        assert user.email == sample_user_data["email"]
        assert user.first_name == sample_user_data["first_name"]
        assert user.last_name == sample_user_data["last_name"]
        assert user.role == sample_user_data["role"]

    def test_get_user_by_id(self, db_session, sample_user_data):
        """Test getting user by ID"""
        repo = UserRepository(db_session)

        # Create user
        created_user = repo.create(sample_user_data)

        # Retrieve user
        retrieved_user = repo.get_by_id(created_user.user_id)

        assert retrieved_user is not None
        assert retrieved_user.user_id == created_user.user_id
        assert retrieved_user.phone_number == created_user.phone_number

    def test_get_user_by_phone(self, db_session, sample_user_data):
        """Test getting user by phone number"""
        repo = UserRepository(db_session)

        # Create user
        repo.create(sample_user_data)

        # Retrieve by phone
        retrieved_user = repo.get_by_phone(sample_user_data["phone_number"])

        assert retrieved_user is not None
        assert retrieved_user.phone_number == sample_user_data["phone_number"]

    def test_update_user(self, db_session, sample_user_data):
        """Test user update"""
        repo = UserRepository(db_session)

        # Create user
        user = repo.create(sample_user_data)

        # Update user
        update_data = {"first_name": "Updated", "last_name": "Name"}
        updated_user = repo.update(user.user_id, update_data)

        assert updated_user is not None
        assert updated_user.first_name == "Updated"
        assert updated_user.last_name == "Name"

    def test_delete_user(self, db_session, sample_user_data):
        """Test user deletion"""
        repo = UserRepository(db_session)

        # Create user
        user = repo.create(sample_user_data)

        # Delete user
        result = repo.delete(user.user_id)
        assert result is True

        # Verify user is deleted
        retrieved_user = repo.get_by_id(user.user_id)
        assert retrieved_user is None


class TestAgentRepository:
    """Test AgentRepository functionality"""

    def test_get_agent_by_id(self, db_session, sample_agent_data):
        """Test getting agent by ID"""
        repo = AgentRepository(db_session)

        # First create the user that agent references
        user_repo = UserRepository(db_session)
        user_data = {
            "user_id": sample_agent_data["user_id"],
            "phone_number": "+919876543210",
            "first_name": "Test",
            "last_name": "Agent",
            "role": "junior_agent",
        }
        user_repo.create(user_data)

        # Create agent
        from app.models.agent import Agent
        agent = Agent(**sample_agent_data)
        db_session.add(agent)
        db_session.commit()

        # Retrieve agent
        retrieved_agent = repo.get_by_id(sample_agent_data["agent_id"])

        assert retrieved_agent is not None
        assert retrieved_agent.agent_id == sample_agent_data["agent_id"]
        assert retrieved_agent.agent_code == sample_agent_data["agent_code"]

    def test_get_agent_by_agent_code(self, db_session, sample_agent_data):
        """Test getting agent by agent code"""
        repo = AgentRepository(db_session)

        # Create agent record
        from app.models.agent import Agent
        agent = Agent(**sample_agent_data)
        db_session.add(agent)
        db_session.commit()

        # Retrieve by agent code
        retrieved_agent = repo.get_by_agent_code(sample_agent_data["agent_code"])

        assert retrieved_agent is not None
        assert retrieved_agent.agent_code == sample_agent_data["agent_code"]


class TestPresentationRepository:
    """Test PresentationRepository functionality"""

    def test_create_presentation(self, db_session, sample_presentation_data, sample_agent_data):
        """Test presentation creation"""
        repo = PresentationRepository(db_session)

        # Create agent first
        from app.models.agent import Agent
        agent = Agent(**sample_agent_data)
        db_session.add(agent)
        db_session.commit()

        # Create presentation
        presentation = repo.create(sample_presentation_data)

        assert presentation.presentation_id is not None
        assert presentation.name == sample_presentation_data["name"]
        assert presentation.status == sample_presentation_data["status"]
        assert presentation.is_active == sample_presentation_data["is_active"]

    def test_get_presentation_by_id(self, db_session, sample_presentation_data, sample_agent_data):
        """Test getting presentation by ID"""
        repo = PresentationRepository(db_session)

        # Create agent first
        from app.models.agent import Agent
        agent = Agent(**sample_agent_data)
        db_session.add(agent)
        db_session.commit()

        # Create presentation
        created_presentation = repo.create(sample_presentation_data)

        # Retrieve presentation
        retrieved_presentation = repo.get_by_id(created_presentation.presentation_id)

        assert retrieved_presentation is not None
        assert retrieved_presentation.presentation_id == created_presentation.presentation_id
        assert retrieved_presentation.name == created_presentation.name

    def test_get_active_presentation_by_agent(self, db_session, sample_presentation_data, sample_agent_data):
        """Test getting active presentation for agent"""
        repo = PresentationRepository(db_session)

        # Create agent first
        from app.models.agent import Agent
        agent = Agent(**sample_agent_data)
        db_session.add(agent)
        db_session.commit()

        # Create presentation
        repo.create(sample_presentation_data)

        # Get active presentation
        active_presentation = repo.get_active_by_agent(sample_agent_data["agent_id"])

        assert active_presentation is not None
        assert active_presentation.is_active is True
        assert active_presentation.status == "published"

    def test_get_presentations_by_agent(self, db_session, sample_presentation_data, sample_agent_data):
        """Test getting all presentations for agent"""
        repo = PresentationRepository(db_session)

        # Create agent first
        from app.models.agent import Agent
        agent = Agent(**sample_agent_data)
        db_session.add(agent)
        db_session.commit()

        # Create multiple presentations
        presentation_data_2 = sample_presentation_data.copy()
        presentation_data_2["presentation_id"] = str(uuid.uuid4())
        presentation_data_2["name"] = "Second Presentation"
        presentation_data_2["status"] = "draft"

        repo.create(sample_presentation_data)
        repo.create(presentation_data_2)

        # Get all presentations
        presentations, total = repo.get_by_agent(sample_agent_data["agent_id"])

        assert total == 2
        assert len(presentations) == 2
        assert presentations[0].status in ["published", "draft"]
        assert presentations[1].status in ["published", "draft"]


class TestRepositoryPerformance:
    """Test repository performance"""

    def test_bulk_user_creation_performance(self, db_session):
        """Test performance of bulk user creation"""
        import time
        repo = UserRepository(db_session)

        # Create multiple users
        user_count = 10
        start_time = time.time()

        for i in range(user_count):
            user_data = {
                "phone_number": f"+91987654321{i}",
                "first_name": f"User{i}",
                "last_name": "Test",
                "role": "policyholder",
            }
            repo.create(user_data)

        end_time = time.time()
        total_time = end_time - start_time

        # Should complete in reasonable time
        assert total_time < 2.0  # Less than 2 seconds for 10 users

        # Verify users were created
        users = db_session.query("SELECT COUNT(*) FROM lic_schema.users").fetchone()
        assert users[0] >= user_count

    def test_query_performance(self, db_session, sample_user_data):
        """Test query performance"""
        import time
        repo = UserRepository(db_session)

        # Create user
        user = repo.create(sample_user_data)

        # Test multiple queries
        query_count = 100
        start_time = time.time()

        for _ in range(query_count):
            retrieved_user = repo.get_by_id(user.user_id)
            assert retrieved_user is not None

        end_time = time.time()
        total_time = end_time - start_time

        # Performance check
        avg_time_per_query = total_time / query_count
        assert avg_time_per_query < 0.001  # Less than 1ms per query
