"""
Authentication API Endpoints
"""
from fastapi import APIRouter, HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel, validator
from typing import Optional, List
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import (
    verify_password,
    get_password_hash,
    create_token_pair,
    refresh_access_token,
    validate_jwt_token,
    blacklist_token,
)
from app.core.auth import get_current_user_context, UserContext, require_permission
from app.core.rate_limiter import otp_rate_limiter, auth_rate_limiter
from app.core.audit_logger import AuditLogger
from app.core.logging_config import get_logger
from app.services.otp_service import OTPService
from app.repositories.user_repository import UserRepository
from datetime import datetime
from fastapi import Request

logger = get_logger(__name__)

router = APIRouter()
security = HTTPBearer()


class LoginRequest(BaseModel):
    phone_number: Optional[str] = None
    password: Optional[str] = None
    agent_code: Optional[str] = None


class OTPRequest(BaseModel):
    phone_number: Optional[str] = None
    email: Optional[str] = None


class OTPVerifyRequest(BaseModel):
    phone_number: Optional[str] = None
    email: Optional[str] = None
    otp: str


class RefreshTokenRequest(BaseModel):
    refresh_token: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int = 900  # 15 minutes
    user: Optional[dict] = None
    permissions: Optional[List[str]] = None


@router.post("/login", response_model=TokenResponse)
async def login(
    request: LoginRequest,
    http_request: Request,
    db: Session = Depends(get_db)
):
    """
    Login endpoint - supports multiple authentication methods:
    1. Phone + Password (for registered users)
    2. Agent Code (for agents)
    """
    try:
        # Rate limiting
        ip_address = http_request.client.host if http_request.client else "unknown"
        user_agent = http_request.headers.get("user-agent")
        
        is_allowed, remaining = auth_rate_limiter.is_allowed(ip_address)
        if not is_allowed:
            await AuditLogger.log_login_attempt(
                db=db,
                user_id=None,
                phone_number=request.phone_number,
                ip_address=ip_address,
                user_agent=user_agent,
                success=False,
                method="rate_limited",
                error_message="Rate limit exceeded"
            )
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Too many login attempts. Please try again later.",
                headers={"X-RateLimit-Remaining": str(remaining)}
            )
        
        user_repo = UserRepository(db)

        # Find user by phone number or agent code
        user = None
        login_method = None

        if request.agent_code:
            # Agent code login - find agent through agent table
            try:
                user = user_repo.get_by_agent_code(request.agent_code)
                login_method = "agent_code"
                logger.debug(f"Agent code lookup: {request.agent_code}, found user: {user.user_id if user else None}")
            except Exception as e:
                logger.error(f"Error looking up agent code {request.agent_code}: {e}", exc_info=True)
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail=f"Error during authentication: {str(e)}"
                )
        elif request.phone_number:
            # Phone login - find user directly
            user = user_repo.get_by_phone(request.phone_number)
            login_method = "phone"
        else:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Either phone_number or agent_code must be provided"
            )

        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid credentials"
            )

        # Check if user account is active
        if hasattr(user, 'status') and user.status != 'active':
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Account is not active"
            )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error during login: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error during authentication: {str(e)}"
        )

    # Verify password if provided (required for phone login)
    if request.password:
        if not user.password_hash:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Password authentication not available for this account"
            )

        if not verify_password(request.password, user.password_hash):
            # Log failed login attempt
            await AuditLogger.log_login_attempt(
                db=db,
                user_id=str(user.user_id),
                phone_number=user.phone_number,
                ip_address=ip_address,
                user_agent=user_agent,
                success=False,
                method=login_method,
                error_message="Invalid password"
            )
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid password"
            )
    elif login_method == "phone":
        # Phone login without password - not allowed
        print("Phone login attempted without password")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Password is required for phone number login"
        )

    # Get feature flags and permissions for user
    from app.services.featurehub_service import get_featurehub_service
    from app.core.auth import PERMISSIONS, ROLE_HIERARCHY
    
    # Build user context for FeatureHub
    try:
        user_context = {
            "userId": str(user.user_id),
            "role": user_role,  # Use role from RBAC system
            "email": getattr(user, 'email', None) or "",
            "phoneNumber": getattr(user, 'phone_number', None) or "",
        }
    except Exception as e:
        logger.error(f"Error building user context: {e}", exc_info=True)
        user_context = {
            "userId": str(user.user_id) if hasattr(user, 'user_id') else "",
            "role": "agent",
            "email": "",
            "phoneNumber": "",
        }
    
    # Get feature flags from FeatureHub (with fallback to defaults)
    feature_flags = {}
    try:
        featurehub_service = await get_featurehub_service()
        feature_flags = await featurehub_service.get_all_flags(user_context=user_context)
        # Ensure we have a dict even if service returns empty
        if not feature_flags:
            raise ValueError("Empty flags returned")
    except Exception as e:
        # FeatureHub unavailable - use fallback flags from settings/env
        logger.warning(f"FeatureHub unavailable, using fallback flags: {e}")
        # Use default feature flags - these match the fallback in FeatureHubService
        feature_flags = {
            "phone_auth_enabled": True,
            "email_auth_enabled": True,
            "otp_verification_enabled": True,
            "agent_code_login_enabled": True,
            "dashboard_enabled": True,
            "policies_enabled": True,
            "chat_enabled": True,
            "notifications_enabled": True,
            "whatsapp_integration_enabled": True,
            "chatbot_enabled": True,
            "callback_management_enabled": True,
            "analytics_enabled": True,
            "roi_dashboards_enabled": True,
            "portal_enabled": True,
            "data_import_enabled": True,
            "marketing_campaigns_enabled": True,
            "campaign_builder_enabled": True,
        }
    
    # Get permissions and role from RBAC system
    try:
        # Create UserContext to load permissions from database
        from app.core.auth import UserContext
        auth_user_context = UserContext(user, {"sub": str(user.user_id)}, db)
        permissions = auth_user_context.permissions
        # Use role from UserContext to ensure it's from RBAC system
        user_role = auth_user_context.role
        logger.info(f"Loaded {len(permissions)} permissions and role '{user_role}' for user {user.user_id}")
    except Exception as e:
        logger.error(f"Error loading permissions from RBAC system: {e}", exc_info=True)
        permissions = []  # Fallback to empty permissions
        user_role = getattr(user, 'role', 'agent')  # Fallback to user object role
    
    # Create token pair with feature flags, permissions, and tenant_id
    try:
        user_data = {
            "user_id": str(user.user_id),
            "phone_number": getattr(user, 'phone_number', None) or "",
            "role": user_role,  # Use role from RBAC system
            "email": getattr(user, 'email', None) or "",
            "tenant_id": str(user.tenant_id) if hasattr(user, 'tenant_id') and user.tenant_id else "",
            "permissions": permissions,
            "feature_flags": feature_flags,
        }
    except Exception as e:
        logger.error(f"Error building user_data: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error preparing user data: {str(e)}"
        )

    token_response = create_token_pair(user_data)

    # Create session in database
    try:
        user_repo.create_session(
            user_id=user.user_id,
            access_token=token_response["access_token"],
            refresh_token=token_response["refresh_token"],
        )
    except Exception as e:
        # Log error but don't fail login
        print(f"Failed to create session: {e}")

    # Update last login timestamp
    try:
        user_repo.update(user.user_id, {"last_login_at": datetime.utcnow()})
    except Exception as e:
        # Log error but don't fail login
        print(f"Failed to update last login: {e}")
    
    # Log successful login
    await AuditLogger.log_login_attempt(
        db=db,
        user_id=str(user.user_id),
        phone_number=user.phone_number,
        ip_address=ip_address,
        user_agent=user_agent,
        success=True,
        method=login_method
    )
    
    # Check trial period and subscription status
    from app.core.trial_subscription import TrialSubscriptionService
    trial_status = TrialSubscriptionService.check_trial_status(user)

    # Return token response with user info
    return TokenResponse(
        access_token=token_response["access_token"],
        refresh_token=token_response["refresh_token"],
        token_type=token_response["token_type"],
        expires_in=token_response["expires_in"],
        permissions=permissions,
        user={
            "user_id": str(user.user_id),
            "phone_number": user.phone_number,
            "full_name": user.full_name,
            "role": user.role,
            "is_verified": getattr(user, 'phone_verified', False) or getattr(user, 'email_verified', False),
            "email": user.email,
            "trial_status": trial_status,
        }
    )


