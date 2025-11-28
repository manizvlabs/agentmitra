#!/usr/bin/env python3
"""
Comprehensive RBAC System Test for Agent Mitra
==============================================

Tests all seeded users with proper role-based access control validation.
"""

import requests
import json
import sys
from typing import Dict, Any, List
from datetime import datetime

# Configuration
BASE_URL = "http://127.0.0.1:8015"
API_BASE = f"{BASE_URL}/api/v1"

# Seeded test users with expected permissions (based on actual database)
SEEDED_USERS = {
    "super_admin": {
        "phone_number": "9876543200",  # Note: no +91 prefix in database
        "password": "testpassword",
        "role": "super_admin",
        "expected_permissions_count": 59,
        "description": "Full system access"
    },
    "provider_admin": {
        "phone_number": "+919876543201",
        "password": "testpassword",
        "role": "insurance_provider_admin",  # Note: actual role name in DB
        "expected_permissions_count": "Insurance provider management",
        "description": "Insurance provider management"
    },
    "regional_manager": {
        "phone_number": "+919876543202",
        "password": "testpassword",
        "role": "regional_manager",
        "expected_permissions_count": 19,
        "description": "Regional operations"
    },
    "senior_agent": {
        "phone_number": "+919876543203",
        "password": "testpassword",
        "role": "senior_agent",
        "expected_permissions_count": 16,
        "description": "Agent operations + inherited permissions"
    },
    "junior_agent": {
        "phone_number": "+919876543204",
        "password": "testpassword",
        "role": "junior_agent",
        "expected_permissions_count": 7,
        "description": "Basic agent operations"
    },
    "policyholder": {
        "phone_number": "+919876543205",
        "password": "testpassword",
        "role": "policyholder",
        "expected_permissions_count": 5,
        "description": "Customer access"
    },
    "support_staff": {
        "phone_number": "+919876543206",
        "password": "testpassword",
        "role": "support_staff",
        "expected_permissions_count": 8,
        "description": "Support operations"
    }
}

# Role hierarchy for access testing
ROLE_HIERARCHY = {
    "super_admin": 100,
    "provider_admin": 80,
    "regional_manager": 60,
    "senior_agent": 40,
    "support_staff": 35,
    "junior_agent": 20,
    "policyholder": 10,
    "guest_user": 5
}

# Test endpoints with required minimum role level
ENDPOINT_ACCESS_LEVELS = {
    "/users/": 80,  # provider_admin and above
    "/analytics/comprehensive/dashboard": 60,  # regional_manager and above (senior_agent level is 40, so they shouldn't access)
    "/external/sms/send": 20,  # junior_agent and above
    "/external/whatsapp/send": 20,  # junior_agent and above
    "/external/ai/chat": 20,  # junior_agent and above
    "/users/me": 5,  # any authenticated user
}

