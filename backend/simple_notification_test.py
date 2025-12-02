#!/usr/bin/env python3
"""
Simple test script for Notification API endpoints
"""

import requests
import time

BASE_URL = "http://127.0.0.1:8015/api/v1"

def test_notification_endpoints():
    print("Testing Notification API Endpoints\n")

    # Authenticate as super admin
    print("1. Authenticating...")
    auth_response = requests.post(f"{BASE_URL}/auth/login", json={
        "phone_number": "+919876543200",
        "password": "testpassword"
    })

    if auth_response.status_code != 200:
        print(f"❌ Authentication failed: {auth_response.status_code}")
        print(auth_response.text)
        return

    token = auth_response.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    print("✅ Authentication successful\n")

    # Test GET notifications
    print("2. Testing GET /notifications/")
    get_response = requests.get(f"{BASE_URL}/notifications/", headers=headers)
    print(f"Status: {get_response.status_code}")
    if get_response.status_code == 200:
        print("✅ GET notifications successful")
    else:
        print(f"❌ GET notifications failed: {get_response.text}")
    print()

    # Test GET statistics
    print("3. Testing GET /notifications/statistics")
    stats_response = requests.get(f"{BASE_URL}/notifications/statistics", headers=headers)
    print(f"Status: {stats_response.status_code}")
    if stats_response.status_code == 200:
        print("✅ GET statistics successful")
        print(f"Stats: {stats_response.json()}")
    else:
        print(f"❌ GET statistics failed: {stats_response.text}")
    print()

    # Test POST notification (this should still fail due to tenant_id)
    print("4. Testing POST /notifications/")
    notification_data = {
        "title": "Test Notification",
        "body": "This is a test notification",
        "type": "system",
        "priority": "medium"
    }
    post_response = requests.post(f"{BASE_URL}/notifications/", json=notification_data, headers=headers)
    print(f"Status: {post_response.status_code}")
    if post_response.status_code == 200:
        print("✅ POST notification successful")
        notification_id = post_response.json()["id"]
        print(f"Created notification ID: {notification_id}")
    else:
        print(f"❌ POST notification failed: {post_response.text[:200]}")
    print()

    # Test settings endpoints
    print("5. Testing GET /notifications/settings")
    settings_get_response = requests.get(f"{BASE_URL}/notifications/settings", headers=headers)
    print(f"Status: {settings_get_response.status_code}")
    if settings_get_response.status_code == 200:
        print("✅ GET settings successful")
    else:
        print(f"❌ GET settings failed: {settings_get_response.text[:200]}")
    print()

    print("6. Testing PUT /notifications/settings")
    settings_data = {
        "enable_push_notifications": True,
        "enable_policy_notifications": True,
        "enable_payment_reminders": False,
        "enable_sound": True,
        "enable_vibration": True
    }
    settings_put_response = requests.put(f"{BASE_URL}/notifications/settings", json=settings_data, headers=headers)
    print(f"Status: {settings_put_response.status_code}")
    if settings_put_response.status_code == 200:
        print("✅ PUT settings successful")
    else:
        print(f"❌ PUT settings failed: {settings_put_response.text[:200]}")
    print()

    # Test device token endpoint
    print("7. Testing POST /notifications/device-token")
    device_data = {
        "token": "test_device_token_123",
        "device_type": "android"
    }
    device_response = requests.post(f"{BASE_URL}/notifications/device-token", json=device_data, headers=headers)
    print(f"Status: {device_response.status_code}")
    if device_response.status_code == 200:
        print("✅ Device token registration successful")
    else:
        print(f"❌ Device token registration failed: {device_response.text[:200]}")
    print()

    # Get the notification ID from the created notification for further testing
    notifications_data = get_response.json()
    if notifications_data and len(notifications_data) > 0:
        notification_id = notifications_data[0]["id"]

        print("8. Testing GET /notifications/{id}")
        single_response = requests.get(f"{BASE_URL}/notifications/{notification_id}", headers=headers)
        print(f"Status: {single_response.status_code}")
        if single_response.status_code == 200:
            print("✅ GET single notification successful")
        else:
            print(f"❌ GET single notification failed: {single_response.text[:200]}")
        print()

        print("9. Testing PATCH /notifications/{id}/read")
        read_response = requests.patch(f"{BASE_URL}/notifications/{notification_id}/read", headers=headers)
        print(f"Status: {read_response.status_code}")
        if read_response.status_code == 200:
            print("✅ Mark as read successful")
        else:
            print(f"❌ Mark as read failed: {read_response.text[:200]}")
        print()

        print("10. Testing PATCH /notifications/read (bulk)")
        bulk_read_data = [notification_id]  # Send as direct array
        bulk_read_response = requests.patch(f"{BASE_URL}/notifications/read", json=bulk_read_data, headers=headers)
        print(f"Status: {bulk_read_response.status_code}")
        if bulk_read_response.status_code == 200:
            print("✅ Bulk mark as read successful")
        else:
            print(f"❌ Bulk mark as read failed: {bulk_read_response.text[:200]}")
        print()

        print("11. Testing POST /notifications/test")
        test_notification_response = requests.post(f"{BASE_URL}/notifications/test", json={
            "title": "Test from API",
            "body": "This is a test notification"
        }, headers=headers)
        print(f"Status: {test_notification_response.status_code}")
        if test_notification_response.status_code == 200:
            print("✅ Send test notification successful")
        else:
            print(f"❌ Send test notification failed: {test_notification_response.text[:200]}")
        print()

        print("12. Testing POST /notifications/bulk")
        bulk_data = [
            {
                "title": "Bulk Test 1",
                "body": "First bulk notification",
                "type": "marketing",
                "priority": "low"
            },
            {
                "title": "Bulk Test 2",
                "body": "Second bulk notification",
                "type": "system",
                "priority": "high"
            }
        ]
        bulk_response = requests.post(f"{BASE_URL}/notifications/bulk", json=bulk_data, headers=headers)
        print(f"Status: {bulk_response.status_code}")
        if bulk_response.status_code == 200:
            print("✅ Bulk create notifications successful")
        else:
            print(f"❌ Bulk create notifications failed: {bulk_response.text[:200]}")
        print()

        print("13. Testing DELETE /notifications/{id}")
        delete_response = requests.delete(f"{BASE_URL}/notifications/{notification_id}", headers=headers)
        print(f"Status: {delete_response.status_code}")
        if delete_response.status_code == 200:
            print("✅ Delete notification successful")
        else:
            print(f"❌ Delete notification failed: {delete_response.text[:200]}")
        print()

    print("Notification API testing completed!")

if __name__ == "__main__":
    test_notification_endpoints()
