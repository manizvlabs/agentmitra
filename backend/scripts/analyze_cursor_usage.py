#!/usr/bin/env python3
"""
Analyze Cursor Usage from Timestamps
"""

from datetime import datetime
from collections import defaultdict

# Sample timestamps from the image (first and last few)
timestamps = [
    "2025-11-28T16:22:34.633Z",
    "2025-11-30T02:32:26.063Z"
]

def analyze_usage():
    """Analyze usage patterns"""
    
    # Based on the image: 150 requests over ~1.4 days
    total_requests = 150
    
    # Time span calculation
    start = datetime.fromisoformat("2025-11-28T16:22:34.633Z".replace('Z', '+00:00'))
    end = datetime.fromisoformat("2025-11-30T02:32:26.063Z".replace('Z', '+00:00'))
    
    time_span = end - start
    hours = time_span.total_seconds() / 3600
    days = hours / 24
    
    # Calculate rates
    requests_per_hour = total_requests / hours
    requests_per_day = total_requests / days
    requests_per_week = requests_per_day * 7
    requests_per_month = requests_per_day * 30
    
    print("=" * 80)
    print("📊 CURSOR USAGE ANALYSIS")
    print("=" * 80)
    print()
    print(f"Data Period: {start.strftime('%Y-%m-%d %H:%M')} to {end.strftime('%Y-%m-%d %H:%M')}")
    print(f"Total Requests: {total_requests}")
    print(f"Time Span: {days:.2f} days ({hours:.1f} hours)")
    print()
    print("=" * 80)
    print("📈 USAGE RATES")
    print("=" * 80)
    print()
    print(f"  • Requests per hour: {requests_per_hour:.1f}")
    print(f"  • Requests per day: {requests_per_day:.1f}")
    print(f"  • Requests per week: {requests_per_week:.0f}")
    print(f"  • Requests per month: {requests_per_month:.0f}")
    print()
    
    # Estimate for different Pro+ limits
    print("=" * 80)
    print("⏱️  ESTIMATED DURATION (Pro+ Subscription)")
    print("=" * 80)
    print()
    
    limits = [
        (500, "Basic Pro+"),
        (1000, "Standard Pro+"),
        (2000, "Premium Pro+"),
        (5000, "Enterprise")
    ]
    
    for limit, plan_name in limits:
        days_remaining = limit / requests_per_day if requests_per_day > 0 else 0
        months_remaining = days_remaining / 30
        
        if days_remaining >= 1:
            print(f"{plan_name} ({limit:,} requests/month):")
            print(f"  • Days remaining: {days_remaining:.1f}")
            print(f"  • Months remaining: {months_remaining:.2f}")
            print(f"  • Usage: {(requests_per_month/limit)*100:.1f}% of monthly limit")
            print()
        else:
            print(f"{plan_name} ({limit:,} requests/month):")
            print(f"  • ⚠️  EXCEEDS LIMIT by {requests_per_month - limit:.0f} requests/month")
            print()
    
    print("=" * 80)
    print("💡 RECOMMENDATIONS")
    print("=" * 80)
    print()
    
    if requests_per_month > 2000:
        print("⚠️  HIGH USAGE DETECTED")
        print()
        print("Your usage rate is quite high. Consider:")
        print("  1. Batching multiple questions into single requests")
        print("  2. Using codebase search before asking questions")
        print("  3. Reviewing code yourself first, then asking specific questions")
        print("  4. Using smaller, focused requests instead of large ones")
        print("  5. Checking if you're making redundant requests")
    else:
        print("✅ Your usage rate is reasonable for active development")
        print("   Continue using Cursor efficiently!")
    
    print()

if __name__ == "__main__":
    analyze_usage()





