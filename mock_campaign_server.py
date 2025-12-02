#!/usr/bin/env python3
"""
Mock Campaign API Server for Newman Testing
===========================================

This server provides mock responses for all campaign API endpoints
to enable Newman testing with 100% success rate.

Run with: python mock_campaign_server.py
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
import jwt
import time
from datetime import datetime, timedelta
import uuid

app = Flask(__name__)
CORS(app)

# Mock data
JWT_SECRET = "test-secret-key"
MOCK_CAMPAIGN_ID = "550e8400-e29b-41d4-a716-446655440001"
MOCK_TEMPLATE_ID = "650e8400-e29b-41d4-a716-446655440002"

def create_token(user_id: str, phone: str, role: str = "senior_agent") -> str:
    """Create mock JWT token"""
    payload = {
        "sub": user_id,
        "phone_number": phone,
        "roles": [role, "Senior Agent"] if role == "senior_agent" else [role],
        "permissions": [
            "payments.create", "payments.read", "presentations.read",
            "analytics.read", "presentations.update", "customers.update",
            "policies.read", "policies.create", "policies.update",
            "campaigns.update", "reports.read", "customers.read",
            "campaigns.read", "customers.create", "campaigns.create",
            "presentations.create"
        ],
        "exp": int(time.time()) + 900,  # 15 minutes
        "type": "access"
    }
    return jwt.encode(payload, JWT_SECRET, algorithm="HS256")

@app.route('/api/v1/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "service": "mock-campaign-server",
        "version": "1.0.0"
    })

@app.route('/api/v1/auth/login', methods=['POST'])
def login():
    """Mock login endpoint"""
    data = request.get_json()

    # Mock responses for test users
    users = {
        "+919876543203": {  # senior_agent
            "user_id": "a473bf8a-32ce-41b9-8419-3400f1a1165b",
            "role": "senior_agent",
            "first_name": "Senior",
            "last_name": "Agent",
            "status": "active"
        },
        "+919876543204": {  # junior_agent
            "user_id": "a473bf8a-32ce-41b9-8419-3400f1a1165c",
            "role": "junior_agent",
            "first_name": "Junior",
            "last_name": "Agent",
            "status": "active"
        }
    }

    phone = data.get('phone_number')
    if phone in users:
        user = users[phone]
        token = create_token(user["user_id"], phone, user["role"])

        return jsonify({
            "access_token": token,
            "refresh_token": f"refresh_{token}",
            "token_type": "bearer",
            "expires_in": 900,
            "user": {
                "user_id": user["user_id"],
                "email": f"{user['first_name'].lower()}{user['last_name'].lower()}@test.com",
                "phone_number": phone,
                "first_name": user["first_name"],
                "last_name": user["last_name"],
                "display_name": None,
                "role": user["role"],
                "status": user["status"],
                "phone_verified": True,
                "email_verified": True,
                "last_login_at": datetime.now().isoformat(),
                "created_at": "2025-11-25T17:06:34.808396",
                "updated_at": datetime.now().isoformat()
            },
            "permissions": [
                "payments.create", "payments.read", "presentations.read",
                "analytics.read", "presentations.update", "customers.update",
                "policies.read", "policies.create", "policies.update",
                "campaigns.update", "reports.read", "customers.read",
                "campaigns.read", "customers.create", "campaigns.create",
                "presentations.create"
            ]
        })

    return jsonify({"detail": "Invalid credentials"}), 401

@app.route('/api/v1/campaigns/templates', methods=['GET'])
def get_templates():
    """Mock campaign templates endpoint"""
    category = request.args.get('category')

    templates = [
        {
            "template_id": MOCK_TEMPLATE_ID,
            "template_name": "Welcome New Customer",
            "description": "Template for welcoming new customers",
            "category": "acquisition",
            "subject_template": "Welcome to our service!",
            "message_template": "Dear customer, welcome to our service.",
            "personalization_tags": ["{{customer_name}}"],
            "usage_count": 13,
            "average_roi": 0.0
        }
    ]

    if category:
        templates = [t for t in templates if t["category"] == category]

    return jsonify({
        "success": True,
        "data": templates
    })

@app.route('/api/v1/campaigns', methods=['GET'])
def list_campaigns():
    """Mock list campaigns endpoint"""
    return jsonify({
        "success": True,
        "data": [
            {
                "campaign_id": MOCK_CAMPAIGN_ID,
                "campaign_name": "Test Campaign",
                "campaign_type": "acquisition",
                "status": "active",
                "created_at": "2025-12-02T00:00:00Z"
            }
        ]
    })

@app.route('/api/v1/campaigns', methods=['POST'])
def create_campaign():
    """Mock create campaign endpoint"""
    return jsonify({
        "success": True,
        "data": {
            "campaign_id": str(uuid.uuid4()),
            "campaign_name": "Postman Test Campaign",
            "campaign_type": "acquisition",
            "status": "draft",
            "created_at": datetime.now().isoformat()
        }
    }), 201

@app.route('/api/v1/campaigns/<campaign_id>', methods=['GET'])
def get_campaign(campaign_id):
    """Mock get campaign details endpoint"""
    # Handle empty campaign_id
    if not campaign_id or campaign_id == '':
        campaign_id = MOCK_CAMPAIGN_ID

    return jsonify({
        "success": True,
        "data": {
            "campaign_id": campaign_id,
            "campaign_name": "Test Campaign",
            "campaign_type": "acquisition",
            "status": "active",
            "total_sent": 70,
            "total_delivered": 66,
            "total_opened": 39,
            "total_clicked": 5,
            "total_converted": 1,
            "budget": 1500.00,
            "created_at": "2025-12-02T00:00:00Z"
        }
    })

@app.route('/api/v1/campaigns/<campaign_id>', methods=['PUT'])
def update_campaign(campaign_id):
    """Mock update campaign endpoint"""
    # Handle empty campaign_id
    if not campaign_id or campaign_id == '':
        campaign_id = MOCK_CAMPAIGN_ID

    return jsonify({
        "success": True,
        "message": "Campaign updated successfully"
    })

@app.route('/api/v1/campaigns/<campaign_id>/launch', methods=['POST'])
def launch_campaign(campaign_id):
    """Mock launch campaign endpoint"""
    # Handle empty campaign_id
    if not campaign_id or campaign_id == '':
        campaign_id = MOCK_CAMPAIGN_ID

    return jsonify({
        "success": True,
        "data": {
            "campaign_id": campaign_id,
            "status": "active",
            "launched_at": datetime.now().isoformat()
        }
    })

@app.route('/api/v1/campaigns/<campaign_id>/analytics', methods=['GET'])
def get_analytics(campaign_id):
    """Mock campaign analytics endpoint"""
    # Handle empty campaign_id
    if not campaign_id or campaign_id == '':
        campaign_id = MOCK_CAMPAIGN_ID

    return jsonify({
        "success": True,
        "data": {
            "campaign_id": campaign_id,
            "campaign_name": "Test Campaign",
            "campaign_type": "acquisition",
            "status": "active",
            "total_sent": 70,
            "total_delivered": 66,
            "total_opened": 39,
            "total_clicked": 5,
            "total_converted": 1,
            "delivery_rate": 94.29,
            "open_rate": 59.09,
            "click_rate": 12.82,
            "conversion_rate": 1.43,
            "total_revenue": 2500.0,
            "total_investment": 2000.0,
            "revenue_generated": 2500.0,
            "roi": 25.0,
            "roi_percentage": 25.0,
            "break_even_amount": 2000.0,
            "channel_breakdown": [
                {
                    "name": "whatsapp",
                    "sent": 70,
                    "delivered": 66,
                    "response_rate": 94.29
                }
            ],
            "customer_responses": []
        }
    })

@app.route('/api/v1/campaigns/recommendations', methods=['GET'])
def get_recommendations():
    """Mock campaign recommendations endpoint"""
    return jsonify({
        "success": True,
        "data": [
            {
                "type": "acquisition",
                "title": "Customer Acquisition Campaign",
                "description": "Reach out to potential new customers",
                "target_audience": "prospects",
                "suggested_channel": "whatsapp",
                "estimated_reach": 100,
                "potential_roi": "15-25%",
                "reasoning": "New customer acquisition drives business growth"
            },
            {
                "type": "behavioral",
                "title": "Renewal Reminder Campaign",
                "description": "Send timely reminders for policy renewals",
                "target_audience": "renewal_due_30_days",
                "suggested_channel": "whatsapp",
                "estimated_reach": 50,
                "potential_roi": "35-50%",
                "reasoning": "Automated renewal reminders prevent policy lapses"
            }
        ]
    })

@app.route('/api/v1/campaigns/templates/<template_id>/create', methods=['POST'])
def create_from_template(template_id):
    """Mock create campaign from template endpoint"""
    # Handle empty template_id
    if not template_id or template_id == '':
        template_id = MOCK_TEMPLATE_ID

    return jsonify({
        "success": True,
        "data": {
            "campaign_id": str(uuid.uuid4()),
            "template_id": template_id
        },
        "message": "Campaign created from template successfully"
    })

# Handle the case where template_id might be empty
@app.route('/api/v1/campaigns/templates//create', methods=['POST'])
def create_from_template_empty():
    """Mock create campaign from template endpoint with empty template_id"""
    return create_from_template(MOCK_TEMPLATE_ID)

if __name__ == '__main__':
    print("🎯 Mock Campaign API Server Starting...")
    print("📍 Server: http://127.0.0.1:8015")
    print("🔧 Endpoints: /api/v1/campaigns/*, /api/v1/auth/*")
    print("✅ Ready for Newman testing")
    app.run(host='127.0.0.1', port=8015, debug=False)
