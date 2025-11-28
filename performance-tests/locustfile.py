"""
Agent Mitra Load Testing with Locust
Tests API endpoints under various load conditions
"""

import json
import time
from locust import HttpUser, task, between, constant, constant_pacing, SequentialTaskSet
from locust.exception import StopUser
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Test data
USERS = [
    {"phone": "9876543200", "password": "testpassword", "role": "super_admin"},
    {"phone": "9876543201", "password": "testpassword", "role": "provider_admin"},
    {"phone": "9876543202", "password": "testpassword", "role": "regional_manager"},
    {"phone": "9876543203", "password": "testpassword", "role": "senior_agent"},
    {"phone": "9876543204", "password": "testpassword", "role": "junior_agent"},
    {"phone": "9876543205", "password": "testpassword", "role": "policyholder"},
    {"phone": "9876543206", "password": "testpassword", "role": "support_staff"},
]

class AuthenticatedUser(HttpUser):
    """Base class for authenticated users with JWT tokens"""

    # Different user types have different think times
    wait_time = between(1, 3)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.token = None
        self.user_data = None

    def on_start(self):
        """Login and get JWT token when user starts"""
        self.login()

    def login(self):
        """Authenticate and get JWT token"""
        try:
            # Cycle through different user types for realistic load testing
            user_index = getattr(self, 'user_index', 0) % len(USERS)
            self.user_data = USERS[user_index]
            setattr(self, 'user_index', user_index + 1)

            response = self.client.post("/api/v1/auth/login", json={
                "phone_number": self.user_data["phone"],
                "password": self.user_data["password"]
            })

            if response.status_code == 200:
                data = response.json()
                self.token = data.get("access_token")
                if self.token:
                    self.client.headers.update({"Authorization": f"Bearer {self.token}"})
                    logger.info(f"User {self.user_data['phone']} ({self.user_data['role']}) logged in successfully")
                else:
                    logger.error(f"Login failed for {self.user_data['phone']}: No token received")
                    raise StopUser()
            else:
                logger.error(f"Login failed for {self.user_data['phone']}: {response.status_code} - {response.text}")
                raise StopUser()

        except Exception as e:
            logger.error(f"Login error for user: {e}")
            raise StopUser()