@router.post("/send-otp")
async def send_otp(
    request: OTPRequest,
    http_request: Request,
    db: Session = Depends(get_db)
):
    """Send OTP to phone number or email"""
    try:
        # Validate input
        if not request.phone_number and not request.email:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Either phone_number or email must be provided"
            )
        
        # Rate limiting for OTP requests
        ip_address = http_request.client.host if http_request.client else "unknown"
        user_agent = http_request.headers.get("user-agent")
        
        # Use phone number or email as identifier for rate limiting
        identifier = request.phone_number or request.email
        is_allowed, remaining = otp_rate_limiter.is_allowed(identifier)
        
        if not is_allowed:
            await AuditLogger.log_otp_sent(
                db=db,
                phone_number=request.phone_number,
                email=request.email,
                ip_address=ip_address,
                user_agent=user_agent,
                success=False,
                error_message="Rate limit exceeded"
            )
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=f"Too many OTP requests. Maximum {otp_rate_limiter.limit} per {otp_rate_limiter.window_str}. Please try again later.",
                headers={"X-RateLimit-Remaining": str(remaining)}
            )
        
        user_repo = UserRepository(db)
        
        # Check if user exists, if not create one
        user = None
        if request.phone_number:
            user = user_repo.get_by_phone(request.phone_number)
        elif request.email:
            user = user_repo.get_by_email(request.email)
        
        if not user:
            # Create new user
            user = user_repo.create({
                "phone_number": request.phone_number,
                "email": request.email,
                "role": "junior_agent",  # Default role for portal users (valid enum value)
                "phone_verified": False,
            })
        
        # Generate and store OTP
        try:
            if request.phone_number:
                otp = OTPService.generate_and_store_otp(request.phone_number)
                # TODO: Send SMS OTP via SMS provider
                print(f"[OTP Service] Generated OTP for {request.phone_number}: {otp}")
            elif request.email:
                otp = OTPService.generate_and_store_otp(request.email)
                # Send Email OTP via Email provider
                from app.services.email_service import get_email_service
                email_service = get_email_service()
                email_sent = email_service.send_otp_email(request.email, otp)
                if not email_sent:
                    logger.warning(f"Failed to send OTP email to {request.email}, but OTP was generated: {otp}")
                else:
                    logger.info(f"OTP email sent successfully to {request.email}")
            
            # Log OTP sent
            await AuditLogger.log_otp_sent(
                db=db,
                phone_number=request.phone_number,
                email=request.email,
                ip_address=ip_address,
                user_agent=user_agent,
                success=True
            )
            
            return {
                "success": True,
                "message": "OTP sent successfully",
                "data": {
                    "phone_number": request.phone_number,
                    "email": request.email,
                    "expires_in": OTPService.OTP_EXPIRY_MINUTES * 60
                }
            }
        except HTTPException:
            # Re-raise HTTP exceptions as-is
            raise
        except Exception as e:
            # Log the actual error for debugging
            logger.error(f"Error sending OTP: {str(e)}", exc_info=True)
            
            # Try to log failure (but don't fail if logging fails)
            try:
                await AuditLogger.log_otp_sent(
                    db=db,
                    phone_number=request.phone_number,
                    email=request.email,
                    ip_address=ip_address,
                    user_agent=user_agent,
                    success=False,
                    error_message=str(e)
                )
            except Exception as log_error:
                logger.error(f"Failed to log OTP error: {str(log_error)}")
            
            # Always show error details for debugging
            error_detail = f"Failed to send OTP: {str(e)}"
            logger.error(f"OTP send error details: {error_detail}")
            import traceback
            logger.error(f"Traceback: {traceback.format_exc()}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=error_detail
            )
    except HTTPException:
        # Re-raise HTTP exceptions as-is
        raise
    except Exception as e:
        # Catch any other errors that might occur
        import traceback
        error_detail = f"Unexpected error: {str(e)}"
        logger.error(f"Unexpected error in send_otp: {error_detail}")
        logger.error(f"Traceback: {traceback.format_exc()}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=error_detail
        )


