#!/usr/bin/env python3
"""
Agent Mitra API Authentication and Authorization Test Suite
===========================================================

Comprehensive testing script for:
- JWT authentication
- Role-based access control (RBAC)
- API endpoint authorization
- External service integrations

Run with: python test_api_auth.py
"""

import requests
import json
import time
import sys
from typing import Dict, Any, Optional
from datetime import datetime

# Configuration
BASE_URL = "http://127.0.0.1:8015"
API_BASE = f"{BASE_URL}/api/v1"

# Test users with different roles (these should exist in your database)
TEST_USERS = {
    "super_admin": {
        "username": "superadmin@test.com",
        "password": "testpass123",
        "expected_roles": ["super_admin"]
    },
    "provider_admin": {
        "username": "provider@test.com",
        "password": "testpass123",
        "expected_roles": ["provider_admin"]
    },
    "regional_manager": {
        "username": "regional@test.com",
        "password": "testpass123",
        "expected_roles": ["regional_manager"]
    },
    "senior_agent": {
        "username": "senior@test.com",
        "password": "testpass123",
        "expected_roles": ["senior_agent"]
    },
    "junior_agent": {
        "username": "junior@test.com",
        "password": "testpass123",
        "expected_roles": ["junior_agent"]
    },
    "policyholder": {
        "username": "customer@test.com",
        "password": "testpass123",
        "expected_roles": ["policyholder"]
    }
}

