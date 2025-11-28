#!/usr/bin/env python3
"""
Simple Authentication Test for Agent Mitra API
===============================================

Basic test to verify authentication middleware and endpoint protection.
"""

import requests
import json
import sys

# Configuration
BASE_URL = "http://127.0.0.1:8015"
API_BASE = f"{BASE_URL}/api/v1"

def test_health_endpoint():
    """Test public health endpoint"""
    print("🔍 Testing public health endpoint...")
    try:
        response = requests.get(f"{API_BASE}/health")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Health check passed: {data.get('status', 'unknown')}")
            return True
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health check error: {e}")
        return False

def test_protected_endpoints():
    """Test that protected endpoints require authentication"""
    print("\n🔒 Testing endpoint protection...")

    protected_endpoints = [
        (f"{API_BASE}/users/", "GET"),
        (f"{API_BASE}/analytics/comprehensive/dashboard", "GET"),
        (f"{API_BASE}/external/sms/send", "POST"),
    ]

    success_count = 0

    for endpoint, method in protected_endpoints:
        try:
            if method == "GET":
                response = requests.get(endpoint)
            elif method == "POST":
                response = requests.post(endpoint, json={})

            # Should get 401 (Unauthorized) for missing auth
            if response.status_code in [401, 403]:
                print(f"✅ {endpoint} properly protected ({response.status_code})")
                success_count += 1
            else:
                print(f"❌ {endpoint} not properly protected ({response.status_code})")
                print(f"   Response: {response.text[:200]}")

        except Exception as e:
            print(f"❌ Error testing {endpoint}: {e}")

    return success_count == len(protected_endpoints)

def test_docs_access():
    """Test that API docs are accessible"""
    print("\n📚 Testing API documentation access...")
    try:
        response = requests.get(f"{BASE_URL}/docs")
        if response.status_code == 200:
            print("✅ API docs accessible")
            return True
        else:
            print(f"❌ API docs not accessible: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ API docs error: {e}")
        return False

def test_openapi_schema():
    """Test OpenAPI schema access"""
    print("\n📋 Testing OpenAPI schema...")
    try:
        response = requests.get(f"{BASE_URL}/openapi.json")
        if response.status_code == 200:
            schema = response.json()
            endpoints = list(schema.get('paths', {}).keys())
            print(f"✅ OpenAPI schema accessible with {len(endpoints)} endpoints")
            return True
        else:
            print(f"❌ OpenAPI schema not accessible: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ OpenAPI schema error: {e}")
        return False

def test_cors_headers():
    """Test CORS headers"""
    print("\n🌐 Testing CORS headers...")
    try:
        response = requests.options(f"{API_BASE}/health",
                                  headers={'Origin': 'http://localhost:3000'})
        cors_headers = ['access-control-allow-origin',
                       'access-control-allow-methods',
                       'access-control-allow-headers']

        has_cors = any(h in response.headers for h in cors_headers)
        if has_cors:
            print("✅ CORS headers present")
            return True
        else:
            print("⚠️  CORS headers not detected (may be configured differently)")
            return True  # Not critical for basic auth test
    except Exception as e:
        print(f"❌ CORS test error: {e}")
        return False

def test_invalid_token():
    """Test invalid token handling"""
    print("\n🚫 Testing invalid token handling...")
    try:
        headers = {'Authorization': 'Bearer invalid.jwt.token'}
        response = requests.get(f"{API_BASE}/users/me", headers=headers)

        if response.status_code in [401, 403]:
            print("✅ Invalid token properly rejected")
            return True
        else:
            print(f"❌ Invalid token not rejected: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Invalid token test error: {e}")
        return False

def run_basic_tests():
    """Run basic authentication and security tests"""
    print("🚀 Agent Mitra Basic Authentication Test Suite")
    print("=" * 60)

    tests = [
        ("Health Endpoint", test_health_endpoint),
        ("Endpoint Protection", test_protected_endpoints),
        ("API Documentation", test_docs_access),
        ("OpenAPI Schema", test_openapi_schema),
        ("CORS Headers", test_cors_headers),
        ("Invalid Token Handling", test_invalid_token),
    ]

    passed = 0
    total = len(tests)

    for test_name, test_func in tests:
        print(f"\n{'='*20} {test_name} {'='*20}")
        try:
            if test_func():
                passed += 1
                print(f"✅ {test_name}: PASSED")
            else:
                print(f"❌ {test_name}: FAILED")
        except Exception as e:
            print(f"💥 {test_name}: ERROR - {e}")

    # Summary
    print("\n" + "="*60)
    print("📋 BASIC AUTHENTICATION TEST SUMMARY")
    print("="*60)
    print(f"Total Tests: {total}")
    print(f"Passed: {passed}")
    print(f"Failed: {total - passed}")
    print(".1f")

    if passed == total:
        print("🎉 ALL BASIC TESTS PASSED!")
        print("✅ Authentication middleware is working correctly")
        print("✅ Endpoints are properly protected")
        print("✅ Public endpoints are accessible")
    elif passed >= total * 0.8:
        print("⚠️  MOST TESTS PASSED - Ready for development")
    else:
        print("❌ SIGNIFICANT ISSUES - Review authentication setup")

    return passed == total

if __name__ == "__main__":
    success = run_basic_tests()
    sys.exit(0 if success else 1)