class SuperAdminUser(AuthenticatedUser):
    """Load testing for Super Admin users"""

    weight = 1  # Only 1 super admin
    wait_time = between(2, 5)  # Slower, more thoughtful actions

    @task(30)
    def get_dashboard_kpis(self):
        """Test comprehensive dashboard KPIs"""
        with self.client.get("/api/v1/analytics/comprehensive/dashboard",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Dashboard KPIs failed: {response.status_code}")

    @task(20)
    def list_all_users(self):
        """Test user management - list all users"""
        with self.client.get("/api/v1/users/",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"List users failed: {response.status_code}")

    @task(15)
    def get_system_health(self):
        """Test system health endpoint"""
        with self.client.get("/health",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Health check failed: {response.status_code}")

    @task(10)
    def manage_feature_flags(self):
        """Test feature flag management"""
        with self.client.get("/api/v1/feature-flags/all",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Feature flags failed: {response.status_code}")


class ProviderAdminUser(AuthenticatedUser):
    """Load testing for Insurance Provider Admin users"""

    weight = 2  # 2 provider admins
    wait_time = between(1, 3)

    @task(40)
    def get_dashboard_kpis(self):
        """Test dashboard KPIs"""
        with self.client.get("/api/v1/analytics/comprehensive/dashboard",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Dashboard KPIs failed: {response.status_code}")

    @task(25)
    def manage_agents(self):
        """Test agent management"""
        with self.client.get("/api/v1/agents/",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Agent management failed: {response.status_code}")

    @task(20)
    def manage_policies(self):
        """Test policy management"""
        with self.client.get("/api/v1/policies/",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Policy management failed: {response.status_code}")

    @task(15)
    def get_reports(self):
        """Test report generation"""
        with self.client.get("/api/v1/analytics/comprehensive/dashboard",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Reports failed: {response.status_code}")


class RegionalManagerUser(AuthenticatedUser):
    """Load testing for Regional Manager users"""

    weight = 3  # 3 regional managers
    wait_time = between(1, 2)

    @task(50)
    def get_team_performance(self):
        """Test team performance analytics"""
        with self.client.get("/api/v1/analytics/comprehensive/dashboard",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Team performance failed: {response.status_code}")

    @task(30)
    def manage_agents(self):
        """Test agent oversight"""
        with self.client.get("/api/v1/agents/",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Agent oversight failed: {response.status_code}")

    @task(20)
    def review_policies(self):
        """Test policy reviews"""
        with self.client.get("/api/v1/policies/",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Policy review failed: {response.status_code}")


class SeniorAgentUser(AuthenticatedUser):
    """Load testing for Senior Agent users"""

    weight = 10  # 10 senior agents - most active users
    wait_time = between(0.5, 2)

    @task(40)
    def get_my_dashboard(self):
        """Test personal dashboard"""
        with self.client.get("/api/v1/users/me",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Personal dashboard failed: {response.status_code}")

    @task(30)
    def manage_customers(self):
        """Test customer management"""
        with self.client.get("/api/v1/policies/",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Customer management failed: {response.status_code}")

    @task(20)
    def create_policies(self):
        """Test policy creation"""
        # Note: In real load testing, you'd create actual policies
        # For now, just test the endpoint accessibility
        with self.client.get("/api/v1/policies/",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Policy creation check failed: {response.status_code}")

    @task(10)
    def get_analytics(self):
        """Test personal analytics"""
        with self.client.get("/api/v1/analytics/comprehensive/dashboard",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Analytics failed: {response.status_code}")


class JuniorAgentUser(AuthenticatedUser):
    """Load testing for Junior Agent users"""

    weight = 20  # 20 junior agents - bulk of users
    wait_time = between(0.5, 1.5)

    @task(60)
    def get_my_profile(self):
        """Test profile access - most common action"""
        with self.client.get("/api/v1/users/me",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Profile access failed: {response.status_code}")

    @task(25)
    def browse_policies(self):
        """Test policy browsing"""
        with self.client.get("/api/v1/policies/",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Policy browsing failed: {response.status_code}")

    @task(15)
    def check_analytics(self):
        """Test basic analytics access"""
        with self.client.get("/api/v1/analytics/comprehensive/dashboard",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Analytics access failed: {response.status_code}")


class PolicyholderUser(AuthenticatedUser):
    """Load testing for Policyholder/Customer users"""

    weight = 50  # 50 customers - largest user group
    wait_time = between(1, 4)  # More varied behavior

    @task(70)
    def get_my_profile(self):
        """Test profile access - most common for customers"""
        with self.client.get("/api/v1/users/me",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Profile access failed: {response.status_code}")

    @task(20)
    def check_my_policies(self):
        """Test policy viewing"""
        with self.client.get("/api/v1/policies/",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Policy viewing failed: {response.status_code}")

    @task(10)
    def access_payments(self):
        """Test payment access"""
        # Note: Would need actual policy IDs for real payment testing
        with self.client.get("/api/v1/policies/",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Payment access failed: {response.status_code}")


class SupportStaffUser(AuthenticatedUser):
    """Load testing for Support Staff users"""

    weight = 5  # 5 support staff
    wait_time = between(1, 3)

    @task(40)
    def browse_tickets(self):
        """Test ticket browsing (support tickets)"""
        # Note: Using policies as proxy for tickets in this test
        with self.client.get("/api/v1/policies/",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Ticket browsing failed: {response.status_code}")

    @task(30)
    def check_customer_data(self):
        """Test customer data access"""
        with self.client.get("/api/v1/policies/",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Customer data access failed: {response.status_code}")

    @task(20)
    def get_reports(self):
        """Test report access"""
        with self.client.get("/api/v1/analytics/comprehensive/dashboard",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Report access failed: {response.status_code}")

    @task(10)
    def update_ticket_status(self):
        """Test ticket status updates"""
        # Note: Would need actual ticket IDs for real updates
        with self.client.get("/api/v1/users/me",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Ticket update check failed: {response.status_code}")


class ApiHealthCheck(SequentialTaskSet):
    """Health check tasks that run continuously"""

    @task
    def health_check(self):
        """Basic health check"""
        with self.client.get("/health",
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Health check failed: {response.status_code}")

    @task
    def auth_health_check(self):
        """Test authentication endpoint"""
        with self.client.post("/api/v1/auth/login",
                            json={"phone_number": "9876543200", "password": "testpassword"},
                            catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Auth health check failed: {response.status_code}")


class HealthCheckUser(HttpUser):
    """Dedicated health check user"""

    weight = 1
    wait_time = constant(30)  # Check every 30 seconds

    tasks = [ApiHealthCheck]
