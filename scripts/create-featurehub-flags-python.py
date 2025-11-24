#!/usr/bin/env python3
"""
FeatureHub Admin Service - Python Implementation
Creates feature flags programmatically using FeatureHub Admin API

This service works around the current 500 server error by:
1. Using correct endpoint structure from OpenAPI spec
2. Providing clear error messages
3. Being ready to work once server issue is resolved
"""

import httpx
import asyncio
import json
import os
import sys
from typing import Dict, List, Optional, Any
from pathlib import Path

# Default feature flags to create
DEFAULT_FEATURES = [
    {"name": "Phone Authentication", "key": "phone_auth_enabled", "valueType": "BOOLEAN", "description": "Enable phone number-based authentication"},
    {"name": "Email Authentication", "key": "email_auth_enabled", "valueType": "BOOLEAN", "description": "Enable email-based authentication"},
    {"name": "OTP Verification", "key": "otp_verification_enabled", "valueType": "BOOLEAN", "description": "Enable OTP verification"},
    {"name": "Biometric Authentication", "key": "biometric_auth_enabled", "valueType": "BOOLEAN", "description": "Enable biometric authentication"},
    {"name": "MPIN Authentication", "key": "mpin_auth_enabled", "valueType": "BOOLEAN", "description": "Enable MPIN authentication"},
    {"name": "Agent Code Login", "key": "agent_code_login_enabled", "valueType": "BOOLEAN", "description": "Enable agent code login"},
    {"name": "Dashboard", "key": "dashboard_enabled", "valueType": "BOOLEAN", "description": "Enable dashboard features"},
    {"name": "Policies", "key": "policies_enabled", "valueType": "BOOLEAN", "description": "Enable policies management"},
    {"name": "Payments", "key": "payments_enabled", "valueType": "BOOLEAN", "description": "Enable payment features"},
    {"name": "Chat", "key": "chat_enabled", "valueType": "BOOLEAN", "description": "Enable chat features"},
    {"name": "Notifications", "key": "notifications_enabled", "valueType": "BOOLEAN", "description": "Enable notifications"},
    {"name": "Presentation Carousel", "key": "presentation_carousel_enabled", "valueType": "BOOLEAN", "description": "Enable presentation carousel"},
    {"name": "Presentation Editor", "key": "presentation_editor_enabled", "valueType": "BOOLEAN", "description": "Enable presentation editor"},
    {"name": "Presentation Templates", "key": "presentation_templates_enabled", "valueType": "BOOLEAN", "description": "Enable presentation templates"},
    {"name": "Presentation Offline Mode", "key": "presentation_offline_mode_enabled", "valueType": "BOOLEAN", "description": "Enable offline mode for presentations"},
    {"name": "Presentation Analytics", "key": "presentation_analytics_enabled", "valueType": "BOOLEAN", "description": "Enable presentation analytics"},
    {"name": "Presentation Branding", "key": "presentation_branding_enabled", "valueType": "BOOLEAN", "description": "Enable presentation branding"},
    {"name": "WhatsApp Integration", "key": "whatsapp_integration_enabled", "valueType": "BOOLEAN", "description": "Enable WhatsApp integration"},
    {"name": "Chatbot", "key": "chatbot_enabled", "valueType": "BOOLEAN", "description": "Enable chatbot features"},
    {"name": "Callback Management", "key": "callback_management_enabled", "valueType": "BOOLEAN", "description": "Enable callback management"},
    {"name": "Analytics", "key": "analytics_enabled", "valueType": "BOOLEAN", "description": "Enable analytics features"},
    {"name": "ROI Dashboards", "key": "roi_dashboards_enabled", "valueType": "BOOLEAN", "description": "Enable ROI dashboards"},
    {"name": "Smart Dashboards", "key": "smart_dashboards_enabled", "valueType": "BOOLEAN", "description": "Enable smart dashboards"},
    {"name": "Portal", "key": "portal_enabled", "valueType": "BOOLEAN", "description": "Enable portal features"},
    {"name": "Data Import", "key": "data_import_enabled", "valueType": "BOOLEAN", "description": "Enable data import features"},
    {"name": "Excel Template Config", "key": "excel_template_config_enabled", "valueType": "BOOLEAN", "description": "Enable Excel template configuration"},
    {"name": "Debug Mode", "key": "debug_mode", "valueType": "BOOLEAN", "description": "Enable debug mode"},
    {"name": "Enable Logging", "key": "enable_logging", "valueType": "BOOLEAN", "description": "Enable logging"},
    {"name": "Development Tools", "key": "development_tools_enabled", "valueType": "BOOLEAN", "description": "Enable development tools"},
]


