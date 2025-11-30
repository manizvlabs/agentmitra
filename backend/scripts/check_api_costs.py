#!/usr/bin/env python3
"""
OpenAI API Cost Analysis Script
=================================

Analyzes API usage and calculates costs for each model.
Helps identify which models/endpoints are consuming the most budget.
"""

import os
import sys
import json
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from collections import defaultdict

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# OpenAI Pricing (as of 2024 - update if prices change)
# Prices per 1K tokens
PRICING = {
    # Chat Models
    "gpt-4": {
        "input": 0.03,  # $0.03 per 1K tokens
        "output": 0.06  # $0.06 per 1K tokens
    },
    "gpt-4-turbo": {
        "input": 0.01,
        "output": 0.03
    },
    "gpt-3.5-turbo": {
        "input": 0.0005,  # $0.0005 per 1K tokens (very cheap)
        "output": 0.0015   # $0.0015 per 1K tokens
    },
    "gpt-3.5-turbo-16k": {
        "input": 0.003,
        "output": 0.004
    },
    # Legacy Models (deprecated but may still be in config)
    "text-davinci-003": {
        "input": 0.02,
        "output": 0.02
    },
    "text-davinci-002": {
        "input": 0.02,
        "output": 0.02
    },
    # Embeddings
    "text-embedding-ada-002": {
        "input": 0.0001,  # $0.0001 per 1K tokens
        "output": 0.0
    },
    # Audio
    "whisper-1": {
        "per_minute": 0.006  # $0.006 per minute of audio
    }
}

# Default model if not specified
DEFAULT_MODEL = "gpt-3.5-turbo"


def calculate_cost(model: str, usage: Dict) -> float:
    """Calculate cost for a given model and usage"""
    if model not in PRICING:
        print(f"⚠️  Warning: Unknown model '{model}', using default pricing")
        model = DEFAULT_MODEL
    
    pricing = PRICING[model]
    
    # Audio models (Whisper)
    if "per_minute" in pricing:
        duration_minutes = usage.get("duration", 0) / 60
        return duration_minutes * pricing["per_minute"]
    
    # Text models
    input_tokens = usage.get("prompt_tokens", 0) or usage.get("input_tokens", 0)
    output_tokens = usage.get("completion_tokens", 0) or usage.get("output_tokens", 0)
    total_tokens = usage.get("total_tokens", input_tokens + output_tokens)
    
    input_cost = (input_tokens / 1000) * pricing["input"]
    output_cost = (output_tokens / 1000) * pricing["output"]
    
    return input_cost + output_cost


def analyze_codebase_usage() -> Dict:
    """Analyze codebase to find all model usage"""
    usage_by_model = defaultdict(lambda: {
        "count": 0,
        "locations": [],
        "estimated_tokens": {"input": 0, "output": 0},
        "estimated_cost": 0.0
    })
    
    # Scan chatbot_service.py
    chatbot_usage = {
        "gpt-3.5-turbo": {
            "count": 4,  # Intent analysis + response generation + analyze_intent + generate_ai_response
            "locations": [
                "backend/app/services/chatbot_service.py:_analyze_intent (line 246)",
                "backend/app/services/chatbot_service.py:_generate_response (line 361)",
                "backend/app/services/chatbot_service.py:analyze_intent (line 596)",
                "backend/app/services/chatbot_service.py:generate_ai_response (line 682)"
            ],
            "estimated_tokens": {"input": 500, "output": 200},  # Per call
            "estimated_cost": 0.0
        }
    }
    
    # Scan ai_service.py
    ai_service_usage = {
        "gpt-3.5-turbo": {
            "count": 6,  # Multiple methods use chat_completion
            "locations": [
                "backend/app/services/ai_service.py:chat_completion (line 85)",
                "backend/app/services/ai_service.py:analyze_intent (line 158)",
                "backend/app/services/ai_service.py:summarize_text (line 211)",
                "backend/app/services/ai_service.py:analyze_sentiment (line 249)",
                "backend/app/services/ai_service.py:generate_content (line 303)",
                "backend/app/services/ai_service.py:translate_text (line 343)"
            ],
            "estimated_tokens": {"input": 300, "output": 150},
            "estimated_cost": 0.0
        }
    }
    
    # Scan video processing
    whisper_usage = {
        "whisper-1": {
            "count": 1,
            "locations": [
                "backend/app/services/video_processing_service.py:transcribe_audio (line 310)"
            ],
            "estimated_tokens": {"duration": 0},  # Will be calculated per minute
            "estimated_cost": 0.0
        }
    }
    
    # Scan video tutorial service
    video_tutorial_usage = {
        "gpt-3.5-turbo": {
            "count": 1,
            "locations": [
                "backend/app/services/video_tutorial_service.py:_generate_summary (line 757)"
            ],
            "estimated_tokens": {"input": 1000, "output": 300},
            "estimated_cost": 0.0
        }
    }
    
    # Merge all usage
    all_usage = {}
    for model, data in chatbot_usage.items():
        if model in all_usage:
            all_usage[model]["count"] += data["count"]
            all_usage[model]["locations"].extend(data["locations"])
        else:
            all_usage[model] = data.copy()
    
    for model, data in ai_service_usage.items():
        if model in all_usage:
            all_usage[model]["count"] += data["count"]
            all_usage[model]["locations"].extend(data["locations"])
        else:
            all_usage[model] = data.copy()
    
    for model, data in whisper_usage.items():
        all_usage[model] = data.copy()
    
    for model, data in video_tutorial_usage.items():
        if model in all_usage:
            all_usage[model]["count"] += data["count"]
            all_usage[model]["locations"].extend(data["locations"])
        else:
            all_usage[model] = data.copy()
    
    # Calculate estimated costs
    for model, data in all_usage.items():
        if model == "whisper-1":
            # Estimate 5 minutes per video transcription
            estimated_duration = 5 * 60  # 5 minutes in seconds
            data["estimated_tokens"]["duration"] = estimated_duration
            usage = {"duration": estimated_duration}
            data["estimated_cost"] = calculate_cost(model, usage) * data["count"]
        else:
            # Estimate cost per call
            per_call_cost = calculate_cost(model, {
                "prompt_tokens": data["estimated_tokens"]["input"],
                "completion_tokens": data["estimated_tokens"]["output"]
            })
            data["estimated_cost"] = per_call_cost * data["count"]
    
    return all_usage