@router.post("/send-email-otp")
async def send_email_otp(
    request: OTPRequest,
    http_request: Request,
    db: Session = Depends(get_db)
):
    """Send OTP to email address (dedicated email OTP endpoint as per design doc)"""
    if not request.email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email address is required"
        )
    
    # Use the existing send_otp logic but only for email
    email_request = OTPRequest(email=request.email)
    return await send_otp(email_request, http_request, db)


@router.post("/verify-email-otp", response_model=TokenResponse)
async def verify_email_otp(
    request: OTPVerifyRequest,
    http_request: Request,
    db: Session = Depends(get_db)
):
    """Verify email OTP and return tokens (dedicated email OTP verification endpoint as per design doc)"""
    if not request.email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email address is required"
        )
    
    # Use the existing verify_otp logic but only for email
    email_request = OTPVerifyRequest(email=request.email, otp=request.otp)
    return await verify_otp(email_request, http_request, db)


@router.post("/verify-otp", response_model=TokenResponse)
async def verify_otp(
    request: OTPVerifyRequest,
    http_request: Request,
    db: Session = Depends(get_db)
):
    """Verify OTP and return tokens (supports both phone and email)"""
    # Validate input
    if not request.phone_number and not request.email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Either phone_number or email must be provided"
        )
    
    user_repo = UserRepository(db)
    ip_address = http_request.client.host if http_request.client else "unknown"
    user_agent = http_request.headers.get("user-agent")
    
    # Get identifier for OTP verification
    identifier = request.phone_number or request.email
    
    # Get user to track attempts
    user = None
    if request.phone_number:
        user = user_repo.get_by_phone(request.phone_number)
    elif request.email:
        user = user_repo.get_by_email(request.email)
    
    user_id = str(user.user_id) if user else None
    
    # Verify OTP
    otp_valid = OTPService.verify_otp(identifier, request.otp)
    
    if not otp_valid:
        # Log failed OTP verification
        await AuditLogger.log_otp_verification(
            db=db,
            phone_number=request.phone_number,
            user_id=user_id,
            ip_address=ip_address,
            user_agent=user_agent,
            success=False,
            attempts=OTPService.OTP_MAX_ATTEMPTS,  # Will be tracked by service
            error_message="Invalid or expired OTP"
        )
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired OTP"
        )
    
    # Get or create user
    if not user:
        user = user_repo.create({
            "phone_number": request.phone_number,
            "email": request.email,
            "role": "policyholder",
            "phone_verified": bool(request.phone_number),
            "email_verified": bool(request.email),
            "status": "active",
        })
    else:
        # Mark user as verified
        update_data = {}
        if request.phone_number:
            update_data["phone_verified"] = True
        if request.email:
            update_data["email_verified"] = True
        user_repo.update(user.user_id, update_data)

    # Get feature flags and permissions for user
    from app.services.featurehub_service import get_featurehub_service
    from app.core.auth import PERMISSIONS, ROLE_HIERARCHY
    
    # Build user context for FeatureHub
    try:
        user_context = {
            "userId": str(user.user_id),
            "role": user_role,  # Use role from RBAC system
            "email": getattr(user, 'email', None) or "",
            "phoneNumber": getattr(user, 'phone_number', None) or "",
        }
    except Exception as e:
        logger.error(f"Error building user context: {e}", exc_info=True)
        user_context = {
            "userId": str(user.user_id) if hasattr(user, 'user_id') else "",
            "role": "agent",
            "email": "",
            "phoneNumber": "",
        }
    
    # Get feature flags from FeatureHub (with fallback to defaults)
    feature_flags = {}
    try:
        featurehub_service = await get_featurehub_service()
        feature_flags = await featurehub_service.get_all_flags(user_context=user_context)
        # Ensure we have a dict even if service returns empty
        if not feature_flags:
            raise ValueError("Empty flags returned")
    except Exception as e:
        # FeatureHub unavailable - use fallback flags from settings/env
        logger.warning(f"FeatureHub unavailable, using fallback flags: {e}")
        # Use default feature flags - these match the fallback in FeatureHubService
        feature_flags = {
            "phone_auth_enabled": True,
            "email_auth_enabled": True,
            "otp_verification_enabled": True,
            "agent_code_login_enabled": True,
            "dashboard_enabled": True,
            "policies_enabled": True,
            "chat_enabled": True,
            "notifications_enabled": True,
            "whatsapp_integration_enabled": True,
            "chatbot_enabled": True,
            "callback_management_enabled": True,
            "analytics_enabled": True,
            "roi_dashboards_enabled": True,
            "portal_enabled": True,
            "data_import_enabled": True,
            "marketing_campaigns_enabled": True,
            "campaign_builder_enabled": True,
        }
    
    # Get permissions and role from RBAC system
    try:
        # Create UserContext to load permissions from database
        from app.core.auth import UserContext
        auth_user_context = UserContext(user, {"sub": str(user.user_id)}, db)
        permissions = auth_user_context.permissions
        # Use role from UserContext to ensure it's from RBAC system
        user_role = auth_user_context.role
        logger.info(f"Loaded {len(permissions)} permissions and role '{user_role}' for user {user.user_id}")
    except Exception as e:
        logger.error(f"Error loading permissions from RBAC system: {e}", exc_info=True)
        permissions = []  # Fallback to empty permissions
        user_role = getattr(user, 'role', 'agent')  # Fallback to user object role
    
    # Create token pair with feature flags, permissions, and tenant_id
    try:
        user_data = {
            "user_id": str(user.user_id),
            "phone_number": getattr(user, 'phone_number', None) or "",
            "role": user_role,  # Use role from RBAC system
            "email": getattr(user, 'email', None) or "",
            "tenant_id": str(user.tenant_id) if hasattr(user, 'tenant_id') and user.tenant_id else "",
            "permissions": permissions,
            "feature_flags": feature_flags,
        }
    except Exception as e:
        logger.error(f"Error building user_data: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error preparing user data: {str(e)}"
        )

    token_response = create_token_pair(user_data)

    # Create session in database
    try:
        user_repo.create_session(
            user_id=user.user_id,
            access_token=token_response["access_token"],
            refresh_token=token_response["refresh_token"],
        )
    except Exception as e:
        # Log error but don't fail login
        print(f"Failed to create session: {e}")

    # Update last login timestamp
    try:
        user_repo.update(user.user_id, {"last_login_at": datetime.utcnow()})
    except Exception as e:
        # Log error but don't fail login
        print(f"Failed to update last login: {e}")
    
    # Log successful OTP verification
    await AuditLogger.log_otp_verification(
        db=db,
        phone_number=request.phone_number,
        user_id=str(user.user_id),
        ip_address=ip_address,
        user_agent=user_agent,
        success=True,
        attempts=1
    )
    
    # Check trial period and subscription status
    from app.core.trial_subscription import TrialSubscriptionService
    
    trial_status = TrialSubscriptionService.check_trial_status(user)
    
    # Include trial/subscription info in token response (will be added to user data)
    # Note: We allow login even if trial expired - frontend will handle feature restrictions

    return TokenResponse(
        access_token=token_response["access_token"],
        refresh_token=token_response["refresh_token"],
        token_type=token_response["token_type"],
        expires_in=token_response["expires_in"],
        user={
            "user_id": str(user.user_id),
            "phone_number": user.phone_number,
            "full_name": user.full_name,
            "role": user.role,
            "is_verified": getattr(user, 'phone_verified', False) or getattr(user, 'email_verified', False),
            "email": user.email,
            "trial_status": trial_status,
        }
    )


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(request: RefreshTokenRequest, db: Session = Depends(get_db)):
    """Refresh access token using valid refresh token"""
    # Verify refresh token with enhanced validation
    token_response = refresh_access_token(request.refresh_token)
    if not token_response:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token"
        )

    # Get user information (optional, for user data in response)
    user_repo = UserRepository(db)
    # Extract user_id from the refresh token payload
    refresh_payload = validate_jwt_token(request.refresh_token, "refresh")
    if refresh_payload:
        user_id = refresh_payload.get("sub")
        user = user_repo.get_by_id(user_id) if user_id else None

        if user:
            # Get permissions and role from RBAC system
            try:
                from app.core.auth import UserContext
                auth_user_context = UserContext(user, {"sub": str(user.user_id)}, db)
                permissions = auth_user_context.permissions
                user_role = auth_user_context.role
                logger.info(f"Loaded {len(permissions)} permissions and role '{user_role}' for refresh token")
            except Exception as e:
                logger.error(f"Error loading permissions for refresh: {e}", exc_info=True)
                permissions = []
                user_role = getattr(user, 'role', 'agent')

            # Get trial status
            from app.core.trial_subscription import TrialSubscriptionService
            trial_status = TrialSubscriptionService.check_trial_status(user)

            return TokenResponse(
                access_token=token_response["access_token"],
                refresh_token=request.refresh_token,  # Return same refresh token
                token_type=token_response["token_type"],
                expires_in=token_response["expires_in"],
                permissions=permissions,
                user={
                    "user_id": str(user.user_id),
                    "phone_number": user.phone_number,
                    "full_name": user.full_name,
                    "role": user_role,
                    "is_verified": getattr(user, 'phone_verified', False) or getattr(user, 'email_verified', False),
                    "email": user.email,
                    "trial_status": trial_status,
                }
            )

    # Return token response without user data if user lookup fails
    return TokenResponse(
        access_token=token_response["access_token"],
        refresh_token=request.refresh_token,
        token_type=token_response["token_type"],
        expires_in=token_response["expires_in"],
    )


