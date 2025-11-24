"""
Test script for email OTP API endpoint
Tests the actual API endpoint for sending email OTP
"""
import requests
import json
import sys
from pathlib import Path

# Configuration
BASE_URL = "http://localhost:8012"
API_BASE = f"{BASE_URL}/api/v1/auth"


def test_send_email_otp(email: str):
    """Test sending email OTP via API"""
    print("\n" + "="*60)
    print("TEST: Send Email OTP via API")
    print("="*60)
    
    url = f"{API_BASE}/send-email-otp"
    payload = {"email": email}
    
    print(f"URL: {url}")
    print(f"Payload: {json.dumps(payload, indent=2)}")
    print(f"\nSending request...")
    
    try:
        response = requests.post(url, json=payload, timeout=10)
        
        print(f"\nStatus Code: {response.status_code}")
        print(f"Response Headers: {dict(response.headers)}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"\n✅ Success! Response:")
            print(json.dumps(data, indent=2))
            return True
        else:
            print(f"\n❌ Error! Response:")
            print(response.text)
            return False
            
    except requests.exceptions.ConnectionError:
        print("\n❌ ERROR: Could not connect to backend server")
        print(f"Make sure the backend is running at {BASE_URL}")
        return False
    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        return False


def test_verify_email_otp(email: str, otp: str):
    """Test verifying email OTP via API"""
    print("\n" + "="*60)
    print("TEST: Verify Email OTP via API")
    print("="*60)
    
    url = f"{API_BASE}/verify-email-otp"
    payload = {
        "email": email,
        "otp": otp
    }
    
    print(f"URL: {url}")
    print(f"Payload: {json.dumps(payload, indent=2)}")
    print(f"\nSending request...")
    
    try:
        response = requests.post(url, json=payload, timeout=10)
        
        print(f"\nStatus Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"\n✅ Success! Response:")
            print(json.dumps(data, indent=2))
            if "access_token" in data:
                print("\n✅ Access token received - OTP verification successful!")
            return True
        else:
            print(f"\n❌ Error! Response:")
            print(response.text)
            return False
            
    except requests.exceptions.ConnectionError:
        print("\n❌ ERROR: Could not connect to backend server")
        print(f"Make sure the backend is running at {BASE_URL}")
        return False
    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        return False


def test_health_check():
    """Test if backend is running"""
    print("\n" + "="*60)
    print("TEST: Backend Health Check")
    print("="*60)
    
    try:
        response = requests.get(f"{BASE_URL}/api/v1/health", timeout=5)
        if response.status_code == 200:
            print("✅ Backend is running!")
            return True
        else:
            print(f"⚠️  Backend responded with status {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ Backend is not running!")
        print(f"Please start the backend server: cd backend && python -m uvicorn main:app --reload")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False


def main():
    """Run API tests"""
    print("\n" + "="*60)
    print("AGENT MITRA - EMAIL OTP API TEST SUITE")
    print("="*60)
    
    # Check if backend is running
    if not test_health_check():
        print("\n⚠️  Please start the backend server before running tests")
        return
    
    # Get test email
    test_email = input("\nEnter your test email address: ").strip()
    
    if not test_email:
        print("❌ Email address required")
        return
    
    results = []
    
    # Test 1: Send Email OTP
    results.append(("Send Email OTP", test_send_email_otp(test_email)))
    
    if results[0][1]:
        print(f"\n📧 Please check your email inbox at {test_email} for the OTP code")
        otp = input("\nEnter the OTP code you received (or 'skip' to skip verification): ").strip()
        
        if otp and otp.lower() != 'skip':
            # Test 2: Verify Email OTP
            results.append(("Verify Email OTP", test_verify_email_otp(test_email, otp)))
        else:
            print("⏭️  Skipping OTP verification test")
            results.append(("Verify Email OTP", None))
    else:
        print("\n❌ Failed to send email OTP. Cannot proceed with verification test.")
        results.append(("Verify Email OTP", None))
    
    # Summary
    print("\n" + "="*60)
    print("TEST SUMMARY")
    print("="*60)
    
    for test_name, result in results:
        if result is None:
            status = "⏭️  SKIPPED"
        elif result:
            status = "✅ PASS"
        else:
            status = "❌ FAIL"
        print(f"{test_name}: {status}")
    
    all_passed = all(result for _, result in results if result is not None)
    
    if all_passed:
        print("\n🎉 All tests passed! Email OTP API is working correctly.")
    else:
        print("\n⚠️  Some tests failed. Please review the errors above.")


if __name__ == "__main__":
    main()

