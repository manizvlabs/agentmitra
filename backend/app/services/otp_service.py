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
    
    OTP_EXPIRY_MINUTES = 10
    
    @staticmethod
    def _get_key(phone_number: str) -> str:
        """Get Redis key for OTP"""
        return f"otp:{phone_number}"
    
    @staticmethod
    def generate_and_store_otp(phone_number: str) -> str:
        """Generate OTP and store it with expiry"""
        otp = generate_otp(6)
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
        """Verify OTP"""
        if redis_client:
            stored_otp = redis_client.get(OTPService._get_key(phone_number))
            if stored_otp and stored_otp == otp:
                redis_client.delete(OTPService._get_key(phone_number))
                return True
            return False
        else:
            # Fallback to in-memory storage
            if phone_number in _otp_storage:
                otp_data = _otp_storage[phone_number]
                expires_at = datetime.fromisoformat(otp_data["expires_at"])
                
                if datetime.utcnow() > expires_at:
                    del _otp_storage[phone_number]
                    return False
                
                if otp_data["otp"] == otp:
                    del _otp_storage[phone_number]
                    return True
                
                otp_data["attempts"] += 1
                if otp_data["attempts"] >= 5:
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

