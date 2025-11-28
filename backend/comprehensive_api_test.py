#!/usr/bin/env python3
"""
Comprehensive Agent Mitra API Testing Suite
============================================

Comprehensive testing script for all backend APIs including:
- Authentication & Authorization (JWT, RBAC)
- User Management
- Agent Management
- Policy Management
- Analytics & Reporting
- Campaign Management
- Content Management
- Quotes & Presentations
- External Services Integration
- Feature Flags
- Notifications
- Trial & Subscription Management
- Health Checks
- Import/Export
- Admin Functions

Run with: python comprehensive_api_test.py

Author: API Testing Automation
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

@dataclass
class TestResult:
    """Result of an individual API test"""
    endpoint: str
    method: str
    status_code: int
    success: bool
    error_message: Optional[str] = None
    response_time: float = 0.0
    user_role: Optional[str] = None

@dataclass
class APITestSuite:
    """Comprehensive API test suite"""
    endpoint: str
    method: str
    description: str
    user_role: str
    data: Optional[Dict] = None
    params: Optional[Dict] = None
    expected_status: Optional[List[int]] = None
    requires_auth: bool = True

class ComprehensiveAPITester:
    """Comprehensive API testing class with authentication and extensive endpoint coverage"""

    def __init__(self):
        self.tokens = {}
        self.session = requests.Session()
        self.session.headers.update({
            'Content-Type': 'application/json',
            'User-Agent': 'AgentMitra-Comprehensive-API-Test/1.0'
        })
        self.test_results = []
        self.endpoint_coverage = {}

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
        """Make authenticated API request with timing"""
        headers = {'Authorization': f'Bearer {token}'}
        url = f"{API_BASE}{endpoint}"

        start_time = time.time()
        try:
            if method.upper() == 'GET':
                response = self.session.get(url, headers=headers, params=params)
            elif method.upper() == 'POST':
                response = self.session.post(url, headers=headers, json=data)
            elif method.upper() == 'PUT':
                response = self.session.put(url, headers=headers, json=data)
            elif method.upper() == 'DELETE':
                response = self.session.delete(url, headers=headers)
            elif method.upper() == 'PATCH':
                response = self.session.patch(url, headers=headers, json=data)
            else:
                raise ValueError(f"Unsupported HTTP method: {method}")

            response_time = time.time() - start_time
            return response, response_time

        except Exception as e:
            print(f"❌ Request error: {e}")
            # Return a mock response for error handling
            class MockResponse:
                status_code = 500
                text = str(e)
                def json(self): return {"error": str(e)}
            return MockResponse(), time.time() - start_time

    def make_request(self, method: str, endpoint: str, data: Optional[Dict] = None,
                    params: Optional[Dict] = None, requires_auth: bool = True,
                    user_role: Optional[str] = None) -> TestResult:
        """Make API request and return test result"""
        token = None
        if requires_auth and user_role:
            token = self.tokens.get(user_role)

        try:
            if requires_auth and token:
                response, response_time = self.make_authenticated_request(method, endpoint, token, data, params)
            else:
                # Public endpoint
                start_time = time.time()
                url = f"{API_BASE}{endpoint}"
                if method.upper() == 'GET':
                    response = self.session.get(url, params=params)
                elif method.upper() == 'POST':
                    response = self.session.post(url, json=data)
                elif method.upper() == 'PUT':
                    response = self.session.put(url, json=data)
                elif method.upper() == 'DELETE':
                    response = self.session.delete(url)
                elif method.upper() == 'PATCH':
                    response = self.session.patch(url, json=data)
                response_time = time.time() - start_time

            # Determine success based on status code
            success = 200 <= response.status_code < 300

            result = TestResult(
                endpoint=endpoint,
                method=method,
                status_code=response.status_code,
                success=success,
                response_time=response_time,
                user_role=user_role
            )

            if not success:
                try:
                    error_data = response.json()
                    result.error_message = json.dumps(error_data)
                except:
                    result.error_message = response.text

            return result

        except Exception as e:
            return TestResult(
                endpoint=endpoint,
                method=method,
                status_code=500,
                success=False,
                error_message=str(e),
                user_role=user_role
            )

    def get_comprehensive_test_suites(self) -> List[APITestSuite]:
        """Get comprehensive list of all API endpoints to test"""

        return [
            # Authentication & Authorization
            APITestSuite("/auth/login", "POST", "User login", None, {"username": "test@test.com", "password": "test"}, requires_auth=False),
            APITestSuite("/auth/refresh", "POST", "Token refresh", "senior_agent", {"refresh_token": "dummy_token"}),
            APITestSuite("/auth/logout", "POST", "User logout", "senior_agent"),

            # Health Checks
            APITestSuite("/health", "GET", "Basic health check", None, requires_auth=False),
            APITestSuite("/api/v1/health", "GET", "API health check", None, requires_auth=False),
            APITestSuite("/health/database", "GET", "Database health check", "super_admin"),
            APITestSuite("/health/system", "GET", "System health check", "super_admin"),
            APITestSuite("/health/comprehensive", "GET", "Comprehensive health check", "super_admin"),
            APITestSuite("/metrics", "GET", "System metrics", "super_admin"),

            # User Management
            APITestSuite("/users/me", "GET", "Get current user profile", "senior_agent"),
            APITestSuite("/users/", "GET", "List all users", "super_admin"),
            APITestSuite("/users/me/preferences", "GET", "Get user preferences", "senior_agent"),
            APITestSuite("/users/me/preferences", "PUT", "Update user preferences", "senior_agent", {"theme": "dark"}),

            # Agent Management
            APITestSuite("/agents", "GET", "List agents", "regional_manager"),
            APITestSuite("/agents/me", "GET", "Get current agent profile", "senior_agent"),

            # Policy Management
            APITestSuite("/policies/", "GET", "List policies", "senior_agent"),
            APITestSuite("/policies/", "POST", "Create policy", "senior_agent", {
                "policy_number": "TEST001",
                "premium_amount": 1000.0,
                "status": "active"
            }),

            # Analytics & Reporting
            APITestSuite("/analytics/comprehensive/dashboard", "GET", "Comprehensive analytics dashboard", "regional_manager"),
            APITestSuite("/analytics/dashboard/overview", "GET", "Dashboard overview", "regional_manager"),
            APITestSuite("/analytics/agents/performance", "GET", "Agent performance analytics", "regional_manager"),
            APITestSuite("/analytics/policies/analytics", "GET", "Policy analytics", "regional_manager"),
            APITestSuite("/analytics/revenue/analytics", "GET", "Revenue analytics", "regional_manager"),

            # Campaign Management
            APITestSuite("/campaigns", "GET", "List campaigns", "senior_agent"),
            APITestSuite("/campaigns/templates", "GET", "Get campaign templates", "senior_agent"),

            # Content Management
            APITestSuite("/content/videos", "GET", "List videos", "senior_agent"),
            APITestSuite("/content/categories", "GET", "Get content categories", "senior_agent"),
            APITestSuite("/content/types", "GET", "Get content types", "senior_agent"),

            # Quotes & Presentations
            APITestSuite("/quotes/", "GET", "List quotes", "senior_agent"),
            APITestSuite("/quotes/categories/list", "GET", "Get quote categories", "senior_agent"),
            APITestSuite("/presentations/templates", "GET", "Get presentation templates", "senior_agent"),

            # External Services
            APITestSuite("/external/sms/send", "POST", "Send SMS", "senior_agent", {
                "to_phone": "+1234567890",
                "message": "Test SMS"
            }),

            # Feature Flags
            APITestSuite("/feature-flags/all", "GET", "Get all feature flags", "super_admin"),
            APITestSuite("/feature-flags/api/flags", "GET", "Get API feature flags", "senior_agent"),

            # Notifications
            APITestSuite("/notifications/", "GET", "List notifications", "senior_agent"),
            APITestSuite("/notifications/statistics", "GET", "Get notification statistics", "senior_agent"),

            # Trial & Subscription Management
            APITestSuite("/trial/analytics/overview", "GET", "Trial analytics overview", "super_admin"),
            APITestSuite("/subscription/plans", "GET", "List subscription plans", "senior_agent"),
            APITestSuite("/subscription/details", "GET", "Get subscription details", "senior_agent"),

            # RBAC (Role-Based Access Control)
            APITestSuite("/rbac/roles", "GET", "List roles", "super_admin"),
            APITestSuite("/rbac/permissions", "GET", "List permissions", "super_admin"),

            # Import/Export
            APITestSuite("/import/templates", "GET", "Get import templates", "senior_agent"),
            APITestSuite("/import/entity-fields/policies", "GET", "Get entity fields for policies", "senior_agent"),

            # Admin Functions
            APITestSuite("/admin/rate-limit/reset", "POST", "Reset rate limit", "super_admin", {"user_id": "test"}),

            # Tenants (Multi-tenancy)
            APITestSuite("/tenants/", "GET", "List tenants", "super_admin"),

            # Callbacks
            APITestSuite("/callbacks", "GET", "List callbacks", "senior_agent"),

            # Dashboard
            APITestSuite("/dashboard/analytics", "GET", "Dashboard analytics", "senior_agent"),

            # Test endpoints (if available)
            APITestSuite("/test/policies", "GET", "Test policies endpoint", "senior_agent"),
            APITestSuite("/test/notifications", "GET", "Test notifications endpoint", "senior_agent"),
            APITestSuite("/test/agent/profile", "GET", "Test agent profile endpoint", "senior_agent"),
        ]

    def test_health_endpoints(self) -> bool:
        """Test public health endpoints"""
        print("\n🔍 Testing public health endpoints...")

        health_endpoints = [
            ("/health", "GET"),
            ("/api/v1/health", "GET"),
        ]

        success_count = 0

        for endpoint, method in health_endpoints:
            result = self.make_request(method, endpoint, requires_auth=False)
            self.test_results.append(result)

            if result.success:
                print(f"✅ {endpoint} accessible")
                success_count += 1
            else:
                print(f"❌ {endpoint} failed: {result.status_code}")

        return success_count == len(health_endpoints)

    def test_unauthenticated_access(self) -> bool:
        """Test that protected endpoints require authentication"""
        print("\n🔒 Testing authentication requirements...")

        protected_endpoints = [
            ("/users/", "GET"),
            ("/analytics/comprehensive/dashboard", "GET"),
            ("/external/sms/send", "POST"),
            ("/feature-flags/all", "GET"),
        ]

        success_count = 0

        for endpoint, method in protected_endpoints:
            result = self.make_request(method, endpoint, requires_auth=False)
            self.test_results.append(result)

            if result.status_code in [401, 403]:
                print(f"✅ {endpoint} properly protected ({result.status_code})")
                success_count += 1
            else:
                print(f"❌ {endpoint} not properly protected ({result.status_code})")

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

    def test_comprehensive_api_coverage(self) -> bool:
        """Test comprehensive API coverage across all endpoints"""
        print("\n🚀 Testing comprehensive API coverage...")

        test_suites = self.get_comprehensive_test_suites()
        total_tests = len(test_suites)
        successful_tests = 0

        print(f"📋 Testing {total_tests} API endpoints...")

        for i, test_suite in enumerate(test_suites, 1):
            print(f"  [{i}/{total_tests}] Testing {test_suite.method} {test_suite.endpoint}")

            result = self.make_request(
                test_suite.method,
                test_suite.endpoint,
                data=test_suite.data,
                params=test_suite.params,
                requires_auth=test_suite.requires_auth,
                user_role=test_suite.user_role
            )

            self.test_results.append(result)

            # Track endpoint coverage
            endpoint_key = f"{test_suite.method} {test_suite.endpoint}"
            self.endpoint_coverage[endpoint_key] = result.success

            if result.success:
                successful_tests += 1
                print(f"    ✅ {test_suite.description}")
            else:
                print(f"    ❌ {test_suite.description}: {result.status_code}")
                if result.error_message:
                    print(f"       Error: {result.error_message[:100]}...")

        success_rate = successful_tests / total_tests if total_tests > 0 else 0
        print(".1f")
        return success_rate >= 0.5  # Consider 50% success as passing

    def generate_test_report(self) -> Dict[str, Any]:
        """Generate comprehensive test report"""
        print("\n📊 Generating comprehensive test report...")

        total_tests = len(self.test_results)
        successful_tests = sum(1 for result in self.test_results if result.success)
        failed_tests = total_tests - successful_tests

        # Group results by category
        categories = {
            "Authentication": [],
            "Health": [],
            "User Management": [],
            "Analytics": [],
            "External Services": [],
            "Other": []
        }

        for result in self.test_results:
            if "auth" in result.endpoint.lower():
                categories["Authentication"].append(result)
            elif "health" in result.endpoint.lower() or "metrics" in result.endpoint.lower():
                categories["Health"].append(result)
            elif "users" in result.endpoint.lower() or "agents" in result.endpoint.lower():
                categories["User Management"].append(result)
            elif "analytics" in result.endpoint.lower():
                categories["Analytics"].append(result)
            elif "external" in result.endpoint.lower():
                categories["External Services"].append(result)
            else:
                categories["Other"].append(result)

        # Calculate category statistics
        category_stats = {}
        for category, results in categories.items():
            if results:
                success_count = sum(1 for r in results if r.success)
                category_stats[category] = {
                    "total": len(results),
                    "successful": success_count,
                    "failed": len(results) - success_count,
                    "success_rate": success_count / len(results) if results else 0
                }

        # Response time analysis
        response_times = [r.response_time for r in self.test_results if r.response_time > 0]
        avg_response_time = sum(response_times) / len(response_times) if response_times else 0

        # Status code distribution
        status_codes = {}
        for result in self.test_results:
            status_codes[result.status_code] = status_codes.get(result.status_code, 0) + 1

        report = {
            "timestamp": datetime.now().isoformat(),
            "summary": {
                "total_endpoints_tested": len(self.endpoint_coverage),
                "total_tests_run": total_tests,
                "successful_tests": successful_tests,
                "failed_tests": failed_tests,
                "success_rate": successful_tests / total_tests if total_tests > 0 else 0,
                "average_response_time": avg_response_time,
                "endpoint_coverage": self.endpoint_coverage
            },
            "category_breakdown": category_stats,
            "status_code_distribution": status_codes,
            "detailed_results": [
                {
                    "endpoint": r.endpoint,
                    "method": r.method,
                    "status_code": r.status_code,
                    "success": r.success,
                    "response_time": r.response_time,
                    "user_role": r.user_role,
                    "error_message": r.error_message
                }
                for r in self.test_results
            ]
        }

        return report

    def run_comprehensive_test(self) -> Dict[str, Any]:
        """Run comprehensive API test suite"""
        print("🚀 Starting Agent Mitra Comprehensive API Test Suite")
        print("=" * 80)
        print(f"Target API: {BASE_URL}")
        print(f"Test Start: {datetime.now().isoformat()}")
        print("=" * 80)

        results = {
            "timestamp": datetime.now().isoformat(),
            "tests": {}
        }

        # Test sequence
        test_sequence = [
            ("health_endpoints", self.test_health_endpoints),
            ("unauthenticated_access", self.test_unauthenticated_access),
            ("user_authentication", self.test_user_authentication),
            ("comprehensive_api_coverage", self.test_comprehensive_api_coverage),
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
                traceback.print_exc()
                results["tests"][test_name] = False

        # Generate comprehensive report
        detailed_report = self.generate_test_report()
        results["detailed_report"] = detailed_report

        # Summary
        print("\n" + "="*80)
        print("📋 COMPREHENSIVE TEST SUMMARY")
        print("="*80)
        print(f"Total Test Categories: {total_tests}")
        print(f"Passed Categories: {passed_tests}")
        print(f"Failed Categories: {total_tests - passed_tests}")
        print(f"Success Rate: {passed_tests / total_tests * 100:.1f}%")
        print(f"Total API Endpoints Tested: {detailed_report['summary']['total_endpoints_tested']}")
        print(f"Total Individual Tests: {detailed_report['summary']['total_tests_run']}")
        print(f"Successful Tests: {detailed_report['summary']['successful_tests']}")
        print(f"Failed Tests: {detailed_report['summary']['failed_tests']}")
        print(f"API Test Success Rate: {detailed_report['summary']['success_rate'] * 100:.1f}%")
        print(f"Average Response Time: {detailed_report['summary']['average_response_time']:.2f}s")
        # Category breakdown
        print("\n📊 Category Breakdown:")
        for category, stats in detailed_report['category_breakdown'].items():
            if stats['total'] > 0:
                print(f"  {category}: {stats['successful']}/{stats['total']} ({stats['success_rate'] * 100:.1f}%)")
        # Status code distribution
        print("\n📈 Status Code Distribution:")
        for status, count in sorted(detailed_report['status_code_distribution'].items()):
            status_desc = {
                200: "OK", 201: "Created", 400: "Bad Request", 401: "Unauthorized",
                403: "Forbidden", 404: "Not Found", 422: "Unprocessable Entity", 500: "Server Error"
            }.get(status, "Unknown")
            print(f"  {status} ({status_desc}): {count} times")

        if passed_tests == total_tests:
            print("\n🎉 ALL TESTS PASSED! API is functioning correctly.")
        elif passed_tests > total_tests * 0.7:
            print("\n⚠️  MOST TESTS PASSED. Review failed tests for minor issues.")
        else:
            print("\n❌ SIGNIFICANT TEST FAILURES. API requires attention.")

        return results


def main():
    """Main test execution"""
    tester = ComprehensiveAPITester()

    try:
        results = tester.run_comprehensive_test()

        # Save results to file
        with open("comprehensive_api_test_results.json", "w") as f:
            json.dump(results, f, indent=2, default=str)

        print("\n📄 Detailed results saved to: comprehensive_api_test_results.json")

        # Exit with appropriate code
        success_rate = results["detailed_report"]["summary"]["success_rate"]
        sys.exit(0 if success_rate >= 0.7 else 1)

    except KeyboardInterrupt:
        print("\n🛑 Test interrupted by user")
        sys.exit(130)
    except Exception as e:
        print(f"\n💥 Test suite failed: {e}")
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
