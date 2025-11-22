"""
Agent Mitra - API v1 Router
Main API router that combines all endpoint routers
"""

from fastapi import APIRouter
from . import auth, users, providers, agents, policies, presentations, chat, analytics, feature_flags, health, notifications

# Create main API router
api_router = APIRouter(prefix="/api/v1", tags=["api"])

# Dashboard endpoint (simplified for Flutter app compatibility)
@api_router.get("/dashboard/analytics")
async def get_dashboard_analytics():
    """Simple dashboard analytics endpoint for Flutter app"""
    # Return mock data for now - will be replaced with real analytics
    return {
        "totalPremium": 35500.0,
        "policiesCount": 3,
        "claimsCount": 2,
        "recentPolicies": [
            {
                "id": "POL001",
                "policyNumber": "LIC123456789",
                "premium": 2500.0,
                "status": "active"
            },
            {
                "id": "POL002",
                "policyNumber": "HDFC987654321",
                "premium": 1500.0,
                "status": "active"
            },
            {
                "id": "POL003",
                "policyNumber": "SBI456789123",
                "premium": 3000.0,
                "status": "pending"
            }
        ],
        "recentClaims": [
            {
                "id": "CLM001",
                "policyNumber": "LIC123456789",
                "amount": 45000.0,
                "status": "approved"
            },
            {
                "id": "CLM002",
                "policyNumber": "HDFC987654321",
                "amount": 25000.0,
                "status": "pending"
            }
        ]
    }

# Test endpoints (temporary - remove in production)
@api_router.get("/test/policies")
async def get_test_policies():
    """Test endpoint for policies (no auth required)"""
    return [
        {
            "policy_id": "POL001",
            "policy_number": "LIC123456789",
            "premium": 2500.0,
            "status": "active"
        },
        {
            "policy_id": "POL002",
            "policy_number": "HDFC987654321",
            "premium": 1500.0,
            "status": "active"
        },
        {
            "policy_id": "POL003",
            "policy_number": "SBI456789123",
            "premium": 3000.0,
            "status": "pending"
        }
    ]

@api_router.get("/test/notifications")
async def get_test_notifications():
    """Test endpoint for notifications (no auth required)"""
    return [
        {
            "id": "notif_001",
            "title": "Policy Renewal Due",
            "body": "Your policy LIC123456789 is due for renewal in 7 days.",
            "type": "renewal",
            "is_read": False
        },
        {
            "id": "notif_002",
            "title": "Claim Approved",
            "body": "Your claim CLM001 for ₹45,000 has been approved.",
            "type": "claim",
            "is_read": False
        },
        {
            "id": "notif_003",
            "title": "Payment Due",
            "body": "Premium payment of ₹2,500 is due in 3 days.",
            "type": "payment",
            "is_read": True
        },
        {
            "id": "notif_004",
            "title": "New Feature Available",
            "body": "Try our new claims filing feature with AI assistance.",
            "type": "marketing",
            "is_read": False
        }
    ]

@api_router.get("/test/agent/profile")
async def get_test_agent_profile():
    """Test endpoint for agent profile (no auth required)"""
    return {
        "agent_id": "test-agent-001",
        "user_id": "test-user-001",
        "agent_code": "AGENT001",
        "license_number": "LIC123456789",
        "license_expiry_date": "2025-12-31",
        "business_name": "Test Insurance Solutions",
        "territory": "Mumbai",
        "experience_years": 5,
        "total_policies_sold": 25,
        "total_premium_collected": 35500.0,
        "status": "active",
        "verification_status": "approved",
        "user_info": {
            "full_name": "John Doe",
            "phone_number": "+919876543210",
            "email": "john.doe@test.com"
        }
    }

# Include all endpoint routers
api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(providers.router, prefix="/providers", tags=["providers"])
api_router.include_router(agents.router, prefix="/agents", tags=["agents"])
api_router.include_router(policies.router, prefix="/policies", tags=["policies"])
api_router.include_router(presentations.router, prefix="/presentations", tags=["presentations"])
api_router.include_router(chat.router, prefix="/chat", tags=["chat"])
api_router.include_router(analytics.router, prefix="/analytics", tags=["analytics"])
api_router.include_router(feature_flags.router, tags=["feature-flags"])
api_router.include_router(health.router, tags=["health"])
api_router.include_router(notifications.router, tags=["notifications"])

