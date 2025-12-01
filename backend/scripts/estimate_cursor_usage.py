#!/usr/bin/env python3
"""
Cursor Subscription Usage Estimator
====================================

Helps estimate how long your Cursor Pro+ subscription will last
based on your usage patterns.
"""

def estimate_subscription_duration():
    """Estimate subscription duration based on usage"""
    
    print("=" * 80)
    print("Cursor Pro+ Subscription Usage Estimator")
    print("=" * 80)
    print()
    
    # Get user input
    print("📊 Enter your usage information:")
    print()
    
    try:
        requests_last_2_weeks = int(input("How many AI requests did you make in the last 2 weeks? "))
        pro_plus_monthly_limit = int(input("What's your Pro+ monthly request limit? (check Cursor settings) "))
        
        # Calculate
        requests_per_week = requests_last_2_weeks / 2
        requests_per_month = requests_per_week * 4.33  # Average weeks per month
        
        months_remaining = pro_plus_monthly_limit / requests_per_month if requests_per_month > 0 else 0
        days_remaining = months_remaining * 30
        
        print()
        print("=" * 80)
        print("📈 USAGE ANALYSIS")
        print("=" * 80)
        print()
        print(f"Your usage rate:")
        print(f"  • Requests per week: {requests_per_week:.1f}")
        print(f"  • Requests per month: {requests_per_month:.1f}")
        print()
        print(f"Pro+ Subscription:")
        print(f"  • Monthly limit: {pro_plus_monthly_limit:,} requests")
        print(f"  • Your monthly usage: {requests_per_month:.1f} requests")
        print(f"  • Usage percentage: {(requests_per_month/pro_plus_monthly_limit)*100:.1f}%")
        print()
        print("=" * 80)
        print("⏱️  ESTIMATED DURATION")
        print("=" * 80)
        print()
        
        if requests_per_month <= pro_plus_monthly_limit:
            print(f"✅ You're within limits!")
            print(f"   Estimated months remaining: {months_remaining:.1f}")
            print(f"   Estimated days remaining: {days_remaining:.0f}")
            print()
            print(f"💡 At your current usage rate, Pro+ will last approximately:")
            print(f"   • {int(months_remaining)} months and {int((months_remaining % 1) * 30)} days")
        else:
            overage = requests_per_month - pro_plus_monthly_limit
            print(f"⚠️  You're exceeding your monthly limit!")
            print(f"   Monthly overage: {overage:.1f} requests")
            print(f"   You'll need to reduce usage or upgrade")
        
        print()
        print("=" * 80)
        print("💡 TIPS TO OPTIMIZE USAGE")
        print("=" * 80)
        print()
        print("1. Batch similar requests together")
        print("2. Use codebase search before asking questions")
        print("3. Review code yourself first, then ask specific questions")
        print("4. Use smaller, focused requests instead of large ones")
        print("5. Check Cursor settings for usage dashboard")
        print()
        
    except ValueError:
        print("❌ Invalid input. Please enter numbers only.")
    except KeyboardInterrupt:
        print("\n\nCancelled.")
    except Exception as e:
        print(f"❌ Error: {e}")


if __name__ == "__main__":
    estimate_subscription_duration()