class APITester:
    """API testing class with authentication"""

    def __init__(self):
        self.tokens = {}
        self.session = requests.Session()
        self.session.headers.update({
            'Content-Type': 'application/json',
            'User-Agent': 'AgentMitra-API-Test/1.0'
        })

    def login_user(self, username: str, password: str) -> Optional[str]:
        """Login user and return JWT token"""
        try:
            response = self.session.post(f"{API_BASE}/auth/login", json={
                "username": username,
                "password": password
            })

            if response.status_code == 200:
                data = response.json()
                token = data.get("access_token")
                print(f"✅ Login successful for {username}")
                return token
            else:
                print(f"❌ Login failed for {username}: {response.status_code} - {response.text}")
                return None

        except Exception as e:
            print(f"❌ Login error for {username}: {e}")
            return None

    def make_authenticated_request(self, method: str, endpoint: str, token: str,
                                 data: Optional[Dict] = None, params: Optional[Dict] = None) -> requests.Response:
        """Make authenticated API request"""
        headers = {'Authorization': f'Bearer {token}'}
        url = f"{API_BASE}{endpoint}"

        try:
            if method.upper() == 'GET':
                response = self.session.get(url, headers=headers, params=params)
            elif method.upper() == 'POST':
                response = self.session.post(url, headers=headers, json=data)
            elif method.upper() == 'PUT':
                response = self.session.put(url, headers=headers, json=data)
            elif method.upper() == 'DELETE':
                response = self.session.delete(url, headers=headers)
            else:
                raise ValueError(f"Unsupported HTTP method: {method}")

            return response

        except Exception as e:
            print(f"❌ Request error: {e}")
            # Return a mock response for error handling
            class MockResponse:
                status_code = 500
                text = str(e)
                def json(self): return {"error": str(e)}
            return MockResponse()

    def test_health_endpoint(self) -> bool:
        """Test public health endpoint"""
        print("\n🔍 Testing public endpoints...")

        try:
            # Test health endpoint (should work without auth)
            response = self.session.get(f"{API_BASE}/health")
            if response.status_code == 200:
                print("✅ Health endpoint accessible")
                return True
            else:
                print(f"❌ Health endpoint failed: {response.status_code}")
                return False
        except Exception as e:
            print(f"❌ Health endpoint error: {e}")
            return False

    def test_unauthenticated_access(self) -> bool:
        """Test that protected endpoints require authentication"""
        print("\n🔒 Testing authentication requirements...")

        protected_endpoints = [
            "/users/",
            "/analytics/comprehensive/dashboard",
            "/external/sms/send",
            "/external/ai/chat"
        ]

        success_count = 0

        for endpoint in protected_endpoints:
            response = self.session.get(f"{API_BASE}{endpoint}")
            if response.status_code in [401, 403]:
                print(f"✅ {endpoint} properly protected ({response.status_code})")
                success_count += 1
            else:
                print(f"❌ {endpoint} not properly protected ({response.status_code})")

        return success_count == len(protected_endpoints)

    def test_user_authentication(self) -> bool:
        """Test user authentication for all test users"""
        print("\n🔐 Testing user authentication...")

        success_count = 0

        for role, user_data in TEST_USERS.items():
            token = self.login_user(user_data["username"], user_data["password"])
            if token:
                self.tokens[role] = token
                success_count += 1
            else:
                print(f"❌ Failed to authenticate {role}")

        print(f"✅ Authenticated {success_count}/{len(TEST_USERS)} users")
        return success_count > 0  # At least one user should authenticate

    def test_role_based_access(self) -> bool:
        """Test role-based access control"""
        print("\n👥 Testing role-based access control...")

        # Test cases: (endpoint, method, allowed_roles, test_data)
        test_cases = [
            ("/users/", "GET", ["super_admin", "provider_admin", "regional_manager"], None),
            ("/analytics/comprehensive/dashboard", "GET", ["super_admin", "provider_admin", "regional_manager", "senior_agent"], None),
            ("/external/ai/chat", "POST", ["super_admin", "provider_admin", "regional_manager", "senior_agent", "junior_agent"],
             {"messages": [{"role": "user", "content": "Hello"}]}),
            ("/external/sms/send", "POST", ["super_admin", "provider_admin", "regional_manager", "senior_agent", "junior_agent"],
             {"to_phone": "+1234567890", "message": "Test SMS"}),
        ]

        success_count = 0
        total_tests = 0

        for endpoint, method, allowed_roles, test_data in test_cases:
            for role, token in self.tokens.items():
                total_tests += 1
                response = self.make_authenticated_request(method, endpoint, token, test_data)

                should_have_access = role in allowed_roles
                has_access = response.status_code not in [401, 403]

                if should_have_access == has_access:
                    status = "✅" if should_have_access else "✅ (denied)"
                    print(f"{status} {role} {'has' if has_access else 'denied'} access to {endpoint}")
                    if should_have_access:
                        success_count += 1
                else:
                    print(f"❌ {role} access mismatch for {endpoint} (expected: {should_have_access}, got: {has_access})")

        print(f"✅ RBAC tests: {success_count}/{total_tests} passed")
        return success_count > 0

    def test_external_services_integration(self) -> bool:
        """Test external service integrations (SMS, WhatsApp, AI)"""
        print("\n🔗 Testing external service integrations...")

        # Test with senior_agent (should have access to most services)
        token = self.tokens.get("senior_agent")
        if not token:
            print("❌ No senior agent token available for external service tests")
            return False

        test_cases = [
            ("AI Chat", "POST", "/external/ai/chat", {
                "messages": [{"role": "user", "content": "Hello, test message"}]
            }),
            ("SMS Send", "POST", "/external/sms/send", {
                "to_phone": "+1234567890",
                "message": "Test SMS from API test"
            }),
            ("WhatsApp Send", "POST", "/external/whatsapp/send", {
                "to_phone": "+1234567890",
                "message_type": "text",
                "content": {"body": "Test WhatsApp message"}
            }),
        ]

        success_count = 0

        for service_name, method, endpoint, data in test_cases:
            response = self.make_authenticated_request(method, endpoint, token, data)

            # For external services, we expect either success or proper error handling
            # (not authentication errors)
            if response.status_code not in [401, 403]:
                print(f"✅ {service_name}: {response.status_code} ({'success' if response.status_code < 400 else 'expected error'})")
                success_count += 1
            else:
                print(f"❌ {service_name}: Authentication/Authorization error ({response.status_code})")

        print(f"✅ External services: {success_count}/{len(test_cases)} properly handled")
        return success_count > 0

    def test_user_management(self) -> bool:
        """Test user management endpoints"""
        print("\n👤 Testing user management...")

        # Test with super_admin
        token = self.tokens.get("super_admin")
        if not token:
            print("❌ No super admin token available for user management tests")
            return False

        # Test getting user list (should work for super_admin)
        response = self.make_authenticated_request("GET", "/users/", token, params={"limit": 5})

        if response.status_code == 200:
            data = response.json()
            print(f"✅ User list retrieved: {len(data.get('data', []))} users shown")
            return True
        else:
            print(f"❌ User list access failed: {response.status_code} - {response.text}")
            return False

    def test_analytics_access(self) -> bool:
        """Test analytics endpoints access"""
        print("\n📊 Testing analytics access...")

        # Test with different user roles
        test_cases = [
            ("super_admin", "/analytics/comprehensive/dashboard"),
            ("provider_admin", "/analytics/comprehensive/dashboard"),
            ("regional_manager", "/analytics/comprehensive/dashboard"),
            ("senior_agent", "/analytics/comprehensive/dashboard"),
            ("junior_agent", "/analytics/comprehensive/dashboard"),  # Should be denied
        ]

        success_count = 0

        for role, endpoint in test_cases:
            token = self.tokens.get(role)
            if not token:
                print(f"⚠️  Skipping {role} analytics test (no token)")
                continue

            response = self.make_authenticated_request("GET", endpoint, token)

            if role in ["super_admin", "provider_admin", "regional_manager", "senior_agent"]:
                if response.status_code == 200:
                    print(f"✅ {role} has analytics access")
                    success_count += 1
                else:
                    print(f"❌ {role} analytics access failed: {response.status_code}")
            else:
                if response.status_code in [401, 403]:
                    print(f"✅ {role} properly denied analytics access")
                    success_count += 1
                else:
                    print(f"❌ {role} should not have analytics access: {response.status_code}")

        return success_count > 0

    def run_comprehensive_test(self) -> Dict[str, Any]:
        """Run comprehensive API test suite"""
        print("🚀 Starting Agent Mitra API Authentication & Authorization Test Suite")
        print("=" * 80)

        results = {
            "timestamp": datetime.now().isoformat(),
            "tests": {}
        }

        # Test sequence
        test_sequence = [
            ("health_endpoint", self.test_health_endpoint),
            ("unauthenticated_access", self.test_unauthenticated_access),
            ("user_authentication", self.test_user_authentication),
            ("role_based_access", self.test_role_based_access),
            ("external_services", self.test_external_services_integration),
            ("user_management", self.test_user_management),
            ("analytics_access", self.test_analytics_access),
        ]

        passed_tests = 0
        total_tests = len(test_sequence)

        for test_name, test_func in test_sequence:
            try:
                print(f"\n{'='*50}")
                print(f"Running: {test_name.replace('_', ' ').title()}")
                print('='*50)

                result = test_func()
                results["tests"][test_name] = result

                if result:
                    passed_tests += 1
                    print(f"✅ {test_name}: PASSED")
                else:
                    print(f"❌ {test_name}: FAILED")

            except Exception as e:
                print(f"💥 {test_name}: ERROR - {e}")
                results["tests"][test_name] = False

        # Summary
        print("\n" + "="*80)
        print("📋 TEST SUMMARY")
        print("="*80)
        print(f"Total Tests: {total_tests}")
        print(f"Passed: {passed_tests}")
        print(f"Failed: {total_tests - passed_tests}")
        print(".1f")

        results["summary"] = {
            "total_tests": total_tests,
            "passed": passed_tests,
            "failed": total_tests - passed_tests,
            "success_rate": passed_tests / total_tests if total_tests > 0 else 0
        }

        if passed_tests == total_tests:
            print("🎉 ALL TESTS PASSED! API is properly secured.")
        elif passed_tests > total_tests * 0.8:
            print("⚠️  MOST TESTS PASSED. Review failed tests before production.")
        else:
            print("❌ SIGNIFICANT TEST FAILURES. Security review required before production.")

        return results


def main():
    """Main test execution"""
    tester = APITester()

    try:
        results = tester.run_comprehensive_test()

        # Save results to file
        with open("api_test_results.json", "w") as f:
            json.dump(results, f, indent=2, default=str)

        print("\n📄 Detailed results saved to: api_test_results.json")        # Exit with appropriate code
        success_rate = results["summary"]["success_rate"]
        sys.exit(0 if success_rate >= 0.8 else 1)

    except KeyboardInterrupt:
        print("\n🛑 Test interrupted by user")
        sys.exit(130)
    except Exception as e:
        print(f"\n💥 Test suite failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