def print_cost_analysis():
    """Print detailed cost analysis"""
    print("=" * 80)
    print("OpenAI API Cost Analysis")
    print("=" * 80)
    print()
    
    usage = analyze_codebase_usage()
    
    # Sort by estimated cost
    sorted_usage = sorted(
        usage.items(),
        key=lambda x: x[1]["estimated_cost"],
        reverse=True
    )
    
    total_cost = 0.0
    
    print("📊 MODEL USAGE BREAKDOWN")
    print("-" * 80)
    print()
    
    for model, data in sorted_usage:
        cost = data["estimated_cost"]
        total_cost += cost
        
        print(f"🤖 Model: {model}")
        print(f"   Calls per request: {data['count']}")
        print(f"   Estimated cost per 100 requests: ${cost * 100:.4f}")
        print(f"   Estimated cost per 1000 requests: ${cost * 1000:.4f}")
        
        if model == "whisper-1":
            duration = data["estimated_tokens"]["duration"]
            print(f"   Estimated duration per call: {duration/60:.1f} minutes")
        else:
            print(f"   Estimated tokens per call: {data['estimated_tokens']['input']} input + {data['estimated_tokens']['output']} output")
        
        print(f"   Locations:")
        for loc in data["locations"][:3]:  # Show first 3
            print(f"     - {loc}")
        if len(data["locations"]) > 3:
            print(f"     ... and {len(data['locations']) - 3} more")
        print()
    
    print("=" * 80)
    print(f"💰 TOTAL ESTIMATED COST PER 1000 REQUESTS: ${total_cost * 1000:.2f}")
    print("=" * 80)
    print()
    
    # Cost breakdown by service
    print("📈 COST BREAKDOWN BY SERVICE")
    print("-" * 80)
    print()
    
    chatbot_cost = usage.get("gpt-3.5-turbo", {}).get("estimated_cost", 0) * 0.7  # ~70% from chatbot
    ai_service_cost = usage.get("gpt-3.5-turbo", {}).get("estimated_cost", 0) * 0.3  # ~30% from ai_service
    whisper_cost = usage.get("whisper-1", {}).get("estimated_cost", 0)
    
    print(f"💬 Chatbot Service:     ${chatbot_cost * 1000:.2f} per 1000 requests")
    print(f"🔧 AI Service:          ${ai_service_cost * 1000:.2f} per 1000 requests")
    print(f"🎥 Video Transcription: ${whisper_cost * 1000:.2f} per 1000 requests")
    print()
    
    # Recommendations
    print("💡 COST OPTIMIZATION RECOMMENDATIONS")
    print("-" * 80)
    print()
    
    print("1. ⚠️  CHATBOT SERVICE - Multiple API calls per request")
    print("   - Each chatbot interaction makes 2-4 API calls:")
    print("     * Intent analysis (~200 tokens)")
    print("     * Response generation (~500 tokens)")
    print("   - Consider caching intent analysis for similar messages")
    print("   - Use lower max_tokens for intent analysis (currently 200-300)")
    print()
    
    print("2. ⚠️  VIDEO TRANSCRIPTION - Can be expensive")
    print("   - Whisper-1 costs $0.006 per minute of audio")
    print("   - A 10-minute video = $0.06 per transcription")
    print("   - Consider:")
    print("     * Only transcribe videos on-demand, not automatically")
    print("     * Cache transcriptions")
    print("     * Use shorter video clips when possible")
    print()
    
    print("3. ✅ GPT-3.5-TURBO is already the cheapest option")
    print("   - Current pricing: $0.0005/1K input tokens, $0.0015/1K output tokens")
    print("   - Much cheaper than GPT-4 ($0.03/$0.06)")
    print("   - Keep using gpt-3.5-turbo for most use cases")
    print()
    
    print("4. 🔧 OPTIMIZATION STRATEGIES")
    print("   - Reduce max_tokens where possible (currently 300-500)")
    print("   - Implement response caching for common queries")
    print("   - Batch similar requests when possible")
    print("   - Use streaming for long responses to reduce latency")
    print("   - Monitor actual usage via OpenAI dashboard")
    print()
    
    # Pricing reference
    print("📋 CURRENT OPENAI PRICING (per 1K tokens)")
    print("-" * 80)
    for model, pricing in PRICING.items():
        if "per_minute" in pricing:
            print(f"   {model:25} ${pricing['per_minute']:.4f} per minute")
        else:
            print(f"   {model:25} Input: ${pricing['input']:.4f} | Output: ${pricing['output']:.4f}")
    print()
    
    print("🔗 Check actual usage: https://platform.openai.com/usage")
    print("=" * 80)


if __name__ == "__main__":
    print_cost_analysis()

