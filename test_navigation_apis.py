#!/usr/bin/env python3
"""
API Endpoint Testing Script for Agent Mitra Navigation Screens

This script verifies that all API endpoints used in the Flutter navigation screens
match and comply with the endpoints listed in the project plan (section 2.1).

Tests endpoints using nginx proxy URLs (localhost/api/v1/*)
"""

import requests
import json
import sys
from typing import Dict, List, Tuple
import time

# API base configuration
API_BASE_URL = "http://localhost/api/v1"  # nginx proxy
HEADERS = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
}

# Seeded users for RBAC testing
SEED_USERS = {
    'super_admin': {
        'phone': '+919876543200',
        'password': 'testpassword',
        'role': 'Super Admin',
        'permissions': 59,
        'description': 'Full system access'
    },
    'provider_admin': {
        'phone': '+919876543201',
        'password': 'testpassword',
        'role': 'Provider Admin',
        'permissions': 0,  # Not specified
        'description': 'Insurance provider management'
    },
    'regional_manager': {
        'phone': '+919876543202',
        'password': 'testpassword',
        'role': 'Regional Manager',
        'permissions': 19,
        'description': 'Regional operations'
    },
    'senior_agent': {
        'phone': '+919876543203',
        'password': 'testpassword',
        'role': 'Senior Agent',
        'permissions': 16,
        'description': 'Agent operations + inherited permissions'
    },
    'junior_agent': {
        'phone': '+919876543204',
        'password': 'testpassword',
        'role': 'Junior Agent',
        'permissions': 7,
        'description': 'Basic agent operations'
    },
    'policyholder': {
        'phone': '+919876543205',
        'password': 'testpassword',
        'role': 'Policyholder',
        'permissions': 5,
        'description': 'Customer access'
    },
    'support_staff': {
        'phone': '+919876543206',
        'password': 'testpassword',
        'role': 'Support Staff',
        'permissions': 8,
        'description': 'Support operations'
    }
}

# Endpoints used in Flutter navigation screens (CORRECTED to match project plan section 2.1)
NAVIGATION_ENDPOINTS = {
    # System & Configuration (✅ All exist in project plan section 2.1)
    '/dashboard/system-overview': 'GET',
    '/health/system': 'GET',
    '/health/database': 'GET',
    '/metrics': 'GET',
    '/tenants/': 'GET',
    '/rbac/feature-flags': 'GET',
    '/notifications/settings': 'GET',

    # Users Management (✅ All exist in project plan section 2.1)
    '/users/': 'GET',
    '/rbac/roles': 'GET',
    '/rbac/users/assign-role': 'POST',

    # Analytics (✅ All exist in project plan section 2.1)
    '/analytics/dashboard/overview': 'GET',
    '/analytics/payments/analytics': 'GET',  # CORRECTED: was calling non-existent payment endpoints
    '/analytics/reports/summary': 'GET',
    '/analytics/export/policies': 'GET',

    # Dashboard & Analytics (✅ All exist in project plan section 2.1)
    '/dashboard/analytics': 'GET',
    '/dashboard/home': 'GET',
    '/dashboard/presentations/carousel': 'GET',
    '/dashboard/feature-tiles': 'GET',

    # Agents (✅ All exist in project plan section 2.1)
    '/agents/profile': 'GET',
    '/agents/performance/metrics': 'GET',

    # Policies (✅ All exist in project plan section 2.1)
    '/policies/': 'GET',
    '/policies/{policy_id}': 'GET',
    '/policies/{policy_id}/premiums': 'GET',
    '/policies/{policy_id}/claims': 'GET',
    '/policies/{policy_id}/coverage': 'GET',
    '/policies/': 'POST',
    '/policies/{policy_id}': 'PUT',

    # Chat & Communication (✅ All exist in project plan section 2.1)
    '/chat/sessions': 'POST',
    '/chat/sessions/{session_id}/messages': 'POST',
    '/external/whatsapp/send': 'POST',

    # Notifications (✅ All exist in project plan section 2.1)
    '/notifications/': 'GET',
    '/notifications/{notification_id}': 'PATCH',
    '/notifications/read': 'PATCH',
    '/notifications/statistics': 'GET',
    '/notifications/settings': 'PUT',
    '/notifications/device-token': 'POST',

    # Quotes (✅ Exists in project plan section 2.1)
    '/quotes/': 'POST',  # CORRECTED: was calling /quotes/requests

    # Claims (✅ Exists in project plan section 2.1)
    '/claims': 'POST',

    # Content & Learning (✅ All exist in project plan section 2.1)
    '/content/videos': 'GET',
    '/content/categories': 'GET',

    # Import (✅ All exist in project plan section 2.1)
    '/import/templates': 'GET',
    '/import/upload': 'POST',  # CORRECTED: was calling /import/excel

    # Feature Flags (✅ Exists in project plan section 2.1)
    '/feature-flags/user/{user_id}': 'GET',

    # User Profile (✅ All exist in project plan section 2.1)
    '/users/me': 'GET',
    '/users/{user_id}/preferences': 'GET',
    '/users/{user_id}/preferences': 'PUT',
    '/users/me': 'PUT',
    '/auth/change-password': 'PUT',
}

