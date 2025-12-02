"""
Campaign API Endpoints Tests
Tests all campaign endpoints with real database queries
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
from uuid import uuid4, UUID
import json
from datetime import datetime, timedelta

# Import app lazily to avoid import issues
from app.core.database import get_db
from app.models.user import User
from app.models.agent import Agent
from app.models.campaign import Campaign, CampaignTemplate, CampaignExecution, CampaignResponse
from app.models.policy import Policyholder
from app.core.security import create_access_token


# Test client fixture
@pytest.fixture
def client(db_session):
    """Test client with database session"""
    # Import app here to avoid circular imports
    from app.main import app

    def override_get_db():
        try:
            yield db_session
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client


# Test data fixtures
@pytest.fixture
def test_user(db_session):
    """Create test user"""
    user = User(
        user_id=uuid4(),
        phone_number="+919876543210",
        email="test@example.com",
        first_name="Test",
        last_name="User",
        role="junior_agent",
        phone_verified=True,
        password_hash="hashed_password"
    )
    db_session.add(user)
    db_session.commit()
    return user


@pytest.fixture
def test_agent(db_session, test_user):
    """Create test agent"""
    agent = Agent(
        agent_id=uuid4(),
        user_id=test_user.user_id,
        agent_code="TEST001",
        license_number="LIC123456",
        status="active",
        business_name="Test Insurance Agency",
        business_address="123 Test Street"
    )
    db_session.add(agent)
    db_session.commit()
    return agent


@pytest.fixture
def test_policyholder(db_session, test_agent):
    """Create test policyholder"""
    policyholder = Policyholder(
        policyholder_id=uuid4(),
        agent_id=test_agent.agent_id,
        first_name="John",
        last_name="Doe",
        phone_number="+919876543211",
        email="john.doe@example.com",
        date_of_birth=datetime(1990, 1, 1),
        address="456 Customer Street",
        status="active"
    )
    db_session.add(policyholder)
    db_session.commit()
    return policyholder


@pytest.fixture
def test_campaign_template(db_session, test_user):
    """Create test campaign template"""
    template = CampaignTemplate(
        template_id=uuid4(),
        template_name="Test Template",
        description="Test campaign template",
        category="acquisition",
        subject_template="Welcome {{customer_name}}!",
        message_template="Dear {{customer_name}}, welcome to our service!",
        personalization_tags=["{{customer_name}}"],
        suggested_channels=["whatsapp"],
        is_public=True,
        is_system_template=False,
        created_by=test_user.user_id
    )
    db_session.add(template)
    db_session.commit()
    return template


@pytest.fixture
def test_campaign(db_session, test_agent, test_user):
    """Create test campaign"""
    campaign = Campaign(
        campaign_id=uuid4(),
        agent_id=test_agent.agent_id,
        campaign_name="Test Campaign",
        campaign_type="acquisition",
        campaign_goal="lead_generation",
        description="Test campaign description",
        subject="Test Subject",
        message="Test message content",
        primary_channel="whatsapp",
        channels=["whatsapp"],
        target_audience="all",
        status="draft",
        budget=1000.00,
        estimated_cost=800.00,
        created_by=test_user.user_id
    )
    db_session.add(campaign)
    db_session.commit()
    return campaign


@pytest.fixture
def test_active_campaign(db_session, test_agent, test_user):
    """Create test active campaign"""
    campaign = Campaign(
        campaign_id=uuid4(),
        agent_id=test_agent.agent_id,
        campaign_name="Active Test Campaign",
        campaign_type="retention",
        campaign_goal="renewal_rate",
        description="Active test campaign",
        subject="Renewal Reminder",
        message="Don't forget to renew your policy",
        primary_channel="whatsapp",
        channels=["whatsapp"],
        target_audience="all",
        status="active",
        budget=2000.00,
        estimated_cost=1600.00,
        launched_at=datetime.utcnow(),
        created_by=test_user.user_id
    )
    db_session.add(campaign)
    db_session.commit()
    return campaign


@pytest.fixture
def auth_headers(test_user):
    """Create authentication headers"""
    token = create_access_token({"user_id": str(test_user.user_id), "agent_id": str(uuid4())})
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture
def auth_headers_with_agent(test_user, test_agent):
    """Create authentication headers with agent context"""
    token = create_access_token({
        "user_id": str(test_user.user_id),
        "agent_id": str(test_agent.agent_id)
    })
    return {"Authorization": f"Bearer {token}"}


class TestCampaignEndpoints:
    """Test suite for campaign endpoints"""

    def test_create_campaign_success(self, client, auth_headers_with_agent, test_agent):
        """Test creating a campaign successfully"""
        campaign_data = {
            "campaign_name": "New Test Campaign",
            "campaign_type": "acquisition",
            "campaign_goal": "lead_generation",
            "description": "Test campaign for new leads",
            "subject": "Welcome to our service!",
            "message": "Dear {{customer_name}}, welcome to our insurance service.",
            "message_template_id": None,
            "personalization_tags": ["{{customer_name}}"],
            "attachments": None,
            "primary_channel": "whatsapp",
            "channels": ["whatsapp"],
            "target_audience": "all",
            "selected_segments": [],
            "targeting_rules": None,
            "estimated_reach": 100,
            "schedule_type": "immediate",
            "scheduled_at": None,
            "start_date": None,
            "end_date": None,
            "is_automated": False,
            "automation_triggers": None,
            "budget": 1500.00,
            "estimated_cost": 1200.00,
            "ab_testing_enabled": False,
            "ab_test_variants": None,
            "triggers": []
        }

        response = client.post(
            "/api/v1/campaigns",
            json=campaign_data,
            headers=auth_headers_with_agent
        )

        assert response.status_code == 201
        data = response.json()
        assert data["success"] == True
        assert "campaign_id" in data["data"]
        assert data["data"]["campaign_name"] == "New Test Campaign"
        assert data["data"]["status"] == "draft"

    def test_create_campaign_unauthorized_no_agent(self, client, auth_headers):
        """Test creating campaign without agent association fails"""
        campaign_data = {
            "campaign_name": "Test Campaign",
            "campaign_type": "acquisition",
            "message": "Test message"
        }

        response = client.post(
            "/api/v1/campaigns",
            json=campaign_data,
            headers=auth_headers
        )

        assert response.status_code == 403
        data = response.json()
        assert "not associated with an agent" in data["detail"]

    def test_list_campaigns_success(self, client, auth_headers_with_agent, test_campaign):
        """Test listing campaigns successfully"""
        response = client.get(
            "/api/v1/campaigns",
            headers=auth_headers_with_agent
        )

        assert response.status_code == 200
        data = response.json()
        assert data["success"] == True
        assert len(data["data"]) >= 1
        assert data["total"] >= 1

        # Check campaign data structure
        campaign_data = data["data"][0]
        assert "campaign_id" in campaign_data
        assert "campaign_name" in campaign_data
        assert "campaign_type" in campaign_data
        assert "status" in campaign_data

    def test_list_campaigns_with_filters(self, client, auth_headers_with_agent, test_campaign, test_active_campaign):
        """Test listing campaigns with status filter"""
        # Filter by status=draft
        response = client.get(
            "/api/v1/campaigns?status=draft",
            headers=auth_headers_with_agent
        )

        assert response.status_code == 200
        data = response.json()
        assert data["success"] == True
        # Should find the draft campaign
        draft_campaigns = [c for c in data["data"] if c["status"] == "draft"]
        assert len(draft_campaigns) >= 1

    def test_get_campaign_templates_success(self, client, test_campaign_template):
        """Test getting campaign templates successfully"""
        response = client.get("/api/v1/campaigns/templates")

        assert response.status_code == 200
        data = response.json()
        assert data["success"] == True
        assert len(data["data"]) >= 1

        # Check template structure
        template = data["data"][0]
        assert "template_id" in template
        assert "template_name" in template
        assert "category" in template
        assert "personalization_tags" in template

    def test_get_campaign_templates_with_category_filter(self, client, test_campaign_template):
        """Test getting campaign templates with category filter"""
        response = client.get("/api/v1/campaigns/templates?category=acquisition")

        assert response.status_code == 200
        data = response.json()
        assert data["success"] == True
        # Should find the acquisition template
        acquisition_templates = [t for t in data["data"] if t["category"] == "acquisition"]
        assert len(acquisition_templates) >= 1

    def test_get_campaign_details_success(self, client, auth_headers_with_agent, test_campaign):
        """Test getting campaign details successfully"""
        response = client.get(
            f"/api/v1/campaigns/{test_campaign.campaign_id}",
            headers=auth_headers_with_agent
        )

        assert response.status_code == 200
        data = response.json()
        assert data["success"] == True
        campaign_data = data["data"]
        assert campaign_data["campaign_id"] == str(test_campaign.campaign_id)
        assert campaign_data["campaign_name"] == test_campaign.campaign_name
        assert campaign_data["campaign_type"] == test_campaign.campaign_type
        assert campaign_data["status"] == test_campaign.status

    def test_get_campaign_details_not_found(self, client, auth_headers_with_agent):
        """Test getting non-existent campaign returns 404"""
        fake_id = str(uuid4())
        response = client.get(
            f"/api/v1/campaigns/{fake_id}",
            headers=auth_headers_with_agent
        )

        assert response.status_code == 404
        data = response.json()
        assert "Campaign not found" in data["detail"]

    def test_update_campaign_success(self, client, auth_headers_with_agent, test_campaign):
        """Test updating campaign successfully"""
        update_data = {
            "campaign_name": "Updated Campaign Name",
            "description": "Updated description",
            "budget": 2500.00
        }

        response = client.put(
            f"/api/v1/campaigns/{test_campaign.campaign_id}",
            json=update_data,
            headers=auth_headers_with_agent
        )

        assert response.status_code == 200
        data = response.json()
        assert data["success"] == True
        assert data["data"]["campaign_id"] == str(test_campaign.campaign_id)
        assert data["message"] == "Campaign updated successfully"

    def test_update_campaign_not_found(self, client, auth_headers_with_agent):
        """Test updating non-existent campaign returns 404"""
        fake_id = str(uuid4())
        update_data = {"campaign_name": "Updated Name"}

        response = client.put(
            f"/api/v1/campaigns/{fake_id}",
            json=update_data,
            headers=auth_headers_with_agent
        )

        assert response.status_code == 404
        data = response.json()
        assert "Campaign not found" in data["detail"]

    def test_launch_campaign_success(self, client, auth_headers_with_agent, test_campaign):
        """Test launching campaign successfully"""
        response = client.post(
            f"/api/v1/campaigns/{test_campaign.campaign_id}/launch",
            headers=auth_headers_with_agent
        )

        assert response.status_code == 200
        data = response.json()
        assert data["success"] == True
        assert data["data"]["campaign_id"] == str(test_campaign.campaign_id)
        assert data["data"]["status"] == "active"
        assert "launched_at" in data["data"]

    def test_launch_campaign_invalid_status(self, client, auth_headers_with_agent, test_active_campaign):
        """Test launching already active campaign fails"""
        response = client.post(
            f"/api/v1/campaigns/{test_active_campaign.campaign_id}/launch",
            headers=auth_headers_with_agent
        )

        assert response.status_code == 400
        data = response.json()
        assert "Cannot launch campaign with status" in data["detail"]

    def test_get_campaign_analytics_success(self, client, auth_headers_with_agent, test_active_campaign, db_session, test_policyholder):
        """Test getting campaign analytics successfully"""
        # Create some campaign executions for analytics
        execution = CampaignExecution(
            execution_id=uuid4(),
            campaign_id=test_active_campaign.campaign_id,
            policyholder_id=test_policyholder.policyholder_id,
            channel="whatsapp",
            personalized_content={"message": "Test message"},
            sent_at=datetime.utcnow(),
            delivered_at=datetime.utcnow(),
            opened_at=datetime.utcnow(),
            status="opened"
        )
        db_session.add(execution)
        db_session.commit()

        # Update campaign metrics
        test_active_campaign.total_sent = 1
        test_active_campaign.total_delivered = 1
        test_active_campaign.total_opened = 1
        test_active_campaign.total_clicked = 0
        test_active_campaign.total_converted = 0
        db_session.commit()

        response = client.get(
            f"/api/v1/campaigns/{test_active_campaign.campaign_id}/analytics",
            headers=auth_headers_with_agent
        )

        assert response.status_code == 200
        data = response.json()
        assert data["success"] == True
        analytics = data["data"]
        assert "total_sent" in analytics
        assert "total_delivered" in analytics
        assert "delivery_rate" in analytics
        assert "open_rate" in analytics
        assert "channel_breakdown" in analytics

    def test_create_campaign_from_template_success(self, client, auth_headers_with_agent, test_campaign_template):
        """Test creating campaign from template successfully"""
        campaign_data = {
            "campaign_name": "Campaign from Template",
            "campaign_type": "acquisition",
            "message": "Custom message content"
        }

        response = client.post(
            f"/api/v1/campaigns/templates/{test_campaign_template.template_id}/create",
            json=campaign_data,
            headers=auth_headers_with_agent
        )

        assert response.status_code == 200
        data = response.json()
        assert data["success"] == True
        assert "campaign_id" in data["data"]
        assert data["data"]["campaign_name"] == "Campaign from Template"

    def test_create_campaign_from_template_not_found(self, client, auth_headers_with_agent):
        """Test creating campaign from non-existent template fails"""
        fake_id = str(uuid4())
        campaign_data = {
            "campaign_name": "Test Campaign",
            "campaign_type": "acquisition",
            "message": "Test message"
        }

        response = client.post(
            f"/api/v1/campaigns/templates/{fake_id}/create",
            json=campaign_data,
            headers=auth_headers_with_agent
        )

        assert response.status_code == 404
        data = response.json()
        assert "Template not found" in data["detail"]

    def test_get_campaign_recommendations_success(self, client, auth_headers_with_agent):
        """Test getting campaign recommendations successfully"""
        response = client.get(
            "/api/v1/campaigns/recommendations",
            headers=auth_headers_with_agent
        )

        assert response.status_code == 200
        data = response.json()
        assert data["success"] == True
        assert isinstance(data["data"], list)

    def test_get_campaign_recommendations_unauthorized(self, client, auth_headers):
        """Test getting recommendations without agent fails"""
        response = client.get(
            "/api/v1/campaigns/recommendations",
            headers=auth_headers
        )

        assert response.status_code == 403
        data = response.json()
        assert "not associated with an agent" in data["detail"]


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
