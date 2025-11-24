"""
OTP Service for generating and verifying OTPs
In production, this would integrate with SMS/Email services
"""
from typing import Optional, Dict
from datetime import datetime, timedelta
import redis
from app.core.config.settings import settings
from app.core.security import generate_otp

# Initialize Redis client (fallback to in-memory dict if Redis unavailable)
try:
    redis_client = redis.from_url(settings.redis_url, decode_responses=True)
except Exception:
    redis_client = None
    # Fallback to in-memory storage (for development)
    _otp_storage: Dict[str, Dict] = {}


class OTPService:
    """Service for OTP generation and verification"""
    
    OTP_EXPIRY_MINUTES = settings.otp_expiry_minutes
    OTP_MAX_ATTEMPTS = settings.otp_max_attempts
    OTP_RATE_LIMIT_PER_HOUR = settings.otp_rate_limit_per_hour
    
    @staticmethod
    def _get_key(phone_number: str) -> str:
        """Get Redis key for OTP"""
        return f"otp:{phone_number}"
    
    @staticmethod
    def generate_and_store_otp(phone_number: str) -> str:
        """Generate OTP and store it with expiry"""
        # For development/testing, use fixed OTP
        otp = "123456" if settings.environment == "development" else generate_otp(6)
        expiry = datetime.utcnow() + timedelta(minutes=OTPService.OTP_EXPIRY_MINUTES)
        
        otp_data = {
            "otp": otp,
            "expires_at": expiry.isoformat(),
            "attempts": 0,
        }
        
        if redis_client:
            redis_client.setex(
                OTPService._get_key(phone_number),
                OTPService.OTP_EXPIRY_MINUTES * 60,
                otp
            )
        else:
            # Fallback to in-memory storage
            _otp_storage[phone_number] = otp_data
        
        # In production, send OTP via SMS/Email
        print(f"[OTP Service] Generated OTP for {phone_number}: {otp}")
        
        return otp
    
    @staticmethod
    def verify_otp(phone_number: str, otp: str) -> bool:
        """Verify OTP with attempt tracking"""
        if redis_client:
            stored_otp = redis_client.get(OTPService._get_key(phone_number))
            attempts_key = f"otp_attempts:{phone_number}"
            attempts = int(redis_client.get(attempts_key) or 0)
            
            if attempts >= OTPService.OTP_MAX_ATTEMPTS:
                return False
            
            if stored_otp and stored_otp == otp:
                redis_client.delete(OTPService._get_key(phone_number))
                redis_client.delete(attempts_key)
                return True
            
            # Increment attempts
            redis_client.incr(attempts_key)
            redis_client.expire(attempts_key, OTPService.OTP_EXPIRY_MINUTES * 60)
            return False
        else:
            # Fallback to in-memory storage
            if phone_number in _otp_storage:
                otp_data = _otp_storage[phone_number]
                expires_at = datetime.fromisoformat(otp_data["expires_at"])
                
                if datetime.utcnow() > expires_at:
                    del _otp_storage[phone_number]
                    return False
                
                # Check attempts
                if otp_data["attempts"] >= OTPService.OTP_MAX_ATTEMPTS:
                    del _otp_storage[phone_number]
                    return False
                
                if otp_data["otp"] == otp:
                    del _otp_storage[phone_number]
                    return True
                
                otp_data["attempts"] += 1
                if otp_data["attempts"] >= OTPService.OTP_MAX_ATTEMPTS:
                    del _otp_storage[phone_number]
            
            return False
    
    @staticmethod
    def is_otp_valid(phone_number: str) -> bool:
        """Check if OTP exists and is not expired"""
        if redis_client:
            return redis_client.exists(OTPService._get_key(phone_number)) > 0
        else:
            if phone_number in _otp_storage:
                otp_data = _otp_storage[phone_number]
                expires_at = datetime.fromisoformat(otp_data["expires_at"])
                return datetime.utcnow() <= expires_at
            return False

