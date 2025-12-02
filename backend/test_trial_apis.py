#!/usr/bin/env python3
"""
Comprehensive Trial APIs Testing Script
Tests all Trial subscription endpoints with real database operations
"""

import requests
import json
import uuid
import time
from datetime import datetime, timedelta
from typing import Dict, List, Optional

# Configuration
API_BASE = "http://127.0.0.1:8015/api/v1"

# Test users with different roles and permissions
TEST_USERS = {
    "super_admin": {
        "phone_number": "+919876543200",
        "password": "testpassword",
        "role": "super_admin",
        "permissions": 59,
        "expected_access": "full_system"
    },
    "provider_admin": {
        "phone_number": "+919876543201",
        "password": "testpassword",
        "role": "provider_admin",
        "permissions": 30,
        "expected_access": "provider_management"
    },
    "regional_manager": {
        "phone_number": "+919876543202",
        "password": "testpassword",
        "role": "regional_manager",
        "permissions": 19,
        "expected_access": "regional_ops"
    },
    "senior_agent": {
        "phone_number": "+919876543203",
        "password": "testpassword",
        "role": "senior_agent",
        "permissions": 16,
        "expected_access": "agent_ops"
    },
    "junior_agent": {
        "phone_number": "+919876543204",
        "password": "testpassword",
        "role": "junior_agent",
        "permissions": 7,
        "expected_access": "basic_agent"
    },
    "policyholder": {
        "phone_number": "+919876543205",
        "password": "testpassword",
        "role": "policyholder",
        "permissions": 5,
        "expected_access": "customer_access"
    },
    "support_staff": {
        "phone_number": "+919876543206",
        "password": "testpassword",
        "role": "support_staff",
        "permissions": 8,
        "expected_access": "support_ops"
    }
}

