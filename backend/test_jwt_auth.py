#!/usr/bin/env python3
"""
JWT Authentication Test for Agent Mitra API
===========================================

Test JWT token generation and authentication flow.
"""

import requests
import json
import sys

# Configuration
BASE_URL = "http://127.0.0.1:8015"
API_BASE = f"{BASE_URL}/api/v1"

# Test user credentials
TEST_USER = {
    "phone_number": "+1234567890",
    "password": "testpass123"
}

def test_user_login():
    """Test user login and JWT token generation"""
    print("🔐 Testing user login...")

    try:
        response = requests.post(f"{API_BASE}/auth/login", json={
            "phone_number": TEST_USER["phone_number"],
            "password": TEST_USER["password"]
        })

        print(f"Login response status: {response.status_code}")

        if response.status_code == 200:
            data = response.json()
            print(f"✅ Login successful!")
            print(f"   Token type: {data.get('token_type', 'N/A')}")
            print(f"   Token preview: {data.get('access_token', '')[:50]}...")

            token = data.get("access_token")
            if token:
                print("✅ JWT token generated successfully")
                return token
            else:
                print("❌ No access token in response")
                return None
        else:
            print(f"❌ Login failed: {response.status_code}")
            print(f"   Response: {response.text}")
            return None

    except Exception as e:
        print(f"❌ Login error: {e}")
        return None

def test_authenticated_request(token):
    """Test making authenticated requests"""
    print("\n🔒 Testing authenticated requests...")

    headers = {'Authorization': f'Bearer {token}'}

    # Test user profile endpoint
    try:
        response = requests.get(f"{API_BASE}/users/me", headers=headers)
        print(f"User profile status: {response.status_code}")

        if response.status_code == 200:
            data = response.json()
            print("✅ Authenticated request successful!")
            print(f"   User: {data.get('first_name', 'N/A')} {data.get('last_name', 'N/A')}")
            print(f"   Role: {data.get('role', 'N/A')}")
            return True
        else:
            print(f"❌ Authenticated request failed: {response.status_code}")
            print(f"   Response: {response.text[:200]}")
            return False

    except Exception as e:
        print(f"❌ Authenticated request error: {e}")
        return False

def test_role_based_access(token):
    """Test role-based access control"""
    print("\n👥 Testing role-based access control...")

    headers = {'Authorization': f'Bearer {token}'}

    # Test endpoints that junior_agent should have access to
    test_cases = [
        ("GET", "/analytics/comprehensive/dashboard", False),  # Should be denied (needs higher role)
        ("GET", "/external/sms/send", False),  # POST endpoint, but GET should check permissions
        ("GET", "/users/me", True),  # Should be allowed
    ]

    success_count = 0

    for method, endpoint, should_succeed in test_cases:
        try:
            if method == "GET":
                response = requests.get(f"{API_BASE}{endpoint}", headers=headers)
            elif method == "POST":
                response = requests.post(f"{API_BASE}{endpoint}", headers=headers, json={})

            # Check if response matches expectation
            is_success = response.status_code in [200, 201, 204]
            is_expected = is_success == should_succeed

            status_icon = "✅" if is_expected else "❌"
            access_status = "granted" if is_success else "denied"

            print(f"{status_icon} {endpoint}: access {access_status} ({response.status_code})")

            if is_expected:
                success_count += 1

        except Exception as e:
            print(f"❌ Error testing {endpoint}: {e}")

    return success_count == len(test_cases)

def test_invalid_token():
    """Test invalid token handling"""
    print("\n🚫 Testing invalid token...")

    headers = {'Authorization': 'Bearer invalid.jwt.token.here'}

    try:
        response = requests.get(f"{API_BASE}/users/me", headers=headers)
        print(f"Invalid token status: {response.status_code}")

        if response.status_code in [401, 403]:
            print("✅ Invalid token properly rejected")
            return True
        else:
            print(f"❌ Invalid token not rejected: {response.status_code}")
            return False

    except Exception as e:
        print(f"❌ Invalid token test error: {e}")
        return False

def test_missing_token():
    """Test missing token handling"""
    print("\n🚫 Testing missing token...")

    try:
        response = requests.get(f"{API_BASE}/users/me")
        print(f"Missing token status: {response.status_code}")

        if response.status_code in [401, 403]:
            print("✅ Missing token properly rejected")
            return True
        else:
            print(f"❌ Missing token not rejected: {response.status_code}")
            return False

    except Exception as e:
        print(f"❌ Missing token test error: {e}")
        return False

def run_jwt_tests():
    """Run JWT authentication tests"""
    print("🚀 Agent Mitra JWT Authentication Test Suite")
    print("=" * 60)

    tests = [
        ("User Login", lambda: test_user_login() is not None),
    ]

    passed = 0
    total = len(tests)

    # Run login test first
    print(f"\n{'='*20} User Login {'='*20}")
    token = test_user_login()

    if token:
        passed += 1
        print("✅ User Login: PASSED")

        # Run authenticated tests
        auth_tests = [
            ("Authenticated Request", lambda: test_authenticated_request(token)),
            ("Role-Based Access", lambda: test_role_based_access(token)),
        ]

        for test_name, test_func in auth_tests:
            print(f"\n{'='*20} {test_name} {'='*20}")
            try:
                if test_func():
                    passed += 1
                    print(f"✅ {test_name}: PASSED")
                else:
                    print(f"❌ {test_name}: FAILED")
            except Exception as e:
                print(f"💥 {test_name}: ERROR - {e}")

        total += len(auth_tests)
    else:
        print("❌ User Login: FAILED")
        print("Skipping authenticated tests due to login failure")

    # Run unauthenticated tests
    unauth_tests = [
        ("Invalid Token", test_invalid_token),
        ("Missing Token", test_missing_token),
    ]

    for test_name, test_func in unauth_tests:
        print(f"\n{'='*20} {test_name} {'='*20}")
        try:
            if test_func():
                passed += 1
                print(f"✅ {test_name}: PASSED")
            else:
                print(f"❌ {test_name}: FAILED")
        except Exception as e:
            print(f"💥 {test_name}: ERROR - {e}")

    total += len(unauth_tests)

    # Summary
    print("\n" + "="*60)
    print("📋 JWT AUTHENTICATION TEST SUMMARY")
    print("="*60)
    print(f"Total Tests: {total}")
    print(f"Passed: {passed}")
    print(f"Failed: {total - passed}")
    print(".1f")

    if passed == total:
        print("🎉 ALL JWT TESTS PASSED!")
        print("✅ JWT authentication is working correctly")
        print("✅ Role-based access control is functional")
        print("✅ Token validation is working")
    elif passed >= total * 0.7:
        print("⚠️  MOST TESTS PASSED - Authentication system is functional")
    else:
        print("❌ SIGNIFICANT ISSUES - Review authentication implementation")

    return passed == total

if __name__ == "__main__":
    success = run_jwt_tests()
    sys.exit(0 if success else 1)