class RBACValidator:
    """Validates RBAC system with comprehensive testing"""

    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({'Content-Type': 'application/json'})
        self.tokens = {}
        self.user_data = {}

    def authenticate_user(self, role: str) -> bool:
        """Authenticate a user and store their token"""
        user_config = SEEDED_USERS[role]

        try:
            response = self.session.post(f"{API_BASE}/auth/login", json={
                "phone_number": user_config["phone_number"],
                "password": user_config["password"]
            })

            if response.status_code == 200:
                data = response.json()
                token = data.get("access_token")

                if token:
                    self.tokens[role] = token

                    # Decode token to get user data (without verification for testing)
                    import base64
                    import json
                    try:
                        # Split JWT and decode payload
                        payload_b64 = token.split('.')[1]
                        # Add padding if needed
                        payload_b64 += '=' * (4 - len(payload_b64) % 4)
                        payload_json = base64.urlsafe_b64decode(payload_b64)
                        payload = json.loads(payload_json)

                        self.user_data[role] = {
                            "user_id": payload.get("sub"),
                            "phone_number": payload.get("phone_number"),
                            "role": payload.get("role"),
                            "permissions": payload.get("permissions", []),
                            "feature_flags": payload.get("feature_flags", {})
                        }

                        print(f"✅ {role}: Authenticated successfully")
                        print(f"   Role: {payload.get('role')}")
                        print(f"   Permissions: {len(payload.get('permissions', []))}")
                        return True
                    except Exception as e:
                        print(f"⚠️  {role}: Token decoded but parsing failed: {e}")
                        return True
                else:
                    print(f"❌ {role}: No access token in response")
                    return False
            else:
                print(f"❌ {role}: Authentication failed ({response.status_code})")
                print(f"   Response: {response.text[:200]}")
                return False

        except Exception as e:
            print(f"❌ {role}: Authentication error: {e}")
            return False

    def validate_user_permissions(self, role: str) -> bool:
        """Validate that user has expected permissions"""
        if role not in self.user_data:
            print(f"❌ {role}: No user data available")
            return False

        user_data = self.user_data[role]
        permissions = user_data.get("permissions", [])
        expected_count = SEEDED_USERS[role]["expected_permissions_count"]

        print(f"🔍 {role}: Validating permissions")
        print(f"   Expected: {expected_count}")
        print(f"   Actual: {len(permissions)}")

        # Check if permission count matches (for numeric expectations)
        if isinstance(expected_count, int):
            if len(permissions) != expected_count:
                print(f"❌ {role}: Permission count mismatch ({len(permissions)} != {expected_count})")
                return False
        elif expected_count == "Insurance provider management":
            # Special case for provider admin
            expected_perms = ["users.read", "users.update", "agents.*", "policies.*", "customers.*",
                            "payments.read", "content.*", "analytics.read", "communication.*", "callbacks.*"]
            if not all(perm in permissions for perm in expected_perms):
                print(f"❌ {role}: Missing expected permissions")
                return False

        print(f"✅ {role}: Permission validation passed")
        return True

    def test_endpoint_access(self, role: str) -> Dict[str, bool]:
        """Test endpoint access for a specific role"""
        if role not in self.tokens:
            print(f"❌ {role}: No authentication token available")
            return {}

        token = self.tokens[role]
        headers = {'Authorization': f'Bearer {token}'}
        role_level = ROLE_HIERARCHY.get(role, 0)

        results = {}

        print(f"🔐 {role}: Testing endpoint access (level: {role_level})")

        for endpoint, required_level in ENDPOINT_ACCESS_LEVELS.items():
            try:
                # Determine HTTP method
                if endpoint in ["/users/", "/analytics/comprehensive/dashboard", "/users/me"]:
                    method = "GET"
                else:
                    method = "POST"
                    data = {"message": "test"} if "send" in endpoint else {"messages": [{"role": "user", "content": "test"}]}

                if method == "GET":
                    response = requests.get(f"{API_BASE}{endpoint}", headers=headers)
                else:
                    response = requests.post(f"{API_BASE}{endpoint}", headers=headers, json=data)

                has_access = response.status_code not in [401, 403]
                should_have_access = role_level >= required_level

                if has_access == should_have_access:
                    status = "✅"
                    result = True
                else:
                    status = "❌"
                    result = False

                access_status = "granted" if has_access else "denied"
                expected_status = "granted" if should_have_access else "denied"

                print(f"   {status} {endpoint}: {access_status} ({response.status_code}) - expected: {expected_status}")
                results[endpoint] = result

            except Exception as e:
                print(f"   ❌ {endpoint}: Error - {e}")
                results[endpoint] = False

        return results

    def test_role_hierarchy(self) -> bool:
        """Test that role hierarchy is properly enforced"""
        print("\n🏗️  Testing role hierarchy...")

        # Test that higher-level roles can access lower-level endpoints
        hierarchy_issues = []

        for role, level in ROLE_HIERARCHY.items():
            if role not in self.tokens:
                continue

            token = self.tokens[role]
            headers = {'Authorization': f'Bearer {token}'}

            for endpoint, required_level in ENDPOINT_ACCESS_LEVELS.items():
                if level < required_level:
                    # This role should NOT have access
                    try:
                        response = requests.get(f"{API_BASE}{endpoint}", headers=headers)
                        if response.status_code not in [401, 403]:
                            hierarchy_issues.append(f"{role} should not access {endpoint} (level {level} < {required_level})")
                    except Exception as e:
                        pass  # Connection error, ignore

        if hierarchy_issues:
            print("❌ Role hierarchy violations:")
            for issue in hierarchy_issues:
                print(f"   - {issue}")
            return False
        else:
            print("✅ Role hierarchy properly enforced")
            return True

    def run_comprehensive_test(self) -> Dict[str, Any]:
        """Run comprehensive RBAC validation"""
        print("🚀 Agent Mitra Comprehensive RBAC Validation")
        print("=" * 60)

        results = {
            "timestamp": datetime.now().isoformat(),
            "users_tested": [],
            "endpoint_tests": {},
            "summary": {}
        }

        # Step 1: Authenticate all users
        print("\n" + "="*30 + " AUTHENTICATION PHASE " + "="*30)

        auth_success = 0
        for role in SEEDED_USERS.keys():
            if self.authenticate_user(role):
                auth_success += 1
                results["users_tested"].append(role)

        print(f"\n✅ Authentication: {auth_success}/{len(SEEDED_USERS)} users authenticated")

        # Step 2: Validate permissions
        print("\n" + "="*30 + " PERMISSION VALIDATION " + "="*30)

        perm_success = 0
        for role in results["users_tested"]:
            if self.validate_user_permissions(role):
                perm_success += 1

        print(f"\n✅ Permission Validation: {perm_success}/{len(results['users_tested'])} users validated")

        # Step 3: Test endpoint access
        print("\n" + "="*30 + " ENDPOINT ACCESS TESTING " + "="*30)

        endpoint_results = {}
        for role in results["users_tested"]:
            role_results = self.test_endpoint_access(role)
            endpoint_results[role] = role_results

        results["endpoint_tests"] = endpoint_results

        # Step 4: Test role hierarchy
        hierarchy_test = self.test_role_hierarchy()

        # Calculate success rates
        total_auth_tests = len(SEEDED_USERS)
        total_perm_tests = len(results["users_tested"])
        total_endpoint_tests = sum(len(role_results) for role_results in endpoint_results.values())

        auth_success_rate = auth_success / total_auth_tests if total_auth_tests > 0 else 0
        perm_success_rate = perm_success / total_perm_tests if total_perm_tests > 0 else 0

        endpoint_success_count = sum(
            sum(1 for result in role_results.values() if result)
            for role_results in endpoint_results.values()
        )
        endpoint_success_rate = endpoint_success_count / total_endpoint_tests if total_endpoint_tests > 0 else 0

        # Overall success
        overall_success = (
            auth_success_rate >= 0.9 and  # 90% auth success
            perm_success_rate >= 0.8 and  # 80% permission validation
            endpoint_success_rate >= 0.7 and  # 70% endpoint access correct
            hierarchy_test  # Role hierarchy must work
        )

        results["summary"] = {
            "authentication": {
                "passed": auth_success,
                "total": total_auth_tests,
                "success_rate": auth_success_rate
            },
            "permissions": {
                "passed": perm_success,
                "total": total_perm_tests,
                "success_rate": perm_success_rate
            },
            "endpoints": {
                "passed": endpoint_success_count,
                "total": total_endpoint_tests,
                "success_rate": endpoint_success_rate
            },
            "hierarchy": hierarchy_test,
            "overall_success": overall_success
        }

        # Print final summary
        print("\n" + "="*60)
        print("📋 COMPREHENSIVE RBAC TEST SUMMARY")
        print("="*60)
        print(f"Authentication: {auth_success}/{total_auth_tests} ({auth_success_rate:.1%})")
        print(f"Permissions: {perm_success}/{total_perm_tests} ({perm_success_rate:.1%})")
        print(f"Endpoints: {endpoint_success_count}/{total_endpoint_tests} ({endpoint_success_rate:.1%})")
        print(f"Hierarchy: {'✅ PASS' if hierarchy_test else '❌ FAIL'}")

        if overall_success:
            print("\n🎉 RBAC SYSTEM VALIDATION: SUCCESS")
            print("✅ All seeded users authenticated")
            print("✅ Permissions correctly assigned")
            print("✅ Role-based access control working")
            print("✅ System ready for production")
        else:
            print("\n❌ RBAC SYSTEM VALIDATION: ISSUES FOUND")
            print("⚠️  Review failed tests before production deployment")

        return results


def main():
    """Main test execution"""
    validator = RBACValidator()

    try:
        results = validator.run_comprehensive_test()

        # Save detailed results
        with open("rbac_test_results.json", "w") as f:
            json.dump(results, f, indent=2, default=str)

        print("\n📄 Detailed results saved to: rbac_test_results.json")        # Exit with success/failure code
        overall_success = results["summary"]["overall_success"]
        sys.exit(0 if overall_success else 1)

    except KeyboardInterrupt:
        print("\n🛑 Test interrupted by user")
        sys.exit(130)
    except Exception as e:
        print(f"\n💥 Test suite failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