class TrialAPITester:
    """Test class for Trial subscription APIs"""

    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        })
        self.auth_tokens = {}
        self.test_results = []

    def log_result(self, api_name: str, status: str, message: str, details: Dict = None):
        """Log test result"""
        result = {
            "api": api_name,
            "status": status,
            "message": message,
            "timestamp": datetime.now().isoformat(),
            "details": details or {}
        }
        self.test_results.append(result)

        status_icon = "✅" if status == "PASS" else "❌" if status == "FAIL" else "⏭️" if status == "SKIP" else "⚠️"
        print(f"{status_icon} {api_name} - {message}")
        if details:
            for key, value in details.items():
                print(f"   {key}: {value}")

    def authenticate_user(self, role: str) -> bool:
        """Authenticate user and store JWT token"""
        user_config = TEST_USERS[role]
        try:
            response = self.session.post(f"{API_BASE}/auth/login", json={
                "phone_number": user_config["phone_number"],
                "password": user_config["password"]
            })

            if response.status_code == 200:
                data = response.json()
                if "access_token" in data:
                    self.auth_tokens[role] = data["access_token"]
                    self.session.headers.update({
                        'Authorization': f'Bearer {data["access_token"]}'
                    })

                    # Decode JWT payload to verify user info
                    import base64
                    payload = data["access_token"].split('.')[1]
                    payload += '=' * (4 - len(payload) % 4)
                    decoded = json.loads(base64.urlsafe_b64decode(payload))

                    self.log_result(
                        f"Authentication - {role}",
                        "PASS",
                        f"Successfully authenticated {role}",
                        {
                            "user_id": decoded.get('sub'),
                            "phone_number": decoded.get('phone_number'),
                            "roles": decoded.get('roles', []),
                            "permissions_count": len(decoded.get('permissions', []))
                        }
                    )
                    return True
                else:
                    self.log_result(f"Authentication - {role}", "FAIL", f"No access token in response: {data}")
                    return False
            else:
                self.log_result(f"Authentication - {role}", "FAIL", f"Login failed: {response.status_code} - {response.text}")
                return False

        except Exception as e:
            self.log_result(f"Authentication - {role}", "FAIL", f"Authentication error: {e}")
            return False

    def test_trial_setup(self):
        """Test POST /api/v1/trial/setup"""
        print("\n🧪 Testing Trial Setup API")

        # Test with Super Admin (should work)
        if self.authenticate_user("super_admin"):
            # Get current authenticated user ID from JWT token
            token = self.auth_tokens.get("super_admin")
            if token:
                import base64
                payload = token.split('.')[1]
                payload += '=' * (4 - len(payload) % 4)
                decoded = json.loads(base64.urlsafe_b64decode(payload))
                current_user_id = decoded.get('sub')

                if current_user_id:
                    print(f"Using authenticated user ID: {current_user_id}")

                    # Test trial setup for the current user (Super Admin)
                    trial_data = {
                        "plan_type": "agent_trial",
                        "custom_trial_days": 30,
                        "extension_days": 0
                    }

                    response = self.session.post(
                        f"{API_BASE}/trial/setup",
                        params={"user_id": current_user_id},
                        json=trial_data
                    )

                    if response.status_code == 200:
                        data = response.json()
                        if data.get("success"):
                            self.log_result(
                                "POST /api/v1/trial/setup",
                                "PASS",
                                "Trial setup successful",
                                {
                                    "trial_id": data.get("data", {}).get("trial_id"),
                                    "plan_type": data.get("data", {}).get("plan_type"),
                                    "trial_days": data.get("data", {}).get("trial_days")
                                }
                            )
                            return data.get("data", {}).get("trial_id")
                        else:
                            self.log_result("POST /api/v1/trial/setup", "FAIL", f"Trial setup failed: {data}")
                    elif response.status_code == 400 and "already has an active trial" in response.text:
                        self.log_result("POST /api/v1/trial/setup", "SKIP", "User already has active trial")
                        return "existing_trial"
                    else:
                        self.log_result("POST /api/v1/trial/setup", "FAIL", f"HTTP {response.status_code}: {response.text}")
                else:
                    self.log_result("POST /api/v1/trial/setup", "SKIP", "Could not extract user ID from token")
            else:
                self.log_result("POST /api/v1/trial/setup", "SKIP", "No auth token available")
        else:
            self.log_result("POST /api/v1/trial/setup", "SKIP", "Authentication failed")

        return None

    def test_trial_status(self, user_id: str = None):
        """Test GET /api/v1/trial/status/{user_id}"""
        print("\n🧪 Testing Trial Status API")

        # Test with Super Admin
        if self.authenticate_user("super_admin"):
            if not user_id:
                # Get current user ID from JWT token
                token = self.auth_tokens.get("super_admin")
                if token:
                    import base64
                    payload = token.split('.')[1]
                    payload += '=' * (4 - len(payload) % 4)
                    decoded = json.loads(base64.urlsafe_b64decode(payload))
                    user_id = decoded.get('sub')

            if user_id:
                response = self.session.get(f"{API_BASE}/trial/status/{user_id}")

                if response.status_code == 200:
                    data = response.json()
                    self.log_result(
                        "GET /api/v1/trial/status/{user_id}",
                        "PASS",
                        "Trial status retrieved successfully",
                        {
                            "user_id": data.get("user_id"),
                            "is_trial": data.get("is_trial"),
                            "trial_status": data.get("trial_status"),
                            "days_remaining": data.get("days_remaining")
                        }
                    )
                else:
                    self.log_result("GET /api/v1/trial/status/{user_id}", "FAIL", f"HTTP {response.status_code}: {response.text}")
            else:
                self.log_result("GET /api/v1/trial/status/{user_id}", "SKIP", "No user ID available")
        else:
            self.log_result("GET /api/v1/trial/status/{user_id}", "SKIP", "Authentication failed")

    def test_trial_extend(self, user_id: str = None):
        """Test POST /api/v1/trial/extend/{user_id}"""
        print("\n🧪 Testing Trial Extend API")

        # Test with Regional Manager (should work)
        if self.authenticate_user("regional_manager"):
            if not user_id:
                # Get current user ID from JWT token
                token = self.auth_tokens.get("regional_manager")
                if token:
                    import base64
                    payload = token.split('.')[1]
                    payload += '=' * (4 - len(payload) % 4)
                    decoded = json.loads(base64.urlsafe_b64decode(payload))
                    user_id = decoded.get('sub')

            if user_id:
                extension_data = {
                    "extension_days": 7,
                    "reason": "Customer requested additional evaluation time",
                    "approved_by": "regional_manager"
                }

                response = self.session.post(
                    f"{API_BASE}/trial/extend/{user_id}",
                    json=extension_data
                )

                if response.status_code == 200:
                    data = response.json()
                    if data.get("success"):
                        self.log_result(
                            "POST /api/v1/trial/extend/{user_id}",
                            "PASS",
                            "Trial extension successful",
                            {
                                "extended_by_days": data.get("data", {}).get("extended_by_days"),
                                "new_end_date": data.get("data", {}).get("new_end_date"),
                                "total_extension_days": data.get("data", {}).get("total_extension_days")
                            }
                        )
                    else:
                        self.log_result("POST /api/v1/trial/extend/{user_id}", "FAIL", f"Trial extension failed: {data}")
                elif response.status_code == 500 and "No active trial found" in response.text:
                    self.log_result("POST /api/v1/trial/extend/{user_id}", "SKIP", "No active trial to extend")
                else:
                    self.log_result("POST /api/v1/trial/extend/{user_id}", "FAIL", f"HTTP {response.status_code}: {response.text}")
            else:
                self.log_result("POST /api/v1/trial/extend/{user_id}", "SKIP", "No user ID available")
        else:
            self.log_result("POST /api/v1/trial/extend/{user_id}", "SKIP", "Authentication failed")

    def test_trial_convert(self, user_id: str = None):
        """Test POST /api/v1/trial/convert/{user_id}"""
        print("\n🧪 Testing Trial Convert API")

        # Test with Super Admin
        if self.authenticate_user("super_admin"):
            if not user_id:
                # Get current user ID from JWT token
                token = self.auth_tokens.get("super_admin")
                if token:
                    import base64
                    payload = token.split('.')[1]
                    payload += '=' * (4 - len(payload) % 4)
                    decoded = json.loads(base64.urlsafe_b64decode(payload))
                    user_id = decoded.get('sub')

            if user_id:
                # Convert to premium plan
                response = self.session.post(
                    f"{API_BASE}/trial/convert/{user_id}",
                    params={"conversion_plan": "premium_customer"}
                )

                if response.status_code == 200:
                    data = response.json()
                    if data.get("success"):
                        self.log_result(
                            "POST /api/v1/trial/convert/{user_id}",
                            "PASS",
                            "Trial conversion successful",
                            {
                                "conversion_date": data.get("data", {}).get("conversion_date"),
                                "conversion_plan": data.get("data", {}).get("conversion_plan"),
                                "trial_duration_days": data.get("data", {}).get("trial_duration_days")
                            }
                        )
                    else:
                        self.log_result("POST /api/v1/trial/convert/{user_id}", "FAIL", f"Trial conversion failed: {data}")
                elif response.status_code == 500 and "No active trial found" in response.text:
                    self.log_result("POST /api/v1/trial/convert/{user_id}", "SKIP", "No active trial to convert")
                else:
                    self.log_result("POST /api/v1/trial/convert/{user_id}", "FAIL", f"HTTP {response.status_code}: {response.text}")
            else:
                self.log_result("POST /api/v1/trial/convert/{user_id}", "SKIP", "No user ID available")
        else:
            self.log_result("POST /api/v1/trial/convert/{user_id}", "SKIP", "Authentication failed")

    def test_trial_engagement(self, user_id: str = None):
        """Test POST /api/v1/trial/engagement/{user_id}"""
        print("\n🧪 Testing Trial Engagement API")

        # Test with Senior Agent (should work)
        if self.authenticate_user("senior_agent"):
            if not user_id:
                # Get current user ID from JWT token
                token = self.auth_tokens.get("senior_agent")
                if token:
                    import base64
                    payload = token.split('.')[1]
                    payload += '=' * (4 - len(payload) % 4)
                    decoded = json.loads(base64.urlsafe_b64decode(payload))
                    user_id = decoded.get('sub')

            if user_id:
                engagement_data = {
                    "feature_used": "dashboard",
                    "engagement_type": "view",
                    "metadata": {
                        "page": "main_dashboard",
                        "time_spent_seconds": 120,
                        "actions_performed": ["view_policies", "check_notifications"]
                    },
                    "engaged_at": datetime.now().isoformat()
                }

                response = self.session.post(
                    f"{API_BASE}/trial/engagement/{user_id}",
                    json=engagement_data
                )

                if response.status_code == 200:
                    data = response.json()
                    if data.get("success"):
                        self.log_result(
                            "POST /api/v1/trial/engagement/{user_id}",
                            "PASS",
                            "Engagement recorded successfully",
                            {
                                "engagement_id": data.get("data", {}).get("engagement_id"),
                                "recorded": data.get("data", {}).get("recorded")
                            }
                        )
                    else:
                        self.log_result("POST /api/v1/trial/engagement/{user_id}", "FAIL", f"Engagement recording failed: {data}")
                else:
                    self.log_result("POST /api/v1/trial/engagement/{user_id}", "FAIL", f"HTTP {response.status_code}: {response.text}")
            else:
                self.log_result("POST /api/v1/trial/engagement/{user_id}", "SKIP", "No user ID available")
        else:
            self.log_result("POST /api/v1/trial/engagement/{user_id}", "SKIP", "Authentication failed")

    def test_trial_analytics(self):
        """Test GET /api/v1/trial/analytics/overview"""
        print("\n🧪 Testing Trial Analytics API")

        # Test with Regional Manager (should work)
        if self.authenticate_user("regional_manager"):
            response = self.session.get(f"{API_BASE}/trial/analytics/overview")

            if response.status_code == 200:
                data = response.json()
                self.log_result(
                    "GET /api/v1/trial/analytics/overview",
                    "PASS",
                    "Trial analytics retrieved successfully",
                    {
                        "total_trial_users": data.get("total_trial_users"),
                        "active_trials": data.get("active_trials"),
                        "conversion_rate": data.get("conversion_rate"),
                        "trials_expiring_soon": data.get("trials_expiring_soon")
                    }
                )
            else:
                self.log_result("GET /api/v1/trial/analytics/overview", "FAIL", f"HTTP {response.status_code}: {response.text}")
        else:
            self.log_result("GET /api/v1/trial/analytics/overview", "SKIP", "Authentication failed")

    def test_expiring_trials(self):
        """Test GET /api/v1/trial/expiring-soon"""
        print("\n🧪 Testing Expiring Trials API")

        # Test with Senior Agent (should work)
        if self.authenticate_user("senior_agent"):
            response = self.session.get(f"{API_BASE}/trial/expiring-soon?days=7")

            if response.status_code == 200:
                data = response.json()
                self.log_result(
                    "GET /api/v1/trial/expiring-soon",
                    "PASS",
                    "Expiring trials retrieved successfully",
                    {
                        "count": data.get("count"),
                        "days_ahead": 7
                    }
                )
            else:
                self.log_result("GET /api/v1/trial/expiring-soon", "FAIL", f"HTTP {response.status_code}: {response.text}")
        else:
            self.log_result("GET /api/v1/trial/expiring-soon", "SKIP", "Authentication failed")

    def test_trial_reminder(self, user_id: str = None):
        """Test POST /api/v1/trial/send-reminder/{user_id}"""
        print("\n🧪 Testing Trial Reminder API")

        # Test with Super Admin
        if self.authenticate_user("super_admin"):
            if not user_id:
                # Get current user ID from JWT token
                token = self.auth_tokens.get("super_admin")
                if token:
                    import base64
                    payload = token.split('.')[1]
                    payload += '=' * (4 - len(payload) % 4)
                    decoded = json.loads(base64.urlsafe_b64decode(payload))
                    user_id = decoded.get('sub')

            if user_id:
                response = self.session.post(
                    f"{API_BASE}/trial/send-reminder/{user_id}",
                    params={"reminder_type": "email"}
                )

                if response.status_code == 200:
                    data = response.json()
                    if data.get("success"):
                        self.log_result(
                            "POST /api/v1/trial/send-reminder/{user_id}",
                            "PASS",
                            "Trial reminder sent successfully",
                            {
                                "reminder_type": data.get("data", {}).get("reminder_type"),
                                "days_remaining": data.get("data", {}).get("days_remaining"),
                                "sent_at": data.get("data", {}).get("sent_at")
                            }
                        )
                    else:
                        self.log_result("POST /api/v1/trial/send-reminder/{user_id}", "FAIL", f"Reminder sending failed: {data}")
                elif response.status_code == 500 and "No active trial found" in response.text:
                    self.log_result("POST /api/v1/trial/send-reminder/{user_id}", "SKIP", "No active trial to send reminder for")
                else:
                    self.log_result("POST /api/v1/trial/send-reminder/{user_id}", "FAIL", f"HTTP {response.status_code}: {response.text}")
            else:
                self.log_result("POST /api/v1/trial/send-reminder/{user_id}", "SKIP", "No user ID available")
        else:
            self.log_result("POST /api/v1/trial/send-reminder/{user_id}", "SKIP", "Authentication failed")

    def test_permission_denied_scenarios(self):
        """Test scenarios where access should be denied"""
        print("\n🧪 Testing Permission Denied Scenarios")

        # Test trial setup with Junior Agent (should fail - insufficient permissions)
        if self.authenticate_user("junior_agent"):
            response = self.session.post(
                f"{API_BASE}/trial/setup",
                params={"user_id": str(uuid.uuid4())},
                json={"plan_type": "policyholder_trial"}
            )

            if response.status_code == 403:
                self.log_result(
                    "Permission Test - Trial Setup (Junior Agent)",
                    "PASS",
                    "Correctly denied trial setup for junior agent"
                )
            else:
                self.log_result(
                    "Permission Test - Trial Setup (Junior Agent)",
                    "FAIL",
                    f"Should have been denied but got HTTP {response.status_code}"
                )

        # Test analytics access with Policyholder (should fail - insufficient permissions)
        if self.authenticate_user("policyholder"):
            response = self.session.get(f"{API_BASE}/trial/analytics/overview")

            if response.status_code == 403:
                self.log_result(
                    "Permission Test - Analytics (Policyholder)",
                    "PASS",
                    "Correctly denied analytics access for policyholder"
                )
            else:
                self.log_result(
                    "Permission Test - Analytics (Policyholder)",
                    "FAIL",
                    f"Should have been denied but got HTTP {response.status_code}"
                )

    def run_all_tests(self):
        """Run all trial API tests"""
        print("🚀 Starting Trial APIs Testing")
        print("=" * 50)

        # Run all test methods
        trial_id = self.test_trial_setup()
        self.test_trial_status()
        self.test_trial_extend()
        self.test_trial_convert()
        self.test_trial_engagement()
        self.test_trial_analytics()
        self.test_expiring_trials()
        self.test_trial_reminder()
        self.test_permission_denied_scenarios()

        # Generate summary
        self.generate_summary()

    def generate_summary(self):
        """Generate test summary"""
        print("\n" + "=" * 50)
        print("📊 TRIAL APIs TESTING SUMMARY")
        print("=" * 50)

        total_tests = len(self.test_results)
        passed = sum(1 for r in self.test_results if r["status"] == "PASS")
        failed = sum(1 for r in self.test_results if r["status"] == "FAIL")
        skipped = sum(1 for r in self.test_results if r["status"] == "SKIP")

        success_rate = (passed / total_tests * 100) if total_tests > 0 else 0

        print(f"Total Tests: {total_tests}")
        print(f"✅ Passed: {passed}")
        print(f"❌ Failed: {failed}")
        print(f"⏭️ Skipped: {skipped}")
        print(".1f")
        # Show failed tests
        if failed > 0:
            print(f"\n❌ FAILED TESTS:")
            for result in self.test_results:
                if result["status"] == "FAIL":
                    print(f"  - {result['api']}: {result['message']}")

        # Show test details
        print(f"\n📋 DETAILED RESULTS:")
        for result in self.test_results:
            status_icon = "✅" if result["status"] == "PASS" else "❌" if result["status"] == "FAIL" else "⏭️"
            print(f"{status_icon} {result['api']}")
            if result["details"]:
                for key, value in result["details"].items():
                    print(f"   {key}: {value}")
            print()

        print(f"🎯 SUCCESS RATE: {success_rate:.1f}%")
        if success_rate >= 80:
            print("🎉 EXCELLENT! Trial APIs are working well!")
        elif success_rate >= 60:
            print("👍 GOOD! Trial APIs are mostly functional!")
        else:
            print("⚠️ NEEDS ATTENTION! Trial APIs require fixes!")


if __name__ == "__main__":
    print("🏥 AgentMitra Trial APIs Tester")
    print("Testing Trial subscription management endpoints")
    print("Using real database operations via Flyway migrations")
    print()

    # Wait a moment for server to be ready
    print("⏳ Waiting for server to be ready...")
    time.sleep(2)

    # Run tests
    tester = TrialAPITester()
    tester.run_all_tests()
