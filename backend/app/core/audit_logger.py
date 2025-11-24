"""
Audit Logging Service
Logs authentication events and security-related activities for compliance
"""
from typing import Optional, Dict, Any
from datetime import datetime
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.core.logging_config import get_logger
from app.core.config.settings import settings

logger = get_logger(__name__)


class AuditLogger:
    """Service for audit logging authentication and security events"""
    
    @staticmethod
    async def log_auth_event(
        db: Session,
        event_type: str,
        user_id: Optional[str] = None,
        phone_number: Optional[str] = None,
        email: Optional[str] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
        success: bool = True,
        details: Optional[Dict[str, Any]] = None,
        error_message: Optional[str] = None
    ):
        """
        Log authentication event
        
        Args:
            db: Database session
            event_type: Type of event (login, logout, otp_sent, otp_verified, etc.)
            user_id: User ID if available
            phone_number: Phone number if available
            email: Email if available
            ip_address: Client IP address
            user_agent: User agent string
            success: Whether the event was successful
            details: Additional details
            error_message: Error message if failed
        """
        if not settings.audit_logging_enabled:
            return
        
        try:
            # Log to application logger
            log_data = {
                "event_type": event_type,
                "user_id": user_id,
                "phone_number": phone_number,
                "email": email,
                "ip_address": ip_address,
                "user_agent": user_agent,
                "success": success,
                "timestamp": datetime.utcnow().isoformat(),
            }
            
            if details:
                log_data["details"] = details
            
            if error_message:
                log_data["error_message"] = error_message
            
            if success:
                logger.info(f"Auth event: {event_type}", extra=log_data)
            else:
                logger.warning(f"Auth event failed: {event_type}", extra=log_data)
            
            # Store in database audit log if table exists
            try:
                # Check if audit log table exists
                result = db.execute(text("""
                    SELECT EXISTS (
                        SELECT FROM information_schema.tables 
                        WHERE table_schema = 'audit' 
                        AND table_name = 'lic_audit_log'
                    )
                """))
                
                if result.scalar():
                    # Insert into audit log
                    db.execute(text("""
                        INSERT INTO audit.lic_audit_log (
                            table_name, record_id, operation,
                            user_id, ip_address, user_agent, timestamp,
                            new_values
                        ) VALUES (
                            'auth_events', :record_id, :operation,
                            :user_id::uuid, :ip_address::inet, :user_agent, NOW(),
                            :new_values::jsonb
                        )
                    """), {
                        "record_id": user_id or phone_number or email or "unknown",
                        "operation": event_type.upper(),
                        "user_id": user_id,
                        "ip_address": ip_address,
                        "user_agent": user_agent,
                        "new_values": {
                            "event_type": event_type,
                            "success": success,
                            "phone_number": phone_number,
                            "email": email,
                            "details": details or {},
                            "error_message": error_message
                        }
                    })
                    db.commit()
            except Exception as e:
                # Don't fail the request if audit logging fails
                logger.error(f"Failed to write audit log to database: {e}")
                db.rollback()
        
        except Exception as e:
            logger.error(f"Failed to log audit event: {e}")
    
    @staticmethod
    async def log_login_attempt(
        db: Session,
        user_id: Optional[str],
        phone_number: Optional[str],
        ip_address: Optional[str],
        user_agent: Optional[str],
        success: bool,
        method: str = "phone",
        error_message: Optional[str] = None
    ):
        """Log login attempt"""
        await AuditLogger.log_auth_event(
            db=db,
            event_type="login_attempt",
            user_id=user_id,
            phone_number=phone_number,
            ip_address=ip_address,
            user_agent=user_agent,
            success=success,
            details={"method": method},
            error_message=error_message
        )
    
    @staticmethod
    async def log_otp_sent(
        db: Session,
        phone_number: Optional[str] = None,
        email: Optional[str] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
        success: bool = True,
        error_message: Optional[str] = None
    ):
        """Log OTP sent event"""
        await AuditLogger.log_auth_event(
            db=db,
            event_type="otp_sent",
            phone_number=phone_number,
            email=email,
            ip_address=ip_address,
            user_agent=user_agent,
            success=success,
            error_message=error_message
        )
    
    @staticmethod
    async def log_otp_verification(
        db: Session,
        phone_number: str,
        user_id: Optional[str],
        ip_address: Optional[str],
        user_agent: Optional[str],
        success: bool,
        attempts: int = 1,
        error_message: Optional[str] = None
    ):
        """Log OTP verification event"""
        await AuditLogger.log_auth_event(
            db=db,
            event_type="otp_verification",
            user_id=user_id,
            phone_number=phone_number,
            ip_address=ip_address,
            user_agent=user_agent,
            success=success,
            details={"attempts": attempts},
            error_message=error_message
        )
    
    @staticmethod
    async def log_logout(
        db: Session,
        user_id: str,
        ip_address: Optional[str],
        user_agent: Optional[str]
    ):
        """Log logout event"""
        await AuditLogger.log_auth_event(
            db=db,
            event_type="logout",
            user_id=user_id,
            ip_address=ip_address,
            user_agent=user_agent,
            success=True
        )
    
    @staticmethod
    async def log_security_event(
        db: Session,
        event_type: str,
        user_id: Optional[str],
        ip_address: Optional[str],
        user_agent: Optional[str],
        details: Optional[Dict[str, Any]] = None
    ):
        """Log general security event"""
        await AuditLogger.log_auth_event(
            db=db,
            event_type=event_type,
            user_id=user_id,
            ip_address=ip_address,
            user_agent=user_agent,
            success=True,
            details=details
        )

