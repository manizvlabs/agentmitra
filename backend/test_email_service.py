"""
Test script for email service
Tests Gmail SMTP email sending functionality
"""
import sys
import os
from pathlib import Path

# Add backend to path
backend_dir = Path(__file__).parent
sys.path.insert(0, str(backend_dir))

# Load environment variables first (this triggers dotenv loading)
from dotenv import load_dotenv
env_local = backend_dir / ".env.local"
if env_local.exists():
    load_dotenv(env_local, override=True)

# Now import settings (which will use the loaded env vars)
from app.services.email_service import get_email_service
from app.core.config.settings import settings
from app.core.logging_config import get_logger

logger = get_logger(__name__)


def test_email_configuration():
    """Test email configuration"""
    print("\n" + "="*60)
    print("TEST 1: Email Configuration Check")
    print("="*60)
    
    print(f"EMAIL_HOST: {settings.email_host}")
    print(f"EMAIL_PORT: {settings.email_port}")
    print(f"EMAIL_USER: {settings.email_user}")
    print(f"EMAIL_PASSWORD: {'*' * len(settings.email_password) if settings.email_password else 'NOT SET'}")
    print(f"EMAIL_FROM: {settings.email_from}")
    
    if not settings.email_user or not settings.email_password:
        print("\n❌ ERROR: Email credentials not configured!")
        print("Please check your .env.local file")
        return False
    
    print("\n✅ Email configuration looks good!")
    return True


def test_smtp_connection():
    """Test SMTP connection"""
    print("\n" + "="*60)
    print("TEST 2: SMTP Connection Test")
    print("="*60)
    
    try:
        email_service = get_email_service()
        print(f"Connecting to {email_service.smtp_host}:{email_service.smtp_port}...")
        
        # Test connection
        smtp = email_service._get_smtp_connection()
        smtp.quit()
        
        print("✅ SMTP connection successful!")
        return True
    except Exception as e:
        print(f"❌ SMTP connection failed: {e}")
        return False


def test_send_test_email():
    """Test sending a test email"""
    print("\n" + "="*60)
    print("TEST 3: Send Test Email")
    print("="*60)
    
    test_email = input("Enter your test email address (or press Enter to skip): ").strip()
    
    if not test_email:
        print("⏭️  Skipping email send test")
        return True
    
    try:
        email_service = get_email_service()
        
        subject = "Agent Mitra - Email Service Test"
        html_body = """
        <html>
        <body>
            <h2>Email Service Test</h2>
            <p>This is a test email from Agent Mitra email service.</p>
            <p>If you received this email, the SMTP configuration is working correctly!</p>
            <hr>
            <p style="color: #666; font-size: 12px;">Sent from Agent Mitra Backend</p>
        </body>
        </html>
        """
        
        print(f"Sending test email to {test_email}...")
        result = email_service.send_email(test_email, subject, html_body)
        
        if result:
            print("✅ Test email sent successfully!")
            print(f"Please check your inbox at {test_email}")
            return True
        else:
            print("❌ Failed to send test email")
            return False
    except Exception as e:
        print(f"❌ Error sending test email: {e}")
        return False


def test_send_otp_email():
    """Test sending OTP email"""
    print("\n" + "="*60)
    print("TEST 4: Send OTP Email")
    print("="*60)
    
    test_email = input("Enter your test email address for OTP (or press Enter to skip): ").strip()
    
    if not test_email:
        print("⏭️  Skipping OTP email test")
        return True
    
    try:
        email_service = get_email_service()
        test_otp = "123456"  # Test OTP
        
        print(f"Sending OTP email to {test_email}...")
        result = email_service.send_otp_email(test_email, test_otp)
        
        if result:
            print("✅ OTP email sent successfully!")
            print(f"Please check your inbox at {test_email}")
            print(f"OTP code: {test_otp}")
            return True
        else:
            print("❌ Failed to send OTP email")
            return False
    except Exception as e:
        print(f"❌ Error sending OTP email: {e}")
        return False


def main():
    """Run all tests"""
    print("\n" + "="*60)
    print("AGENT MITRA - EMAIL SERVICE TEST SUITE")
    print("="*60)
    
    results = []
    
    # Test 1: Configuration
    results.append(("Configuration", test_email_configuration()))
    
    if not results[0][1]:
        print("\n❌ Configuration test failed. Please fix configuration before continuing.")
        return
    
    # Test 2: SMTP Connection
    results.append(("SMTP Connection", test_smtp_connection()))
    
    if not results[1][1]:
        print("\n❌ SMTP connection test failed. Please check your credentials.")
        return
    
    # Test 3: Send Test Email
    results.append(("Send Test Email", test_send_test_email()))
    
    # Test 4: Send OTP Email
    results.append(("Send OTP Email", test_send_otp_email()))
    
    # Summary
    print("\n" + "="*60)
    print("TEST SUMMARY")
    print("="*60)
    
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{test_name}: {status}")
    
    all_passed = all(result for _, result in results)
    
    if all_passed:
        print("\n🎉 All tests passed! Email service is working correctly.")
    else:
        print("\n⚠️  Some tests failed. Please review the errors above.")


if __name__ == "__main__":
    main()

