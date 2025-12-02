#!/usr/bin/env python3
"""
Comprehensive test script for Notification API endpoints
Tests all notification-related endpoints with the seeded RBAC users
"""

import json
import requests
import time
import uuid
from datetime import datetime, timedelta

# Base URL for the API
BASE_URL = "http://127.0.0.1:8015/api/v1"

# Test users from seeded data
TEST_USERS = {
    "super_admin": {
        "phone_number": "+919876543200",
        "password": "testpassword",
        "expected_permissions": "Full system access"
    },
    "provider_admin": {
        "phone_number": "+919876543201",
        "password": "testpassword",
        "expected_permissions": "Insurance provider management"
    },
    "regional_manager": {
        "phone_number": "+919876543202",
        "password": "testpassword",
        "expected_permissions": "Regional operations"
    },
    "senior_agent": {
        "phone_number": "+919876543203",
        "password": "testpassword",
        "expected_permissions": "Agent operations + inherited permissions"
    },
    "junior_agent": {
        "phone_number": "+919876543204",
        "password": "testpassword",
        "expected_permissions": "Basic agent operations"
    },
    "policyholder": {
        "phone_number": "+919876543205",
        "password": "testpassword",
        "expected_permissions": "Customer access"
    },
    "support_staff": {
        "phone_number": "+919876543206",
        "password": "testpassword",
        "expected_permissions": "Support operations"
    }
}