@router.post("/logout")
async def logout(
    http_request: Request,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Logout endpoint - blacklist current access token"""
    ip_address = http_request.client.host if http_request.client else "unknown"
    user_agent = http_request.headers.get("user-agent")
    
    # Blacklist the current access token
    auth_header = current_user.token_data.get("token")
    if auth_header:
        blacklist_token(auth_header)

    # Invalidate user sessions (optional - could be done in background)
    # For now, just return success
    
    # Log logout
    await AuditLogger.log_logout(
        db=db,
        user_id=current_user.user_id,
        ip_address=ip_address,
        user_agent=user_agent
    )

    return {"message": "Logged out successfully"}


@router.get("/sessions")
async def get_sessions(
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Get user's active sessions"""
    user_repo = UserRepository(db)
    sessions = user_repo.get_user_sessions(current_user.user_id)

    return {
        "sessions": [
            {
                "session_id": str(session.session_id),
                "created_at": session.created_at.isoformat(),
                "expires_at": session.expires_at.isoformat(),
                "is_current": False,  # TODO: Implement current session detection
            }
            for session in sessions
            if session.is_active
        ]
    }


@router.delete("/sessions/{session_id}")
async def delete_session(
    session_id: str,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Delete specific session"""
    user_repo = UserRepository(db)

    # Verify session belongs to user
    session = user_repo.get_session_by_id(session_id)
    if not session or str(session.user_id) != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found"
        )

    # Deactivate session
    user_repo.deactivate_session(session_id)

    return {"message": "Session deleted successfully"}


@router.delete("/sessions")
async def delete_all_sessions(
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Delete all user sessions except current"""
    user_repo = UserRepository(db)

    # Deactivate all sessions for user
    user_repo.deactivate_user_sessions(current_user.user_id)

    return {"message": "All sessions deleted successfully"}
    token = credentials.credentials
    payload = verify_token(token)
    
    if payload:
        user_id = payload.get("sub")
        if user_id:
            user_repo = UserRepository(db)
            user_repo.deactivate_all_sessions(user_id)
    
    return {"message": "Logged out successfully"}
