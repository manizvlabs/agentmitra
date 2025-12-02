#!/usr/bin/env python3
"""
Campaign Endpoints Real API Testing Suite
==========================================

Comprehensive testing script for campaign endpoints using real database and running backend.
Tests all endpoints with different user roles and permissions.

Run with: python test_campaign_endpoints_real.py

Author: Campaign API Testing
"""

import requests
import json
import time
import sys
from typing import Dict, Any, Optional, List, Tuple
from datetime import datetime, timedelta
from dataclasses import dataclass
import traceback

# Configuration
BASE_URL = "http://127.0.0.1:8015"
API_BASE = f"{BASE_URL}/api/v1"

# Test users with different roles (seeded in database)
TEST_USERS = {
    "super_admin": {
        "phone_number": "+919876543200",
        "password": "testpassword",
        "expected_roles": ["super_admin"],
        "description": "Full system access (59 permissions)"
    },
    "provider_admin": {
        "phone_number": "+919876543201",
        "password": "testpassword",
        "expected_roles": ["provider_admin"],
        "description": "Insurance provider management"
    },
    "regional_manager": {
        "phone_number": "+919876543202",
        "password": "testpassword",
        "expected_roles": ["regional_manager"],
        "description": "Regional operations (19 permissions)"
    },
    "senior_agent": {
        "phone_number": "+919876543203",
        "password": "testpassword",
        "expected_roles": ["senior_agent"],
        "description": "Agent operations + inherited permissions (16 permissions)"
    },
    "junior_agent": {
        "phone_number": "+919876543204",
        "password": "testpassword",
        "expected_roles": ["junior_agent"],
        "description": "Basic agent operations (7 permissions)"
    },
    "policyholder": {
        "phone_number": "+919876543205",
        "password": "testpassword",
        "expected_roles": ["policyholder"],
        "description": "Customer access (5 permissions)"
    },
    "support_staff": {
        "phone_number": "+919876543206",
        "password": "testpassword",
        "expected_roles": ["support_staff"],
        "description": "Support operations (8 permissions)"
    }
}

@dataclass
class TestResult:
    """Test result data structure"""
    endpoint: str
    method: str
    user: str
    status_code: int
    success: bool
    response_time: float
    error_message: Optional[str] = None
    response_data: Optional[Dict] = None