class NotificationAPITester:
    def __init__(self):
        self.session = requests.Session()
        self.auth_tokens = {}
        self.test_results = []
        self.created_notifications = []

    def log_test(self, test_name, status, message="", response=None):
        """Log test result"""
        result = {
            "test": test_name,
            "status": status,
            "message": message,
            "timestamp": datetime.now().isoformat()
        }
        if response:
            result["response_status"] = response.status_code if hasattr(response, 'status_code') else None
            result["response_data"] = response.json() if hasattr(response, 'json') and response.content else None

        self.test_results.append(result)
        print(f"[{status.upper()}] {test_name}: {message}")

    def authenticate_user(self, user_role):
        """Authenticate a user and store the token"""
        user_data = TEST_USERS[user_role]

        try:
            response = self.session.post(f"{BASE_URL}/auth/login", json={
                "phone_number": user_data["phone_number"],
                "password": user_data["password"]
            })

            if response.status_code == 200:
                data = response.json()
                self.auth_tokens[user_role] = data.get("access_token")
                self.session.headers.update({"Authorization": f"Bearer {data.get('access_token')}"})
                self.log_test(f"Authentication - {user_role}", "PASS", f"Successfully authenticated {user_role}")
                return True
            else:
                self.log_test(f"Authentication - {user_role}", "FAIL", f"Failed to authenticate: {response.text}")
                return False

        except Exception as e:
            self.log_test(f"Authentication - {user_role}", "ERROR", str(e))
            return False

    def make_request(self, method, endpoint, data=None, user_role=None):
        """Make an authenticated request"""
        try:
            # Create a new session for each request to avoid auth conflicts
            session = requests.Session()

            if user_role and user_role in self.auth_tokens:
                session.headers.update({"Authorization": f"Bearer {self.auth_tokens[user_role]}"})
                print(f"DEBUG: Using token for {user_role}: {self.auth_tokens[user_role][:20]}...")

            url = f"{BASE_URL}{endpoint}"
            print(f"DEBUG: Making {method} request to {url}")

            if method.upper() == "GET":
                response = session.get(url, timeout=10)
            elif method.upper() == "POST":
                print(f"DEBUG: POST data: {data}")
                response = session.post(url, json=data, timeout=10)
            elif method.upper() == "PUT":
                print(f"DEBUG: PUT data: {data}")
                response = session.put(url, json=data, timeout=10)
            elif method.upper() == "PATCH":
                print(f"DEBUG: PATCH data: {data}")
                response = session.patch(url, json=data, timeout=10)
            elif method.upper() == "DELETE":
                response = session.delete(url, timeout=10)
            else:
                raise ValueError(f"Unsupported method: {method}")

            print(f"DEBUG: Response status: {response.status_code}")
            return response

        except requests.exceptions.RequestException as e:
            print(f"Request error for {method} {endpoint}: {e}")
            return None
        except Exception as e:
            print(f"Unexpected error for {method} {endpoint}: {e}")
            return None

    def test_get_notifications(self, user_role):
        """Test GET /notifications/"""
        response = self.make_request("GET", "/notifications/", user_role=user_role)

        if response and response.status_code == 200:
            data = response.json()
            self.log_test(f"GET /notifications/ - {user_role}", "PASS", f"Retrieved {len(data)} notifications")
            return data
        else:
            self.log_test(f"GET /notifications/ - {user_role}", "FAIL",
                         f"Status: {response.status_code if response else 'N/A'}")
            return []

    def test_get_statistics(self, user_role):
        """Test GET /notifications/statistics"""
        response = self.make_request("GET", "/notifications/statistics", user_role=user_role)

        if response and response.status_code == 200:
            data = response.json()
            self.log_test(f"GET /notifications/statistics - {user_role}", "PASS",
                         f"Stats: {data.get('total_notifications', 0)} total, {data.get('unread_count', 0)} unread")
            return data
        else:
            self.log_test(f"GET /notifications/statistics - {user_role}", "FAIL",
                         f"Status: {response.status_code if response else 'N/A'}")
            return None

    def test_create_notification(self, user_role):
        """Test POST /notifications/"""
        notification_data = {
            "title": f"Test Notification {uuid.uuid4().hex[:8]}",
            "body": "This is a test notification created via API",
            "type": "system",
            "priority": "medium",
            "action_text": "View Details",
            "action_route": "/dashboard",
            "data": {"test": True, "created_by": user_role}
        }

        response = self.make_request("POST", "/notifications/", data=notification_data, user_role=user_role)

        if response and response.status_code == 200:
            data = response.json()
            self.created_notifications.append(data)
            self.log_test(f"POST /notifications/ - {user_role}", "PASS", f"Created notification: {data.get('id')}")
            return data
        else:
            error_msg = f"Status: {response.status_code if response else 'N/A'}"
            if response:
                try:
                    error_data = response.json()
                    error_msg += f", Error: {error_data}"
                except:
                    error_msg += f", Response: {response.text[:200]}"
            self.log_test(f"POST /notifications/ - {user_role}", "FAIL", error_msg)
            return None

    def test_get_single_notification(self, user_role, notification_id):
        """Test GET /notifications/{id}"""
        response = self.make_request("GET", f"/notifications/{notification_id}", user_role=user_role)

        if response and response.status_code == 200:
            data = response.json()
            self.log_test(f"GET /notifications/{notification_id} - {user_role}", "PASS",
                         f"Retrieved notification: {data.get('title')}")
            return data
        else:
            self.log_test(f"GET /notifications/{notification_id} - {user_role}", "FAIL",
                         f"Status: {response.status_code if response else 'N/A'}")
            return None

    def test_mark_as_read(self, user_role, notification_id):
        """Test PATCH /notifications/{id}/read"""
        response = self.make_request("PATCH", f"/notifications/{notification_id}/read", user_role=user_role)

        if response and response.status_code == 200:
            self.log_test(f"PATCH /notifications/{notification_id}/read - {user_role}", "PASS",
                         "Notification marked as read")
            return True
        else:
            self.log_test(f"PATCH /notifications/{notification_id}/read - {user_role}", "FAIL",
                         f"Status: {response.status_code if response else 'N/A'}")
            return False

    def test_mark_multiple_read(self, user_role, notification_ids):
        """Test PATCH /notifications/read"""
        data = {"notification_ids": notification_ids}
        response = self.make_request("PATCH", "/notifications/read", data=data, user_role=user_role)

        if response and response.status_code == 200:
            data = response.json()
            self.log_test(f"PATCH /notifications/read - {user_role}", "PASS",
                         f"Marked {data.get('success_count', 0)} notifications as read")
            return True
        else:
            self.log_test(f"PATCH /notifications/read - {user_role}", "FAIL",
                         f"Status: {response.status_code if response else 'N/A'}")
            return False

    def test_delete_notification(self, user_role, notification_id):
        """Test DELETE /notifications/{id}"""
        response = self.make_request("DELETE", f"/notifications/{notification_id}", user_role=user_role)

        if response and response.status_code == 200:
            self.log_test(f"DELETE /notifications/{notification_id} - {user_role}", "PASS",
                         "Notification deleted")
            return True
        else:
            self.log_test(f"DELETE /notifications/{notification_id} - {user_role}", "FAIL",
                         f"Status: {response.status_code if response else 'N/A'}")
            return False

    def test_bulk_create_notifications(self, user_role):
        """Test POST /notifications/bulk"""
        notifications_data = [
            {
                "title": f"Bulk Test Notification {i+1}",
                "body": f"This is bulk notification {i+1}",
                "type": "marketing" if i % 2 == 0 else "system",
                "priority": "low" if i % 3 == 0 else "medium",
                "data": {"bulk": True, "index": i+1}
            }
            for i in range(3)
        ]

        response = self.make_request("POST", "/notifications/bulk", data=notifications_data, user_role=user_role)

        if response and response.status_code == 200:
            data = response.json()
            self.log_test(f"POST /notifications/bulk - {user_role}", "PASS",
                         f"Created {len(data.get('notifications', []))} notifications")
            self.created_notifications.extend(data.get('notifications', []))
            return data
        else:
            self.log_test(f"POST /notifications/bulk - {user_role}", "FAIL",
                         f"Status: {response.status_code if response else 'N/A'}")
            return None

    def test_send_test_notification(self, user_role):
        """Test POST /notifications/test"""
        data = {
            "title": "API Test Notification",
            "body": "This is a test notification sent via API"
        }

        response = self.make_request("POST", "/notifications/test", data=data, user_role=user_role)

        if response and response.status_code == 200:
            self.log_test(f"POST /notifications/test - {user_role}", "PASS",
                         "Test notification sent")
            return True
        else:
            error_msg = f"Status: {response.status_code if response else 'N/A'}"
            if response:
                try:
                    error_data = response.json()
                    error_msg += f", Error: {error_data}"
                except:
                    error_msg += f", Response: {response.text[:200]}"
            self.log_test(f"POST /notifications/test - {user_role}", "FAIL", error_msg)
            return False

    def test_get_settings(self, user_role):
        """Test GET /notifications/settings"""
        response = self.make_request("GET", "/notifications/settings", user_role=user_role)

        if response and response.status_code == 200:
            data = response.json()
            self.log_test(f"GET /notifications/settings - {user_role}", "PASS",
                         f"Retrieved settings: push={data.get('enable_push_notifications')}")
            return data
        else:
            self.log_test(f"GET /notifications/settings - {user_role}", "FAIL",
                         f"Status: {response.status_code if response else 'N/A'}")
            return None

    def test_update_settings(self, user_role):
        """Test PUT /notifications/settings"""
        settings_data = {
            "enable_push_notifications": True,
            "enable_policy_notifications": True,
            "enable_payment_reminders": True,
            "enable_claim_updates": True,
            "enable_renewal_notices": True,
            "enable_marketing_notifications": False,
            "enable_sound": True,
            "enable_vibration": True,
            "show_badge": True,
            "quiet_hours_enabled": False,
            "enabled_topics": ["general", "policies", "payments", "claims"]
        }

        response = self.make_request("PUT", "/notifications/settings", data=settings_data, user_role=user_role)

        if response and response.status_code == 200:
            self.log_test(f"PUT /notifications/settings - {user_role}", "PASS",
                         "Notification settings updated")
            return True
        else:
            self.log_test(f"PUT /notifications/settings - {user_role}", "FAIL",
                         f"Status: {response.status_code if response else 'N/A'}")
            return False

    def test_register_device_token(self, user_role):
        """Test POST /notifications/device-token"""
        device_data = {
            "token": f"test_device_token_{uuid.uuid4().hex}",
            "device_type": "android"
        }

        response = self.make_request("POST", "/notifications/device-token", data=device_data, user_role=user_role)

        if response and response.status_code == 200:
            self.log_test(f"POST /notifications/device-token - {user_role}", "PASS",
                         "Device token registered")
            return True
        else:
            self.log_test(f"POST /notifications/device-token - {user_role}", "FAIL",
                         f"Status: {response.status_code if response else 'N/A'}")
            return False

    def run_comprehensive_tests(self):
        """Run all notification API tests"""
        print("=== Starting Comprehensive Notification API Tests ===\n")

        # Test authentication for different user roles
        print("--- Authentication Tests ---")
        successful_auths = 0
        for role in TEST_USERS.keys():
            if self.authenticate_user(role):
                successful_auths += 1
                time.sleep(0.5)  # Small delay between requests

        print(f"\nAuthenticated {successful_auths}/{len(TEST_USERS)} users successfully\n")

        # Run tests for each user role
        for user_role in TEST_USERS.keys():
            if user_role not in self.auth_tokens:
                print(f"Skipping {user_role} - authentication failed")
                continue

            print(f"\n--- Testing {user_role.upper()} ({TEST_USERS[user_role]['expected_permissions']}) ---")

            # Basic CRUD tests
            notifications = self.test_get_notifications(user_role)
            stats = self.test_get_statistics(user_role)

            # Create some test notifications
            created_notification = self.test_create_notification(user_role)

            if created_notification:
                notification_id = created_notification.get('id')

                # Test single notification retrieval
                self.test_get_single_notification(user_role, notification_id)

                # Test mark as read
                self.test_mark_as_read(user_role, notification_id)

                # Test delete (commented out to avoid deleting test data)
                # self.test_delete_notification(user_role, notification_id)

            # Test bulk operations
            bulk_result = self.test_bulk_create_notifications(user_role)

            # Test other endpoints
            self.test_send_test_notification(user_role)

            # Settings tests
            settings = self.test_get_settings(user_role)
            self.test_update_settings(user_role)

            # Device token test
            self.test_register_device_token(user_role)

            # Small delay between user tests
            time.sleep(1)

        # Cross-user tests (if we have multiple notifications)
        if len(self.created_notifications) > 1:
            print("\n--- Cross-user Tests ---")

            # Test marking multiple notifications as read
            notification_ids = [n.get('id') for n in self.created_notifications[:3]]
            self.test_mark_multiple_read("senior_agent", notification_ids)

        # Generate test report
        self.generate_report()

    def generate_report(self):
        """Generate a comprehensive test report"""
        print("\n=== Test Results Summary ===")

        total_tests = len(self.test_results)
        passed_tests = len([r for r in self.test_results if r['status'] == 'PASS'])
        failed_tests = len([r for r in self.test_results if r['status'] == 'FAIL'])
        error_tests = len([r for r in self.test_results if r['status'] == 'ERROR'])

        print(f"Total Tests: {total_tests}")
        print(f"Passed: {passed_tests}")
        print(f"Failed: {failed_tests}")
        print(f"Errors: {error_tests}")
        print(".1f")

        if failed_tests > 0 or error_tests > 0:
            print("\n=== Failed Tests ===")
            for result in self.test_results:
                if result['status'] in ['FAIL', 'ERROR']:
                    print(f"- {result['test']}: {result['message']}")

        print("\n=== Detailed Results ===")
        for result in self.test_results:
            status_icon = "✅" if result['status'] == 'PASS' else "❌" if result['status'] == 'FAIL' else "⚠️"
            print(f"{status_icon} {result['test']}: {result['message']}")

        # Save detailed report to file
        report_file = f"notification_api_test_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_file, 'w') as f:
            json.dump(self.test_results, f, indent=2, default=str)

        print(f"\nDetailed results saved to: {report_file}")

        # Save summary to text file
        summary_file = f"notification_api_test_summary_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
        with open(summary_file, 'w') as f:
            f.write("Notification API Test Summary\n")
            f.write("=" * 50 + "\n\n")
            f.write(f"Total Tests: {total_tests}\n")
            f.write(f"Passed: {passed_tests}\n")
            f.write(f"Failed: {failed_tests}\n")
            f.write(f"Errors: {error_tests}\n")
            f.write(".1f")
            f.write(f"\nTest Date: {datetime.now().isoformat()}\n\n")

            if failed_tests > 0 or error_tests > 0:
                f.write("Failed Tests:\n")
                f.write("-" * 30 + "\n")
                for result in self.test_results:
                    if result['status'] in ['FAIL', 'ERROR']:
                        f.write(f"- {result['test']}: {result['message']}\n")

        print(f"Summary saved to: {summary_file}")


if __name__ == "__main__":
    tester = NotificationAPITester()

    # Wait a moment for server to be ready
    print("Waiting for server to be ready...")
    time.sleep(3)

    try:
        tester.run_comprehensive_tests()
    except KeyboardInterrupt:
        print("\nTest interrupted by user")
        tester.generate_report()
    except Exception as e:
        print(f"\nTest failed with error: {e}")
        tester.generate_report()
