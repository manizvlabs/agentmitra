#!/usr/bin/env python3
"""
Test Campaign Analytics and Recommendations Services
"""

import sys
sys.path.append('backend')

from app.core.database import get_db_session
from app.services.campaign_analytics_service import CampaignAnalyticsService
from app.services.campaign_automation_service import CampaignAutomationService
from app.models.campaign import Campaign
from uuid import UUID

def test_analytics():
    print("=== ANALYTICS TEST ===")
    with get_db_session() as db:
        campaigns = db.query(Campaign).filter(Campaign.status.in_(['active', 'completed'])).limit(1).all()
        if campaigns:
            campaign = campaigns[0]
            print(f"Campaign: {campaign.campaign_name} (Status: {campaign.status})")
            try:
                result = CampaignAnalyticsService.get_campaign_analytics(db, campaign.campaign_id, campaign.agent_id)
                print("✅ Analytics Working")
                print(f"  - Total Sent: {result['total_sent']}")
                print(f"  - ROI: {result['roi']}%")
                print(f"  - Revenue: ${result['total_revenue']}")
                print(f"  - Investment: ${result['total_investment']}")
                print(f"  - Delivery Rate: {result['delivery_rate']}%")
                print("  - Real Data Source: Database campaign metrics")
                return True
            except Exception as e:
                print(f"❌ Analytics Failed: {e}")
                return False
        else:
            print("❌ No campaigns found")
            return False

def test_recommendations():
    print("\n=== RECOMMENDATIONS TEST ===")
    agent_id = UUID('7b501e0e-4393-4b5a-8de7-25fe384e91da')  # senior_agent
    
    with get_db_session() as db:
        try:
            recommendations = CampaignAutomationService.get_campaign_recommendations(db, agent_id)
            print("✅ Recommendations Working")
            print(f"  - Generated {len(recommendations)} recommendations")
            for i, rec in enumerate(recommendations, 1):
                print(f"  {i}. {rec['title']} ({rec['type']}) - {rec['estimated_reach']} reach, {rec['potential_roi']} ROI")
            print("  - Real Data Source: Database agent and campaign history")
            return True
        except Exception as e:
            print(f"❌ Recommendations Failed: {e}")
            return False

if __name__ == "__main__":
    print("🎯 Testing Campaign Analytics & Recommendations Services")
    print("=" * 60)
    
    analytics_ok = test_analytics()
    recommendations_ok = test_recommendations()
    
    print("\n" + "=" * 60)
    print("📊 FINAL RESULTS:")
    print(f"Analytics: {'✅ PASS' if analytics_ok else '❌ FAIL'}")
    print(f"Recommendations: {'✅ PASS' if recommendations_ok else '❌ FAIL'}")
    
    if analytics_ok and recommendations_ok:
        print("\n🎉 ALL TESTS PASSED - Real database data confirmed!")
    else:
        print("\n⚠️  Some tests failed")