class CampaignAPITester:
    """Campaign API Tester Class"""

    def __init__(self):
        self.session = requests.Session()
        self.auth_tokens = {}
        self.test_results = []
        self.created_campaigns = []

    def log(self, message: str, level: str = "INFO"):
        """Log message with timestamp"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        print(f"[{timestamp}] {level}: {message}")

    def authenticate_user(self, user_key: str) -> bool:
        """Authenticate user and store token"""
        user = TEST_USERS[user_key]
        try:
            # Login with phone and password
            login_response = self.session.post(
                f"{API_BASE}/auth/login",
                json={
                    "phone_number": user["phone_number"],
                    "password": user["password"]
                }
            )

            if login_response.status_code == 200:
                data = login_response.json()
                if "access_token" in data:
                    self.auth_tokens[user_key] = data["access_token"]
                    self.log(f"✅ Authenticated {user_key} successfully")
                    return True
                else:
                    self.log(f"❌ No access token in response for {user_key}", "ERROR")
                    return False
            else:
                self.log(f"❌ Failed to login for {user_key}: {login_response.text}", "ERROR")
                return False

        except Exception as e:
            self.log(f"❌ Authentication error for {user_key}: {str(e)}", "ERROR")
            return False

    def make_request(self, method: str, endpoint: str, user_key: str,
                    data: Optional[Dict] = None, params: Optional[Dict] = None) -> TestResult:
        """Make HTTP request and return test result"""
        start_time = time.time()

        headers = {"Content-Type": "application/json"}
        if user_key in self.auth_tokens:
            headers["Authorization"] = f"Bearer {self.auth_tokens[user_key]}"

        try:
            url = f"{API_BASE}{endpoint}"
            if method.upper() == "GET":
                response = self.session.get(url, headers=headers, params=params)
            elif method.upper() == "POST":
                response = self.session.post(url, headers=headers, json=data)
            elif method.upper() == "PUT":
                response = self.session.put(url, headers=headers, json=data)
            elif method.upper() == "DELETE":
                response = self.session.delete(url, headers=headers)
            else:
                raise ValueError(f"Unsupported HTTP method: {method}")

            response_time = time.time() - start_time

            # Try to parse JSON response
            try:
                response_data = response.json() if response.content else None
            except:
                response_data = None

            success = response.status_code in [200, 201, 204]

            result = TestResult(
                endpoint=endpoint,
                method=method.upper(),
                user=user_key,
                status_code=response.status_code,
                success=success,
                response_time=round(response_time, 3),
                response_data=response_data
            )

            if not success:
                result.error_message = response.text

            return result

        except Exception as e:
            response_time = time.time() - start_time
            return TestResult(
                endpoint=endpoint,
                method=method.upper(),
                user=user_key,
                status_code=0,
                success=False,
                response_time=round(response_time, 3),
                error_message=str(e)
            )

    def test_campaign_endpoints(self):
        """Test all campaign endpoints with different users"""
        self.log("🚀 Starting Campaign API Tests")
        self.log("=" * 50)

        # Authenticate all users first
        self.log("🔐 Authenticating users...")
        authenticated_users = []
        for user_key in TEST_USERS.keys():
            if self.authenticate_user(user_key):
                authenticated_users.append(user_key)
            time.sleep(0.5)  # Rate limiting

        if not authenticated_users:
            self.log("❌ No users could be authenticated. Aborting tests.", "ERROR")
            return

        self.log(f"✅ Authenticated {len(authenticated_users)} users: {', '.join(authenticated_users)}")
        self.log("")

        # Test 1: Get campaign templates (should work for all authenticated users)
        self.log("📋 Test 1: GET /api/v1/campaigns/templates")
        for user in authenticated_users:
            result = self.make_request("GET", "/campaigns/templates", user)
            self.test_results.append(result)
            status = "✅" if result.success else "❌"
            self.log(f"  {status} {user}: {result.status_code} ({result.response_time}s)")
        self.log("")

        # Test 2: List campaigns (should work for agents, fail for policyholder)
        self.log("📋 Test 2: GET /api/v1/campaigns")
        for user in authenticated_users:
            result = self.make_request("GET", "/campaigns", user)
            self.test_results.append(result)
            status = "✅" if result.success else "❌"
            self.log(f"  {status} {user}: {result.status_code} ({result.response_time}s)")

            # Check if response contains campaigns
            if result.success and result.response_data:
                campaigns = result.response_data.get("data", [])
                self.log(f"    📊 Found {len(campaigns)} campaigns")
        self.log("")

        # Test 3: Create campaign (should work for agents, fail for policyholder)
        self.log("📋 Test 3: POST /api/v1/campaigns")
        campaign_data = {
            "campaign_name": f"Test Campaign {datetime.now().strftime('%H%M%S')}",
            "campaign_type": "acquisition",
            "campaign_goal": "lead_generation",
            "description": "Automated test campaign",
            "subject": "Welcome to our service!",
            "message": "Dear {{customer_name}}, welcome to our insurance service. Your policy is active.",
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

        created_campaign_ids = {}
        for user in authenticated_users:
            result = self.make_request("POST", "/campaigns", user, data=campaign_data)
            self.test_results.append(result)
            status = "✅" if result.success else "❌"
            self.log(f"  {status} {user}: {result.status_code} ({result.response_time}s)")

            if result.success and result.response_data:
                campaign_id = result.response_data.get("data", {}).get("campaign_id")
                if campaign_id:
                    created_campaign_ids[user] = campaign_id
                    self.created_campaigns.append((user, campaign_id))
                    self.log(f"    📝 Created campaign: {campaign_id}")
        self.log("")

        # Test 4: Get campaign details (for created campaigns)
        self.log("📋 Test 4: GET /api/v1/campaigns/{campaign_id}")
        for user, campaign_id in created_campaign_ids.items():
            result = self.make_request("GET", f"/campaigns/{campaign_id}", user)
            self.test_results.append(result)
            status = "✅" if result.success else "❌"
            self.log(f"  {status} {user}: {result.status_code} ({result.response_time}s)")

            if result.success and result.response_data:
                data = result.response_data.get("data", {})
                self.log(f"    📊 Campaign: {data.get('campaign_name')} ({data.get('status')})")
        self.log("")

        # Test 5: Update campaign (for created campaigns)
        self.log("📋 Test 5: PUT /api/v1/campaigns/{campaign_id}")
        update_data = {
            "campaign_name": f"Updated Test Campaign {datetime.now().strftime('%H%M%S')}",
            "description": "Updated automated test campaign",
            "budget": 2000.00
        }

        for user, campaign_id in created_campaign_ids.items():
            result = self.make_request("PUT", f"/campaigns/{campaign_id}", user, data=update_data)
            self.test_results.append(result)
            status = "✅" if result.success else "❌"
            self.log(f"  {status} {user}: {result.status_code} ({result.response_time}s)")
        self.log("")

        # Test 6: Launch campaign (for created campaigns)
        self.log("📋 Test 6: POST /api/v1/campaigns/{campaign_id}/launch")
        for user, campaign_id in created_campaign_ids.items():
            result = self.make_request("POST", f"/campaigns/{campaign_id}/launch", user)
            self.test_results.append(result)
            status = "✅" if result.success else "❌"
            self.log(f"  {status} {user}: {result.status_code} ({result.response_time}s)")

            if result.success and result.response_data:
                status_after_launch = result.response_data.get("data", {}).get("status")
                self.log(f"    🚀 Campaign status: {status_after_launch}")
        self.log("")

        # Test 7: Get campaign analytics (for launched campaigns)
        self.log("📋 Test 7: GET /api/v1/campaigns/{campaign_id}/analytics")
        for user, campaign_id in created_campaign_ids.items():
            result = self.make_request("GET", f"/campaigns/{campaign_id}/analytics", user)
            self.test_results.append(result)
            status = "✅" if result.success else "❌"
            self.log(f"  {status} {user}: {result.status_code} ({result.response_time}s)")

            if result.success and result.response_data:
                analytics = result.response_data.get("data", {})
                self.log(f"    📈 Sent: {analytics.get('total_sent', 0)}, ROI: {analytics.get('roi', 0)}%")
        self.log("")

        # Test 8: Create campaign from template (if templates exist)
        self.log("📋 Test 8: POST /api/v1/campaigns/templates/{template_id}/create")

        # First get a template ID
        template_result = self.make_request("GET", "/campaigns/templates", "super_admin")
        template_id = None
        if template_result.success and template_result.response_data:
            templates = template_result.response_data.get("data", [])
            if templates:
                template_id = templates[0].get("template_id")

        if template_id:
            template_campaign_data = {
                "campaign_name": f"Template Campaign {datetime.now().strftime('%H%M%S')}",
                "campaign_type": "acquisition",
                "message": "Custom message from template"
            }

            for user in ["senior_agent", "junior_agent"]:  # Only test with agents
                if user in authenticated_users:
                    result = self.make_request("POST", f"/campaigns/templates/{template_id}/create",
                                             user, data=template_campaign_data)
                    self.test_results.append(result)
                    status = "✅" if result.success else "❌"
                    self.log(f"  {status} {user}: {result.status_code} ({result.response_time}s)")

                    if result.success and result.response_data:
                        new_campaign_id = result.response_data.get("data", {}).get("campaign_id")
                        if new_campaign_id:
                            self.created_campaigns.append((user, new_campaign_id))
                            self.log(f"    📝 Created from template: {new_campaign_id}")
        else:
            self.log("  ⚠️  No templates available for testing")
        self.log("")

        # Test 9: Get campaign recommendations
        self.log("📋 Test 9: GET /api/v1/campaigns/recommendations")
        for user in authenticated_users:
            result = self.make_request("GET", "/campaigns/recommendations", user)
            self.test_results.append(result)
            status = "✅" if result.success else "❌"
            self.log(f"  {status} {user}: {result.status_code} ({result.response_time}s)")

            if result.success and result.response_data:
                recommendations = result.response_data.get("data", [])
                self.log(f"    💡 Found {len(recommendations)} recommendations")
        self.log("")

        # Test 10: List campaigns with filters
        self.log("📋 Test 10: GET /api/v1/campaigns (with filters)")
        for user in ["senior_agent", "junior_agent"]:
            if user in authenticated_users:
                # Filter by status
                result = self.make_request("GET", "/campaigns", user, params={"status": "active"})
                self.test_results.append(result)
                status = "✅" if result.success else "❌"
                self.log(f"  {status} {user} (status=active): {result.status_code} ({result.response_time}s)")

                # Filter by type
                result = self.make_request("GET", "/campaigns", user, params={"type": "acquisition"})
                self.test_results.append(result)
                status = "✅" if result.success else "❌"
                self.log(f"  {status} {user} (type=acquisition): {result.status_code} ({result.response_time}s)")
        self.log("")

    def generate_report(self):
        """Generate comprehensive test report"""
        self.log("📊 Generating Test Report")
        self.log("=" * 50)

        total_tests = len(self.test_results)
        successful_tests = len([r for r in self.test_results if r.success])
        failed_tests = total_tests - successful_tests

        self.log(f"Total Tests: {total_tests}")
        self.log(f"Successful: {successful_tests}")
        self.log(f"Failed: {failed_tests}")
        self.log(".1f")
        self.log("")

        # Group results by endpoint
        endpoint_stats = {}
        for result in self.test_results:
            key = f"{result.method} {result.endpoint}"
            if key not in endpoint_stats:
                endpoint_stats[key] = {"total": 0, "success": 0}
            endpoint_stats[key]["total"] += 1
            if result.success:
                endpoint_stats[key]["success"] += 1

        self.log("📋 Endpoint Statistics:")
        for endpoint, stats in endpoint_stats.items():
            success_rate = (stats["success"] / stats["total"]) * 100
            self.log(f"  {endpoint}: {stats['success']}/{stats['total']} ({success_rate:.1f}%)")

        self.log("")

        # Show failed tests
        failed_results = [r for r in self.test_results if not r.success]
        if failed_results:
            self.log("❌ Failed Tests:")
            for result in failed_results[:10]:  # Show first 10 failures
                self.log(f"  {result.method} {result.endpoint} ({result.user}): {result.status_code}")
                if result.error_message:
                    error_preview = result.error_message[:100] + "..." if len(result.error_message) > 100 else result.error_message
                    self.log(f"    Error: {error_preview}")
            if len(failed_results) > 10:
                self.log(f"  ... and {len(failed_results) - 10} more failures")
            self.log("")

        # Show created campaigns
        if self.created_campaigns:
            self.log("📝 Created Campaigns:")
            for user, campaign_id in self.created_campaigns:
                self.log(f"  {user}: {campaign_id}")
            self.log("")

        # Overall assessment
        success_rate = (successful_tests / total_tests) if total_tests > 0 else 0
        if success_rate > 0.8:
            self.log("🎉 Overall Result: EXCELLENT - Campaign endpoints are working well!")
        elif success_rate > 0.6:
            self.log("✅ Overall Result: GOOD - Most endpoints working, some issues to address")
        else:
            self.log("⚠️  Overall Result: NEEDS ATTENTION - Significant issues with campaign endpoints")

    def cleanup(self):
        """Clean up created test data"""
        self.log("🧹 Cleaning up test data...")

        # Note: In a real implementation, you might want to delete the created campaigns
        # But for testing purposes, we'll leave them for inspection

        self.log(f"Created {len(self.created_campaigns)} test campaigns (keeping for inspection)")


def check_backend_health():
    """Check if backend is running and healthy"""
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=5)
        if response.status_code == 200:
            print("✅ Backend is running and healthy")
            return True
        else:
            print(f"❌ Backend health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Cannot connect to backend at {BASE_URL}: {str(e)}")
        print("💡 Make sure backend is running:")
        print("   cd backend && PYTHONPATH=/Users/manish/Documents/GitHub/zero/agentmitra/backend ./venv/bin/python -m uvicorn main:app --host 127.0.0.1 --port 8015 --reload")
        return False


def main():
    """Main test execution"""
    print("🎯 Campaign Endpoints Real API Testing Suite")
    print("=" * 55)
    print()

    # Check backend health
    if not check_backend_health():
        sys.exit(1)

    print()

    # Initialize tester
    tester = CampaignAPITester()

    try:
        # Run all tests
        tester.test_campaign_endpoints()

        # Generate report
        tester.generate_report()

        # Cleanup
        tester.cleanup()

    except KeyboardInterrupt:
        print("\n⏹️  Tests interrupted by user")
    except Exception as e:
        print(f"\n❌ Test execution failed: {str(e)}")
        traceback.print_exc()
    finally:
        print("\n🏁 Campaign API Testing Complete!")


if __name__ == "__main__":
    main()
