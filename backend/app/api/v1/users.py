"""
User Management API Endpoints
"""
from fastapi import APIRouter, HTTPException, Depends, Query, status
from fastapi.security import HTTPBearer
from pydantic import BaseModel, validator
from typing import Optional, List, Dict, Any
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.auth import (
    get_current_user_context,
    UserContext,
    auth_service
)
from app.repositories.user_repository import UserRepository
from app.models.user import UserStatusEnum, UserRoleEnum
from datetime import datetime

router = APIRouter()
security = HTTPBearer()


class UserResponse(BaseModel):
    user_id: str
    email: Optional[str] = None
    phone_number: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    display_name: Optional[str] = None
    role: str
    status: str
    phone_verified: Optional[bool] = None
    email_verified: Optional[bool] = None
    last_login_at: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class UserUpdateRequest(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    display_name: Optional[str] = None
    email: Optional[str] = None
    language_preference: Optional[str] = None
    timezone: Optional[str] = None
    theme_preference: Optional[str] = None
    address: Optional[Dict[str, Any]] = None
    emergency_contact: Optional[Dict[str, Any]] = None


class UserSearchFilters(BaseModel):
    role: Optional[str] = None
    status: Optional[str] = None
    phone_verified: Optional[bool] = None
    email_verified: Optional[bool] = None


class UserPreferences(BaseModel):
    language_preference: Optional[str] = None
    timezone: Optional[str] = None
    theme_preference: Optional[str] = None
    notification_preferences: Optional[Dict[str, Any]] = None


@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get current user profile
    - Returns the authenticated user's own profile information
    """
    user_repo = UserRepository(db)
    user = user_repo.get_by_id(current_user.user_id)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    return UserResponse(
        user_id=str(user.user_id),
        email=user.email,
        phone_number=user.phone_number,
        first_name=user.first_name,
        last_name=user.last_name,
        display_name=user.display_name,
        role=user.role,
        status=user.status or "active",
        phone_verified=user.phone_verified,
        email_verified=user.email_verified,
        last_login_at=user.last_login_at,
        created_at=user.created_at,
        updated_at=user.updated_at
    )


@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: str,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get user profile
    - Users can view their own profile
    - Admins can view any user's profile
    """
    user_repo = UserRepository(db)

    # Check permissions
    if current_user.user_id != user_id:
        # Require permission to view other users
        if not current_user.has_any_permission(["users.read", "agents.read"]):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions to view this user"
            )

    user = user_repo.get_by_id(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    return UserResponse(
        user_id=str(user.user_id),
        email=user.email,
        phone_number=user.phone_number,
        first_name=user.first_name,
        last_name=user.last_name,
        display_name=user.display_name,
        role=user.role,
        status=user.status or "active",
        phone_verified=user.phone_verified,
        email_verified=user.email_verified,
        last_login_at=user.last_login_at,
        created_at=user.created_at,
        updated_at=user.updated_at
    )


@router.put("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: str,
    user_data: UserUpdateRequest,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Update user profile
    - Users can update their own profile
    - Admins can update any user's profile
    """
    user_repo = UserRepository(db)

    # Check permissions
    if current_user.user_id != user_id:
        # Require permission to update other users
        if not current_user.has_permission("users.update"):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions to update this user"
            )

    user = user_repo.get_by_id(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    # Convert request to dict and filter out None values
    update_data = user_data.dict(exclude_unset=True)

    # Users can only update certain fields of their own profile
    if current_user.user_id == user_id:
        allowed_fields = {
            'first_name', 'last_name', 'display_name', 'language_preference',
            'timezone', 'theme_preference', 'address', 'emergency_contact'
        }
        update_data = {k: v for k, v in update_data.items() if k in allowed_fields}

    updated_user = user_repo.update(user_id, update_data)
    if not updated_user:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update user"
        )

    return UserResponse(
        user_id=str(updated_user.user_id),
        email=updated_user.email,
        phone_number=updated_user.phone_number,
        first_name=updated_user.first_name,
        last_name=updated_user.last_name,
        display_name=updated_user.display_name,
        role=updated_user.role,
        status=updated_user.status or "active",
        phone_verified=updated_user.phone_verified,
        email_verified=updated_user.email_verified,
        last_login_at=updated_user.last_login_at,
        created_at=updated_user.created_at,
        updated_at=updated_user.updated_at
    )


@router.delete("/{user_id}")
async def deactivate_user(
    user_id: str,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Deactivate user account (soft delete)
    - Only super admins can deactivate users
    """
    # Check permission using database-driven authorization
    if not current_user.has_permission("users.delete"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to deactivate users"
        )

    user_repo = UserRepository(db)

    user = user_repo.get_by_id(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    # Prevent self-deactivation
    if current_user.user_id == user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot deactivate your own account"
        )

    # Soft delete by updating status
    success = user_repo.update(user_id, {
        "status": "deactivated",
        "deactivated_at": datetime.utcnow()
    })

    if not success:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to deactivate user"
        )

    return {"message": "User deactivated successfully", "user_id": user_id}


@router.get("/", response_model=List[UserResponse])
async def search_users(
    q: Optional[str] = Query(None, description="Search query for name, email, or phone"),
    role: Optional[str] = Query(None, description="Filter by role"),
    status: Optional[str] = Query(None, description="Filter by status"),
    limit: int = Query(20, ge=1, le=100, description="Number of results to return"),
    offset: int = Query(0, ge=0, description="Number of results to skip"),
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Search and filter users
    - Agents can search for policyholders
    - Managers and admins can search more broadly
    - Supports role-based filtering
    """
    user_repo = UserRepository(db)

    # Check permissions based on user role
    if current_user.role in ["super_admin", "provider_admin", "regional_manager"]:
        # Admins and managers can search broadly
        pass
    elif current_user.role in ["senior_agent", "junior_agent"]:
        # Agents can only search for policyholders
        if role and role != "policyholder":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Agents can only search for policyholders"
            )
    else:
        # Other roles cannot search users
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to search users"
        )

    # Build filters based on user permissions and query parameters
    filters = {}

    if q:
        # Search in name, email, or phone
        filters["search"] = q

    if role:
        filters["role"] = role
    elif current_user.role in ["junior_agent", "senior_agent"]:
        # Agents can only see policyholders by default
        filters["role"] = "policyholder"

    if status and current_user.has_role_level("provider_admin"):
        # Only admins can filter by status
        filters["status"] = status

    users = user_repo.search_users(filters, limit=limit, offset=offset)

    return [
        UserResponse(
            user_id=str(user.user_id),
            email=user.email,
            phone_number=user.phone_number,
            first_name=user.first_name,
            last_name=user.last_name,
            display_name=user.display_name,
            role=user.role,
            status=user.status or "active",
            phone_verified=user.phone_verified,
            email_verified=user.email_verified,
            last_login_at=user.last_login_at,
            created_at=user.created_at,
            updated_at=user.updated_at
        )
        for user in users
    ]


@router.get("/{user_id}/preferences", response_model=UserPreferences)
async def get_user_preferences(
    user_id: str,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get user preferences
    - Users can view their own preferences
    - Admins can view any user's preferences
    """
    if current_user.user_id != user_id and not current_user.has_permission("users.read"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to view user preferences"
        )

    user_repo = UserRepository(db)
    user = user_repo.get_by_id(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    return UserPreferences(
        language_preference=user.language_preference,
        timezone=user.timezone,
        theme_preference=user.theme_preference,
        notification_preferences=user.notification_preferences
    )


@router.put("/{user_id}/preferences", response_model=UserPreferences)
async def update_user_preferences(
    user_id: str,
    preferences: UserPreferences,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Update user preferences
    - Users can update their own preferences
    - Admins can update any user's preferences
    """
    if current_user.user_id != user_id and not current_user.has_permission("users.update"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to update user preferences"
        )

    user_repo = UserRepository(db)
    user = user_repo.get_by_id(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    # Convert preferences to dict and update
    update_data = preferences.dict(exclude_unset=True)
    updated_user = user_repo.update(user_id, update_data)

    if not updated_user:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update user preferences"
        )

    return UserPreferences(
        language_preference=updated_user.language_preference,
        timezone=updated_user.timezone,
        theme_preference=updated_user.theme_preference,
        notification_preferences=updated_user.notification_preferences
    )