# Project Plan Endpoints (Section 2.1) - Key categories
PROJECT_PLAN_ENDPOINTS = {
    # Authentication & Authorization
    'POST /api/v1/auth/login': 'Agent code or phone + password login',
    'POST /api/v1/auth/logout': 'Logout user and invalidate session',

    # Users
    'GET /api/v1/users/me': 'Get current user profile',
    'GET /api/v1/users/': 'Search and filter users',
    'GET /api/v1/users/{user_id}': 'Get user by ID',
    'PUT /api/v1/users/{user_id}': 'Update user profile',
    'DELETE /api/v1/users/{user_id}': 'Deactivate user',

    # Agents
    'GET /api/v1/agents/profile': 'Get current agent profile',
    'PUT /api/v1/agents/profile': 'Update agent profile',
    'GET /api/v1/agents/performance/metrics': 'Get performance metrics',

    # Policies
    'GET /api/v1/policies/': 'List policies with filtering',
    'GET /api/v1/policies/{policy_id}': 'Get policy details',
    'POST /api/v1/policies/': 'Create new policy',
    'PUT /api/v1/policies/{policy_id}': 'Update policy',
    'GET /api/v1/policies/{policy_id}/coverage': 'Get coverage details',
    'GET /api/v1/policies/{policy_id}/premiums': 'Get premium schedule',
    'GET /api/v1/policies/{policy_id}/claims': 'Get claims history',

    # Dashboard
    'GET /api/v1/dashboard/analytics': 'Dashboard analytics summary',
    'GET /api/v1/dashboard/home': 'Agent home dashboard',
    'GET /api/v1/dashboard/system-overview': 'System overview (Super Admin)',

    # Presentations
    'GET /api/v1/presentations/agent/{agent_id}/active': 'Get active presentation',
    'POST /api/v1/presentations/agent/{agent_id}': 'Create presentation',
    'PUT /api/v1/presentations/agent/{agent_id}/{presentation_id}': 'Update presentation',

    # Chat & External Services
    'POST /api/v1/chat/sessions': 'Create chat session',
    'POST /api/v1/chat/sessions/{session_id}/messages': 'Send message',
    'POST /api/v1/external/whatsapp/send': 'Send WhatsApp message',
    'POST /api/v1/external/whatsapp/otp': 'Send WhatsApp OTP',

    # Analytics
    'GET /api/v1/analytics/roi/agent/{agent_id}': 'ROI analytics',
    'GET /api/v1/analytics/dashboard/overview': 'Dashboard overview',
    'GET /api/v1/analytics/agents/performance/{agent_id}': 'Agent performance',

    # Campaigns
    'POST /api/v1/campaigns': 'Create campaign',
    'GET /api/v1/campaigns': 'List campaigns',

    # Content
    'GET /api/v1/content/videos': 'Get video library',
    'POST /api/v1/content/upload': 'Upload content file',

    # Notifications
    'GET /api/v1/notifications/': 'Get notifications',
    'PATCH /api/v1/notifications/{notification_id}/read': 'Mark as read',
    'POST /api/v1/notifications/device-token': 'Register device token',

    # Data Import
    'POST /api/v1/import/upload': 'Upload Excel file',
    'POST /api/v1/import/validate/{file_id}': 'Validate file',
    'POST /api/v1/import/data': 'Import data',

    # RBAC
    'GET /api/v1/rbac/roles': 'List all roles',
    'POST /api/v1/rbac/users/assign-role': 'Assign role',

    # Feature Flags
    'GET /api/v1/feature-flags/user/{user_id}': 'Get feature flags',

    # System
    'GET /api/v1/tenants/': 'List all tenants',
    'GET /api/v1/tenants/{tenant_id}': 'Get tenant details',
    'GET /api/v1/health/system': 'System health check',
    'GET /api/v1/metrics': 'Prometheus metrics',
}