class FeatureHubAdminService:
    """FeatureHub Admin Service using REST API"""
    
    def __init__(self, base_url: str, admin_token: str, application_id: str):
        self.base_url = base_url.rstrip('/')
        self.admin_token = admin_token
        self.application_id = application_id
        self.endpoint = f"{self.base_url}/mr-api/application/{self.application_id}/features"
        
    async def create_feature(
        self,
        name: str,
        key: str,
        value_type: str = "BOOLEAN",
        description: Optional[str] = None
    ) -> Dict[str, Any]:
        """Create a single feature flag"""
        headers = {
            "Authorization": f"Bearer {self.admin_token}",
            "Content-Type": "application/json",
            "Accept": "application/json"
        }
        
        payload = {
            "name": name,
            "key": key,
            "valueType": value_type
        }
        
        if description:
            payload["description"] = description
        
        async with httpx.AsyncClient(timeout=30.0, follow_redirects=True) as client:
            try:
                response = await client.post(self.endpoint, json=payload, headers=headers)
                
                if response.status_code in [200, 201]:
                    try:
                        return {"success": True, "data": response.json()}
                    except:
                        return {"success": True, "data": response.text}
                elif response.status_code == 400:
                    error_msg = response.text or "Bad Request"
                    try:
                        error_data = response.json()
                        error_msg = json.dumps(error_data, indent=2)
                    except:
                        pass
                    return {"success": False, "error": f"400 Bad Request: {error_msg}"}
                elif response.status_code == 500:
                    return {
                        "success": False,
                        "error": "500 Server Error - FeatureHub SaaS server-side issue. Please contact FeatureHub support or use dashboard to create flags manually.",
                        "details": "The endpoint exists but returns 500. This is a server-side issue, not a client issue."
                    }
                else:
                    return {"success": False, "error": f"{response.status_code}: {response.text[:500]}"}
            except Exception as e:
                return {"success": False, "error": f"Exception: {type(e).__name__}: {str(e)}"}
    
    async def create_all_features(self) -> Dict[str, Any]:
        """Create all default feature flags"""
        results = {
            "created": [],
            "failed": [],
            "total": len(DEFAULT_FEATURES)
        }
        
        print("="*80)
        print("CREATING FEATURE FLAGS")
        print("="*80)
        print(f"Endpoint: {self.endpoint}")
        print(f"Total features: {len(DEFAULT_FEATURES)}\n")
        
        for feature in DEFAULT_FEATURES:
            print(f"Creating: {feature['key']}...", end=" ", flush=True)
            result = await self.create_feature(
                name=feature["name"],
                key=feature["key"],
                value_type=feature["valueType"],
                description=feature.get("description")
            )
            
            if result["success"]:
                print("✅")
                results["created"].append(feature["key"])
            else:
                print(f"❌ {result['error'][:100]}")
                results["failed"].append({
                    "key": feature["key"],
                    "error": result["error"]
                })
        
        return results


async def main():
    """Main entry point"""
    # Load configuration from environment
    base_url = os.getenv("FEATUREHUB_ADMIN_SDK_URL", "https://app.featurehub.io/vanilla/913a7a7d-3523-4f7b-85ca-9564ad10e858")
    admin_token = os.getenv("FEATUREHUB_ADMIN_TOKEN")
    sdk_key = os.getenv("FEATUREHUB_SDK_KEY", "")
    
    if not admin_token:
        print("❌ Error: FEATUREHUB_ADMIN_TOKEN not set")
        sys.exit(1)
    
    # Extract application ID from SDK key
    if sdk_key:
        parts = sdk_key.split('/')
        if len(parts) >= 1:
            application_id = parts[0]
        else:
            print("❌ Error: Invalid SDK key format")
            sys.exit(1)
    else:
        # Default application ID
        application_id = "4538b168-ba55-4ae8-a815-f99f03fd630a"
    
    print("="*80)
    print("FEATUREHUB ADMIN SERVICE (Python)")
    print("="*80)
    print(f"Base URL: {base_url}")
    print(f"Application ID: {application_id}")
    print()
    
    service = FeatureHubAdminService(base_url, admin_token, application_id)
    results = await service.create_all_features()
    
    print("\n" + "="*80)
    print("RESULTS")
    print("="*80)
    print(f"✅ Created: {len(results['created'])} flags")
    print(f"❌ Failed: {len(results['failed'])} flags")
    print(f"Total: {results['total']}")
    
    if results['failed']:
        print("\nFailed flags:")
        for failure in results['failed']:
            print(f"  ❌ {failure['key']}: {failure['error'][:100]}")
    
    if results['created']:
        print(f"\n✅ Successfully created {len(results['created'])} feature flags!")
    else:
        print("\n⚠️  No features were created. All requests returned errors.")
        print("\nPossible reasons:")
        print("1. Server-side 500 error (current issue)")
        print("2. Authentication/permissions issue")
        print("3. Application ID incorrect")
        print("\nRecommendation:")
        print("- Use FeatureHub dashboard to create flags manually")
        print("- Contact FeatureHub support about Admin SDK POST operations for SaaS")


if __name__ == "__main__":
    asyncio.run(main())

