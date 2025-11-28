"""
Agent Mitra - API v1 Router
Main API router that combines all endpoint routers
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.auth import get_current_user_context, UserContext
from . import auth, users, providers, agents, policies, presentations, chat, analytics, health, notifications, campaigns, tenants, rbac, content, external_services, feature_flags
# Temporarily disable callbacks due to model conflicts
# from . import callbacks

# Create main API router
api_router = APIRouter(prefix="/api/v1", tags=["api"])

# Dashboard endpoint (requires authentication)
@api_router.get("/dashboard/analytics")
async def get_dashboard_analytics(
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Dashboard analytics endpoint for authenticated users"""
    try:
        from app.repositories.analytics_repository import AnalyticsRepository
        from app.repositories.policy_repository import InsurancePolicyRepository

        analytics_repo = AnalyticsRepository(db)
        policy_repo = InsurancePolicyRepository(db)

        # Get real dashboard KPIs
        kpis = analytics_repo.get_dashboard_kpis()

        # Get recent policies (limit to 3)
        recent_policies_data = policy_repo.get_all(limit=3)
        recent_policies = [
            {
                "id": policy.policy_id,
                "policyNumber": policy.policy_number,
                "premium": policy.premium_amount,
                "status": policy.status
            }
            for policy in recent_policies_data
        ]

        # Get recent claims (limit to 2) - simplified for now
        recent_claims = []  # TODO: Implement claims repository

        return {
            "totalPremium": kpis.total_premium_collected,
            "policiesCount": kpis.total_policies,
            "claimsCount": 0,  # TODO: Get from claims repository
            "recentPolicies": recent_policies,
            "recentClaims": recent_claims
        }
    except Exception as e:
        # Fallback to basic data if analytics fail
        print(f"Dashboard analytics error: {e}")
        return {
            "totalPremium": 0.0,
            "policiesCount": 0,
            "claimsCount": 0,
            "recentPolicies": [],
            "recentClaims": []
        }

# Test endpoints (protected - remove in production)
@api_router.get("/test/policies")
async def get_test_policies(
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Test endpoint for policies (requires authentication)"""
    from app.repositories.policy_repository import PolicyRepository

    repo = PolicyRepository(db)
    policies = repo.get_all(limit=10)  # Get first 10 policies

    return [
        {
            "policy_id": str(policy.policy_id),
            "policy_number": policy.policy_number,
            "premium": float(policy.premium_amount) if policy.premium_amount else 0.0,
            "status": policy.status or "active"
        }
        for policy in policies
    ]

@api_router.get("/test/notifications")
async def get_test_notifications(
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Test endpoint for notifications - returns real data from database (requires authentication)"""
    from app.models.notification import Notification
    from sqlalchemy import desc
    
    # Get recent notifications from database (limit 10)
    notifications = db.query(Notification)\
        .order_by(desc(Notification.created_at))\
        .limit(10)\
        .all()
    
    if notifications:
        return [
            {
                "id": str(notif.id),
                "title": notif.title,
                "body": notif.body,
                "type": notif.type,
                "priority": notif.priority,
                "is_read": notif.is_read,
                "created_at": notif.created_at.isoformat() if notif.created_at else None,
                "read_at": notif.read_at.isoformat() if notif.read_at else None,
            }
            for notif in notifications
        ]
    else:
        # Return empty array if no notifications in database
        return []

@api_router.get("/test/agent/profile")
async def get_test_agent_profile(
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Test endpoint for agent profile - returns real data from database (requires authentication)"""
    from app.repositories.agent_repository import AgentRepository

    repo = AgentRepository(db)
    agents = repo.get_all()  # Get agents
    agents = agents[:1] if agents else []  # Take first agent

    if agents:
        agent = agents[0]
        # Get real user info from database
        user_info = None
        if agent.user:
            user_info = {
                "full_name": agent.user.full_name,
                "phone_number": agent.user.phone_number,
                "email": agent.user.email
            }
        
        return {
            "agent_id": str(agent.agent_id),
            "user_id": str(agent.user_id) if agent.user_id else None,
            "agent_code": agent.agent_code,
            "license_number": agent.license_number,
            "license_expiry_date": agent.license_expiry_date.isoformat() if agent.license_expiry_date else None,
            "business_name": agent.business_name,
            "territory": agent.territory,
            "experience_years": agent.experience_years,
            "total_policies_sold": agent.total_policies_sold,
            "total_premium_collected": float(agent.total_premium_collected) if agent.total_premium_collected else 0.0,
            "status": agent.status,
            "verification_status": agent.verification_status,
            "user_info": user_info
        }
    else:
        # Return empty response if no agents in database
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No agents found in database"
        )

# Include all endpoint routers
api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(providers.router, prefix="/providers", tags=["providers"])
api_router.include_router(agents.router, prefix="/agents", tags=["agents"])
api_router.include_router(policies.router, prefix="/policies", tags=["policies"])
api_router.include_router(presentations.router, prefix="/presentations", tags=["presentations"])
api_router.include_router(chat.router, prefix="/chat", tags=["chat"])
api_router.include_router(analytics.router, prefix="/analytics", tags=["analytics"])
api_router.include_router(campaigns.router, prefix="/campaigns", tags=["campaigns"])
# Temporarily disabled callbacks due to model conflicts
# api_router.include_router(callbacks.router, prefix="/callbacks", tags=["callbacks"])
api_router.include_router(feature_flags.router, tags=["feature-flags"])
api_router.include_router(health.router, tags=["health"])
api_router.include_router(notifications.router, tags=["notifications"])
api_router.include_router(content.router, tags=["content"])
api_router.include_router(external_services.router, tags=["external-services"])
api_router.include_router(tenants.router, prefix="/tenants", tags=["tenants"])
api_router.include_router(rbac.router, prefix="/rbac", tags=["rbac"])
# Admin router (optional - for testing/maintenance)
try:
    from . import admin
    api_router.include_router(admin.router, tags=["admin"])
except (ImportError, NameError, AttributeError):
    pass