class APIEndpointTester:
    def __init__(self, base_url: str = API_BASE_URL):
        self.base_url = base_url
        self.session = requests.Session()
        self.session.headers.update(HEADERS)
        self.auth_tokens = {}  # Store tokens for different users

    def authenticate_user(self, phone: str, password: str) -> Tuple[bool, str, dict]:
        """Authenticate a user and get access token"""
        try:
            auth_data = {
                'phone_number': phone,
                'password': password
            }

            response = requests.post(
                f"{self.base_url.replace('/api/v1', '')}/api/v1/auth/login",
                json=auth_data,
                headers=HEADERS,
                timeout=10
            )

            if response.status_code == 200:
                data = response.json()
                token = data.get('access_token')
                if token:
                    return True, "Authenticated successfully", {'Authorization': f'Bearer {token}'}
                else:
                    return False, "No access token in response", {}
            elif response.status_code == 401:
                return False, "Invalid credentials", {}
            else:
                return False, f"Auth failed with status {response.status_code}: {response.text}", {}

        except Exception as e:
            return False, f"Authentication error: {str(e)}", {}

    def test_endpoint_with_auth(self, endpoint: str, method: str, auth_headers: dict = None) -> Tuple[bool, str, int]:
        """Test endpoint with optional authentication"""
        url = f"{self.base_url}{endpoint}"

        headers = HEADERS.copy()
        if auth_headers:
            headers.update(auth_headers)

        try:
            if method.upper() == 'GET':
                response = requests.get(url, headers=headers, timeout=10)
            elif method.upper() == 'POST':
                response = requests.post(url, json={}, headers=headers, timeout=10)
            elif method.upper() == 'PUT':
                response = requests.put(url, json={}, headers=headers, timeout=10)
            elif method.upper() == 'PATCH':
                response = requests.patch(url, json={}, headers=headers, timeout=10)
            elif method.upper() == 'DELETE':
                response = requests.delete(url, headers=headers, timeout=10)
            else:
                return False, f"Unsupported method: {method}", 0

            # For authenticated requests, 200-299 is success, 403 is access denied (RBAC working)
            if auth_headers:
                if response.status_code in [200, 201, 204]:
                    return True, "Access granted", response.status_code
                elif response.status_code == 403:
                    return False, "Access denied (RBAC working)", response.status_code
                elif response.status_code == 401:
                    return False, "Authentication failed", response.status_code
                else:
                    return False, f"Unexpected status: {response.status_code}", response.status_code
            else:
                # For unauthenticated requests, 401 is expected for protected endpoints
                if response.status_code in [200, 201, 204]:
                    return True, "Success", response.status_code
                elif response.status_code == 401:
                    return True, "Auth required (expected)", response.status_code
                else:
                    return False, f"Unexpected status: {response.status_code}", response.status_code

        except Exception as e:
            return False, f"Error: {str(e)}", 0

    def test_endpoint(self, endpoint: str, method: str) -> Tuple[bool, str, int]:
        """Test a single endpoint"""
        url = f"{self.base_url}{endpoint}"

        try:
            if method.upper() == 'GET':
                response = self.session.get(url, timeout=10)
            elif method.upper() == 'POST':
                response = self.session.post(url, json={}, timeout=10)
            elif method.upper() == 'PUT':
                response = self.session.put(url, json={}, timeout=10)
            elif method.upper() == 'PATCH':
                response = self.session.patch(url, json={}, timeout=10)
            elif method.upper() == 'DELETE':
                response = self.session.delete(url, timeout=10)
            else:
                return False, f"Unsupported method: {method}", 0

            # Consider 200-299 as success, 401/403 as auth issues (expected), 404 as not implemented
            if response.status_code in [200, 201, 204]:
                return True, "Success", response.status_code
            elif response.status_code in [401, 403]:
                return True, "Auth required (expected)", response.status_code
            elif response.status_code == 404:
                return False, "Not found (endpoint may not be implemented)", response.status_code
            elif response.status_code >= 500:
                return False, f"Server error: {response.text[:100]}", response.status_code
            else:
                return False, f"Unexpected status: {response.status_code}", response.status_code

        except requests.exceptions.ConnectionError:
            return False, "Connection failed - backend not running", 0
        except requests.exceptions.Timeout:
            return False, "Timeout", 0
        except Exception as e:
            return False, f"Error: {str(e)}", 0

    def authenticate_all_users(self) -> Dict[str, dict]:
        """Authenticate all seeded users and store their tokens"""
        auth_results = {}

        print(f"\n🔐 Authenticating {len(SEED_USERS)} seeded users")
        print("=" * 80)

        for user_key, user_data in SEED_USERS.items():
            print(f"Authenticating {user_data['role']}: {user_data['phone']}")

            success, message, auth_headers = self.authenticate_user(
                user_data['phone'],
                user_data['password']
            )

            auth_results[user_key] = {
                'user_data': user_data,
                'authenticated': success,
                'message': message,
                'auth_headers': auth_headers if success else {},
                'rbac_results': []
            }

            if success:
                print(f"  ✅ {user_data['role']} authenticated successfully")
                self.auth_tokens[user_key] = auth_headers
            else:
                print(f"  ❌ {user_data['role']} authentication failed: {message}")

        return auth_results

    def test_rbac_access(self, auth_results: Dict[str, dict]) -> Dict[str, any]:
        """Test RBAC access for each user role"""
        rbac_results = {
            'total_users': len(auth_results),
            'authenticated_users': 0,
            'rbac_test_results': {},
            'endpoint_access_matrix': {}
        }

        print(f"\n🔒 Testing RBAC Access Control")
        print("=" * 80)

        # Count authenticated users
        for user_key, user_result in auth_results.items():
            if user_result['authenticated']:
                rbac_results['authenticated_users'] += 1

        # Test each endpoint for each authenticated user
        for endpoint, method in NAVIGATION_ENDPOINTS.items():
            rbac_results['endpoint_access_matrix'][endpoint] = {}

            print(f"\nTesting endpoint: {method} {endpoint}")

            for user_key, user_result in auth_results.items():
                if not user_result['authenticated']:
                    rbac_results['endpoint_access_matrix'][endpoint][user_key] = {
                        'access': 'not_tested',
                        'reason': 'user_not_authenticated'
                    }
                    continue

                success, message, status_code = self.test_endpoint_with_auth(
                    endpoint,
                    method,
                    user_result['auth_headers']
                )

                result = {
                    'access': 'granted' if success and 'denied' not in message else 'denied',
                    'message': message,
                    'status_code': status_code,
                    'user_role': user_result['user_data']['role']
                }

                rbac_results['endpoint_access_matrix'][endpoint][user_key] = result
                user_result['rbac_results'].append({
                    'endpoint': endpoint,
                    'method': method,
                    **result
                })

                status = "✅" if success else "❌"
                print(f"  {status} {user_result['user_data']['role']}: {message}")

        rbac_results['rbac_test_results'] = auth_results
        return rbac_results

    def verify_navigation_endpoints(self) -> Dict[str, any]:
        """Test all endpoints used in navigation screens"""
        results = {
            'total_endpoints': len(NAVIGATION_ENDPOINTS),
            'tested_endpoints': 0,
            'successful_endpoints': 0,
            'failed_endpoints': 0,
            'auth_required_endpoints': 0,
            'not_found_endpoints': 0,
            'endpoint_results': []
        }

        print(f"\n🔍 Testing {len(NAVIGATION_ENDPOINTS)} Navigation API Endpoints")
        print("=" * 80)

        for endpoint, method in NAVIGATION_ENDPOINTS.items():
            results['tested_endpoints'] += 1

            success, message, status_code = self.test_endpoint(endpoint, method)

            # Check if endpoint exists in project plan
            plan_match = any(endpoint in plan_endpoint for plan_endpoint in PROJECT_PLAN_ENDPOINTS.keys())

            result = {
                'endpoint': endpoint,
                'method': method,
                'success': success,
                'message': message,
                'status_code': status_code,
                'in_project_plan': plan_match
            }

            results['endpoint_results'].append(result)

            if success:
                if 'Auth required' in message:
                    results['auth_required_endpoints'] += 1
                    print(f"✅ {method} {endpoint} - {message} (Status: {status_code}) {'✓ Plan' if plan_match else '✗ Not in Plan'}")
                else:
                    results['successful_endpoints'] += 1
                    print(f"✅ {method} {endpoint} - {message} (Status: {status_code}) {'✓ Plan' if plan_match else '✗ Not in Plan'}")
            else:
                results['failed_endpoints'] += 1
                if 'Not found' in message:
                    results['not_found_endpoints'] += 1
                print(f"❌ {method} {endpoint} - {message} (Status: {status_code}) {'✓ Plan' if plan_match else '✗ Not in Plan'}")

        return results

    def generate_comprehensive_report(self, results: Dict[str, any]) -> str:
        """Generate a comprehensive test report"""
        report = []
        report.append("# API Endpoint Testing Report")
        report.append(f"**Test Date:** {time.strftime('%Y-%m-%d %H:%M:%S')}")
        report.append(f"**API Base URL:** {self.base_url}")
        report.append("")

        report.append("## Summary")
        report.append(f"- **Total Endpoints Tested:** {results['total_endpoints']}")
        report.append(f"- **Successful:** {results['successful_endpoints']}")
        report.append(f"- **Auth Required (Expected):** {results['auth_required_endpoints']}")
        report.append(f"- **Failed:** {results['failed_endpoints']}")
        report.append(f"- **Not Found:** {results['not_found_endpoints']}")
        report.append("")

        success_rate = (results['successful_endpoints'] + results['auth_required_endpoints']) / results['total_endpoints'] * 100
        report.append(f"**Success Rate:** {success_rate:.1f}%")
        report.append("")

        # Check compliance with project plan
        plan_compliant = sum(1 for r in results['endpoint_results'] if r['in_project_plan'])
        plan_compliance_rate = plan_compliant / results['total_endpoints'] * 100
        report.append(f"**Project Plan Compliance:** {plan_compliance_rate:.1f}% ({plan_compliant}/{results['total_endpoints']})")
        report.append("")

        report.append("## Detailed Results")
        report.append("")

        # Group by status
        success_results = [r for r in results['endpoint_results'] if r['success'] and 'Auth required' not in r['message']]
        auth_results = [r for r in results['endpoint_results'] if r['success'] and 'Auth required' in r['message']]
        failed_results = [r for r in results['endpoint_results'] if not r['success']]

        if success_results:
            report.append("### ✅ Successful Endpoints")
            for r in success_results:
                report.append(f"- `{r['method']} {r['endpoint']}` - {r['message']} ({r['status_code']}) {'✓ Plan' if r['in_project_plan'] else '✗ Not in Plan'}")
            report.append("")

        if auth_results:
            report.append("### 🔒 Auth Required Endpoints (Expected)")
            for r in auth_results:
                report.append(f"- `{r['method']} {r['endpoint']}` - {r['message']} ({r['status_code']}) {'✓ Plan' if r['in_project_plan'] else '✗ Not in Plan'}")
            report.append("")

        if failed_results:
            report.append("### ❌ Failed Endpoints")
            for r in failed_results:
                report.append(f"- `{r['method']} {r['endpoint']}` - {r['message']} ({r['status_code']}) {'✓ Plan' if r['in_project_plan'] else '✗ Not in Plan'}")
            report.append("")

        # Recommendations
        report.append("## Recommendations")
        report.append("")

        not_in_plan = [r for r in results['endpoint_results'] if not r['in_project_plan']]
        if not_in_plan:
            report.append("### Endpoints Not in Project Plan")
            for r in not_in_plan:
                report.append(f"- `{r['method']} {r['endpoint']}` - Should be added to project plan section 2.1")
            report.append("")

        if results['not_found_endpoints'] > 0:
            report.append("### Missing Endpoints to Implement")
            missing = [r for r in results['endpoint_results'] if 'Not found' in r['message']]
            for r in missing:
                report.append(f"- `{r['method']} {r['endpoint']}` - Backend implementation required")
            report.append("")

        # Go Router assessment
        report.append("## Go Router Assessment")
        report.append("")
        report.append("### For Flutter Mobile (iOS/Android)")
        report.append("- ✅ GoRouter works perfectly for mobile apps")
        report.append("- ✅ Deep linking supported via platform-specific URL schemes")
        report.append("- ✅ Navigation state management integrated")
        report.append("")
        report.append("### For Flutter Web")
        report.append("- ⚠️ GoRouter works for web but has limitations:")
        report.append("  - Browser back/forward buttons may not work as expected")
        report.append("  - URL fragments (#) instead of paths for some cases")
        report.append("  - Requires proper web server configuration")
        report.append("- 💡 Recommendation: Test web builds separately from mobile")
        report.append("- 🔧 Alternative: Consider using auto_route or beamer for web if issues persist")
        report.append("")
        report.append("### Testing Strategy")
        report.append("- 🧪 **Mobile Testing:** Use iOS Simulator or Android Emulator")
        report.append("- 🌐 **Web Testing:** Use `flutter run -d web-server` or build web app")
        report.append("- 🐳 **Backend Testing:** Ensure Docker containers are running")
        report.append("- 🔗 **API Testing:** Use nginx proxy URLs (`http://localhost/api/v1/*`)")

        # RBAC Testing Results Section
        rbac_results = results.get('rbac_results', {})
        auth_results = results.get('auth_results', {})

        report.append("---")
        report.append("")
        report.append("## 🔐 RBAC Authentication & Access Control Testing")
        report.append("")

        report.append("### User Authentication Results")
        report.append(f"- **Total Users Tested:** {len(SEED_USERS)}")
        report.append(f"- **Successfully Authenticated:** {rbac_results.get('authenticated_users', 0)}")
        report.append("")

        # Authentication details
        for user_key, user_result in auth_results.items():
            status = "✅" if user_result['authenticated'] else "❌"
            report.append(f"#### {status} {user_result['user_data']['role']}")
            report.append(f"- **Phone:** {user_result['user_data']['phone']}")
            report.append(f"- **Permissions:** {user_result['user_data']['permissions']}")
            report.append(f"- **Status:** {user_result['message']}")
            report.append(f"- **Description:** {user_result['user_data']['description']}")
            report.append("")

        report.append("### RBAC Access Control Matrix")
        report.append("")
        report.append("| Endpoint | Super Admin | Provider Admin | Regional Manager | Senior Agent | Junior Agent | Policyholder | Support Staff |")
        report.append("|----------|-------------|----------------|------------------|--------------|--------------|--------------|---------------|")

        endpoint_matrix = rbac_results.get('endpoint_access_matrix', {})
        for endpoint, user_results in endpoint_matrix.items():
            row = [endpoint.replace('|', '\\|')]  # Escape pipes in markdown

            for user_key in ['super_admin', 'provider_admin', 'regional_manager', 'senior_agent', 'junior_agent', 'policyholder', 'support_staff']:
                if user_key in user_results:
                    result = user_results[user_key]
                    if result['access'] == 'granted':
                        cell = "✅"
                    elif result['access'] == 'denied':
                        cell = "❌"
                    else:
                        cell = "⏭️"
                else:
                    cell = "⏭️"
                row.append(cell)

            report.append("| " + " | ".join(row) + " |")

        report.append("")

        # Detailed RBAC Analysis
        report.append("### Detailed RBAC Analysis")
        report.append("")

        # Expected access patterns
        report.append("#### Expected Access Patterns")
        report.append("")

        expected_access = {
            'super_admin': ['All endpoints - full system access'],
            'provider_admin': ['Provider management, user management, regions'],
            'regional_manager': ['Regional operations, agent management, campaigns'],
            'senior_agent': ['Agent operations, team management, analytics'],
            'junior_agent': ['Basic agent operations, customer management'],
            'policyholder': ['Policy viewing, payments, claims, learning'],
            'support_staff': ['Support operations, customer assistance']
        }

        for user_key, expectations in expected_access.items():
            user_data = SEED_USERS[user_key]
            report.append(f"**{user_data['role']}** ({user_data['permissions']} permissions):")
            for expectation in expectations:
                report.append(f"- {expectation}")
            report.append("")

        # RBAC Compliance Summary
        report.append("#### RBAC Compliance Summary")
        report.append("")

        total_access_tests = 0
        total_granted = 0
        total_denied = 0

        for endpoint, user_results in endpoint_matrix.items():
            for user_key, result in user_results.items():
                if result['access'] != 'not_tested':
                    total_access_tests += 1
                    if result['access'] == 'granted':
                        total_granted += 1
                    elif result['access'] == 'denied':
                        total_denied += 1

        if total_access_tests > 0:
            access_rate = total_granted / total_access_tests * 100
            deny_rate = total_denied / total_access_tests * 100

            report.append(f"- **Total Access Tests:** {total_access_tests}")
            report.append(f"- **Access Granted:** {total_granted} ({access_rate:.1f}%)")
            report.append(f"- **Access Denied:** {total_denied} ({deny_rate:.1f}%)")
            report.append("")

            # For RBAC, high denial rate is GOOD - it means sensitive endpoints are protected
            if deny_rate > 60 and access_rate > 20:
                report.append("✅ **RBAC System Status: HEALTHY** - Proper access control implemented")
                report.append("   High denial rate indicates sensitive endpoints are well-protected")
            elif deny_rate > 40 and access_rate > 10:
                report.append("⚠️ **RBAC System Status: MODERATE** - Basic access control working")
                report.append("   Some endpoints may need additional permission checks")
            else:
                report.append("❌ **RBAC System Status: NEEDS ATTENTION** - Insufficient access control")
        else:
            report.append("❌ **No RBAC tests completed** - Authentication may have failed")

        report.append("")

        # Recommendations
        report.append("### RBAC Recommendations")
        report.append("")

        if rbac_results.get('authenticated_users', 0) < len(SEED_USERS):
            report.append("#### Authentication Issues")
            failed_auth = [k for k, v in auth_results.items() if not v['authenticated']]
            report.append(f"Failed to authenticate: {', '.join(failed_auth)}")
            report.append("- Check user seeding in database")
            report.append("- Verify authentication endpoint functionality")
            report.append("")

        if total_access_tests == 0:
            report.append("#### RBAC Testing Issues")
            report.append("- No access control tests completed")
            report.append("- Fix authentication before testing RBAC")
            report.append("")

        # Critical endpoints that should be restricted
        critical_endpoints = [
            '/users/',
            '/rbac/roles',
            '/rbac/users/assign-role',
            '/tenants/',
            '/dashboard/system-overview'
        ]

        report.append("#### Critical Endpoint Protection")
        for endpoint in critical_endpoints:
            if endpoint in endpoint_matrix:
                super_admin_access = endpoint_matrix[endpoint].get('super_admin', {}).get('access')
                junior_agent_access = endpoint_matrix[endpoint].get('junior_agent', {}).get('access')
                policyholder_access = endpoint_matrix[endpoint].get('policyholder', {}).get('access')

                if super_admin_access == 'granted':
                    report.append(f"✅ {endpoint} - Super Admin access correct")
                else:
                    report.append(f"❌ {endpoint} - Super Admin access denied (should be granted)")

                if junior_agent_access == 'denied':
                    report.append(f"✅ {endpoint} - Junior Agent access correctly denied")
                else:
                    report.append(f"⚠️ {endpoint} - Junior Agent access granted (review required)")

                if policyholder_access == 'denied':
                    report.append(f"✅ {endpoint} - Policyholder access correctly denied")
                else:
                    report.append(f"⚠️ {endpoint} - Policyholder access granted (review required)")

        report.append("")
        report.append("---")

        return "\n".join(report)

def main():
    """Main testing function"""
    print("🚀 Agent Mitra Navigation API & RBAC Testing")
    print("Testing endpoints used in Flutter navigation screens")
    print("against project plan section 2.1 requirements")
    print("Including comprehensive RBAC role-based access testing")
    print()

    # Check if backend is running
    try:
        response = requests.get("http://localhost/health", timeout=5)
        if response.status_code == 200:
            print("✅ Backend health check passed")
        else:
            print(f"⚠️ Backend health check returned status {response.status_code}")
    except:
        print("❌ Backend not accessible. Please ensure Docker containers are running:")
        print("   docker-compose -f docker-compose.prod.yml up -d")
        print("   Or run: scripts/deploy/start-prod.sh")
        return

    # Initialize tester
    tester = APIEndpointTester()

    # Phase 1: Basic endpoint testing
    print("\n📊 PHASE 1: Basic API Endpoint Testing")
    basic_results = tester.verify_navigation_endpoints()

    # Phase 2: RBAC authentication
    print("\n🔐 PHASE 2: RBAC Authentication Testing")
    auth_results = tester.authenticate_all_users()

    # Phase 3: RBAC access testing
    print("\n🔒 PHASE 3: RBAC Access Control Testing")
    rbac_results = tester.test_rbac_access(auth_results)

    # Combine results
    results = {
        **basic_results,
        'rbac_results': rbac_results,
        'auth_results': auth_results
    }

    # Generate and save comprehensive report
    report = tester.generate_comprehensive_report(results)

    print("\n" + "="*80)
    print("📊 TEST SUMMARY")
    print("="*80)
    print(f"Total Endpoints: {results['total_endpoints']}")
    print(f"Successful: {results['successful_endpoints']}")
    print(f"Auth Required: {results['auth_required_endpoints']}")
    print(f"Failed: {results['failed_endpoints']}")
    print(f"Project Plan Compliance: {sum(1 for r in results['endpoint_results'] if r['in_project_plan'])}/{results['total_endpoints']}")

    # Save report to file
    with open("navigation_rbac_test_report.md", "w") as f:
        f.write(report)

    print("\n📄 Detailed report saved to: navigation_api_test_report.md")
    print()

    # Final assessment
    success_rate = (results['successful_endpoints'] + results['auth_required_endpoints']) / results['total_endpoints'] * 100
    plan_compliance = sum(1 for r in results['endpoint_results'] if r['in_project_plan']) / results['total_endpoints'] * 100
    rbac_auth_rate = results['rbac_results']['authenticated_users'] / results['rbac_results']['total_users'] * 100

    # Calculate RBAC effectiveness (if tests were completed)
    rbac_effective = False
    rbac_deny_rate = 0
    endpoint_matrix = results['rbac_results'].get('endpoint_access_matrix', {})
    if endpoint_matrix:
        total_tests = 0
        granted_tests = 0
        denied_tests = 0
        for endpoint, user_results in endpoint_matrix.items():
            for user_key, result in user_results.items():
                if result['access'] != 'not_tested':
                    total_tests += 1
                    if result['access'] == 'granted':
                        granted_tests += 1
                    elif result['access'] == 'denied':
                        denied_tests += 1

        if total_tests > 0:
            rbac_access_rate = granted_tests / total_tests * 100
            rbac_deny_rate = denied_tests / total_tests * 100
            # RBAC is effective if it properly denies access (high denial rate = good protection)
            rbac_effective = rbac_deny_rate > 50 and rbac_access_rate > 15

    print("🎯 FINAL ASSESSMENT:")
    print(f"  • API Success Rate: {success_rate:.1f}%")
    print(f"  • Plan Compliance: {plan_compliance:.1f}%")
    print(f"  • RBAC Auth Success: {rbac_auth_rate:.1f}%")
    print(f"  • RBAC Protection: {rbac_deny_rate:.1f}% denied ({'✅ Excellent' if rbac_deny_rate > 60 else '⚠️ Needs Review'})")

    if success_rate >= 90 and plan_compliance >= 95 and rbac_auth_rate >= 90 and rbac_effective:
        print("🎉 EXCELLENT: All systems working perfectly with proper RBAC!")
        sys.exit(0)
    elif success_rate >= 75 and plan_compliance >= 80 and rbac_auth_rate >= 75:
        print("👍 GOOD: Core functionality working with RBAC")
        sys.exit(0)
    else:
        print("⚠️ NEEDS ATTENTION: RBAC or API issues detected")
        sys.exit(1)

if __name__ == "__main__":
    main()
